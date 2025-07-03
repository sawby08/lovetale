local player = {}
local battleEngine = require 'source.battleEngineState'
local xvel, yvel = 0, 0
local jumpstage, vspeed = 2, -1
local currentInvFrame, timeSince = 30, 0
local krTimer = 0

-- Load heart image and position, global so other objects can place it
player.heart = {
    image = love.graphics.newImage('assets/images/ut-heart.png'),
    x = 0,
    y = 0
}
local fleeingFrames = {
    love.graphics.newImage("assets/images/spr_heartgtfo_0.png"),
    love.graphics.newImage("assets/images/spr_heartgtfo_1.png")
}

-- Load global player stuff
player.stats = {}

-- This only exists because I don't know a better way to make the heart not delayed between menu states
local function updatePosition(dt)
    if battle.turn == 'player' then
        if battle.state == 'fight' or battle.state == 'perform act' or battle.state == 'use item' or battle.state == "end" then
            player.heart.x = -16
            player.heart.y = -16
        elseif battle.state == 'buttons' then
            player.heart.x = ui.buttons[battle.choice].x + 8
            player.heart.y = ui.buttons[battle.choice].y + 13
        elseif battle.state == 'choose enemy' or battle.state == 'mercy' then
            player.heart.x = 64
            player.heart.y = 278 + (battle.subchoice * 32)
        elseif battle.state == 'act' then
            local positions = {
                x = {64, 320, 64, 320, 64, 320},
                y = {278, 278, 310, 310, 342, 342}
            }
            player.heart.x = positions.x[battle.subchoice+1]
            player.heart.y = positions.y[battle.subchoice+1]
        elseif battle.state == 'item' then
            local placement = battle.subchoice % 4
            local positions = {
                x = {64, 304, 64, 304},
                y = {278, 278, 310, 310}
            }
            player.heart.x = positions.x[placement+1]
            player.heart.y = positions.y[placement+1]
        end
    end
    if battle.turn == 'enemies' then
        if battle.state == 'attack' then
            player.heart.x = player.heart.x + (xvel * dt*30)
            player.heart.y = player.heart.y + (yvel * dt*30)
        end
        if player.heart.x < ui.box.x + 2 then
            player.heart.x = ui.box.x + 2
        end
        if player.heart.x > ui.box.x + ui.box.width - 19 then
            player.heart.x = ui.box.x + ui.box.width - 19
        end
        if player.heart.y < ui.box.y + 2 then
            player.heart.y = ui.box.y + 2
        end
        if player.heart.y > ui.box.y + ui.box.height - 19 then
            player.heart.y = ui.box.y + ui.box.height - 19
        end
    end
end

local function performMove(type, number)
    local last = battle.subchoice
    if type == 'item' then
        battle.subchoice = (battle.subchoice + number)
        if battle.subchoice < 0 then
            battle.subchoice = 0
        end
        if battle.subchoice > #player.inventory-1 then
            battle.subchoice = #player.inventory-1
        end
    elseif type == 'act' then
        battle.subchoice = (battle.subchoice + number)
        if battle.subchoice < 0 then
            battle.subchoice = 0
        end
        if battle.subchoice > #encounter.enemies[player.chosenEnemy].acts then
            battle.subchoice = #encounter.enemies[player.chosenEnemy].acts
        end
    elseif type == 'choose enemy' then
        battle.subchoice = (battle.subchoice + number)
        if battle.subchoice < 0 then
            battle.subchoice = 0
        end
        if battle.subchoice > #encounter.enemies-1 then
            battle.subchoice = #encounter.enemies-1
        end
    end
    if last ~= battle.subchoice then
       sfx.menumove:stop()
       sfx.menumove:play()
    end
end

function player.hurt(damage)
    if player.hasKR then
        if player.stats.hp > 1 then
            player.stats.kr = player.stats.kr + 2
        else
            player.stats.kr = player.stats.kr - 1
        end
        player.stats.hp = player.stats.hp - damage
        sfx.hurt:stop()
        sfx.hurt:play()
    elseif currentInvFrame >= player.invFrames then
        camera:shake(1, 1)
        player.stats.hp = player.stats.hp - damage
        sfx.hurt:stop()
        sfx.hurt:play()
        currentInvFrame = 0
    end
