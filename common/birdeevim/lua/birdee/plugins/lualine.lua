return {
  {
    "lualine.nvim",
    for_cat = "general.core",
    -- cmd = { "" },
    event = "DeferredUIEnter",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    load = function (name)
      require("birdee.utils").multi_packadd({
        name,
        "lualine-lsp-progress",
      })
    end,
    after = function (_)
      local colorschemer = nixCats.extra('colorscheme') -- also schemes lualine
      if not require('nixCatsUtils').isNixCats then
        colorschemer = 'onedark'
      end
      -- local components = {
      --   python_env = {
      --     function()
      --       if vim.bo.filetype == "python" then
      --         local venv = os.getenv "CONDA_DEFAULT_ENV" or os.getenv "VIRTUAL_ENV"
      --         if venv then
      --           local icons = require "nvim-web-devicons"
      --           local py_icon, _ = icons.get_icon ".py"
      --           return string.format(" " .. py_icon .. " (%s)", venv)
      --         end
      --       end
      --       return ""
      --     end
      --   },
      -- }
      require('lualine').setup({
        options = {
          icons_enabled = true,
          theme = colorschemer,
          component_separators = { left = '|', right = '|' },
          section_separators = { left = '', right = '' },
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = false,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = {
            'branch',
            {
              "diff",
              symbols = {
                added = require("birdee.icons").git.added,
                modified = require("birdee.icons").git.modified,
                removed = require("birdee.icons").git.removed,
              },
            },
            'diagnostics',
          },
          lualine_c = {
            {
              'filename', path = 1, status = true,
            },
          },
          lualine_x = {
            -- components.python_env,
            'encoding',
            'fileformat',
            'filetype',
          },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {
            {
              'filename', path = 3, status = true,
            },
          },
          lualine_c = {
          },
          lualine_x = { 'filetype' },
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {
          lualine_a = {
            {
              'buffers',
              mode = 4,
            },
          },
          lualine_c = {},
          lualine_b = { 'lsp_progress', },
          lualine_x = {},
          lualine_y = { 'grapple', },
          lualine_z = { 'tabs' }
        },
        winbar = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {}
        },
        inactive_winbar = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {}
        },
        extensions = {}
      })
    end,
  },
}
