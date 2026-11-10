_G.uv = require("luv")

local function splitdir(path, sep)
	if not path or path == "" then
		return {}
	end
	local pattern = "[^" .. (sep or package.config:sub(1, 1)) .. "/]+"
	local parts = {}
	for part in path:gmatch(pattern) do
		parts[#parts + 1] = part
	end
	return parts
end
function os.mkdir(path, mode)
	mode = mode or 511
	if type(path) == "table" then
		local sep = path.sep or package.config:sub(1, 1)
		local fpath = not path.split and path or nil
		if not fpath then
			fpath = {}
			local split = path.split == true and splitdir or path.split
			for _, segment in ipairs(path) do
				for _, v in ipairs(split(segment, sep)) do
					table.insert(fpath, v)
				end
			end
		end
		local current
		for i = 1, #fpath do
			current = (i ~= 1 and (current .. sep) or "") .. fpath[i]
			local ok, err, errname = uv.fs_mkdir(current, mode)
			if not ok and errname ~= "EEXIST" then
				return nil, err, errname
			end
		end
	else
		return uv.fs_mkdir(path, mode)
	end
	return true
end

function os.write_file(opts, filename, content)
	local file = assert(io.open(filename, opts.append and "a" or "w"))
	file:write(content .. (opts.newline ~= false and "\n" or ""))
	file:close()
end

function os.read_file(filename)
	local file = assert(io.open(filename, "r"))
	local content = file:read("*a")
	file:close()
	return content
end

function os.readable(filename)
	if type(filename) == "string" then
		local file = io.open(filename, "r") -- Try to open the file in read mode
		if file then
			file:close() -- Close the file if it exists
			return true
		end
	end
	return false
end

_G.sh = require("sh")
string.escapeShellArg = getmetatable(_G.sh).repr.posix.escape
local cjson = require("cjson")
return function(stdpath)
	do
		local sep = package.config:sub(1, 1)
		os.env = dofile(stdpath .. sep.. "env.lua")
		_G.DRV = cjson.decode(os.read_file(os.env.NIX_ATTRS_JSON_FILE))
		package.preload.DRV = function()
			return _G.DRV
		end
		local name = _G.DRV.name
		local build = os.env.NIX_BUILD_TOP
		if os.mkdir({ build, name .. "-build", split = true, sep = sep }, 511) then
			_G.BUILD_DIR = build .. sep .. name .. "-build"
			uv.chdir(_G.BUILD_DIR)
			os.env.PWD = _G.BUILD_DIR
		end
		local temp = os.tmpname()
		if os.mkdir({ temp, name, "temp", split = true, sep = sep }, 511) then
			_G.TEMP_DIR = temp .. sep .. name
		end
		_G.outputs = _G.DRV.outputs
		_G.out = _G.DRV.outputs[_G.DRV.outputName or "out"]
		_G.src = _G.DRV.src
		_G.DRV.env = _G.DRV.env or {}
		local psep = package.config:sub(3, 3)
		local p = _G.DRV.env.LUA_PATH
		if p then
			package.path = p .. psep .. package.path
		end
		p = _G.DRV.env.LUA_CPATH
		if p then
			package.cpath = p .. psep .. package.cpath
		end
		p = _G.DRV.LUA_PATH
		if p then
			package.path = p .. psep .. package.path
		end
		p = _G.DRV.LUA_CPATH
		if p then
			package.cpath = p .. psep .. package.cpath
		end
		for key, value in pairs(_G.DRV.env) do
			if type(value) == "string" then
				os.env[key] = value
			end
		end
	end
	if type(_G.DRV.buildCommand) == "string" then
		local ok, chunk = pcall((loadstring or load), _G.DRV.buildCommand)
		if not ok then
			io.stderr:write(chunk .. "\n")
			os.exit(1)
		end
		---@cast chunk function
		ok, chunk = pcall(chunk)
		if not ok then
			io.stderr:write(chunk .. "\n")
			os.exit(1)
		end
	elseif type(_G.DRV.build) == "table" then
		for _, v in ipairs(_G.DRV.build) do
			local data = v.data
			if type(data) == "string" then
				local ok, chunk = pcall((loadstring or load), data)
				if not ok then
					io.stderr:write((v.name and ("Error in " .. v.name .. ": ") or "") .. chunk .. "\n")
					os.exit(1)
				end
				---@cast chunk function
				ok, chunk = pcall(chunk)
				if not ok then
					io.stderr:write((v.name and ("Error in " .. v.name .. ": ") or "") .. chunk .. "\n")
					os.exit(1)
				end
			end
		end
	end
end
