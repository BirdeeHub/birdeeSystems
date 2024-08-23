require('lze').load {
  "which-key.nvim",
  -- cmd = { "" },
  event = "DeferredUIEnter",
  -- ft = "",
  -- keys = "",
  -- colorscheme = "",
  after = function (plugin)
    require('which-key').setup({})
    local leaderCmsg
    if nixCats('AI') then
      leaderCmsg = "[C]ode (and [C]ody)"
    else
      leaderCmsg = "[C]ode"
    end
    require('which-key').add {
    { "<leader><leader>", group = "buffer commands" },
    { "<leader><leader>_", hidden = true },
    { "<leader>F", group = "[F]ormat" },
    { "<leader>F_", hidden = true },
    { "<leader>c", group = leaderCmsg },
    { "<leader>c_", hidden = true },
    { "<leader>d", group = "[D]ocument" },
    { "<leader>d_", hidden = true },
    { "<leader>g", group = "[G]it" },
    { "<leader>g_", hidden = true },
    { "<leader>h", group = "[H]arpoon" },
    { "<leader>h_", hidden = true },
    { "<leader>m", group = "[M]arkdown" },
    { "<leader>m_", hidden = true },
    { "<leader>r", group = "[R]ename" },
    { "<leader>r_", hidden = true },
    { "<leader>s", group = "[S]earch" },
    { "<leader>s_", hidden = true },
    { "<leader>w", group = "[W]orkspace" },
    { "<leader>w_", hidden = true },
  }
  end,
}
