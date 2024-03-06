function os.capture(cmd, trim)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if not trim then return s end
  s = string.gsub(s, '^%s+', "")
  s = string.gsub(s, '%s+$', "")
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end
function os.mkdir_recursive(path)
  local current_path = "/"
  for dir in path:gmatch("[^/\\]+") do
    current_path = current_path .. dir .. "/"
    require("lfs").mkdir(current_path)
  end
end
local function remove_values(table1, table2)
  local result = {}
  for i, value in ipairs(table1) do
    result[i] = value
  end
  for _, value in ipairs(table2) do
    for i, v in ipairs(result) do
      if v == value then
        table.remove(result, i)
        break
      end
    end
  end
  return result
end
local function dirname(str)
  return str:match("(.*[/\\])")
end

-- set userJsonCache location if not set by module
if userJsonCache == "" then
  if os.getenv('XDG_CACHE_HOME') ~= nil then
    userJsonCache = os.getenv('XDG_CACHE_HOME')
  elseif os.getenv('HOME') ~= nil then
    userJsonCache = os.getenv('HOME') .. '/.cache'
  end
  userJsonCache = userJsonCache .. "/i3MonMemory/" .. os.getenv('USER') .."/userJsonCache.json"
end

-- get initial i3 info
local i3msgOut = os.capture(paths["i3-msg"] .. " -t get_workspaces", true)
local cjson = require "cjson.safe"
local i3wkspcInfo, err = cjson.decode(i3msgOut)
if err ~= nil then
  return
end
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
local initial_monstring = os.capture(paths.xrandr
    .. [[ --listactivemonitors | ]] .. paths.awk .. [[ '{print($4)}']], true)
os.execute(paths.xrandr .. [[ --auto]])
local final_monstring = os.capture(paths.xrandr
    .. [[ --listactivemonitors | ]] .. paths.awk .. [[ '{print($4)}']], true)
for w in initial_monstring:gmatch("%S+") do
  table.insert(initial_mons, w)
end
for w in final_monstring:gmatch("%S+") do
  table.insert(final_mons, w)
end
local gonemon = remove_values(initial_mons, final_mons)
local newmon = remove_values(final_mons, initial_mons)

-- process gonemons and cache
local newCache = {}
local rhandle = io.open(userJsonCache, "r")
if rhandle then
  local cachedJson
  cachedJson = rhandle:read("*a")
  rhandle:close()
  newCache, err = cjson.decode(cachedJson)
  if err ~= nil then
    newCache = {}
  end
end
for _, mon in ipairs(gonemon) do
  for i, v in pairs(newCache) do
    if i ~= mon then
      newCache[i] = remove_values(v, byMon[mon])
    end
  end
  newCache[mon] = byMon[mon]
end
local resultJson
resultJson, err = cjson.encode(newCache)
if err == nil then
  os.mkdir_recursive(dirname(userJsonCache))
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
local newi3msgOut = cjson.decode(os.capture(paths["i3-msg"] .. " -t get_workspaces", true))
for _, v in pairs(newi3msgOut) do
  if v.focused == true then
    table.insert(focusedWorkspaces, v.num)
  end
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
          deferredCommand = paths["i3-msg"] .. [[ "workspace number ]] .. wkspc .. [[, move workspace to output ]] .. mon .. [[";]]
          break
        else
          table.insert(workspaceCommands, paths["i3-msg"] .. [[ "workspace number ]] .. wkspc .. [[, move workspace to output ]] .. mon .. [[";]])
          break
        end
      end
    else
      table.insert(workspaceCommands, paths["i3-msg"] .. [[ "workspace number ]] .. wkspc .. [[, move workspace to output ]] .. mon .. [[";]])
    end
  end
end

-- run all the moves last after the xrandring is completed.
os.execute(table.concat(workspaceCommands, " "))
if deferredCommand ~= nil then
  os.execute(deferredCommand)
end
