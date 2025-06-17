local player = {}
local battleEngine = require 'source.battleEngineState'
local xvel, yvel = 0, 0
local blueGrav, jumpstage, jumptimer = 0, 0, 0

-- Load heart image and position, global so other objects can place it
player.heart = {
    image = love.graphics.newImage('assets/images/ut-heart.png'),
    x = 0,
    y = 0
}

-- Load global player stuff
player.stats = {}

-- This only exists because I don't know a better way to make the heart not delayed between menu states
local function updatePosition(dt)
    if battle.turn == 'player' then
        if battle.state == 'fight' or battle.state == 'perform act' or battle.state == 'use item' then
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
        

function player.load()
    player.mode = 2
end

function player.update(dt)
    if battle.turn == 'player' then
        if battle.state == 'mercy' then
            if input.check('secondary', 'pressed') then
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
        elseif battle.state == 'use item' and writer.isDone and input.check('primary', 'pressed') then
                battleEngine.changeBattleState('attack', 'enemies')
        elseif battle.state == 'item' then
            -- Note: #player.inventory is subtracted by one because battle.subchoice iterates from 0. This doesn't present a problem for act since check isn't included but since all items are included I have to do it like this
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
            if input.check('primary', 'pressed') then
                battleEngine.changeBattleState('use item', 'player')
            end
            if input.check('secondary', 'pressed') then
                input.refresh()
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
            if input.check('secondary', 'pressed') then
                input.refresh()
                battle.subchoice = player.chosenEnemy - 1
                battleEngine.changeBattleState('choose enemy', 'player')
            end
            if input.check('primary', 'pressed') then
                battleEngine.changeBattleState('perform act', 'player')
            end
        elseif battle.state == 'choose enemy' then
            if input.check('secondary', 'pressed') then
                input.refresh()
                battleEngine.changeBattleState('buttons', 'player')
            end
            if input.check('primary', 'pressed') then
                if battle.choice == 0 then
                    player.lastButton = battle.choice
                    battle.choice = -1
                    battleEngine.changeBattleState('attack', 'enemies')
                elseif battle.choice == 1 then
                    player.chosenEnemy = battle.subchoice + 1
                    battleEngine.changeBattleState('act', 'player')
                    battle.subchoice = 0
                end
                sfx.menuselect:stop()
                sfx.menuselect:play()
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
            elseif input.check('primary', 'pressed') then
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
            local speed = 4
            if input.check('secondary', 'held') then
                speed = 2
            else
                speed = 4
            end
            if player.mode == 1 then -- Red soul movement
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
                -- Left and right movement and gravitational pull
                blueGrav = blueGrav + 0.75 * dt*30
                yvel = yvel + blueGrav
                if input.check('left', 'held') then
                    xvel = xvel - speed
                end
                if input.check('right', 'held') then
                    xvel = xvel + speed
                end

                -- Check if player is on the bottom of the box so they can jump, resets the timer and jumpstage
                if player.heart.y >= ui.box.y + ui.box.height - 19 then
                    jumpstage = 0
                    jumptimer = 0
                    if input.check('up', 'held') then
                        -- Change jumpstage so the player stays jumping
                        jumpstage = 1
                    end
                end
                if jumpstage == 1 and input.check('up', 'held') and player.heart.y <= ui.box.y + ui.box.height - 19 then
                    -- Make the player jump by 6 pixels and increase jumptimer to prevent the player from jumping too high
                    blueGrav = -6
                    jumptimer = jumptimer + dt*30
                end
                if player.heart.y <= ui.box.y + ui.box.height - 19 and jumpstage == 1 and not input.check('up', 'held') then
                    -- Change gravity so movement is tighter
                    blueGrav = -1.5
                    jumpstage = 2
                end
                if jumptimer > 10 then
                    -- Don't change gravity so the full motion is fluid
                    jumptimer = 0
                    jumpstage = 2
                end
            end
        end
    end
    updatePosition(dt)
end

function player.draw()
    love.graphics.push("all")

    if player.mode == 1 then
        love.graphics.setColor(1, 0, 0)
    elseif player.mode == 2 then
        love.graphics.setColor(0, 0, 1)
    end
    love.graphics.draw(player.heart.image, player.heart.x, player.heart.y)

    love.graphics.pop()
end


return player