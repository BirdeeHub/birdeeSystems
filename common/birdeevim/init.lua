vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
require('nixCatsUtils').setup { non_nix_value = true }
if vim.g.vscode == nil then
  -- TODO: this in another file and require here.
  -- require('birdee.non_nix_download').setup({ your plugins })
  require('lze').register_handlers {
      require("nixCatsUtils.lzUtils").for_cat,
      require('lzextras').lsp,
  }
  require('birdee')
end
