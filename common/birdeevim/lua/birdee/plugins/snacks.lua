-- NOTE: this plugin is "loaded" at startup,
-- but we delay the main setup call until later.
-- also we still need to require bigfile from the main one
-- because it tries to index the Snacks global unsafely...

-- also shut up I dont care
---@diagnostic disable-next-line: invisible
require('snacks').bigfile.setup()
---@diagnostic disable-next-line: duplicate-set-field
vim.notify = function(msg, level, o)
  vim.notify = Snacks.notifier.notify
  return Snacks.notifier.notify(msg, level, o)
end
vim.keymap.set({ 'n' }, '<Esc>', function() Snacks.notifier.hide() end, { desc = 'dismiss notify popup' })

return {
  {
    "snacks.nvim",
    for_cat = "general",
    keys = {
      {'<c-\\>', function() Snacks.terminal() end, mode = {'n'}, desc = 'open snacks terminal' },
      {"<leader>_", function() Snacks.lazygit.open() end, mode = {"n"}, desc = 'LazyGit' },
      {"<leader>gc", function() Snacks.lazygit.log() end, mode = {"n"}, desc = 'Lazy[G]it [C]ommit log' },
      {"<leader>gl", function() Snacks.gitbrowse.open() end, mode = {"n"}, desc = '[G]oto git [L]ink' },
      {"<leader>sM", function() Snacks.notifier.show_history() end, mode = {"n"}, desc = '[S]earch [M]essages' },
    },
    event = { 'DeferredUIEnter' },
    after = function(_)
      -- NOTE: It is faster when you comment them out
      -- rather than disabling them.
      -- for some reason, they are still required
      -- when you do { enabled = false }
      Snacks.setup({
        -- dashboard = {},
        -- debug = {},
        -- bufdelete = {},
        -- dim = {},
        -- explorer = {},
        -- quickfile = {},
        -- bigfile = {},
        -- input = {},
        -- scratch = {},
        -- layout = {},
        -- zen = {},
        -- scroll = {},
        -- notifier = {},
        -- notify = {},
        -- win = {},
        -- picker = {},
        -- profiler = {},
        -- toggle = {},
        -- rename = {},
        -- words = {},

        gitbrowse = {},
        lazygit = {},
        git = {},
        terminal = {},
        scope = {},
        indent = {
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
          right = { "sign", "fold" }, -- priority of signs on the right (high to low)
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
