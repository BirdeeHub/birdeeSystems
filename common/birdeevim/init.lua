-- print(debug.getinfo(1, "S").source:sub(2))

local myRequire = require('birdee.lazyutils').lazy_packadd_require
require('_G').require = myRequire

if vim.g.vscode == nil then
  require("birdee")
else
  -- a stripped down version for embedding
  require('vscody')
end
