-- awesome_mode: api-level=4:screen=on

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
-- Declarative object management
local ruled = require("ruled")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:

require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened" .. (startup and " during startup!" or "!"),
        message = message
    }
end)
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

local nix = require("nix-info")

-- This is used later as the default terminal and editor to run.
local terminal = nix.terminal
local editor = nix.editor or os.getenv("EDITOR") or "nvim"
local editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = nix.modkey

-- i3-style direction keys
local left  = nix.left  or "h"
local down  = nix.down  or "j"
local up    = nix.up    or "k"
local right = nix.right or "l"

-- i3-style gaps settings
local gaps_inner = nix.gaps_inner or 5
local gaps_outer = nix.gaps_outer or 1
local smart_gaps = nix.smart_gaps ~= false
local smart_borders = nix.smart_borders or "no_gaps"
local default_border_width = nix.default_border_width or 3
local default_floating_border_width = nix.default_floating_border_width or 1
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
local myawesomemenu = {
    { "hotkeys",     function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual",      terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart",     awesome.restart },
    { "quit",        function() awesome.quit() end },
}

local mymainmenu = awful.menu({
    items = {
        { "awesome", myawesomemenu, beautiful.awesome_icon },
        { "open terminal", terminal },
        { "open terminal no tmux", nix.terminalSTR }
    }
})

local mylauncher = awful.widget.launcher({
    image = nix.flake_svg,
    menu = mymainmenu
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Gaps functions
local function update_gaps()
    awful.screen.focused().padding = {
        left   = gaps_outer,
        right  = gaps_outer,
        top    = gaps_outer,
        bottom = gaps_outer,
    }
    for _, tag in ipairs(awful.screen.focused().selected_tags) do
        tag.gap_single_client = smart_gaps
        tag.gap_colors = {
            inner = beautiful.taglist_spacing or 0,
        }
    end
end

local function inc_gaps_inner(delta)
    gaps_inner = math.max(0, gaps_inner + delta)
    update_gaps()
end

local function inc_gaps_outer(delta)
    gaps_outer = math.max(0, gaps_outer + delta)
    update_gaps()
end

-- {{{ Tag layout
-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.tile,
        awful.layout.suit.tile.left,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.tile.top,
        awful.layout.suit.fair,
        awful.layout.suit.fair.horizontal,
        awful.layout.suit.spiral,
        awful.layout.suit.spiral.dwindle,
        awful.layout.suit.max,
        awful.layout.suit.max.fullscreen,
        awful.layout.suit.magnifier,
        awful.layout.suit.corner.nw,
        awful.layout.suit.floating,
    })
end)
-- }}}

-- {{{ Wallpaper
screen.connect_signal("request::wallpaper", function(s)
    awful.wallpaper {
        screen = s,
        widget = {
            {
                image     = nix.wallpaper,
                upscale   = true,
                downscale = true,
                widget    = wibox.widget.imagebox,
            },
            valign = "center",
            halign = "center",
            tiled  = false,
            widget = wibox.container.tile,
        }
    }
end)
-- }}}

