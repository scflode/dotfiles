#!/usr/bin/env bash

client=${1:-}
target=()
[[ -n "$client" ]] && target=(-t "$client")

status_format="#{$E:@dotfiles-status-format}"

# Always restore status bar, even on signals or early exit
restore() {
  tmux set -g status on "${target[@]}" 2>/dev/null || true
  tmux set -g status-format[0] "$status_format" "${target[@]}" 2>/dev/null || true
}
trap restore EXIT TERM INT HUP

# Half-height status bar while prompt is active
tmux set -g status 2"${target[@]}"
tmux set -g status-format[0] "" "${target[@]}"
tmux set -g status-format[1] "$status_format" "${target[@]}"

# Show the prompt (returns when closed by user or timeout)
tmux command-prompt "${target[@]}" -T command -p ':' '%%'
