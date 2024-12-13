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
    },
  },
}
