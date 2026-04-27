import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { readFile } from "node:fs/promises";
import { join } from "node:path";

const USAGE_URL = "https://chatgpt.com/backend-api/wham/usage";

type CodexAuth = {
  tokens?: {
    access_token?: string;
    account_id?: string;
  };
};

type UsageWindow = {
  used_percent?: number;
  limit_window_seconds?: number;
  reset_after_seconds?: number;
  reset_at?: number;
};

type UsageResponse = {
  plan_type?: string;
  rate_limit?: {
    allowed?: boolean;
    limit_reached?: boolean;
    primary_window?: UsageWindow | null;
    secondary_window?: UsageWindow | null;
  } | null;
  credits?: {
    has_credits?: boolean;
    unlimited?: boolean;
    overage_limit_reached?: boolean;
    balance?: string;
  } | null;
  spend_control?: {
    reached?: boolean;
  } | null;
  rate_limit_reached_type?: string | null;
};

function authFilePath(): string {
  const home = process.env.HOME;
  if (!home) throw new Error("$HOME is not set");
  return join(home, ".codex", "auth.json");
}

async function loadCodexAuth(): Promise<CodexAuth> {
  return JSON.parse(await readFile(authFilePath(), "utf8")) as CodexAuth;
}

function formatDuration(seconds?: number): string | undefined {
  if (typeof seconds !== "number") return undefined;

  const days = Math.floor(seconds / 86_400);
  const hours = Math.floor((seconds % 86_400) / 3_600);
  const minutes = Math.floor((seconds % 3_600) / 60);

  if (days > 0) return hours > 0 ? `${days}d ${hours}h` : `${days}d`;
  if (hours > 0) return minutes > 0 ? `${hours}h ${minutes}m` : `${hours}h`;
  if (minutes > 0) return `${minutes}m`;
  return "<1m";
}

function formatPercent(value: number): string {
  const rounded = Math.round(value * 10) / 10;
  return Number.isInteger(rounded) ? `${rounded}%` : `${rounded.toFixed(1)}%`;
}

function formatResetAt(timestamp?: number): string | undefined {
  return timestamp ? new Date(timestamp * 1000).toLocaleString() : undefined;
}

function windowLabel(fallback: string, window?: UsageWindow | null): string {
  const duration = formatDuration(window?.limit_window_seconds);
  return duration ? `${duration} window` : fallback;
}

function formatWindow(
  fallbackLabel: string,
  window?: UsageWindow | null,
): string {
  const label = windowLabel(fallbackLabel, window);

  if (!window || typeof window.used_percent !== "number") {
    return `${label}: unavailable`;
  }

  const used = Math.max(0, Math.min(100, window.used_percent));
  const left = 100 - used;
  const resetIn = formatDuration(window.reset_after_seconds);
  const resetAt = formatResetAt(window.reset_at);
  const reset = [resetIn && `in ${resetIn}`, resetAt && `at ${resetAt}`]
    .filter(Boolean)
    .join(" / ");

  return `${label}: ${formatPercent(left)} left (${formatPercent(used)} used${reset ? `, resets ${reset}` : ""})`;
}

function formatCredits(credits: UsageResponse["credits"]): string | undefined {
  if (!credits) return undefined;
  if (credits.unlimited) return "Credits: unlimited";
  if (credits.overage_limit_reached) return "Credits: overage limit reached";
  if (credits.has_credits)
    return `Credits: balance ${credits.balance ?? "unknown"}`;
  return "Credits: none";
}

function usageSeverity(usage: UsageResponse): "info" | "warning" {
  const blocked =
    usage.rate_limit?.allowed === false ||
    usage.rate_limit?.limit_reached === true ||
    usage.credits?.overage_limit_reached === true ||
    usage.spend_control?.reached === true;

  return blocked ? "warning" : "info";
}

function usageLines(usage: UsageResponse): string[] {
  const rateLimit = usage.rate_limit;
  const lines = [
    `Plan: ${usage.plan_type ?? "unknown"}`,
    `Status: ${rateLimit?.allowed === false ? "limited" : "available"}`,
    formatWindow("Primary window", rateLimit?.primary_window),
    formatWindow("Secondary window", rateLimit?.secondary_window),
  ];

  if (rateLimit?.limit_reached && usage.rate_limit_reached_type) {
    lines.push(`Limit reached: ${usage.rate_limit_reached_type}`);
  }

  const credits = formatCredits(usage.credits);
  if (credits) lines.push(credits);

  if (usage.spend_control?.reached) {
    lines.push("Spend control: reached");
  }

  return lines;
}

async function fetchCodexUsage(
  accessToken: string,
  accountId: string,
  signal?: AbortSignal,
): Promise<UsageResponse> {
  const response = await fetch(USAGE_URL, {
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

export default function extension(pi: ExtensionAPI) {
  pi.registerCommand("openai-usage", {
    description: "Show OpenAI Codex ChatGPT usage limits",
    handler: async (_args, ctx) => {
      try {
        const auth = await loadCodexAuth();
        const accessToken = auth.tokens?.access_token;
        const accountId = auth.tokens?.account_id;

        if (!accessToken || !accountId) {
          ctx.ui.notify(
            "Codex is not authorized locally. Run the Codex CLI once (`codex`) and sign in again, then retry /openai-usage.",
            "warning",
          );
          return;
        }

        const usage = await fetchCodexUsage(accessToken, accountId, ctx.signal);
        ctx.ui.notify(usageLines(usage).join("\n"), usageSeverity(usage));
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);

        if (message === "AUTH_EXPIRED") {
          ctx.ui.notify(
            "Codex authorization has expired. Run the Codex CLI once (`codex`) so it can refresh/login again, then retry /openai-usage.",
            "warning",
          );
          return;
        }

        if (
          message === "This operation was aborted" ||
          message === "The operation was aborted"
        ) {
          return;
        }

        ctx.ui.notify(`Failed to fetch Codex usage: ${message}`, "error");
      }
    },
  });
}
