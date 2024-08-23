local colorschemer = nixCats('colorscheme') -- also schemes lualine
if not require('nixCatsUtils').isNixCats then
	colorschemer = 'onedark'
end
if colorschemer == 'onedark' then
	require('onedark').setup {
		-- Set a style preset. 'dark' is default.
		style = 'dark', -- dark, darker, cool, deep, warm, warmer, light
	}
	require('onedark').load()
end
if colorschemer ~= "" then
	vim.cmd.colorscheme(colorschemer)
end

require("large_file").setup({
	size_limit = 4 * 1024 * 1024, -- 4 MB
	buffer_options = {
		swapfile = false,
		bufhidden = 'unload',
		buftype = 'nowrite',
		undolevels = -1,
	},
	on_large_file_read_pre = function(ev) end
})

vim.keymap.set('n', '<leader>cpc', function() require("color_picker").rgbPicker() end, { desc = 'color_picker rgb' })
vim.keymap.set('n', '<leader>cph', function() require("color_picker").hsvPicker() end, { desc = 'color_picker hsv' })
vim.keymap.set('n', '<leader>cps', function() require("color_picker").hslPicker() end, { desc = 'color_picker hsl' })
vim.keymap.set('n', '<leader>cpg', function() require("color_picker").rgbGradientPicker() end,
	{ desc = 'color_picker rgb gradient' })
vim.keymap.set('n', '<leader>cpd', function() require("color_picker").hsvGradientPicker() end,
	{ desc = 'color_picker hsv gradient' })
vim.keymap.set('n', '<leader>cpb', function() require("color_picker").hslGradientPicker() end,
	{ desc = 'color_picker hsl gradient' })
require('lze').load({ "color_picker", on_require = "color_picker" })

vim.keymap.set('n', '<leader>rs', '<cmd>lua require("spectre").toggle()<CR>', {
	desc = "Toggle Spectre"
})
vim.keymap.set('n', '<leader>rw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
	desc = "Search current word"
})
vim.keymap.set('v', '<leader>rw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
	desc = "Search current word"
})
vim.keymap.set('n', '<leader>rf', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
	desc = "Search on current file"
})

require('birdee.plugins.oil')

require('birdee.plugins.telescope')

require('birdee.plugins.nestsitter')

require('birdee.plugins.completion')

require('birdee.plugins.lualine')

require('birdee.plugins.git')

require('birdee.plugins.clipboard')

require('birdee.plugins.image')

require('birdee.plugins.notes')

require('birdee.plugins.gutter')

require('birdee.plugins.grapple')

require('birdee.plugins.which-key')

vim.keymap.set('n', '<leader>mp', '<cmd>MarkdownPreview <CR>', { noremap = true, desc = 'markdown preview' })
vim.keymap.set('n', '<leader>ms', '<cmd>MarkdownPreviewStop <CR>', { noremap = true, desc = 'markdown preview stop' })
vim.keymap.set('n', '<leader>mt', '<cmd>MarkdownPreviewToggle <CR>',
	{ noremap = true, desc = 'markdown preview toggle' })
require('lze').load({
	"markdown-preview.nvim",
	enabled = require('nixCatsUtils').enableForCategory('general.markdown'),
	-- cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle", },
	-- event = "",
	ft = "markdown",
	-- keys = {"<leader>mp", "<leader>ms", "<leader>mt", },
	-- colorscheme = "",
	load = function(name)
		require("birdee.utils").safe_packadd({
			name,
		})
	end,
	before = function(plugin)
		vim.g.mkdp_auto_close = 0
	end,
})

