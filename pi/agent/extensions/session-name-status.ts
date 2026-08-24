import { complete } from "@earendil-works/pi-ai/compat";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const PROVIDER = process.env.PI_SESSION_NAME_PROVIDER ?? "openai-codex";
const MODEL = process.env.PI_SESSION_NAME_MODEL;

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

  // Alias providers are registered per project; active model already has correct provider id.
  const model = MODEL ? ctx.modelRegistry.find(PROVIDER, MODEL) : ctx.model;
  const modelName = model ? `${model.provider}/${model.id}` : `${PROVIDER}/${MODEL ?? "active"}`;
  if (!model) {
    ctx.ui.notify(`session-name: model not found: ${modelName}`, "warning");
    return;
  }

  const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
  if (!auth.ok || !auth.apiKey) {
    ctx.ui.notify(`session-name: auth failed for ${modelName}`, "warning");
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
    { apiKey: auth.apiKey, headers: auth.headers, env: auth.env, maxTokens: 32, reasoningEffort: "medium" },
  );

  const title = cleanTitle(response.content.filter((c: any) => c.type === "text").map((c: any) => c.text).join(" "));
  if (title && !pi.getSessionName()) pi.setSessionName(title);
}

export default function (pi: ExtensionAPI) {
  let pendingPrompt: string | undefined;
  let naming = false;

  const maybeName = async (ctx: any) => {
    if (naming || pi.getSessionName()) return;
    naming = true;
    try {
      await nameSession(pi, ctx, pendingPrompt);
    } catch (err) {
      ctx.ui.notify(`session-name: ${err instanceof Error ? err.message : String(err)}`, "warning");
    } finally {
      naming = false;
    }
  };

  pi.on("input", async (event) => {
    if (!pi.getSessionName()) pendingPrompt = event.text;
  });
  pi.on("agent_end", async (_event, ctx) => maybeName(ctx));

  pi.registerCommand("autoname", {
    description: MODEL ? `Generate session name with ${PROVIDER}/${MODEL}` : "Generate session name with active session model",
    handler: async (_args, ctx) => maybeName(ctx),
  });
}
