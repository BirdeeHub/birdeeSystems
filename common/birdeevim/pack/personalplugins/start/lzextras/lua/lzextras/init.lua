---@class lzextras.Debug
---@field handler lze.Handler
---@field get_all_plugins fun(): any
---@field get_a_plugin fun(string): any

---@class lzextras
---@field key2spec fun(mode:string|string[], lhs:string, rhs:string|function, opts:vim.keymap.set.Opts): lze.KeysSpec
---@field keymap fun(mode:string|string[], lhs:string, rhs:string|function, opts:vim.keymap.set.Opts)
---@field debug lzextras.Debug
---@field make_load_with_afters (fun(dirs: string[]|string): fun(names: string|string[]))|(fun(dirs: string[]|string, load: fun(name: string):string|nil): fun(names: string|string[]))
local lzextras = {}

return setmetatable(lzextras,{
    __index = function(_, k)
        return require('lzextras.src.'.. k)
    end,
})
