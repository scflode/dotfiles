local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not status_ok then
  return
end

local servers = {
  "bashls",
  "cssls",
  "dockerls",
  "elixirls",
  "gopls",
  "html",
  "intelephense",
  "jsonls",
  "pyright",
  "sqlls",
  "sumneko_lua",
  "tailwindcss",
  "tsserver",
  "yamlls",
}

for _, name in pairs(servers) do
  local server_is_found, server = lsp_installer.get_server(name)
  if server_is_found and not server:is_installed() then
    print("Installing " .. name)
    server:install()
  end
end

-- Register a handler that will be called for all installed servers.
lsp_installer.on_server_ready(function(server)
  local opts = {
    on_attach = require("foshizzle.lsp.handlers").on_attach,
    capabilities = require("foshizzle.lsp.handlers").capabilities,
  }

  if server.name == "jsonls" then
    local jsonls_opts = require("foshizzle.lsp.settings.jsonls")
    opts = vim.tbl_deep_extend("force", jsonls_opts, opts)
  end

  if server.name == "sumneko_lua" then
    local sumneko_opts = require("foshizzle.lsp.settings.sumneko_lua")
    opts = vim.tbl_deep_extend("force", sumneko_opts, opts)
  end

  if server.name == "intelephense" then
    local intelephense_opts = require("foshizzle.lsp.settings.intelephense")
    opts = vim.tbl_deep_extend("force", intelephense_opts, opts)
  end

  if server.name == "tailwindcss" then
    local tailwindcss_opts = require("foshizzle.lsp.settings.tailwindcss")
    opts = vim.tbl_deep_extend("force", tailwindcss_opts, opts)
  end

  -- This setup() function is exactly the same as lspconfig's setup function.
  -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
  server:setup(opts)
end)
