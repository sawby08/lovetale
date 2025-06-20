local currentScene = nil
local isPaused = false
local scenes = {
    battleEngine = require 'source.battleEngineState'
}
local borders = {
    castle = "assets/images/borders/bg_border_castle_1080.png",
    fire = "assets/images/borders/bg_border_fire_1080.png",
    line = "assets/images/borders/bg_border_line_1080.png",
    rad = "assets/images/borders/bg_border_rad_1080.png",
    ruins = "assets/images/borders/bg_border_ruins_1080.png",
    sepia = "assets/images/borders/bg_border_sepia_1080.png",
    truelab = "assets/images/borders/bg_border_truelab_1080.png",
    tundra = "assets/images/borders/bg_border_tundra_1080.png",
    water = "assets/images/borders/bg_border_water_1080.png"
}
local border = love.graphics.newImage(borders.sepia)

fps = require 'source.utils.fps'
input = require 'source.utils.input'
Camera = require 'source.utils.camera'

function love.keypressed(key)
    input.keypressed(key)
end

currentScene = scenes.battleEngine
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    canvas = love.graphics.newCanvas(virtualWidth, virtualHeight)

    currentScene.load('Test enemies')

    camera = Camera.new(640, 480)
end

function love.update(dt)
    input.update(dt)
    camera:update(dt)
    love.audio.setVolume(conf.mainVolume)

    if not isPaused then
        currentScene.update(dt)
    else
        love.audio.setVolume(conf.mainVolume/4)
    end
    if input.check('fullscreen', 'pressed') then
        conf.fullscreen = not conf.fullscreen
        local fullscreen = conf.fullscreen
		love.window.setFullscreen(fullscreen, "desktop")
    end
    if input.check('pause', 'pressed') then
        isPaused = not isPaused
    end

    input.refresh()
end

function love.draw()
    camera:attachLetterBox()
    camera:apply()

    currentScene.draw()

    camera:reset()
    camera:detachLetterBox()

    if isPaused then
        love.graphics.setColor(0, 0, 0, .5)
        love.graphics.rectangle('fill', 0, 0, 640, 480)

        love.graphics.setColor(1, 1, 0)
        love.graphics.setFont(fonts.determination)
        love.graphics.printf('PAUSED', 0, 240, 640, 'center')

        love.graphics.setColor(1, 1, 1)
    end
    if conf.fullscreen and conf.useBorders then
        windowWidth, windowHeight = love.window.getMode()
        love.graphics.draw(border, 0, 0, 0, windowWidth/1920, windowHeight/1080)
    end
end