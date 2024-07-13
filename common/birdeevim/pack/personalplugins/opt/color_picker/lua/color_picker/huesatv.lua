local utils = require("color_picker.utils");
return {
	__buf = nil,
	__win = nil,

	__on = nil,
	__onwin = nil,

	__ns = vim.api.nvim_create_namespace("huePicker"),
	__au = nil,

	_x = 0, _y = 0,

	_h = 0,
	_s = 100,
	_v = 100,

	_close = nil,

	__entries = 20,

	get_level = function (self, field, value)
		local val_per_lvl
		if field == "h" then
			val_per_lvl = 360 / self.__entries;
		end
		if field == "s" then
			val_per_lvl = 100 / self.__entries;
		end
		if field == "v" then
			val_per_lvl = 100 / self.__entries;
		end
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
			-- Hue
			vim.api.nvim_set_hl(0, "Colors_h_" .. tostring(i + 1), {
				fg = utils.toStr({ h = utils.lerp(0, 360, self.__entries, i), s = 100, v = 100 }),
				bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
			});

			-- Saturation
			vim.api.nvim_set_hl(0, "Colors_s_" .. tostring(i + 1), {
				fg = utils.toStr({ h = 0, s = utils.lerp(0, 100, self.__entries, i), v = 100 }),
				bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
			})

			-- Value
			vim.api.nvim_set_hl(0, "Colors_v_" .. tostring(i + 1), {
				fg = utils.toStr({ h = 0, s = 100, v = utils.lerp(0, 100, self.__entries, i) }),
				bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
			})
		end

		vim.api.nvim_set_hl(0, "Colors_hex", {
			bg = utils.toStr({ h = self._h, s = self._s, v = self._v }),
			fg = utils.getFg({ h = self._h, s = self._s, v = self._v })
		});
		vim.api.nvim_set_hl(0, "Colors_hex_fg", {
			fg = utils.toStr({ h = self._h, s = self._s, v = self._v })
		});
	end,
	create_ui = function (self, buf)
		local slider_h = {};
		local slider_s = {};
		local slider_v = {};

		local h = self:get_level("h", self._h);
		local s = self:get_level("s", self._s);
		local v = self:get_level("v", self._v);

		for i = 1, self.__entries do
			if i == h then
				table.insert(slider_h, { "▌", "Colors_h_" .. i })
			else
				table.insert(slider_h, { "█", "Colors_h_" .. i })
			end

			if i == s then
				table.insert(slider_s, { "▌", "Colors_s_" .. i })
			else
				table.insert(slider_s, { "█", "Colors_s_" .. i })
			end

			if i == v then
				table.insert(slider_v, { "▌", "Colors_v_" .. i })
			else
				table.insert(slider_v, { "█", "Colors_v_" .. i })
			end

		end

		vim.api.nvim_buf_set_extmark(buf, self.__ns, 0, 3, {
			virt_text = slider_h,
			hl_mode = "combine",
		});
		vim.api.nvim_buf_set_extmark(buf, self.__ns, 0, 3, {
			virt_text_pos = "right_align",
			virt_text = { { tostring(self._h) } },

			hl_mode = "combine",
		});

		vim.api.nvim_buf_set_extmark(buf, self.__ns, 1, 3, {
			virt_text = slider_s,
			hl_mode = "combine",
		});
		vim.api.nvim_buf_set_extmark(buf, self.__ns, 1, 3, {
			virt_text_pos = "right_align",
			virt_text = { { tostring(self._s) } },

			hl_mode = "combine",
		});

		vim.api.nvim_buf_set_extmark(buf, self.__ns, 2, 3, {
			virt_text = slider_v,
			hl_mode = "combine",
		});
		vim.api.nvim_buf_set_extmark(buf, self.__ns, 2, 3, {
			virt_text_pos = "right_align",
			virt_text = { { tostring(self._v) } },

			hl_mode = "combine",
		});

		vim.api.nvim_buf_set_extmark(buf, self.__ns, 4, 3, {
			virt_text_pos = "eol",
			virt_text = {
				{ utils.toStr({ h = self._h, s = self._s, v = self._v }), "Colors_hex" },
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

				local H = self._h
				local S = self._s
				local V = self._v

				if cursor[1] == 1 and (H - 1) >= 0 then
					self._h = H - 1;
				elseif cursor[1] == 2 and (S - 1) >= 0 then
					self._s = S - 1;
				elseif cursor[1] == 3 and (V - 1) >= 0 then
					self._v = V - 1;
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

				local H = self._h;
				local S = self._s;
				local V = self._v;

				if cursor[1] == 1 and (H - 10) >= 0 then
					self._h = H - 10;
				elseif cursor[1] == 2 and (S - 10) >= 0 then
					self._s = S - 10;
				elseif cursor[1] == 3 and (V - 10) >= 0 then
					self._v = V - 10;
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

				local H = self._h;
				local S = self._s;
				local V = self._v;

				if cursor[1] == 1 and (H + 1) <= 360 then
					self._h = H + 1;
				elseif cursor[1] == 2 and (S + 1) <= 100 then
					self._s = S + 1;
				elseif cursor[1] == 3 and (V + 1) <= 100 then
					self._v = V + 1;
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

				local H = self._h
				local S = self._s
				local V = self._v

				if cursor[1] == 1 and (H + 10) <= 360 then
					self._h = H + 10;
				elseif cursor[1] == 2 and (S + 10) <= 100 then
					self._s = S + 10;
				elseif cursor[1] == 3 and (V + 10) <= 100 then
					self._v = V + 10;
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
				vim.api.nvim_buf_set_text(self.__on, self._y, self._x, self._y, self._x, { utils.toStr({ h = self._h, s = self._s, v = self._v }) });
			end
		});
		vim.api.nvim_buf_set_keymap(buf, "n", "i", "", {
			silent = true,
			callback = function ()
				local inputcolor = utils.hexToRgb(vim.fn.input('Please input a color code: '))
				if inputcolor.r <= 255 and inputcolor.g <= 255 and inputcolor.b <= 255 then
					local inputhsv = utils.rgbToHsv(inputcolor)
					self._h = inputhsv.h
					self._s = inputhsv.s
					self._v = inputhsv.v
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

		for i = 0, self.__entries do
			-- Saturation
			vim.api.nvim_set_hl(0, "Colors_s_" .. tostring(i + 1), {
				fg = utils.toStr({ h = self._h, s = utils.lerp(0, 100, self.__entries, i), v = 100 }),
				bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
			})
			-- Value
			vim.api.nvim_set_hl(0, "Colors_v_" .. tostring(i + 1), {
				fg = utils.toStr({ h = self._h, s = 100, v = utils.lerp(0, 100, self.__entries, i) }),
				bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
			})
		end
		vim.api.nvim_set_hl(0, "Colors_hex", {
			bg = utils.toStr({ h = self._h, s = self._s, v = self._v }),
			fg = utils.getFg({ h = self._h, s = self._s, v = self._v })
		});
		vim.api.nvim_set_hl(0, "Colors_hex_fg", {
			fg = utils.toStr({ h = self._h, s = self._s, v = self._v })
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
			self.__win= vim.api.nvim_open_win(self.__buf, true, {
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
				"H: ",
				"S: ",
				"V: ",
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
