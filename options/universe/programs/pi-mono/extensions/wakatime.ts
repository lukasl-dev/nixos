import {
	type ExtensionAPI,
	isEditToolResult,
	isReadToolResult,
	isWriteToolResult,
} from "@mariozechner/pi-coding-agent";
import { createHash } from "node:crypto";
import { mkdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";

type TrackedFileChange = {
	entity: string;
	lineChanges?: number;
	isWrite?: boolean;
};

type GenericToolResultEvent = {
	toolName: string;
	input: Record<string, unknown>;
	details?: unknown;
	content: Array<{ type: string; text?: string }>;
};

type ProjectState = {
	lastHeartbeatAt?: number;
};

const HEARTBEAT_INTERVAL_SECONDS = 60;
const STATE_PREFIX = "pi-mono-wakatime";
const PI_VERSION = "0.1.0";
const PLUGIN_NAME = `pi/${PI_VERSION} pi-mono-wakatime/${PI_VERSION}`;

let currentProjectFolder = process.cwd();
let pendingChanges = new Map<string, TrackedFileChange>();
let cliChecked = false;
let cliAvailable = false;

function getWakaHome(): string {
	return process.env.WAKATIME_HOME || join(process.env.HOME || ".", ".wakatime");
}

function getStateFile(projectFolder: string): string {
	const hash = createHash("md5").update(projectFolder).digest("hex").slice(0, 8);
	return join(getWakaHome(), `${STATE_PREFIX}-${hash}.json`);
}

function readProjectState(projectFolder: string): ProjectState {
	try {
		return JSON.parse(readFileSync(getStateFile(projectFolder), "utf8")) as ProjectState;
	} catch {
		return {};
	}
}

function writeProjectState(projectFolder: string, state: ProjectState): void {
	try {
		const file = getStateFile(projectFolder);
		mkdirSync(dirname(file), { recursive: true });
		writeFileSync(file, JSON.stringify(state, null, 2));
	} catch {
		// ignore state write failures
	}
}

function nowSeconds(): number {
	return Math.floor(Date.now() / 1000);
}

function shouldSendHeartbeat(projectFolder: string, force: boolean): boolean {
	if (force) return true;
	const state = readProjectState(projectFolder);
	const lastHeartbeatAt = state.lastHeartbeatAt ?? 0;
	return nowSeconds() - lastHeartbeatAt >= HEARTBEAT_INTERVAL_SECONDS;
}

function markHeartbeatSent(projectFolder: string): void {
	writeProjectState(projectFolder, { lastHeartbeatAt: nowSeconds() });
}

async function ensureCli(pi: ExtensionAPI): Promise<boolean> {
	if (cliChecked) return cliAvailable;
	cliChecked = true;

	try {
		const result = await pi.exec("wakatime-cli", ["--version"], { timeout: 5000 });
		cliAvailable = result.code === 0;
	} catch {
		cliAvailable = false;
	}

	return cliAvailable;
}

function countLines(text: string): number {
	if (!text) return 0;
	return text.split("\n").length;
}

function parseUnifiedDiffStats(diff: string): { additions: number; deletions: number } {
	let additions = 0;
	let deletions = 0;

	for (const line of diff.split("\n")) {
		if (line.startsWith("+++") || line.startsWith("---") || line.startsWith("@@")) continue;
		if (line.startsWith("+")) additions++;
		else if (line.startsWith("-")) deletions++;
	}

	return { additions, deletions };
}

function extractTextContent(event: GenericToolResultEvent): string {
	return event.content
		.filter((item) => item.type === "text" && typeof item.text === "string")
		.map((item) => item.text ?? "")
		.join("\n");
}

function asRecord(value: unknown): Record<string, unknown> | undefined {
	return value && typeof value === "object" && !Array.isArray(value) ? (value as Record<string, unknown>) : undefined;
}

function asArray(value: unknown): unknown[] | undefined {
	return Array.isArray(value) ? value : undefined;
}

function extractPatchChanges(event: GenericToolResultEvent, cwd: string): TrackedFileChange[] {
	const changes: TrackedFileChange[] = [];
	const details = asRecord(event.details);
	const patches = asArray(details?.patches) ?? asArray(details?.changes) ?? asArray(details?.results);
	const seen = new Set<string>();

	if (patches) {
		for (const patch of patches) {
			const record = asRecord(patch);
			const pathValue = record?.path ?? record?.file ?? record?.filePath;
			if (typeof pathValue !== "string") continue;
			const entity = resolve(cwd, pathValue);
			if (seen.has(entity)) continue;
			seen.add(entity);

			const diff = typeof record?.diff === "string" ? record.diff : "";
			const stats = parseUnifiedDiffStats(diff);
			changes.push({
				entity,
				lineChanges: stats.additions - stats.deletions,
				isWrite: true,
			});
		}
	}

	if (changes.length > 0) return changes;

	const text = extractTextContent(event);
	for (const line of text.split("\n")) {
		const trimmed = line.trim();
		if (!trimmed || trimmed.includes(" ")) continue;
		if (!(trimmed.includes("/") || trimmed.includes("."))) continue;
		const entity = resolve(cwd, trimmed);
		if (seen.has(entity)) continue;
		seen.add(entity);
		changes.push({ entity, isWrite: true });
	}

	return changes;
}

function extractMultieditChanges(event: GenericToolResultEvent, cwd: string): TrackedFileChange[] {
	const changes: TrackedFileChange[] = [];
	const seen = new Set<string>();
	const details = asRecord(event.details);
	const results = asArray(details?.results) ?? asArray(details?.edits) ?? asArray(details?.changes);

	if (!results) return changes;

	for (const item of results) {
		const record = asRecord(item);
		const pathValue = record?.path ?? record?.file ?? record?.filePath;
		if (typeof pathValue !== "string") continue;
		const entity = resolve(cwd, pathValue);
		if (seen.has(entity)) continue;
		seen.add(entity);

		const diff = typeof record?.diff === "string" ? record.diff : "";
		const stats = parseUnifiedDiffStats(diff);
		changes.push({
			entity,
			lineChanges: stats.additions - stats.deletions,
			isWrite: true,
		});
	}

	return changes;
}

async function resolveProjectFolder(pi: ExtensionAPI, cwd: string): Promise<string> {
	try {
		const result = await pi.exec("git", ["-C", cwd, "rev-parse", "--show-toplevel"], { timeout: 3000 });
		if (result.code === 0) {
			const root = result.stdout.trim();
			if (root) return root;
		}
	} catch {
		// ignore
	}
	return cwd;
}

function isProbablyFile(path: string): boolean {
	try {
		return !statSync(path).isDirectory();
	} catch {
		// If it doesn't exist anymore, still treat it as a file path heartbeat.
		return true;
	}
}

function queueChange(change: TrackedFileChange): void {
	if (!change.entity || !isProbablyFile(change.entity)) return;

	const existing = pendingChanges.get(change.entity);
	if (!existing) {
		pendingChanges.set(change.entity, change);
		return;
	}

	pendingChanges.set(change.entity, {
		entity: change.entity,
		lineChanges: (existing.lineChanges ?? 0) + (change.lineChanges ?? 0),
		isWrite: existing.isWrite || change.isWrite,
	});
}

async function sendHeartbeat(
	pi: ExtensionAPI,
	projectFolder: string,
	change: TrackedFileChange,
): Promise<void> {
	const args = [
		"--entity",
		change.entity,
		"--entity-type",
		"file",
		"--category",
		"ai coding",
		"--plugin",
		PLUGIN_NAME,
		"--project-folder",
		projectFolder,
	];

	if (typeof change.lineChanges === "number" && change.lineChanges !== 0) {
		args.push("--ai-line-changes", String(change.lineChanges));
	}

	if (change.isWrite) {
		args.push("--write");
	}

	try {
		await pi.exec("wakatime-cli", args, { timeout: 10000 });
	} catch {
		// never break the session on heartbeat failures
	}
}

async function flushHeartbeats(pi: ExtensionAPI, force = false): Promise<void> {
	if (pendingChanges.size === 0) return;
	if (!(await ensureCli(pi))) return;
	if (!shouldSendHeartbeat(currentProjectFolder, force)) return;

	const changes = Array.from(pendingChanges.values());
	pendingChanges.clear();

	for (const change of changes) {
		await sendHeartbeat(pi, currentProjectFolder, change);
	}

	markHeartbeatSent(currentProjectFolder);
}

export default function wakatimeExtension(pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		currentProjectFolder = await resolveProjectFolder(pi, ctx.cwd);
		pendingChanges = new Map();
		await ensureCli(pi);
	});

	pi.on("tool_result", async (event, ctx) => {
		if (isReadToolResult(event)) {
			const path = typeof event.input.path === "string" ? resolve(ctx.cwd, event.input.path) : undefined;
			if (path) queueChange({ entity: path });
		}

		if (isEditToolResult(event)) {
			const path = typeof event.input.path === "string" ? resolve(ctx.cwd, event.input.path) : undefined;
			if (path) {
				const stats = parseUnifiedDiffStats(event.details?.diff ?? "");
				queueChange({
					entity: path,
					lineChanges: stats.additions - stats.deletions,
					isWrite: true,
				});
			}
		}

		if (isWriteToolResult(event)) {
			const path = typeof event.input.path === "string" ? resolve(ctx.cwd, event.input.path) : undefined;
			const content = typeof event.input.content === "string" ? event.input.content : "";
			if (path) {
				queueChange({
					entity: path,
					lineChanges: countLines(content),
					isWrite: true,
				});
			}
		}

		const genericEvent = event as GenericToolResultEvent;
		if (genericEvent.toolName === "multiedit") {
			for (const change of extractMultieditChanges(genericEvent, ctx.cwd)) {
				queueChange(change);
			}
		}

		if (genericEvent.toolName === "patch") {
			for (const change of extractPatchChanges(genericEvent, ctx.cwd)) {
				queueChange(change);
			}
		}

		await flushHeartbeats(pi, false);
	});

	pi.on("agent_end", async () => {
		await flushHeartbeats(pi, true);
	});

	pi.on("session_shutdown", async () => {
		await flushHeartbeats(pi, true);
	});

	pi.registerCommand("wakatime-status", {
		description: "Show WakaTime extension status",
		handler: async (_args, ctx) => {
			const hasCli = await ensureCli(pi);
			const stateFile = getStateFile(currentProjectFolder);
			const state = readProjectState(currentProjectFolder);
			const lines = [
				`wakatime-cli: ${hasCli ? "available" : "missing"}`,
				`project: ${currentProjectFolder}`,
				`pending entities: ${pendingChanges.size}`,
				`last heartbeat: ${state.lastHeartbeatAt ? new Date(state.lastHeartbeatAt * 1000).toLocaleString() : "never"}`,
				`state file: ${stateFile}`,
			];

			if (!hasCli) {
				lines.push("Install wakatime-cli and configure ~/.wakatime.cfg to enable heartbeats.");
			}

			ctx.ui.notify(lines.join("\n"), hasCli ? "info" : "warning");
		},
	});
}
