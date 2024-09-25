local fenster = require('fenster')

-- Open a window
local window_width = 256
local window_height = 144
local window_scale = 4
local window = fenster.open(
	window_width,
	window_height,
	'Plasma Demo - Press ESC to exit',
	window_scale
)

-- Calculate plasma effect steps
local plasma_y_step = 1 / window_height
local plasma_x_step = 1 / window_width

-- Draw plasma effect
local time = 0
while window:loop() and not window.keys[27] do
	local py = 0
	for y = 1, window_height - 1 do
		local px = 0
		for x = 1, window_width - 1 do
			local k = 0.1 + math.cos(py + math.sin(0.148 - time)) + 2.4 * time
			local w = 0.9 + math.cos(px + math.cos(0.628 + time)) - 0.7 * time
			local d = math.sqrt(px * px + py * py)
			local s = 7.0 * math.cos(d + w) * math.sin(k + w)
			local r = math.floor((0.5 + 0.5 * math.cos(s + 0.2)) * 255)
			local g = math.floor((0.5 + 0.5 * math.cos(s + 0.5)) * 255)
			local b = math.floor((0.5 + 0.5 * math.cos(s + 0.7)) * 255)
			window:set(x, y, fenster.rgb(r, g, b))

			px = px + plasma_x_step
		end

		py = py + plasma_y_step
	end

	time = time + 0.5 * window.delta
end
