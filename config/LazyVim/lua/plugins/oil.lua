return {
  {
    "stevearc/oil.nvim",
    opts = {
      win_options = {
        signcolumn = "auto",
      },
      float = {
        max_width = 140,
        max_height = 40,
      },
      keymaps = {
        ["q"] = "actions.close",
      },
    },
    keys = {
      { "-", "<CMD>Oil --float<CR>", desc = "Open parent directory" },
    },
    -- dependencies = { "nvim-tree/nvim-web-devicons" },
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  },
  {
    "refractalize/oil-git-status.nvim",

    dependencies = {
      "stevearc/oil.nvim",
    },

    config = true,
  },
}
