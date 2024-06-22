local loader = require("lz.n.loader")

---@type table<string, function>
local states = {}

---@param mod_path string
---@return boolean
local function call(mod_path)
  local found = false
  local names = {}
  for name, has in pairs(states) do
    if has(mod_path) then
      table.insert(names, name)
      found = true
    end
  end
  loader.load(names)
  return found
end

local function starts_with(str, prefix)
  if str == nil or prefix == nil then
    return false
  end
  return string.sub(str, 1, string.len(prefix)) == prefix
end

-- NOTE: the handler for lz.n

---@class lz.n.ReqHandler: lz.n.Handler

---@type lz.n.ReqHandler
local M = {
    type = "on_require",
}

---Adds a plugin to be lazy loaded upon requiring any submodule of provided mod paths
---@param plugin lz.n.Plugin
function M.add(plugin)
  ---@type string[]
  local mod_paths
  if type(plugin.on_require) == "table" then
      mod_paths = plugin.on_require
  elseif type(plugin.on_require) == "string" then
      mod_paths = { plugin.on_require }
  end
  ---@param mod_path string
  ---@return boolean
  local function item(mod_path)
    for _, v in ipairs(mod_paths) do
      if starts_with(mod_path, v) then
        return true
      end
    end
    return false
  end
  states[plugin.name] = item
end

---@param plugin lz.n.Plugin
function M.del(plugin)
    states[plugin.name] = nil
end

-- NOTE: run require overload
local oldrequire = require
require('_G').require = function (mod_path)
  local ok, value = pcall(oldrequire, mod_path)
  if ok then
    return value
  end
  if call(mod_path) then
    return oldrequire(mod_path)
  end
  error(value)
end

return M
