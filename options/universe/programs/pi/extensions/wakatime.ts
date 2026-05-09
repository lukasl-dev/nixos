import {
	type ExtensionAPI,
	isEditToolResult,
	isReadToolResult,
	isWriteToolResult,
} from "@mariozechner/pi-coding-agent";
import { createHash } from "node:crypto";
import { mkdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { basename, dirname, join, resolve } from "node:path";

type TrackedFileChange = {
	entity: string;
	entityType?: "file" | "app";
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
const HEARTBEAT_RETRY_SECONDS = 60;
const STATE_PREFIX = "pi-mono-wakatime";
const PI_VERSION = "0.1.0";
const PLUGIN_NAME = `pi/${PI_VERSION} pi-mono-wakatime/${PI_VERSION}`;

let currentProjectFolder = process.cwd();
let pendingChanges = new Map<string, TrackedFileChange>();
let cliChecked = false;
let cliAvailable = false;
let cliStatus = "not checked";
let lastActiveFile: string | undefined;
let lastHeartbeatAttemptAt: number | undefined;
let lastHeartbeatSentAt: number | undefined;
let lastHeartbeatError: string | undefined;
let agentActive = false;
let activeHeartbeatTimer: ReturnType<typeof setInterval> | undefined;

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
	const now = nowSeconds();
	if (!force && lastHeartbeatAttemptAt && now - lastHeartbeatAttemptAt < HEARTBEAT_RETRY_SECONDS) return false;
	if (force) return true;
	const state = readProjectState(projectFolder);
	const lastHeartbeatAt = state.lastHeartbeatAt ?? 0;
	return now - lastHeartbeatAt >= HEARTBEAT_INTERVAL_SECONDS;
}

function markHeartbeatSent(projectFolder: string): void {
	writeProjectState(projectFolder, { lastHeartbeatAt: nowSeconds() });
}

function sanitizeOutput(text: string): string {
	return text
		.replace(/(api[_-]?key\s*[=:]\s*)\S+/gi, "$1<redacted>")
		.trim()
		.slice(0, 1000);
}

async function ensureCli(pi: ExtensionAPI): Promise<boolean> {
	if (cliChecked) return cliAvailable;
	cliChecked = true;

	try {
		const version = await pi.exec("wakatime-cli", ["--version"], { timeout: 5000 });
		const versionOutput = `${version.stdout}\n${version.stderr}`;
		if (version.code !== 0 || /failed to parse config|permission denied/i.test(versionOutput)) {
			cliAvailable = false;
			cliStatus = sanitizeOutput(versionOutput) || `wakatime-cli --version exited with ${version.code}`;
			return cliAvailable;
		}

		const config = await pi.exec("wakatime-cli", ["--config-read", "api_key"], { timeout: 5000 });
		const configOutput = `${config.stdout}\n${config.stderr}`;
		if (config.code !== 0 || /api key not found|api_key.*empty|failed to parse config|permission denied/i.test(configOutput)) {
			cliAvailable = false;
			cliStatus = sanitizeOutput(configOutput) || `wakatime-cli config check exited with ${config.code}`;
			return cliAvailable;
		}

		cliAvailable = true;
		cliStatus = "available and configured";
	} catch (error) {
		cliAvailable = false;
		cliStatus = error instanceof Error ? error.message : String(error);
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
	const entityType = change.entityType ?? "file";
	if (!change.entity || (entityType === "file" && !isProbablyFile(change.entity))) return;
	if (entityType === "file") lastActiveFile = change.entity;

	const key = `${entityType}:${change.entity}`;
	const existing = pendingChanges.get(key);
	if (!existing) {
		pendingChanges.set(key, { ...change, entityType });
		return;
	}

	pendingChanges.set(key, {
		entity: change.entity,
		entityType,
		lineChanges: (existing.lineChanges ?? 0) + (change.lineChanges ?? 0),
		isWrite: existing.isWrite || change.isWrite,
	});
}

function projectName(projectFolder: string): string {
	return basename(projectFolder) || "unknown";
}

function queueActiveHeartbeat(): void {
	if (lastActiveFile) {
		queueChange({ entity: lastActiveFile });
		return;
	}

	// Before a tool touches a file, still log active AI-coding time against the project.
	queueChange({ entity: "pi", entityType: "app" });
}

async function sendHeartbeat(
	pi: ExtensionAPI,
	projectFolder: string,
	change: TrackedFileChange,
): Promise<boolean> {
	const entityType = change.entityType ?? "file";
	const args = [
		"--entity",
		change.entity,
		"--entity-type",
		entityType,
		"--category",
		"ai coding",
		"--plugin",
		PLUGIN_NAME,
		"--timeout",
		"5",
		"--project-folder",
		projectFolder,
	];

	if (entityType === "app") {
		args.push("--project", projectName(projectFolder));
	} else {
		args.push("--alternate-project", projectName(projectFolder));
	}

	if (typeof change.lineChanges === "number" && change.lineChanges !== 0) {
		args.push("--ai-line-changes", String(change.lineChanges));
	}

	if (change.isWrite) {
		args.push("--write");
	}

	try {
		const result = await pi.exec("wakatime-cli", args, { timeout: 15000 });
		const output = `${result.stdout}\n${result.stderr}`;
		if (result.code !== 0 || /"level":"error"|failed to parse config|api key not found|permission denied/i.test(output)) {
			lastHeartbeatError = sanitizeOutput(output) || `wakatime-cli exited with ${result.code}`;
			return false;
		}

		lastHeartbeatSentAt = nowSeconds();
		lastHeartbeatError = undefined;
		return true;
	} catch (error) {
		// never break the session on heartbeat failures
		lastHeartbeatError = error instanceof Error ? error.message : String(error);
		return false;
	}
}

function startActiveHeartbeatTimer(pi: ExtensionAPI): void {
	if (activeHeartbeatTimer) return;

	activeHeartbeatTimer = setInterval(() => {
		if (!agentActive) return;
		queueActiveHeartbeat();
		void flushHeartbeats(pi, false);
	}, HEARTBEAT_INTERVAL_SECONDS * 1000);
}

function stopActiveHeartbeatTimer(): void {
	if (!activeHeartbeatTimer) return;
	clearInterval(activeHeartbeatTimer);
	activeHeartbeatTimer = undefined;
}

async function flushHeartbeats(pi: ExtensionAPI, force = false): Promise<void> {
	if (pendingChanges.size === 0) return;
	if (!(await ensureCli(pi))) return;
	if (!shouldSendHeartbeat(currentProjectFolder, force)) return;

	lastHeartbeatAttemptAt = nowSeconds();
	const changes = Array.from(pendingChanges.values());
	pendingChanges.clear();

	let sentAny = false;
	for (const change of changes) {
		const sent = await sendHeartbeat(pi, currentProjectFolder, change);
		if (sent) {
			sentAny = true;
		} else {
			queueChange(change);
		}
	}

	if (sentAny) markHeartbeatSent(currentProjectFolder);
}

export default function wakatimeExtension(pi: ExtensionAPI) {
	pi.on("session_start", async (event, ctx) => {
		if (event.reason === "new" || event.reason === "resume" || event.reason === "fork") {
			await flushHeartbeats(pi, true);
		}

		currentProjectFolder = await resolveProjectFolder(pi, ctx.cwd);
		pendingChanges = new Map();
		lastActiveFile = undefined;
		agentActive = false;
		stopActiveHeartbeatTimer();
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

	pi.on("agent_start", async () => {
		agentActive = true;
		startActiveHeartbeatTimer(pi);
		queueActiveHeartbeat();
		await flushHeartbeats(pi, true);
	});

	pi.on("agent_end", async () => {
		agentActive = false;
		stopActiveHeartbeatTimer();
		queueActiveHeartbeat();
		await flushHeartbeats(pi, true);
	});

	pi.on("session_shutdown", async () => {
		agentActive = false;
		stopActiveHeartbeatTimer();
		await flushHeartbeats(pi, true);
	});

	pi.registerCommand("wakatime-status", {
		description: "Show WakaTime extension status",
		handler: async (_args, ctx) => {
			cliChecked = false;
			const hasCli = await ensureCli(pi);
			const stateFile = getStateFile(currentProjectFolder);
			const state = readProjectState(currentProjectFolder);
			const lines = [
				`wakatime-cli: ${hasCli ? "ready" : "not ready"}`,
				`status: ${cliStatus}`,
				`project: ${currentProjectFolder}`,
				`active: ${agentActive ? "yes" : "no"}`,
				`pending entities: ${pendingChanges.size}`,
				`last sent: ${lastHeartbeatSentAt ? new Date(lastHeartbeatSentAt * 1000).toLocaleString() : "never in this process"}`,
				`last accepted interval: ${state.lastHeartbeatAt ? new Date(state.lastHeartbeatAt * 1000).toLocaleString() : "never"}`,
				`state file: ${stateFile}`,
			];

			if (lastHeartbeatError) {
				lines.push(`last error: ${lastHeartbeatError}`);
			}

			if (!hasCli) {
				lines.push("Install/configure wakatime-cli and make sure ~/.wakatime.cfg is readable.");
			}

			ctx.ui.notify(lines.join("\n"), hasCli ? "info" : "warning");
		},
	});
}
