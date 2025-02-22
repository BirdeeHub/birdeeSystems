return {
  {
    "cmp-buffer",
    on_plugin = { "nvim-cmp" },
    load = require("birdee.utils").load_w_after_plugin,
  },
  {
    "cmp-cmdline",
    on_plugin = { "nvim-cmp" },
    load = require("birdee.utils").load_w_after_plugin,
  },
  {
    "cmp-cmdline-history",
    on_plugin = { "nvim-cmp" },
    load = require("birdee.utils").load_w_after_plugin,
  },
  {
    "cmp-nvim-lsp",
    on_plugin = { "nvim-cmp" },
    dep_of = { "nvim-lspconfig" },
    load = require("birdee.utils").load_w_after_plugin,
  },
  {
    "cmp-nvim-lsp-signature-help",
    on_plugin = { "nvim-cmp" },
    load = require("birdee.utils").load_w_after_plugin,
  },
  {
    "cmp-nvim-lua",
    on_plugin = { "nvim-cmp" },
    load = require("birdee.utils").load_w_after_plugin,
  },
  {
    "cmp-path",
    on_plugin = { "nvim-cmp" },
    load = require("birdee.utils").load_w_after_plugin,
  },
  {
    "cmp_luasnip",
    on_plugin = { "nvim-cmp" },
    load = require("birdee.utils").load_w_after_plugin,
  },
  {
    "friendly-snippets",
    dep_of = { "nvim-cmp" },
  },
  {
    "lspkind.nvim",
    dep_of = { "nvim-cmp" },
    load = require("birdee.utils").load_w_after_plugin,
  },
  {
    "clangd_extensions.nvim",
    dep_of = { "nvim-lspconfig", "nvim-cmp" },
  },
  {
    "luasnip",
    dep_of = { "nvim-cmp" },
    after = function (_)
      require('birdee.snippets')
    end,
  },
  {
    "nvim-cmp",
    -- cmd = { "" },
    event = { "DeferredUIEnter" },
    on_require = { "cmp" },
    -- ft = "",
    -- keys = "",
    dep_of = { "codeium.nvim" },
    -- colorscheme = "",
    after = function (_)
      -- [[ Configure nvim-cmp ]]
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local lspkind = require 'lspkind'

      local T_C = nixCats('tabCompletionKeys')
      local key_mappings = {
        ['<C-p>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'c', 'i' }),
        ['<C-n>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'c', 'i' }),
        ['<M-c>'] = cmp.mapping(cmp.mapping.complete({}), { 'c', 'i', 's' }),
        [ T_C and '<c-space>' or '<M-l>'] = cmp.mapping(cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        }), { 'c', 'i', 's' }),
        [ T_C and '<tab>' or '<M-j>' ] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { 'c', 'i', 's' }),
        [ T_C and '<s-tab>' or '<M-k>' ] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'c', 'i', 's' }),
      }

      cmp.setup {
        formatting = {
          format = lspkind.cmp_format {
            mode = 'text',
            with_text = true,
            maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)

            menu = {
              codeium = '[AI]',
              buffer = '[BUF]',
              nvim_lsp = '[LSP]',
              nvim_lsp_signature_help = '[LSP]',
              nvim_lsp_document_symbol = '[LSP]',
              nvim_lua = '[API]',
              path = '[PATH]',
              luasnip = '[SNIP]',
            },
          },
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert(key_mappings),

        sources = cmp.config.sources {
          -- The insertion order influences the priority of the sources
          { name = 'nvim_lsp' --[[ , keyword_length = 3 ]] },
          { name = 'luasnip' },
          { name = "neorg" },
          { name = 'nvim_lsp_signature_help' --[[ , keyword_length = 3  ]] },
          -- { name = 'cmp_tabnine' },
          { name = 'path' },
          { name = 'codeium' },
          { name = 'buffer' },
        },
        enabled = function()
          return vim.bo[0].buftype ~= 'prompt'
        end,
        experimental = {
          native_menu = false,
          ghost_text = false,
        },
      }

      cmp.setup.filetype({ 'sql', 'mysql', 'plsql' }, {
        sources = cmp.config.sources {
          { name = 'vim-dadbod-completion' },
          { name = 'buffer' },
        },
      })

      cmp.setup.filetype('lua', {
        sources = cmp.config.sources {
          -- The insertion order influences the priority of the sources
          { name = 'lazydev', group_index = 0 },
          { name = 'nvim_lsp' --[[ , keyword_length = 3 ]] },
          { name = 'luasnip' },
          { name = "neorg" },
          { name = 'nvim_lsp_signature_help' --[[ , keyword_length = 3  ]] },
          -- { name = 'cmp_tabnine' },
          { name = 'path' },
          { name = 'codeium' },
          { name = 'buffer' },
        },
        {
          {
            name = 'cmdline',
            option = {
              ignore_cmds = { 'Man', '!' },
            },
          },
        },
      })

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(key_mappings),
        sources = {
          { name = 'nvim_lsp_document_symbol' --[[ , keyword_length = 3  ]] },
          { name = 'buffer' },
          { name = 'cmdline_history' },
        },
        view = {
          entries = { name = 'wildmenu', separator = '|' },
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(key_mappings),
        sources = cmp.config.sources {
          { name = 'cmdline' },
          -- { name = 'cmdline_history' },
          { name = 'path' },
          { name = "neorg" },
        },
      })
    end,
  },
}
