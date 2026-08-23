import type { QuotaAdapter, QuotaResult, NormalizedQuotaUsage, NormalizedQuotaWindow } from '../../adapters/types.ts';
import { formatDuration, formatQuotaStatus } from '../../adapters/utils.ts';
import { globalAuthPath, readQuotaStatusProviderConfig } from '../../adapters/auth-json-store.ts';

const CLAUDE_USAGE_URL = (orgUuid: string) =>
  `https://claude.ai/api/organizations/${orgUuid}/usage`;
const CLAUDE_USER_AGENT =
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Gecko/20100101 Firefox/148.0';
const CLAUDE_API_TIMEOUT_MS = 10_000;

export interface ClaudeUsageWindow {
  utilization: number;
  resets_at: string | null;
}

export interface ClaudeUsageResponse {
  five_hour?: ClaudeUsageWindow | null;
  seven_day?: ClaudeUsageWindow | null;
}

export interface AnthropicApiConfig {
  organizationUuid: string;
  authCookie: string;
  headers?: Record<string, string>;
}

export type AnthropicApiFetch = (url: string, init: RequestInit) => Promise<{ ok: boolean; status: number; json(): Promise<unknown> }>;

export function readAnthropicApiConfig(authPath?: string): AnthropicApiConfig | undefined {
  const raw = readQuotaStatusProviderConfig('anthropic-subscription', authPath ?? globalAuthPath());
  if (!raw) return undefined;

  const organizationUuid = typeof raw.organizationUuid === 'string' ? raw.organizationUuid : undefined;
  const authCookie = typeof raw.authCookie === 'string' ? raw.authCookie : undefined;
  if (!organizationUuid || !authCookie) return undefined;

  const rawHeaders = raw.headers;
  const headers = rawHeaders && typeof rawHeaders === 'object' && !Array.isArray(rawHeaders)
    ? Object.fromEntries(
        Object.entries(rawHeaders as Record<string, unknown>)
          .filter((entry): entry is [string, string] => typeof entry[1] === 'string'),
      )
    : undefined;

  return { organizationUuid, authCookie, ...(headers ? { headers } : {}) };
}

function parseUsageWindow(raw: unknown): ClaudeUsageWindow | null {
  if (!raw || typeof raw !== 'object') return null;
  const obj = raw as Record<string, unknown>;
  const utilization = typeof obj.utilization === 'number' && Number.isFinite(obj.utilization)
    ? obj.utilization
    : undefined;
  if (utilization === undefined) return null;
  const resets_at = obj.resets_at === null ? null : (typeof obj.resets_at === 'string' ? obj.resets_at : null);
  return { utilization, resets_at };
}

export function parseClaudeApiResponse(data: unknown): ClaudeUsageResponse {
  if (!data || typeof data !== 'object') return {};
  const obj = data as Record<string, unknown>;
  return {
    five_hour: 'five_hour' in obj ? parseUsageWindow(obj.five_hour) : undefined,
    seven_day: 'seven_day' in obj ? parseUsageWindow(obj.seven_day) : undefined,
  };
}

export function formatClaudeApiWindow(window: ClaudeUsageWindow, nowMs: number): string {
  const remaining = Math.max(0, Math.min(100, 100 - window.utilization));
  if (window.resets_at === null) return `${remaining.toFixed(0)}%, ??`;
  const resetMs = Date.parse(window.resets_at);
  const durationMs = Number.isFinite(resetMs) ? Math.max(0, resetMs - nowMs) : 0;
  return `${remaining.toFixed(0)}%, ${formatDuration(durationMs)}`;
}

export function normalizeAnthropicUsage(usage: ClaudeUsageResponse): NormalizedQuotaUsage {
  const normalizeWindow = (window: ClaudeUsageWindow | null | undefined): NormalizedQuotaWindow | null => {
    if (!window) return null;
    return {
      remainingPct: Math.max(0, Math.min(100, 100 - window.utilization)),
      resetAt: window.resets_at,
    };
  };

  return {
    fiveHour: normalizeWindow(usage.five_hour),
    weekly: normalizeWindow(usage.seven_day),
  };
}

export function formatClaudeApiStatus(usage: ClaudeUsageResponse, nowMs: number): string | undefined {
  const { five_hour, seven_day } = usage;
  return formatQuotaStatus(
    five_hour ? formatClaudeApiWindow(five_hour, nowMs) : undefined,
    seven_day ? formatClaudeApiWindow(seven_day, nowMs) : undefined,
  );
}

export async function fetchAnthropicApiUsage(
  config: AnthropicApiConfig,
  fetchFn: AnthropicApiFetch = (url, init) => fetch(url, init),
): Promise<ClaudeUsageResponse> {
  const url = CLAUDE_USAGE_URL(config.organizationUuid);
  const headers: Record<string, string> = {
    accept: 'application/json',
    referer: 'https://claude.ai/settings/usage',
    'user-agent': CLAUDE_USER_AGENT,
    ...(config.headers ?? {}),
    cookie: config.authCookie,
  };

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), CLAUDE_API_TIMEOUT_MS);
  try {
    const response = await fetchFn(url, { headers, signal: controller.signal });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return parseClaudeApiResponse(await response.json());
  } finally {
    clearTimeout(timer);
  }
}

export class AnthropicAdapter implements QuotaAdapter {
  private readonly nowMs: () => number;
  private readonly readApiConfig: () => AnthropicApiConfig | undefined;
  private readonly fetchFn: AnthropicApiFetch;

  constructor(
    deps: {
      nowMs?: () => number;
      readApiConfig?: () => AnthropicApiConfig | undefined;
      fetchFn?: AnthropicApiFetch;
    } = {},
  ) {
    this.nowMs = deps.nowMs ?? (() => Date.now());
    this.readApiConfig = deps.readApiConfig ?? readAnthropicApiConfig;
    this.fetchFn = deps.fetchFn ?? ((url, init) => fetch(url, init));
  }

  async fetch(): Promise<QuotaResult> {
    try {
      const apiConfig = this.readApiConfig();
      if (!apiConfig) return { status: 'unknown' };

      const usage = await fetchAnthropicApiUsage(apiConfig, this.fetchFn);
      const display = formatClaudeApiStatus(usage, this.nowMs());
      if (!display) return { status: 'unknown' };
      const normalized = normalizeAnthropicUsage(usage);
      if (!usage.five_hour || !usage.seven_day) return { status: 'partial', display, usage: normalized };
      return { status: 'ok', display, usage: normalized };
    } catch {
      return { status: 'unknown' };
    }
  }
}
