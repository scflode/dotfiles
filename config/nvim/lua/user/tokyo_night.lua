local status_ok, tokyo_night = pcall(require, "tokyonight")

if not status_ok then
  return
end

tokyo_night.setup({
  style = "night",
  transparent = false,
  terminal_colors = true,
  hide_inactive_statusline = false,
  dim_inactive = false,
  lualine_bold = false,
  on_colors = function(colors)
    colors.bg_statusline = colors.bg
  end,
})

vim.cmd("colorscheme tokyonight")
