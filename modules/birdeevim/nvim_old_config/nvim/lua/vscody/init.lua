-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
require("vscody.plugins")
-- require("vscody.LSPs")
require("vscody.config")
require("vscody.keymaps")
