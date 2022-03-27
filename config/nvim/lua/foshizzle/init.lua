require("foshizzle.plugins")
require("foshizzle.settings")
require("foshizzle.mappings")
require("foshizzle.lualine")
require("foshizzle.nerdtree")
require("foshizzle.telescope")
require("foshizzle.lsp")
require("foshizzle.cmp")
require("foshizzle.treesitter")
require("foshizzle.null-ls")
require("foshizzle.autopairs")

-- Common initializing
require("colorizer").setup()
require("gitsigns").setup()

P = function(v)
    print(vim.inspect(v))
    return v
end

-- Reload nvim
function _G.ReloadConfig()
    for name, _ in pairs(package.loaded) do
        if name:match("^foshizzle") then
            package.loaded[name] = nil
        end
    end

    dofile(vim.env.MYVIMRC)
end

vim.cmd("command! ReloadConfig lua ReloadConfig()")
