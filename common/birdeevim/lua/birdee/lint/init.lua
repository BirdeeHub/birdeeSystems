require('lze').load({
  "nvim-lint",
  -- cmd = { "" },
  event = "BufReadPost",
  -- ft = "",
  -- keys = "",
  -- colorscheme = "",
  load = function (name)
    require("birdee.utils").safe_packadd({
      name,
    })
  end,
  after = function (plugin)
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
})