vim.keymap.set('n', '<leader>Ft', [[:TSJToggle<CR>]], { desc = "treesj split/join" })
require('lze').load({
	"treesj",
	cmd = { "TSJToggle" },
	-- event = "",
	-- ft = "",
	-- keys = "",
	-- colorscheme = "",
	load = function(name)
		require("birdee.utils").safe_packadd({
			"nvim-treesitter",
			name,
		})
	end,
	after = function(plugin)
		local tsj = require('treesj')

		-- local langs = {--[[ configuration for languages ]]}

		tsj.setup({
			---@type boolean Use default keymaps (<space>m - toggle, <space>j - join, <space>s - split)
			use_default_keymaps = true,
			---@type boolean Node with syntax error will not be formatted
			check_syntax_error = true,
			---If line after join will be longer than max value,
			---@type number If line after join will be longer than max value, node will not be formatted
			max_join_length = 120,
			---Cursor behavior:
			---hold - cursor follows the node/place on which it was called
			---start - cursor jumps to the first symbol of the node being formatted
			---end - cursor jumps to the last symbol of the node being formatted
			---@type 'hold'|'start'|'end'
			cursor_behavior = 'hold',
			---@type boolean Notify about possible problems or not
			notify = true,
			---@type boolean Use `dot` for repeat action
			dot_repeat = true,
			---@type nil|function Callback for treesj error handler. func (err_text, level, ...other_text)
			on_error = nil,
			---@type table Presets for languages
			-- langs = langs, -- See the default presets in lua/treesj/langs
		})
	end,
})

