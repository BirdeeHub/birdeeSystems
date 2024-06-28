---@type table<string, string>
local states = {}

local M = {
  ---@type lz.n.Handler
  handler = {
	-- this field does nothing but it does stop others from using is_loaded,
	-- which is good because we overwrite the value in getAllPlugins
	spec_field = "is_loaded",
	---@param plugin lz.n.Plugin
	del = function (plugin)
	  states[plugin.name] = plugin.name
	end,
	add = function(_) end,
  },
}

function M.get_all_plugins()
  local result = vim.deepcopy(require("lz.n.state").plugins)
  for _, name in pairs(states) do
	if result[name] ~= nil then
	  ---@diagnostic disable-next-line: inject-field
	  result[name].is_loaded = true
	end
  end
  return result
end

function M.get_a_plugin(name)
  local result = vim.deepcopy(require("lz.n.state").plugins[name])
  if result ~= nil and states[name] ~= nil then
    ---@diagnostic disable-next-line: inject-field
    result.is_loaded = true
  end
  return result
end

return M
