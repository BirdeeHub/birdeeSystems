-- TODO: add ability to restore from history
-- TODO: add display for history
-- TODO: add display for keybinds
-- TODO: add CMYK and LAB color type pickers
-- TODO: figure out why you can't map h and l instead of left and right
-- TODO: make a combined all color types picker
local picker = {}

picker.setup = require("color_picker.config").setup
require("color_picker.config").setup_history()

-- NOTE: they hold their last state once retrieved with get()
local rgb = require("color_picker.pickers.rgb").get()
local hsv = require("color_picker.pickers.hsv").get()
local hsl = require("color_picker.pickers.hsl").get()
local grad_rgb = require("color_picker.gradient").get()
local grad_hsv = require("color_picker.gradient").get()
local grad_hsl = require("color_picker.gradient").get()

-- NOTE: functions to call the pickers
picker.rgbPicker = function()
	rgb:init()
end
picker.hsvPicker = function()
	hsv:init()
end
picker.hslPicker = function()
	hsl:init()
end

-- NOTE: combine any 2 pickers into a gradient picker
-- NOTE: the gradient picker will hold its last state after get(), and pass the colors to the pickers on restore.
picker.rgbGradientPicker = function()
	grad_rgb:init(require("color_picker.pickers.rgb").get(), require("color_picker.pickers.rgb").get())
end
picker.hsvGradientPicker = function()
	grad_hsv:init(require("color_picker.pickers.hsv").get(), require("color_picker.pickers.hsv").get())
end
picker.hslGradientPicker = function()
	grad_hsl:init(require("color_picker.pickers.hsl").get(), require("color_picker.pickers.hsl").get())
end

return picker
