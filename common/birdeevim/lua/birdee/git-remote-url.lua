local M = {}

local function get_git_url_info(branch, local_path)
	local isCurrentPath = false
	local path = local_path
	if path == nil then
		isCurrentPath = true
		path = vim.fn.expand("%")
		if path == "" then
			print("No file is open, nor was a path supplied")
			return
		end
	end
	path = path:gsub("\n", "")
	if string.find(path, "oil://", 1, true) then
		path = path:sub(7, -1)
	end
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
	local relgitpath = path:sub(#vim.fn.system("git -C " .. forgit .. " rev-parse --show-toplevel"):gsub("\n", "") + 2)
	local resolved_branch = branch
	if resolved_branch == nil then
		resolved_branch = vim.fn.system("git -C " .. forgit .. " branch --show-current"):gsub("\n", "")
	end
	local lnSuffix = ""
	if not isDir and isCurrentPath then
		local stsel = vim.fn.line(".")
		local endsel = vim.fn.line("v")
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

function M.get_git_remote_url(desired_branch, local_path)
	local url_info = get_git_url_info(desired_branch, local_path) or {}
	local git_url = url_info.git_url or ""
	local branch = url_info.branch or ""
	local relgitpath = url_info.relgitpath or ""
	local lnSuffix = url_info.lnSuffix or ""
	local combined = build_git_url(git_url, branch, relgitpath, lnSuffix)
	return combined
end

function M.git_url_to_clipboard(desired_branch, local_path)
	  vim.fn.setreg("+", M.get_git_remote_url(desired_branch, local_path))
end

return M
