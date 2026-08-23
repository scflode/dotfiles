import { test, expect } from 'bun:test';
import { applyRefreshResult } from './extension.ts';
import { getQuotaAdapter } from './provider-registry.ts';
import { authFromEnv, authFromStore } from './providers/openai-codex/adapter.ts';

test('uses Codex alias provider and credentials', () => {
  expect(getQuotaAdapter('openai-codex-work')).toBe(getQuotaAdapter('openai-codex'));
  expect(authFromStore({
    'openai-codex-scout24': { access: 'scout-token', accountId: 'scout-account' },
    'openai-codex-munichmade': { access: 'munich-token', accountId: 'munich-account' },
  }, 'openai-codex-scout24')).toEqual({ access: 'scout-token', accountId: 'scout-account' });
  expect(authFromEnv({
    OPENAI_CODEX_ACCESS_TOKEN: 'alias-token',
    CHATGPT_ACCOUNT_ID: 'alias-account',
  })).toEqual({ access: 'alias-token', accountId: 'alias-account' });
});

test('renders unavailable business quota as n/a', () => {
  expect(applyRefreshResult(
    { cachedDisplay: undefined, lastAttemptAt: 0, consecutiveFailures: 0, notApplicable: false },
    { status: 'not_applicable' },
    1,
  ).notApplicable).toBeTrue();
});

test('keeps non-Codex providers unsupported', () => {
  expect(getQuotaAdapter('openai-codexx-work')).toBeUndefined();
  expect(authFromEnv({ OPENAI_CODEX_ACCESS_TOKEN: 'token' })).toBeUndefined();
});
