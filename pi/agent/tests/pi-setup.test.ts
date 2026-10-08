import { expect, spyOn, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync, writeFileSync, mkdirSync, realpathSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import notifications, { notify } from "../extensions/ghostty-context-notify.ts";
import dangerGuard from "../extensions/danger-guard.ts";

const root = fileURLToPath(new URL("../../../", import.meta.url));

test("Pi installers preserve personal settings, enable safe codemode, and rerun cleanly", () => {
  const home = mkdtempSync(join(tmpdir(), "pi-setup-"));
  try {
    const bin = join(home, "bin");
    const agent = join(home, ".pi", "agent");
    mkdirSync(bin);
    mkdirSync(agent, { recursive: true });
    const log = join(home, "commands");
    for (const command of ["pi", "mise", "rcup"]) {
      writeFileSync(join(bin, command), `#!/bin/sh\nprintf '%s\\n' '${command} '"$*" >> "$PI_TEST_LOG"\n`, { mode: 0o755 });
    }
    const settingsPath = join(agent, "settings.json");
    writeFileSync(settingsPath, JSON.stringify({
      defaultProvider: "openai-codex-scout24",
      defaultModel: "gpt-6-luna",
      defaultTools: ["read", "-codemode", "-tool_search"],
      codemode: { mode: "only", inlineBudget: 1234 },
      extensions: ["custom.ts", "+builtin:mcp"],
      packages: [
        { source: "npm:@mjfuertesf/pi-quota-status", extensions: [] },
        "npm:personal-extension",
      ],
    }));
    const mcpPath = join(agent, "mcp-adapter.json");
    const personalMcp = '{"mcpServers":{"private":{"url":"https://example.test/mcp"}}}\n';
    writeFileSync(mcpPath, personalMcp);
    const env = { ...process.env, HOME: home, PI_CODING_AGENT_DIR: agent, DOTFILES_DIR: root, PI_TEST_LOG: log, PATH: `${bin}:${process.env.PATH}` };
    const run = (script: string) => {
      const result = Bun.spawnSync(["bash", join(root, "installer", script)], { env });
      expect(result.stderr.toString()).toBe("");
      expect(result.exitCode).toBe(0);
    };
    run("pi");
    const first = readFileSync(settingsPath, "utf8");
    run("pi");
    expect(readFileSync(settingsPath, "utf8")).toBe(first);
    const settings = JSON.parse(first);
    expect(settings.defaultProvider).toBe("openai-codex-scout24");
    expect(settings.defaultModel).toBe("gpt-6-luna");
    expect(settings.defaultTools).toEqual(["read", "+codemode", "+tool_search"]);
    expect(settings.codemode).toEqual({ mode: "on", inlineBudget: 1234 });
    expect(settings.extensions).toEqual(["custom.ts", "-builtin:mcp"]);
    expect(settings.packages).toEqual(["npm:personal-extension"]);
    expect(settings.theme).toBe("system");
    run("mise");
    run("link");
    run("link");
    expect(readFileSync(mcpPath, "utf8")).toBe(personalMcp);
    for (const name of ["pi-quota-status", "workmux-status.ts"]) {
      expect(realpathSync(join(agent, "extensions", name))).toBe(join(root, "pi", "agent", "extensions", name));
    }
    rmSync(mcpPath);
    run("link");
    expect(JSON.parse(readFileSync(mcpPath, "utf8")).mcpServers.mcp).toMatchObject({ directTools: "search", approveTools: true });
    const commands = readFileSync(log, "utf8");
    expect(commands).toContain("npm:pi-sub-aliases");
    expect(commands).toContain("npm:pi-claude-bridge");
    expect(commands).toContain("https://github.com/gsanhueza/pi-token-speed");
    expect(commands).not.toContain("npm:@mjfuertesf/pi-quota-status");
    expect(commands).toContain("@earendil-works/pi-coding-agent@latest");
    expect(commands).not.toContain("0.80.6");
    expect(JSON.parse(readFileSync(join(root, "pi/agent/extensions/pi-rtk-optimizer/config.json"), "utf8")).outputCompaction.enabled).toBe(false);
  } finally {
    rmSync(home, { recursive: true, force: true });
  }
});

test("terminal notifications never write in RPC, JSON, print, or redirected TUI", async () => {
  const tty = Object.getOwnPropertyDescriptor(process.stdout, "isTTY");
  const writes = spyOn(process.stdout, "write").mockReturnValue(true);
  const tmux = process.env.TMUX;
  delete process.env.TMUX;
  const handlers: Record<string, (event: any, ctx: any) => Promise<any>> = {};
  const ctx = (mode: string) => ({ mode, hasUI: mode === "tui" || mode === "rpc", cwd: "/tmp" });
  try {
    Object.defineProperty(process.stdout, "isTTY", { configurable: true, value: true });
    notifications({ on: (name: string, handler: any) => { handlers[name] = handler; } } as any);
    for (const mode of ["rpc", "json", "print"]) {
      notify("guard", "detail", ctx(mode) as any);
      await handlers.agent_settled({}, ctx(mode));
      await handlers.session_compact({}, ctx(mode));
      await handlers.session_shutdown({ reason: "quit" }, ctx(mode));
    }
    expect(writes).not.toHaveBeenCalled();
    notify("guard;\x1b", "detail\n", ctx("tui") as any);
    expect(writes).toHaveBeenCalledWith("\x1b]777;notify;guard;detail\x07");
    writes.mockClear();
    Object.defineProperty(process.stdout, "isTTY", { configurable: true, value: false });
    notify("guard", "detail", ctx("tui") as any);
    expect(writes).not.toHaveBeenCalled();
    dangerGuard({ on: (name: string, handler: any) => { handlers[name] = handler; } } as any);
    expect(await handlers.tool_call({ toolName: "bash", input: { command: "rm -rf /tmp/example" } }, ctx("print"))).toEqual({ block: true, reason: "Dangerous command blocked" });
    expect(writes).not.toHaveBeenCalled();
  } finally {
    writes.mockRestore();
    if (tmux === undefined) delete process.env.TMUX;
    else process.env.TMUX = tmux;
    if (tty) Object.defineProperty(process.stdout, "isTTY", tty);
    else delete (process.stdout as any).isTTY;
  }
});
