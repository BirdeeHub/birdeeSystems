if os.getenv('WAYLAND_DISPLAY') and vim.fn.exepath('wl-copy') ~= "" then
  vim.g.clipboard = {
      name = 'wl-clipboard',
      copy = {
          ['+'] = 'wl-copy',
          ['*'] = 'wl-copy',
      },
      paste = {
          ['+'] = 'wl-paste',
          ['*'] = 'wl-paste',
      },
      cache_enabled = 1,
  }
end
vim.filetype.add {
  extension = {
    templ = "templ",
    tmpl = "templ",
    ebnf = "EBNF",
    bnf = "EBNF",
    EBNF = "EBNF",
  }
}
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
require('nixCatsUtils').setup { non_nix_value = true }
require('birdee')
