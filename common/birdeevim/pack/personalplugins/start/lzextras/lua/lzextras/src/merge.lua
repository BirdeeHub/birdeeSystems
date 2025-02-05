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
      local pname = plugin.name
      local pstate = require('lze').state(pname)
      if pstate then
        vim.notify('Failed to merge: "' .. pname .. '". Immutable spec already exists',
          vim.log.levels.WARN, { title = "lzextras.merge" })
        return plugin
      elseif pstate == false and not (plugin.allow_again or states[pname].allow_again) then
        vim.notify('Failed to merge: "' .. pname .. '". Spec already loaded',
          vim.log.levels.WARN, { title = "lzextras.merge" })
        return plugin
      end
      states[pname] = vim.tbl_deep_extend('force',states[pname] or {}, plugin)
      return { name = pname, enabled = false }
    end
  },
  trigger = function()
    if states ~= {} then
      require('lze').load(vim.tbl_values(states))
    end
  end,
}

return M
