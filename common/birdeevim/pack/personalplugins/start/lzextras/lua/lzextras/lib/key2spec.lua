---@param mode string|string[] Mode "short-name" (see |nvim_set_keymap()|), or a list thereof.
---@param lhs string           Left-hand side |{lhs}| of the mapping.
---@param rhs string|function  Right-hand side |{rhs}| of the mapping, can be a Lua function.
---@param opts? vim.keymap.set.Opts
---@return lze.KeysSpec
return function(mode, lhs, rhs, opts)
  ---@diagnostic disable-next-line: return-type-mismatch
  return vim.tbl_deep_extend("force", opts or {}, {
    [1] = lhs,
    [2] = rhs,
    mode = mode,
  })
end
