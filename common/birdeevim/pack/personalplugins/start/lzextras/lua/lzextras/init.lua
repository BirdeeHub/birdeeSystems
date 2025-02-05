---@class lzextras
---@field key2spec fun(mode:string|string[], lhs:string, rhs:string|function, opts:vim.keymap.set.Opts): lze.KeysSpec
---@field keymap fun(mode:string|string[], lhs:string, rhs:string|function, opts:vim.keymap.set.Opts)
---@field make_load_with_afters (fun(dirs: string[]|string): fun(names: string|string[]))|(fun(dirs: string[]|string, load: fun(name: string):string|nil): fun(names: string|string[]))

---@type lzextras
local lzextras = {}

return setmetatable(lzextras,{
  __index = function(_, k)
    return require('lzextras.src.'.. k)
  end,
})
