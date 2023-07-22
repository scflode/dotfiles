local M = {}

local Util = require("util")

M.inspect = function(value)
  print(Util.normalize(value))
end

return M
