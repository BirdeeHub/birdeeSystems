---@class lze.Pluginext: lze.Plugin
---@field is_loaded? boolean

---@type table<string, lze.Pluginext>
local states = {}

local M = {
  ---@type lze.Handler
  handler = {
    -- this field does nothing but it does stop others from using is_loaded,
    -- which is good because we are going to write to it.
    spec_field = "is_loaded",
    ---@param plugin lze.Pluginext
    before = function (plugin)
      if not states[plugin.name] then
        states[plugin.name] = plugin
      end
      states[plugin.name].is_loaded = true
    end,
    after = function (plugin)
      if not states[plugin.name] then
        states[plugin.name] = plugin
      end
      states[plugin.name].is_loaded = true
    end,
    ---@param plugin lze.Pluginext
    add = function(plugin)
      states[plugin.name] = plugin
      if plugin.lazy then
        states[plugin.name].is_loaded = false
      else
        states[plugin.name].is_loaded = true
      end
    end,
  },
}

function M.get_all_plugins()
  return states
end

function M.get_a_plugin(name)
  return states[name]
end

return M
