return {
  "olimorris/codecompanion.nvim",
  opts = {},
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "hrsh7th/nvim-cmp", -- Optional: For using slash commands and variables in the chat buffer
    "nvim-telescope/telescope.nvim", -- Optional: For using slash commands
    { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } }, -- Optional: For prettier markdown rendering
    { "stevearc/dressing.nvim", opts = {} }, -- Optional: Improves `vim.ui.select`
  },
  config = function()
    local current_adapter = nil
    local current_model = nil

    -- Helper to update globals
    local function set_status(adapter, model)
      current_adapter = adapter
      current_model = model
    end

    -- Expose status for statusline
    _G.CodeCompanionStatus = function()
      if current_adapter and current_model then
        return string.format("CC[%s:%s]", current_adapter, current_model)
      else
        return "CC[none]"
      end
    end

    require("codecompanion").setup({
      strategies = {
        chat = {
          adapter = "copilot",
          model = "claude-sonnet-4",
          on_start = function()
            set_status("copilot", "claude-sonnet-4")
          end,
        },
        inline = {
          adapter = "copilot",
          model = "gpt-5-mini",
          on_start = function()
            set_status("copilot", "gpt-5-mini")
          end,
        },
      },
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = "",
            },
          })
        end,
      },
    })
  end,
}
