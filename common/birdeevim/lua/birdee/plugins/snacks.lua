return {
  {
    "snacks.nvim",
    lazy = false,
    after = function(_)
      require('snacks').setup({
        bigfile = { enabled = true, },
        dashboard = { enabled = false, },
        indent = { enabled = false, },
        input = { enabled = false, },
        picker = { enabled = true, },
        notifier = { enabled = false, },
        quickfile = { enabled = false, },
        scroll = { enabled = false, },
        statuscolumn = { enabled = false, },
        words = { enabled = false, },
        lazygit = { enabled = true, },
      })
    end,
    vim.keymap.set({"n"},"<leader>_", function() Snacks.lazygit.open() end, { desc = 'LazyGit' })
  }
}
