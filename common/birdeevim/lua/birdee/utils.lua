local M = {}
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

function M.get_os_command_output(cmd, cwd)
  if type(cmd) ~= "table" then
    print("[get_os_command_output]: cmd has to be a table")
    return {}
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
      local ok, err = pcall(vim.cmd, 'packadd ' .. name)
      if not ok then
        vim.notify('packadd ' .. name .. ' failed: ' .. err, vim.log.levels.WARN, { title = "birdee.utils.safe_packadd_list" })
      end
    end
  end
end

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
      local ok, err = pcall(vim.cmd, 'packadd! ' .. name)
      if not ok then
        vim.notify('packadd ' .. name .. ' failed: ' .. err, vim.log.levels.WARN, { title = "birdee.utils.safe_force_packadd_list" })
      end
    end
  end
end

function M.packadd_with_after_dirs(plugin_names)
  local names
  if type(plugin_names) == 'table' then
    names = plugin_names
  elseif type(plugin_names) == 'string' then
    names = { plugin_names }
  else
    return
  end
  local to_source = {}
  for _, name in ipairs(names) do
    if type(name) == 'string' then
      local ok, err = pcall(vim.cmd, 'packadd ' .. name)
      if not ok then
        vim.notify('packadd ' .. name .. ' failed: ' .. err, vim.log.levels.WARN, { title = "birdee.utils.safe_packadd_list" })
      else
        table.insert(to_source, name)
      end
    end
  end
  for _, name in pairs(to_source) do
    local afterpath = require('nixCats').pawsible.allPlugins.opt[name] .. "/after"
    if vim.fn.isdirectory(afterpath) == 1 then
      local plugin_dir = afterpath .. "/plugin"
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

function M.starts_with(str, prefix)
  if str == nil or prefix == nil then
    return false
  end
  return string.sub(str, 1, string.len(prefix)) == prefix
end

return M
