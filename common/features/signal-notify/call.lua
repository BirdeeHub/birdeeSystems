-- TODO: finish this

return function(luv, notify_send, nixInfo)
  local active_calls = {}
  local M = {}

  local function start_call_ring(call)
    call.ringing = true
    call.ringer = luv.spawn(
      "pw-play",
      {
        options = {},
        args = { nixInfo.ringer_sound },
      },
      function(code, signal)
        if call.ringer and not call.ringer:is_closing() then
          call.ringer:close()
        end
        call.ringer = nil
        if call.ringing and code == 0 then
          start_call_ring(call)
        end
      end
    )
  end

  local function stop_call_ring(call)
    call.ringing = false
    if call.ringer and not call.ringer:is_closing() then
      call.ringer:kill(15)
      call.ringer = nil
    end
  end

  local function cleanup_call(call)
    call.ending = true
    -- Invalidate the callback of any notification process that is still around.
    call.notification_generation = (call.notification_generation or 0) + 1

    stop_call_ring(call)

    if active_calls[call.key] == call then
      active_calls[call.key] = nil
    end

    if call.pipe and not call.pipe:is_closing() then
      call.pipe:close()
    end
    call.pipe = nil

    if call.child and not call.child:is_closing() then
      -- notify-send holds the notification open with -w. Terminating it closes
      -- the notification because its D-Bus connection goes away.
      call.child:kill(15)
    end
    call.child = nil
  end

  local function show_call_notification(call, summary, body, actions, on_action)
    local stdout_pipe = luv.new_pipe(false)
    if not stdout_pipe then
      io.stderr:write("could not open a new pipe via luv!\n")
      return false
    end
    local actions_unordered = {}
    for _, action in ipairs(actions) do
      actions_unordered[action[1]] = action[2]
    end

    local output_buffer = ""
    local generation = (call.notification_generation or 0) + 1
    call.notification_generation = generation

    local args = {
      "-p",
      "-w",
      "-t", "0",
      "--urgency=critical",
      "--app-name=Signal",
    }
    for _, action in ipairs(actions) do
      args[#args + 1] = "--action=" .. action[1] .. "=" .. action[2]
    end
    args[#args + 1] = summary
    if body and body ~= "" then
      args[#args + 1] = body
    end

    local function parse_action()
      for line in output_buffer:gmatch("[^\r\n]+") do
        local trimmed = line:match("^%s*(.-)%s*$")
        if actions_unordered[trimmed] then
          return trimmed
        end
      end
    end

    local child
    local pipe_eof = false
    local process_exited = false
    local finished = false

    local function finalize()
      if finished then return end
      finished = true

      -- A newer notification replaced this one, or the call was already ended.
      if call.notification_generation ~= generation then return end

      local action = parse_action()
      if action then
        on_action(action)
      elseif not call.ending then
        -- The notification was dismissed or expired. Stop ringing even if the
        -- remote side has not sent its hangup message yet.
        cleanup_call(call)
      end
    end

    child = luv.spawn(notify_send, {
      args = args,
      stdio = { nil, stdout_pipe, nil },
    }, function(code, signal)
      process_exited = true
      if call.child == child then call.child = nil end
      if child and not child:is_closing() then child:close() end

      -- Wait for stdout to reach EOF so the action that ended notify-send has
      -- definitely been read.
      if pipe_eof then finalize() end
    end)

    if not child then
      stdout_pipe:close()
      return false
    end

    call.child = child
    call.pipe = stdout_pipe
    luv.read_start(stdout_pipe, function(err, chunk)
      if chunk then
        output_buffer = output_buffer .. chunk
        return
      end

      pipe_eof = true
      if call.pipe == stdout_pipe then call.pipe = nil end
      if not stdout_pipe:is_closing() then stdout_pipe:close() end
      if process_exited then finalize() end
    end)

    return true
  end

  function M.send_call_message(uuid, sender)
    if active_calls[uuid] then
      return M.continue_call_message(uuid)
    end

    local call = {
      key = uuid,
      sender = sender,
    }
    active_calls[uuid] = call

    start_call_ring(call)

    local shown = show_call_notification(call,
      "Incoming Signal call from " .. sender,
      sender,
      {
        -- This is kinda lazy, but doing better is hard without making a whole client
        { "open", "Open Signal Desktop" },
        -- I might add hangup and silence, but I am not bothering with picking up the call
      },
      function(action)
        if action == "open" then
          local handle
          handle = luv.spawn(nixInfo.signal_desktop, {
            args = {},
            options = {
              detached = true,
              stdio = {nil, nil, nil},
            }
          }, function(code, signal)
            if handle then
              handle:close()
            end
          end)
          if handle then
            handle:unref()
          end
        end
        cleanup_call(call)
      end)

    if not shown then
      cleanup_call(call)
    end
  end

  function M.continue_call_message(uuid)
    local call = active_calls[uuid]
    if not call then return end
    call.last_activity = luv.now()
  end

  function M.end_call_message(uuid)
    local call = active_calls[uuid]
    if call then
      cleanup_call(call)
    end
  end
  return M
end
