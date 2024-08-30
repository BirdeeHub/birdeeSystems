local trigger_load = require("lz.n").trigger_load
local states = require("lz.n.handler.state").new()
---@type table<string, true>
local called = {}

---@type lz.n.Handler
---@diagnostic disable-next-line: missing-fields
local M = {
    spec_field = "dep_of",
    lookup = states.lookup_plugin
}

---@param plugin lz.n.Plugin
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
    for _, name in ipairs(needed_by) do
        if called[name] == true then
            trigger_load(plugin)
            return
        end
    end
    for _, name in ipairs(needed_by) do
        states.insert(name, plugin)
    end
end

---@param pname string
function M.del(pname)
    states.del(pname)
    called[pname] = true
    if states.has_pending_plugins(pname) then
        states.each_pending(pname,
            function (p)
                states.del(p.name)
                trigger_load(p)
            end
        )
    end
end

return M
