local fenster = require('fenster')

---Load an image from a PPM file
---@param path string
---@return integer[]
---@return integer
---@return integer
local function load_image(path)
	local image = assert(io.open(path, 'rb'))

	local image_type = image:read(2)
	assert(image_type == 'P6', 'Invalid image type: ' .. tostring(image_type))
	assert(image:read(1), 'Invalid image header') -- Whitespace
	local image_width = image:read('*number')
	assert(image_width, 'Invalid image width: ' .. tostring(image_width))
	assert(image:read(1), 'Invalid image header') -- Whitespace
	local image_height = image:read('*number')
	assert(image_height, 'Invalid image height: ' .. tostring(image_height))
	assert(image:read(1), 'Invalid image header') -- Whitespace
	local image_max_color = image:read('*number')
	assert(
		image_max_color == 255,
		'Invalid image maximum color: ' .. tostring(image_max_color)
	)
	assert(image:read(1), 'Invalid image header') -- Whitespace

	local image_buffer = {} ---@type integer[]
	while true do
		local r_raw = image:read(1)
		local g_raw = image:read(1)
		local b_raw = image:read(1)
		if not r_raw or not g_raw or not b_raw then
			break
		end

		local r = string.byte(r_raw)
		local g = string.byte(g_raw)
		local b = string.byte(b_raw)
		image_buffer[#image_buffer + 1] = fenster.rgb(r, g, b)
	end

	return image_buffer, image_width, image_height
end

---Draw an image from load_image()
---@param window window*
---@param x integer
---@param y integer
---@param image_buffer integer[]
---@param image_width integer
---@param image_height integer
local function draw_image(window, x, y, image_buffer, image_width, image_height)
	local ix_end = image_width - 1
	for iy = 0, image_height - 1 do
		local dy = y + iy
		local iy_index = iy * image_width + 1
		for ix = 0, ix_end do
			window:set(x + ix, dy, image_buffer[iy_index + ix])
		end
	end
end

-- Load the image
local dirname = './' .. (debug.getinfo(1, 'S').source:match('^@?(.*[/\\])') or '') ---@type string
local image_path = dirname .. 'assets/uv.ppm'
local image_buffer, image_width, image_height = load_image(image_path)

-- Open a window
local window = fenster.open(
	image_width,
	image_height,
	'Image Demo - Press ESC to exit'
)

-- Draw the image
draw_image(
	window,
	0,
	0,
	image_buffer,
	image_width,
	image_height
)

-- Empty window loop
while window:loop() and not window.keys[27] do
	--
end
