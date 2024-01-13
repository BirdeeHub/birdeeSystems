local M
if vim.g.vscode == nil then
  M = require('cap-onattach.birdee')
else
  M = require('cap-onattach.vscody')
end
return M
