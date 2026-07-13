# Theme related settings

# status
set -g status "on"
set -g status-interval 2
set -g status-position bottom
set -g status-justify "left"
set -g @dotfiles-status-format "#[align=left range=left #{E:status-left-style}]#[push-default]#{T;=/#{status-left-length}:status-left}#[pop-default]#[norange default]#[list=on align=#{status-justify}]#[list=left-marker]<#[list=right-marker]>#[list=on]#{W:#[range=window|#{window_index} #{E:window-status-style}#{?#{&&:#{window_last_flag},#{!=:#{E:window-status-last-style},default}}, #{E:window-status-last-style},}#{?#{&&:#{window_bell_flag},#{!=:#{E:window-status-bell-style},default}}, #{E:window-status-bell-style},#{?#{&&:#{||:#{window_activity_flag},#{window_silence_flag}},#{!=:#{E:window-status-activity-style},default}}, #{E:window-status-activity-style},}}]#[push-default]#{T:window-status-format}#[pop-default]#[norange default]#{?loop_last_flag,,#{E:window-status-separator}},#[range=window|#{window_index} list=focus #{?#{!=:#{E:window-status-current-style},default},#{E:window-status-current-style},#{E:window-status-style}}#{?#{&&:#{window_last_flag},#{!=:#{E:window-status-last-style},default}}, #{E:window-status-last-style},}#{?#{&&:#{window_bell_flag},#{!=:#{E:window-status-bell-style},default}}, #{E:window-status-bell-style},#{?#{&&:#{||:#{window_activity_flag},#{window_silence_flag}},#{!=:#{E:window-status-activity-style},default}}, #{E:window-status-activity-style},}}]#[push-default]#{T:window-status-current-format}#[pop-default]#[norange list=on default]#{?loop_last_flag,,#{E:window-status-separator}}}#[nolist align=right range=right #{E:status-right-style}]#[push-default]#{T;=/#{status-right-length}:status-right}#[pop-default]#[norange default]"
set -g status-format[0] "#{E:@dotfiles-status-format}"
set -g status-format[1] "#{E:@dotfiles-status-format}"
set -g status-style "fg=${thm_fg},bg=${thm_bg}"
set -g status-bg "${thm_bg}"

set -g status-left-length "250"
set -g status-right-length "250"

set -g status-left-style NONE
set -g status-right-style NONE

set -g status-left "#[fg=${thm_fg},bg=${thm_bg},bold] #S #[fg=${thm_fg},bg=${thm_bg},nobold,nounderscore,noitalics]"
set -g status-right "#(${HOME}/.tmux/plugins/tmux-continuum/scripts/continuum_save.sh)#[fg=${thm_black4},bg=${thm_gray},nobold,nounderscore,noitalics]#[fg=${thm_fg},bg=${thm_bg}] #(${HOME}/.dotfiles/scripts/ifstat.sh) | #(${HOME}/.dotfiles/scripts/load.sh) | #(${HOME}/.dotfiles/scripts/battery.sh) | #(${HOME}/.tmux/plugins/tmux-continuum/scripts/continuum_status.sh) #[fg=${thm_gray},bg=${thm_black},nobold,nounderscore,noitalics]#[fg=${thm_fg},bg=${thm_gray}] %Y-%m-%d #[fg=${thm_black},bg=${thm_fg},bold] %I:%M %p #[fg=${thm_fg},bg=${thm_black},nobold,nounderscore,noitalics]"

set -g mode-style 'reverse'

# messages
set -g message-style "fg=${thm_fg},bg=${thm_bg},align=left,width=100%"
set -g message-command-style "fg=${thm_fg},bg=${thm_bg},align=left,width=100%"

# panes
set -g pane-border-style "fg=${thm_fg}"
set -g pane-active-border-style "fg=${thm_yellow}"

# windows
setw -g window-status-activity-style "fg=${thm_fg},bg=${thm_bg},none"
setw -g window-status-separator ""
setw -g window-status-style "fg=${thm_fg},bg=${thm_bg},none"
setw -g window-status-format "#[fg=$thm_fg,bg=$thm_bg,nobold,nounderscore,noitalics] #I #[fg=$thm_fg,bg=$thm_bg,nobold,nounderscore,noitalics] #W "
setw -g window-status-current-format "#[fg=$thm_bg,bg=$thm_orange,nobold,nounderscore,noitalics] #I #[fg=$thm_fg,bg=$thm_gray,nobold,nounderscore,noitalics] #W "

