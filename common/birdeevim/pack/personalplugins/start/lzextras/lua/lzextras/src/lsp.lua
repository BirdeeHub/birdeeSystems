---@class lzextras.LspPlugin: lze.Plugin
---@field lsp? any
---@field after? table|function

---@type table<string, lzextras.LspPlugin[]>
local states = {}

-- TODO: make a handler for lspconfig specs
local M = {
  ---@type lze.Handler
  handler = {
    spec_field = "lsp",
    -- modify is only called when a plugin's field is not nil
    -- modify should return a plugin where the after field is replaced
    ---@param plugin lzextras.LspPlugin
    modify = function(plugin)
      if not plugin.lsp then
        return plugin
      end
      if type(plugin.after) ~= "table" then
        vim.notify('lsp spec for "' .. plugin.name .. '" failed, after field must be a table',
          vim.log.levels.ERROR, { title = "lzextras.lsp" })
        return plugin
      end
      local old_after = plugin.after or {}
      plugin.after = function (p)
        require('lspconfig')[p.name].setup(old_after)
      end
      local oldfttype = type(old_after.filetypes)
      if oldfttype == "string" then
        plugin.ft = old_after.filetypes
      elseif oldfttype == "table" and #old_after.filetypes > 0 then
        plugin.ft = old_after.filetypes
      else
        vim.notify('lsp spec for "' .. plugin.name .. '" failed, no filetypes specified',
          vim.log.levels.ERROR, { title = "lzextras.lsp" })
      end
      return plugin
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
