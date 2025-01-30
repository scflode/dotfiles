-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.mapleader = ","

vim.g.snacks_animate = false

vim.o.tabline = ""
vim.o.showtabline = 0

-- Some custom settings
local opt = vim.opt

opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold

opt.clipboard = ""

-- Require a config file or disable
vim.g.lazyvim_prettier_needs_config = true
