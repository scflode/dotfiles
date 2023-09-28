# NOTE: you can use vars with $<var> and ${<var>} as long as the str is double quoted: ""
# WARNING: hex colors can't contain capital letters

# --> zenbones light
thm_bg="#f0edec"
thm_fg="#2c363c"
thm_cyan="#66a5ad"
thm_black="#888f94"
thm_gray="#b4bdc3"
thm_magenta="#b279a7"
thm_pink="#e8838f"
thm_red="#de6e7c"
thm_green="#819b69"
thm_yellow="#d68c67"
thm_blue="#61abda"
thm_orange="#b77e64"
thm_black4="#1c1917"

source-file $HOME/.config/tmux/theme.tmux

# Overrides
setw -g window-status-format "#[fg=$thm_fg,bg=$thm_bg,nobold,nounderscore,noitalics] #I #[fg=$thm_fg,bg=$thm_bg,nobold,nounderscore,noitalics] #W "
