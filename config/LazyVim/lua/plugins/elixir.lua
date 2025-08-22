return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        elixirls = { enabled = true },
        lexical = { enabled = false },
      },
    },
  },
}
