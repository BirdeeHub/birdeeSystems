local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local extras = require('luasnip.extras')
local rep = extras.rep
local fmta = require('luasnip.extras.fmt').fmta
local c = ls.choice_node
local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.snippet_node

vim.keymap.set({ "i", "s" }, "<M-n>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end)
