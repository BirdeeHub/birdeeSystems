local utils = {}

utils.lerp = function (a, b, t, i)
	if t > 1 then
		t = 1 / t;
	end

	return a + (b - a) * t * (i or 1);
end

---@overload fun(color: color_hsv): string
---@overload fun(color: color_rgb): string
utils.getFg = function (color)
	local brightness
	---@diagnostic disable: undefined-field
	if type(color.h) == "number" and type(color.s) == "number" and type(color.v) == "number" then
		brightness = color.v;
	elseif type(color.r) == "number" and type(color.g) == "number" and type(color.b) == "number" then
		---@cast color color_rgb
		brightness = utils.rgbToHsv(color).v;
	else
	---@diagnostic enable: undefined-field
		return "#000000"
	end

	if brightness > 60 then
		return "#000000"
	else
		return "#FFFFFF"
	end
end

---+ Title: "Turns color tables to hex color codes"
---@overload fun(color: color_hsv): string
---@overload fun(color: color_rgb): string
utils.toStr = function (color)
	if type(color.h) == "number" and type(color.s) == "number" and type(color.v) == "number" then
		color = utils.hsvToRgb(color);
	end
	local R = #string.format("%x", color.r) == 1 and "0" .. string.format("%x", color.r) or string.format("%x", color.r);
	local G = #string.format("%x", color.g) == 1 and "0" .. string.format("%x", color.g) or string.format("%x", color.g);
	local B = #string.format("%x", color.b) == 1 and "0" .. string.format("%x", color.b) or string.format("%x", color.b);

	return "#" .. R .. G .. B;
end
---_

---+ Icon: " " Title: "rgb number to table converter" BorderL: " " BorderR: " "
--- @param color number Number returned by "nvim_get_hl()"
--- @return color_rgb # Table with r, g, b values
utils.rgbToRgb = function (color)
	local hex = string.format("%x", color);

	return {
		r = tonumber(string.sub(hex, 1, 2), 16),
		g = tonumber(string.sub(hex, 3, 4), 16),
		b = tonumber(string.sub(hex, 5, 6), 16),
	};
end
--_

---+ Icon: " " Title: "hex color to table converter" BorderL: " " BorderR: " "
--- @param color string Hexadecimal color code
--- @return color_rgb # Table with r, g, b values
utils.hexToRgb = function (color)
	local hex = string.gsub(color, "#", "");

	if #hex == 3 then
		return {
			r = tonumber(string.sub(hex, 1, 1), 16),
			g = tonumber(string.sub(hex, 2, 2), 16),
			b = tonumber(string.sub(hex, 3, 3), 16),
		};
	else
		return {
			r = tonumber(string.sub(hex, 1, 2), 16),
			g = tonumber(string.sub(hex, 3, 4), 16),
			b = tonumber(string.sub(hex, 5, 6), 16),
		};
	end
end
--_

---+ Icon: " " Title: "Do eased interpolation" BorderL: " " BorderR: " "
--- @param ease string The name of the easing function to use
--- @param from number Starting value
--- @param to number Final value
--- @param position number % position from the start value to the final value
--- @return number
utils.ease = function(ease, from, to, position)
	local easeValue = 0;

	if ease == "linear" then
		easeValue = position;
	elseif ease == "ease-in-sine" then
		easeValue = 1 - math.cos((position * math.pi) / 2);
	elseif ease == "ease-out-sine" then
		easeValue = math.sin((position * math.pi) / 2);
	elseif ease == "ease-in-out-sine" then
		easeValue = -(math.cos(position * math.pi) - 1) / 2;
	elseif ease == "ease-in-quad" then
		easeValue = position ^ 2;
	elseif ease == "ease-out-quad" then
		easeValue = 1 - ((1 - position) ^ 2);
	elseif ease == "ease-in-out-quad" then
		easeValue = position < 0.5 and 2 * (position ^ 2) or 1 - (((-2 * position + 2) ^ 2) / 2);
	elseif ease == "ease-in-cubic" then
		easeValue = position ^ 3;
	elseif ease == "ease-out-cubic" then
		easeValue = 1 - ((1 - position) ^ 3);
	elseif ease == "ease-in-out-cubic" then
		easeValue = position < 0.5 and 4 * (position ^ 3) or 1 - (((-2 * position + 2) ^ 3) / 2);
	elseif ease == "ease-in-quart" then
		easeValue = position ^ 4;
	elseif ease == "ease-out-quart" then
		easeValue = 1 - ((1 - position) ^ 4);
	elseif ease == "ease-in-out-quart" then
		easeValue = position < 0.5 and 8 * (position ^ 4) or 1 - (((-2 * position + 2) ^ 4) / 2);
	elseif ease == "ease-in-quint" then
		easeValue = position ^ 5;
	elseif ease == "ease-out-quint" then
		easeValue = 1 - ((1 - position) ^ 5);
	elseif ease == "ease-in-out-quint" then
		easeValue = position < 0.5 and 16 * (position ^ 5) or 1 - (((-2 * position + 2) ^ 5) / 2);
	elseif ease == "ease-in-circ" then
		easeValue = 1 - math.sqrt(1 - (position ^ 2));
	elseif ease == "ease-out-circ" then
		easeValue = math.sqrt(1 - ((position - 1) ^ 2));
	elseif ease == "ease-in-out-circ" then
		easeValue = position < 0.5 and (1 - math.sqrt(1 - ((2 * y) ^ 2))) / 2 or (math.sqrt(1 - ((-2 * y + 2) ^ 2)) + 1) / 2;
	end

	return from + ((to - from) * easeValue);
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

    return { h = math.floor(h), s = math.floor(s * 100), v = math.floor(v * 100) }  -- Return HSV values with H in degrees, S and V as percentages
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

return utils;
