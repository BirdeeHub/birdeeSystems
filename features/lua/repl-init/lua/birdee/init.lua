local M = {}
local MP = ...
local cfg = string.gmatch(package.config, "(%S+)")
local dirsep, pathsep, pathmark = cfg() or "/", cfg() or ";", cfg() or "?"

-- TODO: add fn_finder and your chaining macros
function M.openLibs()
	string.dircat = function(...)
		return table.concat({ ... }, dirsep)
	end
	string.pathcat = function(...)
		return table.concat({ ... }, pathsep)
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
	_G.sh = require(MP:relpath("shelua")).add_all_reprs(require("sh")({
		proper_pipes = true,
		escape_args = true,
		shell = "posix_plus",
	}))
	os.env = require("osenv")
	_G.uv = require("luv")
	package.add_dir = function(dir, ty)
		dir = dir:sub(-1) == "/" and dir:sub(1, -2) or dir
		if not ty or ty == "lua" then
			package.path = dir:dircat(pathmark .. ".lua"):pathcat(dir:dircat(pathmark, "init.lua"), package.path)
		elseif ty == "c" then
			package.cpath = dir:dircat(pathmark .. ".so"):pathcat(package.cpath)
		elseif ty == "fnl" then
			-- TODO: ??
		end
	end
end

function M.initRepl()
	M.openLibs()
	require(MP:relpath("repl"))()
end

return M
