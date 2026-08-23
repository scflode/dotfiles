import type { QuotaAdapter } from './adapters/types.ts';
import { OpenAICodexAdapter } from './providers/openai-codex/adapter.ts';
import { OpenCodeGoAdapter } from './providers/opencode-go/adapter.ts';
import { AnthropicAdapter } from './providers/anthropic/adapter.ts';

const anthropicAdapter = new AnthropicAdapter();

export const PROVIDER_ADAPTERS: Record<string, QuotaAdapter> = {
  'openai-codex': new OpenAICodexAdapter(),
  'opencode-go': new OpenCodeGoAdapter(),
  'anthropic': anthropicAdapter,
  'claude-bridge': anthropicAdapter,
};

export function getQuotaAdapter(provider: string | undefined): QuotaAdapter | undefined {
  if (provider?.startsWith('openai-codex-')) return PROVIDER_ADAPTERS['openai-codex'];
  return provider ? PROVIDER_ADAPTERS[provider] : undefined;
}

export function hasQuotaAdapter(provider: string | undefined): provider is string {
  return getQuotaAdapter(provider) !== undefined;
}
