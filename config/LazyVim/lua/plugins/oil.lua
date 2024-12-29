return {
  {
    "stevearc/oil.nvim",
    opts = {
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
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
  },
}
