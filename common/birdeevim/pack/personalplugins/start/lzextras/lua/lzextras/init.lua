---@class lzextras.Merge
---@field handler lze.Handler
---@field trigger fun()

---@class lzextras.Keymap
---@field set fun(mode:string|string[], lhs:string, rhs:string|function, opts:vim.keymap.set.Opts)

---@class lzextras
---@field key2spec fun(mode:string|string[], lhs:string, rhs:string|function, opts:vim.keymap.set.Opts): lze.KeysSpec
---@field keymap fun(plugin: string|lze.PluginSpec): lzextras.Keymap
---@field make_load_with_afters (fun(dirs: string[]|string): fun(names: string|string[]))|(fun(dirs: string[]|string, load: fun(name: string):string|nil): fun(names: string|string[]))
---merge handler must be registered
---before all other handlers with modify hooks
---@field merge lzextras.Merge

---@type lzextras
local lzextras = {}

return setmetatable(lzextras,{
  __index = function(_, k)
    return require('lzextras.src.'.. k)
  end,
})
