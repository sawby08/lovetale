local encounterHandler = {}
encounterHandler.enemies = {}

local Enemy = require("source.utils.battleEngine.enemyClass")
local battleEngine = require("source.battleEngineState")

local actTextI = 1

local function performAct(act)
    if type(act.execute) == "function" then
        act:execute()
    end
end

local function performActText(selection, text)
    writer:setParams(encounterHandler.enemies[player.chosenEnemy].acts[selection].text[text], 52, 274, fonts.determination, 0.02, writer.voices.menuText)
end

function encounterHandler.loadEncounter(encounterData)
    for k, v in pairs(encounterData) do
        encounterHandler[k] = v
    end

    if encounterHandler.bgmPath then
        encounterHandler.bgm = love.audio.newSource(encounterHandler.encounterPath .. encounterHandler.bgmPath, "stream")
        encounterHandler.bgm:setVolume(conf.bgmVolume)
        encounterHandler.bgm:setLooping(true)
    end

    if encounterHandler.backgroundImagePath then
        encounterHandler.backgroundImage = love.graphics.newImage(encounterHandler.encounterPath .. encounterHandler.backgroundImagePath)
    end

    for i, enemyData in ipairs(encounterHandler.enemyData or {}) do
        encounterHandler.enemies[i] = Enemy:new(enemyData)
    end

    player.stats.love = encounterHandler.playerLove or 1
    player.stats.name = encounterHandler.playerName or 'CHARA'
    player.inventory = encounterHandler.playerInventory or {}
    player.hasKR = encounterHandler.playerHasKR or false

    player.stats.maxHp = 16 + (player.stats.love * 4)
    player.stats.hp = player.stats.maxHp
    player.kr = 0

    player.weapon = 3
    player.armor = 4

    player.stats.attack = itemManager.getPropertyFromID(player.weapon, 'stat')
    if player.armor == 4 then -- Set defense to 0 if armor is Bandage
        player.stats.defense = 0
    else
        player.stats.defense = itemManager.getPropertyFromID(player.armor, 'stat')
    end
end

function encounterHandler.doAct()
    player.lastButton = battle.choice
    battle.choice = -1
    local enemy = encounterHandler.enemies[player.chosenEnemy]
    if battle.subchoice > 0 then
        performAct(enemy.acts[battle.subchoice])
        performActText(battle.subchoice, actTextI)
    else
        writer:setParams("* " .. string.upper(enemy.name) .. " - ATT " .. enemy.attack .. " DEF " .. enemy.defense .. "[break]" .. enemy.description, 52, 274, fonts.determination, 0.02, writer.voices.menuText)
    end
end

function encounterHandler.update(dt)
    if encounterHandler.bgm then encounter.bgm:play() end
    if battle.state == "flee" then
        if encounterHandler.bgm then
            encounterHandler.bgm:setLooping(false)
            encounterHandler.bgm:stop()
        end
        encounterHandler.bgm = nil
    end

    if battle.state == 'perform act' then
        if writer.isDone and input.check('confirm', 'pressed') then
            if battle.subchoice > 0 then
                if actTextI < #encounterHandler.enemies[player.chosenEnemy].acts[battle.subchoice].text then
                    actTextI = actTextI + 1
                    performActText(battle.subchoice, actTextI)
                else
                    battleEngine.changeBattleState('attack', 'enemies')
                end
            else
                battleEngine.changeBattleState('attack', 'enemies')
            end
        end
    end

    if battle.state == 'attack' and battle.turn == 'enemies' then
        if input.check('cancel', 'pressed') then
            input.refresh()
            actTextI = 1
            battleEngine.changeBattleState('buttons', 'player')
        end
    end
end

function encounterHandler.draw()
    love.graphics.setColor(1, 1, 1)
    for _, enemy in ipairs(encounterHandler.enemies) do
        enemy:draw()
    end
end

function encounterHandler.background()
    love.graphics.setColor(encounterHandler.backgroundColor or {0, 0, 0})
    love.graphics.rectangle('fill', 0, 0, 640, 480)

    if encounterHandler.backgroundImage then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(encounterHandler.backgroundImage)
    end
end

return encounterHandler