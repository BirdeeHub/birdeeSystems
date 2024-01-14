local M
if vim.g.vscode == nil then
  M = require('birdee.caps-onattach')
else
  M = require('vscody.caps-onattach')
end
return M
