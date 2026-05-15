local colors = require 'term.colors'
local char   = require "sirocco.char"
local default = require 'croissant.conf'

local function colorToEscapeCode(color)
    if type(color) == "string" then
        return colors[c]
    end
    local color = ""
    for _, c in ipairs(v) do
        color = color .. colors[c]
    end
    return color
end

local function renderReplKeybinds(keybinds)
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
