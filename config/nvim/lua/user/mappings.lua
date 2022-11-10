local map = vim.api.nvim_set_keymap

-- basic setup
local g = vim.g

g.mapleader = ","

map("n", "<Leader><CR>", ":set hlsearch!<CR>", { noremap = true, silent = true })

map("n", "<Leader>f", ":Telescope find_files hidden=true<CR>", { noremap = true, silent = true })
map("n", "<Leader>b", ":Telescope buffers<CR>", { noremap = true, silent = true })
map("n", "<Leader>s", ":Telescope live_grep_args<CR>", { noremap = true, silent = true })
map("n", "<Leader>g", ":Telescope git_status<CR>", { noremap = true, silent = true })
map("n", "<Leader>d", ":Telescope lsp_document_symbols<CR>", { noremap = true, silent = true })
map("n", "<Leader>t", ":Telescope treesitter<CR>", { noremap = true, silent = true })

map("n", "<Leader>l", ":NvimTreeFindFile<CR>", { noremap = true, silent = true })
map("n", "<Leader>n", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

map("n", "<Leader>ct", ":ColorizerToggle<CR>", { noremap = true, silent = true })

map("n", "<Leader>dr", "<Cmd>lua ReloadConfig()<CR>", { silent = true, noremap = true })

map("", "<Leader>+", "<Plug>(wildfire-fuel)", { silent = true, noremap = true })
map("v", "<Leader>-", "<Plug>(wildfire-water)", { silent = true, noremap = true })
