import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';
import type { QuotaAdapter } from '../adapters/types.ts';
import { getQuotaAdapter } from '../provider-registry.ts';
import type { QuotaStatusUsageResult } from './types.ts';

export const QUOTA_STATUS_USAGE_COMMAND = 'quota-status-usage';

function formatUsageText(result: QuotaStatusUsageResult): string {
  if (result.status === 'ok' || result.status === 'partial') return result.display;
  if (result.status === 'unsupported') return result.provider ? `unsupported: ${result.provider}` : 'unsupported';
  return result.status === 'not_applicable' ? 'n/a' : 'unknown';
}

export async function runQuotaStatusUsage(params: {
  provider: string | undefined;
  adapterOverride?: QuotaAdapter;
  cwd?: string;
}): Promise<QuotaStatusUsageResult> {
  const { provider } = params;

  if (!provider) {
    return { status: 'unsupported', provider: '' };
  }

  const adapter = params.adapterOverride ?? getQuotaAdapter(provider);
  if (!adapter) {
    return { status: 'unsupported', provider };
  }

  const result = await adapter.fetch({ cwd: params.cwd, provider });
  if (result.status === 'unknown' || result.status === 'not_applicable') {
    return { status: result.status, provider };
  }
  return { ...result, provider };
}

export function registerQuotaStatusUsageCommand(pi: ExtensionAPI) {
  pi.registerCommand(QUOTA_STATUS_USAGE_COMMAND, {
    description: 'Fetch and print quota usage for the active provider. Use --json for structured output.',
    handler: async (args, cmdCtx) => {
      const json = args.split(/\s+/).includes('--json'); // ponytail: token split, not substring
      const result = await runQuotaStatusUsage({
        provider: (cmdCtx as unknown as { model?: { provider?: string } }).model?.provider,
        cwd: (cmdCtx as unknown as { cwd?: string }).cwd,
      });
      const content = json ? JSON.stringify(result, null, 2) : formatUsageText(result);
      const mode = (cmdCtx as unknown as { mode?: string }).mode;
      if (mode === 'print' || mode === 'json') {
        process.stdout.write(`${content}\n`);
        return;
      }
      pi.sendMessage({ customType: 'quota-status', content, display: true });
    },
  });
}
