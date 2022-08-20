require("user.plugins")
require("user.settings")
require("user.mappings")
require("user.lualine")
require("user.nvimtree")
require("user.telescope")
require("user.cmp")
require("user.lsp")
require("user.treesitter")
require("user.autopairs")
require("user.markdown")
require("user.trouble")
require("user.onedark")
require("user.tokyo_night")
require("user.bqf")

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
    if name:match("^user") then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)
end

vim.cmd("command! ReloadConfig lua ReloadConfig()")
