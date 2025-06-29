currentScene = nil
local isPaused = false
scenes = {
    battleEngine = require 'source.battleEngineState',
    gameover = require 'source.gameOverState'
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
local inifile = require 'source.utils.inifile'

function love.keypressed(key)
    input.keypressed(key)
end

function love.keyreleased(key)
    input.keyreleased(key)
end

local function split(str, sep)  -- Helper function that loads lists from .ini files as arrays
    local result = {}
    for token in string.gmatch(str, "([^"..sep.."]+)") do
        table.insert(result, token)
    end
    return result
end

currentScene = scenes.battleEngine
function love.load()
    love.audio.stop()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    canvas = love.graphics.newCanvas(virtualWidth, virtualHeight)

    -- Set up settings from .ini file
    local config            = inifile.parse("config.ini")
    conf.fps                = config.graphics.fps
    conf.fullscreen         = config.graphics.fullscreen
    conf.useBorders         = config.graphics.useBorders
    conf.spareColor         = split(config.player.spareColor, ",")
    conf.keys.up            = split(config.player.up, ",")
    conf.keys.down          = split(config.player.down, ",")
    conf.keys.left          = split(config.player.left, ",")
    conf.keys.right         = split(config.player.right, ",")
    conf.keys.confirm       = split(config.player.confirm, ",")
    conf.keys.cancel        = split(config.player.cancel, ",")
    conf.keys.menu          = split(config.player.menu, ",")
    conf.keys.fullscreen    = split(config.player.fullscreen, ",")
    conf.keys.pause         = split(config.player.pause, ",")
    conf.bgmVolume          = config.audio.bgm
    conf.sfxVolume          = config.audio.sfx
    conf.textVolume         = config.audio.txt
    conf.mainVolume         = config.audio.main
    for i = 1, #conf.spareColor do
        conf.spareColor[i] = tonumber(conf.spareColor[i])
    end
    if love.window.getFullscreen() then
        conf.fullscreen = true
    else
        conf.fullscreen = false
    end
    currentScene.load('Test enemies')
    player.hitboxLenience = config.player.hitboxLenience
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