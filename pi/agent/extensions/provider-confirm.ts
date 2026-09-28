import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

// Config lives in Pi settings.json (global, trusted project overrides):
//   "providerConfirm": { "providers": ["openai-codex-scout24"], "fallback": "openai-codex-munichmade" }
type Config = { providers?: string[]; fallback?: string };

const CANCEL = "Cancel (keep text in editor)";

function readConfig(path: string): Config {
  try {
    return JSON.parse(readFileSync(path, "utf8")).providerConfirm ?? {};
  } catch {
    return {};
  }
}

function loadConfig(ctx: ExtensionContext): Config {
  const agentDir = process.env.PI_CODING_AGENT_DIR ?? join(homedir(), ".pi", "agent");
  const global = readConfig(join(agentDir, "settings.json"));
  const project = ctx.isProjectTrusted() ? readConfig(join(ctx.cwd, ".pi", "settings.json")) : {};
  return { ...global, ...project };
}

// Resumed sessions that already talked to this provider count as approved.
const used = (ctx: ExtensionContext, provider: string) =>
  ctx.sessionManager.getBranch().some((e: any) => e.type === "message" && e.message?.provider === provider);

export default function (pi: ExtensionAPI) {
  const approved = new Set<string>();
  let config: Config = {};

  const guarded = (ctx: ExtensionContext) =>
    ctx.model && config.providers?.includes(ctx.model.provider) ? ctx.model.provider : undefined;

  const status = (ctx: ExtensionContext) => {
    if (!ctx.hasUI) return;
    const p = guarded(ctx);
    ctx.ui.setStatus("provider-confirm", p ? ctx.ui.theme.fg("warning", `● ${p}`) : undefined);
  };

  // session_start also fires on /reload, so settings edits apply after /reload.
  pi.on("session_start", async (_event, ctx) => {
    config = loadConfig(ctx);
    approved.clear();
    status(ctx);
  });
  pi.on("model_select", async (_event, ctx) => status(ctx));

  pi.on("input", async (event, ctx) => {
    const provider = guarded(ctx);
    if (!provider || approved.has(provider)) return { action: "continue" };
    if (used(ctx, provider)) {
      approved.add(provider);
      return { action: "continue" };
    }
    if (!ctx.hasUI) {
      console.error(`provider-confirm: ${provider} active, confirmation needs UI. Message blocked.`);
      return { action: "handled" };
    }
    try {
      const send = `Send with ${provider}`;
      const fb = config.fallback;
      const fallback = fb && fb !== provider ? ctx.modelRegistry.find(fb, ctx.model!.id) : undefined;
      const switchLabel = fallback && `Switch to ${fb}/${fallback.id} and send`;
      const choice = await ctx.ui.select(
        `⚠ ${provider} active (${ctx.model!.id}). Send first message?`,
        [send, ...(switchLabel ? [switchLabel] : []), CANCEL],
      );
      if (choice === send) {
        approved.add(provider);
        return { action: "continue" };
      }
      if (choice === switchLabel && fallback && (await pi.setModel(fallback))) return { action: "continue" };
      if (choice === switchLabel) ctx.ui.notify(`No auth for ${fb}; message kept in editor.`, "error");
    } catch (err) {
      ctx.ui.notify(`provider-confirm: ${err instanceof Error ? err.message : String(err)}`, "error");
    }
    // Esc, cancel, or failure: block and give the text back.
    ctx.ui.setEditorText(event.text);
    return { action: "handled" };
  });
}