-- {{{ Wibar

-- Keyboard map indicator and switcher
local mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a textclock widget
local mytextclock = wibox.widget.textclock()

screen.connect_signal("request::desktop_decoration", function(s)
    -- Each screen has its own tag table.
    local svgFillColor = "#d3d3d3"
    local svgBase      = [[<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">]]
    local svgEnd       = [[</svg>]]

    local terminalSvg  = svgBase ..
        [[<path fill="]] ..
        svgFillColor ..
        [[" d="M20 4H4a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h16c1.1 0 2-.9 2-2V6a2 2 0 0 0-2-2zm0 14H4V8h16v10zm-2-1h-6v-2h6v2zM7.5 17l-1.41-1.41L8.67 13l-2.59-2.59L7.5 9l4 4l-4 4z"/>]] ..
        svgEnd

    local globeSvg     = svgBase ..
        [[<path fill="]] ..
        svgFillColor ..
        [[" d="M16.36 14c.08-.66.14-1.32.14-2c0-.68-.06-1.34-.14-2h3.38c.16.64.26 1.31.26 2s-.1 1.36-.26 2m-5.15 5.56c.6-1.11 1.06-2.31 1.38-3.56h2.95a8.03 8.03 0 0 1-4.33 3.56M14.34 14H9.66c-.1-.66-.16-1.32-.16-2c0-.68.06-1.35.16-2h4.68c.09.65.16 1.32.16 2c0 .68-.07 1.34-.16 2M12 19.96c-.83-1.2-1.5-2.53-1.91-3.96h3.82c-.41 1.43-1.08 2.76-1.91 3.96M8 8H5.08A7.923 7.923 0 0 1 9.4 4.44C8.8 5.55 8.35 6.75 8 8m-2.92 8H8c.35 1.25.8 2.45 1.4 3.56A8.008 8.008 0 0 1 5.08 16m-.82-2C4.1 13.36 4 12.69 4 12s.1-1.36.26-2h3.38c-.08.66-.14 1.32-.14 2c0 .68.06 1.34.14 2M12 4.03c.83 1.2 1.5 2.54 1.91 3.97h-3.82c.41-1.43 1.08-2.77 1.91-3.97M18.92 8h-2.95a15.65 15.65 0 0 0-1.38-3.56c1.84.63 3.37 1.90 4.33 3.56M12 2C6.47 2 2 6.5 2 12a10 10 0 0 0 10 10a10 10 0 0 0 10-10A10 10 0 0 0 12 2Z"/>]] ..
        svgEnd

    local partedSvg    = [[<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32">]] ..
        [[<path fill="]] ..
        svgFillColor ..
        [[" d="M13 30a11 11 0 0 1 0-22a1 1 0 0 1 1 1v9h9a1 1 0 0 1 1 1a11 11 0 0 1-11 11Zm-1-19.94A9 9 0 1 0 21.94 20H14a2 2 0 0 1-2-2Z"/><path fill="]] ..
        svgFillColor ..
        [[" d="M28 14h-9a2 2 0 0 1-2-2V3a1 1 0 0 1 1-1a11 11 0 0 1 11 11a1 1 0 0 1-1 1Zm-9-2h7.94A9 9 0 0 0 19 4.06Z"/>]] ..
        svgEnd

    local first        = awful.tag.add("1", {
        screen    = s,
        icon_only = true,
        icon      = terminalSvg,
        layout    = awful.layout.layouts[1],
    })

    awful.tag.add("2", {
        screen    = s,
        icon_only = true,
        icon      = globeSvg,
        layout    = awful.layout.layouts[1],
    })

    awful.tag.add("3", {
        screen    = s,
        icon_only = true,
        icon      = partedSvg,
        layout    = awful.layout.layouts[1],
    })

    awful.tag({ "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    first:view_only()

    -- Set default gaps for this screen
    s.padding = {
        left   = gaps_outer,
        right  = gaps_outer,
        top    = gaps_outer,
        bottom = gaps_outer,
    }

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox {
        screen  = s,
        buttons = {
            awful.button({}, 1, function() awful.layout.inc(1) end),
            awful.button({}, 3, function() awful.layout.inc(-1) end),
            awful.button({}, 4, function() awful.layout.inc(-1) end),
            awful.button({}, 5, function() awful.layout.inc(1) end),
        }
    }

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = {
            awful.button({}, 1, function(t) t:view_only() end),
            awful.button({ modkey }, 1, function(t)
                if client.focus then
                    client.focus:move_to_tag(t)
                end
            end),
            awful.button({}, 3, awful.tag.viewtoggle),
            awful.button({ modkey }, 3, function(t)
                if client.focus then
                    client.focus:toggle_tag(t)
                end
            end),
            awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end),
        }
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = {
            awful.button({}, 1, function(c)
                c:activate { context = "tasklist", action = "toggle_minimization" }
            end),
            awful.button({}, 3, function() awful.menu.client_list { theme = { width = 250 } } end),
            awful.button({}, 4, function() awful.client.focus.byidx(-1) end),
            awful.button({}, 5, function() awful.client.focus.byidx(1) end),
        }
    }

    -- Create the wibox
    s.mywibox = awful.wibar {
        position = "bottom",
        screen   = s,
        widget   = {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                mylauncher,
                s.mytaglist,
                s.mypromptbox,
            },
            s.mytasklist, -- Middle widget
            {             -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                mykeyboardlayout,
                wibox.widget.systray(),
                mytextclock,
                s.mylayoutbox,
            },
        }
    }
end)

-- }}}

-- {{{ Mouse bindings
awful.mouse.append_global_mousebindings({
    awful.button({}, 3, function() mymainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewprev),
    awful.button({}, 5, awful.tag.viewnext),
})
-- }}}

-- {{{ Key bindings

-- General Awesome keys
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, }, "s", hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }),
    awful.key({ modkey, }, "w", function() mymainmenu:show() end,
        { description = "show main menu", group = "awesome" }),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        { description = "reload awesome", group = "awesome" }),
    awful.key({ modkey, "Shift" }, "q", awesome.quit,
        { description = "quit awesome", group = "awesome" }),
    awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end,
        { description = "open a terminal", group = "launcher" }),
    awful.key({ modkey, "Shift" }, "Return", function() awful.spawn(nix.terminalSTR) end,
        { description = "open a terminal without tmux", group = "launcher" }),
    awful.key({ modkey, }, "d", function() awful.spawn(nix.bemenu) end,
        { description = "open bemenu application launcher", group = "launcher" }),
    awful.key({ modkey }, "r", function() awful.screen.focused().mypromptbox:run() end,
        { description = "run prompt", group = "launcher" }),
    awful.key({ modkey }, "p", function() menubar.show() end,
        { description = "show the menubar", group = "launcher" }),
})
if nix.isX11 then
    awful.keyboard.append_global_keybindings({
        awful.key({ modkey }, "x",
            function()
                awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                }
            end,
            { description = "lua execute prompt", group = "awesome" }),
    })
end

-- Tags related keybindings (i3-style with arrow keys and vim keys)
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, }, "Left", awful.tag.viewprev,
        { description = "view previous", group = "tag" }),
    awful.key({ modkey, }, "Right", awful.tag.viewnext,
        { description = "view next", group = "tag" }),
    awful.key({ modkey, }, "h", awful.tag.viewprev,
        { description = "view previous (vim)", group = "tag" }),
    awful.key({ modkey, }, "l", awful.tag.viewnext,
        { description = "view next (vim)", group = "tag" }),
    awful.key({ modkey, }, "Escape", awful.tag.history.restore,
        { description = "go back", group = "tag" }),
    awful.key({ modkey, }, "b", function()
        local s = awful.screen.focused()
        local ws = s.selected_tag.index
        local target = ws > 1 and (ws - 1) or #s.tags
        awful.tag.viewonly(s.tags[target])
    end,
        { description = "workspace back and forth", group = "tag" }),
    awful.key({ modkey, "Shift" }, "b", function()
        if client.focus then
            local s = awful.screen.focused()
            local ws = s.selected_tag.index
            local target = ws > 1 and (ws - 1) or #s.tags
            client.focus:move_to_tag(s.tags[target])
            awful.tag.viewonly(s.tags[target])
        end
    end,
        { description = "move to workspace back and forth", group = "tag" }),
})

-- Focus related keybindings (i3-style with vim keys)
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, }, "j",
        function()
            awful.client.focus.byidx(1)
        end,
        { description = "focus next by index", group = "client" }
    ),
    awful.key({ modkey, }, "k",
        function()
            awful.client.focus.byidx(-1)
        end,
        { description = "focus previous by index", group = "client" }
    ),
    awful.key({ modkey, }, down,
        function()
            awful.client.focus.byidx(1)
        end,
        { description = "focus next by index (vim)", group = "client" }
    ),
    awful.key({ modkey, }, up,
        function()
            awful.client.focus.byidx(-1)
        end,
        { description = "focus previous by index (vim)", group = "client" }
    ),
    awful.key({ modkey, }, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "go back", group = "client" }),
    awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
        { description = "focus the next screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
        { description = "focus the previous screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "n",
        function()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                c:activate { raise = true, context = "key.unminimize" }
            end
        end,
        { description = "restore minimized", group = "client" }),
    -- i3-style focus with vim keys
    awful.key({ modkey, }, left, function() awful.client.focus.bydirection("left") end,
        { description = "focus left", group = "client" }),
    awful.key({ modkey, }, right, function() awful.client.focus.bydirection("right") end,
        { description = "focus right", group = "client" }),
    -- Focus parent/child
    awful.key({ modkey }, "a", function(c)
        local c = client.focus
        if c and c.valid then
            local parent = c:get_xproperty("wm-windows")
            if parent then
                awful.client.focus.bywindow(parent)
            end
        end
    end,
        { description = "focus parent", group = "client" }),
    awful.key({ modkey }, "c", function()
        awful.client.focus.bydirection("down")
    end,
        { description = "focus child", group = "client" }),
})

-- Layout related keybindings (i3-style with vim keys)
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
        { description = "swap with next client by index", group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
        { description = "swap with previous client by index", group = "client" }),
    awful.key({ modkey, "Shift" }, down, function() awful.client.swap.byidx(1) end,
        { description = "swap with next client by index (vim)", group = "client" }),
    awful.key({ modkey, "Shift" }, up, function() awful.client.swap.byidx(-1) end,
        { description = "swap with previous client by index (vim)", group = "client" }),
    -- i3-style swap with vim keys
    awful.key({ modkey, "Shift" }, left, function() awful.client.swap.bydirection("left") end,
        { description = "swap with left client", group = "client" }),
    awful.key({ modkey, "Shift" }, right, function() awful.client.swap.bydirection("right") end,
        { description = "swap with right client", group = "client" }),
    awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }),
    awful.key({ modkey, }, "l", function() awful.tag.incmwfact(0.05) end,
        { description = "increase master width factor", group = "layout" }),
    awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end,
        { description = "decrease master width factor", group = "layout" }),
    awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
        { description = "increase the number of master clients", group = "layout" }),
    awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
        { description = "decrease the number of master clients", group = "layout" }),
    awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
        { description = "increase the number of columns", group = "layout" }),
    awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
        { description = "decrease the number of columns", group = "layout" }),
    awful.key({ modkey, }, "space", function() awful.layout.inc(1) end,
        { description = "select next", group = "layout" }),
    awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
        { description = "select previous", group = "layout" }),
    -- i3-style split commands
    awful.key({ modkey, }, "g", function()
        awful.tag.incmwfact(0)
        local t = awful.screen.focused().selected_tag
        if t then
            local c = client.focus
            if c then
                awful.layout.split_screen(awful.screen.focused())
            end
        end
        awful.util.spawn("notify-send 'tile horizontally'")
    end,
        { description = "split horizontal", group = "layout" }),
    awful.key({ modkey, }, "v", function()
        awful.tag.incmwfact(0)
        local t = awful.screen.focused().selected_tag
        if t then
            local c = client.focus
            if c then
                awful.layout.split_screen(awful.screen.focused())
            end
        end
        awful.util.spawn("notify-send 'tile vertically'")
    end,
        { description = "split vertical", group = "layout" }),
    awful.key({ modkey, }, "q", function()
        local t = awful.screen.focused().selected_tag
        if t then
            local cur_layout = t.layout
            local layouts = t.layouts or awful.layout.layouts
            for i, layout in ipairs(layouts) do
                if layout == cur_layout then
                    t.layout = layouts[i % #layouts + 1]
                    break
                end
            end
        end
    end,
        { description = "toggle split layout", group = "layout" }),
})

