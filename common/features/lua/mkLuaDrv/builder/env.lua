local uv = _G.uv
if not uv then
	local ok
	ok, uv = pcall(require, "luv")
	if not ok then
		error("luv is required for sh.env")
	end
end
return setmetatable({}, {
	__index = function(_, k)
		return uv.os_getenv(tostring(k))
	end,
	__newindex = function(self, k, v)
		-- false → mass unset (env[{}] = {...})
		-- true → “with defs” (table-key conditional behavior enabled)
		-- nil → normal scalar key behavior
		local w_defs
		if type(k) == "table" then
			w_defs = (k[1] ~= nil)
		else
			w_defs = nil
		end
		if w_defs == false then
			if type(v) ~= "table" then
				uv.os_unsetenv(tostring(v))
			else
				for _, n in pairs(v) do
					uv.os_unsetenv(tostring(n))
				end
			end
			return
		end
		k = tostring(w_defs and k[1] or k)
		if v == nil then
			uv.os_unsetenv(k)
		elseif not w_defs or not uv.os_getenv(k) then
			uv.os_setenv(k, tostring(v))
		end
	end,
	__call = function(self, t, overwrite)
		if not t then
			return uv.os_environ()
		end
		if overwrite then
			local t2 = {}
			for k, v in pairs(t) do
				local key = tostring(type(k) == "table" and k[1] or k)
				uv.os_setenv(key, tostring(v))
				t2[key] = true
			end
			for k, _ in pairs(uv.os_environ()) do
				if not t2[k] then
					uv.os_unsetenv(k)
				end
			end
		else
			for k, v in pairs(t) do
				if type(k) == "table" then
					local key = k[1] ~= nil and tostring(k[1]) or nil
					if key ~= nil and not uv.os_getenv(key) then
						uv.os_setenv(key, tostring(v))
					end
				else
					uv.os_setenv(tostring(k), tostring(v))
				end
			end
		end
		return self
	end,
})
