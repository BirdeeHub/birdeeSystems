local catUtils = require('nixCatsUtils')
local colorschemer = nixCats('colorscheme') -- also schemes lualine
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

require("large_file").setup {
  size_limit = 4 * 1024 * 1024, -- 4 MB
  buffer_options = {
    swapfile = false,
    bufhidden = 'unload',
    buftype = 'nowrite',
    undolevels = -1,
  },
  on_large_file_read_pre = function(ev) end
}

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

if nixCats('rust') then
  -- rustaceanvim setup if any
end

require('birdee.plugins.oil')

-- NOTE: everything else is lazily loaded

-- decided to actually make use of the import feature of lze
-- which does not automatically include the entire directory.
-- because otherwise you could not choose the order
-- of startup programs without using priority,
-- or have files that are not imported within the directory

-- personally though I don't use lze to load startup plugins because... why...

require('lze').load {
  { import = "birdee.plugins.telescope", },
  { import = "birdee.plugins.nestsitter", },
  { import = "birdee.plugins.completion", },
  { import = "birdee.plugins.grapple", },
  { import = "birdee.plugins.lualine", },
  { import = "birdee.plugins.git", },
  { import = "birdee.plugins.gutter", },
  { import = "birdee.plugins.clipboard", },
  { import = "birdee.plugins.image", },
  { import = "birdee.plugins.notes", },
  { import = "birdee.plugins.which-key", },
  { import = "birdee.plugins.AI", },
  {
    "color_picker",
    keys = {
      { "<leader>cpc", function() require("color_picker").rgbPicker() end, mode = { 'n', }, desc = "color_picker rgb" },
      { "<leader>cph", function() require("color_picker").hsvPicker() end, mode = { 'n', }, desc = "color_picker hsv" },
      { "<leader>cps", function() require("color_picker").hslPicker() end, mode = { 'n', }, desc = "color_picker hsl" },
      { "<leader>cpg", function() require("color_picker").rgbGradientPicker() end, mode = { 'n', }, desc = "color_picker rgb gradient" },
      { "<leader>cpd", function() require("color_picker").hsvGradientPicker() end, mode = { 'n', }, desc = "color_picker hsv gradient" },
      { "<leader>cpb", function() require("color_picker").hslGradientPicker() end, mode = { 'n', }, desc = "color_picker hsl gradient" },
    },
    on_require = "color_picker",
  },
  {
    "markdown-preview.nvim",
    enabled = catUtils.enableForCategory('general.markdown'),
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle", },
    ft = "markdown",
    keys = {
      {"<leader>mp", "<cmd>MarkdownPreview <CR>", mode = {"n"}, noremap = true, desc = "markdown preview"},
      {"<leader>ms", "<cmd>MarkdownPreviewStop <CR>", mode = {"n"}, noremap = true, desc = "markdown preview stop"},
      {"<leader>mt", "<cmd>MarkdownPreviewToggle <CR>", mode = {"n"}, noremap = true, desc = "markdown preview toggle"},
    },
    before = function(plugin)
      vim.g.mkdp_auto_close = 0
    end,
  },
  {
    "treesj",
    cmd = { "TSJToggle" },
    keys = { { "<leader>Ft", ":TSJToggle<CR>", mode = { "n" }, desc = "treesj split/join" }, },
    after = function(plugin)
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
    cmd = { "UndotreeToggle", "UndotreeHide", "UndotreeShow", "UndotreeFocus", "UndotreePersistUndo", },
    keys = { { "<leader>U", "<cmd>UndotreeToggle<CR>", mode = { "n" }, desc = "Undo Tree" }, },
    before = function(_)
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 40
    end,
  },
  {
    "lazydev.nvim",
    enabled = catUtils.enableForCategory('neonixdev'),
    cmd = { "LazyDev" },
    ft = "lua",
    after = function(plugin)
      require('lazydev').setup({
        library = {
          { words = { "vim%.uv", "vim%.loop" }, path = (require('nixCats').pawsible.allPlugins.start["luvit-meta"] or "luvit-meta") .. "/library" },
          { words = { "nixCats" }, path = require('nixCats').nixCatsPath .. '/lua' },
        },
      })
    end,
  },
  {
    "otter.nvim",
    enabled = catUtils.enableForCategory('otter'),
    -- event = "DeferredUIEnter",
    on_require = { "otter" },
    -- ft = { "markdown", "norg", "templ", "nix", "javascript", "html", "typescript", },
    after = function(plugin)
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
    "vim-cmake",
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
    after = function(plugin)
      if nixCats('C') then
        vim.api.nvim_create_user_command('BirdeeCMake', [[:CMake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .<CR>]],
          { desc = 'Run CMake with compile_commands.json' })
        vim.cmd [[let g:cmake_link_compile_commands = 1]]
      end
    end,
  },
  {
    "todo-comments.nvim",
    event = "DeferredUIEnter",
    after = function(plugin)
      require("todo-comments").setup({ signs = false })
    end,
  },
  {
    "indent-blankline.nvim",
    event = "DeferredUIEnter",
    after = function(plugin)
      require("ibl").setup()
    end,
  },
  {
    "visual-whitespace",
    event = "DeferredUIEnter",
    after = function(plugin)
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
    enabled = catUtils.enableForCategory('general.other'),
    cmd = { "StartupTime" },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = require("nixCatsUtils").packageBinPath
    end,
  },
  {
    "nvim-surround",
    event = "DeferredUIEnter",
    -- keys = "",
    after = function(plugin)
      require('nvim-surround').setup()
    end,
  },
  {
    "eyeliner.nvim",
    event = "DeferredUIEnter",
    -- keys = "",
    after = function(plugin)
      -- Highlights unique characters for f/F and t/T motions
      require('eyeliner').setup {
        highlight_on_key = true, -- show highlights only after key press
        dim = true,          -- dim all other characters
      }
    end,
  },
  {
    "render-markdown",
    ft = "markdown",
    after = function(plugin)
      require('render-markdown').setup({})
    end,
  },
  {
    "vim-dadbod",
    cmd = { "DB", "DBUI", "DBUIAddConnection", "DBUIClose",
      "DBUIToggle", "DBUIFindBuffer", "DBUILastQueryInfo", "DBUIRenameBuffer", },
    load = function(name)
      require("birdee.utils").safe_packadd({
        name,
        "vim-dadbod-ui",
      })
      require("birdee.utils").load_w_after_plugin("vim-dadbod-completion")
    end,
    after = function(plugin)
    end,
  },
  {
    "hlargs",
    event = "DeferredUIEnter",
    after = function(plugin)
      require('hlargs').setup({
        color = '#32a88f',
      })
      vim.cmd([[hi clear @lsp.type.parameter]])
      vim.cmd([[hi link @lsp.type.parameter Hlargs]])
    end,
  },
  {
    "vim-sleuth",
    event = "DeferredUIEnter",
  },
  {
    "nvim-highlight-colors",
    event = "DeferredUIEnter",
    -- ft = "",
    after = function(plugin)
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
}
