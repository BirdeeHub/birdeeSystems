-- TODO: make this into a keybind with operator pending to select text to surround with,
-- like vim-surrounds but for visual selection instead of motion
vim.keymap.set({'v', 'x'}, "<leader>s", [[:'<,'>s/\%V\(.*\)\%V/<before-text>\1<after-text>/]], { desc = 'Replace inside selection with text' })
