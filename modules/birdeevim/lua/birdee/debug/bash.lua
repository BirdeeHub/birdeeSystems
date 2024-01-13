local dap = require "dap"
dap.adapters.sh = {
    type = 'executable',
    command = vim.fn.exepath('bashdb')
}

dap.configurations.sh = {
    {
        name = "Launch Bash Debugger",
        type = "sh",
        request = "launch",
        program = "${file}",
        cwd = "${fileDirname}",
        pathBashdb = vim.fn.exepath('bashdb'),
        pathBashdbLib = vim.fn.fnamemodify(vim.fn.exepath('bashdb'), ":h") .. "/../share/bashdb",
        pathBash = "bash",
        pathCat = "cat",
        pathMkfifo = "mkfifo",
        pathPkill = "pkill",
        env = {},
        args = {},
    }
}
