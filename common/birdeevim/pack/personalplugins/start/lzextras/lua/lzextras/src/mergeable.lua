---@class lze.Pluginext: lze.Plugin
---@field merge? boolean
---@field opts? boolean

-- TODO: use modify to bounce everything mergeable
-- hold them here until trigger is called
-- merge duplicates coming in.

local M = {
  trgger = function() end,
  ---@type lze.Handler
  handler = {
  }
}

return M
