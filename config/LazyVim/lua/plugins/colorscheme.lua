local function overwrite_colorscheme(type)
  -- if type == "dark" then
  --   vim.api.nvim_set_hl(0, "Function", { fg = "#FFFAA0" })
  -- else
  --   vim.api.nvim_set_hl(0, "Function", { fg = "#FFFA8A" })
  -- end
end

return {
  {
    "zenbones-theme/zenbones.nvim",
    lazy = true,
    dependencies = {
      "rktjmp/lush.nvim",
    },
  },
  { "rose-pine/neovim", name = "rose-pine", priority = 1000 },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "folke/tokyonight.nvim", priority = 1000 },
  {
    "f-person/auto-dark-mode.nvim",
    init = function()
      local auto_dark_mode = require("auto-dark-mode")
      auto_dark_mode.setup({
        update_interval = 1000,
        set_dark_mode = function()
          vim.api.nvim_set_option_value("background", "dark", {})
          overwrite_colorscheme("dark")
        end,
        set_light_mode = function()
          vim.api.nvim_set_option_value("background", "light", {})
          -- vim.api.nvim_set_option_value("background", "dark", {})
          overwrite_colorscheme("light")
        end,
      })
      auto_dark_mode.init()
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "rose-pine",
      -- colorscheme = "zenbones",
      colorscheme = "catppuccin-mocha",
      -- colorscheme = "tokyobones",
    },
  },
}
