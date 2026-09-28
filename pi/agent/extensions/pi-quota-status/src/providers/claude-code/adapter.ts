import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import type { QuotaAdapter, QuotaResult } from '../../adapters/types.ts';
import { formatClaudeApiStatus, normalizeAnthropicUsage, parseClaudeApiResponse } from '../anthropic/adapter.ts';

const run = promisify(execFile);
const USAGE_URL = 'https://api.anthropic.com/api/oauth/usage';

// ponytail: macOS Keychain only; add ~/.claude/.credentials.json fallback for Linux if needed.
// Undocumented Claude Code endpoint. Token stays in memory, never logged. Refresh left to `claude` CLI.
async function readToken(): Promise<string | undefined> {
  const { stdout } = await run('security', ['find-generic-password', '-s', 'Claude Code-credentials', '-w']);
  const oauth = JSON.parse(stdout).claudeAiOauth;
  if (typeof oauth?.accessToken !== 'string') return undefined;
  if (typeof oauth.expiresAt === 'number' && oauth.expiresAt <= Date.now()) return undefined;
  return oauth.accessToken;
}

export class ClaudeCodeAdapter implements QuotaAdapter {
  async fetch(): Promise<QuotaResult> {
    try {
      const token = await readToken();
      if (!token) return { status: 'unknown' };
      const res = await fetch(USAGE_URL, {
        headers: { authorization: `Bearer ${token}`, 'anthropic-beta': 'oauth-2025-04-20', accept: 'application/json' },
        signal: AbortSignal.timeout(10_000),
      });
      if (!res.ok) return { status: 'unknown' };
      const usage = parseClaudeApiResponse(await res.json());
      const display = formatClaudeApiStatus(usage, Date.now());
      if (!display) return { status: 'unknown' };
      const status = usage.five_hour && usage.seven_day ? 'ok' : 'partial';
      return { status, display, usage: normalizeAnthropicUsage(usage) };
    } catch {
      return { status: 'unknown' };
    }
  }
}
