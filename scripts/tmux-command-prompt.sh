#!/usr/bin/env bash
set -euo pipefail

client=${1:-}
target=()
[[ -n $client ]] && target=(-t "$client")

status_format='#{E:@dotfiles-status-format}'

tmux set -g status 2
tmux set -g status-format[0] ""
tmux set -g status-format[1] "$status_format"
tmux command-prompt "${target[@]}" -T command -p ':' '%%'

# command-prompt returns immediately; restore one-line status when prompt closes.
for _ in {1..10}; do
  [[ $(tmux display-message "${target[@]}" -p '#{command_prompt}') == 1 ]] && break
  sleep 0.05
done
while [[ $(tmux display-message "${target[@]}" -p '#{command_prompt}') == 1 ]]; do
  sleep 0.05
done

tmux set -g status on
tmux set -g status-format[0] "$status_format"
