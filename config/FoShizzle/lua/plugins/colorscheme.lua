return {
  {
    "mcchrish/zenbones.nvim",
    lazy = true,
    dependencies = {
      "rktjmp/lush.nvim",
    },
  },
  {
    "f-person/auto-dark-mode.nvim",
    init = function()
      local adm = require("auto-dark-mode")
      adm.setup({
        update_interval = 1000,
        set_dark_mode = function()
          vim.api.nvim_set_option("background", "dark")
        end,
        set_light_mode = function()
          vim.api.nvim_set_option("background", "light")
        end,
      })
      adm.init()
    end,
  },
}
