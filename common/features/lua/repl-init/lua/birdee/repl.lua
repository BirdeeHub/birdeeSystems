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

local function croissant(self)
	local conf = require("croissant.conf")
	for k, v in pairs(self.colors or default_colors) do
		conf.syntaxColors[k] = M.colorToEscapeCode(v)
	end
	require("croissant.repl")()
end

local function init(self)
	local repl = require("repl.console")
	if not self.rlwrap then
		repl:loadplugin("linenoise")
	else
		pcall(repl.loadplugin, repl, "rlwrap")
	end
	repl:loadplugin("history")
	repl:loadplugin("completion")
	repl:loadplugin("filename_completion")
	repl:loadplugin("autoreturn")
	if self.pretty_print then
		repl:loadplugin("inspect")
	end
	print("Lua REPL " .. tostring(repl.VERSION))
	repl:run()
end

M.pretty_print = true

return setmetatable(M, {
	__call = init,
	__index = function(self, k)
		if k == "init" then
			return function()
				return init(self)
			end
		end
		if k == "croissant" then
			return function()
				return croissant(self)
			end
		end
	end,
})
