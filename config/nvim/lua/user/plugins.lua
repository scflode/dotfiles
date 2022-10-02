local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "rounded" })
    end,
  },
})

return packer.startup(function(use)
  use("wbthomason/packer.nvim")

  -- UI
  use("nvim-lualine/lualine.nvim")
  --  use({
  --    "mcchrish/zenbones.nvim",
  --    config = function()
  --      vim.cmd("colorscheme zenbones")
  --    end,
  --    -- Optionally install Lush. Allows for more configuration or extending the colorscheme
  --    -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
  --    -- In Vim, compat mode is turned on as Lush only works in Neovim.
  --    requires = "rktjmp/lush.nvim",
  --  })

  -- use("olimorris/onedarkpro.nvim")

  use("folke/tokyonight.nvim")

  use({
    "lewis6991/gitsigns.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
    },
  })
  use("norcalli/nvim-colorizer.lua")
  use("markstory/vim-zoomwin")

  -- TMUX integration
  use("christoomey/vim-tmux-navigator")

  -- file navigation
  use({
    "kyazdani42/nvim-tree.lua",
    requires = {
      "kyazdani42/nvim-web-devicons", -- optional, for file icons
    },
  })
  use("nvim-lua/plenary.nvim")
  use({
    "nvim-telescope/telescope.nvim",
    requires = {
      { "nvim-telescope/telescope-live-grep-args.nvim" },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        run = "make",
      },
    },
  })
  use({
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
  })
  use({ "kevinhwang91/nvim-bqf", filetype = { "qf" } })
  use("j-hui/fidget.nvim")

  -- LSP
  use({
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
  })
  use("ray-x/lsp_signature.nvim")
  use("tamago324/nlsp-settings.nvim") -- For JSON and YAML autocomplete
  use({
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  })
  use({
    "jayp0521/mason-null-ls.nvim",
    after = {
      "null-ls.nvim",
      "mason.nvim",
    },
    requires = { "WhoIsSethDaniel/mason-tool-installer.nvim" },
  })

  -- Treesitter
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
  })

  -- completion
  use("windwp/nvim-autopairs")
  use("rafamadriz/friendly-snippets")
  use("hrsh7th/cmp-nvim-lsp")
  use("hrsh7th/cmp-buffer")
  use("hrsh7th/cmp-path")
  use("hrsh7th/cmp-cmdline")
  use("hrsh7th/nvim-cmp")
  use("L3MON4D3/LuaSnip")
  use("saadparwaiz1/cmp_luasnip")
  use("onsails/lspkind-nvim")

  -- programming language support
  use("gpanders/editorconfig.nvim")
  use("tpope/vim-fugitive")
  use("tpope/vim-projectionist")

  -- Markdown
  use({ "preservim/vim-markdown", requires = { "godlygeek/tabular" } })

  -- behavior
  use("tpope/vim-sensible")
  use("famiu/bufdelete.nvim")
  use("tpope/vim-surround")
  use("tpope/vim-unimpaired")
  use("lukas-reineke/indent-blankline.nvim")
  use("gcmt/wildfire.vim")
end)
