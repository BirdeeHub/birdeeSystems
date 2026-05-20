local uv = vim and (vim.uv or vim.loop) or require("luv")

--- vim.system modified slightly

--- @class Shelua.SystemOpts
--- @field stdin? string|string[]|true
--- @field stdout? fun(err:string?, data: string?)|false
--- @field stderr? fun(err:string?, data: string?)|false
--- @field cwd? string
--- @field env? table<string,string|number>
--- @field clear_env? boolean
--- @field text? boolean
--- @field timeout? integer Timeout in ms
--- @field detach? boolean

--- @class Shelua.SystemCompleted
--- @field code integer
--- @field signal integer
--- @field stdout? string
--- @field stderr? string
--- @field cwd? string

--- @class Shelua.SystemState
--- @field cmd string[]
--- @field cwd? string
--- @field handle? uv.uv_process_t
--- @field timer?  uv.uv_timer_t
--- @field pid? integer
--- @field timeout? integer
--- @field done? boolean|'timeout'
--- @field stdin? uv.uv_stream_t
--- @field stdout? uv.uv_stream_t
--- @field stderr? uv.uv_stream_t
--- @field stdout_data? string[]
--- @field stderr_data? string[]
--- @field result? Shelua.SystemCompleted

--- @enum Shelua.SystemSig
local SIG = {
  HUP = 1, -- Hangup
  INT = 2, -- Interrupt from keyboard
  KILL = 9, -- Kill signal
  TERM = 15, -- Termination signal
  -- STOP = 17,19,23  -- Stop the process
}

---@param handle uv.uv_handle_t?
local function close_handle(handle)
  if handle and not handle:is_closing() then
    handle:close()
  end
end

--- @class Shelua.SystemObj
--- @field cmd string[]
--- @field pid integer
--- @field private _state Shelua.SystemState
--- @field wait fun(self: Shelua.SystemObj, timeout?: integer): Shelua.SystemCompleted
--- @field kill fun(self: Shelua.SystemObj, signal: integer|string)
--- @field write fun(self: Shelua.SystemObj, data?: string|string[]|fun())
--- @field write_many fun(self: Shelua.SystemObj, data?: (string|string[]|fun()|uv.uv_stream_t)[])
--- @field is_closing fun(self: Shelua.SystemObj): boolean
local SystemObj = {}

--- @param state Shelua.SystemState
--- @return Shelua.SystemObj
local function new_systemobj(state)
  return setmetatable({
    cmd = state.cmd,
    pid = state.pid,
    _state = state,
  }, { __index = SystemObj })
end

--- @param signal integer|string
function SystemObj:kill(signal)
  self._state.handle:kill(signal)
end

--- @package
--- @param signal? Shelua.SystemSig
function SystemObj:_timeout(signal)
  self._state.done = 'timeout'
  self:kill(signal or SIG.TERM)
end
--- Waits for a condition to be true or timeout.
--- @param timeout integer: maximum time to wait (in ms)
--- @param callback fun(): boolean function
--- @param interval? integer: how often to poll (in ms)
--- @param fast_return? boolean: run check immediately first
--- @return boolean: true if condition met, false if timed out
local function wait_loop(timeout, callback, interval, fast_return)
  interval = interval or 1
  local start = uv.now()
  local done = false
  local timer = uv.new_timer()

  if fast_return and callback() then
    return true
  end

  timer:start(0, interval, function()
    if callback() then
      done = true
      timer:stop()
      timer:close()
    elseif uv.now() - start >= timeout then
      timer:stop()
      timer:close()
    end
  end)

  -- Spin the event loop until done or timeout
  while not done and (uv.now() - start < timeout) do
    uv.run("nowait")
  end

  return done
end
-- Use max 32-bit signed int value to avoid overflow on 32-bit systems. #31633
local MAX_TIMEOUT = 2 ^ 31 - 1

--- @param timeout? integer
--- @return Shelua.SystemCompleted
function SystemObj:wait(timeout)
  local state = self._state

  local done = ((vim or {}).wait or wait_loop)(timeout or state.timeout or MAX_TIMEOUT, function()
    return state.result ~= nil
  end, nil, true)

  if not done then
    -- Send sigkill since this cannot be caught
    self:_timeout(SIG.KILL)
    wait_loop(timeout or state.timeout or MAX_TIMEOUT, function()
      return state.result ~= nil
    end, nil, true)
  end

  return state.result
