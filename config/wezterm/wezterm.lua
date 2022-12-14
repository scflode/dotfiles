local status_ok, wezterm = pcall(require, "wezterm")

if not status_ok then
	print("wezterm not found!")
end

return {
	color_scheme = "tokyonight",
	font = wezterm.font({
		family = "VictorMono Nerd Font",
		weight = "Bold",
		harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
	}),
	font_size = 15.0,
	line_height = 1.4,
	enable_tab_bar = false,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
}
