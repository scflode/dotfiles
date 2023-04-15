-- https://github.com/jascha030/macos-nvim-dark-mode
return {
  {
    "f-person/auto-dark-mode.nvim",
    init = function()
      require("auto-dark-mode").init()
    end,
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.cmd([[colorscheme tokyonight-night]])
      end,
      set_light_mode = function()
        vim.cmd([[colorscheme tokyonight-day]])
      end,
    },
  },
  {
    "folke/tokyonight.nvim",
  },
}
