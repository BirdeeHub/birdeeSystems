os.env = require "osenv"
os.sh = require "sh"
os.lfs = require "lfs"
local cjson = require "cjson.safe"
-- local inspect = require "inspect"
local utils = require "i3MonagerUtils"

-- get config values and cache path
local nixinfo = require "nixinfo"
os.env.PATH = nixinfo.extra_path .. ":" .. os.env.PATH
local basecachepath = nixinfo.json_cache or ((os.getenv('XDG_CACHE_HOME') or os.getenv('HOME') .. '/.cache' or '/tmp') .. "/i3Monager/")
local userJsonCacheDir = basecachepath .. os.getenv('USER')
local userJsonCache = userJsonCacheDir.."/userJsonCache.json"
local trigger_file_dir = nixinfo.trigger_file_dir
local trigger_file_name = nixinfo.trigger_file_name
local isBoot = arg[1] == "boot"
local ipccmd = nixinfo.ipc_cmd or "i3-msg"

function os.mkdir_recursive(path)
  local current_path = "/"
  for dir in path:gmatch("[^/\\]+") do
    current_path = current_path .. dir .. "/"
    os.lfs.mkdir(current_path)
  end
end
function os.capture(cmd, trim)
  local f = assert(io.popen(cmd, 'r'), "unable to execute: " .. cmd)
  local s = assert(f:read('*a'), "unable to read output of: " .. cmd)
  f:close()
  if not trim then return s end
  s = string.gsub(s, '^%s+', "")
  s = string.gsub(s, '%s+$', "")
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end
function table.remove_values(OG, rmv)
  local result = {}
  for i, value in ipairs(OG) do
    result[i] = value
  end
  for _, value in ipairs(rmv) do
    for i, v in ipairs(result) do
      if v == value then
        table.remove(result, i)
        break
      end
    end
  end
  return result
end
local function awkFourth(str)
  local mons = {}
  for line in str:gmatch("[^\n]+") do
    local mon = line:match("^%s*%S+%s+%S+%s+%S+%s+(%S+)")
    if mon then table.insert(mons, mon) end
  end
  return mons
end

local function getMonitors()
  if ipccmd == "i3-msg" then
    return awkFourth(os.capture([[xrandr --listmonitors]]))
  else
    -- TODO: check that this branch works
    local str = os.capture([[swaymsg -rt get_outputs]])
    local outputs = assert(cjson.decode(str))
    local mons = {}
    for _, output in ipairs(outputs) do
      if output.active then
        mons[#mons + 1] = output.name
      end
    end
    return mons
  end
end

local function getInitialWorkspaces(maxRetries)
  maxRetries = maxRetries or 1
  local baseDelay = 0.5 -- 500ms
  for attempt = 1, maxRetries do
    local i3msgOut = os.capture(ipccmd .. [[ -t get_workspaces]], true)
    local i3wkspcInfo, err = cjson.decode(i3msgOut)
    if i3wkspcInfo ~= nil then
      return i3wkspcInfo
    end
    io.stderr:write(
      "failed to get initial workspaces (attempt "
        .. attempt .. "/"
        .. maxRetries .. "): "
        .. tostring(err)
        .. "\n"
    )
    if attempt < maxRetries then
      local delay = baseDelay * (2 ^ (attempt - 1))
      utils.sleep(delay)
    end
  end
  error("unable to get initial i3 workspace information")
end

local watcher
if not isBoot then
  os.mkdir_recursive(trigger_file_dir)
  watcher = utils.watch_dir(trigger_file_dir)
end

while true do

  -- TODO: I think sway might need you to do this in a different place?
  -- But we need to read initial workspaces before they are changed, but not forever before, like, right before
  if not isBoot then
    io.stdout:write("waiting for trigger file to be written to...\n")
    if not pcall(watcher.wait, watcher, trigger_file_name) then
      break
    end
  end

  local byMon = {}
  if not isBoot then
    -- get initial i3 info
    local i3wkspcInfo = getInitialWorkspaces()
    for _, v in ipairs(i3wkspcInfo) do
      if byMon[v.output] == nil then
        byMon[v.output] = { v.num }
      else
        table.insert(byMon[v.output], v.num)
      end
    end
  end
  -- get initial active mons
  local initial_mons = getMonitors()
  -- get xrandr to detect the new monitors
  if ipccmd == "i3-msg" then
    os.execute([[xrandr --auto]])
  end
  -- get final active mons
  local final_mons = getMonitors()

  local gonemon = table.remove_values(initial_mons, final_mons)
  local newmon = table.remove_values(final_mons, initial_mons)

  local err
  -- process gonemons and cache
  local newCache = {}
  if not isBoot then
    local rhandle = io.open(userJsonCache, "r")
    if rhandle then
      local cachedJson = rhandle:read("*a")
      rhandle:close()
      newCache, err = cjson.decode(cachedJson)
      if err ~= nil then newCache = {} end
    end
    for _, mon in ipairs(gonemon) do
      for i, v in pairs(newCache) do
        if i ~= mon then
          newCache[i] = table.remove_values(v, byMon[mon])
        end
      end
      newCache[mon] = byMon[mon]
    end
    local resultJson
    resultJson, err = cjson.encode(newCache)
    if err == nil then
      os.mkdir_recursive(userJsonCacheDir)
      local whandle = io.open(userJsonCache, "w")
      if whandle then
          whandle:write(resultJson)
          whandle:close()
      end
    end
  end

  -- call user lua monitor config script to run xrandr or equivalent swaymsg commands
  -- TODO: pass some functions for user to do this agnostically of window manager
  local chunk
  chunk, err = loadfile(nixinfo.config_script)
  if chunk then
    local ok
    ok, err = pcall(chunk, {
      boot = isBoot,
      newmons = newmon,
      gonemons = gonemon,
      initial_mons = initial_mons,
      final_mons = final_mons
    })
    if not ok then
      io.stderr:write("error running monitor config script: " .. err .. "\n")
    end
  else
    io.stderr:write("error loading monitor config script: " .. err .. "\n")
  end

  if isBoot then break end

  -- create i3-msg or swaymsg commands to move workspaces after monitor setup script was ran
  local workspaceCommands = {}
  local focusedWorkspaces = {}
  local deferredCommand = nil
  local newi3msgOut = cjson.decode(os.capture(ipccmd .. [[ -t get_workspaces]], true))
  for _, v in pairs(newi3msgOut) do
    if v.focused == true then
      table.insert(focusedWorkspaces, v.num)
    end
  end
  local function mkWkspcCMD(wkspc, mon)
    return ipccmd .. [[ "workspace number ]] .. wkspc .. [[, move workspace to output ]] .. mon .. [[";]]
  end
  for i, mon in ipairs(newmon) do
    for j, wkspc in ipairs(newCache[mon]) do
      if i == 1 and j == 1 then
        for _, v in ipairs(focusedWorkspaces) do
          if v == wkspc then
            -- if the first workspace is focused, we will put it off until last
            -- because you cant move a focused workspace to another output
            deferredCommand = mkWkspcCMD(wkspc, mon)
            break
          else
            table.insert(workspaceCommands, mkWkspcCMD(wkspc, mon))
            break
          end
        end
      else
        table.insert(workspaceCommands, mkWkspcCMD(wkspc, mon))
      end
    end
  end
  -- run all the moves last after the xrandring is completed.
  os.execute(table.concat(workspaceCommands, " ") .. (deferredCommand or ""))
end

if not isBoot then
  watcher:close()
end
