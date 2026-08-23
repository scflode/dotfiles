import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';
import { formatStatusLabel, styledLabel, type ThemeAnsiLike } from './adapters/style.ts';
import { fetchOpencodeGoPrStatus, formatOpencodeGoPrStatus, type PrStatus } from './providers/opencode-go/pr-status.ts';
import { registerQuotaStatusExtractCommand } from './commands/extract.ts';
import { registerQuotaStatusUsageCommand } from './commands/usage.ts';
import { getQuotaAdapter, hasQuotaAdapter } from './provider-registry.ts';

const STATUS_KEY = 'quota-status';
const REFRESH_OK_MS = 60_000;
const REFRESH_RETRY_MS = 15_000;
const STALE_FAILURE_LIMIT = 3;

interface PiContext {
  hasUI?: boolean;
  ui: {
    setStatus(key: string, value: string | undefined): void;
    theme?: ThemeAnsiLike;
  };
  model?: { provider?: string };
  cwd?: string;
}

interface RefreshState {
  cachedDisplay: string | undefined;
  lastAttemptAt: number;
  consecutiveFailures: number;
  notApplicable: boolean;
}

interface SessionProviderSnapshot {
  sessionEpoch: number;
  provider?: string;
}

export function shouldAnnounceOpencodeGoPrStatus(params: {
  hasUI: boolean;
  reason: 'session_start' | 'model_select';
  previousProvider?: string;
  nextProvider?: string;
}): boolean {
  if (!params.hasUI || params.nextProvider !== 'opencode-go') return false;
  if (params.reason === 'session_start') return true;
  return params.previousProvider !== 'opencode-go';
}

export function nextRefreshDelayMs(state: RefreshState): number {
  return state.consecutiveFailures === 0 ? REFRESH_OK_MS : REFRESH_RETRY_MS;
}

export function shouldRefresh(state: RefreshState, now: number): boolean {
  return now - state.lastAttemptAt >= nextRefreshDelayMs(state);
}

export function isCurrentSessionProvider(
  expected: SessionProviderSnapshot,
  current: SessionProviderSnapshot,
): boolean {
  return expected.sessionEpoch === current.sessionEpoch && expected.provider === current.provider;
}

export function sessionProviderKey(snapshot: SessionProviderSnapshot): string {
  return `${snapshot.sessionEpoch}:${snapshot.provider ?? ''}`;
}

export function applyRefreshResult(
  state: RefreshState,
  result: { status: 'ok'; display: string } | { status: 'partial'; display: string } | { status: 'not_applicable' } | { status: 'unknown' },
  now: number,
): RefreshState {
  if (result.status === 'ok') {
    return { cachedDisplay: result.display, lastAttemptAt: now, consecutiveFailures: 0, notApplicable: false };
  }
  if (result.status === 'not_applicable') {
    return { cachedDisplay: undefined, lastAttemptAt: now, consecutiveFailures: 0, notApplicable: true };
  }

  const consecutiveFailures = state.consecutiveFailures + 1;
  if (result.status === 'partial') {
    return {
      cachedDisplay: state.cachedDisplay !== undefined && consecutiveFailures < STALE_FAILURE_LIMIT
        ? state.cachedDisplay
        : result.display,
      lastAttemptAt: now,
      consecutiveFailures,
      notApplicable: false,
    };
  }

  return {
    cachedDisplay: consecutiveFailures >= STALE_FAILURE_LIMIT ? undefined : state.cachedDisplay,
    lastAttemptAt: now,
    consecutiveFailures,
    notApplicable: false,
  };
}

export {
  QUOTA_STATUS_EXTRACT_COMMAND,
  QUOTA_STATUS_EXTRACT_USAGE,
  detectExtractProviders,
  parseExtractArgs,
  registerQuotaStatusExtractCommand,
  runQuotaStatusExtract,
} from './commands/extract.ts';
export {
  QUOTA_STATUS_USAGE_COMMAND,
  registerQuotaStatusUsageCommand,
  runQuotaStatusUsage,
} from './commands/usage.ts';
export type { ExtractProvider, QuotaStatusExtractResult, QuotaStatusUsageResult } from './commands/types.ts';

