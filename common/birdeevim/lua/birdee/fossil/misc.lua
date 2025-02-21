-- TODO: make this into a keybind with operator pending to select text to surround with,
-- like vim-surrounds but for visual selection instead of motion
-- vim.keymap.set({'v', 'x'}, "<leader>s", [[:'<,'>s/\%V\(.*\)\%V/<before-text>\1<after-text>/]], { desc = 'Replace inside selection with text' })


-- dont worry about it.... it saved me some time in the end
if nixCats('notes') then
  vim.keymap.set({ 'v', 'x' }, '<leader>Fp',
    [["ad:let @a = substitute(@a, '\\(favicon-.\\{-}\\)\\(\\.com\\|\\.org\\|\\.net\\|\\.edu\\|\\.gov\\|\\.mil\\|\\.int\\|\\.io\\|\\.co\\|\\.ai\\|\\.ly\\|\\.me\\|\\.tv\\|\\.info\\|\\.co\\.uk\\|\\.de\\|\\.jp\\|\\.cn\\|\\.au\\|\\.fr\\|\\.it\\|\\.es\\|\\.br\\|\\.gay\\)', 'https:\/\/', 'g')<CR>dd:while substitute(@a, '\\(https:\\/\\/.\\{-}\\) > ', '\\1\/', 'g') != @a | let @a = substitute(@a, '\\(https:\\/\\/.\\{-}\\) > ', '\\1\/', 'g') | endwhile<CR>"ap]],
    { desc = 'fix the links in copies from phind' })
end
