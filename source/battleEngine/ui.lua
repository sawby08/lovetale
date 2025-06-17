local ui = {}
ui.buttons = {}

function ui.newButton(name, x, y, id, goTo)
    local image = love.graphics.newImage('assets/images/ui/bt/' .. name .. '.png')
    local button = {}
    button.image = image
    button.name = name
    button.quads = {}
    button.quads[1] = love.graphics.newQuad(0, 0, 110, 42, image)
    button.quads[2] = love.graphics.newQuad(110, 0, 110, 42, image)
    button.x = x
    button.y = y
    button.id = id
    button.canSelect = true
    button.goTo = goTo or name
    ui.buttons[id] = button
end

function ui.newBoxParams(x, y, w, h)
    ui.box.x = x
    ui.box.y = y
    ui.box.width = w
    ui.box.height = h
end

-- Load "HP" and "KR" graphics
local hp = love.graphics.newImage('assets/images/ui/spr_hpname_0.png')
local kr = love.graphics.newImage('assets/images/ui/spr_krmeter_0.png')

function ui.load()
    -- Set box dimensions
    ui.box = {
        x = 320 - 570/2,
        y = 253,
        width = 570,
        height = 135,
        direction = 0
    }
end

function ui.update(dt)
    -- Disable item menu if player doesn't have any items
    if #player.inventory < 1 then
        ui.buttons[2].canSelect = false
    end
end

function ui.draw()
    -- Draw buttons
    for _, button in pairs(ui.buttons) do
        if button.canSelect then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(1, 1, 1, .5)
        end
        love.graphics.draw(
            button.image,
            button.quads[(battle.choice == button.id) and 2 or 1],
            button.x,
            button.y
        )
    end

    -- Draw stats text
    love.graphics.setFont(fonts.mars)
    love.graphics.print(player.stats.name or 'chara', 30, 400) -- NAME
    love.graphics.print('LV ' .. player.stats.love, 148, 400) -- LV

    -- Draw "HP" and "KR" symbols
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(hp, 240, 400)
    if player.hasKR then
        if player.kr > 0 then
            -- Purple color (I haven't gotten to that part yet)
        end
        love.graphics.draw(kr, 280 + player.stats.maxHp * 1.25, 405)
    end

    -- Draw HP bar
    if player.stats.hp > player.stats.maxHp then    -- Cap the healthbar without any visual feedback
        player.stats.hp = player.stats.maxHp
    end
    love.graphics.setColor(.8, 0, 0)
    love.graphics.rectangle('fill', 275, 400, player.stats.maxHp * 1.25, 21)
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle('fill', 275, 400, player.stats.hp * 1.25, 21)

    -- Draw HP numbers
    if player.stats.hp < 10 then
        if player.hasKR then
            if player.kr == 0 then
                love.graphics.setColor(1, 1, 1)
            else
                -- Purple color (I haven't gotten to that part yet)
            end
            love.graphics.setFont(fonts.mars)
            love.graphics.print('0' .. player.stats.hp .. ' / ' .. player.stats.maxHp, 320 + player.stats.maxHp*1.25, 400)
        else
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(fonts.mars)
            love.graphics.print('0' .. player.stats.hp .. ' / ' .. player.stats.maxHp, 289 + player.stats.maxHp*1.25, 400)
        end
    else
        if player.hasKR then
            if player.kr == 0 then
                love.graphics.setColor(1, 1, 1)
            else
                -- Purple color (I haven't gotten to that part yet)
            end
            love.graphics.setFont(fonts.mars)
            love.graphics.print(player.stats.hp .. ' / ' .. player.stats.maxHp, 320 + player.stats.maxHp*1.25, 400)
        else
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(fonts.mars)
            love.graphics.print(player.stats.hp .. ' / ' .. player.stats.maxHp, 289 + player.stats.maxHp*1.25, 400)
        end
    end

    -- Draw box
    love.graphics.push("all")

    love.graphics.translate(ui.box.x, ui.box.y)
    love.graphics.rotate(ui.box.direction)

    love.graphics.setColor(0, 0, 0, .50) -- Fill
    love.graphics.rectangle('fill', 0, 0, ui.box.width, ui.box.height)
    love.graphics.setColor(1, 1, 1) -- Line
    love.graphics.setLineWidth(5)
    love.graphics.setLineStyle('rough')
    love.graphics.rectangle('line', 0, 0, ui.box.width, ui.box.height)

    love.graphics.pop()

    -- Draw text
    love.graphics.setFont(fonts.determination)
    if battle.state == 'choose enemy' then
        local i = 1
        for _, enemy in ipairs(encounter.enemies) do
            local string = '  * ' .. enemy.name
            love.graphics.setColor(1, 1, 1)
            if enemy.canSpare then
                love.graphics.setColor(conf.spareColor)
            end
            love.graphics.print('  * ' .. enemy.name, 68, 242 + (i * 32))

            -- Draw enemy HP bar
            if enemy.showHPBar and battle.choice == 0 then -- Checks if enemy can show HP bar and if the player is on selection 0 (fight)
                love.graphics.setColor(.8, 0, 0)
                love.graphics.rectangle('fill', 110 + #string*16, 248 + (i * 32), 101, 17)

                love.graphics.setColor(0, 1, 0)
                love.graphics.rectangle('fill', 110 + #string*16, 248 + (i * 32), ((enemy.hp / enemy.maxHp) * 101), 17)
            end
            i = i + 1
        end
    elseif battle.state == 'act' then
        love.graphics.print('  * Check', 68, 274)
        local positions = { {x = 324, y = 274}, {x = 68, y = 306}, {x = 324, y = 306}, {x = 68, y = 338}, {x = 324, y = 338} }
        for i = 1, #encounter.enemies[player.chosenEnemy].acts do
            love.graphics.print('  * ' .. encounter.enemies[player.chosenEnemy].acts[i].name, positions[i].x, positions[i].y)
        end
    elseif battle.state == 'item' then
        local itemPage = math.floor(battle.subchoice / 4)
        local positions = { {x = 68,  y = 274}, {x = 308, y = 274}, {x = 68,  y = 306}, {x = 308, y = 306} }
        for i = 1, 4 do
            if player.inventory[i + (itemPage * 4)] then
                love.graphics.print('  * ' .. itemManager.getPropertyFromID(player.inventory[i + (itemPage * 4)], 'shortName'), positions[i].x, positions[i].y)
            end
        end
        if #player.inventory > 4 then
            love.graphics.print('     PAGE ' .. itemPage+1, 308, 338)
        end
    elseif battle.state == 'mercy' then
        love.graphics.setColor(1, 1, 1)
        for _, enemy in ipairs(encounter.enemies) do
            if enemy.canSpare then
                love.graphics.setColor(conf.spareColor)
            end
        end
        love.graphics.print('  * Spare', 68, 274)
        if encounter.canFlee then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print('  * Flee', 68, 306)
        end
    end
end

return ui