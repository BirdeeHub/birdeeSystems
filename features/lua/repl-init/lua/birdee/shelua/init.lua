local M = {}
local MP = ...
M.system = require(MP .. '.system')
M.add_reprs = function (sh, ...)
    ---@cast sh Shelua
    sh = sh or require('sh')
    local sherun = M.system.run
    for _, v in ipairs({...}) do
      sh[{'repr', v}] = require(MP .. '.repr.' .. v)(sh, sherun)
    end
    return sh
end
M.add_all_reprs = function (sh)
  ---@cast sh Shelua
  sh = sh or require('sh')
  local sherun = M.system.run
  for _, v in ipairs({"uv", "posix_plus"}) do
    sh[{'repr', v}] = require(MP .. '.repr.' .. v)(sh, sherun)
  end
  return sh
end
return M
