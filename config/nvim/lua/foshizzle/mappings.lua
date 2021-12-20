local map = vim.api.nvim_set_keymap

-- basic setup
local g = vim.g

g.mapleader = ","

map('n', '<Leader><CR>', ':set hlsearch!<CR>', { noremap = true, silent = true })

map('n', '<Leader>f', ':Telescope find_files<CR>', { noremap = true, silent = true })
map('n', '<Leader>b', ':Telescope buffers<CR>', { noremap = true, silent = true })
map('n', '<Leader>s', ':Telescope live_grep<CR>', { noremap = true, silent = true })
map('n', '<Leader>g', ':Telescope git_status<CR>', { noremap = true, silent = true })

map('n', '<Leader>l', ':NERDTreeFind<CR>', { noremap = true, silent = true })
map('n', '<Leader>n', ':NERDTreeToggle<CR>', { noremap = true, silent = true })

map('n', '<Leader>ct', ':ColorizerToggle<CR>', { noremap = true, silent = true })

map('n', '<Leader>dr', '<Cmd>lua ReloadConfig()<CR>', { silent = true, noremap = true })
