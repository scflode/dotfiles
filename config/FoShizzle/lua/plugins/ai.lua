return {
  {
    "Exafunction/codeium.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup()
    end,
  },
  {
    "David-Kunz/gen.nvim",
    opts = {
      model = "llama3:latest",
    },
    keys = {
      { "<leader>A", "<cmd>Gen<cr>", mode = { "n", "v" }, desc = "Open AI Prompt" },
    },
  },
}
