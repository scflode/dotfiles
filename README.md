# dotfiles

Personal macOS setup and dotfiles.

## Install

```sh
git clone https://github.com/scflode/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup
```

`setup` is safe to re-run: it installs missing tools, keeps existing links, and reapplies preferences.

### SSH

`setup` does not install secrets. After Nextcloud syncs `~/Nextcloud/Private/ssh`, run:

```sh
./link_ssh
```

This links SSH configuration and public keys; private keys remain in 1Password.

## Included

- Homebrew and `Brewfile` packages
- mise-managed tools
- LazyVim, tmux, Ghostty, zsh, Git, and Pi configuration

Review `Brewfile` and `installer/macos` before first use; both contain personal choices.
