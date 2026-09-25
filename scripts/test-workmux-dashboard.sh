#!/usr/bin/env bash
set -euo pipefail

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/home/.dotfiles/config/workmux" "$tmp/home/.local/state/tmux"
printf 'agent: pi\n' > "$tmp/home/.dotfiles/config/workmux/config.yaml"
cat > "$tmp/bin/workmux" <<'EOF'
#!/usr/bin/env bash
[ "$1" = dashboard ]
grep -qx "  mode: $EXPECTED_MODE" "$XDG_CONFIG_HOME/workmux/config.yaml"
EOF
chmod +x "$tmp/bin/workmux"

for mode in light dark; do
  theme=catppuccin_latte
  [ "$mode" = dark ] && theme=catppuccin_mocha
  ln -sf "/tmp/$theme.tmux" "$tmp/home/.local/state/tmux/tmux-dark-notify-theme.conf"
  EXPECTED_MODE="$mode" HOME="$tmp/home" PATH="$tmp/bin:$PATH" "$(dirname "$0")/workmux-dashboard.sh"
done
