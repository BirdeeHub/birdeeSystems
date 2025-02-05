local M = {}

M.config = {
	history_path = vim.fn.stdpath('cache') .. "/color_picker_history.json",
	history_limit = 10,
	history_gradient_limit = 10,
	keybinds = {
		left = "<left>",
		right = "<right>",
		jump_l_or_shrink_gradient = "z",
		jump_r_or_grow_gradient = "x",
		quit = "q",
		insert = "i",
		yank = "y",
		yank_gradient = "Y",
		write_selection = "<Enter>",
		write_gradient = "<Space>",
		cycle_window = "<Tab>",
		history = "H",
		gradient_history = "G",
		keys = "?",
	},
}

M.setup = function(config)
	M.config = vim.tbl_deep_extend("force", M.config, config)
	M.setup_history()
end

function M.setup_history()
	-- NOTE: setup history from file
	vim.g.color_picker_history_path = vim.g.color_picker_history_path or M.config.history_path
	vim.g.color_picker_history_limit = vim.g.color_picker_history_limit or M.config.history_limit
	vim.g.color_picker_history_gradient_limit = vim.g.color_picker_history_gradient_limit or M.config.history_gradient_limit
	if vim.fn.filereadable(vim.g.color_picker_history_path) == 1 then
		local history_file = vim.fn.readfile(vim.g.color_picker_history_path)[1]
		local histories = vim.fn.json_decode(history_file)
		require("color_picker.history").history = histories.history
		require("color_picker.history").history_gradient = histories.history_gradient
	end

	-- NOTE: write history to file on exit
	vim.api.nvim_create_autocmd('VimLeave', {
		group = vim.api.nvim_create_augroup('color_picker_save_on_exit', { clear = true }),
		callback = function(event)
			local history_path = vim.g.color_picker_history_path or M.config.history_path
			local history_limit = vim.g.color_picker_history_limit or M.config.history_limit
			local history_gradient_limit = vim.g.color_picker_history_gradient_limit or M.config.history_gradient_limit
			local histItems = require("color_picker.history").history
			local histlen = #(histItems)
			local gradhistItems = require("color_picker.history").history_gradient
			local gradhistlen = #(gradhistItems)
			if histlen > history_limit then
				require("color_picker.history").history = vim.list_slice(histItems, histlen - history_limit, histlen)
			end
			if gradhistlen > history_gradient_limit then
				require("color_picker.history").history_gradient = vim.list_slice(gradhistItems, gradhistlen - history_gradient_limit, gradhistlen)
			end
			local json_hist = vim.fn.json_encode(require("color_picker.history"))
			vim.fn.writefile({ json_hist }, history_path)
		end,
	})
end

return M
