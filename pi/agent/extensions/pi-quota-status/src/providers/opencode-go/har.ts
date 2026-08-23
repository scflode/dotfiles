import { globalAuthPath, writeQuotaStatusProviderConfig } from '../../adapters/auth-json-store.ts';
import { fetchDashboard, type OpenCodeGoConfig, type OpenCodeGoFetch } from './adapter.ts';

const WORKSPACE_GO_RE = /^\/workspace\/([^/]+)\/go$/;

interface HarNameValue {
  name: string;
  value: string;
}

interface HarEntry {
  request: {
    method: string;
    url: string;
    headers: HarNameValue[];
  };
}

export type OpencodeGoHarExtractionResult =
  | { ok: true; config: OpenCodeGoConfig }
  | { ok: false; error: string };

function getEntries(har: unknown): HarEntry[] {
  if (!har || typeof har !== 'object') return [];
  const log = (har as Record<string, unknown>).log;
  if (!log || typeof log !== 'object') return [];
  const entries = (log as Record<string, unknown>).entries;
  if (!Array.isArray(entries)) return [];
  return entries.filter(
    (e): e is HarEntry =>
      !!e &&
      typeof e === 'object' &&
      !!(e as Record<string, unknown>).request &&
      typeof (e as Record<string, unknown>).request === 'object',
  );
}

export function extractWorkspaceId(url: string): string | undefined {
  try {
    const { pathname } = new URL(url);
    const match = WORKSPACE_GO_RE.exec(pathname);
    return match ? match[1] : undefined;
  } catch {
    return undefined;
  }
}

export function extractAuthCookie(cookieHeader: string): string | undefined {
  for (const part of cookieHeader.split(';')) {
    const trimmed = part.trim();
    if (!trimmed) continue;
    const eq = trimmed.indexOf('=');
    const name = eq >= 0 ? trimmed.slice(0, eq).trim() : trimmed;
    if (name !== 'auth') continue;
    return eq >= 0 ? trimmed.slice(eq + 1) : '';
  }
  return undefined;
}

export function detectOpencodeGoHar(harContent: string): boolean {
  let parsed: unknown;
  try {
    parsed = JSON.parse(harContent);
  } catch {
    return false;
  }

  return getEntries(parsed).some((entry) =>
    entry.request.method.toUpperCase() === 'GET' && !!extractWorkspaceId(entry.request.url),
  );
}

export function extractFromHar(harContent: string): OpencodeGoHarExtractionResult {
  let parsed: unknown;
  try {
    parsed = JSON.parse(harContent);
  } catch {
    return { ok: false, error: 'invalid HAR: not valid JSON' };
  }

  const entries = getEntries(parsed);
  let sawWorkspaceDashboard = false;

  for (const entry of entries) {
    if (entry.request.method.toUpperCase() !== 'GET') continue;

    const workspaceId = extractWorkspaceId(entry.request.url);
    if (!workspaceId) continue;
    sawWorkspaceDashboard = true;

    const cookieHeader = entry.request.headers.find((h) => h.name.toLowerCase() === 'cookie')?.value ?? '';
    const authCookie = extractAuthCookie(cookieHeader);
    if (!authCookie) continue;

    return {
      ok: true,
      config: { workspaceId, authCookie },
    };
  }

  if (sawWorkspaceDashboard) {
    return {
      ok: false,
      error: 'opencode workspace HAR entry found, but auth cookie was missing',
    };
  }

  return {
    ok: false,
    error: 'no authenticated opencode workspace HAR entry found (expected GET /workspace/<workspaceId>/go)',
  };
}

export async function verifyOpencodeGoConfig(
  config: OpenCodeGoConfig,
  fetchFn?: OpenCodeGoFetch,
): Promise<void> {
  await fetchDashboard(config.workspaceId, config.authCookie, fetchFn);
}

export function writeOpencodeGoConfig(config: OpenCodeGoConfig, authPath?: string): void {
  writeQuotaStatusProviderConfig('opencode-go', config, authPath ?? globalAuthPath());
}
