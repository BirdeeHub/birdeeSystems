require('nixCatsUtils').setup {
  non_nix_value = true,
}
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
local ok, notify = pcall(require, "notify")
if ok then
  notify.setup({
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { focusable = false })
    end,
  })
  vim.notify = notify
  vim.keymap.set("n", "<Esc>", function()
      notify.dismiss({ silent = true, })
  end, { desc = "dismiss notify popup and clear hlsearch" })
end
vim.g.lze = {
  load = require('birdee.utils').safe_packadd,
}
require("lze").register_handlers(require('lze.x'))
require('lze').register_handlers({
  {
    enabled = false,
    handler = require("birdee.handlers.debug_handler").handler
  },
  {
    enabled = true,
    handler = require("birdee.handlers.for_cat")
  },
})
require("birdee.patcheduiopen")
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
