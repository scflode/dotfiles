import type { NormalizedQuotaUsage } from '../adapters/types.ts';

export type ExtractProvider = 'anthropic-subscription' | 'opencode-go';

export type QuotaStatusUsageResult =
  | { status: 'ok'; display: string; provider: string; usage?: NormalizedQuotaUsage }
  | { status: 'partial'; display: string; provider: string; usage?: NormalizedQuotaUsage }
  | { status: 'not_applicable'; provider: string }
  | { status: 'unknown'; provider: string }
  | { status: 'unsupported'; provider: string };

export type QuotaStatusExtractResult = { message: string; isError: boolean };
