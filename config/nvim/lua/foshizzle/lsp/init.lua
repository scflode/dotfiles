local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

require "foshizzle.lsp.lsp-installer"
require("foshizzle.lsp.handlers").setup()
require "foshizzle.lsp.null-ls"
