local M = {}

function M.copy_relative_path()
  local full_path = vim.fn.expand("%:p") -- full path of the current file
  local project_root = vim.fn.getcwd() -- project root (cwd)
  local relative_path = full_path:gsub(project_root .. "/", "")
  vim.fn.setreg("+", relative_path) -- copy to system clipboard
  print("Copied relative path: " .. relative_path)
end

vim.api.nvim_create_user_command("CopyRelPath", M.copy_relative_path, {})

return M
