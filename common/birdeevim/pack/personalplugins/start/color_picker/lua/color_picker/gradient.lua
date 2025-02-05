-- NOTE: This code is from
-- https://github.com/OXY2DEV/colors.nvim/tree/main/lua/colors
-- or, well, it is, but I took the parts that actually do the color picking out of it,
-- and made it be able to recieve multiple types of pickers to make a gradient out of.
local utils = require("color_picker.utils")
local M = {}
function M.get()
	local keymaps = require("color_picker.config").config.keybinds
	return {
		picker_1 = nil,
		picker_2 = nil,

		__buf_3 = nil,
		__win_3 = nil,
		__on = nil,
		__onwin = nil,

		__ns = vim.api.nvim_create_namespace(""),
		__au = nil,

		_x = 0,
		_y = 0,

		---@type color_rgb
		_color_1 = nil,
		---@type color_rgb
		_color_2 = nil,

		_history_callback = nil,

		_close_3 = nil,

		__entries = 20,
		_steps = 10,

		_cache = {},
		_cache_pos = 1,

		get_level = function(self, value)
			local val_per_lvl = 255 / self.__entries
			local lvl = math.floor(value / val_per_lvl)

			return math.min(math.max(lvl, 1), self.__entries)
		end,

		set_options = function(self)
			vim.bo[self.__buf_3].modifiable = false

			vim.wo[self.__win_3].signcolumn = "no"
			vim.wo[self.__win_3].number = false
			vim.wo[self.__win_3].relativenumber = false
		end,

		set_hls = function(self)
			self._cache = {}
			for i = 0, self._steps do
				vim.api.nvim_set_hl(0, "Colors_p_" .. tostring(i + 1), {
					fg = utils.toStr({
						r = utils.lerp(self._color_1.r, self._color_2.r, self._steps, i),
						g = utils.lerp(
							self._color_1.g, self._color_2.g, self._steps, i),
						b = utils.lerp(self._color_1.b, self._color_2.b,
							self._steps, i)
					}),
					bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
				})

				table.insert(self._cache,
					utils.toStr({
						r = utils.lerp(self._color_1.r, self._color_2.r, self._steps, i),
						g = utils.lerp(
							self._color_1.g, self._color_2.g, self._steps, i),
						b = utils.lerp(self._color_1.b, self._color_2.b,
							self._steps, i)
					}))
			end

			vim.api.nvim_set_hl(0, "Colors_hex_p", {
				bg = self._cache[self._cache_pos],
				fg = utils.getFg(utils.hexToRgb(self._cache[self._cache_pos]))
			})
			vim.api.nvim_set_hl(0, "Colors_hex_p_fg", {
				fg = self._cache[self._cache_pos],
			})
		end,

		create_preview = function(self)
			local _p = {}

			for i = 1, self._steps do
				table.insert(_p, { "█", "Colors_p_" .. i })
			end

			vim.api.nvim_buf_set_extmark(self.__buf_3, self.__ns, 0, 0, {
				virt_text_pos = "overlay",
				virt_text = _p,
				hl_mode = "combine",
			})
			vim.api.nvim_buf_set_extmark(self.__buf_3, self.__ns, 2, 0, {
				virt_text_pos = "eol",
				virt_text = {
					{ self._cache[self._cache_pos], "Colors_hex_p" },
					{ " ██", "Colors_hex_p_fg" },
				},

				hl_mode = "combine",
			})
		end,

		add_switches = function(self, buf)
			vim.api.nvim_buf_set_keymap(buf, "n", keymaps.cycle_window, "", {
				silent = true,
				desc = "cycle through color picker windows",
				callback = function()
					local c_win = vim.api.nvim_get_current_win()

					if c_win == self.picker_1.__win then
						vim.api.nvim_set_current_win(self.picker_2.__win)
					elseif c_win == self.picker_2.__win then
						vim.api.nvim_set_current_win(self.__win_3)
					else
						vim.api.nvim_set_current_win(self.picker_1.__win)
					end
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
		add_actions = function(self, buf)
			vim.api.nvim_buf_set_keymap(buf, "n", keymaps.write_gradient, "", {
				silent = true,
				desc = "write gradient",
				callback = function()
					local _o = ""

					for c, col in ipairs(self._cache) do
						_o = _o .. '"' .. col .. '"'

						if c ~= #self._cache then
							_o = _o .. ", "
						end
					end

					vim.api.nvim_set_current_win(self.__onwin)
					vim.api.nvim_buf_set_text(self.__on, self._y, self._x, self._y, self._x, { _o })
					self._history_callback()
				end
			})
			vim.api.nvim_buf_set_keymap(buf, "n", keymaps.yank_gradient, "", {
				silent = true,
				desc = "yank gradient",
				callback = function()
					local _o = ""

					for c, col in ipairs(self._cache) do
						_o = _o .. '"' .. col .. '"'

						if c ~= #self._cache then
							_o = _o .. ", "
						end
					end

					vim.api.nvim_set_current_win(self.__onwin)
					vim.fn.setreg('+', _o)
					self._history_callback()
				end
			})
		end,
		add_grad_control = function(self)
			vim.api.nvim_buf_set_keymap(self.__buf_3, "n", keymaps.left, "", {
				silent = true,
				desc = "decrease gradient selection index",
				callback = function()
					local cursor = vim.api.nvim_win_get_cursor(self.__win_3)

					if cursor[1] == 1 and (self._cache_pos - 1) >= 1 then
						self._cache_pos = self._cache_pos - 1
					end

					self:clear_ns(self.__buf_3)
					self:set_hls()
					self:create_preview()
				end
			})
			vim.api.nvim_buf_set_keymap(self.__buf_3, "n", keymaps.jump_l_or_shrink_gradient, "", {
				silent = true,
				desc = "shrink gradient selection",
				callback = function()
					local cursor = vim.api.nvim_win_get_cursor(self.__win_3)

					if cursor[1] == 1 and (self._steps - 1) >= 5 then
						self._steps = self._steps - 1
					end
					local width = vim.api.nvim_win_get_width(self.__win_3)
					if self._steps < width and width > 30 then
						vim.api.nvim_win_set_width(self.__win_3, width - 1)
					end

					self:clear_ns(self.__buf_3)
					self:set_hls()
					self:create_preview()
				end
			})

			vim.api.nvim_buf_set_keymap(self.__buf_3, "n", keymaps.write_selection, "", {
				silent = true,
				desc = "write selected gradient value",
				callback = function()
					vim.api.nvim_set_current_win(self.__onwin)
					vim.api.nvim_buf_set_text(self.__on, self._y, self._x, self._y, self._x,
						{ self._cache[self._cache_pos] })
					self._history_callback()
				end
			})
			vim.api.nvim_buf_set_keymap(self.__buf_3, "n", keymaps.yank, "", {
				silent = true,
				desc = "yank selected gradient value",
				callback = function()
					vim.api.nvim_set_current_win(self.__onwin)
					vim.fn.setreg('+', self._cache[self._cache_pos])
					self._history_callback()
				end
			})

			vim.api.nvim_buf_set_keymap(self.__buf_3, "n", keymaps.right, "", {
				silent = true,
				desc = "increase gradient selection index",
				callback = function()
					local cursor = vim.api.nvim_win_get_cursor(self.__win_3)

					if cursor[1] == 1 and (self._cache_pos + 1) <= self._steps then
						self._cache_pos = self._cache_pos + 1
					end

					self:clear_ns(self.__buf_3)
					self:set_hls()
					self:create_preview()
				end
			})
			vim.api.nvim_buf_set_keymap(self.__buf_3, "n", keymaps.jump_r_or_grow_gradient, "", {
				silent = true,
				desc = "grow gradient selection",
				callback = function()
					local cursor = vim.api.nvim_win_get_cursor(self.__win_3)

					if cursor[1] == 1 then
						self._steps = self._steps + 1
					end
					local width = vim.api.nvim_win_get_width(self.__win_3)
					if self._steps > width then
						vim.api.nvim_win_set_width(self.__win_3, width + 1)
					end

					self:clear_ns(self.__buf_3)
					self:set_hls()
					self:create_preview()
				end
			})
		end,

		clear_ns = function(self, buf)
			vim.api.nvim_buf_clear_namespace(buf, self.__ns, 0, -1)
		end,
		close_win = function(self, win)
			vim.api.nvim_win_close(win, true)
		end,

		---@param self table
		---@param picker_1 table
		---@param picker_2 table
		init = function(self, picker_1, picker_2)
			if (picker_1.__win and picker_2.__win and self.__win_3) and (vim.api.nvim_win_is_valid(picker_1.__win) or vim.api.nvim_win_is_valid(picker_2.__win) or vim.api.nvim_win_is_valid(self.__win_3)) then
				return
			end

			self.picker_1 = picker_1
			self.picker_2 = picker_2

			self._history_callback = function(_)
				vim.list_extend(require('color_picker.history').history_gradient,
					{ {
						colors = { utils.toStr(self._color_1), utils.toStr(self._color_2) },
						steps = self._steps,
						selection =
							self._cache_pos
					} })
			end

			self.__on = vim.api.nvim_get_current_buf()
			self.__onwin = vim.api.nvim_get_current_win()

			self._x = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[2]
			self._y = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[1] - 1

			local Y = self._y - vim.fn.line('w0', self.__onwin)

			local _off = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].textoff

			---@param n number
			---@param color color_rgb
			local function grad_callback(n, color)
				self["_color_" .. n] = color
				if self._color_1 and self._color_2 then
					self:clear_ns(self.__buf_3)
					self:set_hls()
					self:create_preview()
				end
			end

			if self.__buf_3 then
				self.__win_3 = vim.api.nvim_open_win(self.__buf_3, false, {
					relative = "editor",

					row = Y + 7,
					col = _off + self._x,

					width = self._steps > 30 and self._steps or 30,
					height = 3,

					border = "rounded"
				})
			else
				self.__buf_3 = vim.api.nvim_create_buf(false, true)

				self.__win_3 = vim.api.nvim_open_win(self.__buf_3, false, {
					relative = "editor",

					row = Y + 7,
					col = _off + self._x,

					width = self._steps > 30 and self._steps or 30,
					height = 3,

					focusable = false,
					border = "rounded"
				})

				vim.bo[self.__buf_3].filetype = "color_picker"

				vim.api.nvim_buf_set_lines(self.__buf_3, 0, -1, false, {
					"",
					string.rep("─", self._steps > 30 and self._steps or 30),
					"Current color: "
				})
			end

			picker_1:init(self.x, self.y, _off, self.__on, self.__onwin, self._x, Y, 1, self._color_1, grad_callback,
				self._history_callback)
			picker_2:init(self.x, self.y, _off, self.__on, self.__onwin, self._x + self.__entries + 6 + 4, Y, 2,
				self._color_2, grad_callback, self._history_callback)

			self:set_options()

			self:add_actions(picker_1.__buf)
			self:add_actions(picker_2.__buf)
			self:add_actions(self.__buf_3)

			self:add_switches(picker_1.__buf)
			self:add_switches(picker_2.__buf)
			self:add_switches(self.__buf_3)

			self:add_exit(self.__buf_3)

			self:add_grad_control()

			if not self.__au then
				self.__au = vim.api.nvim_create_autocmd({ "WinEnter" }, {
					callback = function(event)
						if vim.bo[event.buf].filetype == "color_picker" then
							return
						end

						self.__au = vim.api.nvim_del_autocmd(self.__au)

						if vim.api.nvim_win_is_valid(self.__win_3) then
							self:close_win(self.__win_3)
						end

						vim.api.nvim_buf_clear_namespace(self.__buf_3, self.__ns, 0, -1)
					end
				})
			end

			if vim.api.nvim_win_is_valid(picker_1.__win) then
				vim.api.nvim_set_current_win(picker_1.__win)
			end
		end
	}
end

return M
