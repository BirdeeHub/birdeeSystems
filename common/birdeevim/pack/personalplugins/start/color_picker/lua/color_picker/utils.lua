local utils = {}

utils.lerp = function(a, b, t, i)
	if t > 1 then
		t = 1 / t
	end

	return a + (b - a) * t * (i or 1)
end

---@param color color_rgb|color_hsv|color_hsl
---@return string
utils.getFg = function(color)
	local brightness
	if type(color.h) == "number" and type(color.s) == "number" and type(color.v) == "number" then
		brightness = color.v
	elseif type(color.r) == "number" and type(color.g) == "number" and type(color.b) == "number" then
		---@cast color color_rgb
		brightness = utils.rgbToHsv(color).v
	elseif type(color.h) == "number" and type(color.s) == "number" and type(color.l) == "number" then
		---@cast color color_hsl
		brightness = utils.hslToHsv(color).v
	else
		return "#000000"
	end

	if brightness > 70 then
		return "#000000"
	else
		return "#FFFFFF"
	end
end

---+ Title: "Turns color tables to hex color codes"
---@param color color_rgb|color_hsv|color_hsl
---@return string
utils.toStr = function(color)
	if type(color.h) == "number" and type(color.s) == "number" and type(color.v) == "number" then
		---@cast color color_hsv
		color = utils.hsvToRgb(color)
	elseif type(color.h) == "number" and type(color.s) == "number" and type(color.l) == "number" then
		---@cast color color_hsl
		color = utils.hslToRgb(color)
	end
	local R = #string.format("%x", color.r) == 1 and "0" .. string.format("%x", color.r) or
		string.format("%x", color.r)
	local G = #string.format("%x", color.g) == 1 and "0" .. string.format("%x", color.g) or
		string.format("%x", color.g)
	local B = #string.format("%x", color.b) == 1 and "0" .. string.format("%x", color.b) or
		string.format("%x", color.b)

	return "#" .. R .. G .. B
end
---_

---+ Icon: " " Title: "hex color to table converter" BorderL: " " BorderR: " "
--- @param color string Hexadecimal color code
--- @return color_rgb # Table with r, g, b values
utils.hexToRgb = function(color)
	local hex = string.gsub(color, "#", "")

	if #hex == 3 then
		return {
			r = tonumber(string.sub(hex, 1, 1), 16),
			g = tonumber(string.sub(hex, 2, 2), 16),
			b = tonumber(string.sub(hex, 3, 3), 16),
		}
	else
		return {
			r = tonumber(string.sub(hex, 1, 2), 16),
			g = tonumber(string.sub(hex, 3, 4), 16),
			b = tonumber(string.sub(hex, 5, 6), 16),
		}
	end
end
--_

---@param color color_rgb
---@return color_hsv
function utils.rgbToHsv(color)
	-- Normalize the RGB values
	local r_prime = color.r / 255
	local g_prime = color.g / 255
	local b_prime = color.b / 255

	-- Find max and min values
	local c_max = math.max(r_prime, g_prime, b_prime)
	local c_min = math.min(r_prime, g_prime, b_prime)
	local delta = c_max - c_min

	-- Calculate Value (V)
	local v = c_max

	-- Calculate Saturation (S)
	local s
	if c_max == 0 then
		s = 0
	else
		s = delta / c_max
	end

	-- Calculate Hue (H)
	local h
	if delta == 0 then
		h = 0
	else
		if c_max == r_prime then
			h = 60 * (((g_prime - b_prime) / delta) % 6)
		elseif c_max == g_prime then
			h = 60 * (((b_prime - r_prime) / delta) + 2)
		elseif c_max == b_prime then
			h = 60 * (((r_prime - g_prime) / delta) + 4)
		end
	end

	-- Ensure hue is non-negative
	if h < 0 then
		h = h + 360
	end

	return { h = math.floor(h), s = math.floor(s * 100), v = math.floor(v * 100) } -- Return HSV values with H in degrees, S and V as percentages
end

