vim.api.nvim_create_user_command('CopyGithubLink', function(args)
    local branch = (args.fargs or {})[1]
    local path = (args.fargs or {})[2]
    if branch ~= nil then
        branch = branch:sub(2, -2)
    end
    if path ~= nil then
        path = path:sub(2, -2)
    end
    require('birdee.git-remote-url').git_url_to_clipboard(branch, path, args.line1, args.line2)
end, { range = true })
