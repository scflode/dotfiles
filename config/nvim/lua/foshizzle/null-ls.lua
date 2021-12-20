local null_ls = require("null-ls")
null_ls.config({
	sources = {
		null_ls.builtins.formatting.stylua.with({

    }),
		null_ls.builtins.formatting.eslint,
	},
})
require("lspconfig")["null-ls"].setup({})
