-- https://github.com/OXY2DEV/colors.nvim/tree/main/lua/colors
local picker = {};
local utils = require("color_picker.utils");

picker.colorPicker = {
	__buf_1 = nil,
	__win_1 = nil,

	__on = nil,

	__ns = vim.api.nvim_create_namespace("colorPicker"),
	__au = nil,

	_x = 0, _y = 0,

	_r_1 = 0,
	_g_1 = 0,
	_b_1 = 0,

	_close_1 = nil,

	__entries = 20,
	_steps = 10,

	_cache = {},
	_cache_pos = 1,

	get_level = function (self, value)
		local val_per_lvl = 255 / self.__entries;
		local lvl = math.floor(value / val_per_lvl);

		return math.min(math.max(lvl, 1), self.__entries);
	end,

	set_options = function (self)
		vim.bo[self.__buf_1].modifiable = false;

		vim.wo[self.__win_1].number = false;
		vim.wo[self.__win_1].relativenumber = false;
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

		vim.api.nvim_set_hl(0, "Colors_hex_1", {
			bg = utils.toStr({ r = self._r_1, g = self._g_1, b = self._b_1 }),
			fg = utils.getFg({ r = self._r_1, g = self._g_1, b = self._b_1 })
		});
		vim.api.nvim_set_hl(0, "Colors_hex_1_fg", {
			fg = utils.toStr({ r = self._r_1, g = self._g_1, b = self._b_1 })
		});
	end,
	create_ui = function (self, buf, n)
		local slider_r = {};
		local slider_g = {};
		local slider_b = {};

		local l_r = self:get_level(self["_r_" .. n]);
		local l_g = self:get_level(self["_g_" .. n]);
		local l_b = self:get_level(self["_b_" .. n]);

		for i = 1, self.__entries do
			if i == l_r then
				table.insert(slider_r, { "▌", "Colors_r_" .. i })
			else
				table.insert(slider_r, { "█", "Colors_r_" .. i })
			end

			if i == l_g then
				table.insert(slider_g, { "▌", "Colors_g_" .. i })
			else
				table.insert(slider_g, { "█", "Colors_g_" .. i })
			end

			if i == l_b then
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
			virt_text = { { tostring(self["_r_" .. n]) } },

			hl_mode = "combine",
		});

		vim.api.nvim_buf_set_extmark(buf, self.__ns, 1, 3, {
			virt_text = slider_g,
			hl_mode = "combine",
		});
		vim.api.nvim_buf_set_extmark(buf, self.__ns, 1, 3, {
			virt_text_pos = "right_align",
			virt_text = { { tostring(self["_g_" .. n]) } },

			hl_mode = "combine",
		});

		vim.api.nvim_buf_set_extmark(buf, self.__ns, 2, 3, {
			virt_text = slider_b,
			hl_mode = "combine",
		});
		vim.api.nvim_buf_set_extmark(buf, self.__ns, 2, 3, {
			virt_text_pos = "right_align",
			virt_text = { { tostring(self["_b_" .. n]) } },

			hl_mode = "combine",
		});

		vim.api.nvim_buf_set_extmark(buf, self.__ns, 4, 3, {
			virt_text_pos = "eol",
			virt_text = {
				{ utils.toStr({ r = self["_r_" .. n], g = self["_g_" .. n], b = self["_b_" .. n] }), "Colors_hex_" .. n },
				{ " ██", "Colors_hex_" .. n .. "_fg" },
			},

			hl_mode = "combine",
		});
	end,

	add_movement = function (self, win, buf, n)
		vim.api.nvim_buf_set_keymap(buf, "n", "<left>", "", {
			silent = true,
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(win);

				local R = self["_r_" .. n];
				local G = self["_g_" .. n];
				local B = self["_b_" .. n];

				if cursor[1] == 1 and (R - 1) >= 0 then
					self["_r_" .. n] = R - 1;
				elseif cursor[1] == 2 and (G - 1) >= 0 then
					self["_g_" .. n] = G - 1;
				elseif cursor[1] == 3 and (B - 1) >= 0 then
					self["_b_" .. n] = B - 1;
				end

				self:clear_ns(buf);
				self:update_hex(n);
				self:create_ui(buf, n)
			end
		});
		vim.api.nvim_buf_set_keymap(buf, "n", "z", "", {
			silent = true,
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(win);

				local R = self["_r_" .. n];
				local G = self["_g_" .. n];
				local B = self["_b_" .. n];

				if cursor[1] == 1 and (R - 10) >= 0 then
					self["_r_" .. n] = R - 10;
				elseif cursor[1] == 2 and (G - 10) >= 0 then
					self["_g_" .. n] = G - 10;
				elseif cursor[1] == 3 and (B - 10) >= 0 then
					self["_b_" .. n] = B - 10;
				end

				self:clear_ns(buf);
				self:update_hex(n);
				self:create_ui(buf, n)
			end
		});

		vim.api.nvim_buf_set_keymap(buf, "n", "<right>", "", {
			silent = true,
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(win);

				local R = self["_r_" .. n];
				local G = self["_g_" .. n];
				local B = self["_b_" .. n];

				if cursor[1] == 1 and (R + 1) <= 255 then
					self["_r_" .. n] = R + 1;
				elseif cursor[1] == 2 and (G + 1) <= 255 then
					self["_g_" .. n] = G + 1;
				elseif cursor[1] == 3 and (B + 1) <= 255 then
					self["_b_" .. n] = B + 1;
				end

				self:clear_ns(buf);
				self:update_hex(n);
				self:create_ui(buf, n)
			end
		})
		vim.api.nvim_buf_set_keymap(buf, "n", "x", "", {
			silent = true,
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(win);

				local R = self["_r_" .. n];
				local G = self["_g_" .. n];
				local B = self["_b_" .. n];

				if cursor[1] == 1 and (R + 10) <= 255 then
					self["_r_" .. n] = R + 10;
				elseif cursor[1] == 2 and (G + 10) <= 255 then
					self["_g_" .. n] = G + 10;
				elseif cursor[1] == 3 and (B + 10) <= 255 then
					self["_b_" .. n] = B + 10;
				end

				self:clear_ns(buf);
				self:update_hex(n);
				self:create_ui(buf, n);
			end
		});
	end,
	add_switches = function (self, buf)
		vim.api.nvim_buf_set_keymap(buf, "n", "<Tab>", "", {
			silent = true,
			callback = function ()
				local c_win = vim.api.nvim_get_current_win();

				vim.api.nvim_set_current_win(self.__win_1);
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
	add_actions = function (self, buf, n)
		vim.api.nvim_buf_set_keymap(buf, "n", "<Enter>", "", {
			silent = true,
			callback = function ()
				vim.api.nvim_set_current_win(self.__onwin)
				vim.api.nvim_buf_set_text(self.__on, self._y, self._x, self._y, self._x, { utils.toStr({ r = self["_r_" ..n], g = self["_g_" .. n], b = self["_b_" .. n] }) });
			end
		});
	end,

	clear_ns = function (self, buf)
		vim.api.nvim_buf_clear_namespace(buf, self.__ns, 0, -1)
	end,
	update_hex = function (self, n)
		vim.api.nvim_set_hl(0, "Colors_hex_" .. n, {
			bg = utils.toStr({ r = self["_r_" .. n], g = self["_g_" .. n], b = self["_b_" .. n] }),
			fg = utils.getFg({ r = self["_r_" .. n], g = self["_g_" .. n], b = self["_b_" .. n] })
		});
		vim.api.nvim_set_hl(0, "Colors_hex_" .. n .. "_fg", {
			fg = utils.toStr({ r = self["_r_" .. n], g = self["_g_" .. n], b = self["_b_" .. n] })
		});
	end,
	close_win = function (self, win)
		vim.api.nvim_win_close(win, true);
	end,

	init = function (self)
		if (self.__win_1 and self.__win_2 and self.__win_3) and (vim.api.nvim_win_is_valid(self.__win_1) or vim.api.nvim_win_is_valid(self.__win_2) or vim.api.nvim_win_is_valid(self.__win_3)) then
			return;
		end

		self.__on = vim.api.nvim_get_current_buf();
		self.__onwin = vim.api.nvim_get_current_win();

		self._y = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[1] - 1;
		self._x = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[2];

		local _off = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].textoff;

		if self.__buf_1 and self.__buf_2 and self.__buf_3 then
			self.__win_1 = vim.api.nvim_open_win(self.__buf_1, true, {
				relative = "editor",

				row = self._y,
				col = _off + self._x,

				width = self.__entries + 4 + 4,
				height = 5,

				border = "rounded"
			});
			goto bufReady;
		end

		self.__buf_1 = vim.api.nvim_create_buf(false, true);

		self.__win_1 = vim.api.nvim_open_win(self.__buf_1, true, {
			relative = "editor",

			row = self._y,
			col = _off + self._x,

			width = self.__entries + 4 + 4,
			height = 5,

			focusable = false,
			border = "rounded"
		});
		vim.bo[self.__buf_1].filetype = "Gradient_picker"

		vim.api.nvim_buf_set_lines(self.__buf_1, 0, -1, false, {
			"R: ",
			"G: ",
			"B: ",
			"",
			"Color: "
		});

		::bufReady::

		if not self.__au and not self._close_1 then
			self.__au = vim.api.nvim_create_autocmd({ "WinEnter" }, {
				callback = function (event)
					if vim.bo[event.buf].filetype == "Gradient_picker" then
						return;
					end

					self.__au = vim.api.nvim_del_autocmd(self.__au)

					self._close_1 = vim.api.nvim_del_autocmd(self._close_1)

					if vim.api.nvim_win_is_valid(self.__win_1) then
						self:close_win(self.__win_1)
					end

					vim.api.nvim_buf_clear_namespace(self.__buf_1, self.__ns, 0, -1);
				end
			});

			self._close_1 = vim.api.nvim_create_autocmd({ "WinClosed" }, {
				buffer = self.__buf_1,
				callback = function ()
					self.__au = vim.api.nvim_del_autocmd(self.__au)

					self._close_1 = vim.api.nvim_del_autocmd(self._close_1)

					vim.api.nvim_buf_clear_namespace(self.__buf_1, self.__ns, 0, -1);
				end
			});
		end

		self:set_options();
		self:create_ui(self.__buf_1, 1);

		self:add_movement(self.__win_1, self.__buf_1, 1);

		self:add_switches(self.__buf_1);

		self:add_exit(self.__buf_1);

		self:add_actions(self.__buf_1, 1)

		self:create_hls();
	end

}

