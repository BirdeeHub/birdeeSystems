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
if vim.g.vscode == nil then
  require("birdee")
else
  -- a stripped down version for embedding
  require('vscody')
end