export default function quotaStatus(pi: ExtensionAPI) {
  let ctx: PiContext | undefined;
  let refreshState: RefreshState = {
    cachedDisplay: undefined,
    lastAttemptAt: 0,
    consecutiveFailures: 0,
    notApplicable: false,
  };
  let activeRefreshKey: string | undefined;
  let lastProvider: string | undefined;
  let interval: ReturnType<typeof setInterval> | undefined;
  let activePrAnnouncementKey: string | undefined;
  let cachedMergedPrStatus: PrStatus | null | undefined;
  let sessionEpoch = 0;

  registerQuotaStatusUsageCommand(pi);
  registerQuotaStatusExtractCommand(pi);

  const provider = () => ctx?.model?.provider;
  const sessionProviderSnapshot = (): SessionProviderSnapshot => ({
    sessionEpoch,
    provider: provider(),
  });

  const render = () => {
    const p = provider();
    let value: string | undefined;

    if (!hasQuotaAdapter(p) || refreshState.notApplicable) {
      value = styledLabel('n/a');
    } else if (refreshState.cachedDisplay === undefined) {
      value = styledLabel('unknown');
    } else {
      value = formatStatusLabel(refreshState.cachedDisplay, ctx?.ui.theme);
    }

    ctx?.ui.setStatus(STATUS_KEY, value);
  };

  const refresh = async () => {
    const snapshot = sessionProviderSnapshot();
    const snapshotKey = sessionProviderKey(snapshot);
    const adapter = getQuotaAdapter(snapshot.provider);
    if (!adapter || activeRefreshKey === snapshotKey) {
      render();
      return;
    }

    activeRefreshKey = snapshotKey;
    try {
      const result = await adapter.fetch({ cwd: ctx?.cwd, provider: snapshot.provider });
      if (isCurrentSessionProvider(snapshot, sessionProviderSnapshot())) {
        refreshState = applyRefreshResult(refreshState, result, Date.now());
      }
    } finally {
      if (activeRefreshKey === snapshotKey) activeRefreshKey = undefined;
      render();
    }
  };

  const resetStateIfProviderChanged = () => {
    const p = provider();
    if (p !== lastProvider) {
      refreshState = {
        cachedDisplay: undefined,
        lastAttemptAt: 0,
        consecutiveFailures: 0,
        notApplicable: false,
      };
      lastProvider = p;
    }
  };

  const announceOpencodeGoPrStatus = () => {
    const snapshot = sessionProviderSnapshot();
    const snapshotKey = sessionProviderKey(snapshot);
    if (!ctx?.hasUI || snapshot.provider !== 'opencode-go' || activePrAnnouncementKey === snapshotKey) return;

    const sendAnnouncement = (status: PrStatus) => {
      pi.sendMessage({
        customType: 'quota-status',
        content: formatOpencodeGoPrStatus(status),
        display: true,
      });
    };

    if (cachedMergedPrStatus) {
      sendAnnouncement(cachedMergedPrStatus);
      return;
    }

    activePrAnnouncementKey = snapshotKey;
    void (async () => {
      const status = await fetchOpencodeGoPrStatus();
      if (status?.merged && isCurrentSessionProvider(snapshot, sessionProviderSnapshot())) {
        cachedMergedPrStatus = status;
        sendAnnouncement(status);
      }
    })().finally(() => {
      if (activePrAnnouncementKey === snapshotKey) activePrAnnouncementKey = undefined;
    });
  };

  const tick = () => {
    resetStateIfProviderChanged();
    render();
    const p = provider();
    if (hasQuotaAdapter(p) && shouldRefresh(refreshState, Date.now())) void refresh();
  };

  pi.on('session_start', (_event, nextCtx) => {
    if (interval) clearInterval(interval);
    sessionEpoch += 1;
    ctx = nextCtx as PiContext;
    lastProvider = undefined;
    if (!ctx.hasUI) return;
    tick();
    if (shouldAnnounceOpencodeGoPrStatus({
      hasUI: true,
      reason: 'session_start',
      nextProvider: provider(),
    })) announceOpencodeGoPrStatus();
    interval = setInterval(tick, 1000);
  });

  pi.on('model_select', (_event, nextCtx) => {
    const previousProvider = provider();
    ctx = nextCtx as PiContext;
    if (!ctx.hasUI) return;
    tick();
    if (shouldAnnounceOpencodeGoPrStatus({
      hasUI: true,
      reason: 'model_select',
      previousProvider,
      nextProvider: provider(),
    })) announceOpencodeGoPrStatus();
  });

  pi.on('turn_end', () => {
    if (ctx?.hasUI) tick();
  });

  pi.on('agent_end', () => {
    if (ctx?.hasUI) tick();
  });

  pi.on('session_compact', () => {
    if (ctx?.hasUI) tick();
  });

  pi.on('session_shutdown', (_event, shutdownCtx) => {
    sessionEpoch += 1;
    if (interval) clearInterval(interval);
    interval = undefined;
    ctx = undefined;
    refreshState = {
      cachedDisplay: undefined,
      lastAttemptAt: 0,
      consecutiveFailures: 0,
      notApplicable: false,
    };
    activeRefreshKey = undefined;
    activePrAnnouncementKey = undefined;
    lastProvider = undefined;
    if (shutdownCtx.hasUI) shutdownCtx.ui.setStatus(STATUS_KEY, undefined);
  });
}
