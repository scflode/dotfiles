local opt = vim.opt

opt.ruler = false
opt.hidden = true
opt.ignorecase = true
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true
opt.cul = true
opt.signcolumn = "yes"
opt.cmdheight = 1
--opt.clipboard = "unnamedplus"

-- Specials
opt.updatetime = 250 -- update interval for gitsigns

-- File handling
opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.config/nvim/undodir"
opt.undofile = true

-- Line numbers
opt.number = true
opt.numberwidth = 2
opt.relativenumber = true

-- Indentation
opt.expandtab = true
opt.shiftwidth = 2
opt.smartindent = true

-- Theme
opt.background = "dark"
--vim.cmd[[colorscheme tokyonight]]
--vim.g.tokyonight_style = "night"
--vim.g.tokyonight_colors = {
--  bg_sidebar = '#1f1b26',
--}

-- Status bar
opt.laststatus = 3
