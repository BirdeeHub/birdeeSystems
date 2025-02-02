return {
  {
    "snacks.nvim",
    lazy = false,
    after = function(_)
      require('snacks').setup({
        bigfile = { enabled = true, },
        dashboard = { enabled = false, },
        git = { enabled = true, },
        indent = { enabled = false, },
        input = { enabled = false, },
        picker = { enabled = true, },
        notifier = { enabled = false, },
        quickfile = { enabled = true, },
        scroll = { enabled = false, },
        statuscolumn = { enabled = false, },
        words = { enabled = false, },
        lazygit = { enabled = true, },
      })
      vim.keymap.set('n', '<leader>t', function() Snacks.terminal() end, { desc = 'open snacks terminal' })
      vim.keymap.set({"n"},"<leader>_", function() Snacks.lazygit.open() end, { desc = 'LazyGit' })
    end,
  }
}
