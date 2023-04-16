#!/usr/bin/env bash

set -g mode-style "fg=#88507D,bg=#F0EDEC"

set -g message-style "fg=#88507D,bg=#F0EDEC"
set -g message-command-style "fg=#88507D,bg=#F0EDEC"

set -g pane-border-style "fg=#F0EDEC"
set -g pane-active-border-style "fg=#88507D"

set -g status "on"
set -g status-justify "left"

set -g status-style "fg=#88507D,bg=#2C363C"

set -g status-left-length "250"
set -g status-right-length "250"

set -g status-left-style NONE
set -g status-right-style NONE

set -g status-left "#[fg=#15161E,bg=#88507D,bold] #S #[fg=#88507D,bg=#2C363C,nobold,nounderscore,noitalics]"
set -g status-right "#[fg=#2C363C,bg=#2C363C,nobold,nounderscore,noitalics]#[fg=#88507D,bg=#2C363C] #{prefix_highlight} #(${HOME}/.dotfiles/scripts/ifstat.sh) | #(${HOME}/.dotfiles/scripts/load.sh) | #(${HOME}/.dotfiles/scripts/battery.sh) #[fg=#F0EDEC,bg=#2C363C,nobold,nounderscore,noitalics]#[fg=#88507D,bg=#F0EDEC] %Y-%m-%d #[fg=#15161E,bg=#88507D,bold] %I:%M %p #[fg=#88507D,bg=#F0EDEC,nobold,nounderscore,noitalics]"

setw -g window-status-activity-style "underscore,fg=#F0EDEC,bg=#2C363C"
setw -g window-status-separator ""
setw -g window-status-style "NONE,fg=#F0EDEC,bg=#2C363C"
setw -g window-status-format "#[fg=#2C363C,bg=#2C363C,nobold,nounderscore,noitalics]#[default] #I  #W #F #[fg=#2C363C,bg=#2C363C,nobold,nounderscore,noitalics]"
setw -g window-status-current-format "#[fg=#2C363C,bg=#F0EDEC,nobold,nounderscore,noitalics]#[fg=#88507D,bg=#F0EDEC,bold] #I #W #F #[fg=#F0EDEC,bg=#2C363C,nobold,nounderscore,noitalics]"
  
# REPLACE
#set -g status-left ' #[fg=#88507D,bold]#{s/root//:client_key_table} '
#set -g status-right '#[fg=#88507D,bold] [#S]#[fg=#88507D,bold] [%d/%m] #[fg=#88507D,bold][%I:%M%p] '
#set -g status-style fg='#88507D',bg='#2C363C'
#
#set -g window-status-current-style fg='#88507D',bg='#2C363C',bold
#
#set -g pane-border-style fg='#88507D'
#set -g pane-active-border-style fg='#88507D'
#
#set -g message-style fg='#F0EDEC',bg='#CBD9E3'
#
#set -g display-panes-active-colour '#88507D'
#set -g display-panes-colour '#88507D'
#
#set -g clock-mode-colour '#88507D'
#
#set -g mode-style fg='#F0EDEC',bg='#CBD9E3'
