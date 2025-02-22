return {
  "nvim-lint",
  for_cat = "general.core",
  -- cmd = { "" },
  event = "FileType",
  -- ft = "",
  -- keys = "",
  -- colorscheme = "",
  after = function (_)
    require('lint').linters_by_ft = {
      -- markdown = {'vale',},
      kotlin = { 'ktlint' },
      cpp = { 'cpplint' },
      javascript = { 'eslint' },
      typescript = { 'eslint' },
      -- elixir = { 'credo' },
      go = { 'golangcilint' },
    }

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
}
