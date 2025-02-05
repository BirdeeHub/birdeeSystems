---@diagnostic disable-next-line: duplicate-set-field
vim.ui.open = function(path)
  vim.validate({
	path = { path, 'string' },
  })
  local is_uri = path:match('%w+:')
  local is_half_url = path:match('%.com$') or path:match('%.com%.')
  local is_repo = vim.bo.filetype == 'lua' and path:match('%w/%w') and vim.fn.count(path, '/') == 1
  local is_dir = path:match('/%w')
  if not is_uri then
    if is_half_url then
      path = ('https://%s'):format(path)
    elseif is_repo then
      path = ('https://github.com/%s'):format(path)
    elseif not is_dir then
      path = ('https://google.com/search?q=%s'):format(path)
    else
      path = vim.fs.normalize(path)
    end
  end

  local cmd --- @type string[]

  if vim.fn.has('mac') == 1 then
    cmd = { 'open', path }
  elseif vim.fn.has('win32') == 1 then
    if vim.fn.executable('rundll32') == 1 then
      cmd = { 'rundll32', 'url.dll,FileProtocolHandler', path }
    else
      return nil, 'vim.ui.open: rundll32 not found'
    end
  elseif vim.fn.executable('wslview') == 1 then
    cmd = { 'wslview', path }
  elseif vim.fn.executable('explorer.exe') == 1 then
    cmd = { 'explorer.exe', path }
  elseif vim.fn.executable('xdg-open') == 1 then
    cmd = { 'xdg-open', path }
  else
    return nil, 'vim.ui.open: no handler found (tried: wslview, explorer.exe, xdg-open)'
  end

  return vim.system(cmd, { text = true, detach = true }), nil
end
