
-- kickstart.nvim starts you with this. 
-- But it constantly clobbers your system clipboard whenever you delete anything.

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.o.clipboard = 'unnamedplus'

-- So, meet clippy.lua

vim.keymap.set("n", '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to clipboard' })
vim.keymap.set({"v", "x"}, '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to clipboard' })
vim.keymap.set({"n", "v", "x"}, '<leader>yy', '"+yy', { noremap = true, silent = true, desc = 'Yank line to clipboard' })
vim.keymap.set({"n", "v", "x"}, '<leader>Y', '"+yy', { noremap = true, silent = true, desc = 'Yank line to clipboard' })
vim.keymap.set({"n", "v", "x"}, '<C-a>', 'gg0vG$', { noremap = true, silent = true, desc = 'Select all' })
vim.keymap.set({"n", "v", "x"}, '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste from clipboard' })
vim.keymap.set('i', '<C-p>', '<C-r><C-p>+', { noremap = true, silent = true, desc = 'Paste from clipboard from within insert mode' })

-- this is now included in visual mode by default as P keybind
-- vim.keymap.set("x", "<leader>P", '"_dP', { noremap = true, silent = true, desc = 'Paste over selection without erasing unnamed register' })


-- so, my normal mode <leader>y randomly didnt accept motions. 
-- If that ever happens to you, comment out the normal one for normal mode, then uncomment this keymap and the function below it.
-- A full purge of all previous config files installed via pacman fixed it for me, as the pacman config was the one that had that problem.
-- I thought I was cool, but apparently I was doing a workaround to restore default behavior.


-- a collection of mappings to allow you to yank to clipboard using <leader>y
-- as well as a few nice paste options, and ctrl+a
-- in normal mode, it accepts motions as well.
-- vim.keymap.set("n", '<leader>y', [[:set opfunc=Yank_to_clipboard<CR>g@]], { silent = true, desc = 'Yank to clipboard (accepts motions)' })
-- vim.cmd([[
--   function! Yank_to_clipboard(type)
--     silent exec 'normal! `[v`]"+y'
--     silent exec 'let @/=@"'
--   endfunction
--   " nmap <silent> <leader>y :set opfunc=Yank_to_clipboard<CR>g@
-- ]])
