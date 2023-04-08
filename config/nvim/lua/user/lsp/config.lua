local helper = require("helpers")

local mason = helper.require_plugin("mason")
local mason_lspconfig = helper.require_plugin("mason-lspconfig")
local lspconfig = helper.require_plugin("lspconfig")

local servers = {
  "bashls",
  "cssls",
  "dockerls",
  "elixirls",
  "gopls",
  "html",
  "intelephense",
  "jsonls",
  "lemminx",
  "pyright",
  "lua_ls",
  "tailwindcss",
  "tsserver",
  "yamlls",
}

mason.setup()
mason_lspconfig.setup({
  ensure_installed = servers,
  automatic_installation = false,
})

for _, server in pairs(servers) do
  local opts = {
    on_attach = require("user.lsp.handlers").on_attach,
    capabilities = require("user.lsp.handlers").capabilities,
  }
  local has_custom_opts, server_custom_opts = pcall(require, "user.lsp.settings." .. server)
  if has_custom_opts then
    opts = vim.tbl_deep_extend("force", server_custom_opts, opts)
  end
  lspconfig[server].setup(opts)
end
