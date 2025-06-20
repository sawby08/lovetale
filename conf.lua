function love.conf(t)
    -- A menu for this will be made eventually
    conf = {
        keys = {
            up = {'up', 'w'},
            down = {'down', 's'},
            left = {'left', 'a'},
            right = {'right', 'd'},
            confirm = {'z', 'return'},
            cancel = {'x', 'lshift', 'rshift'},
            menu = {'c', 'lctrl', 'rctrl'},
            fullscreen = {'f4'},
            pause = {'escape'}
        },
        fps = 60,
        fullscreen = false,
        gameScale = 1,
        useBorders = true,
        spareColor = {1, 1, 0}, -- {1, 1, 0} is yellow and {1, 187 / 255, 212 / 255} is pink
        
        bgmVolume = 0.5,
        sfxVolume = 1,
        textVolume = 1,
        mainVolume = 0.5
    }

    t.window.width = 640 * conf.gameScale
    t.window.height = 480 * conf.gameScale
    t.window.vsync = true
    t.window.fullscreentype = "desktop"
    t.window.resizable = false
    t.window.fullscreen = conf.fullscreen

    t.window.title = "LOVETALE"
    t.window.icon = "icon.png"
end