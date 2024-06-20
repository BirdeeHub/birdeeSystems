local M = {}

local function starts_with(str, prefix)
  if str == nil or prefix == nil then
    return false
  end
  return string.sub(str, 1, string.len(prefix)) == prefix
end

---@type function[]
local states = {}

---@param plugin_name string
---@param mod_paths string[]
function M.append(plugin_name, mod_paths)
  ---@param mod_path string
  ---@return string|nil
  states[states+1] = function(mod_path)
	for _, v in ipairs(mod_paths) do
	  if starts_with(mod_path, v) then
		return plugin_name
	  end
	end
	return nil
  end
end

---@param mod_path string
---@return boolean
function M.call(mod_path)
  for i, v in ipairs(M.states) do
	local name = v(mod_path)
	if name ~= nil then
	  local ok, err = pcall(vim.cmd.packadd, name)
	  table.remove(M.states, i)
	  if ok then
		return true
	  else
		vim.notify('packadd ' .. name .. ' failed: ' .. err, vim.log.levels.WARN, { title = "birdee lazy require" })
		return false
	  end
	end
  end
  return false
end

return M