-- Workspace navigation (i3-style)
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, "Control", }, "Right", function()
        local s = awful.screen.focused()
        local ws = s.selected_tag.index
        local next = (ws % #s.tags) + 1
        awful.tag.viewonly(s.tags[next])
    end,
        { description = "workspace next", group = "tag" }),
    awful.key({ modkey, "Control", }, "Left", function()
        local s = awful.screen.focused()
        local ws = s.selected_tag.index
        local prev = ws > 1 and (ws - 1) or #s.tags
        awful.tag.viewonly(s.tags[prev])
    end,
        { description = "workspace prev", group = "tag" }),
})

awful.keyboard.append_global_keybindings({
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numrow",
        description = "only view tag",
        group       = "tag",
        on_press    = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control" },
        keygroup    = "numrow",
        description = "toggle tag",
        group       = "tag",
        on_press    = function(index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Shift" },
        keygroup    = "numrow",
        description = "move focused client to tag",
        group       = "tag",
        on_press    = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control", "Shift" },
        keygroup    = "numrow",
        description = "toggle focused client on tag",
        group       = "tag",
        on_press    = function(index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numpad",
        description = "select layout directly",
        group       = "layout",
        on_press    = function(index)
            local t = awful.screen.focused().selected_tag
            if t then
                t.layout = t.layouts[index] or t.layout
            end
        end,
    }
})

-- Scratchpad (i3-style)
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, "Shift" }, "x", function()
        local c = client.focus
        if c then
            c:move_to_tag(awful.tag.add("scratchpad", {
                screen = awful.screen.focused(),
                hide = true,
                floating = true,
            }))
        end
    end,
        { description = "move to scratchpad", group = "client" }),
    awful.key({ modkey, }, "x", function()
        local s = awful.screen.focused()
        local scratchpad = nil
        for _, tag in ipairs(s.tags) do
            if tag.name == "scratchpad" then
                scratchpad = tag
                break
            end
        end
        if scratchpad then
            local scratch_clients = scratchpad:clients()
            if #scratch_clients > 0 then
                scratch_clients[1]:toggle_tag(scratchpad)
            end
        end
    end,
        { description = "show scratchpad", group = "client" }),
})

