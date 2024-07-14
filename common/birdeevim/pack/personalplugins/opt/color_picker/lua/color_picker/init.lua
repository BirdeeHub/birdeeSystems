-- TODO: add ability to restore from history
-- TODO: add ability to customize keybinds, and maybe a keybind to show them too
-- TODO: add CMYK and LAB color type pickers
local picker = {}
-- NOTE: they hold their last state once retrieved with get()
local rgb = require("color_picker.color").get()
local hsv = require("color_picker.hsv").get()
local hsl = require("color_picker.hsl").get()
local grad_rgb = require("color_picker.gradient").get()
local grad_hsv = require("color_picker.gradient").get()
local grad_hsl = require("color_picker.gradient").get()

require("color_picker.config").setup_history()

-- NOTE: functions to call the pickers
picker.colorPicker = function() rgb:init() end
picker.huePicker = function() hsv:init() end
picker.hslPicker = function() hsl:init() end

picker.gradientPicker = function() grad_rgb:init(require("color_picker.color").get(), require("color_picker.color").get()) end
picker.hsvGradientPicker = function() grad_hsv:init(require("color_picker.hsv").get(), require("color_picker.hsv").get()) end
picker.hslGradientPicker = function() grad_hsl:init(require("color_picker.hsl").get(), require("color_picker.hsl").get()) end

return picker
