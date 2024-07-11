-- rectangle.lua
local function run_fenster()
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
end
local function callback()
    vim.notify("Done", vim.log.levels.INFO)
end
return {
    run = function ()
        require('plenary.async').run(run_fenster,callback)
    end
}
