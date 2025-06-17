-- https://tomat.dev/undertale
local currentScene = nil
local scenes = {
    battleEngine = require 'source.battleEngineState'
}

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
    
    local scale = math.min(scaleX, scaleY)
    
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

    currentScene.update(dt)
    if input.check('fullscreen', 'pressed') then
        conf.fullscreen = not conf.fullscreen
        local fullscreen = conf.fullscreen
		love.window.setFullscreen(fullscreen, "desktop")
    end

    input.refresh()
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    currentScene.draw()

    love.graphics.setCanvas()

    love.graphics.clear()
    love.graphics.draw(canvas, offsetX, offsetY, 0, scaleX, scaleY)
end