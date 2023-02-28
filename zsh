#!/usr/bin/env sh

export ZSH=${HOME}/.oh-my-zsh

eval "$(/opt/homebrew/bin/brew shellenv)"

COMPLETION_WAITING_DOTS="true"
ZSH_THEME="spaceship"
HIST_STAMPS="mm/dd/yyyy"
plugins=(asdf git docker docker-compose zsh-autosuggestions)

#SPACESHIP_NODE_SYMBOL="Node "
#SPACESHIP_ELIXIR_SYMBOL="Elixir "
#SPACESHIP_DOCKER_SYMBOL="Docker "

source ${ZSH}/oh-my-zsh.sh

fpath+=(~/.config/hcloud/completion/zsh)

autoload -U compinit && compinit
autoload -U +X bashcompinit && bashcompinit

# ZSH completion
hosts=$(awk '/^Host / {printf("%s ",$2)}' ~/.ssh/config 2>/dev/null)
zstyle ':completion:*:hosts' hosts $hosts

# Docker autocompletion fix https://github.com/docker/docker/issues/31216
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

source <(kubectl completion zsh)

eval "$(op completion zsh)"; compdef _op op
