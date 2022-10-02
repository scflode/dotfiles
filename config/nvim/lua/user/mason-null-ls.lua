local status_ok, mason_null_ls = pcall(require, "mason-null-ls")
if not status_ok then
  return
end

mason_null_ls.setup({
  automatic_installation = true,
  ensure_installed = {
    'stylua',
    'shellcheck',
    'editorconfig-checker',
    'shfmt',
    'pslam',
    'phpcsfixer',
  }
})

