return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      require("util").add_to_table(opts.ensure_installed, {
        "php",
        "twig",
      })
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      require("util").add_to_table(opts.ensure_installed, {
        "intelephense",
        "twigcs",
        "php-cs-fixer",
        "psalm",
      })
    end,
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
}
