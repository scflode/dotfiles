import type { QuotaAdapter, QuotaResult } from '../../adapters/types.ts';
import { formatDuration, formatQuotaStatus } from '../../adapters/utils.ts';
import { readQuotaStatusProviderConfig } from '../../adapters/auth-json-store.ts';

const DASHBOARD_URL = (workspaceId: string) =>
  `https://opencode.ai/workspace/${workspaceId}/go`;
const USER_AGENT =
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Gecko/20100101 Firefox/148.0';
const SCRAPE_TIMEOUT_MS = 10_000;

export interface GoWindow {
  usagePercent: number;
  resetInSec: number;
}

export interface ParsedData {
  rolling: GoWindow | null;
  weekly: GoWindow | null;
}

export interface OpenCodeGoConfig {
  workspaceId: string;
  authCookie: string;
}

export type OpenCodeGoFetch = (
  url: string,
  init: RequestInit,
) => Promise<{ ok: boolean; status: number; url: string; text(): Promise<string> }>;

export function readConfig(_startDir?: string): { workspaceId: string } | undefined {
  const workspaceId = readQuotaStatusProviderConfig('opencode-go')?.workspaceId;
  return typeof workspaceId === 'string' ? { workspaceId } : undefined;
}

export function readAuthCookie(_startDir?: string): string | undefined {
  const authCookie = readQuotaStatusProviderConfig('opencode-go')?.authCookie;
  return typeof authCookie === 'string' ? authCookie : undefined;
}

const NUM = String.raw`(-?\d+(?:\.\d+)?)`;

function windowRegex(name: string): [RegExp, RegExp] {
  return [
    new RegExp(String.raw`${name}:\$R\[\d+\]=\{[^}]*usagePercent:${NUM}[^}]*resetInSec:${NUM}[^}]*\}`),
    new RegExp(String.raw`${name}:\$R\[\d+\]=\{[^}]*resetInSec:${NUM}[^}]*usagePercent:${NUM}[^}]*\}`),
  ];
}

const [RE_ROLLING_U, RE_ROLLING_R] = windowRegex('rollingUsage');
const [RE_WEEKLY_U, RE_WEEKLY_R] = windowRegex('weeklyUsage');

function parseWindow(html: string, reUFirst: RegExp, reRFirst: RegExp): GoWindow | null {
  let m = reUFirst.exec(html);
  if (m) {
    const usagePercent = Number(m[1]);
    const resetInSec = Number(m[2]);
    if (Number.isFinite(usagePercent) && Number.isFinite(resetInSec))
      return { usagePercent, resetInSec };
  }
  m = reRFirst.exec(html);
  if (m) {
    const resetInSec = Number(m[1]);
    const usagePercent = Number(m[2]);
    if (Number.isFinite(usagePercent) && Number.isFinite(resetInSec))
      return { usagePercent, resetInSec };
  }
  return null;
}

export function parseDashboard(html: string): ParsedData {
  return {
    rolling: parseWindow(html, RE_ROLLING_U, RE_ROLLING_R),
    weekly: parseWindow(html, RE_WEEKLY_U, RE_WEEKLY_R),
  };
}

export function isAuthenticatedUrl(url: string, workspaceId: string): boolean {
  try {
    return new URL(url).pathname === `/workspace/${workspaceId}/go`;
  } catch {
    return false;
  }
}

export async function fetchDashboard(
  workspaceId: string,
  authCookie: string,
  fetchFn: OpenCodeGoFetch = (url, init) => fetch(url, init),
): Promise<string> {
  const url = DASHBOARD_URL(workspaceId);
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), SCRAPE_TIMEOUT_MS);
  try {
    const resp = await fetchFn(url, {
      headers: { Cookie: `auth=${authCookie}`, 'User-Agent': USER_AGENT },
      signal: controller.signal,
    });
    if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
    if (!isAuthenticatedUrl(resp.url, workspaceId))
      throw new Error('auth invalid or session expired');
    return await resp.text();
  } finally {
    clearTimeout(timer);
  }
}

function formatGoWindow(w: GoWindow): string {
  const remaining = 100 - Math.max(0, Math.min(100, w.usagePercent));
  return `${remaining.toFixed(0)}%, ${formatDuration(w.resetInSec * 1000)}`;
}

export function formatGoStatus(data: ParsedData): string | undefined {
  const { rolling, weekly } = data;
  return formatQuotaStatus(
    rolling ? formatGoWindow(rolling) : undefined,
    weekly ? formatGoWindow(weekly) : undefined,
  );
}

export class OpenCodeGoAdapter implements QuotaAdapter {
  async fetch(params?: { cwd?: string }): Promise<QuotaResult> {
    try {
      const config = readConfig(params?.cwd);
      const authCookie = readAuthCookie(params?.cwd);
      if (!config || !authCookie) return { status: 'unknown' };

      const html = await fetchDashboard(config.workspaceId, authCookie);
      const data = parseDashboard(html);

      const display = formatGoStatus(data);
      if (!display) return { status: 'unknown' };
      if (!data.rolling || !data.weekly) return { status: 'partial', display };
      return { status: 'ok', display };
    } catch {
      return { status: 'unknown' };
    }
  }
}
