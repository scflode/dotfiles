local M = {}

M.require_plugin = function(module_name)
  local status_ok, loaded_plugin = pcall(require, module_name)
  if not status_ok then
    error("Could not load " .. module_name)
  end

  return loaded_plugin
end

return M
