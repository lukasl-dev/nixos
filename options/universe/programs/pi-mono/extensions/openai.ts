import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { readFile } from "node:fs/promises";
import { join } from "node:path";

type CodexAuth = {
  tokens?: {
    access_token?: string;
    account_id?: string;
  };
};

type UsageWindow = {
  used_percent?: number;
  reset_at?: number;
};

type UsageResponse = {
  plan_type?: string;
  rate_limit?: {
    primary_window?: UsageWindow | null;
    secondary_window?: UsageWindow | null;
  } | null;
};

function getAuthFilePath(): string {
  const home = process.env.HOME;
  if (!home) throw new Error("$HOME is not set");
  return join(home, ".codex", "auth.json");
}

async function loadCodexAuth(): Promise<CodexAuth> {
  const authJson = await readFile(getAuthFilePath(), "utf8");
  return JSON.parse(authJson) as CodexAuth;
}

function formatReset(resetAt?: number): string {
  if (!resetAt) return "unknown";
  return new Date(resetAt * 1000).toLocaleString();
}

function formatWindow(label: string, window?: UsageWindow | null): string {
  if (!window || typeof window.used_percent !== "number") {
    return `${label}: unavailable`;
  }

  const used = Math.round(window.used_percent);
  const left = Math.max(0, 100 - used);
  return `${label}: ${left}% left (${used}% used, resets ${formatReset(window.reset_at)})`;
}

async function fetchCodexUsage(
  accessToken: string,
  accountId: string,
  signal?: AbortSignal,
): Promise<UsageResponse> {
  const response = await fetch("https://chatgpt.com/backend-api/wham/usage", {
    signal,
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "ChatGPT-Account-Id": accountId,
    },
  });

  if (response.status === 401 || response.status === 403) {
    throw new Error("AUTH_EXPIRED");
  }

  if (!response.ok) {
    const body = await response.text().catch(() => "");
    throw new Error(
      `Request failed: ${response.status} ${response.statusText}${body ? `\n${body}` : ""}`,
    );
  }

  return (await response.json()) as UsageResponse;
}

export default function openaiExtension(pi: ExtensionAPI) {
  pi.registerCommand("oai-usage", {
    description: "Show OpenAI Codex ChatGPT usage limits",
    handler: async (_args, ctx) => {
      try {
        const auth = await loadCodexAuth();
        const accessToken = auth.tokens?.access_token;
        const accountId = auth.tokens?.account_id;

        if (!accessToken || !accountId) {
          ctx.ui.notify(
            "Codex is not authorized locally. Run the Codex CLI once (`codex`) and sign in again, then retry /oai-usage.",
            "warning",
          );
          return;
        }

        const usage = await fetchCodexUsage(accessToken, accountId, ctx.signal);
        const lines = [
          `Plan: ${usage.plan_type ?? "unknown"}`,
          formatWindow("5h limit", usage.rate_limit?.primary_window),
          formatWindow("Weekly limit", usage.rate_limit?.secondary_window),
        ];

        ctx.ui.notify(lines.join("\n"), "info");
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);

        if (message === "AUTH_EXPIRED") {
          ctx.ui.notify(
            "Codex authorization has expired. Run the Codex CLI once (`codex`) so it can refresh/login again, then retry /oai-usage.",
            "warning",
          );
          return;
        }

        if (message === "This operation was aborted" || message === "The operation was aborted") {
          return;
        }

        ctx.ui.notify(`Failed to fetch Codex usage: ${message}`, "error");
      }
    },
  });
}
