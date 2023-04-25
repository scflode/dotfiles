local elixir = require("elixir")
local elixirls = require("elixir.elixirls")
elixir.setup({
  elixirls = {
    tag = "v0.14.3",
    settings = elixirls.settings({
      dialyzerEnabled = true,
      fetchDeps = false,
      enableTestLenses = true,
      suggestSpecs = true,
    }),
  },
})
