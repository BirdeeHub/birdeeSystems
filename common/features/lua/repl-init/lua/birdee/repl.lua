local colors = require("term.colors")
local char = require("sirocco.char")

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
			local prefix, suffix = key:match("^([CM])-(.*)")

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

local default_colors = {
	identifier = "cyan",
}

function M.init(self)
	local conf = require("croissant.conf")
	for k, v in pairs(self.colors or default_colors) do
		conf.syntaxColors[k] = M.colorToEscapeCode(v)
	end
	require("croissant.repl")()
end

return setmetatable(M, { __call = M.init })
