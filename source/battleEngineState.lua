local battleEngine = {}
local fadeOpacity = 1

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function battleEngine.checkEnemiesStates()
    if battle.state ~= "end" then
        local noneAreAlive = true
        for _, enemy in ipairs(encounter.enemies) do
            if enemy.status == "alive" then
                noneAreAlive = false
            end
        end
        if noneAreAlive then
            battleEngine.changeBattleState('end', 'player')
        end
    end
end

function battleEngine.changeBattleState(state, turn)
    input.refresh()
    if turn == 'player' then
        if state == 'buttons' then
            if battle.state == 'go to menu' then
                battle.choice = player.lastButton or 0
                battle.subchoice = 0
            end
            local encounterText
            if type(encounter.text) == 'string' then
                encounterText = encounter.text
            else
                encounterText = encounter.text[love.math.random(1, #encounter.text)]
            end
            writer:setParams(encounterText, 52, 274, fonts.main, 0.02, writer.voices.menuText, true)
        elseif state == 'fight' then
            battle.choice = -1
        elseif state == 'use item' then
            player.lastButton = battle.choice
            battle.choice = -1
            local selectedItem = player.inventory[battle.subchoice+1]
            itemManager.useItem(battle.subchoice+1)
            local verb
            if itemManager.getPropertyFromID(selectedItem, 'type') == 'consumable' then
                sfx.playerheal:play()
                verb = 'ate'
                if player.stats.hp >= player.stats.maxHp then
                    writer:setParams("* You " .. verb .. " the " .. itemManager.getPropertyFromID(selectedItem, 'name') .. '.     \n* Your HP maxed out!', 52, 274, fonts.main, 0.02, writer.voices.menuText)
                else
                    writer:setParams("* You " .. verb .. " the " .. itemManager.getPropertyFromID(selectedItem, 'name') .. '.     \n* You recovered ' .. itemManager.getPropertyFromID(selectedItem, 'stat') .. ' HP.', 52, 274, fonts.main, 0.02, writer.voices.menuText)
                end
            else
                sfx.menuselect:play()
                verb = 'equipped'
                writer:setParams("* You " .. verb .. " the " .. itemManager.getPropertyFromID(selectedItem, 'name') .. '.', 52, 274, fonts.main, 0.02, writer.voices.menuText)
            end
        elseif state == 'perform act' then
            encounter.doAct()
        elseif state == "flee" then
            battle.choice = -1
            local fleeingLines = {
                "  * I'm outta here.",
                "  * I've got better to do.",
                "  * Escaped...",
                "  * Don't slow me down."
            }
            writer:setParams(fleeingLines[love.math.random(1, #fleeingLines)], 68, 306, fonts.main, 0.02, writer.voices.menuText)
            sfx.flee:play()
        elseif state == "end" then
            battle.choice = -1
            ui.removeTweens()
            writer:setParams("* YOU WON!     \n* What you've won has not been\n  decided yet.", 52, 274, fonts.main, 0.02, writer.voices.menuText)
        end
    elseif turn == 'enemies' then
        if state == 'dialogue' then
            if encounter.encounterType == "random" then
                battle.turnCount = love.math.random(1, #encounter.attacks)
            else
                battle.turnCount = battle.turnCount + 1
            end
            ui.doDialogueStuff()
            ui.goToAttack()
            player.heart.x = encounter.attacks[battle.turnCount].boxDims.x + (encounter.attacks[battle.turnCount].boxDims.width / 2) - 8
            player.heart.y = encounter.attacks[battle.turnCount].boxDims.y + (encounter.attacks[battle.turnCount].boxDims.height / 2) - 8
        end
        if state == 'attack' then
            writer:stop()
            encounter.attacks[battle.turnCount].init()
            player.heart.x = encounter.attacks[battle.turnCount].boxDims.x + (encounter.attacks[battle.turnCount].boxDims.width / 2) - 8
            player.heart.y = encounter.attacks[battle.turnCount].boxDims.y + (encounter.attacks[battle.turnCount].boxDims.height / 2) - 8
        end
    else
        error('Turn type ' .. turn .. ' not valid, can only either be player or enemies')
    end

    battle.turn = turn
    battle.state = state
end

function battleEngine.load(encounterName)
    fadeOpacity = 1

    -- Set up basic battle variables
    battle = {
        turn = 'player',
        state = 'buttons',
        choice = 0,
        subchoice = 0,
        turnCount = 1
    }

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

    -- Import objects
    player = require 'source.battleEngine.player'
    ui = require 'source.battleEngine.ui'
    writer = require 'source.utils.writer'
    -- Set writer volume to player configuration
    for _, sound in pairs(writer.voices) do
        sound:setVolume(conf.textVolume)
    end
    encounter = require 'source.utils.battleEngine.encounterHandler'
    itemManager = require 'source.utils.battleEngine.itemManager'

    local originalEncounterData = require("encounters/" .. encounterName)
    local freshData = deepcopy(originalEncounterData)

    encounter.loadEncounter(freshData)


    -- Placements are mostly accurate to undertale, but buttons are slightly changed to be actually centered
    ui.load()
    ui.newButton('fight', 27, 432, 0, 'choose enemy')
    ui.newButton('act', 185, 432, 1, 'choose enemy')
    ui.newButton('item', 343, 432, 2)
    ui.newButton('mercy', 501, 432, 3)
    
    player.load()

    -- Go to menu or enemy turn
    if encounter.startFirst then
        player.lastButton = 0
        battleEngine.changeBattleState('dialogue', 'enemies')
        battle.choice = -1
    else
        battleEngine.changeBattleState('buttons', 'player')
    end
end

function battleEngine.update(dt)
    if fadeOpacity > 0 then
        fadeOpacity = fadeOpacity - 0.125 * dt*30
    end
    -- Stop fight when all enemies are either spared or killed
    battleEngine.checkEnemiesStates()

    encounter.update(dt)
    if battle.state == "attack" and battle.turn == "enemies" then
        encounter.attacks[battle.turnCount].update(dt)
    end
    ui.update(dt)
    player.update(dt)
    writer:update(dt)

    -- Game over
    if player.stats.hp < 1 then
        if player.hasKR then
        if (player.stats.hp + player.stats.kr > player.stats.hp) then
            player.stats.hp = 1
        else
            currentScene = scenes.gameover
            love.load()
        end
        elseif not player.hasKR then
            currentScene = scenes.gameover
            love.load()
        end
    end
end

function battleEngine.draw()
    encounter.background()
    encounter.draw()
    ui.drawbox('fill') -- Separate function so attacks draw over
    if battle.state == "attack" and battle.turn == "enemies" then
        encounter.attacks[battle.turnCount].draw()
    end
    ui.drawbox('line') -- Separate function so attacks draw over
    ui.draw()

    love.graphics.push("all")
    if battle.turn == "enemies" then
        love.graphics.translate(0, encounter.attacks[battle.turnCount].boxDims.y - 253)
    else
        love.graphics.translate(0, 0) 
    end
    writer:draw()
    love.graphics.pop()
    
    player.draw()

    if fadeOpacity > 0 then
        love.graphics.setColor(0, 0, 0, fadeOpacity)
        love.graphics.rectangle('fill', 0, 0, 640, 480)
    end
end

return battleEngine