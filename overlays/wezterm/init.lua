-- See https://wezfurlong.org/wezterm/
local fromnix = require('nixStuff')
local fontpkg = fromnix.fontpkg
local shellString = fromnix.shellString
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.font_size = 10.5
config.color_scheme = 'Oceanic Next (Gogh)'
config.font = wezterm.font('FiraMono Nerd Font')
config.color_scheme_dirs = { wezterm.config_dir .. "/colors" }
config.font_dirs = { fontpkg .. "/share/fonts" }
config.keys = {}
config.set_environment_variables = fromnix.envVars
config.window_padding = {
    left = 0,
    right = -1,
    top = 0,
    bottom = -5,
}
config.default_prog = shellString
config.adjust_window_size_when_changing_font_size = nil
config.use_fancy_tab_bar = false
config.show_tabs_in_tab_bar = false
config.tab_bar_at_bottom = false
config.front_end = "Software"
-- config.front_end = "OpenGL"
-- config.front_end = "WebGpu"
config.command_palette_rows = 0
return config

