vim.g.NERDTreeWinPos = "right"
vim.g.NERDTreeWinSize = 48
vim.g.NERDTreeMinimalUI = 1
vim.api.nvim_exec(
    [[ autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif ]],
    false
)
