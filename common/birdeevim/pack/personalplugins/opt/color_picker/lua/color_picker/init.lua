-- NOTE: in roughly this order
-- TODO: add history feature (should store as hex so that it can be easily generalized for other color spaces)
-- TODO: add ability to export to vim.fn.setreg('+', color) instead of buffer
-- TODO: add ability to customize keybinds
-- TODO: add cmyk, hsl, and lab color type pickers
local picker = {};
local color = require("color_picker.color").get()
local hsv = require("color_picker.hsv").get()

picker.colorPicker = function() color:init() end
picker.gradientPicker = function() require("color_picker.gradient"):init(require("color_picker.color").get(), require("color_picker.color").get()) end
picker.hsvGradientPicker = function() require("color_picker.gradient"):init(require("color_picker.hsv").get(), require("color_picker.hsv").get()) end
picker.huePicker = function() hsv:init() end

return picker;
