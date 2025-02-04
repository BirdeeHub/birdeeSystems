require('snacks').setup({
  dashboard = { enabled = false, },
  debug = { enabled = false, },
  bufdelete = { enabled = false, },
  dim = { enabled = false, },
  explorer = { enabled = false, },
  input = { enabled = false, },
  profiler = { enabled = false, },
  scratch = { enabled = false, },
  layout = { enabled = false, },
  zen = { enabled = false, },
  scroll = { enabled = false, },

  notifier = { enabled = false, },
  notify = { enabled = false, },
  scope = { enable = false, },
  indent = { enabled = false, },
  statuscolumn = { enabled = false, },
  win = { enabled = false, },
  toggle = { enabled = false, },
  picker = { enabled = false, },
  words = { enabled = false, },
  rename = { enabled = false, },

  gitbrowse = { enabled = true, },
  quickfile = { enabled = true, },
  lazygit = { enabled = true, },
  bigfile = { enabled = true, },
  git = { enabled = true, },
  terminal = { enabled = true, },
})
vim.keymap.set({'n'}, '<c-\\>', function() Snacks.terminal() end, { desc = 'open snacks terminal' })
vim.keymap.set({"n"},"<leader>_", function() Snacks.lazygit.open() end, { desc = 'LazyGit' })
vim.keymap.set({"n"},"<leader>gc", function() Snacks.lazygit.log() end, { desc = 'Lazy[G]it [C]ommit log' })
vim.keymap.set({"n"},"<leader>gl", function() Snacks.gitbrowse.open() end, { desc = '[G]oto git [L]ink' })
