return {
  {
    "grapple.nvim",
    for_cat = "other",
    -- cmd = { "" },
    event = "DeferredUIEnter",
    dep_of = { "lualine.nvim" },
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function (_)
      local function grapple_default_select(path)
        if vim.startswith(path, "oil://") then
          require("oil").open(path)
        elseif vim.startswith(path, "https://") then
          vim.ui.open(path)
        elseif vim.startswith(path, "tmux://") then
          -- remove tmux:// prefix
          local name = string.sub(path, 8)
          -- if integer, will go to window id, otherwise, you may put any valid tmux pane identifier such as tmux://{right-of}
          require("birdee.fossil.tmux").grapple_tmux(name)
        else
          vim.cmd.edit(path)
        end
      end

      require("grapple").setup({
        command = grapple_default_select,
      })

      local function grapple_select(index)
        -- Select based on URI "scheme"
        require("grapple").select({
          index = index,
          -- command = grapple_default_select,
        })
      end
      vim.keymap.set("n", "<leader>ha", function() require("grapple").tag({ path = vim.fn.expand("%:p") }) end,
        { noremap = true, silent = true, desc = 'grapple append' })
      vim.keymap.set("n", "<leader>hr", function() require("grapple").untag({ path = vim.fn.expand("%:p") }) end,
        { noremap = true, silent = true, desc = 'grapple remove' })
      vim.keymap.set("n", "<leader>ht", function() require("grapple").toggle() end,
        { noremap = true, silent = true, desc = 'grapple toggle' })
      vim.keymap.set("n", "<leader>hm", [[<cmd>Grapple open_tags<CR>]],
        { noremap = true, silent = true, desc = 'open grapple tags menu' })
      vim.keymap.set("n", "<leader>hs", [[<cmd>Grapple open_scopes<CR>]],
        { noremap = true, silent = true, desc = 'open grapple scopes menu' })
      vim.keymap.set("n", "<leader>hl", [[<cmd>Grapple open_loaded<CR>]],
        { noremap = true, silent = true, desc = 'open grapple loaded scopes menu' })
      vim.keymap.set("n", "<leader>hc", [[<cmd>Grapple cycle forward<CR>]],
        { noremap = true, silent = true, desc = 'open grapple loaded scopes menu' })
      vim.keymap.set("n", "<M-1>", function() grapple_select(1) end,
        { noremap = true, silent = true, desc = "Grapple Select index 1" })
      vim.keymap.set("n", "<M-2>", function() grapple_select(2) end,
        { noremap = true, silent = true, desc = "Grapple Select index 2" })
      vim.keymap.set("n", "<M-3>", function() grapple_select(3) end,
        { noremap = true, silent = true, desc = "Grapple Select index 3" })
      vim.keymap.set("n", "<M-4>", function() grapple_select(4) end,
        { noremap = true, silent = true, desc = "Grapple Select index 4" })
      vim.keymap.set("n", "<M-5>", function() grapple_select(5) end,
        { noremap = true, silent = true, desc = "Grapple Select index 5" })
      vim.keymap.set("n", "<M-6>", function() grapple_select(6) end,
        { noremap = true, silent = true, desc = "Grapple Select index 6" })
      vim.keymap.set("n", "<M-7>", function() grapple_select(7) end,
        { noremap = true, silent = true, desc = "Grapple Select index 7" })
      vim.keymap.set("n", "<M-8>", function() grapple_select(8) end,
        { noremap = true, silent = true, desc = "Grapple Select index 8" })
      vim.keymap.set("n", "<M-9>", function() grapple_select(9) end,
        { noremap = true, silent = true, desc = "Grapple Select index 9" })
      vim.keymap.set("n", "<M-0>", function() grapple_select(10) end,
        { noremap = true, silent = true, desc = "Grapple Select index 10" })
    end,
  },
}
