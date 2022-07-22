local status_ok, onedark = pcall(require, "onedarkpro")

if not status_ok then
  return
end

onedark.setup({
  dark_theme = "onedark",
  light_theme = "onelight",
  styles = {
    comments = "italic",
    functions = "NONE",
    keywords = "bold,italic",
    strings = "NONE",
    variables = "NONE",
    virtual_text = "NONE",
  },
})

vim.cmd("colorscheme onedarkpro")
