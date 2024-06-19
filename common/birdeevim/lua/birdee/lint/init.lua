require('lz.n').load({
  "nvim-lint",
  -- cmd = { "" },
  event = "BufReadPre",
  -- ft = "",
  -- keys = "",
  -- colorscheme = "",
  load = function (name)
    local list = {
      name,
    }
    require("birdee.utils").safe_packadd_list(list)
  end,
  after = function (plugin)
    require('lint').linters_by_ft = {
      -- markdown = {'vale',},
      kotlin = { 'ktlint' },
      cpp = { 'cpplint' },
      javascript = { 'eslint' },
      typescript = { 'eslint' },
      -- elixir = { 'credo' },
    }

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
})
