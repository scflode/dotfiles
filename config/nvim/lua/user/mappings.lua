local map = vim.keymap.set

-- basic setup
local g = vim.g

g.mapleader = ","

map("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
map("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

map("n", "<Leader><CR>", ":set hlsearch!<CR>", { noremap = true, silent = true })

map("n", "<Leader>f", ":Telescope find_files hidden=true<CR>", { noremap = true, silent = true })
map(
  "n",
  "<Leader>b",
  ":lua require('telescope.builtin').buffers({ sort_mru = true })<CR>",
  { noremap = true, silent = true }
)
map("n", "<Leader>s", ":Telescope live_grep_args<CR>", { noremap = true, silent = true })
map("n", "<Leader>g", ":Telescope git_status<CR>", { noremap = true, silent = true })
map("n", "<Leader>d", ":Telescope lsp_document_symbols<CR>", { noremap = true, silent = true })
map("n", "<Leader>t", ":Telescope treesitter<CR>", { noremap = true, silent = true })
map("n", "<Leader>n", ":Telescope file_browser<CR>", { noremap = true })
map("n", "<Leader>l", ":Telescope file_browser path=%:p:h<CR>", { noremap = true })

--map("n", "<Leader>l", ":NvimTreeFindFile<CR>", { noremap = true, silent = true })
--map("n", "<Leader>n", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

map("n", "<Leader>ct", ":ColorizerToggle<CR>", { noremap = true, silent = true })

map("n", "<Leader>rc", "<Cmd>lua ReloadConfig()<CR>", { silent = true, noremap = true })

map("", "<Leader>+", "<Plug>(wildfire-fuel)", { silent = true, noremap = true })
map("v", "<Leader>-", "<Plug>(wildfire-water)", { silent = true, noremap = true })

map("n", "<leader>nl", ":NoiceLast<CR>", { silent = true, noremap = true })

map("n", "<leader>nh", ":NoiceHistory<CR>", { silent = true, noremap = true })
map("n", "<c-f>", function()
  if not require("noice.lsp").scroll(4) then
    return "<c-f>"
  end
end, { silent = true, expr = true })

map("n", "<c-b>", function()
  if not require("noice.lsp").scroll(-4) then
    return "<c-b>"
  end
end, { silent = true, expr = true })
