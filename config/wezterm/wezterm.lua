local status_ok, wezterm = pcall(require, "wezterm")

if not status_ok then
  print("wezterm not found!")
end

local function scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "zenbones_dark"
  else
    return "zenbones"
  end
end

return {
  -- window_decorations = "NONE",
  -- window_decorations = "INTEGRATED_BUTTONS|RESIZE",
  color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
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
