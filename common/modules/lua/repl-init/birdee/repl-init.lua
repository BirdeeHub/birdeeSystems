local colors = require 'term.colors'
local char   = require "sirocco.char"
local default = require 'croissant.conf'

local M = {}

function M.colorToEscapeCode(color)
    if type(color) == "string" then
        return colors[color]
    end
    local res = ""
    for _, c in ipairs(color) do
        res = res .. (colors[c] or "")
    end
    return res
end

function M.renderReplKeybinds(keybinds)
    local res = {}
    for command, bindings in pairs(keybinds) do
        local bds = {}

        for _, key in ipairs(bindings) do
            local prefix, suffix = key:match "^([CM])-(.*)"

            if prefix then
                table.insert(bds, char[prefix](suffix))
            else
                table.insert(bds, key)
            end
        end

        res[command] = bds
    end
    return res
end

function M.initRepl()
    default.syntaxColors.identifier = M.colorToEscapeCode 'cyan'
    os.sh = require('sh')
    os.env = require('osenv')
    _G.uv = require('luv')
    require('croissant.repl')()
end

return M
