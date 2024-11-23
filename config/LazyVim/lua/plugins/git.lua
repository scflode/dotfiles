return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = true,
    opts = {
      process_spinner = false,
    },
  },
  {
    "pwntester/octo.nvim",
    opts = {
      use_local_fs = true,
    },
  },
}
