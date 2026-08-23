const PR_URL = 'https://github.com/anomalyco/opencode/pull/16513';
const PR_API_URL = 'https://api.github.com/repos/anomalyco/opencode/pulls/16513';
const FETCH_TIMEOUT_MS = 10_000;

interface PullRequestResponse {
  merged_at?: string | null;
  state?: string;
  html_url?: string;
}

export interface PrStatus {
  merged: boolean;
  url: string;
}

export async function fetchOpencodeGoPrStatus(): Promise<PrStatus | undefined> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), FETCH_TIMEOUT_MS);
  try {
    const response = await fetch(PR_API_URL, {
      headers: {
        Accept: 'application/vnd.github+json',
        'User-Agent': 'pi-quota-status',
      },
      signal: controller.signal,
    });
    if (!response.ok) return undefined;

    const body = (await response.json()) as PullRequestResponse;
    return {
      merged: typeof body.merged_at === 'string' && body.merged_at.length > 0,
      url: typeof body.html_url === 'string' && body.html_url.length > 0 ? body.html_url : PR_URL,
    };
  } catch {
    return undefined;
  } finally {
    clearTimeout(timer);
  }
}

export function formatOpencodeGoPrStatus(status: PrStatus): string {
  return `opencode-go note: PR merged — ${status.url} — quota-status can be simplified to a direct request instead of dashboard scraping.`;
}
