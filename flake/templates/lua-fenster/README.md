# lua-fenster

> The most minimal cross-platform GUI library - now in Lua!

[![LuaRocks](https://img.shields.io/luarocks/v/jonasgeiler/fenster?style=for-the-badge&color=%232c3e67)](https://luarocks.org/modules/jonasgeiler/fenster)
[![Downloads](https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Fluarocks.org%2Fmodules%2Fjonasgeiler%2Ffenster&query=%2F%2Fdiv%5B%40class%3D%22metadata_columns_inner%22%5D%2Fdiv%5B%40class%3D%22column%22%5D%5Blast()%5D%2Ftext()&style=for-the-badge&label=Downloads&color=099dff&cacheSeconds=86400)](https://luarocks.org/modules/jonasgeiler/fenster)
[![Projects using lua-fenster](https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Fgithub.com%2Fjonasgeiler%2Flua-fenster%3Ftab%3Dreadme-ov-file&query=count%28%2F%2Farticle%5Bcontains%28concat%28'%20'%2Cnormalize-space%28%40class%29%2C'%20'%29%2C'%20entry-content%20'%29%5D%2Ful%5Blast%28%29%5D%2Fli%29&suffix=%2B&style=for-the-badge&label=Projects%20using%20lua-fenster&color=2c3e67&cacheSeconds=86400)](#projects-using-lua-fenster)
[![License](https://img.shields.io/github/license/jonasgeiler/lua-fenster?style=for-the-badge&color=%23099dff)](./LICENSE.md)

A Lua binding for the [fenster](https://github.com/zserge/fenster) GUI library,
providing the most minimal and highly opinionated way to display a
cross-platform 2D canvas. It's basic idea is giving you the simplest means
possible to "just put pixels on the screen" without any of the fancy stuff. As a
nice bonus you also get cross-platform keyboard/mouse input and frame timing in
only a few lines of code.

Read more about the idea behind fenster here:
[Minimal cross-platform graphics - zserge.com](https://zserge.com/posts/fenster/)

> [!NOTE]
> This library is primarily intended for educational and prototyping purposes
> and may not include all the features you would expect from a proper GUI
> library. If you're looking for something more feature-rich and
> production-ready, you might want to check out [LÖVE](https://love2d.org/)
> or [raylib](https://www.raylib.com/).

## Installation

From LuaRocks server:

```shell
luarocks install fenster
```

From source:

```shell
git clone https://github.com/jonasgeiler/lua-fenster.git
cd lua-fenster
luarocks make
```

## Simple Example

Here is a simple example that opens a 500x300 window, draws a red rectangle and
exits when pressing the Escape key:

```lua
-- rectangle.lua
local fenster = require('fenster')

local window = fenster.open(500, 300, 'Hello fenster!')

while window:loop() and not window.keys[27] do
	window:clear()

	for y = 100, 200 do
		for x = 200, 300 do
			window:set(x, y, 0xff0000)
		end
	end
end
```

To run the example:

```shell
lua rectangle.lua
```

Here is what you should see:

![rectangle screenshot](https://github.com/jonasgeiler/lua-fenster/assets/10259118/7c9e495e-409b-4b3b-b232-c20da1ebfc88)

## Demos

Check out the [./demos](./demos) folder for more elaborate example applications!  
To run a demo use:

```shell
lua demos/<demo>.lua
```

Some of the demos are user-contributed. If you have a demo you'd like to share,
feel free to create a pull request!

## Useful Snippets

I have compiled a collection of useful snippets in
[this discussion (#11)](https://github.com/jonasgeiler/lua-fenster/discussions/11).  
Check them out and maybe add your own!

## Type Definitions

I have created type definitions for lua-fenster for the
[Teal Programming Language](https://github.com/teal-language/tl) and
[Sumneko's Lua Language Server](https://github.com/LuaLS/lua-language-server).
You can find the Teal type definitions in the
[teal-language/teal-types](https://github.com/teal-language/teal-types/tree/master/types/fenster)
repository and the Lua Language Server type definitions in the
[LuaLS/LLS-Addons](https://github.com/LuaLS/LLS-Addons/tree/main/addons/fenster)
repository.
Consult their respective documentation on how to use these type definitions in
your projects.

## API Documentation

Here is a documentation of all functions, methods and properties provided by the
fenster Lua module:

- [`fenster.open(width: integer, height: integer, title: string | nil, scale: integer | nil, targetfps: number | nil): userdata`](#fensteropenwidth-integer-height-integer-title-string--nil-scale-integer--nil-targetfps-number--nil-userdata)

- [`fenster.sleep(milliseconds: integer)`](#fenstersleepmilliseconds-integer)

- [`fenster.time(): integer`](#fenstertime-integer)

- [`fenster.rgb(redorcolor: integer, green: integer | nil, blue: integer | nil): integer, integer | nil, integer | nil`](#fensterrgbredorcolor-integer-green-integer--nil-blue-integer--nil-integer-integer--nil-integer--nil)

- [`window:close()`](#windowclose)

- [`window:loop()`](#windowloop-boolean)

- [`window:set(x: integer, y: integer, color: integer)`](#windowsetx-integer-y-integer-color-integer)

- [`window:get(x: integer, y: integer): integer`](#windowgetx-integer-y-integer-integer)

- [`window:clear(color: integer | nil)`](#windowclearcolor-integer--nil)

- [`window.keys: boolean[]`](#windowkeys-boolean)

- [`window.delta: number`](#windowdelta-number)

- [`window.mousex: integer`](#windowmousex-integer)

- [`window.mousey: integer`](#windowmousey-integer)

- [`window.mousedown: boolean`](#windowmousedown-boolean)

- [`window.modcontrol: boolean`](#windowmodcontrol-boolean)

- [`window.modshift: boolean`](#windowmodshift-boolean)

- [`window.modalt: boolean`](#windowmodalt-boolean)

- [`window.modgui: boolean`](#windowmodgui-boolean)

- [`window.width: integer`](#windowwidth-integer)

- [`window.height: integer`](#windowheight-integer)

- [`window.title: string`](#windowtitle-string)

- [`window.scale: integer`](#windowscale-integer)

- [`window.targetfps: number`](#windowtargetfps-number)

### `fenster.open(width: integer, height: integer, title: string | nil, scale: integer | nil, targetfps: number | nil): userdata`

This function is used to create a new window for your application.

**Parameters:**

- `width` (integer): The width of the window in pixels.

- `height` (integer): The height of the window in pixels.

- `title` (string, optional): The title of the window. If not provided, the
  default title 'fenster' will be used.

- `scale` (integer, optional): The scale factor for the window. This should be a
  power of 2 (e.g., 1, 2, 4, 8). If not provided, the default scale factor of 1
  will be used. This means that each pixel in your application corresponds to
  one pixel on the screen. A scale factor of 2 would mean that each pixel in
  your application corresponds to a 2x2 square of pixels on the screen, and so
  on. The scaling happens completely internally, and you won't have to worry
  about it in your code. It is just a way to make your application more visible
  on high-resolution screens without sacrificing performance.

- `targetfps` (number, optional): The target frames per second (FPS) for the
  window. If not provided, the default target FPS of 60 will be used. This is
  used to limit the CPU usage of your application and get more consistent frame
  durations by pausing for a short time after each frame to reach the target
  FPS. You can set it to 0 to disable FPS handling and let your application run
  as fast as possible, but generally, you should keep it at the default value of
  60 FPS.

**Returns:**

An userdata object representing the created window. This object can be used to
interact with the window, such as drawing pixels, handling input, and
reading the window's properties.

**Example:**

```lua
local fenster = require('fenster')

-- Create a new window with a width of 500 pixels, a height of 300 pixels, a title of 'My Application', a scale factor of 2, and a target FPS of 60.
local window = fenster.open(500, 300, 'My Application', 2, 60)
```

### `fenster.sleep(milliseconds: integer)`

This utility function is used to pause the program execution for a specified
amount of time.

**Parameters:**

- `milliseconds` (integer): The amount of time, in milliseconds, for which the
  program execution should be paused.

**Example:**

```lua
local fenster = require('fenster')

-- Pause the program execution for 2 seconds (2000 milliseconds)
fenster.sleep(2000)
```

### `fenster.time(): integer`

This utility function is used to get the current time in milliseconds since the
Unix epoch (January 1, 1970). This is similar to `os.time()`, but with
milliseconds instead of seconds.

**Returns:**

The current time in milliseconds since the Unix epoch as an integer.

**Example:**

```lua
local fenster = require('fenster')

-- Get the current time in milliseconds
local time = fenster.time()
```

### `fenster.rgb(redorcolor: integer, green: integer | nil, blue: integer | nil): integer, integer | nil, integer | nil`

This utility function is used to convert RGB values to a single color integer or
vice versa.

**Parameters:**

- `redorcolor` (integer): If only one argument is given, it is assumed to be a
  color integer and the function returns the red, green and blue components as
  separate values. If three arguments are given, this represents the red
  component of the color.

- `green` (integer, optional): The green component of the color. This is
  required if `redorcolor` is the red component.

- `blue` (integer, optional): The blue component of the color. This is required
  if `redorcolor` is the red component.

**Returns:**

- If only `redorcolor` is provided, the function returns three integers
  representing the red, green, and blue components of the color.
- If `redorcolor`, `green`, and `blue` are provided, the function returns a
  single integer representing the color.

**Example:**

```lua
local fenster = require('fenster')

-- Convert RGB values to a single color integer
local color = fenster.rgb(255, 0, 0) -- Returns: 0xff0000 (16711680 in decimal)

-- Convert a single color integer to RGB values
local red, green, blue = fenster.rgb(0xff0000) -- Returns: 255, 0, 0
```

### `window:close()`

This method is used to close a window that was previously opened
with `fenster.open`.
The `__gc` and `__close` (Lua 5.4) metamethods call this function internally to
automatically close the window when it goes out of scope, so you won't
have to call this function manually in most cases.

**Example:**

```lua
local fenster = require('fenster')

-- Open a new window
local window = fenster.open(500, 300, 'My Application', 2, 60)

-- Close the window immediately
window:close()
```

**Note:**

In Lua 5.4 you can use
[local variable attributes](https://www.lua.org/manual/5.4/manual.html#3.3.8)
to immediately close the window when the `window` variable goes out of scope:

```lua
local fenster = require('fenster')

function main()
  -- Open a new window (note the <close> attribute!)
  local window <close> = fenster.open(500, 300, 'My Application', 2, 60)

  -- The window will be immediately closed when this function returns
  -- (Normally, garbage collection will also close the window but only at an
  -- undetermined time later on)
end
```

### `window:loop(): boolean`

This method is used to handle the main loop for the window. It takes care of
FPS limiting, updates delta time, keys, mouse coordinates, modifier keys, and
the whole screen.

**Returns:**

A boolean value indicating whether the window is still open. It returns true if
the window is still open and false if it's closed.

> [!WARNING]
> Currently it looks like only Windows returns false when the window is closed.
> On Linux and macOS `fenster` just throws an error when closing the window...

**Example:**

```lua
local fenster = require('fenster')

-- Open a new window
local window = fenster.open(500, 300, 'My Application', 2, 60)

-- Handle the main loop for the window
while window:loop() do
  -- ... Your code here...
end
```

### `window:set(x: integer, y: integer, color: integer)`

This method is used to set a pixel in the window buffer at the given
coordinates to the given color.

**Parameters:**

- `x` (integer): The x-coordinate of the pixel.

- `y` (integer): The y-coordinate of the pixel.

- `color` (integer): The color to set the pixel to.

**Example:**

```lua
local fenster = require('fenster')

-- Open a new window
local window = fenster.open(500, 300, 'My Application', 2, 60)

-- Set the pixel at coordinates (10, 20) to red
window:set(10, 20, 0xff0000)
```

### `window:get(x: integer, y: integer): integer`

This method is used to get the color of a pixel in the window buffer at the
given coordinates.

**Parameters:**

- `x` (integer): The x-coordinate of the pixel.

- `y` (integer): The y-coordinate of the pixel.

**Returns:**

An integer representing the color of the pixel at the given coordinates.

**Example:**

```lua
local fenster = require('fenster')

-- Open a new window
local window = fenster.open(500, 300, 'My Application', 2, 60)

-- Set the pixel at coordinates (10, 20) to green
window:set(10, 20, 0x00ff00)

-- Get the color of the pixel at coordinates (10, 20)
local color = window:get(10, 20) -- Returns: 0x00ff00 (65280 in decimal)
```

### `window:clear(color: integer | nil)`

This method is used to clear the window buffer with a given color. This can
also be used to set a background color for the window.

**Parameters:**

- `color` (integer, optional): The color to fill the window buffer with. If not
  provided, the default color `0x000000` (black) is used.

**Example:**

```lua
local fenster = require('fenster')

-- Open a new window
local window = fenster.open(500, 300, 'My Application', 2, 60)

-- Clear the window buffer with the color blue
window:clear(0x0000ff)
```

### `window.keys: boolean[]`

This property is an array of boolean values representing the state of each key
on the keyboard. Each index in the array corresponds to a specific key, and the
value at that index is `true` if the key is currently pressed, and `false`
otherwise.
The key codes are mostly ASCII, but arrow keys are 17 to 20.

**Example:**

```lua
local fenster = require('fenster')

-- Open a new window
local window = fenster.open(500, 300, 'My Application', 2, 60)

-- Get the ASCII code for the "F" key (70)
local fkey = string.byte('F')

-- Handle the main loop for the window
while window:loop() do
  -- Check if the "F" key is pressed
  if window.keys[fkey] then
    -- Print a message
    print('F is pressed.')
  end
end
```

### `window.delta: number`

This property contains the time in seconds that has passed since the last
frame was rendered. This property is useful for creating smooth animations
and movement, as you can use it to adjust the speed of an object based on the
frame rate.

Read more about delta time here:
[Delta timing - Wikipedia](https://wikipedia.org/wiki/Delta_timing)

**Example:**

```lua
local fenster = require('fenster')

-- Try out these values and notice the difference:
local targetfps = 60
--local targetfps = 30
--local targetfps = 15

-- Open a new window (very wide and scaled to see the pixels moving)
local window = fenster.open(100, 40, 'My Application', 4, targetfps)

-- Calculate the y position of the first pixel (center minus 10)
local pixel1y = window.height / 2 - 10

-- Initialize the x position of the first pixel
local pixel1x = 0

-- Calculate the x position of the second pixel (center plus 10)
local pixel2y = window.height / 2 + 10

-- Initialize the x position of the second pixel
local pixel2x = 0

-- Handle the main loop for the window
while window:loop() do
  -- Clear the screen for redraw
  window:clear()

  -- Draw the first pixel in red (we have to floor the x position, because it has to be an integer)
  window:set(math.floor(pixel1x), pixel1y, 0xff0000)

  -- Move the first pixel to the right (no delta time)
  pixel1x = pixel1x + 0.35

  -- Reset the first pixel if it reaches the right edge of the window
  if pixel1x >= window.width then pixel1x = 0 end

  -- Draw the second pixel in green (also floor here)
  window:set(math.floor(pixel2x), pixel2y, 0x00ff00)

  -- Move the second pixel to the right (with delta time)
  pixel2x = pixel2x + 20 * window.delta

  -- Reset the second pixel if it reaches the right edge of the window
  if pixel2x >= window.width then pixel2x = 0 end
end
```

### `window.mousex: integer`

This property contains the x-coordinate of the mouse cursor relative to the
window. The coordinate system is the same as the window buffer, so you can pass
it directly to the `window:set(...)` method to draw on the screen.

**Example:**

```lua
local fenster = require('fenster')

-- Open a new window
local window = fenster.open(500, 300, 'My Application', 2, 60)

-- Handle the main loop for the window
while window:loop() do
  -- Draw a cyan pixel at the mouse position
  window:set(window.mousex, window.mousey, 0x00ffff)
end
```

### `window.mousey: integer`

This property contains the y-coordinate of the mouse cursor relative to the
window. See [`window.mousex`](#windowmousex-integer) for more information.

### `window.mousedown: boolean`

This property contains the state of the mouse button. If the mouse button is
currently pressed, the value will be `true`, otherwise it will be `false`.
Currently, all mouse buttons are treated as the same button, so you can't
distinguish between left, right, or middle mouse buttons.

**Example:**

```lua
local fenster = require('fenster')

-- Open a new window
local window = fenster.open(500, 300, 'My Application', 2, 60)

-- Handle the main loop for the window
while window:loop() do
  -- Check if the mouse is pressed
  if window.mousedown then
    -- Draw a yellow pixel at the mouse position
    window:set(window.mousex, window.mousey, 0xffff00)
  end
end
```

### `window.modcontrol: boolean`

This property contains the state of the Control key, also known as the Ctrl key.
If the Control key is currently pressed, the value will be `true`, otherwise it
will be `false`.

> [!IMPORTANT]
> In my experience, the states of the modifier keys are only updated when
> another key is pressed simultaneously, so you might not get the expected
> behavior if you only check the modifier property.

**Example:**

```lua
local fenster = require('fenster')

-- Open a new window
local window = fenster.open(500, 300, 'My Application', 2, 60)

-- Get the ASCII code for the "G" key (71)
local gkey = string.byte('G')

-- Handle the main loop for the window
while window:loop() do
  -- Check if the "G" key is pressed
  if window.keys[gkey] then
    local keycombination = {}

    -- Check which modifier key is pressed and add it to the key combination
    if window.modcontrol then
      keycombination[#keycombination + 1] = 'Ctrl'
    end
    if window.modshift then
      keycombination[#keycombination + 1] = 'Shift'
    end
    if window.modalt then
      keycombination[#keycombination + 1] = 'Alt'
    end
    if window.modgui then
      keycombination[#keycombination + 1] = 'GUI'
    end

    -- Add the "G" key to the key combination
    keycombination[#keycombination + 1] = 'G'

    -- Print the key combination that is pressed
    print(table.concat(keycombination, ' + ') .. ' is pressed.')
  end
end
```

### `window.modshift: boolean`

This property contains the state of the Shift key. See
[`window.modcontrol`](#windowmodcontrol-boolean) for more information.

### `window.modalt: boolean`

This property contains the state of the Alt key. See
[`window.modcontrol`](#windowmodcontrol-boolean) for more information.

### `window.modgui: boolean`

This property contains the state of the GUI key, also known as the Windows,
Command or Meta key. See [`window.modcontrol`](#windowmodcontrol-boolean) for
more information.

### `window.width: integer`

This property contains the width of the window. Note that the width of the
window is read-only and cannot be updated, like all other properties of the
window object.

**Example:**

```lua
local fenster = require('fenster')

-- Open a new window
local window = fenster.open(500, 300, 'My Application', 2, 60)

-- Print the width of the window
print(window.width) -- Output: 500
```

### `window.height: integer`

This property contains the height of the window. Note that the height of the
window is read-only and cannot be updated, like all other properties of the
window object.

**Example:**

```lua
local fenster = require('fenster')

-- Open a new window
local window = fenster.open(500, 300, 'My Application', 2, 60)

-- Print the height of the window
print(window.height) -- Output: 300
```

### `window.title: string`

This property contains the title of the window. Note that the title of the
window is read-only and cannot be updated, like all other properties of the
window object.

**Example:**

```lua
local fenster = require('fenster')

-- Open a new window
local window = fenster.open(500, 300, 'My Application', 2, 60)

-- Print the title of the window
print(window.title) -- Output: My Application
```

### `window.scale: integer`

This property contains the scale factor of the window. Note that the scale of
the window is read-only and cannot be updated, like all other properties of the
window object. If you are using this property for reasons other than debugging,
you are probably doing something wrong, as the scaling happens completely
internally and you won't have to worry about it in your code.

**Example:**

```lua
local fenster = require('fenster')

-- Open a new window
local window = fenster.open(500, 300, 'My Application', 2, 60)

-- Print the scale of the window
print(window.scale) -- Output: 2
```

### `window.targetfps: number`

This property contains the target frames per second (FPS) of the window. Note
that the target FPS of the window is read-only and cannot be updated, like all
other properties of the window object.

**Example:**

```lua
local fenster = require('fenster')

-- Open a new window
local window = fenster.open(500, 300, 'My Application', 2, 60)

-- Print the target FPS of the window
print(window.targetfps) -- Output: 60.0
```

## Projects using lua-fenster

Here is a list of projects that use lua-fenster:

- [3d-rasterizer-lua](https://github.com/jonasgeiler/3d-rasterizer-lua) - A simple 3D rasterizer written in Lua, by [Jonas Geiler (@jonasgeiler)](https://github.com/jonasgeiler).

<!--
If you want to add your own projects here, please format the entries as follows,
including the extra newline between each entry:

- [Name](Link) - Description, by Author.

- [Name](Link) - Description, by [Full Name (@Username)](https://github.com/Username).

- [Name](Link) - Description, by [@Username](https://github.com/Username).

-->

Feel free to add your own projects to this list by creating a pull request!

## Credits

Many thanks to [Serge Zaitsev (@zserge)](https://github.com/zserge) for creating
the original [fenster](https://github.com/zserge/fenster) library and making it
available to the public. This Lua binding wouldn't have been possible without
his work.

## License

This project is licensed under the [MIT License](./LICENSE.md). Feel free to use
it in your own proprietary or open-source projects. If you have any questions,
please open an issue or discussion!
