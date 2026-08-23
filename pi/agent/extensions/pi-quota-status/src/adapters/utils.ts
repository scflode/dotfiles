export function formatDuration(ms: number): string {
  const minutes = Math.max(0, ms / 60_000);
  if (minutes >= 1440) return `${(minutes / 1440).toFixed(2)}d`;
  if (minutes >= 60) {
    const totalMinutes = Math.round(minutes);
    const hours = Math.floor(totalMinutes / 60);
    const remainingMinutes = totalMinutes % 60;
    return remainingMinutes === 0 ? `${hours}h` : `${hours}h${remainingMinutes}m`;
  }
  return `${minutes.toFixed(0)}min`;
}

export function formatQuotaStatus(fiveHour?: string | null, weekly?: string | null): string | undefined {
  const parts = [];
  if (fiveHour) parts.push(`5h(${fiveHour})`);
  if (weekly) parts.push(`Wk(${weekly})`);
  return parts.length ? parts.join(' ') : undefined;
}
