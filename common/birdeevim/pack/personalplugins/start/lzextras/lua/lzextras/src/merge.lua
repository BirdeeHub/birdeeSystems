---@class lzextras.MergePlugin: lze.Plugin
---@field merge? any

---@type table<string, lze.Plugin>
local states = {}

local M = {
  ---@type lze.Handler
  handler = {
    spec_field = "merge",
    -- modify is only called when a plugin's field is not nil
    ---@param plugin lzextras.MergePlugin
    modify = function(plugin)
      if not plugin.merge then
        return plugin
      end
      states[plugin.name] = vim.tbl_deep_extend('force',states[plugin.name] or {}, plugin)
      return { name = plugin.name, enabled = false }
    end
  },
  trigger = function()
    if states ~= {} then
      require('lze').load(vim.tbl_values(states))
    end
  end,
}

return M
