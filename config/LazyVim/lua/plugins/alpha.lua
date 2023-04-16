return {
  "goolord/alpha-nvim",
  opts = function(_, opts)
    local logo = [[
                     ______ 
___  / ______ __________  __
__  /  _  __ `/__  /_  / / /
_  /___/ /_/ /__  /_  /_/ / 
/_____/\__,_/ _____/\__, /  
                   /____/   
	                   [ @scflode ]
    ]]
    opts.section.header.val = vim.split(logo, "\n", { trimempty = true })
    return opts
  end,
}
