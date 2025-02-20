vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
require('nixCatsUtils').setup { non_nix_value = true }
if vim.g.vscode == nil then
  _G.lze = require('lze')
  lze.register_handlers {
      require("nixCatsUtils.lzUtils").for_cat,
      require('lzextras').lsp,
  }
  require('birdee')
end
