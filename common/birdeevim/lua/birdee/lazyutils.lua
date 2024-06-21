local M = {}

local function starts_with(str, prefix)
  if str == nil or prefix == nil then
    return false
  end
  return string.sub(str, 1, string.len(prefix)) == prefix
end

---@type function[]
local states = {}

---@param mod_path string
---@return boolean
local function call(mod_path)
  for i, v in ipairs(states) do
    local name, loader = v(mod_path)
    if name ~= nil then
      local ok, err = pcall(loader, name, mod_path)
      table.remove(states, i)
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

-- NOTE: public functions below

---Adds a plugin to be lazy loaded upon requiring any submodule of provided mod paths
---@param plugin_name string
---@param mod_paths string[]
---@param loader fun(plugin_name: string, mod_path: string)|nil
function M.addPlugin(plugin_name, mod_paths, loader)
  if loader == nil then
    loader = function(name, _)
      vim.cmd.packadd(name)
    end
  end
  ---@param mod_path string
  ---@return string|nil, fun(plugin_name: string, mod_path: string)
  local function item(mod_path)
    for _, v in ipairs(mod_paths) do
      if starts_with(mod_path, v) then
	return plugin_name, loader
      end
    end
    return nil, loader
  end
  table.insert(states, item)
end

local oldrequire = require

---@param mod_path string
function M.lazy_packadd_require(mod_path)
  local ok, value = pcall(oldrequire, mod_path)
  if ok then
    return value
  end
  if call(mod_path) then
    return oldrequire(mod_path)
  end
  error(value)
end

-- NOTE: static functions below

function M.safe_packadd_list(names)
  for _, name in ipairs(names) do
    if type(name) == 'string' then
      local ok, err = pcall(vim.cmd, 'packadd ' .. name)
      if not ok then
        vim.notify('packadd ' .. name .. ' failed: ' .. err, vim.log.levels.WARN, { title = "birdee.utils.safe_packadd_list" })
      end
    end
  end
end

function M.safe_force_packadd_list(names)
  for _, name in ipairs(names) do
    if type(name) == 'string' then
      local ok, err = pcall(vim.cmd, 'packadd! ' .. name)
      if not ok then
        vim.notify('packadd ' .. name .. ' failed: ' .. err, vim.log.levels.WARN, { title = "birdee.utils.safe_force_packadd_list" })
      end
    end
  end
end

return M
