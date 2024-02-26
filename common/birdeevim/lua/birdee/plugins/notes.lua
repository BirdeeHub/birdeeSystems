if nixCats('notes') then
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
  require('neorg').setup {
    load = {
      ["core.defaults"] = {},
      ["core.concealer"] = {},
      ["core.completion"] = {
        config = {
          engine = "nvim-cmp",
          name = "[Neorg]",
        },
      },
      ["core.manoeuvre"] = {},
      -- ["core.presenter"] = {
      --   zen_mode = "",
      -- },
      ["core.export"] = {},
      ["core.export.markdown"] = {},
      ["core.ui.calendar"] = {},
      ["core.integrations.telescope"] = {}
      -- ["core.dirman"] = {
      --   config = {
      --     workspaces = {
      --       my_ws = "~/neorg", -- Format: <name_of_workspace> = <path_to_workspace_root>
      --       my_other_notes = "~/work/notes",
      --     },
      --     index = "index.norg", -- The name of the main (root) .norg file
      --   }
      -- }
    }
  }

  local neorg_callbacks = require("neorg.core.callbacks")

  neorg_callbacks.on_event("core.keybinds.events.enable_keybinds", function(_, keybinds)
    -- Map all the below keybinds only when the "norg" mode is active
    keybinds.map_event_to_mode("norg", {
      n = {     -- Bind keys in normal mode
        { "<C-s>", "core.integrations.telescope.find_linkable" },
      },

      i = {     -- Bind in insert mode
        { "<C-l>", "core.integrations.telescope.insert_link" },
      },
    }, {
      silent = true,
      noremap = true,
    })
  end)
end
