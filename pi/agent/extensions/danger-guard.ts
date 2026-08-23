import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { notify } from "./ghostty-context-notify.ts";

const dangerousBash = [
	/\brm\s+(?:-[^\s]*[rR][^\s]*[fF]?|-[^\s]*[fF][^\s]*[rR]|--recursive|--force)/,
	/\bsudo\b/,
	/\b(?:chmod|chown)\b.*(?:\s|=)777\b/,
	/\bdd\s+.*\bof=\/dev\//,
	/\bmkfs(?:\.\w+)?\b/,
	/\bdiskutil\s+(?:erase|partition|unmount|apfs\s+delete)/i,
	/\b(?:shutdown|reboot|halt)\b/,
	/\bkillall\b|\bkill\s+-9\b/,
	/>\s*~?\/(?:\.zshrc|\.bashrc|\.ssh|\.gitconfig|\.config)\b/,
];

const protectedPaths = [
	/(^|\/)\.env(?:\.|$)/,
	/(^|\/)\.ssh(?:\/|$)/,
	/(^|\/)\.git(?:\/|$)/,
	/(^|\/)node_modules(?:\/|$)/,
	/(^|\/)package-lock\.json$/,
	/(^|\/)pnpm-lock\.yaml$/,
	/(^|\/)yarn\.lock$/,
];

function isDangerousBash(command: string) {
	return dangerousBash.some((pattern) => pattern.test(command));
}

function touchesProtectedPath(input: unknown) {
	const text = JSON.stringify(input);
	return protectedPaths.some((pattern) => pattern.test(text));
}

async function confirm(ctx: any, title: string, detail: string) {
	notify(title, detail);
	if (!ctx.hasUI) return false;
	return ctx.ui.confirm(title, detail.length > 1600 ? `${detail.slice(0, 1600)}…` : detail);
}

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName === "bash") {
			const command = String((event.input as { command?: unknown }).command ?? "");
			if (isDangerousBash(command)) {
				const ok = await confirm(ctx, "⚠️ Dangerous bash command", command);
				if (!ok) return { block: true, reason: "Dangerous command blocked" };
			}
		}

		if (["write", "edit"].includes(event.toolName) && touchesProtectedPath(event.input)) {
			const ok = await confirm(ctx, `⚠️ ${event.toolName} touches a protected path`, JSON.stringify(event.input, null, 2));
			if (!ok) return { block: true, reason: "Protected path blocked" };
		}

		return undefined;
	});

	pi.on("user_bash", async (event, ctx) => {
		if (!isDangerousBash(event.command)) return undefined;
		const ok = await confirm(ctx, "⚠️ Dangerous shell command", event.command);
		if (!ok) return { result: { output: "Blocked by danger-guard\n", exitCode: 1, cancelled: false, truncated: false } };
		return undefined;
	});
}
