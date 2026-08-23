export interface NormalizedQuotaWindow {
  /** Remaining quota as a percentage (0–100, clamped). */
  remainingPct: number;
  /** ISO 8601 timestamp of next reset, or null when no active window is running. */
  resetAt: string | null;
}

export interface NormalizedQuotaUsage {
  /** Five-hour rolling window, or null when the provider does not expose it. */
  fiveHour: NormalizedQuotaWindow | null;
  /** Seven-day/weekly window, or null when the provider does not expose it. */
  weekly: NormalizedQuotaWindow | null;
}

export type QuotaResult =
  | { status: 'ok'; display: string; usage?: NormalizedQuotaUsage }
  | { status: 'partial'; display: string; usage?: NormalizedQuotaUsage }
  | { status: 'not_applicable' }
  | { status: 'unknown' };

export interface QuotaAdapter {
  fetch(params?: { cwd?: string; provider?: string }): Promise<QuotaResult>;
}
