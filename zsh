if (( $+commands[brew] )); then
  source "$(brew --prefix antidote)/share/antidote/antidote.zsh"

  zsh_plugins="${ZDOTDIR:-$HOME}/.zsh_plugins.zsh"
  if [[ ! -f $zsh_plugins || ${zsh_plugins:r}.txt -nt $zsh_plugins ]]; then
    antidote bundle < "${zsh_plugins:r}.txt" > "$zsh_plugins"
  fi
  source "$zsh_plugins"
fi

autoload -U compinit && compinit
autoload -U +X bashcompinit && bashcompinit

fpath+=(~/.config/hcloud/completion/zsh)

hosts=$(awk '/^Host / {printf("%s ",$2)}' ~/.ssh/config 2>/dev/null)
zstyle ':completion:*:hosts' hosts $hosts
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

(( $+commands[kubectl] )) && source <(kubectl completion zsh)
(( $+commands[doctl] )) && source <(doctl completion zsh)
(( $+commands[op] )) && eval "$(op completion zsh)" && compdef _op op
(( $+commands[mise] )) && eval "$(mise activate zsh)"
