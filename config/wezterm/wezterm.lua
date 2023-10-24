local status_ok, wezterm = pcall(require, "wezterm")

if not status_ok then
  print("wezterm not found!")
end

--local colors = require("lua/rose-pine").colors()

local function scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "zenbones_dark"
    --return "Catppuccin Mocha"
  else
    return "zenbones"
    --return "Catppuccin Latte"
  end
end

local function colors_for_appearance(appearance)
  if appearance:find("Dark") then
    return require("lua/rose-pine").colors()
  else
    return require("lua/rose-pine-dawn").colors()
  end
end

return {
  -- window_decorations = "NONE",
  -- window_decorations = "INTEGRATED_BUTTONS|RESIZE",
  window_decorations = "RESIZE",
  color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
  -- colors = colors_for_appearance(wezterm.gui.get_appearance()),
  font = wezterm.font({
    family = "VictorMono Nerd Font",
    weight = "Bold",
    harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
  }),
  font_size = 16.0,
  line_height = 1.7,
  enable_tab_bar = false,
  window_padding = {
    left = 4,
    right = 4,
    top = 0,
    bottom = 0,
  },
}
