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
        "phpactor",
        "twigcs",
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {},
    },
  },
}
