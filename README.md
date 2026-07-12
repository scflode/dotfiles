# dotfiles

Personal macOS setup and dotfiles.

## Install

Bootstrap from macOS Terminal. Initial clone uses HTTPS, so SSH/Nextcloud is not a prerequisite.

```sh
git clone https://github.com/scflode/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup bootstrap
```

Bootstrap installs command-line tools plus Nextcloud, 1Password, and Ghostty. Continue in this order:

1. Sign into Nextcloud and setup `.ssh` sync.
2. Sign into 1Password, enable its SSH agent, then start a new shell (`exec zsh -l`).
3. Run `./link_ssh`. It links SSH configuration and public keys; private keys remain in 1Password. It refuses to replace an existing `~/.ssh` directory.
4. Run `./setup apps` for remaining casks.
5. Sign into App Store, then run `./setup store` for MAS apps. On Apple Silicon it installs Rosetta 2 for Vimari.

`setup` stages are safe to re-run. Brew packages may upgrade on rerun.

## Included

- Homebrew and `Brewfile` packages
- mise-managed tools
- LazyVim, tmux, Ghostty, zsh, Git, and Pi configuration

Review Brewfiles and `installer/macos` before first use; both contain personal choices.
