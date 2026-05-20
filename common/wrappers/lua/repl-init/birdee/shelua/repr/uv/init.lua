-- Vibe commenting to remind me how this s*** works

--[[
uv/init.lua — The UV Backend Representation
============================================
This is shelua's "UV backend" — a complete representation (repr) that
translates shelua's shell DSL into direct libuv process spawning instead
of shell command strings.

Architecture vs. the POSIX repr:
  POSIX repr:  shelua DSL → bash string → bash -c "string" → child process
  UV repr:     shelua DSL → function closure → uv.spawn() → child process

Key advantages of the UV approach:
  - No shell injection: strings are never interpreted by a shell.
  - No escaping needed: escape = identity, since argv is passed natively.
  - Process metadata: exit codes, signals, stderr, cwd are all first-class.
  - Control-flow in Lua: AND/OR/CD are implemented as Lua logic, not
    shell operators — so we get proper short-circuit evaluation and
    error handling.
  - Proper pipes: when proper_pipes=true, we pipe data between processes
    at the libuv level using write_many() with uv_stream_t handles.

How it works (proper_pipes=true):
  1. shelua resolves a chain like `ls /tmp : grep foo : wc -l`
     by calling concat_cmd bottom-up.
  2. concat_cmd returns a FUNCTION (not a string). Each function,
     when called, spawns the command via sherun (shelua.system.run),
     pipes stdin from prior results, and returns a SystemObj.
  3. run_cmd calls the function, waits for completion, and returns
     a standardized { __input, __stderr, __exitcode, __signal, __cwd }.

How it works (proper_pipes=false):
  1. single_stdin collects all prior output strings and builds
     env/cwd overrides.
  2. run_cmd spawns the process directly with the concatenated stdin.
]]

