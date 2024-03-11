local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    lua = { "stylua" },
    go = { "gofmt", "golint" },
    -- Conform will run multiple formatters sequentially
    python = { "isort", "black" },
    kotlin = { 'ktlint' },
    c = { "clang_format" },
    cpp = { "clang_format" },
    cmake = { "cmake_format" },
    -- Use a sub-list to run only the first available formatter
    -- javascript = { { "prettierd", "prettier" } },
  },
})

vim.keymap.set({ "n", "v" }, "<leader>FF", function()
  conform.format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
  })
end, { desc = "[F]ormat [F]ile" })


-- vim.keymap.set("n", "<leader>Fm", "<cmd>Format<CR>", { noremap = true, desc = '[F]or[m]at (lsp)' })


