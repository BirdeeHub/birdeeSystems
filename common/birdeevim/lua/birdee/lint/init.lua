require('lint').linters_by_ft = {
  -- markdown = {'vale',},
  kotlin = { 'ktlint' },
  cpp = { 'cpplint' },
  javascript = { 'eslint' },
  typescript = { 'eslint' },
  elixir = { 'credo' },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})
