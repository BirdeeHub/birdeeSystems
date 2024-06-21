local loader = require("lz.n.loader")

---@class lz.n.ReqHandler: lz.n.Handler

---@type lz.n.ReqHandler
local M = {
    pending = {},
    type = "on_require",
}

local function starts_with(str, prefix)
    if str == nil or prefix == nil then
        return false
    end
    return string.sub(str, 1, string.len(prefix)) == prefix
end

---@param mod_path string
---@return boolean
local function call(mod_path)
    local plugin_names = {}
    for mod, vals in pairs(M.pending) do
        if starts_with(mod_path, mod) then
            vim.list_extend(plugin_names, vim.tbl_values(vals))
        end
    end
    if plugin_names ~= {} then
        loader.load(vim.tbl_values(plugin_names))
        return true
    end
    return false
end

local oldrequire = require

---@param mod_path string
local function lazy_packadd_require(mod_path)
    local ok, value = pcall(oldrequire, mod_path)
    if ok then
        return value
    end
    if call(mod_path) then
        return oldrequire(mod_path)
    end
    error(value)
end

require('_G').require = lazy_packadd_require

---Adds a plugin to be lazy loaded upon requiring any submodule of provided mod paths
---@param plugin lz.n.Plugin
function M.add(plugin)
    if type(plugin.on_require) == "table" then
        for _, mod in pairs(plugin.on_require) do
            M.pending[mod] = M.pending[mod] or {}
            M.pending[mod][plugin.name] = plugin.name
        end
    elseif type(plugin.on_require) == "string" then
        M.pending[plugin.on_require] = M.pending[plugin.on_require] or {}
        M.pending[plugin.on_require][plugin.name] = plugin.name
    else
        vim.notify("on_require value must be a string or a list of strings, but it is of type" .. type(plugin.on_require),
        vim.log.levels.ERROR, { title = "lz.n" })
    end
end

---@param plugin lz.n.Plugin
function M.del(plugin)
    if type(plugin.on_require) == "table" then
        for _, mod in pairs(plugin.on_require) do
            M.pending[mod][plugin.name] = nil
        end
    elseif type(plugin.on_require) == "string" then
        M.pending[plugin.on_require][plugin.name] = nil
    else
        vim.notify("on_require value must be a string or a list of strings, but it is of type" .. type(plugin.on_require),
        vim.log.levels.ERROR, { title = "lz.n" })
    end
end

return M
