local M = {}

function M.setup_history(file_path)
	-- NOTE: setup history from file
	vim.g.color_picker_history_path = file_path or vim.g.color_picker_history_path or vim.fn.stdpath('cache') .. "/color_picker_history.json"
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
			vim.g.color_picker_history_path = vim.g.color_picker_history_path or vim.fn.stdpath('cache') .. "/color_picker_history.json"
			local json_hist = vim.fn.json_encode(require("color_picker.history"))
			vim.fn.writefile({ json_hist }, vim.g.color_picker_history_path)
		end,
	})
end

return M
