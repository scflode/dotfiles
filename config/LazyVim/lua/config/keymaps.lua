-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

map("n", "<leader>gg", function()
  require("neogit").open({ kind = "tab" })
end, { desc = "Neogit (cwd)" })

map("n", "<leader>H", function()
  local current_file = vim.fn.expand("%:t")
  vim.notify("Added file: " .. current_file, vim.log.levels.INFO, { title = "Harpoon" })
  require("harpoon"):list():add()
end, { desc = "Add file to harpoon" })

-- CodeCompanion
vim.keymap.set("n", "<leader>a", "<cmd>CodeCompanionChat Toggle<cr>", {
  desc = "Chat with AI",
  silent = true,
})