vim.keymap.set('n', '<leader>U', "<cmd>UndotreeToggle<CR>", { desc = "Undo Tree" })
require('lze').load({
	{
		"undotree",
		cmd = { "UndotreeToggle", "UndotreeHide", "UndotreeShow", "UndotreeFocus", "UndotreePersistUndo", },
		-- event = "",
		-- ft = "",
		-- keys = "<leader>U",
		-- colorscheme = "",
		before = function(_)
			vim.g.undotree_WindowLayout = 1
			vim.g.undotree_SplitWidth = 40
		end,
		load = function(name)
			require("birdee.utils").safe_packadd({
				name,
			})
		end,
	},
	{
		"lazydev.nvim",
		enabled = require('nixCatsUtils').enableForCategory('neonixdev'),
		cmd = { "LazyDev" },
		-- event = "DeferredUIEnter",
		ft = "lua",
		-- keys = "",
		-- colorscheme = "",
		load = function(name)
			require("birdee.utils").safe_packadd({ name, })
		end,
		after = function(plugin)
			require('lazydev').setup({
				library = {
					-- See the configuration section for more details
					-- Load luvit types when the `vim.uv` word is found
					-- { path = "luvit-meta/library", words = { "vim%.uv" } },
					{ path = require('nixCats').nixCatsPath .. '/lua', words = { "nixCats" } },
				},
			})
		end,
	},
	{
		"otter.nvim",
		enabled = require('nixCatsUtils').enableForCategory('otter'),
		-- cmd = { "" },
		-- event = "DeferredUIEnter",
		on_require = { "otter" },
		-- ft = { "markdown", "norg", "templ", "nix", "javascript", "html", "typescript", },
		-- keys = "",
		-- colorscheme = "",
		load = function(name)
			require("birdee.utils").safe_packadd({
				"nvim-lspconfig",
				"nvim-treesitter",
				name,
			})
		end,
		after = function(plugin)
			local otter = require 'otter'
			otter.setup {
				lsp = {
					-- `:h events` that cause the diagnostics to update. Set to:
					-- { "BufWritePost", "InsertLeave", "TextChanged" } for less performant
					-- but more instant diagnostic updates
					diagnostic_update_events = { "BufWritePost" },
					-- function to find the root dir where the otter-ls is started
					root_dir = function(_, bufnr)
						return vim.fs.root(bufnr or 0, {
							".git",
							"_quarto.yml",
							"package.json",
						}) or vim.fn.getcwd(0)
					end,
				},
				buffers = {
					-- if set to true, the filetype of the otterbuffers will be set.
					-- otherwise only the autocommand of lspconfig that attaches
					-- the language server will be executed without setting the filetype
					set_filetype = false,
					-- write <path>.otter.<embedded language extension> files
					-- to disk on save of main buffer.
					-- usefule for some linters that require actual files
					-- otter files are deleted on quit or main buffer close
					write_to_disk = false,
				},
				verbose = {          -- set to false to disable all verbose messages
					no_code_found = false, -- warn if otter.activate is called, but no injected code was found
				},
				strip_wrapping_quote_characters = { "'", '"', "`" },
				-- otter may not work the way you expect when entire code blocks are indented (eg. in Org files)
				-- When true, otter handles these cases fully.
				handle_leading_whitespace = false,
			}
		end,
	},
	{
		"todo-comments.nvim",
		-- cmd = { "" },
		event = "DeferredUIEnter",
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		load = function(name)
			require("birdee.utils").safe_packadd({
				name,
			})
		end,
		after = function(plugin)
			require("todo-comments").setup({ signs = false })
		end,
	},
	{
		"indent-blankline.nvim",
		-- cmd = { "" },
		event = "DeferredUIEnter",
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		load = function(name)
			require("birdee.utils").safe_packadd({
				name,
			})
		end,
		after = function(plugin)
			require("ibl").setup()
		end,
	},
	{
		"visual-whitespace",
		-- cmd = { "" },
		event = "DeferredUIEnter",
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		load = function(name)
			require("birdee.utils").safe_packadd({
				name,
			})
		end,
		after = function(plugin)
			require('visual-whitespace').setup({
				highlight = { link = 'Visual' },
				space_char = '·',
				tab_char = '→',
				nl_char = '↲'
			})
		end,
	},
	{
		"vim-startuptime",
		enabled = require('nixCatsUtils').enableForCategory('general.other'),
		cmd = { "StartupTime" },
		before = function(_)
			vim.g.startuptime_exe_path = require("nixCatsUtils").packageBinPath
		end,
	},
	{
		"nvim-surround",
		-- cmd = { "" },
		event = "DeferredUIEnter",
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		load = function(name)
			require("birdee.utils").safe_packadd({
				name,
			})
		end,
		after = function(plugin)
			require('nvim-surround').setup()
		end,
	},
	{
		"eyeliner.nvim",
		-- cmd = { "" },
		event = "DeferredUIEnter",
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		load = function(name)
			require("birdee.utils").safe_packadd({
				name,
			})
		end,
		after = function(plugin)
			-- Highlights unique characters for f/F and t/T motions
			require('eyeliner').setup {
				highlight_on_key = true, -- show highlights only after key press
				dim = true,          -- dim all other characters
			}
		end,
	},
	{
		"render-markdown",
		-- cmd = { "" },
		-- event = "",
		ft = "markdown",
		-- keys = "",
		-- colorscheme = "",
		load = function(name)
			require("birdee.utils").safe_packadd({
				"nvim-treesitter",
				name,
			})
		end,
		after = function(plugin)
			require('render-markdown').setup({})
		end,
	},
	{
		"vim-dadbod",
		cmd = { "DB", "DBUI", "DBUIAddConnection", "DBUIClose",
			"DBUIToggle", "DBUIFindBuffer", "DBUILastQueryInfo", "DBUIRenameBuffer", },
		-- event = "",
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		load = function(name)
			require("birdee.utils").safe_packadd({
				name,
				"vim-dadbod-ui",
			})
			require("birdee.utils").load_w_after_plugin("vim-dadbod-completion")
		end,
		after = function(plugin)
		end,
	},
	{
		"hlargs",
		-- cmd = { "" },
		event = "DeferredUIEnter",
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		load = function(name)
			require("birdee.utils").safe_packadd({
				"nvim-treesitter",
				name,
			})
		end,
		after = function(plugin)
			require('hlargs').setup({
				color = '#32a88f',
			})
			vim.cmd([[hi clear @lsp.type.parameter]])
			vim.cmd([[hi link @lsp.type.parameter Hlargs]])
		end,
	},
	{
		"vim-sleuth",
		-- cmd = { "" },
		event = "DeferredUIEnter",
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		load = function(name)
			require("birdee.utils").safe_packadd({
				name,
			})
		end,
	},
	{
		"nvim-highlight-colors",
		-- cmd = { "" },
		event = "DeferredUIEnter",
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		load = function(name)
			require("birdee.utils").safe_packadd({
				name,
			})
		end,
		after = function(plugin)
			require("nvim-highlight-colors").setup {
				---Render style
				---@usage 'background'|'foreground'|'virtual'
				render = 'virtual',

				---Set virtual symbol (requires render to be set to 'virtual')
				virtual_symbol = '■',

				---Highlight named colors, e.g. 'green'
				enable_named_colors = true,

				---Highlight tailwind colors, e.g. 'bg-blue-500'
				enable_tailwind = true,

				---Set custom colors
				---Label must be properly escaped with '%' to adhere to `string.gmatch`
				--- :help string.gmatch
				custom_colors = {
					{ label = '%-%-theme%-primary%-color',   color = '#0f1219' },
					{ label = '%-%-theme%-secondary%-color', color = '#5a5d64' },
				}
			}
		end,
	},
})
