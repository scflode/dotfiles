#!/usr/bin/env bash
# Rex keeps look & feel in macOS preferences, which can't be symlinked; apply them instead.
# Mirrors config/ghostty/config. Restart Rex.app afterwards so it rereads them.

set -euo pipefail

d() { defaults write com.superlogical.rex "Workspace.$1" "${@:2}"; }

d terminalFontName -string "VictorMono Nerd Font Mono"
d terminalFontPointSize -float 15
d terminalFontStyle -string Medium
# Thickens strokes like Ghostty's font-thicken; thin VictorMono looks broken on 1x displays.
d terminalFontSmoothing -bool true
d terminalAllowsLigatures -bool true
d terminalCellHeightPercent -int 40
d terminalOptionKeyBehavior -string rightActsAsAlt
d paneDensity -string compact
# Default "extend" stretches the last row (nvim statusline with cmdheight=0) into the bottom padding.
d terminalPaddingColor -string background
