-- local ok, notify = pcall(require, "notify")
-- if ok then
--   notify.setup({
--     on_open = function(win)
--       vim.api.nvim_win_set_config(win, { focusable = false })
--     end,
--   })
--   vim.notify = notify
--   vim.keymap.set("n", "<Esc>", function()
--       notify.dismiss({ silent = true, })
--   end, { desc = "dismiss notify popup and clear hlsearch" })
-- end
local catUtils = require('nixCatsUtils')
local colorschemer = nixCats.extra('colorscheme') -- also schemes lualine
if not catUtils.isNixCats then
  colorschemer = 'onedark'
end
if colorschemer == 'onedark' then
  require('onedark').setup {
    -- Set a style preset. 'dark' is default.
    style = 'darker', -- dark, darker, cool, deep, warm, warmer, light
  }
  require('onedark').load()
end
if colorschemer ~= "" then
  vim.cmd.colorscheme(colorschemer)
end

if nixCats('other') then
  vim.keymap.set('n', '<leader>rs', '<cmd>lua require("spectre").toggle()<CR>', {
    desc = "Toggle Spectre"
  })
  vim.keymap.set('n', '<leader>rw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
    desc = "Search current word"
  })
  vim.keymap.set('v', '<leader>rw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
    desc = "Search current word"
  })
  vim.keymap.set('n', '<leader>rf', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
    desc = "Search on current file"
  })
end

-- NOTE: This is already lazy. It doesnt require it until you use the keybinding
vim.keymap.set({ 'n', }, "<leader>cpc", function() require("color_picker").rgbPicker() end, { desc = "color_picker rgb" })
vim.keymap.set({ 'n', }, "<leader>cph", function() require("color_picker").hsvPicker() end, { desc = "color_picker hsv" })
vim.keymap.set({ 'n', }, "<leader>cps", function() require("color_picker").hslPicker() end, { desc = "color_picker hsl" })
vim.keymap.set({ 'n', }, "<leader>cpg", function() require("color_picker").rgbGradientPicker() end, { desc = "color_picker rgb gradient" })
vim.keymap.set({ 'n', }, "<leader>cpd", function() require("color_picker").hsvGradientPicker() end, { desc = "color_picker hsv gradient" })
vim.keymap.set({ 'n', }, "<leader>cpb", function() require("color_picker").hslGradientPicker() end, { desc = "color_picker hsl gradient"})

if nixCats('general') then
  require('birdee.plugins.oil')
end

