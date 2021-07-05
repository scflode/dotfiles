local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

return require("packer").startup(function(use)
  use "wbthomason/packer.nvim"

  -- UI
  use "nvim-lualine/lualine.nvim"
  use {
    "folke/tokyonight.nvim",
    branch = "main",
    config = function()
       vim.cmd 'colorscheme tokyonight'
    end
  }
  use {
    'lewis6991/gitsigns.nvim',
    requires = {
      'nvim-lua/plenary.nvim'
    },
  }
  use "norcalli/nvim-colorizer.lua"

  -- TMUX integration
  use "christoomey/vim-tmux-navigator"

  -- file navigation
  use "preservim/nerdtree"
  use "Xuyuanp/nerdtree-git-plugin"
  use "nvim-lua/plenary.nvim"
  use "nvim-telescope/telescope.nvim"
  use {
    "nvim-telescope/telescope-fzf-native.nvim",
    run = 'make'
  }
  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  }

  -- LSP
  use "williamboman/nvim-lsp-installer"
  use "neovim/nvim-lspconfig"
  use "jose-elias-alvarez/null-ls.nvim"

  -- Treesitter
  use {
     "nvim-treesitter/nvim-treesitter",
     run = ":TSUpdate"
  }

  -- completion
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-buffer"
  use "hrsh7th/cmp-path"
  use "hrsh7th/cmp-cmdline"
  use "hrsh7th/nvim-cmp"
  use "L3MON4D3/LuaSnip"
  use "saadparwaiz1/cmp_luasnip"
  use "onsails/lspkind-nvim"

  -- programming language support
  use "gpanders/editorconfig.nvim"

end)

