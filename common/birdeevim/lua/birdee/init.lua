-- TODO: this in another file and require here.
-- require('birdee.non_nix_download').setup({ your plugins })

-- vim.g.lze = {
--   load = vim.cmd.packadd,
--   verbose = true,
--   default_priority = 50,
--   without_default_handlers = false,
-- }
require('lze').register_handlers {
    require("nixCatsUtils.lzUtils").for_cat,
    require('lzextras').lsp,
}
require('lze').load {
  { import = "birdee.plugins" },
  { import = "birdee.LSPs" },
  { import = "birdee.debug", enabled = nixCats('debug') },
  { import = "birdee.format" },
  { import = "birdee.lint" },
}
