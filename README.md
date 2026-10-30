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
3. Run `./setup apps` for remaining casks.
4. Sign into App Store, then run `./setup store` for MAS apps. On Apple Silicon it installs Rosetta 2 for Vimari.

`setup` stages are safe to re-run. Brew packages may upgrade on rerun.

## Included

- Homebrew and `Brewfile` packages
- mise-managed tools
- LazyVim, tmux, Ghostty, Rex, zsh, Git, and Pi configuration

Review Brewfiles and `installer/macos` before first use; both contain personal choices.

## Rex

Install Rex.app manually (no Homebrew cask), launch it once, then run `installer/rex`.
It applies the look & feel from `config/rex/defaults.sh` (restart Rex.app afterwards),
installs the `xterm-rex` terminfo entry and reloads `config/rex/init.lua`. Press
`Ctrl-a Shift-i` once to import the Catppuccin themes. After editing `init.lua`, run
`rex config reload` or press `Ctrl-a Shift-r`.

`installer/rex` also fetches the third-party
[tab-numbers](https://github.com/manishprivet/.dotfiles/tree/main/.config/rex/extensions/tab-numbers)
extension at a pinned commit (unlicensed upstream, so not vendored). It numbers tab
titles; restore them with
`rex do ~/.config/rex/extensions/tab-numbers/watcher.lua --all mode=remove` after
removing its `require` line.

## Pi

Bootstrap installs the latest Pi and the packages in `installer/pi`. Refresh packages and
merge Pi defaults without changing model/account settings:

```sh
mise exec node@lts -- bash installer/pi
```

- Native codemode and tool search are enabled alongside ordinary tools.
- MCP uses `pi-mcp-adapter`; native MCP stays disabled. Linear tools are deferred and
  require approval for every call, including calls from scripts. Headless calls fail
  closed without an approval broker. Existing MCP configs are preserved by setup;
  compare them with `pi/agent/mcp-adapter.json` when updating.
- RTK command rewriting stays enabled; incompatible result compaction is disabled.
- Quota status uses the local fork, not the duplicate npm package. Workmux is linked
  from this repo. The account-specific `~/.pi/agent/extensions/pi-codex-usage` remains
  separately managed; it is not replaced or installed by bootstrap.
- Authenticate subscription aliases through `/login`; credentials are never stored here.
