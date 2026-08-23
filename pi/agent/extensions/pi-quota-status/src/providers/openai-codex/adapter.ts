import { readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { join } from 'node:path';
import type { NormalizedQuotaUsage, NormalizedQuotaWindow, QuotaAdapter, QuotaResult } from '../../adapters/types.ts';
import { formatDuration, formatQuotaStatus } from '../../adapters/utils.ts';

const AUTH_PATH = join(homedir(), '.pi', 'agent', 'auth.json');
const USAGE_URLS = [
  'https://chatgpt.com/backend-api/wham/usage',
  'https://chatgpt.com/backend-api/codex/usage',
] as const;
const FETCH_TIMEOUT_MS = 10_000;

interface UsageWindow {
  used_percent?: number;
  reset_at?: number;
  reset_after_seconds?: number;
  limit_window_seconds?: number;
}

interface UsageResponse {
  rate_limit?: {
    primary_window?: UsageWindow | null;
    secondary_window?: UsageWindow | null;
  };
}

export function authFromEnv(env: NodeJS.ProcessEnv = process.env): { access: string; accountId: string } | undefined {
  const access = env.OPENAI_CODEX_ACCESS_TOKEN ?? env.OPENAI_CODEX_OAUTH_TOKEN;
  const accountId = env.CHATGPT_ACCOUNT_ID ?? env.OPENAI_CODEX_ACCOUNT_ID;
  return access && accountId ? { access, accountId } : undefined;
}

export function authFromStore(
  store: Record<string, unknown>,
  provider: string | undefined,
): { access: string; accountId: string } | undefined {
  const raw = store[provider ?? 'openai-codex'] as { access?: unknown; accountId?: unknown } | undefined;
  const access = typeof raw?.access === 'string' ? raw.access : undefined;
  const accountId = typeof raw?.accountId === 'string' ? raw.accountId : undefined;
  return access && accountId ? { access, accountId } : undefined;
}

function readAuth(provider: string | undefined): { access: string; accountId: string } | undefined {
  try {
    const auth = authFromStore(JSON.parse(readFileSync(AUTH_PATH, 'utf8')), provider);
    if (auth) return auth;
  } catch {}
  return authFromEnv();
}

async function fetchUsage(provider: string | undefined): Promise<UsageResponse | undefined> {
  const auth = readAuth(provider);
  if (!auth) return;

  const headers = {
    Authorization: `Bearer ${auth.access}`,
    'chatgpt-account-id': auth.accountId,
    originator: 'pi',
    'User-Agent': 'pi',
  };

  for (const url of USAGE_URLS) {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), FETCH_TIMEOUT_MS);
    try {
      const response = await fetch(url, { headers, signal: controller.signal });
      if (!response.ok) continue;
      return (await response.json()) as UsageResponse;
    } catch {} finally {
      clearTimeout(timer);
    }
  }
}

function clampRemainingPct(usedPercent: number): number {
  return Math.max(0, Math.min(100, 100 - usedPercent));
}

function millisUntilReset(window: UsageWindow, nowMs: number): number {
  if (typeof window.reset_after_seconds === 'number') return Math.max(0, window.reset_after_seconds * 1000);
  if (typeof window.reset_at === 'number') return Math.max(0, window.reset_at * 1000 - nowMs);
  return 0;
}

function isoResetAt(window: UsageWindow, nowMs: number): string | null {
  if (typeof window.reset_at === 'number') return new Date(window.reset_at * 1000).toISOString();
  if (typeof window.reset_after_seconds === 'number') return new Date(nowMs + Math.max(0, window.reset_after_seconds * 1000)).toISOString();
  return null;
}

function formatWindow(window: UsageWindow | null | undefined, nowMs: number): string | undefined {
  if (!window) return undefined;
  const usedPercent = typeof window.used_percent === 'number' ? window.used_percent : 100;
  const remaining = clampRemainingPct(usedPercent);
  return `${remaining.toFixed(0)}%, ${formatDuration(millisUntilReset(window, nowMs))}`;
}

function resolveWindows(usage: UsageResponse | undefined): { fiveHour: UsageWindow | null | undefined; weekly: UsageWindow | null | undefined } {
  const primary = usage?.rate_limit?.primary_window;
  const secondary = usage?.rate_limit?.secondary_window;
  const windows = [primary, secondary].filter((window): window is UsageWindow => !!window);
  const fiveHour = windows.find((window) => window.limit_window_seconds === 5 * 60 * 60);
  const weekly = windows.find((window) => window.limit_window_seconds === 7 * 24 * 60 * 60);
  return {
    fiveHour: fiveHour ?? (weekly ? null : primary),
    weekly: weekly ?? (fiveHour ? null : secondary),
  };
}

function normalizeWindow(window: UsageWindow | null | undefined, nowMs: number): NormalizedQuotaWindow | null {
  if (!window || typeof window.used_percent !== 'number' || !Number.isFinite(window.used_percent)) return null;
  return {
    remainingPct: clampRemainingPct(window.used_percent),
    resetAt: isoResetAt(window, nowMs),
  };
}

export function normalizeUsage(usage: UsageResponse | undefined, nowMs: number = Date.now()): NormalizedQuotaUsage {
  const { fiveHour, weekly } = resolveWindows(usage);
  return {
    fiveHour: normalizeWindow(fiveHour, nowMs),
    weekly: normalizeWindow(weekly, nowMs),
  };
}

export function formatStatus(usage: UsageResponse | undefined, nowMs: number = Date.now()): string | undefined {
  const { fiveHour, weekly } = resolveWindows(usage);
  return formatQuotaStatus(formatWindow(fiveHour, nowMs), formatWindow(weekly, nowMs));
}

export class OpenAICodexAdapter implements QuotaAdapter {
  private readonly nowMs: () => number;

  constructor(deps: { nowMs?: () => number } = {}) {
    this.nowMs = deps.nowMs ?? (() => Date.now());
  }

  async fetch(params?: { cwd?: string; provider?: string }): Promise<QuotaResult> {
    const nowMs = this.nowMs();
    const usage = await fetchUsage(params?.provider);
    if (usage?.rate_limit === null) return { status: 'not_applicable' };
    const display = formatStatus(usage, nowMs);
    if (!display) return { status: 'unknown' };
    const normalized = normalizeUsage(usage, nowMs);
    if (!normalized.fiveHour || !normalized.weekly) return { status: 'partial', display, usage: normalized };
    return { status: 'ok', display, usage: normalized };
  }
}
