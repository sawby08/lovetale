local battleEngine = {}

local refs = {
    main = love.graphics.newImage("refs/main.png"),
    acts = love.graphics.newImage("refs/acts.png"),
    items = love.graphics.newImage("refs/items.png"),
    choose = love.graphics.newImage("refs/choose.png")
}

function battleEngine.changeBattleState(state, turn)
    if turn == 'player' then
        if state == 'buttons' then
            if battle.state == 'attack' and battle.turn == 'enemies' then
                battle.choice = player.lastButton
                battle.subchoice = 0
            end
            local encounterText
            if type(encounter.text) == 'string' then
                encounterText = encounter.text
            else
                encounterText = encounter.text[love.math.random(1, #encounter.text)]
            end
            writer:setParams(encounterText, 52, 274, fonts.determination, 0.02, writer.voices.menuText)
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
                    writer:setParams("* You " .. verb .. " the " .. itemManager.getPropertyFromID(selectedItem, 'name') .. '.     [break]* Your HP maxed out!', 52, 274, fonts.determination, 0.02, writer.voices.menuText)
                else
                    writer:setParams("* You " .. verb .. " the " .. itemManager.getPropertyFromID(selectedItem, 'name') .. '.     [break]* You recovered ' .. itemManager.getPropertyFromID(selectedItem, 'stat') .. ' HP.', 52, 274, fonts.determination, 0.02, writer.voices.menuText)
                end
            else
                sfx.menuselect:play()
                verb = 'equipped'
                writer:setParams("* You " .. verb .. " the " .. itemManager.getPropertyFromID(selectedItem, 'name') .. '.', 52, 274, fonts.determination, 0.02, writer.voices.menuText)
            end
        elseif state == 'perform act' then
            encounter.doAct()
        end
    elseif turn == 'enemies' then
        if state == 'attack' then
            writer:stop()
        end
    else
        error('Turn type ' .. turn .. ' not valid, can only either be player or enemies')
    end

    battle.turn = turn
    battle.state = state
end

function battleEngine.load(encounterName)
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
        playerheal = love.audio.newSource('assets/sound/playerHeal.ogg', 'static')
    }
    fonts = {
        mars = love.graphics.newFont('assets/fonts/Mars_Needs_Cunnilingus.ttf', 23),
        determination = love.graphics.newFont('assets/fonts/determination-mono.ttf', 32),
        dotumche = love.graphics.newFont("assets/fonts/undertale-dotumche.ttf", 12),
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

    -- Load objects
    encounter.loadEncounter(require("encounters/" .. encounterName))

    ui.load()
    ui.newButton('fight', 27, 432, 0, 'choose enemy') -- make buttons
    ui.newButton('act', 185, 432, 1, 'choose enemy')
    ui.newButton('item', 343, 432, 2)
    ui.newButton('mercy', 501, 432, 3)
    
    player.load()

    -- Go to menu or enemy turn
    if encounter.startFirst then
        battleEngine.changeBattleState('attack', 'enemies')
    else
        battleEngine.changeBattleState('buttons', 'player')
    end
end

function battleEngine.update(dt)
    encounter.update(dt)
    encounter.bgm:play()

    ui.update(dt)
    player.update(dt)
    writer:update(dt)
end

function battleEngine.draw()
    encounter.background()

    ui.draw()
    writer:draw()

    encounter.draw() -- basically draws the enemies and the background
    player.draw()

    -- Saves the graphics state so drawing the ref and black base doesn't mess up the other stuff
    love.graphics.push("all")

    love.graphics.setColor(1, 1, 1, 0)
    love.graphics.draw(refs.choose, 0, 0)

    love.graphics.pop()
end

return battleEngine