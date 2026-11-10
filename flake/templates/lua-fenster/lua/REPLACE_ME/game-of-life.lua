-- Game of Life Demo by Paul Adam
-- https://github.com/pauladam94

local fenster = require('fenster')

local window_width = 200
local window_height = 200
local window_scale = 4
local window = fenster.open(
	window_width,
	window_height,
	'Game of Life Demo - Press ESC to exit',
	window_scale
)

local neighbours = { { -1, -1 }, { -1, 0 }, { 0, -1 }, { -1, 1 }, { 1, -1 }, { 1, 0 }, { 0, 1 }, { 1, 1 } }

---@param x integer
---@param y integer
---@param world boolean[][]
---@return integer
local function count_alive_neighbours(x, y, world)
	local count = 0
	for _, neighbour in pairs(neighbours) do
		local dx = x + neighbour[1]
		local dy = y + neighbour[2]
		if dx >= 1 and dx <= window_width and dy <= window_height and dy >= 1 then
			if world[dx][dy] then
				count = count + 1
			end
		end
	end
	return count
end

---@param obj any
---@return any
local function copy(obj)
	if type(obj) ~= 'table' then return obj end
	local res = {} ---@type table<any, any>
	for k, v in pairs(obj) do res[copy(k)] = copy(v) end
	return res
end

local world = {} ---@type boolean[][]
for x = 1, window_width do
	world[x] = {}
	for y = 1, window_height do
		world[x][y] = false
		if x % 2 == 0 then
			world[x][y] = true
		end
	end
end

while window:loop() and not window.keys[27] do
	local previous_world = copy(world)
	for x = 1, window_width do
		for y = 1, window_height do
			if previous_world[x][y] then
				window:set(x - 1, y - 1, 0xffffff)
			else
				window:set(x - 1, y - 1, 0x000000)
			end
			local count = count_alive_neighbours(x, y, previous_world)
			world[x][y] = (count == 3) or (previous_world[x][y] and count == 2)
		end
	end
end
