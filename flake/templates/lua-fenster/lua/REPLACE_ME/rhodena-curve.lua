-- Rhodonea Curves by Jakob Kruse
-- https://github.com/jakob-kruse
-- You can read more here https://en.wikipedia.org/wiki/Rose_(mathematics)

local fenster = require('fenster')

local windowSize = 900
local window = fenster.open(windowSize, windowSize, 'Math Roses - R to reset + ESC to exit', 1, 0)

---@param delta number
---@param variant fun(delta:number):number
---@return number
local function generateRoseValue(delta, variant)
	return 100 * math.sin(variant(delta))
end

---@param offsetX number
---@param offsetY number
---@param delta number
---@param variant fun(delta:number):number
---@param generator fun(delta:number,variant:fun(delta:number):number):number
local function drawRose(offsetX, offsetY, delta, variant, generator)
	local radius = generator(delta, variant)
	local x = math.floor(radius * math.cos(delta) + offsetX)
	local y = math.floor(radius * math.sin(delta) + offsetY)

	x = math.max(0, math.min(windowSize - 1, x))
	y = math.max(0, math.min(windowSize - 1, y))

	window:set(x, y, 0xffffff)
end

local variantValues = {
	---Circle
	---@param delta number
	---@return number
	function(delta)
		return delta / delta
	end,

	---4-leaf rose
	---@param delta number
	---@return number
	function(delta)
		return math.sin(delta * 2)
	end,

	---12-leaf rose
	---@param delta number
	---@return number
	function(delta)
		return math.sin(delta * 6)
	end,

	---Butterfly
	---@param delta number
	---@return number
	function(delta)
		return math.sin(delta) + math.sin(delta * 4)
	end,

	---Biker Glasses
	---@param delta number
	---@return number
	function(delta)
		return math.sin(delta) + math.sin(delta * 3)
	end,

	---Neutron Star
	---@param delta number
	---@return number
	function(delta)
		return math.tan(delta)
	end,

	---Logarithmic Spiral
	---@param delta number
	---@return number
	function(delta)
		return math.log(delta)
	end,

	---@param delta number
	---@return number
	function(delta)
		return math.rad(delta) * 10
	end,

	---@param delta number
	---@return number
	function(delta)
		return math.fmod(delta, 2)
	end,
}

local gridSize = math.ceil(math.sqrt(#variantValues))
local cellSize = windowSize / gridSize
local delta = 1

while window:loop() and not window.keys[27] do
	if window.keys[82] then
		delta = 1
		window:clear()
	end

	for i = 0, gridSize - 1 do
		for j = 0, gridSize - 1 do
			local variant = variantValues[i * gridSize + j + 1]
			if variant then
				drawRose(
					i * cellSize + cellSize / 2,
					j * cellSize + cellSize / 2,
					delta,
					variant,
					generateRoseValue
				)
			end
		end
	end

	delta = delta + 0.0005
end
