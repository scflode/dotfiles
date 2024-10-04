return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>fr", "<cmd>Telescope oldfiles cwd_only=true<cr>", desc = "Recent" },
      { "<leader>fR", LazyVim.pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
    },
    opts = {
      defaults = {
        path_display = { "truncate" },
      },
      pickers = {
        oldfiles = {
          cwd_only = true,
        },
      },
    },
  },
}
