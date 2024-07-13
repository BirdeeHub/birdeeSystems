-- NOTE: This code is from
-- https://github.com/OXY2DEV/colors.nvim/tree/main/lua/colors
local utils = require("color_picker.utils");
return {
	__buf_1 = nil,
	__win_1 = nil,

	__buf_2 = nil,
	__win_2 = nil,

	__buf_3 = nil,
	__win_3 = nil,
	__on = nil,

	__ns = vim.api.nvim_create_namespace("hsvGradientPicker"),
	__au = nil,

	_x = 0, _y = 0,

	_h_1 = 0, _h_2 = 360,
	_s_1 = 100, _s_2 = 100,
	_v_1 = 100, _v_2 = 100,

	_close_1 = nil,
	_close_2 = nil,
	_close_3 = nil,

	__entries = 20,
	_steps = 10,

	_cache = {},
	_cache_pos = 1,

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
		vim.bo[self.__buf_1].modifiable = false;

		vim.wo[self.__win_1].signcolumn = "no"
		vim.wo[self.__win_1].number = false;
		vim.wo[self.__win_1].relativenumber = false;

		vim.bo[self.__buf_2].modifiable = false;

		vim.wo[self.__win_2].signcolumn = "no"
		vim.wo[self.__win_2].number = false;
		vim.wo[self.__win_2].relativenumber = false;

		vim.bo[self.__buf_3].modifiable = false;

		vim.wo[self.__win_3].signcolumn = "no"
		vim.wo[self.__win_3].number = false;
		vim.wo[self.__win_3].relativenumber = false;
	end,

	create_hls = function (self)
		for i = 0, self.__entries do
			-- Red
			vim.api.nvim_set_hl(0, "Colors_h_1_" .. tostring(i + 1), {
				fg = utils.toStr({ h = utils.lerp(0, 360, self.__entries, i), s = 100, v = 100 }),
				bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
			});

			-- Green
			vim.api.nvim_set_hl(0, "Colors_s_1_" .. tostring(i + 1), {
				fg = utils.toStr({ h = 0, s = utils.lerp(0, 100, self.__entries, i), v = 100 }),
				bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
			})

			-- Blue
			vim.api.nvim_set_hl(0, "Colors_v_1_" .. tostring(i + 1), {
				fg = utils.toStr({ h = 0, s = 100, v = utils.lerp(0, 100, self.__entries, i) }),
				bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
			})

			vim.api.nvim_set_hl(0, "Colors_h_2_" .. tostring(i + 1), {
				fg = utils.toStr({ h = utils.lerp(0, 360, self.__entries, i), s = 100, v = 100 }),
				bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
			});

			-- Green
			vim.api.nvim_set_hl(0, "Colors_s_2_" .. tostring(i + 1), {
				fg = utils.toStr({ h = 0, s = utils.lerp(0, 100, self.__entries, i), v = 100 }),
				bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
			})

			-- Blue
			vim.api.nvim_set_hl(0, "Colors_v_2_" .. tostring(i + 1), {
				fg = utils.toStr({ h = 0, s = 100, v = utils.lerp(0, 100, self.__entries, i) }),
				bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
			})
		end


		local rgb_1 = utils.hsvToRgb(self._h_1, self._s_1, self._v_1)
		local rgb_2 = utils.hsvToRgb(self._h_2, self._s_2, self._v_2)

		for i = 0, self._steps do
			vim.api.nvim_set_hl(0, "Colors_p_" .. tostring(i + 1), {
				fg = utils.toStr({ r = utils.lerp(rgb_1.r, rgb_2.r, self._steps, i), g = utils.lerp(rgb_1.g, rgb_2.g, self._steps, i), b = utils.lerp(rgb_1.b, rgb_2.b, self._steps, i)}),
			})

			table.insert(self._cache, utils.toStr({ r = utils.lerp(rgb_1.r, rgb_2.r, self._steps, i), g = utils.lerp(rgb_1.g, rgb_2.g, self._steps, i), b = utils.lerp(rgb_1.b, rgb_2.b, self._steps, i)}))
		end



		vim.api.nvim_set_hl(0, "Colors_hex_1", {
			bg = utils.toStr({ h = self._h_1, s = self._s_1, v = self._v_1 }),
			fg = utils.getFg({ h = self._h_1, s = self._s_1, v = self._v_1 })
		});
		vim.api.nvim_set_hl(0, "Colors_hex_1_fg", {
			fg = utils.toStr({ h = self._h_1, s = self._s_1, v = self._v_1 })
		});

		vim.api.nvim_set_hl(0, "Colors_hex_2", {
			bg = utils.toStr({ h = self._h_2, s = self._s_2, v = self._v_2 }),
			fg = utils.getFg({ h = self._h_2, s = self._s_2, v = self._v_2 })
		});
		vim.api.nvim_set_hl(0, "Colors_hex_2_fg", {
			fg = utils.toStr({ h = self._h_2, s = self._s_2, v = self._v_2 })
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
		local slider_h = {};
		local slider_s = {};
		local slider_v = {};

		local l_h = self:get_level("h", self["_h_" .. n]);
		local l_s = self:get_level("s", self["_s_" .. n]);
		local l_v = self:get_level("v", self["_v_" .. n]);

		for i = 1, self.__entries do
			if i == l_h then
				table.insert(slider_h, { "▌", "Colors_h_" .. n .. "_" .. i })
			else
				table.insert(slider_h, { "█", "Colors_h_" .. n .. "_" .. i })
			end

			if i == l_s then
				table.insert(slider_s, { "▌", "Colors_s_" .. n .. "_" .. i })
			else
				table.insert(slider_s, { "█", "Colors_s_" .. n .. "_" .. i })
			end

			if i == l_v then
				table.insert(slider_v, { "▌", "Colors_v_" .. n .. "_" .. i })
			else
				table.insert(slider_v, { "█", "Colors_v_" .. n .. "_" .. i })
			end

		end

		vim.api.nvim_buf_set_extmark(buf, self.__ns, 0, 3, {
			virt_text = slider_h,
			hl_mode = "combine",
		});
		vim.api.nvim_buf_set_extmark(buf, self.__ns, 0, 3, {
			virt_text_pos = "right_align",
			virt_text = { { tostring(self["_h_" .. n]) } },

			hl_mode = "combine",
		});

		vim.api.nvim_buf_set_extmark(buf, self.__ns, 1, 3, {
			virt_text = slider_s,
			hl_mode = "combine",
		});
		vim.api.nvim_buf_set_extmark(buf, self.__ns, 1, 3, {
			virt_text_pos = "right_align",
			virt_text = { { tostring(self["_s_" .. n]) } },

			hl_mode = "combine",
		});

		vim.api.nvim_buf_set_extmark(buf, self.__ns, 2, 3, {
			virt_text = slider_v,
			hl_mode = "combine",
		});
		vim.api.nvim_buf_set_extmark(buf, self.__ns, 2, 3, {
			virt_text_pos = "right_align",
			virt_text = { { tostring(self["_v_" .. n]) } },

			hl_mode = "combine",
		});

		vim.api.nvim_buf_set_extmark(buf, self.__ns, 4, 3, {
			virt_text_pos = "eol",
			virt_text = {
				{ utils.toStr({ h = self["_h_" .. n], s = self["_s_" .. n], v = self["_v_" .. n] }), "Colors_hex_" .. n },
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

				local H = self["_h_" .. n];
				local S = self["_s_" .. n];
				local V = self["_v_" .. n];

				if cursor[1] == 1 and (H - 1) >= 0 then
					self["_h_" .. n] = H - 1;
				elseif cursor[1] == 2 and (S - 1) >= 0 then
					self["_s_" .. n] = S - 1;
				elseif cursor[1] == 3 and (V - 1) >= 0 then
					self["_v_" .. n] = V - 1;
				end

				self:clear_ns(buf);
				self:update_hex(n);
				self:update_gradient();
				self:create_ui(buf, n)
				self:clear_ns(self.__buf_3);
				self:create_preview();
			end
		});
		vim.api.nvim_buf_set_keymap(buf, "n", "z", "", {
			silent = true,
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(win);

				local H = self["_h_" .. n];
				local S = self["_s_" .. n];
				local V = self["_v_" .. n];

				if cursor[1] == 1 and (H - 10) >= 0 then
					self["_h_" .. n] = H - 10;
				elseif cursor[1] == 2 and (S - 10) >= 0 then
					self["_s_" .. n] = S - 10;
				elseif cursor[1] == 3 and (V - 10) >= 0 then
					self["_v_" .. n] = V - 10;
				end

				self:clear_ns(buf);
				self:update_hex(n);
				self:update_gradient();
				self:create_ui(buf, n)
				self:clear_ns(self.__buf_3);
				self:create_preview();
			end
		});

		vim.api.nvim_buf_set_keymap(buf, "n", "<right>", "", {
			silent = true,
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(win);

				local H = self["_h_" .. n];
				local S = self["_s_" .. n];
				local V = self["_v_" .. n];

				if cursor[1] == 1 and (H + 1) <= 360 then
					self["_h_" .. n] = H + 1;
				elseif cursor[1] == 2 and (S + 1) <= 100 then
					self["_s_" .. n] = S + 1;
				elseif cursor[1] == 3 and (V + 1) <= 100 then
					self["_v_" .. n] = V + 1;
				end

				self:clear_ns(buf);
				self:update_hex(n);
				self:update_gradient();
				self:create_ui(buf, n)
				self:clear_ns(self.__buf_3);
				self:create_preview();
			end
		})
		vim.api.nvim_buf_set_keymap(buf, "n", "x", "", {
			silent = true,
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(win);

				local H = self["_h_" .. n];
				local S = self["_s_" .. n];
				local V = self["_v_" .. n];

				if cursor[1] == 1 and (H + 10) <= 360 then
					self["_h_" .. n] = H + 10;
				elseif cursor[1] == 2 and (S + 10) <= 100 then
					self["_s_" .. n] = S + 10;
				elseif cursor[1] == 3 and (V + 10) <= 100 then
					self["_v_" .. n] = V + 10;
				end

				self:clear_ns(buf);
				self:update_hex(n);
				self:update_gradient();
				self:create_ui(buf, n);
				self:clear_ns(self.__buf_3);
				self:create_preview();
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
				vim.api.nvim_buf_set_text(self.__on, self._y, self._x, self._y, self._x, { utils.toStr({ h = self["_h_" ..n], s = self["_s_" .. n], v = self["_v_" .. n] }) });
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
				local width = vim.api.nvim_win_get_width(self.__win_3)
				if self._steps < width and width > 30 then
					vim.api.nvim_win_set_width(self.__win_3, width - 1)
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
				local width = vim.api.nvim_win_get_width(self.__win_3)
				if self._steps > width then
					vim.api.nvim_win_set_width(self.__win_3, width + 1)
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
		for i = 0, self.__entries do
			-- Saturation
			vim.api.nvim_set_hl(0, "Colors_s_" .. n .. "_" .. tostring(i + 1), {
				fg = utils.toStr({ h = self["_h_" .. n], s = utils.lerp(0, 100, self.__entries, i), v = 100 }),
				bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
			})
			-- Value
			vim.api.nvim_set_hl(0, "Colors_v_" .. n .. "_" .. tostring(i + 1), {
				fg = utils.toStr({ h = self["_h_" .. n], s = 100, v = utils.lerp(0, 100, self.__entries, i) }),
				bg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg
			})
		end
		vim.api.nvim_set_hl(0, "Colors_hex_" .. n, {
			bg = utils.toStr({ h = self["_h_" .. n], s = self["_s_" .. n], v = self["_v_" .. n] }),
			fg = utils.getFg({ h = self["_h_" .. n], s = self["_s_" .. n], v = self["_v_" .. n] })
		});
		vim.api.nvim_set_hl(0, "Colors_hex_" .. n .. "_fg", {
			fg = utils.toStr({ h = self["_h_" .. n], s = self["_s_" .. n], v = self["_v_" .. n] })
		});
	end,
	update_gradient = function (self)
		self._cache = {};

		local rgb_1 = utils.hsvToRgb(self._h_1, self._s_1, self._v_1)
		local rgb_2 = utils.hsvToRgb(self._h_2, self._s_2, self._v_2)

		for i = 0, self._steps do
			vim.api.nvim_set_hl(0, "Colors_p_" .. tostring(i + 1), {
				fg = utils.toStr({ r = utils.lerp(rgb_1.r, rgb_2.r, self._steps, i), g = utils.lerp(rgb_1.g, rgb_2.g, self._steps, i), b = utils.lerp(rgb_1.b, rgb_2.b, self._steps, i)}),
			})

			table.insert(self._cache, utils.toStr({ r = utils.lerp(rgb_1.r, rgb_2.r, self._steps, i), g = utils.lerp(rgb_1.g, rgb_2.g, self._steps, i), b = utils.lerp(rgb_1.b, rgb_2.b, self._steps, i)}))
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

		self._y = self._y - vim.fn.line('w0', self.__onwin)

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

				width = self._steps > 30 and self._steps or 30,
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

			width = self._steps > 30 and self._steps or 30,
			height = 3,

			focusable = false,
			border = "rounded"
		});

		vim.bo[self.__buf_1].filetype = "Gradient_picker"
		vim.bo[self.__buf_2].filetype = "Gradient_picker"
		vim.bo[self.__buf_3].filetype = "Gradient_picker"

		vim.api.nvim_buf_set_lines(self.__buf_1, 0, -1, false, {
			"H: ",
			"S: ",
			"V: ",
			"",
			"Color: "
		});
		vim.api.nvim_buf_set_lines(self.__buf_2, 0, -1, false, {
			"H: ",
			"S: ",
			"V: ",
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
