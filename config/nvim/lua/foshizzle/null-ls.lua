local null_ls = require("null-ls")

null_ls.setup({
    debug = true,
    sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.eslint.with({
            prefer_local = "node_modules/.bin"
        }),
        null_ls.builtins.diagnostics.eslint.with({
            prefer_local = "node_modules/.bin"
        }),
        null_ls.builtins.completion.spell,
        null_ls.builtins.formatting.phpcsfixer.with({
            prefer_local = "vendor/bin/",
        }),
        null_ls.builtins.diagnostics.psalm.with({
            prefer_local = "vendor/bin/",
        }),
    },
})
