const GREY_ITALIC = '\x1b[3;90m';
const RESET = '\x1b[0m';

export interface ThemeAnsiLike {
  getFgAnsi?(color: string): string;
  fg?(color: string, text: string): string;
}

export function shouldEmitAnsi(env: NodeJS.ProcessEnv = process.env): boolean {
  if ('NO_COLOR' in env) return false;
  if (env.TERM === 'dumb') return false;
  return true;
}

function stripAnsiSuffix(value: string): string {
  return value.replace(/\x1b\[(?:0|39)m$/, '');
}

function colorize(prefix: string, text: string): string {
  return prefix ? `${prefix}${text}${RESET}` : text;
}

function getThemeAnsi(theme: ThemeAnsiLike | undefined, color: string): string {
  try {
    if (theme?.getFgAnsi) return stripAnsiSuffix(theme.getFgAnsi(color));
    if (theme?.fg) return stripAnsiSuffix(theme.fg(color, ''));
  } catch {
    // ignore and fall back
  }
  return '';
}

export function styledLabel(label: string, env: NodeJS.ProcessEnv = process.env): string {
  if (!shouldEmitAnsi(env)) return label;
  return `${GREY_ITALIC}${label}${RESET}`;
}

export function formatStatusLabel(
  label: string,
  theme?: ThemeAnsiLike,
  env: NodeJS.ProcessEnv = process.env,
): string {
  if (!shouldEmitAnsi(env)) return label;

  try {
    if (theme?.fg) return theme.fg('mdHeading', label);
  } catch {
    // ignore and fall back
  }

  return colorize(getThemeAnsi(theme, 'mdHeading'), label);
}
