local fenster = require('fenster')

---Draw a filled circle
---@param window window*
---@param x integer
---@param y integer
---@param radius integer
---@param color integer
local function draw_circle(window, x, y, radius, color)
	local radius_neg = -radius
	local radius_pow2 = radius * radius
	for dy = radius_neg, radius do
		local dy_pow2 = dy * dy
		local sy = y + dy
		for dx = radius_neg, radius do
			if dx * dx + dy_pow2 < radius_pow2 then
				window:set(x + dx, sy, color)
			end
		end
	end
end

-- Open two windows
local window_width = 426
local window_height = 240
local window1 = fenster.open(
	window_width,
	window_height,
	'Multi-Window Demo - Press ESC to exit (1)'
)
local window2 = fenster.open(
	window_width,
	window_height,
	'Multi-Window Demo - Press ESC to exit (2)',
	2 -- scale by 2
)

-- Draw a circle on the both windows
draw_circle(
	window1,
	math.floor(window_width / 2),
	math.floor(window_height / 2),
	30,
	0xff0000
)
draw_circle(
	window2,
	math.floor(window_width / 2),
	math.floor(window_height / 2),
	30,
	0x0000ff
)

-- Draw pixels on both windows
while window1:loop() and window2:loop() and not window1.keys[27] and not window2.keys[27] do
	local x = math.random(0, window_width - 1)
	local y = math.random(0, window_height - 1)
	window1:set(x, y, 0xff0000)
	window2:set(x, y, 0x0000ff)
end