return {
  { import = "birdee.plugins.snacks", },
  { import = "birdee.plugins.telescope", },
  { import = "birdee.plugins.nestsitter", },
  { import = "birdee.plugins.completion", enabled = nixCats('general.cmp'), },
  { import = "birdee.plugins.grapple", },
  { import = "birdee.plugins.lualine", },
  { import = "birdee.plugins.gutter", },
  { import = "birdee.plugins.clipboard", },
  { import = "birdee.plugins.image", },
  { import = "birdee.plugins.notes", },
  { import = "birdee.plugins.which-key", },
  { import = "birdee.plugins.AI", },
  {
    "markdown-preview.nvim",
    for_cat = "general.markdown",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle", },
    ft = "markdown",
    keys = {
      {"<leader>mp", "<cmd>MarkdownPreview <CR>", mode = {"n"}, noremap = true, desc = "markdown preview"},
      {"<leader>ms", "<cmd>MarkdownPreviewStop <CR>", mode = {"n"}, noremap = true, desc = "markdown preview stop"},
      {"<leader>mt", "<cmd>MarkdownPreviewToggle <CR>", mode = {"n"}, noremap = true, desc = "markdown preview toggle"},
    },
    before = function(_)
      vim.g.mkdp_auto_close = 0
    end,
  },
  {
    "treesj",
    for_cat = "general.core",
    cmd = { "TSJToggle" },
    keys = { { "<leader>Ft", ":TSJToggle<CR>", mode = { "n" }, desc = "treesj split/join" }, },
    after = function(_)
      local tsj = require('treesj')

      -- local langs = {--[[ configuration for languages ]]}

      tsj.setup({
        ---@type boolean Use default keymaps (<space>m - toggle, <space>j - join, <space>s - split)
        use_default_keymaps = true,
        ---@type boolean Node with syntax error will not be formatted
        check_syntax_error = true,
        ---If line after join will be longer than max value,
        ---@type number If line after join will be longer than max value, node will not be formatted
        max_join_length = 120,
        ---Cursor behavior:
        ---hold - cursor follows the node/place on which it was called
        ---start - cursor jumps to the first symbol of the node being formatted
        ---end - cursor jumps to the last symbol of the node being formatted
        ---@type 'hold'|'start'|'end'
        cursor_behavior = 'hold',
        ---@type boolean Notify about possible problems or not
        notify = true,
        ---@type boolean Use `dot` for repeat action
        dot_repeat = true,
        ---@type nil|function Callback for treesj error handler. func (err_text, level, ...other_text)
        on_error = nil,
        ---@type table Presets for languages
        -- langs = langs, -- See the default presets in lua/treesj/langs
      })
    end,
  },
  {
    "undotree",
    for_cat = "general.core",
    cmd = { "UndotreeToggle", "UndotreeHide", "UndotreeShow", "UndotreeFocus", "UndotreePersistUndo", },
    keys = { { "<leader>U", "<cmd>UndotreeToggle<CR>", mode = { "n" }, desc = "Undo Tree" }, },
    before = function(_)
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 40
    end,
  },
  {
    "otter.nvim",
    for_cat = "otter",
    -- event = "DeferredUIEnter",
    on_require = { "otter" },
    -- ft = { "markdown", "norg", "templ", "nix", "javascript", "html", "typescript", },
    after = function(_)
      local otter = require 'otter'
      otter.setup {
        lsp = {
          -- `:h events` that cause the diagnostics to update. Set to:
          -- { "BufWritePost", "InsertLeave", "TextChanged" } for less performant
          -- but more instant diagnostic updates
          diagnostic_update_events = { "BufWritePost" },
          -- function to find the root dir where the otter-ls is started
          root_dir = function(_, bufnr)
            return vim.fs.root(bufnr or 0, {
              ".git",
              "_quarto.yml",
              "package.json",
            }) or vim.fn.getcwd(0)
          end,
        },
        buffers = {
          -- if set to true, the filetype of the otterbuffers will be set.
          -- otherwise only the autocommand of lspconfig that attaches
          -- the language server will be executed without setting the filetype
          set_filetype = false,
          -- write <path>.otter.<embedded language extension> files
          -- to disk on save of main buffer.
          -- usefule for some linters that require actual files
          -- otter files are deleted on quit or main buffer close
          write_to_disk = false,
        },
        verbose = {          -- set to false to disable all verbose messages
          no_code_found = false, -- warn if otter.activate is called, but no injected code was found
        },
        strip_wrapping_quote_characters = { "'", '"', "`" },
        -- otter may not work the way you expect when entire code blocks are indented (eg. in Org files)
        -- When true, otter handles these cases fully.
        handle_leading_whitespace = false,
      }
    end,
  },
  {
    "vim-fugitive",
    for_cat = "general.core",
    cmd = { "G", "Git", "Gdiffsplit", "Gvdiffsplit", "Gedit", "Gread", "Gwrite",
      "Ggrep", "GMove", "Glgrep", "GRename", "GDelete", "GRemove", "GBrowse",
      "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles",
      "DiffviewRefresh", "DiffviewFileHistory", },
    -- event = "",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    load = function (name)
      require("birdee.utils").multi_packadd({
        name,
        "vim-rhubarb",
        "diffview.nvim",
      })
    end,
  },
  {
    "vim-cmake",
    for_cat = "C",
    ft = { "cmake" },
    cmd = {
      "CMakeGenerate",
      "CMakeClean",
      "CMakeBuild",
      "CMakeInstall",
      "CMakeRun",
      "CMakeTest",
      "CMakeSwitch",
      "CMakeOpen",
      "CMakeClose",
      "CMakeToggle",
      "CMakeCloseOverlay",
      "CMakeStop",
    },
    after = function(_)
      vim.api.nvim_create_user_command('BirdeeCMake', [[:CMake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .<CR>]],
        { desc = 'Run CMake with compile_commands.json' })
      vim.cmd [[let g:cmake_link_compile_commands = 1]]
    end,
  },
  {
    "todo-comments.nvim",
    for_cat = "other",
    event = "DeferredUIEnter",
    after = function(_)
      require("todo-comments").setup({ signs = false })
    end,
  },
  {
    "visual-whitespace",
    for_cat = "other",
    event = "DeferredUIEnter",
    after = function(_)
      require('visual-whitespace').setup({
        highlight = { link = 'Visual' },
        space_char = '·',
        tab_char = '→',
        nl_char = '↲'
      })
    end,
  },
  {
    "vim-startuptime",
    for_cat = "other",
    cmd = { "StartupTime" },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixCats.packageBinPath
    end,
  },
  {
    "nvim-surround",
    for_cat = "general.core",
    event = "DeferredUIEnter",
    -- keys = "",
    after = function(_)
      require('nvim-surround').setup()
    end,
  },
  {
    "eyeliner.nvim",
    for_cat = "other",
    event = "DeferredUIEnter",
    -- keys = "",
    after = function(_)
      -- Highlights unique characters for f/F and t/T motions
      require('eyeliner').setup {
        highlight_on_key = true, -- show highlights only after key press
        dim = true,          -- dim all other characters
      }
    end,
  },
  {
    "render-markdown.nvim",
    for_cat = "general.markdown",
    ft = "markdown",
    after = function(_)
      require('render-markdown').setup({})
    end,
  },
  {
    "vim-dadbod",
    for_cat = "SQL",
    cmd = { "DB", "DBUI", "DBUIAddConnection", "DBUIClose",
      "DBUIToggle", "DBUIFindBuffer", "DBUILastQueryInfo", "DBUIRenameBuffer", },
    load = function(name)
      require("birdee.utils").multi_packadd({
        name,
        "vim-dadbod-ui",
      })
      require("birdee.utils").load_w_after_plugin("vim-dadbod-completion")
    end,
    after = function(_)
    end,
  },
  {
    "hlargs",
    for_cat = "other",
    event = "DeferredUIEnter",
    after = function(_)
      require('hlargs').setup({
        color = '#32a88f',
      })
      vim.cmd([[hi clear @lsp.type.parameter]])
      vim.cmd([[hi link @lsp.type.parameter Hlargs]])
    end,
  },
  {
    "vim-sleuth",
    for_cat = "general.core",
    event = "DeferredUIEnter",
  },
  {
    "nvim-highlight-colors",
    for_cat = "other",
    event = "DeferredUIEnter",
    -- ft = "",
    after = function(_)
      require("nvim-highlight-colors").setup {
        ---Render style
        ---@usage 'background'|'foreground'|'virtual'
        render = 'virtual',

        ---Set virtual symbol (requires render to be set to 'virtual')
        virtual_symbol = '■',

        ---Highlight named colors, e.g. 'green'
        enable_named_colors = true,

        ---Highlight tailwind colors, e.g. 'bg-blue-500'
        enable_tailwind = true,

        ---Set custom colors
        ---Label must be properly escaped with '%' to adhere to `string.gmatch`
        --- :help string.gmatch
        custom_colors = {
          { label = '%-%-theme%-primary%-color',   color = '#0f1219' },
          { label = '%-%-theme%-secondary%-color', color = '#5a5d64' },
        }
      }
    end,
  },
  -- {
  --   "indent-blankline.nvim",
  --   for_cat = "general.core",
  --   event = "DeferredUIEnter",
  --   after = function(plugin)
  --     require("ibl").setup()
  --   end,
  -- },
}
