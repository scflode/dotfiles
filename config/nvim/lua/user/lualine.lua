local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
  return
end

local icons = require("user.icons")

local hide_in_width_60 = function()
  return vim.o.columns > 60
end

local mode = {
  "mode",
  fmt = function(str)
    return str:sub(1, 1)
  end,
}

local diff = {
  "diff",
  colored = false,
  symbols = { added = icons.git.Add .. " ", modified = icons.git.Mod .. " ", removed = icons.git.Remove .. " " }, -- changes diff symbols
  cond = hide_in_width_60,
  separator = "%#SLSeparator#" .. "%*",
}

local filetype = {
  "filetype",
  colored = false,
  icons_enabled = true,
}

lualine.setup({
  options = {
    fmt = string.lower,
    icons_enabled = true,
    theme = "base16",
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = {},
    always_divide_middle = true,
    globalstatus = true,
  },
  sections = {
    lualine_a = { mode },
    lualine_b = { "branch" },
    lualine_c = { "diagnostics" },
    lualine_x = { diff, "encoding", "fileformat", filetype },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = {},
})
