--NOTE: I dont use this, I use the snacks.nvim gitbrowse
-- I just dont want to delete it because
-- it has some git commands I always forget when I need them, and easy gsub examples in it.
local M = {}

local function get_git_url_info(branch, local_path, select_start, select_end)
	local isCurrentPath = false
	local isCurrentBranch = false
	local path = local_path
	if path == nil then
		isCurrentPath = true
		path = vim.fn.expand("%:p")
		if path == "" then
			print("No file is open, nor was a path supplied")
			return
		end
	end
	if string.find(path, "oil://", 1, true) then
		path = path:sub(7, -1)
	end
	path = vim.fn.fnamemodify(path:gsub("\n", ""), ':p')
	local isDir = (vim.fn.isdirectory(path) == 1)
	local forgit = path
	if not isDir then
		forgit = path:match("(.*[/\\])")
	end
	local git_url = vim.fn.system("git -C " .. forgit .. " config --get remote.origin.url"):gsub("\n", "")
	if git_url == "" then
		print("Not a git repository")
		return
	elseif git_url:sub(-4) == ".git" then
		git_url = git_url:sub(1, -5)
	end
	-- gets the absolute path, then subtracts the git repository root from it and the /.
	local relgitpath = path:sub(#vim.fn.system("git -C " .. forgit .. " rev-parse --show-toplevel"):gsub("\n", "") + 2)
	local resolved_branch = vim.fn.system("git -C " .. forgit .. " branch --show-current"):gsub("\n", "")
	if branch == nil then
		isCurrentBranch = true
	elseif resolved_branch == branch then
		isCurrentBranch = true
	else
		resolved_branch = branch
	end

	local lnSuffix = ""
	if not isDir and ((isCurrentPath and isCurrentBranch) or (select_start ~= nil and select_end ~= nil)) then
		local stsel = select_start or vim.fn.line(".")
		local endsel = select_end or vim.fn.line("v")
		if stsel == endsel then
			lnSuffix = "#L" .. stsel
		elseif stsel < endsel then
			lnSuffix = "#L" .. stsel .. "-L" .. endsel
		elseif stsel > endsel then
			lnSuffix = "#L" .. endsel .. "-L" .. stsel
		end
	end
	return {
		git_url    = git_url,
		branch     = resolved_branch,
		relgitpath = relgitpath,
		lnSuffix   = lnSuffix,
	}
end

local function build_git_url(git_url, branch, relgitpath, lnSuffix)
	if string.find(git_url, "https://github.com", 1, true) then
		return git_url .. "/blob/" .. branch .. "/" .. relgitpath .. lnSuffix
	elseif string.find(git_url, "git@github.com", 1, true) then
		local new_git_url = "https://" .. git_url:sub(5):gsub(":", "/", 1)
		return new_git_url .. "/blob/" .. branch .. "/" .. relgitpath .. lnSuffix
	else
		print("currently only supports github.com links")
		return
	end
end

function M.get_git_remote_url(desired_branch, local_path, select_start, select_end)
	local url_info = get_git_url_info(desired_branch, local_path, select_start, select_end) or {}
	local git_url = url_info.git_url or ""
	local branch = url_info.branch or ""
	local relgitpath = url_info.relgitpath or ""
	local lnSuffix = url_info.lnSuffix or ""
	return build_git_url(git_url, branch, relgitpath, lnSuffix)
end

function M.git_url_to_clipboard(desired_branch, local_path, select_start, select_end)
	vim.fn.setreg("+", M.get_git_remote_url(desired_branch, local_path, select_start, select_end))
end

M.setup = function()
	vim.api.nvim_create_user_command('CopyGithubLink', function(args)
		local branch = (args.fargs or {})[1]
		local path = (args.fargs or {})[2]
		if branch ~= nil then
			branch = branch:sub(2, -2)
		end
		if path ~= nil then
			path = path:sub(2, -2)
		end
		M.git_url_to_clipboard(branch, path, args.line1, args.line2)
	end, { range = true })
	vim.keymap.set('', '<leader>gl', function() M.git_url_to_clipboard() end, { desc = 'Get git link' })
end

return M
