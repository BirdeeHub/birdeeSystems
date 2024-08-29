---@class lz.n.ReqPluginSpec: lz.n.PluginSpec
---@field on_require string[]

---@class lz.n.ReqPlugin: lz.n.Plugin
---@field on_require string[]

---@type lz.n.handler.State
local state = require("lz.n.handler.state").new()

---@type lz.n.Handler
local M = {
    spec_field = "on_require",
    ---@param plugin lz.n.ReqPlugin
    add = function(plugin)
        if not plugin.on_require then
            return
        end
        state.insert(plugin)
    end,
    del = state.del,
    lookup = state.lookup_plugin,
}

local trigger_load = require("lz.n").trigger_load

-- How we search for and load our plugins.
---@param mod_path string
---@return boolean
local function call(mod_path)
    local triggered_load = false
    ---@param plugin lz.n.ReqPlugin
    state.each_pending(function(plugin)
        local on_req = plugin.on_require
        ---@type string[]
        local mod_paths = {}
        if type(on_req) == "table" then
            ---@cast on_req string[]
            mod_paths = on_req
        elseif type(on_req) == "string" then
            mod_paths = { on_req }
        end
        local has_mod = vim.iter(mod_paths):any(function(path)
            return vim.startswith(mod_path, path)
        end)
        if has_mod then
            trigger_load(plugin)
            triggered_load = true
        end
    end)
    return triggered_load
end

--- Override `require` to search for plugins to lazy-load.
local oldrequire = require
require("_G").require = function(mod_path)
    local ok, value = pcall(oldrequire, mod_path)
    if ok then
        return value
    end
    package.loaded[mod_path] = nil
    if call(mod_path) == true then
        return oldrequire(mod_path)
    end
    error(value)
end

return M
