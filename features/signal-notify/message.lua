return function(luv, notify_send, nixInfo)
  local M = {}
  local function play_sound()
    local handle
    handle = luv.spawn(
      "pw-play",
      {
        options = {},
        args = { nixInfo.msg_sound },
      },
      function(code, signal)
        if handle and not handle:is_closing() then
          handle:close()
          handle = nil
        end
      end
    )
  end
  function M.send(sender, message)
    -- Create a pipe to capture notify-send's standard output (stdout)
    local stdout_pipe = luv.new_pipe(false)
    if not stdout_pipe then error("could not open a new pipe via luv!") end
    local output_buffer = ""

    -- Spawn options for the initial summary notification
    local options = {
      args = {
        "-p",
        "--action=expand=Show Message",
        "Signal Message from " .. sender,
      },
      stdio = { nil, stdout_pipe, nil }
    }

    play_sound()

    local child
    child = luv.spawn(notify_send, options, function(code, signal)
      -- Clean up process resources when it finishes
      if child then child:close() end
      if not stdout_pipe:is_closing() then stdout_pipe:close() end

      -- Check if the user clicked our "expand" action button
      if output_buffer:find("expand") then
        -- Extract the numeric notification ID from the output string
        local clean_id = output_buffer:match("(%d+)")
        if clean_id then
          -- Spawn a second notify-send to replace (-r) the old one with a longer string
          local replace_child
          replace_child = luv.spawn(notify_send, {
            args = {
              "-r", clean_id,
              "Signal Message from " .. sender .. " (Full Text)",
              message
            }
          }, function()
            if replace_child then replace_child:close() end
          end)
        end
      end
    end)

    -- Start reading stdout chunk data from the running notify-send process
    luv.read_start(stdout_pipe, function(err, chunk)
      if chunk then
        output_buffer = output_buffer .. chunk
      end
    end)
  end
  return M
end
