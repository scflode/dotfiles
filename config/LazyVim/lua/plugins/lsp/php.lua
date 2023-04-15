return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "intelephense",
      },
    },
    {
      "neovim/nvim-lspconfig",
      opts = {
        servers = {
          intelephense = {
            init_options = {
              licenceKey = vim.env.INTELEPHENSE_LICENCE_KEY,
            },
          },
        },
      },
    },
  },
}