end

function player.load()
    player.mode = 1
end

function player.update(dt)
    timeSince = timeSince + 1
    if timeSince > 1 * dt*30 then
        timeSince = 0
        currentInvFrame = currentInvFrame + 1
    end
    local lx, ly = player.heart.x, player.heart.y
    if battle.turn == 'player' then
        if battle.state == "flee" then
            player.heart.x = player.heart.x - 2 * dt*30
            if player.heart.x < -16 then
                love.load()
            end
        end
        if battle.state == "end" then
            if writer.isDone and input.check('confirm', 'pressed') then
                input.refresh()
                love.load()
            end
        end
        if battle.state == 'mercy' then
            player.lastButton = battle.choice
            if input.check('confirm', 'pressed') then
                if battle.subchoice == 0 then
                    local i = 1
                    local sparedenem = 0
                    for _, enemy in ipairs(encounter.enemies) do
                        if enemy.canSpare then
                            enemy.status = "spared"
                            enemy.canSpare = false
                            sfx.dust:play()
                            sparedenem = i
                        end
                        i = i + 1
                        battle.choice = -1
                    end
                    encounter.onSpare(sparedenem)
                    battleEngine.changeBattleState('dialogue', 'enemies')
                elseif battle.subchoice == 1 then
                    battleEngine.changeBattleState('flee', 'player')
                end
            end
            if input.check('cancel', 'pressed') then
                input.refresh()
                battleEngine.changeBattleState('buttons', 'player')
            end
            if input.check('down', 'pressed') and encounter.canFlee then
                if encounter.canFlee and battle.subchoice == 0 then
                    sfx.menumove:stop()
                    sfx.menumove:play()
                end
                battle.subchoice = 1
                updatePosition()
            end
            if input.check('up', 'pressed') then
                if battle.subchoice == 1 then
                    sfx.menumove:stop()
                    sfx.menumove:play()
                end
                battle.subchoice = 0
                updatePosition()
            end
        elseif battle.state == 'use item' and writer.isDone and input.check('confirm', 'pressed') then
            battleEngine.changeBattleState('attack', 'enemies')
        elseif battle.state == 'item' then
            if input.check('up', 'pressed') then
                performMove('item', -2)
            end
            if input.check('down', 'pressed') then
                performMove('item', 2)
            end
            if input.check('left', 'pressed') then
                performMove('item', -1)
            end
            if input.check('right', 'pressed') then
                performMove('item', 1)
            end
            if input.check('confirm', 'pressed') then
                input.refresh()
                battleEngine.changeBattleState('use item', 'player')
            end
            if input.check('cancel', 'pressed') then
                battleEngine.changeBattleState('buttons', 'player')
            end
        elseif battle.state == 'act' then
            if input.check('up', 'pressed') then
                performMove('act', -2)
            end
            if input.check('down', 'pressed') then
                performMove('act', 2)
            end
            if input.check('left', 'pressed') then
                performMove('act', -1)
            end
            if input.check('right', 'pressed') then
                performMove('act', 1)
            end
            if input.check('cancel', 'pressed') then
                battle.subchoice = player.chosenEnemy - 1
                battleEngine.changeBattleState('choose enemy', 'player')
            end
            if input.check('confirm', 'pressed') then
                battleEngine.changeBattleState('perform act', 'player')
                input.refresh()
            end
        elseif battle.state == 'choose enemy' then
            if input.check('cancel', 'pressed') then
                input.refresh()
                battleEngine.changeBattleState('buttons', 'player')
            end
            if input.check('confirm', 'pressed') then
                if battle.choice == 0 and encounter.enemies[battle.subchoice+1].status == "alive" then
                    player.lastButton = battle.choice
                    battle.choice = -1
                    player.chosenEnemy = battle.subchoice + 1
                    battleEngine.changeBattleState('fight', 'player')
                    ui.setUpTarget()
                    sfx.menuselect:stop()
                    sfx.menuselect:play()
                elseif battle.choice == 1 and encounter.enemies[battle.subchoice+1].status == "alive" then
                    player.chosenEnemy = battle.subchoice + 1
                    battleEngine.changeBattleState('act', 'player')
                    battle.subchoice = 0
                    sfx.menuselect:stop()
                    sfx.menuselect:play()
                end
            end
            if input.check('up', 'pressed') then
                performMove('choose enemy', -1)
            end
            if input.check('down', 'pressed') then
                performMove('choose enemy', 1)
            end
        elseif battle.state == 'buttons' then
            if input.check('right', 'pressed') then
                battle.choice = (battle.choice + 1) % (#ui.buttons + 1)
                sfx.menumove:stop()
                sfx.menumove:play()
                updatePosition()
            elseif input.check('left', 'pressed') then
                battle.choice = (battle.choice - 1) % (#ui.buttons + 1)
                sfx.menumove:stop()
                sfx.menumove:play()
                updatePosition()
            elseif input.check('confirm', 'pressed') then
                if ui.buttons[battle.choice].canSelect then
                    writer.stop()
                    battle.subchoice = 0
                    battleEngine.changeBattleState(ui.buttons[battle.choice].goTo, 'player')
                    sfx.menuselect:stop()
                    sfx.menuselect:play()
                end
            end
        end
    elseif battle.turn == 'enemies' then
        if battle.state == 'attack' then
            xvel, yvel = 0, 0
            if player.mode == 1 then -- Red soul movement
                local speed = 4
                if input.check('cancel', 'held') then
                    speed = 2
                end
                if input.check('up', 'held') then
                    yvel = yvel - speed
                end
                if input.check('down', 'held') then
                    yvel = yvel + speed
                end
                if input.check('left', 'held') then
                    xvel = xvel - speed
                end
                if input.check('right', 'held') then
                    xvel = xvel + speed
                end
            elseif player.mode == 2 then -- Blue soul movement
                local speed = 5
                if input.check('cancel', 'held') then
                    speed = 2
                end
                if input.check('left', 'held') then
                    xvel = xvel - speed
                end
                if input.check('right', 'held') then
                    xvel = xvel + speed
                end
                if jumpstage == 2 then
                    if not input.check('up', 'held') and vspeed <= -1 then
                        vspeed = -1
                    end
                    if vspeed > .5 and vspeed < 8 then
                        vspeed = vspeed + .6 * dt*30
                    end
                    if vspeed > -1 and vspeed <= .5 then
                        vspeed = vspeed + .2 * dt*30
                    end
                    if vspeed > -4 and vspeed <= -1 then
                        vspeed = vspeed + .5 * dt*30
                    end
                    if vspeed <= -4 then
                        vspeed = vspeed + .2 * dt*30
                    end
                end
                yvel = yvel + math.floor(vspeed + .5)
                if player.heart.y >= ui.box.y + ui.box.height - 19 then
                    player.heart.y = ui.box.y + ui.box.height - 19
                    jumpstage = 1
                    vspeed = 0
                end
                if player.heart.y <= ui.box.y - ui.box.height + 2 then
                    vspeed = 1
                end
                if input.check('up', 'held') and jumpstage == 1 then
                    jumpstage = 2
                    vspeed = -6
                end
            end
        end
    end
    updatePosition(dt)
    player.isMoving = (lx ~= player.heart.x or ly ~= player.heart.y or (jumpstage == 2 and player.mode == 2))

    krTimer = krTimer + dt
    if krTimer > 1.8 / (player.stats.kr + 1) then
        krTimer = 0
        if player.stats.hp + player.stats.kr > player.stats.hp then
            player.stats.kr = player.stats.kr - 1
        else
            player.stats.kr = 0
        end
    end
end

function player.draw()
    love.graphics.push("all")

    local brightness = currentInvFrame >= player.invFrames and 1 or 0.5
    if player.mode == 1 then
        love.graphics.setColor(1, 0, 0, brightness)
    elseif player.mode == 2 then
        love.graphics.setColor(0, 0, 1, brightness)
    end
    if battle.state == "flee" then
        love.graphics.draw(fleeingFrames[math.floor((love.timer.getTime()*10)%2) + 1], player.heart.x, player.heart.y)
    else
        love.graphics.draw(player.heart.image, player.heart.x, player.heart.y)
    end

    love.graphics.pop()
end


return player