import { expect, test } from "bun:test";
import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import scout24Confirm from "../extensions/provider-confirm.ts";

const agentDir = mkdtempSync(join(tmpdir(), "pi-agent-"));
writeFileSync(join(agentDir, "settings.json"), JSON.stringify({
  providerConfirm: { providers: ["openai-codex-scout24"], fallback: "openai-codex-munichmade" },
}));
process.env.PI_CODING_AGENT_DIR = agentDir;

test("guarded provider asks once on first sent message", async () => {
  const handlers: Record<string, (event: any, ctx: any) => Promise<any>> = {};
  let switched: any;
  scout24Confirm({
    on: (name: string, handler: any) => { handlers[name] = handler; },
    setModel: async (m: any) => { switched = m; ctx.model = m; return true; },
  } as any);

  let prompts = 0;
  let answer: string | undefined;
  let editor = "";
  const branch: any[] = [];
  const ctx: any = {
    model: { provider: "openai-codex-scout24", id: "gpt-6-sol" },
    hasUI: true,
    cwd: agentDir,
    isProjectTrusted: () => false,
    sessionManager: { getBranch: () => branch },
    modelRegistry: { find: (provider: string, id: string) => ({ provider, id }) },
    ui: {
      select: async (_t: string, opts: string[]) => { prompts++; return answer === "switch" ? opts[1] : answer; },
      setEditorText: (t: string) => { editor = t; },
      setStatus: () => {},
      notify: () => {},
      theme: { fg: (_c: string, s: string) => s },
    },
  };
  const send = (text: string) => handlers.input({ text }, ctx);

  // Selecting / session start alone: no prompt.
  await handlers.session_start({}, ctx);
  await handlers.model_select({}, ctx);
  expect(prompts).toBe(0);

  // Cancel (Esc): blocked, text restored.
  answer = undefined;
  expect(await send("hi")).toEqual({ action: "handled" });
  expect([prompts, editor]).toEqual([1, "hi"]);

  // Approve: follow-ups don't ask.
  answer = "Send with openai-codex-scout24";
  expect(await send("hi")).toEqual({ action: "continue" });
  expect(await send("follow-up")).toEqual({ action: "continue" });
  expect(prompts).toBe(2);

  // New session resets; switch option moves to fallback and sends.
  await handlers.session_start({}, ctx);
  answer = "switch";
  expect(await send("x")).toEqual({ action: "continue" });
  expect(switched).toEqual({ provider: "openai-codex-munichmade", id: "gpt-6-sol" });

  // Resumed session with Scout24 history: no prompt.
  ctx.model = { provider: "openai-codex-scout24", id: "gpt-6-sol" };
  await handlers.session_start({}, ctx);
  branch.push({ type: "message", message: { role: "assistant", provider: "openai-codex-scout24" } });
  expect(await send("y")).toEqual({ action: "continue" });
  expect(prompts).toBe(3);

  // No UI: fail closed.
  await handlers.session_start({}, ctx);
  branch.length = 0;
  ctx.hasUI = false;
  const err = console.error; console.error = () => {};
  expect(await send("z")).toEqual({ action: "handled" });
  console.error = err;
});
