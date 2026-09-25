#!/usr/bin/env bash
set -euo pipefail

mode=${1:?expected light or dark}
case "$mode" in light|dark) ;; *) exit 2 ;; esac

config_dir=${XDG_CONFIG_HOME:-$HOME/.config}/workmux
source_config=$HOME/.dotfiles/config/workmux/config.yaml
mkdir -p "$config_dir"
tmp=$(mktemp "$config_dir/.config.XXXXXX")
trap 'rm -f "$tmp"' EXIT
cp "$source_config" "$tmp"
printf '\ntheme:\n  mode: %s\n' "$mode" >> "$tmp"
mv -f "$tmp" "$config_dir/config.yaml"
