local M = {}
--  This function gets run when an LSP connects to a particular buffer.
function M.on_attach(_, bufnr)
  
end

function M.get_capabilities()
  -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
  --vim.tbl_extend('keep', capabilities, require'coq'.lsp_ensure_capabilities())
  --vim.api.nvim_out_write(vim.inspect(capabilities))
  return capabilities
end

return M
