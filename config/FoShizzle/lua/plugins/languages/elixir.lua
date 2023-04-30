return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      require("util").add_to_table(opts.ensure_installed, {
        "elixir",
        "erlang",
        "eex",
        "heex",
      })
    end,
  },
  {
    "elixir-tools/elixir-tools.nvim",
    ft = { "elixir", "eex", "heex", "surface" },
    config = function()
      local elixir = require("elixir")
      local elixirls = require("elixir.elixirls")

      elixir.setup({
        credo = {},
        elixirls = {
          enabled = true,
          settings = elixirls.settings({
            dialyzerEnabled = true,
            enableTestLenses = true,
          }),
        },
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
}
