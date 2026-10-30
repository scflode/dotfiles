-- Outside tmux but inside Rex, leave the last nvim split by asking Rex to move focus.
local function rex_navigate(wincmd, direction)
  return function()
    local win = vim.api.nvim_get_current_win()
    vim.cmd.wincmd(wincmd)
    if win == vim.api.nvim_get_current_win() then
      vim.system({ vim.env.REX_BIN_DIR .. "/rex", "focus", direction })
    end
  end
end

local in_rex = vim.env.TMUX == nil and vim.env.REX_BIN_DIR ~= nil

return {
  -- tmux integration
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    cond = not in_rex,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", desc = "Navigate left" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", desc = "Navigate down" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", desc = "Navigate up" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", desc = "Navigate right" },
    },
  },
  {
    "LazyVim/LazyVim",
    keys = in_rex and {
      { "<c-h>", rex_navigate("h", "left"), desc = "Navigate left" },
      { "<c-j>", rex_navigate("j", "down"), desc = "Navigate down" },
      { "<c-k>", rex_navigate("k", "up"), desc = "Navigate up" },
      { "<c-l>", rex_navigate("l", "right"), desc = "Navigate right" },
    } or {},
  },
}
