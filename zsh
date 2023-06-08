#!/usr/bin/env sh

function load_antidote {
  source ${ZDOTDIR:-~}/.antidote/antidote.zsh

  # initialize plugins statically with ${ZDOTDIR:-~}/.zsh_plugins.txt
  antidote load

  # Set the name of the static .zsh plugins file antidote will generate.
  zsh_plugins=${ZDOTDIR:-~}/.zsh_plugins.zsh

  # Ensure you have a .zsh_plugins.txt file where you can add plugins.
  [[ -f ${zsh_plugins:r}.txt ]] || touch ${zsh_plugins:r}.txt

  # Lazy-load antidote.
  fpath+=(${ZDOTDIR:-~}/.antidote)
  autoload -Uz $fpath[-1]/antidote

  # Generate static file in a subshell when .zsh_plugins.txt is updated.
  if [[ ! $zsh_plugins -nt ${zsh_plugins:r}.txt ]]; then
    (antidote bundle <${zsh_plugins:r}.txt >|$zsh_plugins)
  fi

  # Source your static plugins file.
  source $zsh_plugins
}

eval "$(/opt/homebrew/bin/brew shellenv)"

autoload -U compinit && compinit
autoload -U +X bashcompinit && bashcompinit

load_antidote

fpath+=(~/.config/hcloud/completion/zsh)

# ZSH completion
hosts=$(awk '/^Host / {printf("%s ",$2)}' ~/.ssh/config 2>/dev/null)
zstyle ':completion:*:hosts' hosts $hosts

# Docker autocompletion fix https://github.com/docker/docker/issues/31216
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# kubectl
source <(kubectl completion zsh)

# doctl
source <(doctl completion zsh)

# 1Password
eval "$(op completion zsh)"; compdef _op op

