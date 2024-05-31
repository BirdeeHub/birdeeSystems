local dap = require "dap"
dap.adapters.elixir = {
    type = 'executable',
    command = vim.fn.exepath('elixir-debug-adapter')
}

dap.configurations.elixir = {
    {
        name = "Launch Elixir Debugger",
        type = "elixir",
        request = "launch",
        program = "${file}",
        cwd = "${fileDirname}",
        env = {},
        args = {},
    }
}
