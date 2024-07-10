local M = {}

-- these 3 files are intended to be independent. You will likely want at least something in this one,
-- but unless you use lazy.nvm or want to use pckr or rocks when not on nix, you wont need the other 2

---@type boolean
M.isNixCats = vim.g[ [[nixCats-special-rtp-entry-nixCats]] ] ~= nil

---@class nixCatsSetupOpts
---@field non_nix_value boolean|nil

---defaults to true if non_nix_value is not provided or is not a boolean.
---@param v nixCatsSetupOpts
function M.setup(v)
    if not M.isNixCats then
        local nixCats_default_value
        if type(v) == "table" and type(v.non_nix_value) == "boolean" then
            nixCats_default_value = v.non_nix_value
        else
            nixCats_default_value = true
        end
        -- if not in nix, just make it return a boolean
        require('_G').nixCats = function(_) return nixCats_default_value end
    end
end

---allows you to guarantee a boolean is returned, and also declare a different
---default value than specified in setup when not using nix to load the config
---@overload fun(v: string|table): boolean
---@overload fun(v: string|table, o: boolean): boolean
function M.enableForCategory(v, default)
  if M.isNixCats or default == nil then
    if nixCats(v) then
      return true
    else
      return false
    end
  else
    return default
  end
end

---for conditionally disabling build steps on nix, as they are done via nix
---I should probably have named it dontAddIfCats or something.
---@overload fun(v: any): any|nil
---@overload fun(v: any, o: any): any
function M.lazyAdd(v, o)
  if M.isNixCats then
    return o
  else
    return v
  end
end

return M
