return {
  {
    "folke/sidekick.nvim",
    opts = {
      nes = { enabled = false }, -- Disable Next Edit Suggestions
      cli = {
        tools = {
          pi = { cmd = { "mise", "exec", "node@lts", "--", "pi" } },
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      if opts.servers then
        opts.servers.copilot = nil
      end
    end,
  },
}
