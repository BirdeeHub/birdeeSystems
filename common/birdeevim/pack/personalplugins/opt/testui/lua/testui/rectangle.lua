-- rectangle.lua
return {
    run = function ()
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
}
