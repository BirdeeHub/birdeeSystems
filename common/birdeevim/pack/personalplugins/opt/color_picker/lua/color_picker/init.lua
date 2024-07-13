-- TODO: add history feature
-- TODO: add ability to customize keybinds
-- TODO: add cmyk, hsl, and lab color type pickers?
local picker = {};

picker.colorPicker = function() require("color_picker.color"):init() end
picker.gradientPicker = function() require("color_picker.gradient"):init() end
picker.hsvGradientPicker = function() require("color_picker.hsvgradient"):init() end
picker.huePicker = function() require("color_picker.huesatv"):init() end

return picker;
