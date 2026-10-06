import { expect, test } from "bun:test";
import sessionNameStatus from "../extensions/session-name-status.ts";

test("names sessions through registered provider, including custom APIs", async () => {
  const handlers: Record<string, (event: any, ctx: any) => Promise<void>> = {};
  let title: string | undefined;
  const requests: any[] = [];
  sessionNameStatus({
    on: (event: string, handler: any) => { handlers[event] = handler; },
    getSessionName: () => title,
    setSessionName: (name: string) => { title = name; },
    registerCommand: () => {},
  } as any);

  for (const provider of ["claude-bridge", "openai-codex-work"]) {
    title = undefined;
    const model = { provider, id: "test", api: provider };
    const ctx = {
      model,
      modelRegistry: {
        streamSimple: (m: any, context: any, options: any) => {
          requests.push({ m, context, options });
          return { result: async () => ({ content: [{ type: "text", text: "Fix Session Name" }] }) };
        },
      },
      ui: { notify: (message: string) => { throw new Error(message); } },
    };
    await handlers.input({ text: "Fix naming" }, ctx);
    await handlers.agent_end({}, ctx);
    expect(title).toBe("Fix Session Name");
    expect(requests.at(-1).m).toBe(model);
    expect(requests.at(-1).context.messages[0].content[0].text).toContain("Fix naming");
    expect(requests.at(-1).options.maxTokens).toBe(32);
  }
});
