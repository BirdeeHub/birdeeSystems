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
require('lze').load {
  { import = "birdee.plugins" },
  { import = "birdee.LSPs" },
  { import = "birdee.debug", enabled = nixCats('debug') },
  { import = "birdee.format" },
  { import = "birdee.lint" },
}
