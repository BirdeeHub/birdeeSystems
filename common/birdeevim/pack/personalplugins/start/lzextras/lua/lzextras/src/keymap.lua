local key2spec = require("lzextras.src.key2spec")
return function (plugin)
  local plugin_name = type(plugin) == "table" and (plugin.name or plugin[1]) or plugin
  if type(plugin) == "table" then
    require('lze').load(plugin)
  end
  return {
    ---@param mode string|string[] Mode "short-name" (see |nvim_set_keymap()|), or a list thereof.
    ---@param lhs string           Left-hand side |{lhs}| of the mapping.
    ---@param rhs string|function  Right-hand side |{rhs}| of the mapping, can be a Lua function.
    ---@param opts? vim.keymap.set.Opts
    set = function(mode, lhs, rhs, opts)
      if require("lze").state(plugin_name) == false then
        vim.keymap.set(mode, lhs, rhs, opts)
        return
      elseif require("lze").state(plugin_name) == nil then
        -- NOTE: Technically this case would be fine,
        -- but then, if this key is pressed
        -- before the lze spec is loaded by configuration,
        -- it wont have anything to load.
        -- I think the chances of this are basically 0, but who knows,
        -- maybe someone only sets up the lze spec
        -- in the command spec of another plugin.
        -- Will re evaluate how I feel about this later after testing and stuff
        vim.notify('setting keybind for "' .. plugin_name .. '" failed, no corresponding lze spec loaded',
          vim.log.levels.WARN, { title = "lzextras.keymap.set" })
        return
      end
      require("lze.h.keys").add({
        name = plugin_name,
        keys = {
          key2spec(mode, lhs, rhs, opts),
        },
      })
    end
  }
end
