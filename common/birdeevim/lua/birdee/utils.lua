local M = {}
function M.deleteFileIfExists(file_path)
  if vim.fn.filereadable(file_path) == 1 then
    os.remove(file_path)
  end
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

return M
