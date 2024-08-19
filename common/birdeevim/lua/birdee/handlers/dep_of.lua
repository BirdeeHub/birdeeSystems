---@type table<string, string[]>
local states = {}

local trigger_load = require("lze").trigger_load

-- NOTE: the handler for lze

---@class lze.DepOfHandler: lze.Handler
---@type lze.DepOfHandler
local M = {
  spec_field = "dep_of",
}

---@class p_dep_of: lze.Plugin
---@field dep_of? string[]|string

---@param plugin p_dep_of
function M.add(plugin)
  local dep_of = plugin.dep_of
  ---@type string[]
  local needed_by = {}
  if type(dep_of) == "table" then
    ---@cast dep_of string[]
    needed_by = dep_of
  elseif type(dep_of) == "string" then
    needed_by = { dep_of }
  else
    return
  end
  for _, dep in ipairs(needed_by) do
    vim.list_extend(states[dep], { plugin.name })
  end
end

---@param plugin p_dep_of
function M.before(plugin)
  if states[plugin.name] ~= nil then
    trigger_load(states[plugin.name])
    states[plugin.name] = nil
  end
end

return M
