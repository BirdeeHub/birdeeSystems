-- NOTE: This code is from
-- https://github.com/OXY2DEV/colors.nvim/tree/main/lua/colors
local utils = require("color_picker.utils");
return {
	__buf = nil,
	__win = nil,

	__on = nil,
	__onwin = nil,

	__ns = vim.api.nvim_create_namespace("colorPicker"),
	__au = nil,

	_x = 0, _y = 0,

	_r = 0,
	_g = 0,
	_b = 0,

	_close = nil,

	__entries = 20,

	get_level = function (self, value)
		local val_per_lvl = 255 / self.__entries;
		local lvl = math.floor(value / val_per_lvl);

		return math.min(math.max(lvl, 1), self.__entries);
	end,

	set_options = function (self)
		vim.bo[self.__buf].modifiable = false;

		vim.wo[self.__win].signcolumn = "no"
		vim.wo[self.__win].number = false;
		vim.wo[self.__win].relativenumber = false;
	end,

	create_hls = function (self)
		for i = 0, self.__entries do
			-- Red
			vim.api.nvim_set_hl(0, "Colors_r_" .. tostring(i + 1), {
				fg = utils.toStr({ r = utils.lerp(0, 255, self.__entries, i), g = 0, b = 0 }),
				bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
			});

			-- Green
			vim.api.nvim_set_hl(0, "Colors_g_" .. tostring(i + 1), {
				fg = utils.toStr({ r = 0, g = utils.lerp(0, 255, self.__entries, i), b = 0 }),
				bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
			})

			-- Blue
			vim.api.nvim_set_hl(0, "Colors_b_" .. tostring(i + 1), {
				fg = utils.toStr({ r = 0, g = 0, b = utils.lerp(0, 255, self.__entries, i) }),
				bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
			})
		end

		vim.api.nvim_set_hl(0, "Colors_hex", {
			bg = utils.toStr({ r = self._r, g = self._g, b = self._b}),
			fg = utils.getFg({ r = self._r, g = self._g, b = self._b})
		});
		vim.api.nvim_set_hl(0, "Colors_hex_fg", {
			fg = utils.toStr({ r = self._r, g = self._g, b = self._b})
		});
	end,
	create_ui = function (self, buf)
		local slider_r = {};
		local slider_g = {};
		local slider_b = {};

		local r = self:get_level(self._r);
		local g = self:get_level(self._g);
		local b = self:get_level(self._b);

		for i = 1, self.__entries do
			if i == r then
				table.insert(slider_r, { "▌", "Colors_r_" .. i })
			else
				table.insert(slider_r, { "█", "Colors_r_" .. i })
			end

			if i == g then
				table.insert(slider_g, { "▌", "Colors_g_" .. i })
			else
				table.insert(slider_g, { "█", "Colors_g_" .. i })
			end

			if i == b then
				table.insert(slider_b, { "▌", "Colors_b_" .. i })
			else
				table.insert(slider_b, { "█", "Colors_b_" .. i })
			end

		end

		vim.api.nvim_buf_set_extmark(buf, self.__ns, 0, 3, {
			virt_text = slider_r,
			hl_mode = "combine",
		});
		vim.api.nvim_buf_set_extmark(buf, self.__ns, 0, 3, {
			virt_text_pos = "right_align",
			virt_text = { { tostring(self._r) } },

			hl_mode = "combine",
		});

		vim.api.nvim_buf_set_extmark(buf, self.__ns, 1, 3, {
			virt_text = slider_g,
			hl_mode = "combine",
		});
		vim.api.nvim_buf_set_extmark(buf, self.__ns, 1, 3, {
			virt_text_pos = "right_align",
			virt_text = { { tostring(self._g) } },

			hl_mode = "combine",
		});

		vim.api.nvim_buf_set_extmark(buf, self.__ns, 2, 3, {
			virt_text = slider_b,
			hl_mode = "combine",
		});
		vim.api.nvim_buf_set_extmark(buf, self.__ns, 2, 3, {
			virt_text_pos = "right_align",
			virt_text = { { tostring(self._b) } },

			hl_mode = "combine",
		});

		vim.api.nvim_buf_set_extmark(buf, self.__ns, 4, 3, {
			virt_text_pos = "eol",
			virt_text = {
				{ utils.toStr({ r = self._r, g = self._g, b = self._b }), "Colors_hex" },
				{ " ██", "Colors_hex_fg" },
			},

			hl_mode = "combine",
		});
	end,

	add_movement = function (self, win, buf)
		vim.api.nvim_buf_set_keymap(buf, "n", "<left>", "", {
			silent = true,
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(win);

				local R = self._r
				local G = self._g
				local B = self._b

				if cursor[1] == 1 and (R - 1) >= 0 then
					self._r = R - 1;
				elseif cursor[1] == 2 and (G - 1) >= 0 then
					self._g = G - 1;
				elseif cursor[1] == 3 and (B - 1) >= 0 then
					self._b = B - 1;
				end

				self:clear_ns(buf);
				self:update_hex();
				self:create_ui(buf)
			end
		});
		vim.api.nvim_buf_set_keymap(buf, "n", "z", "", {
			silent = true,
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(win);

				local R = self._r
				local G = self._g
				local B = self._b

				if cursor[1] == 1 and (R - 10) >= 0 then
					self._r = R - 10;
				elseif cursor[1] == 2 and (G - 10) >= 0 then
					self._g = G - 10;
				elseif cursor[1] == 3 and (B - 10) >= 0 then
					self._b = B - 10;
				end

				self:clear_ns(buf);
				self:update_hex();
				self:create_ui(buf)
			end
		});

		vim.api.nvim_buf_set_keymap(buf, "n", "<right>", "", {
			silent = true,
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(win);

				local R = self._r
				local G = self._g
				local B = self._b

				if cursor[1] == 1 and (R + 1) <= 255 then
					self._r = R + 1;
				elseif cursor[1] == 2 and (G + 1) <= 255 then
					self._g = G + 1;
				elseif cursor[1] == 3 and (B + 1) <= 255 then
					self._b = B + 1;
				end

				self:clear_ns(buf);
				self:update_hex();
				self:create_ui(buf)
			end
		})
		vim.api.nvim_buf_set_keymap(buf, "n", "x", "", {
			silent = true,
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(win);

				local R = self._r
				local G = self._g
				local B = self._b

				if cursor[1] == 1 and (R + 10) <= 255 then
					self._r = R + 10;
				elseif cursor[1] == 2 and (G + 10) <= 255 then
					self._g = G + 10;
				elseif cursor[1] == 3 and (B + 10) <= 255 then
					self._b = B + 10;
				end

				self:clear_ns(buf);
				self:update_hex();
				self:create_ui(buf);
			end
		});
	end,
	add_exit = function (self, buf)
		vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
			silent = true,
			callback = function ()
				vim.api.nvim_set_current_win(self.__onwin)
			end
		});
	end,
	add_actions = function (self, buf)
		vim.api.nvim_buf_set_keymap(buf, "n", "<Enter>", "", {
			silent = true,
			callback = function ()
				vim.api.nvim_set_current_win(self.__onwin)
				vim.api.nvim_buf_set_text(self.__on, self._y, self._x, self._y, self._x, { utils.toStr({ r = self._r, g = self._g, b = self._b }) });
			end
		});
		vim.api.nvim_buf_set_keymap(buf, "n", "i", "", {
			silent = true,
			callback = function ()
				local inputcolor = utils.hexToRgb(vim.fn.input('Please input a color code: '))
				if inputcolor.r <= 255 and inputcolor.g <= 255 and inputcolor.b <= 255 then
					self._r = inputcolor.r
					self._g = inputcolor.g
					self._b = inputcolor.b
					self:clear_ns(buf);
					self:update_hex();
					self:create_ui(buf);
				end
			end
		});
	end,

	clear_ns = function (self, buf)
		vim.api.nvim_buf_clear_namespace(buf, self.__ns, 0, -1)
	end,
	update_hex = function (self)
		vim.api.nvim_set_hl(0, "Colors_hex", {
			bg = utils.toStr({ r = self._r, g = self._g, b = self._b }),
			fg = utils.getFg({ r = self._r, g = self._g, b = self._b })
		});
		vim.api.nvim_set_hl(0, "Colors_hex_fg", {
			fg = utils.toStr({ r = self._r, g = self._g, b = self._b })
		});
	end,
	close_win = function (self, win)
		vim.api.nvim_win_close(win, true);
	end,

	init = function (self)
		if self.__win and vim.api.nvim_win_is_valid(self.__win) then
			return;
		end

		self.__on = vim.api.nvim_get_current_buf();
		self.__onwin = vim.api.nvim_get_current_win();

		self._y = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[1] - 1;
		self._x = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[2];

		self._y = self._y - vim.fn.line('w0', self.__onwin)

		local _off = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].textoff;

		if self.__buf then
			self.__win = vim.api.nvim_open_win(self.__buf, true, {
				relative = "editor",

				row = self._y,
				col = _off + self._x,

				width = self.__entries + 4 + 4,
				height = 5,

				border = "rounded"
			});
		else

			self.__buf = vim.api.nvim_create_buf(false, true);

			self.__win = vim.api.nvim_open_win(self.__buf, true, {
				relative = "editor",

				row = self._y,
				col = _off + self._x,

				width = self.__entries + 4 + 4,
				height = 5,

				focusable = false,
				border = "rounded"
			});
			vim.bo[self.__buf].filetype = "color_picker"

			vim.api.nvim_buf_set_lines(self.__buf, 0, -1, false, {
				"R: ",
				"G: ",
				"B: ",
				"",
				"Color: "
			});
		end

		if not self.__au and not self._close then
			self.__au = vim.api.nvim_create_autocmd({ "WinEnter" }, {
				callback = function (event)
					if vim.bo[event.buf].filetype == "color_picker" then
						return;
					end

					self.__au = vim.api.nvim_del_autocmd(self.__au)

					self._close = vim.api.nvim_del_autocmd(self._close)

					if vim.api.nvim_win_is_valid(self.__win) then
						self:close_win(self.__win)
					end

					vim.api.nvim_buf_clear_namespace(self.__buf, self.__ns, 0, -1);
				end
			});

			self._close = vim.api.nvim_create_autocmd({ "WinClosed" }, {
				buffer = self.__buf,
				callback = function ()
					self.__au = vim.api.nvim_del_autocmd(self.__au)

					self._close = vim.api.nvim_del_autocmd(self._close)

					vim.api.nvim_buf_clear_namespace(self.__buf, self.__ns, 0, -1);
				end
			});
		end

		self:set_options();
		self:create_ui(self.__buf, 1);

		self:add_movement(self.__win, self.__buf, 1);

		self:add_exit(self.__buf);

		self:add_actions(self.__buf, 1)

		self:create_hls();
	end

}
