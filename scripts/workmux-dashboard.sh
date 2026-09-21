#!/usr/bin/env bash
set -euo pipefail

state_dir=${XDG_STATE_HOME:-$HOME/.local/state}/tmux
link=$state_dir/tmux-dark-notify-theme.conf
mode=light

case "$(readlink "$link" 2>/dev/null || true)" in
  *catppuccin_mocha.tmux) mode=dark ;;
  *catppuccin_latte.tmux) mode=light ;;
  *) defaults read -g AppleInterfaceStyle 2>/dev/null | grep -qx Dark && mode=dark ;;
esac

tmp=$(mktemp -d "${TMPDIR:-/tmp}/workmux.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/workmux"
cp "$HOME/.config/workmux/config.yaml" "$tmp/workmux/config.yaml"
printf '\ntheme:\n  mode: %s\n' "$mode" >> "$tmp/workmux/config.yaml"

XDG_CONFIG_HOME=$tmp workmux dashboard