---@param color color_hsv
---@return color_rgb
function utils.hsvToRgb(color)
	local h = color.h
	local s = color.s
	local v = color.v
	-- Convert saturation and value to [0, 1] range
	s = s / 100
	v = v / 100

	local c = v * s
	local x = c * (1 - math.abs((h / 60) % 2 - 1))
	local m = v - c

	local r_prime, g_prime, b_prime

	if h < 60 then
		r_prime, g_prime, b_prime = c, x, 0
	elseif h < 120 then
		r_prime, g_prime, b_prime = x, c, 0
	elseif h < 180 then
		r_prime, g_prime, b_prime = 0, c, x
	elseif h < 240 then
		r_prime, g_prime, b_prime = 0, x, c
	elseif h < 300 then
		r_prime, g_prime, b_prime = x, 0, c
	else
		r_prime, g_prime, b_prime = c, 0, x
	end

	-- Convert back to [0, 255] range
	local r = (r_prime + m) * 255
	local g = (g_prime + m) * 255
	local b = (b_prime + m) * 255

	return { r = math.floor(r), g = math.floor(g), b = math.floor(b) }
end



---@param color color_rgb
---@return color_hsl
function utils.rgbToHsl(color)
    -- Normalize the RGB values
    local r_prime = color.r / 255
    local g_prime = color.g / 255
    local b_prime = color.b / 255

    -- Find max and min values
    local c_max = math.max(r_prime, g_prime, b_prime)
    local c_min = math.min(r_prime, g_prime, b_prime)
    local delta = c_max - c_min

    -- Calculate Lightness (L)
    local l = (c_max + c_min) / 2

    -- Calculate Saturation (S)
    local s
    if delta == 0 then
        s = 0
    else
        if l < 0.5 then
            s = delta / (c_max + c_min)
        else
            s = delta / (2 - c_max - c_min)
        end
    end

    -- Calculate Hue (H)
    local h
    if delta == 0 then
        h = 0
    else
        if c_max == r_prime then
            h = 60 * ((g_prime - b_prime) / delta % 6)
        elseif c_max == g_prime then
            h = 60 * ((b_prime - r_prime) / delta + 2)
        elseif c_max == b_prime then
            h = 60 * ((r_prime - g_prime) / delta + 4)
        end

        -- Ensure hue is non-negative
        if h < 0 then
            h = h + 360
        end
    end

    -- Convert s and l to percentages
    s = s * 100
    l = l * 100

    return { h = math.floor(h), s = math.floor(s), l = math.floor(l) } -- Return HSL values with H in degrees, S and L as percentages
end

---@param color color_hsl
---@return color_rgb
function utils.hslToRgb(color)
	local h = color.h
	local s = color.s / 100
	local l = color.l / 100

	local c = (1 - math.abs(2 * l - 1)) * s
	local x = c * (1 - math.abs((h / 60) % 2 - 1))
	local m = l - c / 2

	local r_prime, g_prime, b_prime

	if h < 60 then
		r_prime, g_prime, b_prime = c, x, 0
	elseif h < 120 then
		r_prime, g_prime, b_prime = x, c, 0
	elseif h < 180 then
		r_prime, g_prime, b_prime = 0, c, x
	elseif h < 240 then
		r_prime, g_prime, b_prime = 0, x, c
	elseif h < 300 then
		r_prime, g_prime, b_prime = x, 0, c
	else
		r_prime, g_prime, b_prime = c, 0, x
	end

	-- Convert back to [0, 255] range
	local r = (r_prime + m) * 255
	local g = (g_prime + m) * 255
	local b = (b_prime + m) * 255

	r = math.max(0, math.min(255, r))
	g = math.max(0, math.min(255, g))
	b = math.max(0, math.min(255, b))

	return { r = math.floor(r), g = math.floor(g), b = math.floor(b) }
end

---@param color color_hsl
---@return color_hsv
function utils.hslToHsv(color)
    local s_l = color.s / 100
    local l = color.l / 100

    local v = l + s_l * math.min(l, 1 - l)
    local s_v = 0
    if v ~= 0 then
        s_v = 2 * (1 - l / v)
    end

    return { h = color.h, s = math.floor(s_v * 100), v = math.floor(v * 100) }
end

return utils
