local uv = require("luv")
local inspect = require("inspect")
local json = require("cjson") -- or dkjson / vim.json
local _, ffi = pcall(require, "ffi")

local sock_path = os.getenv("I3SOCK")
local is_i3 = sock_path and true
sock_path = sock_path or os.getenv("SWAYSOCK")
assert(sock_path, "I3SOCK environment variable is not set")

-- Common Sway IPC message types
local IPC = {
  RUN_COMMAND       = 0,
  GET_WORKSPACES    = 1,
  SUBSCRIBE         = 2,
  GET_OUTPUTS       = 3,
  GET_TREE          = 4,
  GET_MARKS         = 5,
  GET_BAR_CONFIG    = 6,
  GET_VERSION       = 7,
  GET_BINDING_MODES = 8,
  GET_CONFIG        = 9,
  SEND_TICK         = 10,
  SYNC              = 11,
  GET_BINDING_STATE = 12,
}
local EVENT = {
  WORKSPACE        = 0,
  OUTPUT           = 1,
  MODE             = 2,
  WINDOW           = 3,
  BARCONFIG_UPDATE = 4,
  BINDING          = 5,
  SHUTDOWN         = 6,
  TICK             = 7,
}
local EVENT_NAMES = {
  "output",
  "mode",
  "window",
  "barconfig_update",
  "binding",
  "shutdown",
  "tick"
}
EVENT_NAMES[0] = "workspace"

-- Allocate a reusable 2-element uint32 array (8 bytes total) for packing
local header_ints = ffi.new("uint32_t[2]")

local function pack_msg(msg_type, payload_str)
  if ffi then
    payload_str = payload_str or ""
    header_ints[0] = #payload_str
    header_ints[1] = msg_type
    return "i3-ipc" .. ffi.string(header_ints, 8) .. payload_str
  else
    payload_str = payload_str or ""
    return string.pack("<c6I4I4", "i3-ipc", #payload_str, msg_type) .. payload_str
  end
end

local function unpack_header(buf)
  if ffi then
  local magic = buf:sub(1, 6)
  -- Cast bytes 7..14 of the Lua string directly to a uint32_t pointer
  local ptr = ffi.cast("const uint32_t *", ffi.cast("const char *", buf) + 6)
  local len = ptr[0]
  local msg_type = ptr[1]
  return magic, len, msg_type
  else
    return string.unpack("<c6I4I4", buf)
  end
end

-- Helper to attach a framed packet reader to any luv pipe
local function attach_reader(pipe, on_packet)
  local read_buf = ""
  pipe:read_start(function(err, chunk)
    assert(not err, err)
    if not chunk then
      pipe:close()
      return
    end

    read_buf = read_buf .. chunk
    while #read_buf >= 14 do
      local magic, len, msg_type = unpack_header(read_buf)
      assert(magic == "i3-ipc", "Invalid IPC magic header")
      if #read_buf < 14 + len then
        break
      end

      local payload = read_buf:sub(15, 14 + len)
      read_buf = read_buf:sub(15 + len)
      on_packet(msg_type, json.decode(payload))
    end
  end)
end

-- Create a Unix domain socket pipe
local event_pipe = uv.new_pipe(false)
if not event_pipe then
  error("could not open libuv pipe")
end

-- 1. Command Pipe (FIFO request/response queue)
local cmd_pipe = uv.new_pipe(false)
if not cmd_pipe then
  error("could not open libuv pipe")
end
local pending_callbacks = {}

local function send_request(msg_type, payload_str, callback)
  table.insert(pending_callbacks, callback or function() end)
  cmd_pipe:write(pack_msg(msg_type, payload_str))
end

local function run_command(cmd_str, callback)
  send_request(IPC.RUN_COMMAND, cmd_str, callback)
end

local function get_outputs(callback)
  send_request(IPC.GET_OUTPUTS, "", callback)
end

local function get_workspaces(callback)
  send_request(IPC.GET_WORKSPACES, "", callback)
end

-- Start both connections
cmd_pipe:connect(sock_path, function(err)
  assert(not err, err)

  attach_reader(cmd_pipe, function(msg_type, data)
    local cb = table.remove(pending_callbacks, 1)
    if cb then
      cb(data, msg_type)
    end
  end)
end)

event_pipe:connect(sock_path, function(err)
  assert(not err, err)

  attach_reader(event_pipe, function(msg_type, data)
    -- This pipe only listens to events, ignore others
    if msg_type < 0x80000000 then return end
    local event_id = msg_type - 0x80000000
    print(string.format("Event %s | data=%s", EVENT_NAMES[event_id], inspect(data)))
  end)

  -- Subscribe to workspace and output events
  local sub_payload = json.encode({ "workspace", "output" })
  event_pipe:write(pack_msg(IPC.SUBSCRIBE, sub_payload))
end)

uv.run()
