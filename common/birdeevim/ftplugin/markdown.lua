vim.opt.conceallevel = 2
if nixCats('otter') then
  require('otter').activate(nil, true, true, nil)
end
