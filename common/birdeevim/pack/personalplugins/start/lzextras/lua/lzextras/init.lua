---@class lzextras
---@field key2spec fun(): any
---@field keymap fun(): any
---@field debug fun(): any
---@field make_load_with_afters fun(): any
local lzextras = {}

return setmetatable(lzextras,{
    __index = function(_, k)
        return require('lzextras.src.'.. k)
    end,
})
