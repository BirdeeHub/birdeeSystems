if vim.g.vscode == nil then
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
  require('lze').register_handlers({
    {
      enabled = true,
      handler = require("nixCatsUtils.lzUtils").for_cat
    },
  })
end

require("birdee.patcheduiopen")
require("birdee.opts")
require("birdee.keymaps")
require("birdee.clippy")

if vim.g.vscode == nil then
  -- TODO: this in another file and require here.
  -- require('nixCatsUtils.catPacker').setup({ your plugins })
  require("birdee.plugins")
  require("birdee.LSPs")
  if nixCats('debug') then
    require("birdee.debug")
  end
  require("birdee.format")
  require("birdee.lint")
end
