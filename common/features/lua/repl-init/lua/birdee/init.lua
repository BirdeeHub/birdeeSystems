local M = {}
local MP = ...

-- TODO: add fn_finder and your chaining macros
function M.openLibs()
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
	_G.sh = require(MP:relpath "shelua").add_all_reprs(require("sh") {
		proper_pipes = true,
		escape_args = true,
		shell = "posix_plus",
	})
	os.env = require("osenv")
	_G.uv = require("luv")
end

function M.initRepl()
	M.openLibs()
	require(MP:relpath "repl")()
end

return M
