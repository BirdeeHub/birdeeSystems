-- local ok, notify = pcall(require, "notify")
-- if ok then
--   notify.setup({
--     on_open = function(win)
--       vim.api.nvim_win_set_config(win, { focusable = false })
--     end,
--   })
--   vim.notify = notify
--   vim.keymap.set("n", "<Esc>", function()
--       notify.dismiss({ silent = true, })
--   end, { desc = "dismiss notify popup and clear hlsearch" })
-- end
-- vim.g.lze = {
--   load = vim.cmd.packadd,
--   verbose = true,
-- }
-- TODO: this in another file and require here.
-- require('nixCatsUtils.catPacker').setup({ your plugins })
require("birdee.plugins")
require("birdee.LSPs")
if nixCats('debug') then
  require("birdee.debug")
end
require("birdee.format")
require("birdee.lint")
