local status_ok, onedark = pcall(require, "onedarkpro")

if not status_ok then
  return
end

onedark.setup({
  dark_theme = "onedark",
  light_theme = "onelight",
})

vim.cmd("colorscheme onedarkpro")
