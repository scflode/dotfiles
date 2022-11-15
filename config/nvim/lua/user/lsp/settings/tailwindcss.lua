vim.lsp.set_log_level("debug")
return {
  filetypes = {
    "aspnetcorerazor",
    "astro",
    "astro-markdown",
    "blade",
    "django-html",
    "edge",
    "elixir",
    "eelixir",
    "heex",
    "leex",
    "html-eex",
    "ejs",
    "erb",
    "eruby",
    "gohtml",
    "haml",
    "handlebars",
    "hbs",
    "html",
    "jade",
    "leaf",
    "liquid",
    "markdown",
    "mdx",
    "mustache",
    "njk",
    "nunjucks",
    "php",
    "razor",
    "slim",
    "twig",
    "css",
    "less",
    "postcss",
    "sass",
    "scss",
    "stylus",
    "sugarss",
    "javascript",
    "javascriptreact",
    "reason",
    "rescript",
    "typescript",
    "typescriptreact",
    "vue",
    "svelte",
  },
  init_options = {
    userLanguages = {
      eelixir = "html-eex",
      elixir = "html-eex",
      heex = "html-eex",
      leex = "html-eex",
      eruby = "erb",
    },
  },
  settings = {
    tailwindCss = {
      classAttributes = { "class", "className", "ngClass" },
      experimental = {
        configFile = "assets/tailwind.config.js",
      },
    },
  },
}
