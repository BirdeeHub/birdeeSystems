---@class lze.Pluginext: lze.Plugin
---@field after_loaded? boolean
---@field before_loaded? boolean
---@field pre_loaded? boolean

---@type table<string, lze.Pluginext>
local states = {}

local M = {
  ---@type lze.Handler
  handler = {
    -- throwaway field because it is required
    spec_field = "debug_handler_field",
    before = function (name)
      states[name].before_loaded = true
    end,
    after = function (name)
      states[name].after_loaded = true
    end,
    ---@param plugin lze.Pluginext
    add = function(plugin)
      states[plugin.name] = plugin
      if plugin.lazy then
        states[plugin.name].pre_loaded = false
      else
        states[plugin.name].pre_loaded = true
      end
    end,
  },
  get_all_plugins = function()
    return states
  end,
  get_a_plugin = function(name)
    return states[name]
  end,
}

return M
