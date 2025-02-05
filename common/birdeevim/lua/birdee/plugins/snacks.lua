-- NOTE: this plugin is "loaded" at startup,
-- but we delay the main setup call until later.
-- also we still need to require bigfile from the main one
-- because it tries to index the Snacks global unsafely...

-- also shut up I dont care
---@diagnostic disable-next-line: invisible
require('snacks').bigfile.setup()

return {
  {
    "snacks.nvim",
    keys = {
      {'<c-\\>', function() Snacks.terminal() end, mode = {'n'}, desc = 'open snacks terminal' },
      {"<leader>_", function() Snacks.lazygit.open() end, mode = {"n"}, desc = 'LazyGit' },
      {"<leader>gc", function() Snacks.lazygit.log() end, mode = {"n"}, desc = 'Lazy[G]it [C]ommit log' },
      {"<leader>gl", function() Snacks.gitbrowse.open() end, mode = {"n"}, desc = '[G]oto git [L]ink' },
    },
    event = { 'DeferredUIEnter' },
    after = function(_)
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
        -- bigfile = { enabled = true, },
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
        git = { enabled = true, },
        terminal = { enabled = true, },
        scope = { enabled = true, },
        indent = {
          enabled = true,
          scope = {
            hl = 'Hlargs',
          },
          chunk = {
            -- enabled = true,
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
    end,
  }
}
