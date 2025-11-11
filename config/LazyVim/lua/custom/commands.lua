local M = {}

function M.copy_relative_path()
  local full_path = vim.fn.expand("%:p") -- full path of the current file
  local project_root = vim.fn.getcwd() -- project root (cwd)
  local relative_path = full_path:gsub(project_root .. "/", "")
  vim.fn.setreg("+", relative_path) -- copy to system clipboard
  print("Copied relative path: " .. relative_path)
end

vim.api.nvim_create_user_command("CopyRelPath", M.copy_relative_path, {})

function M.open_lsp_log_float()
  local buf = vim.api.nvim_create_buf(false, true) -- create new scratch buffer
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  local log_path = vim.lsp.get_log_path() -- get the LSP log file path

  -- clear buffer and read current log contents
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "-- LSP Log --" })
  local lines = vim.fn.readfile(log_path)
  vim.api.nvim_buf_set_lines(buf, 1, -1, false, lines)

  -- function to update buffer with new lines (trailing log)
  local timer = vim.loop.new_timer()
  timer:start(
    0,
    1000,
    vim.schedule_wrap(function()
      local new_lines = vim.fn.readfile(log_path)
      vim.api.nvim_buf_set_lines(buf, 1, -1, false, new_lines)
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent! normal! G") -- jump to end to trail
      end)
    end)
  )

  -- close timer on window close
  vim.api.nvim_create_autocmd("WinClosed", {
    buffer = buf,
    callback = function()
      timer:stop()
      timer:close()
    end,
  })
end

vim.api.nvim_create_user_command("LspLogFloat", M.open_lsp_log_float, {})

return M
