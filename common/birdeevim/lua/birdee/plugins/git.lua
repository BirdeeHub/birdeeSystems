-- vim.cmd("packadd fugit2-nvim")
require('fugit2').setup({})

vim.keymap.set("n", "<leader>_", "<cmd>Fugit2<CR>", { noremap = true, desc = 'Fugit2' })
