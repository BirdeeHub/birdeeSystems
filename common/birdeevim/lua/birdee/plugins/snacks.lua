
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
  -- quickfile = { enabled = true, },
  -- input = { enabled = true, },
  -- scratch = { enabled = true, },
  -- layout = { enabled = true, },
  -- zen = { enabled = true, },
  -- scroll = { enabled = true, },
  -- notifier = { enabled = true, },
  -- notify = { enabled = true, },
  -- win = { enabled = true, },
  -- picker = { enabled = true, },
  -- profiler = { enabled = true, },
  -- toggle = { enabled = true, },
  -- rename = { enabled = true, },
  -- words = { enabled = true, },

  gitbrowse = { enabled = true, },
  lazygit = { enabled = true, },
  bigfile = { enabled = true, },
  git = { enabled = true, },
  terminal = { enabled = true, },
  scope = { enabled = true, },
  indent = {
    enabled = true,
    scope = {
      hl = 'Hlargs',
    },
    chunk = {
      enabled = true,
      hl = 'Hlargs',
    }
  },
  statuscolumn = {
    left = { "mark", "git" }, -- priority of signs on the left (high to low)
    right = { "fold", "sign" }, -- priority of signs on the right (high to low)
    folds = {
      open = false, -- show open fold icons
      git_hl = false, -- use Git Signs hl for fold icons
    },
    git = {
      -- patterns to match Git signs
      patterns = { "GitSign", "MiniDiffSign" },
    },
    refresh = 50, -- refresh at most every 50ms
  },
})
vim.keymap.set({'n'}, '<c-\\>', function() Snacks.terminal() end, { desc = 'open snacks terminal' })
vim.keymap.set({"n"},"<leader>_", function() Snacks.lazygit.open() end, { desc = 'LazyGit' })
vim.keymap.set({"n"},"<leader>gc", function() Snacks.lazygit.log() end, { desc = 'Lazy[G]it [C]ommit log' })
vim.keymap.set({"n"},"<leader>gl", function() Snacks.gitbrowse.open() end, { desc = '[G]oto git [L]ink' })
