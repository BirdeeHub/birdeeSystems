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
      ["core.keybinds"] = {
        config = {
          hook = function(keybinds)
            -- Unmaps any Neorg key from the `norg` mode
            -- keybinds.unmap("norg", "n", "<C-Space>")
            -- keybinds.unmap("norg", "n", keybinds.leader .. "nn")

            -- Binds the `gtd` key in `norg` mode to execute `:echo 'Hello'`
            -- keybinds.map("norg", "n", "gtd", "<cmd>echo 'Hello!'<CR>")

            -- Remap unbinds the current key then rebinds it to have a different action
            -- associated with it.
            -- The following is the equivalent of the `unmap` and `map` calls you saw above:
            -- keybinds.remap("norg", "n", "gtd", "<cmd>echo 'Hello!'<CR>")

            -- Sometimes you may simply want to rebind the Neorg action something is bound to
            -- versus remapping the entire keybind. This remap is essentially the same as if you
            -- did `keybinds.remap("norg", "n", "<C-Space>, "<cmd>Neorg keybind norg core.qol.todo_items.todo.task_done<CR>")
            -- keybinds.remap_event("norg", "n", "<C-Space>", "core.qol.todo_items.todo.task_done")

            -- Want to move one keybind into the other? `remap_key` moves the data of the
            -- first keybind to the second keybind, then unbinds the first keybind.
            keybinds.remap_key("norg", "n", "<C-Space>", "<Leader>tt")
          end,
        },
      },
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
      n = { -- Bind keys in normal mode
        { "<C-s>", "core.integrations.telescope.find_linkable" },
      },

      i = { -- Bind in insert mode
        { "<C-l>", "core.integrations.telescope.insert_link" },
      },
    }, {
      silent = true,
      noremap = true,
    })
  end)
end
