-- NOTE: in this order
-- TODO: add history feature (should store as hex so that it can be easily generalized for other color spaces)
-- TODO: add ability to customize keybinds
-- TODO: refactor such that 2 pickers can be provided and a gradient view is generated for it.
-- TODO: add cmyk, hsl, and lab color type pickers
local picker = {};

picker.colorPicker = function() require("color_picker.color").get():init() end
picker.gradientPicker = function() require("color_picker.gradient").get():init() end
picker.hsvGradientPicker = function() require("color_picker.hsvgradient"):init() end
picker.huePicker = function() require("color_picker.huesatv"):init() end

return picker;
