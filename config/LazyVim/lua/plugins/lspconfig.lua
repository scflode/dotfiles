return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },
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
