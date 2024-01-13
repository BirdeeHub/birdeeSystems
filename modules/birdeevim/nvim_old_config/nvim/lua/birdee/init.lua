-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
require("birdee.plugins")
require("birdee.LSPs")
require("birdee.config")
require("birdee.keymaps")
