-- https://tomat.dev/undertale
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

local virtualWidth = 640
local virtualHeight = 480

local canvas
local scaleX, scaleY
local offsetX, offsetY

function love.keypressed(key)
    input.keypressed(key)
end

local function updateScale()
    local windowWidth, windowHeight = love.graphics.getDimensions()
    
    scaleX = windowWidth / virtualWidth
    scaleY = windowHeight / virtualHeight
    
    local scale
    if conf.fullscreen and conf.useBorders then
        scale = math.min(windowWidth / virtualWidth, windowHeight / virtualHeight) * 1 * (0.89 * 1) 
    else
        scale = math.min(windowWidth / virtualWidth, windowHeight / virtualHeight) * 1
    end
        
    scaleX = scale
    scaleY = scale

    offsetX = (windowWidth - virtualWidth * scaleX) / 2
    offsetY = (windowHeight - virtualHeight * scaleY) / 2
end

currentScene = scenes.battleEngine
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    canvas = love.graphics.newCanvas(virtualWidth, virtualHeight)
    updateScale()

    currentScene.load('Test enemies')
    love.audio.setVolume(conf.mainVolume)
end

function love.resize(w, h)
    updateScale()
end

function love.update(dt)
    input.update(dt)

    if not isPaused then
        currentScene.update(dt)
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
    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    currentScene.draw()

    if isPaused then
        love.graphics.setColor(0, 0, 0, .5)
        love.graphics.rectangle('fill', 0, 0, 640, 480)

        love.graphics.setColor(1, 1, 0)
        love.graphics.setFont(fonts.determination)
        love.graphics.printf('PAUSED', 0, 240, 640, 'center')

        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.setCanvas()

    love.graphics.clear()
    love.graphics.draw(canvas, offsetX, offsetY, 0, scaleX, scaleY)

    local windowWidth, windowHeight = love.graphics.getDimensions()
    if conf.fullscreen and conf.useBorders then
        love.graphics.draw(border, 0, 0, 0, windowWidth/1920, windowHeight/1080)
    end
end