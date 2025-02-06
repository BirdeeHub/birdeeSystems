local global_config = {
    tmux_autoclose_windows = false,
}
local utils = require("birdee.utils")

local M = {}
local tmux_windows = {}

if global_config.tmux_autoclose_windows then
    local grapple_tmux_group = vim.api.nvim_create_augroup(
        "GRAPPLE_TMUX",
        { clear = true }
    )

    vim.api.nvim_create_autocmd("VimLeave", {
        callback = function()
            require("birdee.fossil.tmux").clear_all()
        end,
        group = grapple_tmux_group,
    })
end

local function create_terminal()
    local window_id

    -- Create a new tmux window and store the window id
    local out, ret, _ = utils.get_os_command_output({
        "tmux",
        "new-window",
        "-P",
        "-F",
        "#{pane_id}",
    }, vim.loop.cwd())

    if ret == 0 then
        window_id = out[1]:sub(2)
    end

    if window_id == nil then
        return nil
    end

    return window_id
end

-- Checks if the tmux window with the given window id exists
local function terminal_exists(window_id)
    local exists = false

    local window_list, _, _ = utils.get_os_command_output({
        "tmux",
        "list-windows",
    }, vim.loop.cwd())

    -- This has to be done this way because tmux has-session does not give
    -- updated results
    for _, line in pairs(window_list) do
        local window_info = utils.split_string(line, "@")[2]

        if string.find(window_info, string.sub(window_id, 2)) then
            exists = true
        end
    end

    return exists
end

local function find_terminal(args)
    if type(args) == "string" then
        -- assume args is a valid tmux target identifier
        -- if invalid, the error returned by tmux will be thrown
        return {
            window_id = args,
            pane = true,
        }
    end

    if type(args) == "number" then
        args = { idx = args }
    end

    local window_handle = tmux_windows[args.idx]
    local window_exists

    if window_handle then
        window_exists = terminal_exists(window_handle.window_id)
    end

    if not window_handle or not window_exists then
        local window_id = create_terminal()

        if window_id == nil then
            error("Failed to find and create tmux window.")
            return
        end

        window_handle = {
            window_id = "%" .. window_id,
        }

        tmux_windows[args.idx] = window_handle
    end

    return window_handle
end

function M.gotoTerminal(idx)
    local window_handle = find_terminal(idx)

    local _, ret, stderr = utils.get_os_command_output({
        "tmux",
        window_handle.pane and "select-pane" or "select-window",
        "-t",
        window_handle.window_id,
    }, vim.loop.cwd())

    if ret ~= 0 then
        error("Failed to go to terminal." .. stderr[1])
    end
end

function M.clear_all()
    for _, window in pairs(tmux_windows) do
        -- Delete the current tmux window
        utils.get_os_command_output({
            "tmux",
            "kill-window",
            "-t",
            window.window_id,
        }, vim.loop.cwd())
    end

    tmux_windows = {}
end

function M.valid_index(idx)
    if idx == nil or idx > M.get_length() or idx <= 0 then
        return false
    end
    return true
end

local function convertToIntegerOrString(value)
    local number = tonumber(value)
    if number and number % 1 == 0 then
        return math.floor(number)
    else
        return value
    end
end

---if integer, will go to window id, otherwise, you may put any valid tmux pane identifier such as tmux://{right-of}
function M.grapple_tmux(value)
    M.gotoTerminal(convertToIntegerOrString(value))
end

return M
