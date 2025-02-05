---@class lzextras.LspPlugin: lze.Plugin
---@field lsp? any

---@type table<string, lzextras.LspPlugin[]>
local states = {}

-- TODO: make a handler for lspconfig specs
local M = {
  ---@type lze.Handler
  handler = {
    spec_field = "lsp",
    -- modify is only called when a plugin's field is not nil
    ---@param plugin lzextras.LspPlugin
    modify = function(plugin)
      if not plugin.lsp then
        return plugin
      end
      return plugin
    end,
    ---@param plugin lzextras.LspPlugin
    add = function(plugin)
      if not plugin.lsp then
        return
      end
    end,
    ---@param plugin lzextras.LspPlugin
    before = function(plugin)
      if not plugin.lsp then
        return
      end
      for _, filetypelist in pairs(states) do
        for i = #filetypelist, 1, -1 do
          if filetypelist[i].name == plugin.name then
            table.remove(filetypelist, i)
          end
        end
      end
    end,
  },
}

return M
