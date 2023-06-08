local Util = require("util")

return {
  "akinsho/flutter-tools.nvim",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/dressing.nvim", -- optional for vim.ui.select
  },
  opts = {
    flutter_lookup_cmd = "asdf where flutter",
    widget_guides = {
      enabled = true,
    },
    on_attach = Util.on_attach(function(client, buffer)
      require("plugins.lsp.format").on_attach(client, buffer)
      require("plugins.lsp.keymaps").on_attach(client, buffer)
    end),
  },
}
