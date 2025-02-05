-- NOTE: This code is from
-- https://github.com/OXY2DEV/colors.nvim/tree/main/lua/colors
local utils = require("color_picker.utils")
local M = {}
function M.get()
	local keymaps = require("color_picker.config").config.keybinds
	return {
		__buf = nil,
		__win = nil,

		__on = nil,
		__onwin = nil,

		__ns = vim.api.nvim_create_namespace(""),
		__au = nil,

		_x = 0,
		_y = 0,

		---@type color_rgb
		_color = { r = 0, g = 0, b = 0 },

		---@type fun(n:number, color: color_rgb)
		_grad_callback = function(n, color) end,

		---@type fun(color: string)
		_history_callback = function(color)
			vim.list_extend(require('color_picker.history').history, {{ color = color }})
		end,

		__entries = 20,

		get_level = function(self, value)
			local val_per_lvl = 255 / self.__entries
			local lvl = math.floor(value / val_per_lvl)

			return math.min(math.max(lvl, 1), self.__entries)
		end,

		set_options = function(self)
			vim.bo[self.__buf].modifiable = false

			vim.wo[self.__win].signcolumn = "no"
			vim.wo[self.__win].number = false
			vim.wo[self.__win].relativenumber = false
		end,

		create_hls = function(self, n)
			for i = 0, self.__entries do
				-- Red
				vim.api.nvim_set_hl(0, "Colors_r_" .. n .. "_" .. tostring(i + 1), {
					fg = utils.toStr({ r = utils.lerp(0, 255, self.__entries, i), g = 0, b = 0 }),
					bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
				})

				-- Green
				vim.api.nvim_set_hl(0, "Colors_g_" .. n .. "_" .. tostring(i + 1), {
					fg = utils.toStr({ r = 0, g = utils.lerp(0, 255, self.__entries, i), b = 0 }),
					bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
				})

				-- Blue
				vim.api.nvim_set_hl(0, "Colors_b_" .. n .. "_" .. tostring(i + 1), {
					fg = utils.toStr({ r = 0, g = 0, b = utils.lerp(0, 255, self.__entries, i) }),
					bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
				})
			end

			vim.api.nvim_set_hl(0, "Colors_hex_" .. n, {
				bg = utils.toStr(self._color),
				fg = utils.getFg(self._color)
			})
			vim.api.nvim_set_hl(0, "Colors_hex_fg_" .. n, {
				fg = utils.toStr(self._color)
			})
		end,
		create_ui = function(self, buf, n)
			local slider_r = {}
			local slider_g = {}
			local slider_b = {}

			local r = self:get_level(self._color.r)
			local g = self:get_level(self._color.g)
			local b = self:get_level(self._color.b)

			for i = 1, self.__entries do
				if i == r then
					table.insert(slider_r, { "▌", "Colors_r_" .. n .. "_" .. i })
				else
					table.insert(slider_r, { "█", "Colors_r_" .. n .. "_" .. i })
				end

				if i == g then
					table.insert(slider_g, { "▌", "Colors_g_" .. n .. "_" .. i })
				else
					table.insert(slider_g, { "█", "Colors_g_" .. n .. "_" .. i })
				end

				if i == b then
					table.insert(slider_b, { "▌", "Colors_b_" .. n .. "_" .. i })
				else
					table.insert(slider_b, { "█", "Colors_b_" .. n .. "_" .. i })
				end
			end

			vim.api.nvim_buf_set_extmark(buf, self.__ns, 0, 3, {
				virt_text = slider_r,
				hl_mode = "combine",
			})
			vim.api.nvim_buf_set_extmark(buf, self.__ns, 0, 3, {
				virt_text_pos = "right_align",
				virt_text = { { tostring(self._color.r) } },

				hl_mode = "combine",
			})

			vim.api.nvim_buf_set_extmark(buf, self.__ns, 1, 3, {
				virt_text = slider_g,
				hl_mode = "combine",
			})
			vim.api.nvim_buf_set_extmark(buf, self.__ns, 1, 3, {
				virt_text_pos = "right_align",
				virt_text = { { tostring(self._color.g) } },

				hl_mode = "combine",
			})

			vim.api.nvim_buf_set_extmark(buf, self.__ns, 2, 3, {
				virt_text = slider_b,
				hl_mode = "combine",
			})
			vim.api.nvim_buf_set_extmark(buf, self.__ns, 2, 3, {
				virt_text_pos = "right_align",
				virt_text = { { tostring(self._color.b) } },

				hl_mode = "combine",
			})

			vim.api.nvim_buf_set_extmark(buf, self.__ns, 4, 3, {
				virt_text_pos = "eol",
				virt_text = {
					{ utils.toStr(self._color), "Colors_hex_" .. n },
					{ " ██", "Colors_hex_fg_" .. n },
				},

				hl_mode = "combine",
			})
		end,

		add_movement = function(self, win, buf, n)
			vim.api.nvim_buf_set_keymap(buf, "n", keymaps.left, "", {
				silent = true,
				desc = "decrease color channel value",
				callback = function()
					local cursor = vim.api.nvim_win_get_cursor(win)

					local R = self._color.r
					local G = self._color.g
					local B = self._color.b

					if cursor[1] == 1 and (R - 1) >= 0 then
						self._color.r = R - 1
					elseif cursor[1] == 2 and (G - 1) >= 0 then
						self._color.g = G - 1
					elseif cursor[1] == 3 and (B - 1) >= 0 then
						self._color.b = B - 1
					end

					self:clear_ns(buf)
					self:update_hex(n)
					self:create_ui(buf, n)
					self._grad_callback(n, self._color)
				end
			})
			vim.api.nvim_buf_set_keymap(buf, "n", keymaps.jump_l_or_shrink_gradient, "", {
				silent = true,
				desc = "decrease color channel value faster",
				callback = function()
					local cursor = vim.api.nvim_win_get_cursor(win)

					local R = self._color.r
					local G = self._color.g
					local B = self._color.b

					if cursor[1] == 1 and (R - 10) >= 0 then
						self._color.r = R - 10
					elseif cursor[1] == 2 and (G - 10) >= 0 then
						self._color.g = G - 10
					elseif cursor[1] == 3 and (B - 10) >= 0 then
						self._color.b = B - 10
					end

					self:clear_ns(buf)
					self:update_hex(n)
					self:create_ui(buf, n)
					self._grad_callback(n, self._color)
				end
			})

			vim.api.nvim_buf_set_keymap(buf, "n", keymaps.right, "", {
				silent = true,
				desc = "increase color channel value",
				callback = function()
					local cursor = vim.api.nvim_win_get_cursor(win)

					local R = self._color.r
					local G = self._color.g
					local B = self._color.b

					if cursor[1] == 1 and (R + 1) <= 255 then
						self._color.r = R + 1
					elseif cursor[1] == 2 and (G + 1) <= 255 then
						self._color.g = G + 1
					elseif cursor[1] == 3 and (B + 1) <= 255 then
						self._color.b = B + 1
					end

					self:clear_ns(buf)
					self:update_hex(n)
					self:create_ui(buf, n)
					self._grad_callback(n, self._color)
				end
			})
			vim.api.nvim_buf_set_keymap(buf, "n", keymaps.jump_r_or_grow_gradient, "", {
				silent = true,
				desc = "increase color channel value faster",
				callback = function()
					local cursor = vim.api.nvim_win_get_cursor(win)

					local R = self._color.r
					local G = self._color.g
					local B = self._color.b

					if cursor[1] == 1 and (R + 10) <= 255 then
						self._color.r = R + 10
					elseif cursor[1] == 2 and (G + 10) <= 255 then
						self._color.g = G + 10
					elseif cursor[1] == 3 and (B + 10) <= 255 then
						self._color.b = B + 10
					end

					self:clear_ns(buf)
					self:update_hex(n)
					self:create_ui(buf, n)
					self._grad_callback(n, self._color)
				end
			})
		end,
		add_exit = function(self, buf)
			vim.api.nvim_buf_set_keymap(buf, "n", keymaps.quit, "", {
				silent = true,
				desc = "quit color picker",
				callback = function()
					vim.api.nvim_set_current_win(self.__onwin)
				end
			})
		end,
		add_actions = function(self, buf, n)
			vim.api.nvim_buf_set_keymap(buf, "n", keymaps.write_selection, "", {
				silent = true,
				desc = "write value to buffer",
				callback = function()
					vim.api.nvim_set_current_win(self.__onwin)
					local colorstr = utils.toStr(self._color)
					vim.api.nvim_buf_set_text(self.__on, self._y, self._x, self._y, self._x, { colorstr })
					self._history_callback(colorstr)
				end
			})
			vim.api.nvim_buf_set_keymap(buf, "n", keymaps.yank, "", {
				silent = true,
				desc = "yank value to clipboard",
				callback = function()
					vim.api.nvim_set_current_win(self.__onwin)
					local colorstr = utils.toStr(self._color)
					vim.fn.setreg('+', colorstr)
					self._history_callback(colorstr)
				end
			})
			vim.api.nvim_buf_set_keymap(buf, "n", keymaps.insert, "", {
				silent = true,
				desc = "input color hex code",
				callback = function()
					local inputcolor = utils.hexToRgb(vim.fn.input('Please input a color code: '))
					if inputcolor.r <= 255 and inputcolor.g <= 255 and inputcolor.b <= 255 then
						self._color = inputcolor
						self:clear_ns(buf)
						self:update_hex(n)
						self:create_ui(buf, n)
						self._grad_callback(n, self._color)
					end
				end
			})
		end,

		clear_ns = function(self, buf)
			vim.api.nvim_buf_clear_namespace(buf, self.__ns, 0, -1)
		end,
		update_hex = function(self, n)
			vim.api.nvim_set_hl(0, "Colors_hex_" .. n, {
				bg = utils.toStr(self._color),
				fg = utils.getFg(self._color)
			})
			vim.api.nvim_set_hl(0, "Colors_hex_fg_" .. n, {
				fg = utils.toStr(self._color)
			})
		end,
		close_win = function(self, win)
			vim.api.nvim_win_close(win, true)
		end,

		---arguments are for gradient
		---@param self table
		---@param c_x number
		---@param c_y number
		---@param offset number
		---@param onbuf number
		---@param onwin number
		---@param x number
		---@param y number
		---@param n number
		---@param color color_rgb|string
		---@param grad_callback fun(n: number, color: color_rgb)
		---@param history_callback fun(color: string)
		---@overload fun(self: table)
		init = function(self, c_x, c_y, offset, onbuf, onwin, x, y, n, color, grad_callback, history_callback)
			if self.__win and vim.api.nvim_win_is_valid(self.__win) then
				return
			end
			if type(color) == 'string' then
				self._color = utils.hexToRgb(color)
			elseif type(color) == 'table' then
				self._color = color
			end
			if type(history_callback) == 'function' then
				self._history_callback = history_callback
			end

			if type(grad_callback) == 'function' then
				self._grad_callback = grad_callback
			end

			self.__on = onbuf or vim.api.nvim_get_current_buf()
			self.__onwin = onwin or vim.api.nvim_get_current_win()

			self._x = c_x or vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[2]
			x = x or self._x

			self._y = c_y or vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[1] - 1
			y = y or self._y - vim.fn.line('w0', self.__onwin)

			local _off = offset or vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].textoff

			if self.__buf then
				self.__win = vim.api.nvim_open_win(self.__buf, true, {
					relative = "editor",

					row = y,
					col = _off + x,

					width = self.__entries + 4 + 4,
					height = 5,

					border = "rounded"
				})
			else
				self.__buf = vim.api.nvim_create_buf(false, true)

				self.__win = vim.api.nvim_open_win(self.__buf, true, {
					relative = "editor",

					row = y,
					col = _off + x,

					width = self.__entries + 4 + 4,
					height = 5,

					focusable = false,
					border = "rounded"
				})
				vim.bo[self.__buf].filetype = "color_picker"

				vim.api.nvim_buf_set_lines(self.__buf, 0, -1, false, {
					"R: ",
					"G: ",
					"B: ",
					"",
					"Color: "
				})
			end

			if not self.__au then
				self.__au = vim.api.nvim_create_autocmd({ "WinEnter" }, {
					callback = function(event)
						if vim.bo[event.buf].filetype == "color_picker" then
							return
						end

						self.__au = vim.api.nvim_del_autocmd(self.__au)

						if vim.api.nvim_win_is_valid(self.__win) then
							self:close_win(self.__win)
						end

						vim.api.nvim_buf_clear_namespace(self.__buf, self.__ns, 0, -1)
					end
				})
			end

			self:set_options()
			self:create_ui(self.__buf, n or 1)

			self:add_movement(self.__win, self.__buf, n or 1)

			self:add_exit(self.__buf)

			self:add_actions(self.__buf, n or 1)

			self:create_hls(n or 1)

			self._grad_callback(n, self._color)
		end

	}
end

return M
