import type {
  ExtensionAPI,
  ProviderConfig,
  ProviderModelConfig,
} from "@earendil-works/pi-coding-agent";

const PROVIDER_ID = "opencode-free";
const BASE_URL = "https://opencode.ai/zen/v1";

const ZERO_COST = {
  input: 0,
  output: 0,
  cacheRead: 0,
  cacheWrite: 0,
};

const FALLBACK_FREE_MODEL_IDS = [
  "big-pickle",
  "deepseek-v4-flash-free",
  "mimo-v2.5-free",
  "qwen3.6-plus-free",
  "minimax-m3-free",
  "nemotron-3-super-free",
];

function displayName(id: string): string {
  return `OpenCode Free ${id
    .replace(/-free$/, "")
    .split("-")
    .map((part) => {
      const special = part.toLowerCase();
      if (special === "m3") return "M3";
      if (special === "v4") return "V4";
      if (special === "v2.5") return "V2.5";
      if (special === "qwen3.6") return "Qwen3.6";
      return part.charAt(0).toUpperCase() + part.slice(1);
    })
    .join(" ")}`;
}

function model(id: string): ProviderModelConfig {
  return {
    id,
    name: displayName(id),
    reasoning: false,
    input: ["text"],
    cost: ZERO_COST,
    contextWindow: 128000,
    maxTokens: 16384,
    compat: {
      // OpenCode Zen is OpenAI-compatible, but these free models often emit
      // literal <think>...</think> tags in the content stream instead of a
      // separate reasoning_content delta.  We post-process those tags below.
      supportsReasoningEffort: false,
    },
  };
}

type TextBlock = { type: "text"; text: string };
type ThinkingBlock = {
  type: "thinking";
  thinking: string;
  thinkingSignature: string;
};
type ContentBlock = TextBlock | ThinkingBlock | Record<string, unknown>;

function splitThinkTags(text: string): Array<TextBlock | ThinkingBlock> {
  const blocks: Array<TextBlock | ThinkingBlock> = [];
  const thinkTag = /<think>([\s\S]*?)<\/think>/gi;
  let lastIndex = 0;

  for (const match of text.matchAll(thinkTag)) {
    const index = match.index ?? 0;
    const before = text.slice(lastIndex, index);
    if (before.length > 0) {
      blocks.push({ type: "text", text: before });
    }

    const thinking = match[1]?.trim();
    if (thinking) {
      blocks.push({
        type: "thinking",
        thinking,
        thinkingSignature: "opencode-free-think-tags",
      });
    }

    lastIndex = index + match[0].length;
  }

  const after = text.slice(lastIndex);
  if (after.length > 0) {
    blocks.push({ type: "text", text: after });
  }

  return blocks;
}

function normalizeThinkTags(message: unknown): unknown | undefined {
  if (!message || typeof message !== "object") return undefined;

  const assistant = message as {
    role?: unknown;
    provider?: unknown;
    content?: unknown;
  };

  if (assistant.role !== "assistant" || assistant.provider !== PROVIDER_ID) {
    return undefined;
  }
  if (!Array.isArray(assistant.content)) return undefined;

  let changed = false;
  const content: ContentBlock[] = [];

  for (const block of assistant.content as ContentBlock[]) {
    if (
      block &&
      typeof block === "object" &&
      block.type === "text" &&
      typeof (block as TextBlock).text === "string" &&
      (block as TextBlock).text.includes("<think>")
    ) {
      changed = true;
      content.push(...splitThinkTags((block as TextBlock).text));
    } else {
      content.push(block);
    }
  }

  if (!changed) return undefined;
  return { ...assistant, content };
}

function unique(ids: string[]): string[] {
  return [...new Set(ids)].sort((a, b) => a.localeCompare(b));
}

async function fetchFreeModelIds(): Promise<string[]> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 2_000);

  try {
    const response = await fetch(`${BASE_URL}/models`, {
      headers: { Authorization: "Bearer public" },
      signal: controller.signal,
    });

    if (!response.ok) return [];

    const payload = (await response.json()) as {
      data?: Array<{ id?: unknown }>;
    };

    return unique(
      (payload.data ?? [])
        .map((entry) => entry.id)
        .filter((id): id is string => typeof id === "string")
        .filter((id) => id === "big-pickle" || id.endsWith("-free")),
    );
  } catch {
    return [];
  } finally {
    clearTimeout(timeout);
  }
}

export default async function (pi: ExtensionAPI) {
  const fetchedIds = await fetchFreeModelIds();
  const ids = fetchedIds.length > 0 ? fetchedIds : FALLBACK_FREE_MODEL_IDS;

  const config: ProviderConfig = {
    name: "OpenCode Free",
    baseUrl: BASE_URL,
    api: "openai-completions",
    apiKey: "public",
    authHeader: true,
    models: ids.map(model),
  };

  pi.registerProvider(PROVIDER_ID, config);

  pi.on("message_end", (event) => {
    const message = normalizeThinkTags(event.message);
    if (message) return { message: message as typeof event.message };
  });
}
