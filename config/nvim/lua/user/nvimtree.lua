local status_ok, nvimtree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

local icons = require("user.icons")

nvimtree.setup({
  disable_netrw = true,
  hijack_netrw = true,
  update_cwd = false,
  view = {
    adaptive_size = true,
    hide_root_folder = true,
    side = "right",
    mappings = {
      list = {
        { key = "u", action = "dir_up" },
      },
    },
  },
  renderer = {
    indent_markers = {
      enable = true,
    },
    icons = {
      webdev_colors = false,
      glyphs = {
        git = {
          unstaged = icons.git.Mod,
          staged = icons.git.Add,
          unmerged = icons.git.Unmerged,
          renamed = icons.git.Rename,
          untracked = "★",
          deleted = icons.git.Remove,
          ignored = icons.git.Ignore,
        },
      },
    },
  },
})
