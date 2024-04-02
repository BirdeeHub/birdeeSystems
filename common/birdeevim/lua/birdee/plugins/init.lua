local colorschemer = nixCats('colorscheme') -- also schemes lualine
if not require('nixCatsUtils').isNixCats then
  colorschemer = 'onedark'
end
if colorschemer == 'onedark' then
  require('onedark').setup {
    -- Set a style preset. 'dark' is default.
    style = 'dark', -- dark, darker, cool, deep, warm, warmer, light
  }
  require('onedark').load()
end
local hlargsColor = '#32a88f'  -- if this doesnt work for new theme, change it here
if colorschemer ~= "" then
  vim.cmd.colorscheme(colorschemer)
end

require("large_file").setup({
  size_limit = 4 * 1024 * 1024,  -- 4 MB
  buffer_options = {
      swapfile = false,
      bufhidden = 'unload',
      buftype = 'nowrite',
      undolevels = -1,
  },
  on_large_file_read_pre = function(ev) end
})

require('birdee.plugins.telescope')

require('birdee.plugins.nestsitter')

require('birdee.plugins.completion')

require('birdee.plugins.lualine')

require('birdee.plugins.git')

require('birdee.plugins.imgclip')

require("todo-comments").setup({ signs = false })

require('garbage-day').setup({})

if nixCats('web') then
  local otter = require 'otter'
  otter.setup {
    lsp = {
      hover = {
        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
      },
    },
    buffers = {
      -- if set to true, the filetype of the otterbuffers will be set.
      -- otherwise only the autocommand of lspconfig that attaches
      -- the language server will be executed without setting the filetype
      set_filetype = true,
      -- write <path>.otter.<embedded language extension> files
      -- to disk on save of main buffer.
      -- usefule for some linters that require actual files
      -- otter files are deleted on quit or main buffer close
      write_to_disk = false,
    },
    strip_wrapping_quote_characters = { "'", '"', "`" },
  }
end

require('visual-whitespace').setup({
  highlight = { link = 'Visual' },
  space_char = '·',
  tab_char = '→',
  nl_char = '↲'
})
require('yankbank').setup({
  max_entries = 10,
  sep = "-----",
})
vim.keymap.set("n", "<leader>sc", ":YankBank<CR>", { silent = true, noremap = true, desc = "[s]earch [c]liphist (yankbank)" })

require('render-markdown').setup({})

if (nixCats('general.markdown')) then
  vim.g.mkdp_auto_close = 0
  vim.keymap.set('n', '<leader>mp', '<cmd>MarkdownPreview <CR>', { noremap = true, desc = 'markdown preview' })
  vim.keymap.set('n', '<leader>ms', '<cmd>MarkdownPreviewStop <CR>', { noremap = true, desc = 'markdown preview stop' })
  vim.keymap.set('n', '<leader>mt', '<cmd>MarkdownPreviewToggle <CR>', { noremap = true, desc = 'markdown preview toggle' })
end

require('birdee.plugins.notes')

require('birdee.plugins.gutter')

require('birdee.plugins.grapple')

require('birdee.plugins.oil')

require("ibl").setup()

require('Comment').setup()

require('nvim-surround').setup()


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
vim.keymap.set('n', '<leader>Ft', [[:TSJToggle<CR>]], { desc = "treesj split/join" })

vim.keymap.set('n', '<leader>U', vim.cmd.UndotreeToggle, { desc = "Undo Tree" })
vim.g.undotree_WindowLayout = 1
vim.g.undotree_SplitWidth = 40

-- Highlights unique characters for f/F and t/T motions
require('eyeliner').setup {
  highlight_on_key = true, -- show highlights only after key press
  dim = true,              -- dim all other characters
}
require('hlargs').setup({
  color = hlargsColor,
})
vim.cmd([[hi clear @lsp.type.parameter]])
vim.cmd([[hi link @lsp.type.parameter Hlargs]])
require('birdee.plugins.which-key')