-- Resize mode (i3-style)
local resize_mode = false
local resize_keys = {
    awful.key({ modkey }, "r", function()
        resize_mode = not resize_mode
        if resize_mode then
            naughty.notification {
                title = "Resize Mode",
                text = "Use h/j/k/l or arrow keys to resize. Enter/Escape to exit."
            }
        end
    end),
}

awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "r", function()
        resize_mode = not resize_mode
        if resize_mode then
            naughty.notification {
                title = "Resize Mode",
                text = "Use h/j/k/l or arrow keys to resize. Enter/Escape to exit.",
                timeout = 5
            }
        end
    end,
        { description = "enter resize mode", group = "layout" }),
})

-- System mode (i3-style power menu)
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, "Shift" }, "e", function()
        awful.prompt.run {
            prompt = "(q)uit, (e)xit to lockscreen, (s)uspend, (h)ibernate, (r)eboot, (Shift+s)hutdown: ",
            textbox = awful.screen.focused().mypromptbox.widget,
            exe_callback = function(cmd)
                if cmd == "e" then
                    awful.spawn.with_shell("loginctl lock-session $XDG_SESSION_ID")
                elseif cmd == "s" then
                    awful.spawn.with_shell("systemctl suspend")
                elseif cmd == "h" then
                    awful.spawn.with_shell("systemctl suspend-then-hibernate")
                elseif cmd == "r" then
                    awful.spawn.with_shell("systemctl reboot")
                elseif cmd == "q" then
                    awful.spawn.with_shell("loginctl terminate-session $XDG_SESSION_ID")
                elseif cmd == "S" or cmd == "shift+s" then
                    awful.spawn.with_shell("systemctl poweroff")
                end
            end,
            history_path = awful.util.get_cache_dir() .. "/history_system"
        }
    end,
        { description = "system mode", group = "awesome" }),
})

