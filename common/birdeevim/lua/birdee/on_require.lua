local trigger_load = require("lz.n").trigger_load

---@type table<string, function>
local states = {}

---@param mod_path string
---@return boolean
local function call(mod_path)
  local found = false
  local plugins = {}
  for _, has in pairs(states) do
    local plugin = has(mod_path)
    if plugin ~= nil then
      table.insert(plugins, plugin)
      found = true
    end
  end
  if plugins ~= {} then
    trigger_load(plugins)
  end
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
  spec_field = "on_require",
  ---@param plugin lz.n.Plugin
  del = function (plugin)
    states[plugin.name] = nil
  end,
}

---@class lz_n_plugin: lz.n.Plugin
---@field on_require? string[]|string

---Adds a plugin to be lazy loaded upon requiring any submodule of provided mod paths
---@param plugin lz_n_plugin
function M.add(plugin)
  local on_req = plugin.on_require
  ---@type string[]
  local mod_paths = {}
  if type(on_req) == "table" then
    ---@cast on_req string[]
    mod_paths = on_req
  elseif type(on_req) == "string" then
    mod_paths = { on_req }
  else
    return
  end
  ---@param mod_path string
  ---@return lz_n_plugin|nil
  local function item(mod_path)
    for _, v in ipairs(mod_paths) do
      if starts_with(mod_path, v) then
        return plugin
      end
    end
    return nil
  end
  states[plugin.name] = item
end

-- NOTE: run require overload
local oldrequire = require
require('_G').require = function (mod_path)
  local ok, value = pcall(oldrequire, mod_path)
  if ok then
    return value
  end
  package.loaded[mod_path] = nil
  if call(mod_path) then
    return oldrequire(mod_path)
  end
  error(value)
end

return M
