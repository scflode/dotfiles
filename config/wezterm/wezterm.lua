local status_ok, wezterm = pcall(require, "wezterm")

if not status_ok then
  print("wezterm not found!")
end

-- local colors = require("lua/rose-pine").colors()

local function scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "Catppuccin Mocha"
    -- return "zenbones_dark"
    -- return "Tokyo Night Storm"
  else
    return "Catppuccin Mocha"
    -- return "zenbones"
    -- return "zenbones_dark"
    -- return "Catppuccin Latte"
    -- return "Tokyo Night Day"
    -- return "Tokyo Night Storm"
  end
end

-- local function colors_for_appearance(appearance)
--   if appearance:find("Dark") then
--     return require("lua/rose-pine").colors()
--   else
--     return require("lua/rose-pine-dawn").colors()
--   end
-- end

return {
  -- window_decorations = "NONE",
  -- window_decorations = "TITLE|INTEGRATED_BUTTONS|RESIZE",
  -- window_decorations = "INTEGRATED_BUTTONS|RESIZE",
  window_decorations = "RESIZE",
  color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
  -- colors = colors,
  -- colors = colors_for_appearance(wezterm.gui.get_appearance()),
  font = wezterm.font({
    family = "VictorMono NFM",
    weight = "Bold",
    harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
  }),
  font_size = 15.0,
  line_height = 1.3,
  enable_tab_bar = false,
  window_padding = {
    left = 2,
    right = 2,
    top = 0,
    bottom = 0,
  },
}
