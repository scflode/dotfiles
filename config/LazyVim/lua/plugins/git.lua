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
    "otavioschwanck/github-pr-reviewer.nvim",
    opts = {
      next_hunk_key = "<C-d>",
      prev_hunk_key = "<C-u>",
      next_file_key = "<C-n>",
      prev_file_key = "<C-p>",
    },
    keys = {
      { "<leader>p", "<cmd>PRReviewMenu<cr>", desc = "PR Review Menu" },
      { "<leader>p", ":<C-u>'<,'>PRSuggestChange<CR>", desc = "Suggest change", mode = "v" },
    },
  },
  -- {
  --   "ldelossa/gh.nvim",
  --   dependencies = {
  --     {
  --       "ldelossa/litee.nvim",
  --       config = function()
  --         require("litee.lib").setup()
  --       end,
  --     },
  --   },
  --   config = function()
  --     require("litee.gh").setup()
  --   end,
  -- },
}