end

--- @param data string[]|string|fun()|nil
function SystemObj:write(data)
  local stdin = self._state.stdin
  if not stdin then
    error('pipe has not been opened')
  end

  if type(data) == 'table' then
    for _, v in ipairs(data) do
      stdin:write(v)
      stdin:write('\n')
    end
  elseif type(data) == 'string' then
    stdin:write(data)
  elseif type(data) == 'function' then
    local new = data()
    while new ~= nil do
      stdin:write(new)
      new = data()
    end
  elseif data == nil then
    -- Shutdown the write side of the duplex stream and then close the pipe.
    -- Note shutdown will wait for all the pending write requests to complete
    -- TODO(lewis6991): apparently shutdown doesn't behave this way.
    -- (https://github.com/neovim/neovim/pull/17620#discussion_r820775616)
    stdin:write('', function()
      stdin:shutdown(function()
        close_handle(stdin)
      end)
    end)
  end
end

--- @param data (string[]|string|fun()|uv.uv_stream_t)[]
function SystemObj:write_many(data)
  local inputs = type(data) == "table" and data or { data }
  local function process_next(i)
    local input = inputs[i]
    if not input then
      self:write(nil)
      return
    end
    if type(input) == "userdata" then
      ---@cast input uv.uv_stream_t
      input:read_start(function(err, d)
        assert(not err, err)
        if d then
          self:write(d)
        else
          input:close()
          process_next(i + 1)
        end
      end)
    else
      self:write(input)
      process_next(i + 1)
    end
  end
  process_next(1)
end

--- @return boolean
function SystemObj:is_closing()
  local handle = self._state.handle
  return handle == nil or handle:is_closing() or false
end

--- @param output? fun(err: string?, data: string?)|false
--- @param text? boolean
--- @return uv.uv_stream_t? pipe
--- @return fun(err: string?, data: string?)? handler
--- @return string[]? data
local function setup_output(output, text)
  if output == false then
    return
  end

  local bucket --- @type string[]?
  local handler --- @type fun(err: string?, data: string?)

  if type(output) == 'function' then
    handler = output
  else
    bucket = {}
    handler = function(err, data)
      if err then
        error(err)
      end
      if text and data then
        bucket[#bucket + 1] = data:gsub('\r\n', '\n')
      else
        bucket[#bucket + 1] = data
      end
    end
  end

  local pipe = assert(uv.new_pipe(false))

  --- @param err? string
  --- @param data? string
  local function handler_with_close(err, data)
    handler(err, data)
    if data == nil then
      pipe:read_stop()
      pipe:close()
    end
  end

  return pipe, handler_with_close, bucket
end

--- @param input? string|string[]|boolean
--- @return uv.uv_stream_t?
--- @return string|string[]|function?
local function setup_input(input)
  if not input then
    return
  end

  local towrite --- @type string|string[]|function?
  if type(input) == 'string' or type(input) == 'table' or type(input) == 'function' then
    towrite = input
  end

  return assert(uv.new_pipe(false)), towrite
end

--- uv.spawn will completely overwrite the environment
--- when we just want to modify the existing one, so
--- make sure to prepopulate it with the current env.
--- @param env? table<string,string|number>
--- @param clear_env? boolean
--- @return string[]?
local function setup_env(env, clear_env)
  if not clear_env then
    local function extend_tbl(t,n)
      for k, v in pairs(n) do
        t[k] = v
      end
      return t
    end
    local base_env = uv.os_environ()
    base_env['NVIM'] = ((vim or {}).v or {}).servername
    base_env['NVIM_LISTEN_ADDRESS'] = nil
    --- @type table<string,string|number>
    env = extend_tbl(base_env, env or {})
  end

  local renv = {} --- @type string[]
  for k, v in pairs(env or {}) do
    renv[#renv + 1] = string.format('%s=%s', k, tostring(v))
  end

  return renv
end

local M = {}

--- @param cmd string
--- @param opts uv.spawn.options
--- @param on_exit fun(code: integer, signal: integer)
--- @param on_error fun()
--- @return uv.uv_process_t, integer
local function spawn(cmd, opts, on_exit, on_error)
  local handle, pid_or_err = uv.spawn(cmd, opts, on_exit)
  if not handle then
    on_error()
    error(('%s: "%s"'):format(pid_or_err, cmd))
  end
  return handle, pid_or_err --[[@as integer]]
end

--- @param timeout integer
--- @param cb fun()
--- @return uv.uv_timer_t
local function timer_oneshot(timeout, cb)
  local timer = assert(uv.new_timer())
  timer:start(timeout, 0, function()
    timer:stop()
    timer:close()
    cb()
  end)
  return timer
end

--- @param state Shelua.SystemState
--- @param code integer
--- @param signal integer
--- @param on_exit fun(result: Shelua.SystemCompleted)?
local function _on_exit(state, code, signal, on_exit)
  close_handle(state.handle)
  close_handle(state.stdin)
  close_handle(state.timer)

  -- #30846: Do not close stdout/stderr here, as they may still have data to
  -- read. They will be closed in uv.read_start on EOF.

  local check = assert(uv.new_check())
  check:start(function()
    for _, pipe in pairs({ state.stdin, state.stdout, state.stderr }) do
      if not pipe:is_closing() then
        return
      end
    end
    check:stop()
    check:close()

    if state.done == nil then
      state.done = true
    end

    if (code == 0 or code == 1) and state.done == 'timeout' then
      -- Unix: code == 0
      -- Windows: code == 1
      code = 124
    end

    local stdout_data = state.stdout_data
    local stderr_data = state.stderr_data

    state.result = {
      code = code,
      cwd = state.cwd or nil,
      signal = signal,
      stdout = stdout_data and table.concat(stdout_data) or nil,
      stderr = stderr_data and table.concat(stderr_data) or nil,
    }

    if on_exit then
      on_exit(state.result)
    end
  end)
end

--- @param state Shelua.SystemState
local function _on_error(state)
  close_handle(state.handle)
  close_handle(state.stdin)
  close_handle(state.stdout)
  close_handle(state.stderr)
  close_handle(state.timer)
end

local function checkarg(name, val, val_type, optional)
  if optional and val == nil then
    return
  end
  if type(val) ~= val_type then
    error(('%s must be %s, got %s'):format(name, val_type, type(val)), 2)
  end
end

--- Run a system command
---
--- @param cmd string[]
--- @param opts? Shelua.SystemOpts
--- @param on_exit? fun(out: Shelua.SystemCompleted)
--- @return Shelua.SystemObj
function M.run(cmd, opts, on_exit)
  checkarg('cmd', cmd, 'table')
  checkarg('opts', opts, 'table', true)
  checkarg('on_exit', on_exit, 'function', true)

  opts = opts or {}

  local stdout, stdout_handler, stdout_data = setup_output(opts.stdout, opts.text)
  local stderr, stderr_handler, stderr_data = setup_output(opts.stderr, opts.text)
  local stdin, towrite = setup_input(opts.stdin)

  --- @type Shelua.SystemState
  local state = {
    done = false,
    cmd = cmd,
    cwd = opts.cwd or nil,
    timeout = opts.timeout,
    stdin = stdin,
    stdout = stdout,
    stdout_data = stdout_data,
    stderr = stderr,
    stderr_data = stderr_data,
  }

  local rgs = {}
  for i = 2, #cmd do
    table.insert(rgs, cmd[i])
  end

  --- @diagnostic disable-next-line:missing-fields
  state.handle, state.pid = spawn(cmd[1], {
    args = rgs,
    stdio = { stdin, stdout, stderr },
    cwd = state.cwd,
    --- @diagnostic disable-next-line:assign-type-mismatch
    env = setup_env(opts.env, opts.clear_env),
    detached = opts.detach,
    hide = true,
  }, function(code, signal)
    _on_exit(state, code, signal, on_exit)
  end, function()
    _on_error(state)
  end)

  if stdout and stdout_handler then
    stdout:read_start(stdout_handler)
  end

  if stderr and stderr_handler then
    stderr:read_start(stderr_handler)
  end

  local obj = new_systemobj(state)

  if towrite then
    obj:write(towrite)
    obj:write(nil) -- close the stream
  end

  if opts.timeout then
    state.timer = timer_oneshot(opts.timeout, function()
      if state.handle and state.handle:is_active() then
        obj:_timeout()
      end
    end)
  end

  return obj
end

return M
