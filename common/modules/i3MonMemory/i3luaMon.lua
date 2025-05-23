function os.mkdir_recursive(path)
  local lfs = require("lfs")
  local current_path = "/"
  for dir in path:gmatch("[^/\\]+") do
    current_path = current_path .. dir .. "/"
    lfs.mkdir(current_path)
  end
end
function string.dirname(str)
  return str:match("(.*[/\\])")
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

-- get config values and cache path
local nixinfo = require "nixinfo"
local newmonConfig = nixinfo.newmon
local alwaysRunConfig = nixinfo.always_run
local basecachepath = nixinfo.json_cache or ((os.getenv('XDG_CACHE_HOME')
    or os.getenv('HOME') .. '/.cache' or '/tmp') .. "/i3MonMemory/")
local userJsonCache = basecachepath .. os.getenv('USER') .."/userJsonCache.json"

-- get initial i3 info
local i3msgOut = os.capture([[i3-msg -t get_workspaces]], true)
local cjson = require "cjson.safe"
local i3wkspcInfo, err = cjson.decode(i3msgOut)
assert(err == nil, "unable to parse i3-msg output")
local byMon = {}
for _, v in ipairs(i3wkspcInfo) do
  if byMon[v.output] == nil then
    byMon[v.output] = { v.num }
  else
    table.insert(byMon[v.output], v.num)
  end
end

-- get initial and final active mons
local initial_mons = {}
local final_mons = {}
local initial_monstring = os.capture([[xrandr --listactivemonitors | awk '{print($4)}']], true)
os.execute([[xrandr --auto]])
local final_monstring = os.capture([[xrandr --listactivemonitors | awk '{print($4)}']], true)
for w in initial_monstring:gmatch("%S+") do
  table.insert(initial_mons, w)
end
for w in final_monstring:gmatch("%S+") do
  table.insert(final_mons, w)
end
local gonemon = table.remove_values(initial_mons, final_mons)
local newmon = table.remove_values(final_mons, initial_mons)

-- process gonemons and cache
local newCache = {}
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
  os.mkdir_recursive(string.dirname(userJsonCache))
  local whandle = io.open(userJsonCache, "w")
  if whandle then
      whandle:write(resultJson)
      whandle:close()
  end
end

-- create i3-msg commands to move workspaces and run xrandr scripts
if alwaysRunConfig ~= nil then
  os.execute(alwaysRunConfig .. " " .. table.concat(final_mons, " "))
end
local workspaceCommands = {}
local focusedWorkspaces = {}
local deferredCommand = nil
local newi3msgOut = cjson.decode(os.capture([[i3-msg -t get_workspaces]], true))
for _, v in pairs(newi3msgOut) do
  if v.focused == true then
    table.insert(focusedWorkspaces, v.num)
  end
end
local function mkWkspcCMD(wkspc, mon)
  return [[i3-msg "workspace number ]] .. wkspc .. [[, move workspace to output ]] .. mon .. [[";]]
end
for i, mon in ipairs(newmon) do
  if newmonConfig ~= nil then
    os.execute(newmonConfig .. " " .. mon)
  end
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
