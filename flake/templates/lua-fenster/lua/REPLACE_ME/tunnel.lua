-- Inspired by https://lodev.org/cgtutor/tunnel.html

local fenster = require('fenster')

local math = math
-- Lua 5.3+ compatibility (math.atan2 can be replaced with math.atan)
local atan2 = math.atan2 or math.atan

---Returns the bitwise XOR of two numbers
---(added for cross-Lua-version compatibility)
---@param a number
---@param b number
---@return integer
local function xor(a, b)
	local result = 0
	local bitval = 1
	while a > 0 or b > 0 do
		if a % 2 ~= b % 2 then
			result = result + bitval
		end
		bitval = bitval * 2
		a = math.floor(a / 2)
		b = math.floor(b / 2)
	end
	return result
end

-- Open a window
local window_width = 256
local window_height = 144
local window_scale = 4
local window = fenster.open(
	window_width,
	window_height,
	'Tunnel Demo - Press ESC to exit',
	window_scale
)

-- Generate texture
local texture_width = 256
local texture_height = 256
local texture = {} ---@type integer[][]
for y = 0, texture_height - 1 do
	texture[y] = {}
	for x = 0, texture_width - 1 do
		texture[y][x] = xor((x * 256 / texture_width), (y * 256 / texture_height))
	end
end

-- Generate non-linear transformation table
local ratio = 32
local distance_table = {} ---@type integer[][]
local angle_table = {} ---@type integer[][]
for y = 0, (window_height * 2) - 1 do
	distance_table[y] = {}
	angle_table[y] = {}
	for x = 0, (window_width * 2) - 1 do
		local distance = math.floor(
			ratio * texture_height / math.sqrt(
				(x - window_width) * (x - window_width) + (y - window_height) * (y - window_height)
			)
		) % texture_height
		if distance ~= distance then
			distance = 0 -- fix nan/inf values
		end
		distance_table[y][x] = distance

		local angle = math.floor(0.5 * texture_width * atan2(y - window_height, x - window_width) / math.pi)
		if angle ~= angle then
			angle = 0 -- fix nan/inf values
		end
		angle_table[y][x] = angle
	end
end

-- Begin the main loop
local time = 0
local half_window_width = window_width / 2
local half_window_height = window_height / 2
while window:loop() and not window.keys[27] do
	-- Calculate the shift values out of the animation value
	local shift_x = math.floor(texture_width * 1 * time);
	local shift_y = math.floor(texture_height * 0.25 * time);

	-- Calculate the look values out of the animation value
	-- (by using sine functions, it'll alternate between looking left/right and up/down)
	local shift_look_x = half_window_width + math.floor(half_window_width * math.sin(time))
	local shift_look_y = half_window_height + math.floor(half_window_height * math.sin(time * 2))

	for y = 0, window_height - 1 do
		for x = 0, window_width - 1 do
			-- Get the texel from the texture by using the tables, shifted with the animation variable
			-- (x and y are shifted as well with the "look" animation values)
			local texture_x = math.floor(distance_table[y + shift_look_y][x + shift_look_x] + shift_x) % texture_width
			local texture_y = math.floor(angle_table[y + shift_look_y][x + shift_look_x] + shift_y) % texture_height

			window:set(x, y, texture[texture_y][texture_x])
		end
	end

	time = time + 0.5 * window.delta
end
