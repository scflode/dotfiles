import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { dirname, join } from 'node:path';

const QUOTA_STATUS_KEY = 'quota-status';

export function globalAuthPath(): string {
  return join(homedir(), '.pi', 'agent', 'auth.json');
}

function readJsonFile(path: string): Record<string, unknown> | undefined {
  try {
    return JSON.parse(readFileSync(path, 'utf8')) as Record<string, unknown>;
  } catch {
    return undefined;
  }
}

export function readQuotaStatusProviderConfig(
  providerKey: string,
  authPath: string = globalAuthPath(),
): Record<string, unknown> | undefined {
  const auth = readJsonFile(authPath);
  const quotaStatus = auth?.[QUOTA_STATUS_KEY];
  if (!quotaStatus || typeof quotaStatus !== 'object' || Array.isArray(quotaStatus)) return undefined;

  const provider = (quotaStatus as Record<string, unknown>)[providerKey];
  if (!provider || typeof provider !== 'object' || Array.isArray(provider)) return undefined;
  return provider as Record<string, unknown>;
}

export function writeQuotaStatusProviderConfig(
  providerKey: string,
  config: Record<string, unknown>,
  authPath: string = globalAuthPath(),
): void {
  const existing = readJsonFile(authPath) ?? {};
  const existingQuotaStatus = existing[QUOTA_STATUS_KEY];
  const quotaStatus =
    existingQuotaStatus && typeof existingQuotaStatus === 'object' && !Array.isArray(existingQuotaStatus)
      ? (existingQuotaStatus as Record<string, unknown>)
      : {};

  const next = {
    ...existing,
    [QUOTA_STATUS_KEY]: {
      ...quotaStatus,
      [providerKey]: config,
    },
  };

  mkdirSync(dirname(authPath), { recursive: true });
  writeFileSync(authPath, `${JSON.stringify(next, null, 2)}\n`, 'utf8');
}
