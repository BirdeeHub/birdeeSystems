-- Vibe commenting to remind me how this s*** works

--[[
specials.lua — UV Backend Special Command Combinators
=====================================================
Shelua's POSIX repr serializes AND/OR/CD into shell operators like `&&`, `||`,
and the `cd` builtin. But the UV repr doesn't go through a shell — it spawns
processes directly via libuv. So AND, OR, and CD must be handled in Lua.

This module defines "Special" objects that hook into the UV repr's
concat_cmd, single_stdin, and run_cmd to implement these control-flow
primitives entirely in-process.

Each Special has three methods:
  resolve(opts, cmd, input) → closure
    Called by concat_cmd when proper_pipes=true. Returns a lazy closure
    that, when invoked, decides which commands actually run based on
    exit codes (for AND/OR) or sets cwd (for CD).

  single(opts, cmd, inputs, codes) → result closure
    Called by single_stdin when proper_pipes=false. Returns a closure
    that constructs the result table directly from prior codes/inputs.

  recieve(opts, resolved) → mkopts_fn?, data_to_write?
    Called during pipeline resolution to extract data from a special's
    resolved result and pass it to the next command in the pipeline.
]]

--- @type table<string, Shelua.Special>
local M = {}

--- @alias Shelua.Special.resolved any|Shelua.SystemObj

--- @class Shelua.Special
--- @field name? string
--- @field single fun(opts, cmd, inputs, codes): string[]|fun():Shelua.SystemCompleted, { env: table<string, string|number>, towrite: any[] }
--- @field resolve fun(opts, cmd, inputs): fun():Shelua.Special.resolved
--- @field recieve? fun(opts, res: Shelua.Special.resolved): nil|(fun(og: Shelua.SystemOpts):Shelua.SystemOpts), any[]?

--╔══════════════════════════════════════════════════════════════════════╗
--║  concat_inputs — helper used by AND, OR, and CD                    ║
--║                                                                     ║
--║  Takes a pre-evaluated first result (v0) and the remaining raw     ║
--║  input descriptors. Runs each remaining input sequentially,        ║
--║  concatenating their stdout/stderr into flat strings. Returns a    ║
--║  SystemObj-like table with .wait() that produces the final result. ║
--║                                                                     ║
--║  This is the UV backend's equivalent of "collect all prior pipe    ║
--║  output and merge it into one stream". Since there's no real shell ║
--║  pipe, we just run everything sequentially and concatenate.         ║
--╚══════════════════════════════════════════════════════════════════════╝
local function concat_inputs(v0, input, cwd_override)
  -- Returns a closure so we're lazy — nothing runs until .wait() is called.
  return function()
    local full_out, full_err = {}, {}
    -- First input: already evaluated (v0 is a full result table)
    if type(v0.stdout) == "string" then table.insert(full_out, v0.stdout) end
    if type(v0.stderr) == "string" then table.insert(full_err, v0.stderr) end
    local last_code, last_signal
    local last_cwd = v0.cwd

    -- Remaining inputs: evaluate each one
    for i = 2, #input do
      local v = input[i]
      local result
      if v.c then
        -- Input is a command closure — run it to completion
        result = v.c():wait()
      else
        -- Input is a plain string (v.s) with optional metadata (v.e)
        local ce = v.e or {}
        result = {
          stdout = v.s,
          code = ce.__exitcode or 0,
          signal = ce.__signal or 0,
          stderr = ce.__stderr,
          cwd = ce.__cwd or nil,
        }
      end
      if type(result.stdout) == "string" then table.insert(full_out, result.stdout) end
      if type(result.stderr) == "string" then table.insert(full_err, result.stderr) end
      last_code, last_signal, last_cwd = result.code, result.signal, result.cwd or last_cwd
    end

    -- Return a SystemObj-like table with .wait()
    return {
      wait = function ()
        return {
          stdout = table.concat(full_out),
          stderr = table.concat(full_err),
          code = last_code or 0,
          signal = last_signal or 0,
          cwd = cwd_override or last_cwd or nil,
        }
      end,
    }
  end
