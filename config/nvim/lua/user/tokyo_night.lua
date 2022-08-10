local status_ok, _tokyo_night = pcall(require, "tokyonight")

if not status_ok then
  return
end

vim.g.tokyonight_style = "night"
vim.g.tokyonight_italic_functions = true
vim.g.tokyonight_sidebars = { "qf", "vista_kind", "terminal", "packer" }

vim.cmd("colorscheme tokyonight")
