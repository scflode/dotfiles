import { globalAuthPath, writeQuotaStatusProviderConfig } from '../../adapters/auth-json-store.ts';
import type { AnthropicApiConfig } from './adapter.ts';

const COOKIE_ALLOWLIST = new Set([
  'sessionKey',
  'sessionKeyLC',
  'cf_clearance',
  'routingHint',
  'lastActiveOrg',
  'anthropic-device-id',
  'activitySessionId',
  '_cfuvid',
  '__cf_bm',
]);

const SESSION_COOKIE_NAMES = ['sessionKey', 'sessionKeyLC'];

const HEADER_ALLOWLIST = new Set([
  'anthropic-anonymous-id',
  'anthropic-client-platform',
  'anthropic-client-sha',
  'anthropic-client-version',
  'anthropic-device-id',
  'x-activity-session-id',
  'user-agent',
]);

const USAGE_ENDPOINT_RE = /^\/api\/organizations\/([^/]+)\/usage$/;

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

export type HarExtractionResult =
  | { ok: true; config: AnthropicApiConfig }
  | { ok: false; error: string };

export function filterCookies(cookieHeader: string): string {
  return cookieHeader
    .split(';')
    .map((s) => s.trim())
    .filter((s) => {
      const eq = s.indexOf('=');
      const name = eq >= 0 ? s.slice(0, eq).trim() : s.trim();
      return COOKIE_ALLOWLIST.has(name);
    })
    .join('; ');
}

export function filterHeaders(headers: Array<{ name: string; value: string }>): Record<string, string> {
  const result: Record<string, string> = {};
  for (const h of headers) {
    const lower = h.name.toLowerCase();
    if (HEADER_ALLOWLIST.has(lower)) {
      result[lower] = h.value;
    }
  }
  return result;
}

export function extractOrganizationUuid(url: string): string | undefined {
  try {
    const { pathname } = new URL(url);
    const m = USAGE_ENDPOINT_RE.exec(pathname);
    return m ? m[1] : undefined;
  } catch {
    return undefined;
  }
}

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

export function detectAnthropicHar(harContent: string): boolean {
  let parsed: unknown;
  try {
    parsed = JSON.parse(harContent);
  } catch {
    return false;
  }

  return getEntries(parsed).some((entry) =>
    entry.request.method.toUpperCase() === 'GET' && !!extractOrganizationUuid(entry.request.url),
  );
}

export function extractFromHar(harContent: string): HarExtractionResult {
  let parsed: unknown;
  try {
    parsed = JSON.parse(harContent);
  } catch {
    return { ok: false, error: 'invalid HAR: not valid JSON' };
  }

  const entries = getEntries(parsed);

  let usageEntry: HarEntry | undefined;
  let organizationUuid: string | undefined;

  for (const entry of entries) {
    if (entry.request.method.toUpperCase() !== 'GET') continue;
    const uuid = extractOrganizationUuid(entry.request.url);
    if (uuid) {
      organizationUuid = uuid;
      usageEntry = entry;
      break;
    }
  }

  if (!usageEntry || !organizationUuid) {
    return {
      ok: false,
      error: 'no Claude usage endpoint found in HAR (expected GET /api/organizations/<uuid>/usage)',
    };
  }

  const cookieHeader =
    usageEntry.request.headers.find((h) => h.name.toLowerCase() === 'cookie')?.value ?? '';
  const authCookie = filterCookies(cookieHeader);

  const hasSession = SESSION_COOKIE_NAMES.some((name) =>
    authCookie.split(';').some((c) => c.trim().startsWith(`${name}=`)),
  );
  if (!hasSession) {
    return {
      ok: false,
      error: 'required session cookie (sessionKey or sessionKeyLC) not found in HAR request',
    };
  }

  const headers = filterHeaders(usageEntry.request.headers);

  const config: AnthropicApiConfig = {
    organizationUuid,
    authCookie,
    ...(Object.keys(headers).length > 0 ? { headers } : {}),
  };

  return { ok: true, config };
}

export function writeAnthropicConfig(config: AnthropicApiConfig, authPath?: string): void {
  writeQuotaStatusProviderConfig('anthropic-subscription', config, authPath ?? globalAuthPath());
}
