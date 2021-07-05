# Default Theme

if patched_font_in_use; then
	#TMUX_POWERLINE_SEPARATOR_LEFT_BOLD=""
	#TMUX_POWERLINE_SEPARATOR_LEFT_THIN=""
	#TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD=""
	#TMUX_POWERLINE_SEPARATOR_RIGHT_THIN=""
	TMUX_POWERLINE_SEPARATOR_LEFT_BOLD="|"
	TMUX_POWERLINE_SEPARATOR_LEFT_THIN="|"
	TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD="|"
	TMUX_POWERLINE_SEPARATOR_RIGHT_THIN="|"
else
	TMUX_POWERLINE_SEPARATOR_LEFT_BOLD="|"
	TMUX_POWERLINE_SEPARATOR_LEFT_THIN="|"
	TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD="|"
	TMUX_POWERLINE_SEPARATOR_RIGHT_THIN="|"
fi

TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR=#1d1f22 #${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR:-'235'}
TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR=#b9b9b9 #${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR:-'255'}

TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_RIGHT_THIN}
TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_LEFT_THIN}


# Format: segment_name background_color foreground_color [non_default_separator]

if [ -z $TMUX_POWERLINE_LEFT_STATUS_SEGMENTS ]; then
	TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
                "hostname ${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR} ${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR}" \
		"tmux_session_info ${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR} ${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR}" \
		#"ifstat 30 255" \
		#"ifstat_sys 30 255" \
		"vcs_branch ${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR} ${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR}" \
                "vcs_compare ${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR} ${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR}" \
		"vcs_staged ${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR} ${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR}" \
		"vcs_modified ${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR} ${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR}" \
		"vcs_others ${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR} ${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR}" \
	)
fi

if [ -z $TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS ]; then
	TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
		#"earthquake 3 0" \
#		"pwd 89 211" \
		#"macos_notification_count 29 255" \
#		"mailcount 9 255" \
#		"now_playing 234 37" \
#		"lan_ip 232 255" \
#		"wan_ip 232 255" \
		#"cpu 240 136" \
		#"ifstat ${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR} $((${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR} - 11))" \
		"ifstat_sys ${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR} ${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR}" \
    "load ${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR} ${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR}" \
		#"tmux_mem_cpu_load 234 136" \
		"battery ${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR} ${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR}" \
#		"weather 37 255" \
		#"rainbarf 0 ${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR}" \
		#"xkb_layout 125 117" \
#		"date_day 235 136" \
		"date ${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR} ${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR}" \
		"time ${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR} ${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR}" \
		#"utc_time 235 136" \
	)
fi
