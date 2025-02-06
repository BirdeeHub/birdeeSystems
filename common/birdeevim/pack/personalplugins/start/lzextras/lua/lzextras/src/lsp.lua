---@class lzextras.LspPlugin: lze.Plugin
---@field lsp? any

---@type lze.Handler
return {
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
    local newftlist = type(lspfield.filetypes) == "string" and { lspfield.filetypes } or lspfield.filetypes
    local oldftlist = type(plugin.ft) == "string" and { plugin.ft } or plugin.ft
    ---@diagnostic disable-next-line: param-type-mismatch
    plugin.ft = vim.list_extend(newftlist or {}, oldftlist or {})
    return plugin
  end,
}
