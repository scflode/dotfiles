#!/usr/bin/env bash
set -euo pipefail

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/home/.dotfiles/config/workmux" "$tmp/config/workmux"
printf 'agent: pi\n' > "$tmp/home/.dotfiles/config/workmux/config.yaml"
ln -s "$tmp/home/.dotfiles/config/workmux/config.yaml" "$tmp/config/workmux/config.yaml"
for mode in light dark; do
  HOME="$tmp/home" XDG_CONFIG_HOME="$tmp/config" "$(dirname "$0")/workmux-theme.sh" "$mode"
  grep -qx "  mode: $mode" "$tmp/config/workmux/config.yaml"
  grep -qx 'agent: pi' "$tmp/config/workmux/config.yaml"
  ! grep -q 'mode:' "$tmp/home/.dotfiles/config/workmux/config.yaml"
done
