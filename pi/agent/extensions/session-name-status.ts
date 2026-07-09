import { complete } from "@earendil-works/pi-ai/compat";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";

const PROVIDER = process.env.PI_SESSION_NAME_PROVIDER ?? "openai-codex";
const MODEL = process.env.PI_SESSION_NAME_MODEL ?? "gpt-5.4-mini";

function text(content: unknown): string {
  if (typeof content === "string") return content;
  if (Array.isArray(content)) return content.map((p: any) => (typeof p === "string" ? p : p?.text ?? "")).join(" ");
  return "";
}

function firstPrompt(ctx: any): string | undefined {
  const firstUser = ctx.sessionManager
    .getBranch()
    .find((e: any) => e.type === "message" && e.message?.role === "user");
  return text(firstUser?.message?.content).replace(/\s+/g, " ").trim() || undefined;
}

function cleanTitle(s: string): string {
  return s
    .replace(/^['"`]+|['"`.]+$/g, "")
    .replace(/\s+/g, " ")
    .trim()
    .slice(0, 60);
}

async function nameSession(pi: ExtensionAPI, ctx: any, prompt = firstPrompt(ctx)) {
  if (pi.getSessionName() || !prompt) return;

  const model = ctx.modelRegistry.find(PROVIDER, MODEL);
  if (!model) {
    ctx.ui.notify(`session-name: model not found: ${PROVIDER}/${MODEL}`, "warning");
    return;
  }

  const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
  if (!auth.ok || !auth.apiKey) {
    ctx.ui.notify(`session-name: auth failed for ${PROVIDER}/${MODEL}`, "warning");
    return;
  }

  const response = await complete(
    model,
    {
      messages: [
        {
          role: "user" as const,
          content: [{ type: "text" as const, text: `Name this coding session in 2-5 words. Return only the title.\n\n${prompt}` }],
          timestamp: Date.now(),
        },
      ],
    },
    { apiKey: auth.apiKey, headers: auth.headers, env: auth.env, maxTokens: 32 },
  );

  const title = cleanTitle(response.content.filter((c: any) => c.type === "text").map((c: any) => c.text).join(" "));
  if (title && !pi.getSessionName()) pi.setSessionName(title);
}

export default function (pi: ExtensionAPI) {
  let pendingPrompt: string | undefined;
  let naming = false;

  const update = (ctx: any, name = pi.getSessionName()) => {
    const title = name?.trim() || firstPrompt(ctx) || pendingPrompt || "unnamed";
    ctx.ui.setStatus("session-name", ctx.ui.theme.fg("accent", `session: ${truncateToWidth(title, 48)}`));
  };

  const maybeName = async (ctx: any) => {
    if (naming || pi.getSessionName()) return;
    naming = true;
    try {
      await nameSession(pi, ctx, pendingPrompt);
    } catch (err) {
      ctx.ui.notify(`session-name: ${err instanceof Error ? err.message : String(err)}`, "warning");
    } finally {
      naming = false;
      update(ctx);
    }
  };

  pi.on("session_start", async (_event, ctx) => update(ctx));
  pi.on("session_info_changed", async (event, ctx) => update(ctx, event.name));
  pi.on("input", async (event, ctx) => {
    if (!pi.getSessionName()) {
      pendingPrompt = event.text;
      update(ctx);
    }
  });
  pi.on("agent_end", async (_event, ctx) => maybeName(ctx));

  pi.registerCommand("autoname", {
    description: `Generate session name with ${PROVIDER}/${MODEL}`,
    handler: async (_args, ctx) => maybeName(ctx),
  });
}
