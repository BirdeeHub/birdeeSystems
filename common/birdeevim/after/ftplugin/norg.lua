if nixCats('otter') then
  vim.schedule(function ()
    require('otter').activate(nil, true, true, nil)
  end)
end
