# dotfiles

This repository provides my dotfiles and system setup.

> Note: Some things are still a bit weird. Check the issue tracker for known issues.

## Installation

In order to install do:

```
git clone https://github.com/scflode/dotfiles.git ~/.dotfiles

cd ~/.dotfiles

# Adapt stuff as needed (and create a fresh Git repo maybe)

./setup
```

> Be sure you checked and adapted the scripts for your needs.

## Architecture

Quickly iterated the architecture consists of:

- system setup scripts
- the dotfiles
- update functionality for all dependencies
- setups are bundled by tools or language to switch and swap easily

The basic architecture is pretty OS agnostic. Currently the macOS is
the main system that is supported but a Linux version will come as well.

Some features are:

- idempotency for running scripts multiple times without destroying something
- modularity to allow easy removal of chunks not wanted

## What is used?

### macOS

In order to leverage the latest and greatest versions of CLI tools there
are the following two players involved:

- (Homebrew)[https://brew.sh]
- (asdf)[https://asdf-vm.com]

Homebrew is used to install

- lower level system tools (overriding outdated versions of macOS)
- applications via `cask`

asdf is used to install:

- programming languages
- tools that need versioning

### Common

The setup contains configuration for

- neovim
- tmux
- zsh

## Sources

Of course the files themselves depend on a lot of work of different people.

Some mentions go to:

- https://github.com/mathiasbynens/dotfiles for the macOS part

And of course all the others I learned from but can't name anymore.

Also a big shoutout to the maintainers, developer and inventors of all the
stuff I use.

## License

MIT
