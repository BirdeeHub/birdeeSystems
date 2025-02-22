return {
  {
    "nvim-treesitter",
    for_cat = "treesitter",
    -- cmd = { "" },
    event = "DeferredUIEnter",
    dep_of = { "treesj", "otter.nvim", "hlargs", "render-markdown", "neorg" },
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    load = function (name)
      require("birdee.utils").multi_packadd({
        name,
        "nvim-treesitter-textobjects",
      })
    end,
    after = function (_)

      -- [[ Configure Treesitter ]]
      -- See `:help nvim-treesitter`
      -- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
      vim.defer_fn(function()
        require('nvim-treesitter.configs').setup {
          --parser_install_dir = absolute_path,

          highlight = {
            enable = true,
            -- additional_vim_regex_highlighting = { "kotlin" },
          },
          indent = { enable = false },
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = '<M-t>',
              node_incremental = '<M-t>',
              scope_incremental = '<M-T>',
              node_decremental = '<M-r>',
            },
          },
          textobjects = {
            select = {
              enable = true,
              lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
              keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ['aa'] = '@parameter.outer',
                ['ia'] = '@parameter.inner',
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner',
              },
            },
            move = {
              enable = true,
              set_jumps = true, -- whether to set jumps in the jumplist
              goto_next_start = {
                [']m'] = '@function.outer',
                [']]'] = '@class.outer',
              },
              goto_next_end = {
                [']M'] = '@function.outer',
                [']['] = '@class.outer',
              },
              goto_previous_start = {
                ['[m'] = '@function.outer',
                ['[['] = '@class.outer',
              },
              goto_previous_end = {
                ['[M'] = '@function.outer',
                ['[]'] = '@class.outer',
              },
            },
            swap = {
              enable = true,
              swap_next = {
                ['<leader>a'] = '@parameter.inner',
              },
              swap_previous = {
                ['<leader>A'] = '@parameter.inner',
              },
            },
          },
        }
      end, 0)
    end,
  },
}