end

--╔══════════════════════════════════════════════════════════════════════╗
--║  CD  —  "Change Directory"                                         ║
--║                                                                     ║
--║  CD doesn't spawn a process — it just stamps the result with a     ║
--║  __cwd field. Subsequent commands in the pipeline read __cwd from   ║
--║  their input and pass it to uv.spawn's `cwd` option.               ║
--║                                                                     ║
--║  Input piping still works: stdin from prior commands flows through  ║
--║  CD unmodified.                                                     ║
--╚══════════════════════════════════════════════════════════════════════╝
M.CD = {
  -- proper_pipes=false path: return a synthetic result with __cwd set.
  -- This bypasses uv.spawn entirely — the result is crafted in Lua.
  single = function(opts, cmd, inputs, codes)
    return function()
      local result = {
        __input = false,
        __exitcode = 0,
        __signal = 0,
        __cwd = cmd[2] or error("cd requires a target directory"),
      }
      -- Flow any prior stdin/stderr through unchanged,
      -- adopting the last non-zero exit code.
      for i, v in ipairs(inputs or {}) do
        local c = codes[i] or {}
        if v then
          result.__input = (result.__input or "") .. v
        end
        if c.__stderr then
          result.__stderr = (result.__stderr or "") .. c.__stderr
        end
        result.__exitcode = c.__exitcode or result.__exitcode
        result.__signal = c.__signal or result.__signal
      end
      return result
    end
  end,

  -- proper_pipes=true path: evaluate all inputs, set cwd on the result.
  resolve = function (opts, cmd, input)
    local cwd = cmd[2] or error("cd requires a target directory")
    local v0 = input[1] or {}
    if v0.c then
      return concat_inputs(v0.c():wait(), input, cwd)
    elseif v0.s then
      local c0 = v0.e or {}
      return concat_inputs({
        stdout = v0.s or false,
        code = c0.__exitcode or 0,
        signal = c0.__signal or 0,
        stderr = c0.__stderr,
      }, input, cwd)
    else
      -- No prior input at all — just return the cwd as a no-op
      return function()
        return {
          wait = function ()
            return {
              stdout = false,
              code = 0,
              signal = 0,
              stderr = "",
              cwd = cwd,
            }
          end
        }
      end
    end
  end,

  -- Called when piped data from this CD result feeds the next command.
  -- Extracts the cwd and stdout from the resolved result.
  recieve = function (opts, res)
    local c = res():wait()
    return function(prev)
      prev.cwd = c.cwd or prev.cwd
      return prev
    end, c.stdout
  end,
}
M.cd = M.CD  -- lowercase alias

