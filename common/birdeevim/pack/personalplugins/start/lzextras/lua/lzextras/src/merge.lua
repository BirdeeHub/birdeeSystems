---@class lze.Pluginext: lze.Plugin
---@field merge? boolean
---@field opts? boolean

-- TODO: use modify to bounce everything mergeable
-- by setting enabled = false
-- hold them here until trigger is called
-- merge duplicates coming in.
-- when trigger is called, lze.load all at once

---@type table<string, lze.Pluginext>
local states = {}

local M = {
  trgger = function() end,
  ---@type lze.Handler
  handler = {
    spec_field = "merge",
    -- modify is only called when a plugin's field is not nil
    modify = function(plugin)
      plugin.enabled = false
      return plugin
    end
  }
}

return M
