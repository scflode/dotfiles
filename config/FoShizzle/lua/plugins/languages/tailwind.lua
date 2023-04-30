return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      require("util").add_to_table(opts.ensure_installed, {
        "javascript",
        "typescript",
        "json",
        "html",
        "css",
      })
    end,
  },
}
