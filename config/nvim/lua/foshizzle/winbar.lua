require("winbar").setup({
  enabled = true,

  show_file_path = true,
  show_symbols = false,

  colors = {
    path = "", -- You can customize colors like #c946fd
    file_name = "",
    symbols = "",
  },

  icons = {
    file_icon_default = "",
    seperator = ">",
    editor_state = "●",
    lock_icon = "",
  },

  exclude_filetype = {
    "help",
    "nerdtree",
  },
})
