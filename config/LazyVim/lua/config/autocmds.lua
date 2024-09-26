-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Start angularls if in an Angular project
local function detect_angularls()
  local is_angular = require("lspconfig.util").root_pattern("angular.json")
  LazyVim.lsp.disable("angularls", function(root_dir)
    local angular_detected = is_angular(root_dir)
    if angular_detected then
      vim.notify("Detected an Angular project", vim.log.levels.INFO, { title = "lspconfig" })
    end

    return not angular_detected
  end)
end

-- Auto command to start angularls on buffer enter
vim.api.nvim_create_augroup("Angular", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
  group = "Angular",
  callback = detect_angularls,
})
