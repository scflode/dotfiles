-- must be set before calling require
vim.g.nvim_tree_indent_markers = 1 -- this option shows indent markers when folders are open

require('nvim-tree').setup {
  disable_netrw = false,
  hijack_netrw = false,
  auto_close = true,
  update_cwd = true,
  view = { auto_resize = true,
      hide_root_folder = true,
      side = 'right',
  }
}
