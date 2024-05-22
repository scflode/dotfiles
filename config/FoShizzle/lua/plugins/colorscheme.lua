local function overwrite_colorscheme()
  vim.api.nvim_set_hl(0, "Function", { fg = "#FFFAA0" })
end

return {
  {
    "mcchrish/zenbones.nvim",
    lazy = true,
    dependencies = {
      "rktjmp/lush.nvim",
    },
  },
  -- { "rose-pine/neovim", name = "rose-pine", priority = 1000 },
  -- { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  -- { "folke/tokyonight.nvim", priority = 1000 },
  {
    "f-person/auto-dark-mode.nvim",
    init = function()
      local adm = require("auto-dark-mode")
      adm.setup({
        update_interval = 1000,
        set_dark_mode = function()
          vim.api.nvim_set_option("background", "dark")
          overwrite_colorscheme()
        end,
        set_light_mode = function()
          -- vim.api.nvim_set_option("background", "light")
          vim.api.nvim_set_option("background", "dark")
          overwrite_colorscheme()
        end,
      })
      adm.init()
    end,
  },
}
