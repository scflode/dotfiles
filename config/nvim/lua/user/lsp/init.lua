local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

--require("renamer").setup({
--  min_width = 25,
--  -- The maximum width of the popup
--  max_width = 45,
--  empty = true,
--})

require("user.lsp.config")
require("user.lsp.handlers").setup()
require("user.lsp.null-ls")
require("fidget").setup()
--require("user.lsp.notify")
