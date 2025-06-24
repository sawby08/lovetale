function love.conf(t)
    conf = {keys = {}}

    t.window.width = 640
    t.window.height = 480
    t.window.vsync = true
    t.window.fullscreentype = "desktop"
    t.window.fullscreen = conf.fullscreen

    t.window.title = "LOVETALE"
    t.window.icon = "icon.png"
end