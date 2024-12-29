return {
  {
    "neovim/nvim-lspconfig",
    commit = "124be12d782d656b3c75b513a44d9e4728406078", -- Until https://github.com/neovim/nvim-lspconfig/issues/3503 is resolved
    opts = {
      inlay_hints = { enabled = true },
      capabilities = {
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = false,
          },
        },
      },
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = false, -- Disable virtual text
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = LazyVim.config.icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = LazyVim.config.icons.diagnostics.Warn,
            [vim.diagnostic.severity.INFO] = LazyVim.config.icons.diagnostics.Info,
            [vim.diagnostic.severity.HINT] = LazyVim.config.icons.diagnostics.Hint,
          },
        },
      },
    },
  },
}
