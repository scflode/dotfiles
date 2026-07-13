for brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  [[ -x $brew ]] && eval "$("$brew" shellenv)" && break
done

autoload -U compinit && compinit
autoload -U +X bashcompinit && bashcompinit

if (( $+commands[brew] )); then
  antidote="$(brew --prefix antidote)/share/antidote/antidote.zsh"
  if [[ -f $antidote ]]; then
    source "$antidote"
    zsh_plugins="${ZDOTDIR:-$HOME}/.zsh_plugins.zsh"
    if [[ ! -f $zsh_plugins || ${zsh_plugins:r}.txt -nt $zsh_plugins ]]; then
      antidote bundle < "${zsh_plugins:r}.txt" > "$zsh_plugins"
    fi
    source "$zsh_plugins"
  fi
fi

onepassword_agent="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
[[ -S $onepassword_agent ]] && export SSH_AUTH_SOCK="$onepassword_agent"

ssh() {
  if [[ ${SSH_AUTH_SOCK:-} == "$onepassword_agent" ]]; then
    ssh-add -l >/dev/null 2>&1
    if (( $? == 2 )); then
      open -a '1Password'
      print -u2 -- '1Password SSH agent unavailable. Unlock 1Password, then rerun SSH.'
      return 255
    fi
  fi

  command ssh "$@"
}

fpath+=(~/.config/hcloud/completion/zsh)

hosts=$(awk '/^Host / {printf("%s ",$2)}' ~/.ssh/config 2>/dev/null)
zstyle ':completion:*:hosts' hosts $hosts
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

(( $+commands[kubectl] )) && source <(kubectl completion zsh)
(( $+commands[doctl] )) && source <(doctl completion zsh)
(( $+commands[op] )) && eval "$(op completion zsh)" && compdef _op op
(( $+commands[mise] )) && eval "$(mise activate zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init zsh --cmd cd)"
