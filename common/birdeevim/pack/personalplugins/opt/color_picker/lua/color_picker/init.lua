-- TODO: add history feature (should store as hex so that it can be easily generalized for other color spaces)
-- TODO: add ability to export to vim.fn.setreg('+', color) instead of buffer
-- TODO: add ability to customize keybinds
-- TODO: add cmyk, hsl, and lab color type pickers
local picker = {}
local rgb = require("color_picker.color").get()
local hsv = require("color_picker.hsv").get()
local grad_rgb = require("color_picker.gradient").get()
local grad_hsv = require("color_picker.gradient").get()

picker.colorPicker = function() rgb:init() end
picker.gradientPicker = function() grad_rgb:init(require("color_picker.color").get(), require("color_picker.color").get()) end
picker.hsvGradientPicker = function() grad_hsv:init(require("color_picker.hsv").get(), require("color_picker.hsv").get()) end
picker.huePicker = function() hsv:init() end

return picker
