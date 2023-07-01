# Theme related settings

# status
set -g status "on"
set -g status-interval 2
set -g status-position bottom
set -g status-justify "left"
set -g status-style "fg=${thm_fg},bg=${thm_bg}"
set -g status-bg "${thm_bg}"

set -g status-left-length "250"
set -g status-right-length "250"

set -g status-left-style NONE
set -g status-right-style NONE

set -g status-left "#[fg=${thm_fg},bg=${thm_bg},bold] #S #[fg=${thm_fg},bg=${thm_bg},nobold,nounderscore,noitalics]"
set -g status-right "#[fg=${thm_black4},bg=${thm_gray},nobold,nounderscore,noitalics]#[fg=${thm_fg},bg=${thm_bg}] #{prefix_highlight} #(${HOME}/.dotfiles/scripts/ifstat.sh) | #(${HOME}/.dotfiles/scripts/load.sh) | #(${HOME}/.dotfiles/scripts/battery.sh) #[fg=${thm_gray},bg=${thm_black},nobold,nounderscore,noitalics]#[fg=${thm_fg},bg=${thm_gray}] %Y-%m-%d #[fg=${thm_black},bg=${thm_fg},bold] %I:%M %p #[fg=${thm_fg},bg=${thm_black},nobold,nounderscore,noitalics]"

set -g mode-style "fg=${thm_fg},bg=${thm_bg}"

# messages
set -g message-style "fg=${thm_fg},bg=${thm_bg},align=centre"
set -g message-command-style "fg=${thm_fg},bg=${thm_bg},align=centre"

# panes
set -g pane-border-style "fg=${thm_fg}"
set -g pane-active-border-style "fg=${thm_bg}"

# windows
setw -g window-status-activity-style "fg=${thm_fg},bg=${thm_bg},none"
setw -g window-status-separator ""
setw -g window-status-style "fg=${thm_fg},bg=${thm_bg},none"
setw -g window-status-format "#[fg=$thm_bg,bg=$thm_blue,nobold,nounderscore,noitalics] #I #[fg=$thm_fg,bg=$thm_bg,nobold,nounderscore,noitalics] #W "
setw -g window-status-current-format "#[fg=$thm_bg,bg=$thm_orange,nobold,nounderscore,noitalics] #I #[fg=$thm_fg,bg=$thm_gray,nobold,nounderscore,noitalics] #W "