--╔══════════════════════════════════════════════════════════════════════╗
--║  AND (&&)  —  Run second command only if first succeeds            ║
--║                                                                     ║
--║  Semantics: evaluate commands left to right. If any fails          ║
--║  (exit code ≠ 0), short-circuit and return that failure.           ║
--║  If all succeed, concatenate all output.                           ║
--╚══════════════════════════════════════════════════════════════════════╝
M.AND = {
  -- proper_pipes=false: check the exit code of the first command.
  -- If it succeeded (code=0), return the LAST command's result
  -- with all inputs concatenated. If it failed, return the FIRST
  -- command's result (short-circuit).
  single = function (opts, cmd, inputs, codes)
    if not inputs or #inputs < 2 then error("AND requires at least 2 commands") end
    local c0 = codes[1]
    local cf = codes[#codes]
    if (c0.__exitcode or 0) == 0 then
      return function()
        cf.__input = table.concat(inputs)
        -- Propagate __cwd from any code in the chain
        for _, v in ipairs(codes) do
          if type(v) == "table" then
            cf.__cwd = v.__cwd
          end
        end
        return cf
      end
    else
      return function()
        c0.__input = inputs[1] or false
        return c0
      end
    end
  end,

  -- proper_pipes=true: evaluate the first input. If it fails, return it.
  -- If it succeeds, concatenate all remaining inputs.
  resolve = function (opts, cmd, input)
    local v0 = input[1]
    if v0.c then
      v0 = v0.c():wait()
    elseif v0.s then
      local c0 = v0.e or {}
      v0 = {
        stdout = v0.s or false,
        code = c0.__exitcode or 0,
        signal = c0.__signal or 0,
        stderr = c0.__stderr,
        cwd = c0.__cwd or opts.cwd or nil,
      }
    else
      error("NOT ENOUGH ARGS for AND")
    end
    if (v0.code or 0) ~= 0 then
      -- Short-circuit: first command failed, return its result
      return function()
        return {
          wait = function ()
            v0.stdout = v0.stdout or false
            return v0
          end
        }
      end
    else
      return concat_inputs(v0, input)
    end
  end,
}
M["&&"] = M.AND  -- operator alias

--╔══════════════════════════════════════════════════════════════════════╗
--║  OR (||)  —  Run second command only if first FAILS                ║
--║                                                                     ║
--║  Semantics: evaluate first command. If it succeeds (code=0),       ║
--║  short-circuit and return it. If it fails, run remaining commands  ║
--║  and concatenate their output.                                     ║
--╚══════════════════════════════════════════════════════════════════════╝
M.OR = {
  -- proper_pipes=false: mirror of AND logic but inverted.
  single = function(opts, cmd, inputs, codes)
    if not inputs or #inputs < 2 then error("OR requires at least 2 commands") end
    local c0 = codes[1]
    local cf = codes[#codes]
    if c0.__exitcode == 0 then
      return function()
        c0.__input = inputs[1] or false
        return c0
      end
    else
      return function()
        cf.__input = table.concat(inputs)
        for _, v in ipairs(codes) do
          if type(v) == "table" then
            cf.__cwd = v.__cwd
          end
        end
        return cf
      end
    end
  end,

  -- proper_pipes=true: evaluate first input. If it succeeds, return it.
  -- If it fails, concatenate all remaining inputs.
  resolve = function(opts, cmd, input)
    local v0 = input[1]
    if v0.c then
      v0 = v0.c():wait()
    elseif v0.s then
      local c0 = v0.e or {}
      v0 = {
        stdout = v0.s or false,
        code = c0.__exitcode or 0,
        signal = c0.__signal or 0,
        stderr = c0.__stderr,
        cwd = c0.__cwd or opts.cwd or nil,
      }
    else
      error("NOT ENOUGH ARGS for OR")
    end
    if (v0.code or 0) == 0 then
      -- Short-circuit: first command succeeded
      return function()
        return {
          wait = function ()
            v0.stdout = v0.stdout or false
            return v0
          end
        }
      end
    else
      return concat_inputs(v0, input)
    end
  end,
}
M["||"] = M.OR  -- operator alias

--╔══════════════════════════════════════════════════════════════════════╗
--║  mkSpecial — wraps raw spec tables into Special objects            ║
--║                                                                     ║
--║  Sets a default recieve method (extracts stdout from resolved),    ║
--║  stamps the name, and gives each Special a __tostring metamethod   ║
--║  so it can participate in error messages meaningfully.             ║
--╚══════════════════════════════════════════════════════════════════════╝
--- @param spec Shelua.Special
local function mkSpecial(spec) return setmetatable({
  name = spec.name,
  resolve = spec.resolve,
  single = spec.single,
  recieve = spec.recieve or function (c) return nil, c():wait().stdout end,
}, { __tostring = function() return spec.name end }) end

-- Apply mkSpecial to every entry in M, keyed by name.
for key, value in pairs(M) do
  value.name = key
  M[key] = mkSpecial(value)
end

return M