local MP = ...
--- @param sh Shelua
return function(sh, sherun)
  --╔══════════════════════╗
  --║  Repr method table   ║
  --╚══════════════════════╝
  --- @type Shelua.Repr
  ---@diagnostic disable-next-line: missing-fields
  local representation = {
    -- Identity escape: we pass argv directly via uv.spawn, so no shell
    -- escaping is ever needed. This is the whole point of the UV backend.
    escape_args = false,

    -- Translate shelua's key-value argument DSL into flag strings.
    -- Same logic as posix — single char → "-k", multi char → "--key".
    arg_tbl = function(opts, k, a)
      k = (#k > 1 and '--' or '-') .. k
      if type(a) == 'boolean' and a then return k end
      if type(a) == 'string' then return { k, tostring(a) } end
      if type(a) == 'number' then return { k, tostring(a) } end
      return nil
    end,

    -- Build the final command "array" (actually a table with __tostring).
    -- Unlike POSIX which concatenates "cmd arg1 arg2", UV returns a table
    -- suitable for passing to uv.spawn: { "/bin/ls", "-la", "/tmp" }.
    -- The __tostring metamethod preserves error messages and tostring().
    add_args = function(opts, cmd, args)
      return setmetatable({ cmd, unpack(args) }, {
        __tostring = function(self) return table.concat(self, " ") end,
      })
    end,

    -- extra_cmd_results tells shelua's resolver that accessing __env,
    -- __stderr, or __cwd on a result should trigger pipe resolution
    -- (because they may only exist after the command runs).
    extra_cmd_results = { "__env", "__stderr", "__cwd" },
  }

  local SPECIAL = require(MP .. '.specials')

  --╔══════════════════════════════════════════════════════════════════╗
  --║  concat_cmd — build pipeline closures                            ║
  --║                                                                  ║
  --║  Called by shelua's resolver when proper_pipes=true.             ║
  --║  Input:                                                          ║
  --║    opts  — shelua settings for this instance                     ║
  --║    cmd   — the command table from add_args (e.g. {"ls", "-la"})  ║
  --║    input — array of PipeInput items from earlier in the chain:   ║
  --║            { s=string, e={__exitcode,...} }  for string inputs   ║
  --║            { c=closure, m=msg }              for command inputs  ║
  --║                                                                  ║
  --║  Returns a FUNCTION (or a {function, special} pair).             ║
  --║  The function, when called, actually spawns the process.         ║
  --╚══════════════════════════════════════════════════════════════════╝
  function representation.concat_cmd(opts, cmd, input)
    local special

    -- Check if cmd[1] names a Special (CD, AND, OR, &&, ||).
    -- Specials override normal process spawning with Lua logic.
    for k, def in pairs(SPECIAL) do
      if cmd[1] == k then
        special = def
      end
    end

    if special then
      -- Delegate entirely to the Special's resolve function.
      -- Returns a lazy closure + the Special object (for recieve later).
      return special.resolve(opts, cmd, input), special

    elseif #input == 1 then
      --╔═══════════════════════════════════════════════════╗
      --║  Single input: pipe one source into this command  ║
      --╚═══════════════════════════════════════════════════╝
      local v = input[1] or {}
      return function()
        local mkopts, towrite
        if v.m then
          -- Input has a "message" from a Special — call recieve to get
          -- both a function that modifies spawn opts and the data to pipe.
          mkopts, towrite = v.m.recieve(opts, v.c)
        elseif v.c then
          -- Input is a prior command closure (SystemObj factory).
          -- Evaluate it to get its state, then capture its stdout to pipe.
          local cstate = v.c()._state
          towrite = cstate.stdout
          mkopts = function(prev)
            prev.cwd = cstate.cwd or prev.cwd
            return prev
          end
        else
          -- Input is a plain string (v.s) with optional metadata (v.e).
          mkopts = function(prev)
            prev.cwd = (v.e or {}).__cwd or prev.cwd
            prev.env = (v.e or {}).__env
            return prev
          end
          towrite = v.s
        end

        -- Prepare spawn options. stdin=true means open a writable pipe.
        local runargs = {
          stdin = true,
          text = true,
          cwd = opts.cwd or nil,
        }
        if not towrite then
          runargs.stdin = false  -- no input to send, don't bother piping
        end
        runargs = mkopts and mkopts(runargs) or runargs
        local result = sherun(cmd, runargs)
        if towrite then
          -- Pipe the captured stdout/data into the new process's stdin.
          result:write_many({ towrite })
        end
        return result
      end

    elseif #input > 1 then
      --╔═══════════════════════════════════════════════════════════╗
      --║  Multiple inputs: merge env/cwd, concatenate all stdout   ║
      --╚═══════════════════════════════════════════════════════════╝
      return function ()
        -- Phase 1: collect cwd and env overrides from all inputs
        local env = {}
        local cwd
        for _, v in ipairs(input) do
          cwd = (v.e or {}).__cwd or cwd
          for k, val in pairs((v.e or {}).__env or {}) do
            env[k] = val
          end
        end

        local runargs = {
          stdin = true,
          env = env,
          cwd = cwd or opts.cwd or nil,
          text = true,
        }

        -- Phase 2: collect all data to pipe from each input
        local towrite = {}
        for _, v in ipairs(input) do
          if v.m then
            local mkopts, w = v.m.recieve(opts, v.c)
            if mkopts then
              runargs = mkopts(runargs)
            end
            if w then
              table.insert(towrite, w)
            end
          elseif v.c then
            local cstate = v.c()._state
            table.insert(towrite, cstate.stdout)
            runargs.cwd = cstate.cwd or runargs.cwd
          else
            table.insert(towrite, v.s)
          end
        end

        local result = sherun(cmd, runargs)
        result:write_many(towrite)
        return result
      end

    else
      --╔═══════════════════════════════════════════════════╗
      --║  No input: just spawn the command with no stdin   ║
      --╚═══════════════════════════════════════════════════╝
      return function()
        return sherun(cmd, { cwd = opts.cwd or nil, text = true })
      end
    end
  end

  --╔════════════════════════════════════════════════════════════════╗
  --║  single_stdin — handle stdin for non-piped mode                ║
  --║                                                                ║
  --║  Called by shelua when proper_pipes=false. Unlike concat_cmd,  ║
  --║  this does NOT create a pipeline of processes — it collects    ║
  --║  all prior stdout strings, concatenates them, and returns      ║
  --║  them alongside env/cwd overrides for run_cmd to use.          ║
  --║                                                                ║
  --║  Returns: cmd (the command table), and a msg table containing  ║
  --║  { env, towrite, cwd } passed to run_cmd.                      ║
  --╚════════════════════════════════════════════════════════════════╝
  function representation.single_stdin(opts, cmd, inputs, codes)
    local special
    for k, def in pairs(SPECIAL) do
      if cmd[1] == k then
        special = def
        break
      end
    end
    if special then
      return special.single(opts, cmd, inputs, codes)
    else
      -- Merge environment and cwd from all prior command results (codes).
      -- Collect all input strings to pipe to this command.
      local env = {}
      local cwd
      local towrite = {}
      for i, res in ipairs(codes or {}) do
        local newin = inputs[i]
        if newin then
          table.insert(towrite, newin)
        end
        if res.__env then
          for k, v in pairs(res.__env or {}) do
            env[k] = v
          end
        end
        if res.__cwd then cwd = res.__cwd end
      end
      return cmd, { env = env, towrite = towrite, cwd = cwd }
    end
  end

  --╔═══════════════════════════════════════════════════════════════╗
  --║  run_cmd — execute a command and collect results              ║
  --║                                                               ║
  --║  Three code paths:                                            ║
  --║    1. proper_pipes=true + command is a function closure:      ║
  --║       call it, it returns a SystemObj, wait for completion.   ║
  --║    2. proper_pipes=true + command looks like a table:         ║
  --║       it's actually a closure masquerading; call and wrap.    ║
  --║    3. proper_pipes=false: spawn directly via sherun,          ║
  --║       write collected stdin, wait, return results.            ║
  --║                                                               ║
  --║  Always returns the standardized table:                       ║
  --║    { __input, __stderr, __exitcode, __signal, __cwd }         ║
  --╚═══════════════════════════════════════════════════════════════╝
  representation.run_cmd = function (opts, cmd, msg)
    local result
    if opts.proper_pipes then
      -- proper_pipes mode: cmd is a function closure from concat_cmd
      result = cmd():wait()
    elseif type(cmd) == "function" then
      -- Command is already a closure (e.g. from a Special's single handler).
      result = cmd()
      -- Ensure metadata fields exist even if the closure didn't set them.
      result.__exitcode = result.__exitcode or 0
      result.__signal = result.__signal or 0
      result.__cwd = result.__cwd or opts.cwd or nil
      return result
    else
      -- non-piped mode: cmd is a table like {"ls", "-la"}.
      -- msg contains { env, towrite, cwd } from single_stdin.
      result = sherun(cmd, {
        env = msg.env or nil,
        cwd = msg.cwd or opts.cwd or nil,
        stdin = msg.towrite and true or false,
        text = true,
      })
      if msg.towrite then
        result:write_many(msg.towrite)
      end
      result = result:wait()
    end
    return {
      __input = result.stdout,
      __stderr = result.stderr,
      __exitcode = result.code,
      __signal = result.signal,
      __cwd = result.cwd,
    }
  end

  return representation
end
