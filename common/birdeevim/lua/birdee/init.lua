require('nixCatsUtils').setup {
  nin_nix_value = true,
}
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
require('nixCatsUtils.catPacker')
if nixCats('nixCats_packageName') ~= "minimalVim" then
  require("birdee.plugins")
  require("birdee.LSPs")
  if nixCats('debug') then
    require("birdee.debug")
  end
  require("birdee.format")
end
require("birdee.keymaps")
require("birdee.clippy")
require("birdee.opts")
