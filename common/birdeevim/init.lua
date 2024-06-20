-- print(debug.getinfo(1, "S").source:sub(2))
-- local oldrequire = require
-- require('_G').require = function(mod)
--   local ok, value = pcall(oldrequire, mod)
--   if ok then
--     return value
--   end
--   -- search specs for something to packadd
--   return require(mod)
-- end
if vim.g.vscode == nil then
  require("birdee")
else
  -- a stripped down version for embedding
  require('vscody')
end
