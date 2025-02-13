-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.api.nvim_set_keymap('', '<M-h>', '<Esc>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<M-h>', '<C-\\><C-n>', { noremap = true, silent = true, desc = "escape terminal mode" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = 'Moves Line Down' })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = 'Moves Line Up' })
-- vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = 'Scroll Down' })
-- vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = 'Scroll Up' })
vim.keymap.set("n", "n", "nzzzv", { desc = 'Next Search Result' })
vim.keymap.set("n", "N", "Nzzzv", { desc = 'Previous Search Result' })

vim.keymap.set("n", "<leader><leader>[", "<cmd>bprev<CR>", { desc = 'Previous buffer' })
vim.keymap.set("n", "<leader><leader>]", "<cmd>bnext<CR>", { desc = 'Next buffer' })
vim.keymap.set("n", "<leader><leader>l", "<cmd>b#<CR>", { desc = 'Last buffer' })
vim.keymap.set("n", "<leader><leader>d", "<cmd>bdelete<CR>", { desc = 'delete buffer' })

-- see help sticky keys on windows
vim.cmd([[command! W w]])
vim.cmd([[command! Wq wq]])
vim.cmd([[command! WQ wq]])
vim.cmd([[command! Q q]])

vim.keymap.set("n", "<leader>:", ":<C-f>", { desc = 'delete buffer' })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Netrw
-- vim.keymap.set("n", "<leader>FF", "<cmd>Explore<CR>", { noremap = true, desc = '[F]ile[F]inder' })
-- vim.keymap.set("n", "<leader>Fh", "<cmd>e .<CR>", { noremap = true, desc = '[F]ile[h]ome' })

-- Diagnostic keymaps
-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' }) -- now included by default
-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' }) -- now included by default
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })


vim.keymap.set('n', '<leader>lh', function () vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, { desc = 'Toggle inlay hints' })

vim.keymap.set('n', '<leader><leader>g', function()
  local count = vim.v.count
  if count > 0 then
    vim.cmd('buffer ' .. count)
  else
    print("No buffer number provided")
  end
end, { noremap = true, silent = true, desc = 'Go to buffer by number [num]<keybind>', })

--TODO: get this to ask you your sudo password
vim.api.nvim_create_user_command('Swq', function(args)
    vim.cmd([[w !sudo tee %]])
end, {})

-- these 3 jankily fix which-key related errors for some reason
-- I disabled them via which-key options now.
-- vim.keymap.set('n', '<C-W>', '<c-w>', { desc = '+window'})
-- vim.keymap.set({"n", "v", "x"}, '"', '"', { desc = '+registers'})
-- vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- dont worry about it.... it saved me some time in the end
if nixCats('notes') then
  vim.keymap.set({ 'v', 'x' }, '<leader>Fp',
    [["ad:let @a = substitute(@a, '\\(favicon-.\\{-}\\)\\(\\.com\\|\\.org\\|\\.net\\|\\.edu\\|\\.gov\\|\\.mil\\|\\.int\\|\\.io\\|\\.co\\|\\.ai\\|\\.ly\\|\\.me\\|\\.tv\\|\\.info\\|\\.co\\.uk\\|\\.de\\|\\.jp\\|\\.cn\\|\\.au\\|\\.fr\\|\\.it\\|\\.es\\|\\.br\\|\\.gay\\)', 'https:\/\/', 'g')<CR>dd:while substitute(@a, '\\(https:\\/\\/.\\{-}\\) > ', '\\1\/', 'g') != @a | let @a = substitute(@a, '\\(https:\\/\\/.\\{-}\\) > ', '\\1\/', 'g') | endwhile<CR>"ap]],
    { desc = 'fix the links in copies from phind' })
end
