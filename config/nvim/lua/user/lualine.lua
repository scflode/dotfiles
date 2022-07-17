require("lualine").setup({
    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", { "diagnostics", sources = { "nvim_lsp" } } },
        lualine_c = {},
        lualine_x = { "filename" },
        lualine_y = { "location", "progress" },
        lualine_z = { "encoding", "filetype", "fileformat" },
    },
})
