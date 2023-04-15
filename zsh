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

#export ZSH=${HOME}/.oh-my-zsh

eval "$(/opt/homebrew/bin/brew shellenv)"

autoload -U compinit && compinit
autoload -U +X bashcompinit && bashcompinit

load_antidote

#COMPLETION_WAITING_DOTS="true"
#ZSH_THEME="spaceship"
#HIST_STAMPS="mm/dd/yyyy"
#plugins=(asdf git docker docker-compose zsh-autosuggestions)

#SPACESHIP_NODE_SYMBOL="Node "
#SPACESHIP_ELIXIR_SYMBOL="Elixir "
#SPACESHIP_DOCKER_SYMBOL="Docker "

#source ${ZSH}/oh-my-zsh.sh

fpath+=(~/.config/hcloud/completion/zsh)

# ZSH completion
hosts=$(awk '/^Host / {printf("%s ",$2)}' ~/.ssh/config 2>/dev/null)
zstyle ':completion:*:hosts' hosts $hosts

# Docker autocompletion fix https://github.com/docker/docker/issues/31216
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

source <(kubectl completion zsh)

eval "$(op completion zsh)"; compdef _op op

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
