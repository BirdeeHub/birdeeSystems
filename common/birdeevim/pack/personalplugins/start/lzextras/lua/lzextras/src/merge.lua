---@class lzextras.MergePlugin: lze.Plugin
---@field merge? any

local function is_enabled(spec)
    local disabled = spec.enabled == false or (type(spec.enabled) == "function" and not spec.enabled())
    return not disabled
end

---@type table<string, lze.Plugin>
local states = {}

local M = {
  ---@type lze.Handler
  handler = {
    spec_field = "merge",
    -- modify is only called when a plugin's field is not nil
    ---@param plugin lzextras.MergePlugin
    modify = function(plugin)
      if not plugin.merge and not is_enabled(plugin) then
        return plugin
      end
      local pname = plugin.name
      local pstate = require('lze').state(pname)
      if pstate then
        vim.notify('Failed to merge: "' .. pname .. '". Immutable spec already exists',
          vim.log.levels.ERROR, { title = "lzextras.merge" })
        return plugin
      elseif pstate == false and not (plugin.allow_again or states[pname].allow_again) then
        vim.notify('Failed to merge: "' .. pname .. '". Spec already loaded',
          vim.log.levels.ERROR, { title = "lzextras.merge" })
        return plugin
      end
      states[pname] = vim.tbl_deep_extend('force',states[pname] or {}, plugin)
      plugin.enabled = false
      return plugin
    end
  },
  trigger = function()
    if states ~= {} then
      require('lze').load(vim.tbl_values(states))
    end
  end,
}

return M
