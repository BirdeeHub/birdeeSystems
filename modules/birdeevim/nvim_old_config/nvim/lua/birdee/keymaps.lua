-- non plugin/lsp setup keymaps
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = 'Moves Line Down' })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = 'Moves Line Up' })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = 'Scroll Down' })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = 'Scroll Up' })
vim.keymap.set("n", "n", "nzzzv", { desc = 'Next Search Result' })
vim.keymap.set("n", "N", "Nzzzv", { desc = 'Previous Search Result' })
vim.keymap.set('n', '<leader>hh', [[:lua require("harpoon.ui").toggle_quick_menu()<CR>]], { noremap = true, silent = true, desc = 'open harpoon menu' })
vim.keymap.set('n', '<leader>hm', [[:lua require("harpoon.mark").add_file()<CR>]], { noremap = true, silent = true, desc = 'add file to harpoon' })
vim.keymap.set('n', '<leader>hb', [[:lua require("harpoon.ui").nav_prev()<CR>]], { noremap = true, silent = true, desc = 'open prev harpoon' })
vim.keymap.set('n', '<leader>hn', [[:lua require("harpoon.ui").nav_next()<CR>]], { noremap = true, silent = true, desc = 'open next harpoon' })
vim.keymap.set({"n", "v", "x"}, '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to clipboard' })
vim.keymap.set({"n", "v", "x"}, '<leader>yy', '"+yy', { noremap = true, silent = true, desc = 'Yank line to clipboard' })
vim.keymap.set('n', '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste from clipboard' })
vim.keymap.set("x", "<leader>P", '"_dP', { desc = 'Paste from Selection' })
vim.cmd([[command! W w]])
vim.cmd([[command! Wq wq]])
vim.cmd([[command! WQ wq]])
vim.cmd([[command! Q q]])

-- vim.keymap.set("n", "<leader>Fc", require('conform').format, { noremap = true, desc = '[F]ormat ([c]onform.nvim)' })
vim.keymap.set("n", "<leader>Fm", "<cmd>Format<CR>", { noremap = true, desc = '[F]or[m]at' })
vim.keymap.set("n", "<leader>FF", "<cmd>E<CR>", { noremap = true, desc = '[F]ile[F]inder' })
vim.keymap.set("n", "<leader>Fh", "<cmd>e .<CR>", { noremap = true, desc = '[F]ile[h]ome' })
vim.keymap.set("n", "<leader>FT", "<cmd>Neotree toggle<CR>", { noremap = true, desc = '[F]ile [T]ree' })

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<C-W>', '<c-w>', { desc = '+window'})
vim.keymap.set({"n", "v", "x"}, '"', '"', { desc = '+registers'})

vim.keymap.set('n', '<leader>hg', require('telescope.builtin').git_files, { desc = 'Searc[h] [g]it' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]resume' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })


vim.keymap.set({'v', 'x'}, '<leader>Fp', [["ad:let @a = substitute(@a, '\\(favicon-.\\{-}\\)\\(\\.com\\|\\.org\\|\\.net\\|\\.edu\\|\\.gov\\|\\.mil\\|\\.int\\|\\.io\\|\\.co\\|\\.ai\\|\\.ly\\|\\.me\\|\\.tv\\|\\.info\\|\\.co\\.uk\\|\\.de\\|\\.jp\\|\\.cn\\|\\.au\\|\\.fr\\|\\.it\\|\\.es\\|\\.br\\|\\.gay\\)', 'https:\/\/', 'g')<CR>dd:while substitute(@a, '\\(https:\\/\\/.\\{-}\\) > ', '\\1\/', 'g') != @a | let @a = substitute(@a, '\\(https:\\/\\/.\\{-}\\) > ', '\\1\/', 'g') | endwhile<CR>"ap]], { desc = 'fix the links in copies from phind' })

vim.keymap.set('n', '<leader>ss', require('sg.extensions.telescope').fuzzy_search_results, { noremap = true, desc = 'sourcegraph search' })
vim.keymap.set('n', '<leader>sc', [[<cmd>CodyToggle<CR>]], { noremap = true, desc = 'CodyChat' })
vim.keymap.set('v', '<leader>sc', [[:CodyAsk ]], { noremap = true, desc = 'CodyAsk' })
