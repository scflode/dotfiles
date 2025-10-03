return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "php" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        intelephense = {
          enabled = true,
          init_options = {
            licenceKey = vim.env.INTELEPHENSE_LICENCE_KEY,
          },
        },
        phpactor = { enabled = false },
      },
      -- setup = {
      --   phpactor = function()
      --     LazyVim.lsp.on_attach(function(client)
      --       client.server_capabilities.renameProvider = false
      --       client.server_capabilities.definitionProvider = false
      --       client.server_capabilities.referencesProvider = false
      --       client.server_capabilities.inlineCompletionProvider = false
      --       client.server_capabilities.documentSymbolProvider = false
      --       client.server_capabilities.workspaceSymbolProvider = false
      --       client.server_capabilities.diagnosticProvider = nil
      --       client.server_capabilities.hoverProvider = false
      --       client.server_capabilities.inlayHintProvider = false
      --     end, "phpactor")
      --   end,
      --   intelephense = function()
      --     LazyVim.lsp.on_attach(function(client) end, "intelephense")
      --   end,
      -- },
    },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      local path = require("mason-registry").get_package("php-debug-adapter"):get_install_path()
      dap.adapters.php = {
        type = "executable",
        command = "node",
        args = { path .. "/extension/out/phpDebug.js" },
      }
      dap.configurations.php = {
        {
          type = "php",
          request = "launch",
          name = "Listen for Xdebug",
          port = 9003,
        },
      }
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "php-cs-fixer",
      },
    },
  },
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = opts.sources or {}
      table.insert(opts.sources, nls.builtins.formatting.phpcsfixer)
      table.insert(opts.sources, nls.builtins.diagnostics.phpcs)
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        php = { "php_cs_fixer", timeout_ms = 30000 },
      },
    },
  },
}
