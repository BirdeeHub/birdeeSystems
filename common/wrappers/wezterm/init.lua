local config = require 'nix-info'
local wezterm = require "wezterm"
-- local sessionizer = require("sessionizer")

config.hide_tab_bar_if_only_one_tab = true
config.keys = {}
config.allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace"
config.window_padding = {
	left = 0,
	right = -1,
	top = 0,
	bottom = -5,
	-- left = "0px",
	-- right = "0px",
	-- top = "0px",
	-- bottom = "0px",
}
config.adjust_window_size_when_changing_font_size = nil
config.use_fancy_tab_bar = false
config.show_tabs_in_tab_bar = false
config.tab_bar_at_bottom = false
config.command_palette_rows = 0
config.font_size = 11
config.color_scheme = "Konsolas"
config.use_ime = true
config.enable_kitty_keyboard = true
config.window_background_opacity = 1
config.window_decorations = "NONE" -- <-- fixes the bars around the tmux but breaks i3 border
config.window_close_confirmation = "NeverPrompt"
config.enable_tab_bar = false
config.webgpu_preferred_adapter = nil
config.check_for_updates = false
config.enable_wayland = true
config.max_fps = 165
config.anti_alias_custom_block_glyphs = true
config.default_cursor_style = "SteadyBlock"
config.warn_about_missing_glyphs = true
config.tiling_desktop_environments = {
	"X11 i3",
	"Wayland sway",
}
config.hyperlink_rules = {
	-- Matches: a URL in parens: (URL)
	{
		regex = "\\((\\w+://\\S+)\\)",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in brackets: [URL]
	{
		regex = "\\[(\\w+://\\S+)\\]",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in curly braces: {URL}
	{
		regex = "\\{(\\w+://\\S+)\\}",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in angle brackets: <URL>
	{
		regex = "<(\\w+://\\S+)>",
		format = "$1",
		highlight = 1,
	},
	-- Then handle URLs not wrapped in brackets
	{
		regex = "\\b\\w+://\\S+[)/a-zA-Z0-9-]+",
		format = "$0",
	},
	-- implicit mailto link
	{
		regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
		format = "mailto:$0",
	},
}
return config
