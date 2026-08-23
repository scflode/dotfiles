import { readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { resolve } from 'node:path';
import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';
import { fetchAnthropicApiUsage, type AnthropicApiConfig, type AnthropicApiFetch } from '../providers/anthropic/adapter.ts';
import { detectAnthropicHar, extractFromHar as extractAnthropicFromHar, writeAnthropicConfig } from '../providers/anthropic/har.ts';
import { type OpenCodeGoConfig, type OpenCodeGoFetch } from '../providers/opencode-go/adapter.ts';
import { detectOpencodeGoHar, extractFromHar as extractOpencodeGoFromHar, verifyOpencodeGoConfig, writeOpencodeGoConfig } from '../providers/opencode-go/har.ts';
import type { ExtractProvider, QuotaStatusExtractResult } from './types.ts';

export const QUOTA_STATUS_EXTRACT_COMMAND = 'quota-status-extract';
export const QUOTA_STATUS_EXTRACT_USAGE = 'Usage: /quota-status-extract [--write] [--no-verify] [--provider <anthropic-subscription|opencode-go>] <path/to/file.har>';

export function parseExtractArgs(args: string): {
  path: string | undefined;
  write: boolean;
  noVerify: boolean;
  provider: string | undefined;
} {
  const tokens = args.trim().split(/\s+/).filter(Boolean);
  let write = false;
  let noVerify = false;
  let provider: string | undefined;
  const pathTokens: string[] = [];

  for (let i = 0; i < tokens.length; i += 1) {
    const token = tokens[i];
    if (token === '--write') { write = true; continue; }
    if (token === '--no-verify') { noVerify = true; continue; }
    if (token === '--provider') {
      provider = tokens[i + 1];
      i += 1;
      continue;
    }
    pathTokens.push(token);
  }

  const rawPath = pathTokens.join(' ');
  const withoutAt = rawPath.startsWith('@') ? rawPath.slice(1) : rawPath;
  const path = withoutAt.length > 0
    ? (withoutAt === '~' ? homedir() : withoutAt.replace(/^~(?=\/)/, homedir()))
    : undefined;

  return { path, write, noVerify, provider };
}

export function detectExtractProviders(harContent: string): ExtractProvider[] {
  const detected: ExtractProvider[] = [];
  if (detectAnthropicHar(harContent)) detected.push('anthropic-subscription');
  if (detectOpencodeGoHar(harContent)) detected.push('opencode-go');
  return detected;
}

export async function runQuotaStatusExtract(params: {
  harContent: string;
  write: boolean;
  noVerify: boolean;
  provider?: string;
  anthropicFetchFn?: AnthropicApiFetch;
  opencodeFetchFn?: OpenCodeGoFetch;
  anthropicWriteFn?: (config: AnthropicApiConfig) => void;
  opencodeWriteFn?: (config: OpenCodeGoConfig) => void;
}): Promise<QuotaStatusExtractResult> {
  try {
    JSON.parse(params.harContent);
  } catch {
    return { message: 'quota-status extract failed: invalid HAR: not valid JSON', isError: true };
  }

  const detected = detectExtractProviders(params.harContent);

  let provider: ExtractProvider | undefined;
  if (params.provider !== undefined) {
    if (params.provider === 'anthropic-subscription' || params.provider === 'opencode-go') {
      provider = params.provider;
    } else {
      return {
        message: `quota-status extract failed: unsupported provider "${params.provider}". Use --provider anthropic-subscription or --provider opencode-go.`,
        isError: true,
      };
    }

    if (!detected.includes(provider)) {
      return {
        message: `quota-status extract failed: HAR does not contain detectable ${provider} traffic.`,
        isError: true,
      };
    }
  } else if (detected.length === 1) {
    [provider] = detected;
  } else if (detected.length === 0) {
    return {
      message: 'quota-status extract failed: no supported provider detected in HAR. Supported providers: anthropic-subscription, opencode-go.',
      isError: true,
    };
  } else {
    return {
      message: `quota-status extract failed: multiple providers detected in HAR (${detected.join(', ')}). Re-run with --provider <name>.`,
      isError: true,
    };
  }

  if (provider === 'anthropic-subscription') {
    const extraction = extractAnthropicFromHar(params.harContent);
    if (!extraction.ok) return { message: `quota-status extract failed: ${extraction.error}`, isError: true };

    const { config } = extraction;
    if (!params.noVerify) {
      try {
        await fetchAnthropicApiUsage(config, params.anthropicFetchFn);
      } catch {
        return {
          message: 'quota-status extract failed: verification failed for anthropic-subscription — check that your Claude session is still active.',
          isError: true,
        };
      }
    }

    if (params.write) {
      (params.anthropicWriteFn ?? writeAnthropicConfig)(config);
      return {
        message: 'quota-status config saved to ~/.pi/agent/auth.json under quota-status.anthropic-subscription. Restart or reload quota-status to apply.',
        isError: false,
      };
    }

    return {
      message: JSON.stringify(config, null, 2),
      isError: false,
    };
  }

  const extraction = extractOpencodeGoFromHar(params.harContent);
  if (!extraction.ok) return { message: `quota-status extract failed: ${extraction.error}`, isError: true };

  const { config } = extraction;
  if (!params.noVerify) {
    try {
      await verifyOpencodeGoConfig(config, params.opencodeFetchFn);
    } catch {
      return {
        message: 'quota-status extract failed: verification failed for opencode-go — check that your opencode session is still active.',
        isError: true,
      };
    }
  }

  if (params.write) {
    (params.opencodeWriteFn ?? writeOpencodeGoConfig)(config);
    return {
      message: 'quota-status config saved to ~/.pi/agent/auth.json under quota-status.opencode-go. Restart or reload quota-status to apply.',
      isError: false,
    };
  }

  return {
    message: JSON.stringify(config, null, 2),
    isError: false,
  };
}

export function registerQuotaStatusExtractCommand(pi: ExtensionAPI) {
  pi.registerCommand(QUOTA_STATUS_EXTRACT_COMMAND, {
    description: 'Extract quota-status provider auth config from a supported HAR export.',
    handler: async (args, cmdCtx) => {
      const send = (content: string) => pi.sendMessage({ customType: 'quota-status', content, display: true });

      const parsed = parseExtractArgs(args);
      if (!parsed.path) {
        send(QUOTA_STATUS_EXTRACT_USAGE);
        return;
      }

      let harContent: string;
      try {
        const absPath = resolve((cmdCtx as { cwd?: string }).cwd ?? process.cwd(), parsed.path);
        harContent = readFileSync(absPath, 'utf8');
      } catch {
        send(`quota-status extract failed: could not read HAR file at ${parsed.path}`);
        return;
      }

      const result = await runQuotaStatusExtract({
        harContent,
        write: parsed.write,
        noVerify: parsed.noVerify,
        provider: parsed.provider,
      });

      send(result.message);
    },
  });
}
