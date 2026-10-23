local luv = require("luv")
local cjson = require("cjson")
local nixInfo = require("nixInfo")
local notify_send = nixInfo.notify_send

local buffer = ""

local reader = luv.new_pipe()
local writer = luv.new_pipe()
if not reader or not writer then
  error("Failed to create a pipe via luv!")
end

local message_handler = nixInfo.message_handler(luv, notify_send, nixInfo)
local call_handler = nixInfo.call_handler(luv, notify_send, nixInfo, cjson, writer)

local handle

local function closepipes()
  if handle and not handle:is_closing() then
    handle:close()
    handle = nil
  end
  if writer and not writer:is_closing() then
    writer:close()
    writer = nil
  end
  if reader and not reader:is_closing() then
    reader:close()
    reader = nil
  end
end

handle = luv.spawn(nixInfo.signal_cli, {
  args = { "jsonRpc" },
  stdio = {
    writer,
    reader,
    nil
  }
}, function(code, signal)
  io.stderr:write("signal-cli jsonRpc exited with code "..tostring(code).."\n")
  closepipes()
end)

-- Start reading data stream from the socket
luv.read_start(reader, function(read_err, chunk)
  if read_err then
    io.stderr:write("Read error: " .. read_err .. "\n")
    closepipes()
    return
  end

  if chunk then
    buffer = buffer .. chunk
    -- Process line-by-line (JSON lines)
    while true do
      local next_pos = buffer:find("\n", 1, true)
      if not next_pos then break end
      local line = buffer:sub(1, next_pos)
      buffer = buffer:sub(next_pos + 1)
      if line == "" then break end

      local success, data = pcall(cjson.decode, line)
      if success and data and data.method == "receive" then
        local env = (data.params or {}).envelope or ((data.params or {}).result or {}).envelope
        if env then
          local sender = env.sourceName or env.sourceNumber or "Unknown"
          if env.dataMessage then
            local message = ""
            message = env.dataMessage.message or ""
            if message and message ~= "" and message ~= cjson.null then
              message_handler.send(sender, message)
            end
          elseif env.syncMessage and env.syncMessage.sentMessage then
            local message = ""
            message = env.syncMessage.sentMessage.message or ""
            if message and message ~= "" and message ~= cjson.null then
              message_handler.send(sender, message)
            end
          elseif env.callMessage then
            local uuid = env.sourceUuid or "Unknown"
            if env.callMessage.offerMessage then
              call_handler.send_call_message(uuid, sender)
            elseif env.callMessage.iceUpdateMessages then
              call_handler.continue_call_message(uuid)
            elseif env.callMessage.hangupMessage then
              call_handler.end_call_message(uuid)
            end
          end
        end
      end
    end
  else
    closepipes()
  end
end)

luv.run("default")
