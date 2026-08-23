/** macOS/Ghostty Pi notifications with tmux context. */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execFileSync } from "node:child_process";

function clean(s: unknown): string {
  return String(s ?? "")
    .replace(/[\x00-\x1f\x7f;]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function tmuxCtx(): string {
  if (!process.env.TMUX) return "";
  try {
    return clean(execFileSync("tmux", ["display-message", "-p", "#S:#W.#P"], { encoding: "utf8" }));
  } catch {
    return "tmux";
  }
}

function wrapForTmux(seq: string): string {
  if (!process.env.TMUX) return seq;
  return `\x1bPtmux;${seq.replaceAll("\x1b", "\x1b\x1b")}\x1b\\`;
}

export function notify(title: string, body: string): void {
  title = clean(title);
  body = clean(body);
  const seq = `\x1b]777;notify;${title};${body}\x07`;
  process.stdout.write(wrapForTmux(seq));
}

function where(ctx: any): string {
  const parts = [tmuxCtx(), ctx?.cwd].filter(Boolean).map(clean);
  return parts.join(" — ");
}

export default function (pi: ExtensionAPI) {
  pi.on("agent_settled", async (_event, ctx) => notify("Pi done", where(ctx)));

  pi.on("session_compact", async (_event, ctx) => notify("Pi compacted", where(ctx)));

  pi.on("session_shutdown", async (event, ctx) => {
    if (event.reason === "quit") notify("Pi session ended", where(ctx));
  });
}
