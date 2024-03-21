-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = 'Moves Line Down' })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = 'Moves Line Up' })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = 'Scroll Down' })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = 'Scroll Up' })
vim.keymap.set("n", "n", "nzzzv", { desc = 'Next Search Result' })
vim.keymap.set("n", "N", "Nzzzv", { desc = 'Previous Search Result' })
require('vscody.clippy')

-- see help sticky keys on windows
vim.cmd([[command! W w]])
vim.cmd([[command! Wq wq]])
vim.cmd([[command! WQ wq]])
vim.cmd([[command! Q q]])

-- opposite of A
vim.keymap.set('n', 'B', '^i', { noremap = true, silent = true, desc = 'edit at beginning of line' })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Netrw
vim.keymap.set("n", "<leader>FF", "<cmd>Explore<CR>", { noremap = true, desc = '[F]ile[F]inder' })
vim.keymap.set("n", "<leader>Fh", "<cmd>e .<CR>", { noremap = true, desc = '[F]ile[h]ome' })


-- dont worry about it.... it saved me some time in the end
vim.keymap.set({ 'v', 'x' }, '<leader>Fp',
  [["ad:let @a = substitute(@a, '\\(favicon-.\\{-}\\)\\(\\.com\\|\\.org\\|\\.net\\|\\.edu\\|\\.gov\\|\\.mil\\|\\.int\\|\\.io\\|\\.co\\|\\.ai\\|\\.ly\\|\\.me\\|\\.tv\\|\\.info\\|\\.co\\.uk\\|\\.de\\|\\.jp\\|\\.cn\\|\\.au\\|\\.fr\\|\\.it\\|\\.es\\|\\.br\\|\\.gay\\)', 'https:\/\/', 'g')<CR>dd:while substitute(@a, '\\(https:\\/\\/.\\{-}\\) > ', '\\1\/', 'g') != @a | let @a = substitute(@a, '\\(https:\\/\\/.\\{-}\\) > ', '\\1\/', 'g') | endwhile<CR>"ap]],
  { desc = 'fix the links in copies from phind' })





-- [[ Setting options ]]
-- See `:help vim.o`
vim.opt.list = true
vim.opt.listchars:append("space:⋅")
-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Indent
vim.o.smarttab = true
-- vim.o.smartindent = true
-- vim.o.indentexpr = true
vim.o.autoindent = true
vim.o.cpoptions = 'I'
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'
vim.wo.relativenumber = true

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menu,preview,noselect'

-- [[ Disable auto comment on enter ]]
-- See :help formatoptions
vim.api.nvim_create_autocmd("FileType", {
  desc = "remove formatoptions",
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
