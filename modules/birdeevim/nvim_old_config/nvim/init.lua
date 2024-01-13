-- vim.g.configs = "~/.config/nvimflakes"

if vim.g.vscode == nil then
  require("birdee")
else
  -- just in case I need to show someone something in vscode idk
  require('vscody')
end
  
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
