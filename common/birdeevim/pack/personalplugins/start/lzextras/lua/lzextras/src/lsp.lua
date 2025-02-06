---@class lzextras.LspPlugin: lze.Plugin
---@field lsp? any

local M = {
  ---@type lze.Handler
  handler = {
    spec_field = "lsp",
    ---@param plugin lzextras.LspPlugin
    modify = function(plugin)
      local lspfield = plugin.lsp
      if not lspfield then
        return plugin
      end
      if type(lspfield) ~= "table" then
        vim.notify('lsp spec for "' .. plugin.name .. '" failed, lsp field must be a table',
          vim.log.levels.ERROR, { title = "lzextras.lsp" })
        return plugin
      end
      plugin.load = function(name)
        require('lspconfig')[name].setup(lspfield)
      end
      local ftlist = lspfield.filetypes
      local oldfttype = type(ftlist)
      if oldfttype == "string" then
        plugin.ft = ftlist
      elseif oldfttype == "table" and #ftlist > 0 then
        plugin.ft = ftlist
      else
        vim.notify('lsp spec for "' .. plugin.name .. '" may never trigger, no plugin.lsp.filetypes specified',
          vim.log.levels.WARN, { title = "lzextras.lsp" })
      end
      return plugin
    end,
  },
}

return M
