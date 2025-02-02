return {
  {
    "snacks.nvim",
    lazy = false,
    after = function(_)
      require('snacks').setup({
        dashboard = { enabled = false, },
        gitbrowse = { enabled = false, },
        indent = { enabled = false, },
        debug = { enabled = false, },
        bufdelete = { enabled = false, },
        dim = { enabled = false, },
        explorer = { enabled = false, },
        input = { enabled = false, },
        notifier = { enabled = false, },
        notify = { enabled = false, },
        profiler = { enabled = false, },
        scratch = { enabled = false, },
        layout = { enabled = false, },
        win = { enabled = false, },
        toggle = { enabled = false, },
        zen = { enabled = false, },
        scope = { enable = false, },
        rename = { enabled = false, },
        scroll = { enabled = false, },
        statuscolumn = { enabled = false, },
        words = { enabled = false, },
        quickfile = { enabled = true, },
        lazygit = { enabled = true, },
        picker = { enabled = true, },
        bigfile = { enabled = true, },
        git = { enabled = true, },
        terminal = { enabled = true, },
      })
      vim.keymap.set('n', '<c-\\>', function() Snacks.terminal() end, { desc = 'open snacks terminal' })
      vim.keymap.set({"n"},"<leader>_", function() Snacks.lazygit.open() end, { desc = 'LazyGit' })
    end,
  }
}
