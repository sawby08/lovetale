-- All encounter-related stuff is in the example encounter folder. Only get in here if you know what you're doing please!! this code can be ugly sometimes!!

local quitTimer = 0
local curTimer
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

input = require 'source.utils.input'
Camera = require 'source.utils.camera'
local inifile = require 'source.utils.inifile'
require('source.utils.fps')
sceneman = require 'source.utils.sceneman'
sceneman.scenePrefix = "source."

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
    conf.hitboxLenience     = config.player.hitboxLenience
    conf.keys.up            = split(config.player.up, ",")
    conf.keys.down          = split(config.player.down, ",")
    conf.keys.left          = split(config.player.left, ",")
    conf.keys.right         = split(config.player.right, ",")
    conf.keys.confirm       = split(config.player.confirm, ",")
    conf.keys.cancel        = split(config.player.cancel, ",")
    conf.keys.menu          = split(config.player.menu, ",")
    conf.keys.fullscreen    = split(config.player.fullscreen, ",")
    conf.keys.quit          = split(config.player.quit, ",")
    conf.bgmVolume          = config.audio.bgm
    conf.sfxVolume          = config.audio.sfx
    conf.textVolume         = config.audio.txt
    conf.mainVolume         = config.audio.main
    conf.modName            = config.game.modName
    for i = 1, #conf.spareColor do
        conf.spareColor[i] = tonumber(conf.spareColor[i])
    end
    if love.window.getFullscreen() then
        conf.fullscreen = true
    else
        conf.fullscreen = false
    end

    -- Import assets
    sfx = {
        menumove = love.audio.newSource('assets/sound/menuMove.ogg', 'static'),
        menuselect = love.audio.newSource('assets/sound/menuSelect.ogg', 'static'),
        playerheal = love.audio.newSource('assets/sound/playerHeal.ogg', 'static'),
        flee = love.audio.newSource("assets/sound/runaway.wav", "static"),
        dust = love.audio.newSource("assets/sound/enemydust.wav", "static"),
        slice = love.audio.newSource("assets/sound/slice.wav", "static"),
        hit = love.audio.newSource("assets/sound/hitsound.wav", "static"),
        hurt = love.audio.newSource("assets/sound/hurtsound.wav", "static")
    }
    fonts = {
        ui = love.graphics.newFont('assets/fonts/Mars_Needs_Cunnilingus.ttf', 23),
        main = love.graphics.newFont('assets/fonts/determination-mono.ttf', 32),
        dialog = love.graphics.newFont("assets/fonts/undertale-dotumche.ttf", 12),
        attack = love.graphics.newFont("assets/fonts/hachicro.ttf", 32),

        dialogue = love.graphics.newFont("assets/fonts/dotumche.ttf", 12),
        sans = love.graphics.newFont("assets/fonts/comic-sans-ut.ttf", 14),
        papyrus = love.graphics.newFont("assets/fonts/papyrus-pixel-mono.ttf", 16)
    }

    -- Set all sounds to player configuration
    for _, sound in pairs(sfx) do
        sound:setVolume(conf.sfxVolume)
    end

    sceneman.switchScene('battleEngineState', conf.modName)
    camera = Camera.new(640, 480)
end

function love.update(dt)
    input.update(dt)
    camera:update(dt)
    love.audio.setVolume(conf.mainVolume)

    sceneman.update(dt)
    if input.check('fullscreen', 'pressed') then
        conf.fullscreen = not conf.fullscreen
        local fullscreen = conf.fullscreen
		love.window.setFullscreen(fullscreen, "desktop")
    end

    if input.check('quit', 'pressed') then
        curTimer = love.timer.getTime()
    end
    if input.check('quit', 'held') then
        quitTimer = (love.timer.getTime() - curTimer) / 2
    else
        quitTimer = 0
    end

    input.refresh()
end

function love.draw()
    camera:attachLetterBox()
    camera:apply()

    sceneman.draw()

    if quitTimer > 0 then
        love.graphics.setColor(1, 1, 1, quitTimer*1.33)
        if quitTimer < 1/3 then
            love.graphics.print("QUITTING.")
        elseif quitTimer < 2/3 then
            love.graphics.print("QUITTING..")
        elseif quitTimer < 3/3 then
            love.graphics.print("QUITTING...")
        elseif quitTimer < 4/3 then
            local farewells = {
                "Goodbye!",
                "See you later!",
                "Auf wiedersehen!",
                "Ciao!"
            }
            local farewell = farewells[love.math.random(1, #farewells)]
            love.graphics.print(farewell)
            love.event.quit()
        end
    end

    camera:reset()
    camera:detachLetterBox()

    if conf.fullscreen and conf.useBorders then
        windowWidth, windowHeight = love.window.getMode()
        love.graphics.draw(border, 0, 0, 0, windowWidth/1920, windowHeight/1080)
    end
end

sceneman.enableCallbackHook()