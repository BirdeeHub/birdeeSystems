if vim.g.vscode ~= nil and nixCats('otter') then
  -- currently disabled because I found it annoying with all the bash errors
  vim.schedule(function ()
    require('otter').activate(nil, true, true, nil)
  end)
end