-- Gaps mode (i3-style)
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, "Shift" }, "g", function()
        awful.prompt.run {
            prompt = "Gaps: (o) outer, (i) inner, (+/-) change, (0) reset: ",
            textbox = awful.screen.focused().mypromptbox.widget,
            exe_callback = function(cmd)
                if cmd == "o" then
                    awful.prompt.run {
                        prompt = "Outer gaps: (+/-) change: ",
                        textbox = awful.screen.focused().mypromptbox.widget,
                        exe_callback = function(delta)
                            if delta == "+" then inc_gaps_outer(5)
                            elseif delta == "-" then inc_gaps_outer(-5)
                            end
                        end
                    }
                elseif cmd == "i" then
                    awful.prompt.run {
                        prompt = "Inner gaps: (+/-) change: ",
                        textbox = awful.screen.focused().mypromptbox.widget,
                        exe_callback = function(delta)
                            if delta == "+" then inc_gaps_inner(5)
                            elseif delta == "-" then inc_gaps_inner(-5)
                            end
                        end
                    }
                elseif cmd == "+" then
                    inc_gaps_inner(5)
                    inc_gaps_outer(5)
                elseif cmd == "-" then
                    inc_gaps_inner(-5)
                    inc_gaps_outer(-5)
                elseif cmd == "0" then
                    gaps_inner = 0
                    gaps_outer = 0
                    update_gaps()
                end
            end
        }
    end,
        { description = "gaps mode", group = "layout" }),
})

client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({}, 1, function(c)
            c:activate { context = "mouse_click" }
        end),
        awful.button({ modkey }, 1, function(c)
            c:activate { context = "mouse_click", action = "mouse_move" }
        end),
        awful.button({ modkey }, 3, function(c)
            c:activate { context = "mouse_click", action = "mouse_resize" }
        end),
    })
end)

