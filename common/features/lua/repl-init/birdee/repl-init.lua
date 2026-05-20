local colors = require("term.colors")
local char = require("sirocco.char")
local conf = require("croissant.conf")

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

string.relpath = function(str, sub, n)
	local result = {}
	n = type(sub) == "string" and n or sub
	if type(n) == "number" and n > 0 then
		for match in (str .. "."):gmatch("(.-)%.") do
			table.insert(result, match)
		end
		while n > 0 do
			table.remove(result)
			n = n - 1
		end
	else
		table.insert(result, str)
	end
	if type(sub) == "string" then
		table.insert(result, sub)
	end
	return #result == 1 and result[1] or table.concat(result, ".")
end

if not table.pack then
	table.pack = function(...)
		return { n = select("#", ...), ... }
	end
end

-- TODO: add fn_finder and your chaining macros

function M.initRepl()
	conf.syntaxColors.identifier = M.colorToEscapeCode("cyan")
	_G.sh = require("birdee.shelua").add_all_reprs(require("sh") {
		proper_pipes = true,
		escape_args = true,
		shell = "posix_plus",
	})
	os.env = require("osenv")
	_G.uv = require("luv")
	require("croissant.repl")()
end

return M
