-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Disable angularls if in not an Angular project
-- local function detect_angularls()
--   local is_angular = require("lspconfig.util").root_pattern("angular.json")
--   LazyVim.lsp.disable("angularls", function(root_dir)
--     return not is_angular(root_dir)
--   end)
-- end

-- Auto command to start angularls on buffer enter
-- vim.api.nvim_create_augroup("Angular", { clear = true })
-- vim.api.nvim_create_autocmd("BufEnter", {
--   group = "Angular",
--   callback = detect_angularls,
-- })

vim.api.nvim_create_autocmd("DirChanged", {
  callback = function()
    if vim.fn.filereadable(".lazy.lua") then
      dofile(".lazy.lua")
      vim.cmd("LspRestart")
    end
  end,
})
