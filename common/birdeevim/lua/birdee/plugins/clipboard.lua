return {
  {
    "nvim-neoclip.lua",
    for_cat = "other",
    cmd = { "Telescope" },
    keys = {
      {"<leader>sc", function()
        require('telescope').extensions.neoclip['default']()
      end, mode = { 'n' }, silent = true, noremap = true, desc = "[s]earch [c]liphist" },
      {"<leader>sm", function()
        require('telescope').extensions.macroscope['default']()
      end, mode = { "n" }, silent = true, noremap = true, desc = "[s]earch [m]acro history" },
    },
    after = function (_)
      require('neoclip').setup({
        history = 1000,
        enable_persistent_history = false,
        length_limit = 1048576,
        continuous_sync = false,
        db_path = vim.fn.stdpath("data") .. "/databases/neoclip.sqlite3",
        filter = nil,
        preview = true,
        prompt = nil,
        default_register = '"',
        default_register_macros = 'q',
        enable_macro_history = true,
        content_spec_column = false,
        disable_keycodes_parsing = false,
        on_select = {
          move_to_front = false,
          close_telescope = true,
        },
        on_paste = {
          set_reg = false,
          move_to_front = false,
          close_telescope = true,
        },
        on_replay = {
          set_reg = false,
          move_to_front = false,
          close_telescope = true,
        },
        on_custom_action = {
          close_telescope = true,
        },
        keys = {
          telescope = {
            i = {
              select = '<cr>',
              paste = '<c-p>',
              paste_behind = '<c-k>',
              replay = '<c-q>',     -- replay a macro
              delete = '<c-d>',     -- delete an entry
              edit = '<c-e>',       -- edit an entry
              custom = {},
            },
            n = {
              select = '<cr>',
              paste = 'p',
              --- It is possible to map to more than one key.
              -- paste = { 'p', '<c-p>' },
              paste_behind = 'P',
              replay = 'q',
              delete = 'd',
              edit = 'e',
              custom = {},
            },
          },
          fzf = {
            select = 'default',
            paste = 'ctrl-p',
            paste_behind = 'ctrl-k',
            custom = {},
          },
        },
      })
    end,
  },
  {
    "img-clip.nvim",
    for_cat = "other",
    cmd = { "PasteImage", "ImgClipDebug", "ImgClipConfig" },
    -- event = "",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function (_)
      require("img-clip").setup({
        default = {
          -- file and directory options
          dir_path = "assets", ---@type string
          file_name = "%Y-%m-%d-%H-%M-%S", ---@type string
          use_absolute_path = false, ---@type boolean
          relative_to_current_file = false, ---@type boolean

          -- template options
          template = "$FILE_PATH", ---@type string
          url_encode_path = false, ---@type boolean
          relative_template_path = true, ---@type boolean
          use_cursor_in_template = true, ---@type boolean
          insert_mode_after_paste = true, ---@type boolean

          -- prompt options
          prompt_for_file_name = true, ---@type boolean
          show_dir_path_in_prompt = false, ---@type boolean

          -- base64 options
          max_base64_size = 10, ---@type number
          embed_image_as_base64 = false, ---@type boolean

          -- image options
          process_cmd = "", ---@type string
          copy_images = false, ---@type boolean
          download_images = true, ---@type boolean

          -- drag and drop options
          drag_and_drop = {
            enabled = true, ---@type boolean
            insert_mode = false, ---@type boolean
          },
        },

        -- filetype specific options
        filetypes = {
          markdown = {
            url_encode_path = true, ---@type boolean
            template = "![$CURSOR]($FILE_PATH)", ---@type string
            download_images = false, ---@type boolean
          },

          html = {
            template = '<img src="$FILE_PATH" alt="$CURSOR">', ---@type string
          },

          tex = {
            relative_template_path = false, ---@type boolean
            template = [[ 
      \begin{figure}[h]
        \centering
        \includegraphics[width=0.8\textwidth]{$FILE_PATH}
        \caption{$CURSOR}
        \label{fig:$LABEL}
      \end{figure}
          ]], ---@type string
          },

          typst = {
            template = [[
      #figure(
        image("$FILE_PATH", width: 80%),
        caption: [$CURSOR],
      ) <fig-$LABEL>
          ]], ---@type string
          },

          rst = {
            template = [[
      .. image:: $FILE_PATH
         :alt: $CURSOR
         :width: 80%
          ]], ---@type string
          },

          asciidoc = {
            template = 'image::$FILE_PATH[width=80%, alt="$CURSOR"]', ---@type string
          },

          org = {
            template = [=[
      #+BEGIN_FIGURE
      [[file:$FILE_PATH]]
      #+CAPTION: $CURSOR
      #+NAME: fig:$LABEL
      #+END_FIGURE
          ]=], ---@type string
          },
        },

        -- file, directory, and custom triggered options
        files = {}, ---@type table
        dirs = {}, ---@type table
        custom = {}, ---@type table
      })
    end,
  },
}