picker.gradientPicker = {
	__buf_1 = nil,
	__win_1 = nil,

	__buf_2 = nil,
	__win_2 = nil,

	__buf_3 = nil,
	__win_3 = nil,
	__on = nil,

	__ns = vim.api.nvim_create_namespace("gradientPicker"),
	__au = nil,

	_x = 0, _y = 0,

	_r_1 = 0, _r_2 = 25,
	_g_1 = 0, _g_2 = 255,
	_b_1 = 0, _b_2 = 255,

	_close_1 = nil,
	_close_2 = nil,
	_close_3 = nil,

	__entries = 20,
	_steps = 10,

	_cache = {},
	_cache_pos = 1,

	get_level = function (self, value)
		local val_per_lvl = 255 / self.__entries;
		local lvl = math.floor(value / val_per_lvl);

		return math.min(math.max(lvl, 1), self.__entries);
	end,

	set_options = function (self)
		vim.bo[self.__buf_1].modifiable = false;

		vim.wo[self.__win_1].number = false;
		vim.wo[self.__win_1].relativenumber = false;

		vim.bo[self.__buf_2].modifiable = false;

		vim.wo[self.__win_2].number = false;
		vim.wo[self.__win_2].relativenumber = false;

		vim.bo[self.__buf_3].modifiable = false;

		vim.wo[self.__win_3].number = false;
		vim.wo[self.__win_3].relativenumber = false;
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

		for i = 0, self._steps do
			vim.api.nvim_set_hl(0, "Colors_p_" .. tostring(i + 1), {
				fg = utils.toStr({ r = utils.lerp(self._r_1, self._r_2, self._steps, i), g = utils.lerp(self._g_1, self._g_2, self._steps, i), b = utils.lerp(self._b_1, self._b_2, self._steps, i)}),
				bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
			})

			table.insert(self._cache, utils.toStr({ r = utils.lerp(self._r_1, self._r_2, self._steps, i), g = utils.lerp(self._g_1, self._g_2, self._steps, i), b = utils.lerp(self._b_1, self._b_2, self._steps, i)}))
		end


		vim.api.nvim_set_hl(0, "Colors_hex_1", {
			bg = utils.toStr({ r = self._r_1, g = self._g_1, b = self._b_1 }),
			fg = utils.getFg({ r = self._r_1, g = self._g_1, b = self._b_1 })
		});
		vim.api.nvim_set_hl(0, "Colors_hex_1_fg", {
			fg = utils.toStr({ r = self._r_1, g = self._g_1, b = self._b_1 })
		});

		vim.api.nvim_set_hl(0, "Colors_hex_2", {
			bg = utils.toStr({ r = self._r_2, g = self._g_2, b = self._b_2 }),
			fg = utils.getFg({ r = self._r_2, g = self._g_2, b = self._b_2 })
		});
		vim.api.nvim_set_hl(0, "Colors_hex_2_fg", {
			fg = utils.toStr({ r = self._r_2, g = self._g_2, b = self._b_2 })
		});


		vim.api.nvim_set_hl(0, "Colors_hex_p", {
			bg = self._cache[self._cache_pos],
			fg = utils.getFg(utils.hexToTable(self._cache[self._cache_pos]))
		});
		vim.api.nvim_set_hl(0, "Colors_hex_p_fg", {
			fg = self._cache[self._cache_pos],
		});
	end,
	create_ui = function (self, buf, n)
		local slider_r = {};
		local slider_g = {};
		local slider_b = {};

		local l_r = self:get_level(self["_r_" .. n]);
		local l_g = self:get_level(self["_g_" .. n]);
		local l_b = self:get_level(self["_b_" .. n]);

		for i = 1, self.__entries do
			if i == l_r then
				table.insert(slider_r, { "▌", "Colors_r_" .. i })
			else
				table.insert(slider_r, { "█", "Colors_r_" .. i })
			end

			if i == l_g then
				table.insert(slider_g, { "▌", "Colors_g_" .. i })
			else
				table.insert(slider_g, { "█", "Colors_g_" .. i })
			end

			if i == l_b then
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
			virt_text = { { tostring(self["_r_" .. n]) } },

			hl_mode = "combine",
		});

		vim.api.nvim_buf_set_extmark(buf, self.__ns, 1, 3, {
			virt_text = slider_g,
			hl_mode = "combine",
		});
		vim.api.nvim_buf_set_extmark(buf, self.__ns, 1, 3, {
			virt_text_pos = "right_align",
			virt_text = { { tostring(self["_g_" .. n]) } },

			hl_mode = "combine",
		});

		vim.api.nvim_buf_set_extmark(buf, self.__ns, 2, 3, {
			virt_text = slider_b,
			hl_mode = "combine",
		});
		vim.api.nvim_buf_set_extmark(buf, self.__ns, 2, 3, {
			virt_text_pos = "right_align",
			virt_text = { { tostring(self["_b_" .. n]) } },

			hl_mode = "combine",
		});

		vim.api.nvim_buf_set_extmark(buf, self.__ns, 4, 3, {
			virt_text_pos = "eol",
			virt_text = {
				{ utils.toStr({ r = self["_r_" .. n], g = self["_g_" .. n], b = self["_b_" .. n] }), "Colors_hex_" .. n },
				{ " ██", "Colors_hex_" .. n .. "_fg" },
			},

			hl_mode = "combine",
		});
	end,
	create_preview = function (self)
		local _p = {};

		for i = 1, self._steps do
			table.insert(_p, { "█", "Colors_p_" .. i })
		end

		vim.api.nvim_buf_set_extmark(self.__buf_3, self.__ns, 0, 0, {
			virt_text_pos = "overlay",
			virt_text = _p,
			hl_mode = "combine",
		});
		vim.api.nvim_buf_set_extmark(self.__buf_3, self.__ns, 2, 0, {
			virt_text_pos = "eol",
			virt_text = {
				{ self._cache[self._cache_pos], "Colors_hex_p" },
				{ " ██", "Colors_hex_p_fg" },
			},

			hl_mode = "combine",
		});
	end,

	add_movement = function (self, win, buf, n)
		vim.api.nvim_buf_set_keymap(buf, "n", "<left>", "", {
			silent = true,
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(win);

				local R = self["_r_" .. n];
				local G = self["_g_" .. n];
				local B = self["_b_" .. n];

				if cursor[1] == 1 and (R - 1) >= 0 then
					self["_r_" .. n] = R - 1;
				elseif cursor[1] == 2 and (G - 1) >= 0 then
					self["_g_" .. n] = G - 1;
				elseif cursor[1] == 3 and (B - 1) >= 0 then
					self["_b_" .. n] = B - 1;
				end

				self:clear_ns(buf);
				self:update_hex(n);
				self:update_gradient();
				self:create_ui(buf, n)
			end
		});
		vim.api.nvim_buf_set_keymap(buf, "n", "z", "", {
			silent = true,
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(win);

				local R = self["_r_" .. n];
				local G = self["_g_" .. n];
				local B = self["_b_" .. n];

				if cursor[1] == 1 and (R - 10) >= 0 then
					self["_r_" .. n] = R - 10;
				elseif cursor[1] == 2 and (G - 10) >= 0 then
					self["_g_" .. n] = G - 10;
				elseif cursor[1] == 3 and (B - 10) >= 0 then
					self["_b_" .. n] = B - 10;
				end

				self:clear_ns(buf);
				self:update_hex(n);
				self:update_gradient();
				self:create_ui(buf, n)
			end
		});

		vim.api.nvim_buf_set_keymap(buf, "n", "<right>", "", {
			silent = true,
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(win);

				local R = self["_r_" .. n];
				local G = self["_g_" .. n];
				local B = self["_b_" .. n];

				if cursor[1] == 1 and (R + 1) <= 255 then
					self["_r_" .. n] = R + 1;
				elseif cursor[1] == 2 and (G + 1) <= 255 then
					self["_g_" .. n] = G + 1;
				elseif cursor[1] == 3 and (B + 1) <= 255 then
					self["_b_" .. n] = B + 1;
				end

				self:clear_ns(buf);
				self:update_hex(n);
				self:update_gradient();
				self:create_ui(buf, n)
			end
		})
		vim.api.nvim_buf_set_keymap(buf, "n", "x", "", {
			silent = true,
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(win);

				local R = self["_r_" .. n];
				local G = self["_g_" .. n];
				local B = self["_b_" .. n];

				if cursor[1] == 1 and (R + 10) <= 255 then
					self["_r_" .. n] = R + 10;
				elseif cursor[1] == 2 and (G + 10) <= 255 then
					self["_g_" .. n] = G + 10;
				elseif cursor[1] == 3 and (B + 10) <= 255 then
					self["_b_" .. n] = B + 10;
				end

				self:clear_ns(buf);
				self:update_hex(n);
				self:update_gradient();
				self:create_ui(buf, n);
			end
		});
	end,
	add_switches = function (self, buf)
		vim.api.nvim_buf_set_keymap(buf, "n", "<Tab>", "", {
			silent = true,
			callback = function ()
				local c_win = vim.api.nvim_get_current_win();

				if c_win == self.__win_1 then
					vim.api.nvim_set_current_win(self.__win_2);
				elseif c_win == self.__win_2 then
					vim.api.nvim_set_current_win(self.__win_3);
				else
					vim.api.nvim_set_current_win(self.__win_1);
				end
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
	add_actions = function (self, buf, n)
		vim.api.nvim_buf_set_keymap(buf, "n", "<Enter>", "", {
			silent = true,
			callback = function ()
				vim.api.nvim_set_current_win(self.__onwin)
				vim.api.nvim_buf_set_text(self.__on, self._y, self._x, self._y, self._x, { utils.toStr({ r = self["_r_" ..n], g = self["_g_" .. n], b = self["_b_" .. n] }) });
			end
		});

		vim.api.nvim_buf_set_keymap(buf, "n", "<Space>", "", {
			silent = true,
			callback = function ()
				local _o = "";

				for c, col in ipairs(self._cache) do
					_o = _o .. '"' .. col .. '"';

					if c ~= #self._cache then
						_o = _o .. ", ";
					end
				end

				vim.api.nvim_set_current_win(self.__onwin)
				vim.api.nvim_buf_set_text(self.__on, self._y, self._x, self._y, self._x, { _o });
			end
		});
	end,
	add_grad_control = function (self)
		vim.api.nvim_buf_set_keymap(self.__buf_3, "n", "<left>", "", {
			silent = true,
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(self.__win_3);

				if cursor[1] == 1 and (self._cache_pos - 1) >= 1 then
					self._cache_pos = self._cache_pos - 1;
				end

				self:clear_ns(self.__buf_3);
				self:update_gradient();
				self:create_preview();
			end
		});
		vim.api.nvim_buf_set_keymap(self.__buf_3, "n", "z", "", {
			silent = true,
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(self.__win_3);

				if cursor[1] == 1 and (self._steps - 1) >= 5 then
					self._steps = self._steps - 1;
				end

				self:clear_ns(self.__buf_3);
				self:update_gradient();
				self:create_preview();
			end
		});

		vim.api.nvim_buf_set_keymap(self.__buf_3, "n", "<Enter>", "", {
			silent = true,
			callback = function ()
				local _o = "";

				for c, col in ipairs(self._cache) do
					_o = _o .. '"' .. col .. '"';

					if c ~= #self._cache then
						_o = _o .. ", ";
					end
				end

				vim.api.nvim_set_current_win(self.__onwin)
				vim.api.nvim_buf_set_text(self.__on, self._y, self._x, self._y, self._x, { _o });
			end
		});

		vim.api.nvim_buf_set_keymap(self.__buf_3, "n", "<right>", "", {
			silent = true,
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(self.__win_3);

				if cursor[1] == 1 and (self._cache_pos + 1) <= self._steps then
					self._cache_pos = self._cache_pos + 1;
				end

				self:clear_ns(self.__buf_3);
				self:update_gradient();
				self:create_preview();
			end
		});
		vim.api.nvim_buf_set_keymap(self.__buf_3, "n", "x", "", {
			silent = true,
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(self.__win_3);

				if cursor[1] == 1 then
					self._steps = self._steps + 1;
				end

				self:clear_ns(self.__buf_3);
				self:update_gradient();
				self:create_preview();
			end
		});
	end,

	clear_ns = function (self, buf)
		vim.api.nvim_buf_clear_namespace(buf, self.__ns, 0, -1)
	end,
	update_hex = function (self, n)
		vim.api.nvim_set_hl(0, "Colors_hex_" .. n, {
			bg = utils.toStr({ r = self["_r_" .. n], g = self["_g_" .. n], b = self["_b_" .. n] }),
			fg = utils.getFg({ r = self["_r_" .. n], g = self["_g_" .. n], b = self["_b_" .. n] })
		});
		vim.api.nvim_set_hl(0, "Colors_hex_" .. n .. "_fg", {
			fg = utils.toStr({ r = self["_r_" .. n], g = self["_g_" .. n], b = self["_b_" .. n] })
		});
	end,
	update_gradient = function (self)
		self._cache = {};

		for i = 0, self._steps do
			vim.api.nvim_set_hl(0, "Colors_p_" .. tostring(i + 1), {
				fg = utils.toStr({ r = utils.lerp(self._r_1, self._r_2, self._steps, i), g = utils.lerp(self._g_1, self._g_2, self._steps, i), b = utils.lerp(self._b_1, self._b_2, self._steps, i)}),
			})

			table.insert(self._cache, utils.toStr({ r = utils.lerp(self._r_1, self._r_2, self._steps, i), g = utils.lerp(self._g_1, self._g_2, self._steps, i), b = utils.lerp(self._b_1, self._b_2, self._steps, i)}))
		end

		vim.api.nvim_set_hl(0, "Colors_hex_p", {
			bg = self._cache[self._cache_pos],
			fg = utils.getFg(utils.hexToTable(self._cache[self._cache_pos]))
		});
		vim.api.nvim_set_hl(0, "Colors_hex_p_fg", {
			fg = self._cache[self._cache_pos],
		});
	end,
	close_win = function (self, win)
		vim.api.nvim_win_close(win, true);
	end,

	init = function (self)
		if (self.__win_1 and self.__win_2 and self.__win_3) and (vim.api.nvim_win_is_valid(self.__win_1) or vim.api.nvim_win_is_valid(self.__win_2) or vim.api.nvim_win_is_valid(self.__win_3)) then
			return;
		end

		self.__on = vim.api.nvim_get_current_buf();
		self.__onwin = vim.api.nvim_get_current_win();

		self._y = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[1] - 1;
		self._x = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[2];

		local _off = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].textoff;

		if self.__buf_1 and self.__buf_2 and self.__buf_3 then
			self.__win_1 = vim.api.nvim_open_win(self.__buf_1, true, {
				relative = "editor",

				row = self._y,
				col = _off + self._x,

				width = self.__entries + 4 + 4,
				height = 5,

				border = "rounded"
			});
			self.__win_2 = vim.api.nvim_open_win(self.__buf_2, false, {
				relative = "editor",

				row = self._y,
				col = _off + self._x + self.__entries + 6 + 4,

				width = self.__entries + 4 + 4,
				height = 5,

				border = "rounded"
			});
			self.__win_3 = vim.api.nvim_open_win(self.__buf_3, false, {
				relative = "editor",

				row = self._y + 7,
				col = _off + self._x,

				width = self._steps,
				height = 3,

				border = "rounded"
			});

			goto bufReady;
		end

		self.__buf_1 = vim.api.nvim_create_buf(false, true);
		self.__buf_2 = vim.api.nvim_create_buf(false, true);
		self.__buf_3 = vim.api.nvim_create_buf(false, true);

		self.__win_1 = vim.api.nvim_open_win(self.__buf_1, true, {
			relative = "editor",

			row = self._y,
			col = _off + self._x,

			width = self.__entries + 4 + 4,
			height = 5,

			focusable = false,
			border = "rounded"
		});
		self.__win_2 = vim.api.nvim_open_win(self.__buf_2, false, {
			relative = "editor",

			row = self._y,
			col = _off + self._x + self.__entries + 6 + 4,

			width = self.__entries + 4 + 4,
			height = 5,

			focusable = false,
			border = "rounded"
		});
		self.__win_3 = vim.api.nvim_open_win(self.__buf_3, false, {
			relative = "editor",

			row = self._y + 7,
			col = _off + self._x,

			width = self._steps,
			height = 3,

			focusable = false,
			border = "rounded"
		});

		vim.bo[self.__buf_1].filetype = "Gradient_picker"
		vim.bo[self.__buf_2].filetype = "Gradient_picker"
		vim.bo[self.__buf_3].filetype = "Gradient_picker"

		vim.api.nvim_buf_set_lines(self.__buf_1, 0, -1, false, {
			"R: ",
			"G: ",
			"B: ",
			"",
			"Color: "
		});
		vim.api.nvim_buf_set_lines(self.__buf_2, 0, -1, false, {
			"R: ",
			"G: ",
			"B: ",
			"",
			"Color: "
		});
		vim.api.nvim_buf_set_lines(self.__buf_3, 0, -1, false, {
			"",
			string.rep("─", self._steps > 30 and self._steps or 30),
			"Current color: "
		});

		::bufReady::

		if not self.__au and not self._close_1 and not self._close_2 and not self._close_3 then
			self.__au = vim.api.nvim_create_autocmd({ "WinEnter" }, {
				callback = function (event)
					if vim.bo[event.buf].filetype == "Gradient_picker" then
						return;
					end

					self.__au = vim.api.nvim_del_autocmd(self.__au)

					self._close_1 = vim.api.nvim_del_autocmd(self._close_1)
					self._close_2 = vim.api.nvim_del_autocmd(self._close_2);
					self._close_3 = vim.api.nvim_del_autocmd(self._close_3)

					if vim.api.nvim_win_is_valid(self.__win_1) then
						self:close_win(self.__win_1)
					end

					if vim.api.nvim_win_is_valid(self.__win_2) then
						self:close_win(self.__win_2)
					end

					if vim.api.nvim_win_is_valid(self.__win_3) then
						self:close_win(self.__win_3)
					end

					vim.api.nvim_buf_clear_namespace(self.__buf_1, self.__ns, 0, -1);
					vim.api.nvim_buf_clear_namespace(self.__buf_2, self.__ns, 0, -1);
					vim.api.nvim_buf_clear_namespace(self.__buf_3, self.__ns, 0, -1);
				end
			});

			self._close_1 = vim.api.nvim_create_autocmd({ "WinClosed" }, {
				buffer = self.__buf_1,
				callback = function ()
					self.__au = vim.api.nvim_del_autocmd(self.__au)

					self._close_1 = vim.api.nvim_del_autocmd(self._close_1)
					self._close_2 = vim.api.nvim_del_autocmd(self._close_2);
					self._close_3 = vim.api.nvim_del_autocmd(self._close_3)

					if vim.api.nvim_win_is_valid(self.__win_2) then
						self:close_win(self.__win_2)
					end

					if vim.api.nvim_win_is_valid(self.__win_3) then
						self:close_win(self.__win_3)
					end

					vim.api.nvim_buf_clear_namespace(self.__buf_1, self.__ns, 0, -1);
					vim.api.nvim_buf_clear_namespace(self.__buf_2, self.__ns, 0, -1);
					vim.api.nvim_buf_clear_namespace(self.__buf_3, self.__ns, 0, -1);
				end
			});

			self._close_2 = vim.api.nvim_create_autocmd({ "WinClosed" }, {
				buffer = self.__buf_2,
				callback = function ()
					self.__au = vim.api.nvim_del_autocmd(self.__au)

					self._close_1 = vim.api.nvim_del_autocmd(self._close_1)
					self._close_2 = vim.api.nvim_del_autocmd(self._close_2);
					self._close_3 = vim.api.nvim_del_autocmd(self._close_3)

					if vim.api.nvim_win_is_valid(self.__win_1) then
						self:close_win(self.__win_1)
					end

					if vim.api.nvim_win_is_valid(self.__win_3) then
						self:close_win(self.__win_3)
					end

					vim.api.nvim_buf_clear_namespace(self.__buf_1, self.__ns, 0, -1);
					vim.api.nvim_buf_clear_namespace(self.__buf_2, self.__ns, 0, -1);
					vim.api.nvim_buf_clear_namespace(self.__buf_3, self.__ns, 0, -1);
				end
			})

			self._close_3 = vim.api.nvim_create_autocmd({ "WinClosed" }, {
				buffer = self.__buf_3,
				callback = function ()
					self.__au = vim.api.nvim_del_autocmd(self.__au)

					self._close_1 = vim.api.nvim_del_autocmd(self._close_1)
					self._close_2 = vim.api.nvim_del_autocmd(self._close_2);
					self._close_3 = vim.api.nvim_del_autocmd(self._close_3)

					if vim.api.nvim_win_is_valid(self.__win_1) then
						self:close_win(self.__win_1)
					end

					if vim.api.nvim_win_is_valid(self.__win_2) then
						self:close_win(self.__win_2)
					end

					vim.api.nvim_buf_clear_namespace(self.__buf_1, self.__ns, 0, -1);
					vim.api.nvim_buf_clear_namespace(self.__buf_2, self.__ns, 0, -1);
					vim.api.nvim_buf_clear_namespace(self.__buf_3, self.__ns, 0, -1);
				end
			})
		end

		self:set_options();
		self:create_ui(self.__buf_1, 1);
		self:create_ui(self.__buf_2, 2);

		self:add_movement(self.__win_1, self.__buf_1, 1);
		self:add_movement(self.__win_2, self.__buf_2, 2);

		self:add_switches(self.__buf_1);
		self:add_switches(self.__buf_2);
		self:add_switches(self.__buf_3);

		self:add_exit(self.__buf_1);
		self:add_exit(self.__buf_2);
		self:add_exit(self.__buf_3);

		self:add_actions(self.__buf_1, 1)
		self:add_actions(self.__buf_2, 2)
		self:add_grad_control();

		self:create_hls();
		self:create_preview();
	end
}

return picker;
