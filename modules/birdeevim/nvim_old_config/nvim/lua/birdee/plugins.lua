-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },
      -- { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },
  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lua',
      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-cmdline',
      {
        'tzachar/cmp-tabnine',
        build = './install.sh',
        -- requires curl and unzip
      },
      -- {
      --   "Exafunction/codeium.nvim",
      --   dependencies = {
      --     "nvim-lua/plenary.nvim",
      --   },
      --   config = function()
      --     require("codeium").setup({
      --     })
      --   end,
      -- },
      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },
  {
    'sourcegraph/sg.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
    -- requires cargo
  },
  -- { 'windwp/nvim-autopairs' },
  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>hp', require('gitsigns').preview_hunk, { buffer = bufnr, desc = 'Preview git hunk' })

        -- don't override the built-in and fugitive keymaps
        local gs = package.loaded.gitsigns
        vim.keymap.set({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = "Jump to next hunk" })
        vim.keymap.set({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = "Jump to previous hunk" })
      end,
    },
  },

  -- {
  --   -- Theme inspired by Atom
  --   'folke/tokyonight.nvim',
  --   priority = 1000,
  --   config = function()
  --     vim.cmd.colorscheme 'tokyonight'
  --   end,
  -- },
  { 'catppuccin/nvim', name = "catppuccin", priority = 1000 },
  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        -- theme = 'tokyonight',
        theme = 'catppuccin',
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        lualine_c = {
          {
            'filename', path = 1, status = true,
          },
        },
      },
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help indent_blankline.txt`
    main = "ibl",
    opts = {},
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },


  -- {
  --   'udalov/kotlin-vim',
  -- },
  {
    'mfussenegger/nvim-jdtls',
  },
  {
    'ThePrimeagen/harpoon',
    lazy = false,
    opts = {
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
      },
    },
  },
  {
    'iamcco/markdown-preview.nvim',
    config = function()
      vim.fn['mkdp#util#install']()
      vim.g.mkdp_auto_close = 0
      vim.api.nvim_set_keymap('n', '<leader>mp', '<Plug>MarkdownPreviewToggle', {})
    end
  },
--  {
--    'mfussenegger/nvim-lint',
--    lazy = false,
--  },
  -- {
  --  'stevearc/conform.nvim',
  --  opts = {
  --   formatters_by_ft = {
  --     kotlin = {"KT_fmt"},
  --   },
  --   formatters = {
  --     KT_fmt = {
  --       -- This can be a string or a function that returns a string
  --       command = "/usr/bin/ktlint --format",
  --     },
  --   },
  --   lsp_fallback = true,
  --   timeout_ms = 9001,
  --  },
  -- },
  {
    'm-demare/hlargs.nvim',
    opts = {
      color = '#32a88f',
    },
  },
  {
    'tpope/vim-surround',
  },
--  {
--    'sheerun/vim-polyglot'
--  },
 {
   'nvim-neo-tree/neo-tree.nvim',
   branch = "v3.x",
   dependencies = {
     'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
     'MunifTanjim/nui.nvim',
  },
  opts = {
    close_if_last_window = true,
    window = {
      position = "right",
      mappings = {
        ["<space>"] = {
          nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use 
          noremap = false,
        },
      },
    },
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = true,
        hide_gitignored = true,
        hide_hidden = true,
      },
      hijack_netrw_behavior = "disabled",
    },
    buffers = {
      follow_current_file = {
        enabled = true,
      },
    },
  },
 },
 -- {
 --  "jackMort/ChatGPT.nvim",
 --    event = "VeryLazy",
 --    config = function()
 --      require("chatgpt").setup({
 --        api_key_cmd = "cat /home/birdee/Documents/gptkey"
 --      })
 --    end,
 --    dependencies = {
 --      "MunifTanjim/nui.nvim",
 --      "nvim-lua/plenary.nvim",
 --      "nvim-telescope/telescope.nvim"
 --    }
 --  },
-- require 'birdee.autoformat',
  require 'birdee.debug',
  --For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'package.lua_file_or_folder_with_init' },
}, {})

