return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "folke/noice.nvim",
    "hrsh7th/nvim-cmp", -- Optional: For using slash commands and variables in the chat buffer
    "nvim-telescope/telescope.nvim", -- Optional: For using slash commands
    { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } }, -- Optional: For prettier markdown rendering
    { "stevearc/dressing.nvim", opts = {} }, -- Optional: Improves `vim.ui.select`
  },
  init = function()
    require("plugins.ai.extensions.companion-notifications").init()
  end,
  config = function()
    require("codecompanion").setup({
      strategies = {
        chat = {
          adapter = { name = "copilot", model = "claude-sonnet-4" },
        },
        inline = {
          adapter = { name = "copilot", model = "gpt-5-mini" },
        },
      },
    })
  end,
}
