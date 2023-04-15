-- https://github.com/jascha030/macos-nvim-dark-mode
local os_is_dark = function()
  return (vim.call(
    "system",
    [[echo $(defaults read -globalDomain AppleInterfaceStyle &> /dev/null && echo 'dark' || echo 'light')]]
  )):find("dark") ~= nil
end

return {
  {
    "folke/tokyonight.nvim",
    opts = function(_, opts)
      if os_is_dark() then
        opts.style = "night"
      else
        opts.style = "day"
      end
    end,
  },
}
