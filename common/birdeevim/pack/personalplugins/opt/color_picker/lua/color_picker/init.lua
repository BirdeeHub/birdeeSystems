-- NOTE: This code is from
-- https://github.com/OXY2DEV/colors.nvim/tree/main/lua/colors
-- And huePicker will be offered as a PR if its any good.
local picker = {};

picker.colorPicker = require("color_picker.color")
picker.gradientPicker = require("color_picker.gradient")
picker.hsvGradientPicker = require("color_picker.hsvgradient")
picker.huePicker = require("color_picker.huesatv")

return picker;
