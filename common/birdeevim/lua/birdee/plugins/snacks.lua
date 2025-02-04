
-- NOTE: It is faster when you comment them out
-- rather than disabling them.
-- for some reason, they are still required
-- when you do { enabled = false }
require('snacks').setup({
  -- dashboard = { enabled = true, },
  -- debug = { enabled = true, },
  -- bufdelete = { enabled = true, },
  -- dim = { enabled = true, },
  -- explorer = { enabled = true, },
  -- input = { enabled = true, },
  -- scratch = { enabled = true, },
  -- layout = { enabled = true, },
  -- zen = { enabled = true, },
  -- scroll = { enabled = true, },
  -- quickfile = { enabled = true, },

  -- profiler = { enabled = true, },
  -- notifier = { enabled = true, },
  -- notify = { enabled = true, },
  -- scope = { enable = true, },
  -- indent = { enabled = true, },
  -- statuscolumn = { enabled = true, },
  -- win = { enabled = true, },
  -- toggle = { enabled = true, },
  -- picker = { enabled = true, },
  -- words = { enabled = true, },
  -- rename = { enabled = true, },

  gitbrowse = { enabled = true, },
  lazygit = { enabled = true, },
  bigfile = { enabled = true, },
  git = { enabled = true, },
  terminal = { enabled = true, },
})
vim.keymap.set({'n'}, '<c-\\>', function() Snacks.terminal() end, { desc = 'open snacks terminal' })
vim.keymap.set({"n"},"<leader>_", function() Snacks.lazygit.open() end, { desc = 'LazyGit' })
vim.keymap.set({"n"},"<leader>gc", function() Snacks.lazygit.log() end, { desc = 'Lazy[G]it [C]ommit log' })
vim.keymap.set({"n"},"<leader>gl", function() Snacks.gitbrowse.open() end, { desc = '[G]oto git [L]ink' })
