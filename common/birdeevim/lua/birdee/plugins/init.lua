local colorschemer = nixCats('colorscheme')-- also schemes lualine
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
local hlargsColor =  '#32a88f' -- if this doesnt work for new theme, change it here
if colorschemer ~= "" then
  vim.cmd.colorscheme(colorschemer)
end

require('birdee.plugins.telescope')

require('birdee.plugins.nestsitter')

require('birdee.plugins.completion')

require("todo-comments").setup({ signs = false })

if(nixCats('general.markdown')) then
  vim.g.mkdp_auto_close = 0
  vim.keymap.set('n','<leader>mp','<cmd>MarkdownPreview <CR>',{ noremap = true, desc = 'markdown preview' })
  vim.keymap.set('n','<leader>ms','<cmd>MarkdownPreviewStop <CR>',{ noremap = true, desc = 'markdown preview stop' })
  vim.keymap.set('n','<leader>mt','<cmd>MarkdownPreviewToggle <CR>',{ noremap = true, desc = 'markdown preview toggle' })
end

require('birdee.plugins.notes')

require('birdee.plugins.gutter')

local tsj = require('treesj')

local langs = {--[[ configuration for languages ]]}

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
  -- langs = {}, -- See the default presets in lua/treesj/langs
})
vim.keymap.set('n', '<leader>Ft', [[:TSJToggle<CR>]], { desc = "treesj split/join" })

vim.keymap.set('n', '<leader>U', vim.cmd.UndotreeToggle, { desc = "Undo Tree" })
vim.g.undotree_WindowLayout = 1
vim.g.undotree_SplitWidth = 40

-- Highlights unique characters for f/F and t/T motions
require('eyeliner').setup {
  highlight_on_key = true, -- show highlights only after key press
  dim = true, -- dim all other characters
}
require('hlargs').setup({
  color = hlargsColor,
})
vim.cmd([[hi clear @lsp.type.parameter]])
vim.cmd([[hi link @lsp.type.parameter Hlargs]])
require('Comment').setup()
  -- require('fidget').setup()
require('lualine').setup({
  options = {
    icons_enabled = false,
    theme = colorschemer,
    component_separators = '|',
    section_separators = '',
  },
  sections = {
    lualine_c = {
      {
        'filename', path = 1, status = true,
      },
      'buffers',
      -- 'lsp_progress',
    },
  },
})
require('fidget').setup({})
require('nvim-surround').setup()

local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup({})
-- REQUIRED

vim.keymap.set("n", "<leader>ha", function() harpoon:list():append() end, { noremap = true, silent = true, desc = 'append to harpoon' })
vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { noremap = true, silent = true, desc = 'open harpoon menu' })

vim.keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end, { noremap = true, silent = true, desc = 'harpoon 1' })
vim.keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end, { noremap = true, silent = true, desc = 'harpoon 2' })
vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end, { noremap = true, silent = true, desc = 'harpoon 3' })
vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end, { noremap = true, silent = true, desc = 'harpoon 4' })
require("ibl").setup()

-- I honestly only use this to see the little git icons. 
-- I wanna figure out how to add them to oil instead and ditch this
require('neo-tree').setup({
  close_if_last_window = true,
  window = {
    position = "float",
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
})
vim.keymap.set("n", "<leader>_", "<cmd>Neotree toggle<CR>", { noremap = true, desc = 'Open neo-tree' })

require('birdee.plugins.oil')
require('birdee.plugins.which-key')