client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key({ modkey, }, "f",
            function(c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            { description = "toggle fullscreen", group = "client" }),
        awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end,
            { description = "close", group = "client" }),
        awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
            { description = "toggle floating", group = "client" }),
        awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
            { description = "move to master", group = "client" }),
        awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
            { description = "move to screen", group = "client" }),
        awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
            { description = "toggle keep on top", group = "client" }),
        awful.key({ modkey, }, "n",
            function(c)
                c.minimized = true
            end,
            { description = "minimize", group = "client" }),
        awful.key({ modkey, }, "m",
            function(c)
                c.maximized = not c.maximized
                c:raise()
            end,
            { description = "(un)maximize", group = "client" }),
        awful.key({ modkey, "Control" }, "m",
            function(c)
                c.maximized_vertical = not c.maximized_vertical
                c:raise()
            end,
            { description = "(un)maximize vertically", group = "client" }),
        awful.key({ modkey, "Shift" }, "m",
            function(c)
                c.maximized_horizontal = not c.maximized_horizontal
                c:raise()
            end,
            { description = "(un)maximize horizontally", group = "client" }),
        -- i3-style sticky toggle
        awful.key({ modkey, "Shift" }, "s",
            function(c)
                c.sticky = not c.sticky
            end,
            { description = "toggle sticky", group = "client" }),
    })
end)

-- }}}

-- {{{ Rules
-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
    -- All clients will match this rule.
    ruled.client.append_rule {
        id         = "global",
        rule       = {},
        properties = {
            focus     = awful.client.focus.filter,
            raise     = true,
            screen    = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
            border_width = default_border_width,
        }
    }

    -- Floating clients.
    ruled.client.append_rule {
        id         = "floating",
        rule_any   = {
            instance = { "copyq", "pinentry" },
            class    = {
                "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
                "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer",
                "Pavucontrol", "Blueman-manager"
            },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name     = {
                "Event Tester", -- xev.
            },
            role     = {
                "AlarmWindow",   -- Thunderbird's calendar.
                "ConfigManager", -- Thunderbird's about:config.
                "pop-up",        -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = {
            floating = true,
            border_width = default_floating_border_width,
        }
    }

    -- Add titlebars to normal clients and dialogs
    ruled.client.append_rule {
        id         = "titlebars",
        rule_any   = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = true }
    }

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- ruled.client.append_rule {
    --     rule       = { class = "Firefox"     },
    --     properties = { screen = 1, tag = "2" }
    -- }
end)
-- }}}

-- {{{ Titlebars
-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = {
        awful.button({}, 1, function()
            c:activate { context = "titlebar", action = "mouse_move" }
        end),
        awful.button({}, 3, function()
            c:activate { context = "titlebar", action = "mouse_resize" }
        end),
    }

    awful.titlebar(c).widget = {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        {     -- Middle
            { -- Title
                halign = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)
-- }}}

-- {{{ Notifications

ruled.notification.connect_signal('request::rules', function()
    -- All notifications will match this rule.
    ruled.notification.append_rule {
        rule       = {},
        properties = {
            screen           = awful.screen.preferred,
            implicit_timeout = 5,
        }
    }
end)

naughty.connect_signal("request::display", function(n)
    naughty.layout.box { notification = n }
end)

-- }}}

-- {{{ Signal to update gaps when clients are added/removed
tag.connect_signal("property::layout", function(t)
    update_gaps()
end)

screen.connect_signal("arrange", function(s)
    local layout = s.selected_tag and s.selected_tag.layout or awful.layout.layouts[1]
    -- Apply border styling based on client count
    local clients = s.clients
    local only_one = #clients == 1
    for _, c in ipairs(clients) do
        if smart_borders == "on" or (smart_borders == "no_gaps" and only_one) then
            c.border_width = 0
        else
            c.border_width = c.floating and default_floating_border_width or default_border_width
        end
    end
end)

-- }}}

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:activate { context = "mouse_enter", raise = false }
end)

-- {{{ Xresources support (i3-style)
awful.spawn.with_line_callback("xrdb -query", {
    stdout = function(line)
        local key, value = line:match("^([^:]+):[%s]*(.*)")
        if key and value then
            if key:match("%.color0$") then
                beautiful.color0 = value
            elseif key:match("%.color1$") then
                beautiful.color1 = value
            elseif key:match("%.color2$") then
                beautiful.color2 = value
            elseif key:match("%.background$") then
                beautiful.bg_normal = value
            elseif key:match("%.foreground$") then
                beautiful.fg_normal = value
            end
        end
    end
})
-- }}}
