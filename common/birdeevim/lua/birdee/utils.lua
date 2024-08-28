local M = {}

---@param file_path string
---@return boolean existed
function M.deleteFileIfExists(file_path)
  if vim.fn.filereadable(file_path) == 1 then
    os.remove(file_path)
    return true
  end
  return false
end

function M.split_string(str, delimiter)
  local result = {}
  for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match)
  end
  return result
end

---Requires plenary
---@param cmd string[]
---@param cwd string
---@return table
---@return unknown
---@return table
function M.get_os_command_output(cmd, cwd)
  if type(cmd) ~= "table" then
    print("[get_os_command_output]: cmd has to be a table")
    ---@diagnostic disable-next-line: return-type-mismatch
    return {}, nil, nil
  end
  local command = table.remove(cmd, 1)
  local stderr = {}
  local stdout, ret = require("plenary.job")
      :new({
        command = command,
        args = cmd,
        cwd = cwd,
        on_stderr = function(_, data)
          table.insert(stderr, data)
        end,
      })
      :sync()
  return stdout, ret, stderr
end

function M.authTerminal()
  local session
  local handle
  handle = io.popen([[bw login --check ]], "r")
  if handle then
    session = handle:read("*l")
    handle:close()
  end
  if vim.fn.expand('$BW_SESSION') ~= "$BW_SESSION" then
    session = vim.fn.expand('$BW_SESSION')
  else
    if session == "You are logged in!" then
      handle = io.popen([[bw unlock --raw --nointeraction ]] .. vim.fn.inputsecret('Enter password: '), "r")
      if handle then
        session = handle:read("*l")
        handle:close()
      end
    else
      local email = vim.fn.inputsecret('Enter email: ')
      local pass = vim.fn.inputsecret('Enter password: ')
      local client_secret = vim.fn.inputsecret('Enter api key client_secret: ')
      handle = io.popen([[bw login --raw --quiet ]] .. email .. " " .. pass .. ">/dev/null 2>&1", "w")
      if handle then
        handle:write(client_secret)
        handle:close()
      end
      handle = io.popen([[bw unlock --raw --nointeraction ]] .. pass, "r")
      if handle then
        session = handle:read("*l")
        handle:close()
      end
    end
  end
  return session
end

---@param plugin_names string[]|string
function M.safe_packadd(plugin_names)
  local names
  if type(plugin_names) == 'table' then
    names = plugin_names
  elseif type(plugin_names) == 'string' then
    names = { plugin_names }
  else
    return
  end
  for _, name in ipairs(names) do
    if type(name) == 'string' then
      ---@diagnostic disable-next-line: param-type-mismatch
      local ok, err = pcall(vim.cmd, 'packadd ' .. name)
      if not ok then
        vim.notify('packadd ' .. name .. ' failed: ' .. err, vim.log.levels.WARN,
          { title = "birdee.utils.safe_packadd_list" })
      end
    end
  end
end

---@param plugin_names string[]|string
function M.safe_force_packadd(plugin_names)
  local names
  if type(plugin_names) == 'table' then
    names = plugin_names
  elseif type(plugin_names) == 'string' then
    names = { plugin_names }
  else
    return
  end
  for _, name in ipairs(names) do
    if type(name) == 'string' then
      ---@diagnostic disable-next-line: param-type-mismatch
      local ok, err = pcall(vim.cmd, 'packadd! ' .. name)
      if not ok then
        vim.notify('packadd ' .. name .. ' failed: ' .. err, vim.log.levels.WARN,
          { title = "birdee.utils.safe_force_packadd_list" })
      end
    end
  end
end

---Recieves the names of directories from a plugin's after directory
---that you wish to source files from.
---Will return a load function that can take a name, or list of names,
---and will load a plugin and its after directories.
---The function returned is a suitable substitute for the load field of a plugin spec.
---
---e.g. load_with_after_plugin will load the plugin names it is given, and their after/plugin dir
---
---local load_with_after_plugin = require('lze').make_load_with_after({ 'plugin' })
---load_with_after_plugin('some_plugin')
---@overload fun(dirs: string[]|string): fun(names: string|string[])
---It also optionally recieves a function that should load a plugin and return its path
---for if the plugin is not on the packpath, or return nil to load from the packpath as normal
---@overload fun(dirs: string[]|string, load: fun(name: string):string|nil): fun(names: string|string[])
function M.make_load_with_after(dirs, load)
    dirs = (type(dirs) == "table" and dirs) or { dirs }
    local fromPackpath = function(name)
        for _, packpath in ipairs(vim.opt.packpath:get()) do
            local plugin_path = vim.fn.globpath(packpath, "pack/*/opt/" .. name, nil, true, true)
            if plugin_path[1] then
                return plugin_path[1]
            end
        end
        return nil
    end
    ---@param plugin_names string[]|string
    return function(plugin_names)
        local names
        if type(plugin_names) == "table" then
            names = plugin_names
        elseif type(plugin_names) == "string" then
            names = { plugin_names }
        else
            return
        end
        local to_source = {}
        for _, name in ipairs(names) do
            if type(name) == "string" then
                local path = (type(load) == "function" and load(name)) or nil
                if type(path) == "string" then
                    table.insert(to_source, { name = name, path = path })
                else
                    ---@diagnostic disable-next-line: param-type-mismatch
                    local ok, err = pcall(vim.cmd, "packadd " .. name)
                    if ok then
                        table.insert(to_source, { name = name, path = path })
                    else
                        vim.notify(
                            '"packadd '
                                .. name
                                .. '" failed, and path provided by custom load function (if provided) was not a string\n'
                                .. err,
                            vim.log.levels.WARN,
                            { title = "lze.load_with_after" }
                        )
                    end
                end
            else
                vim.notify(
                    "plugin name was not a string and was instead of value:\n" .. vim.inspect(name),
                    vim.log.levels.WARN,
                    { title = "lze.load_with_after" }
                )
            end
        end
        for _, info in pairs(to_source) do
            local plugpath = info.path or fromPackpath(info.name)
            if type(plugpath) == "string" then
                local afterpath = plugpath .. "/after"
                for _, dir in ipairs(dirs) do
                    if vim.fn.isdirectory(afterpath) == 1 then
                        local plugin_dir = afterpath .. "/" .. dir
                        if vim.fn.isdirectory(plugin_dir) == 1 then
                            local files = vim.fn.glob(plugin_dir .. "/*", false, true)
                            for _, file in ipairs(files) do
                                if vim.fn.filereadable(file) == 1 then
                                    vim.cmd("source " .. file)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

---@param dirs string[]
---@return fun(names: string[]|string)
M.get_new_packadd_func = function(dirs)
  local new_load = function(name)
    local ok, err = pcall(vim.cmd, 'packadd ' .. name)
    if not ok then
      vim.notify('packadd ' .. name .. ' failed: ' .. err, vim.log.levels.WARN,
        { title = "birdee.utils.safe_force_packadd_list" })
    end
    return require("nixCats").pawsible.allPlugins.opt[name]
  end
  return M.make_load_with_after(dirs, new_load)
end

---packadd + after/plugin
---@type fun(names: string[]|string)
M.load_w_after_plugin = M.get_new_packadd_func({ "plugin" })

return M
