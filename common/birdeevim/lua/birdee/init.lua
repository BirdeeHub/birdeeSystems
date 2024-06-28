require('nixCatsUtils').setup {
  nin_nix_value = true,
}
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- require('lz.n').register_handler(require("birdee.debug_handler").handler)
vim.notify = require("notify")
require('lz.n').register_handler(require("birdee.on_require"))
require("lz.n").load({"plenary.nvim", on_require = {"plenary", "luassert", "say"}})
require("birdee.opts")
require("birdee.keymaps")
require("birdee.clippy")
if nixCats('nixCats_packageName') ~= "minimalVim" then
  require('nixCatsUtils.catPacker')
  require("birdee.plugins")
  require("birdee.LSPs")
  if nixCats('debug') then
    require("birdee.debug")
  end
  require("birdee.format")
  require("birdee.lint")
end
