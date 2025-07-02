local ui = {}
ui.buttons = {}
local battleEngine = require 'source.battleEngineState'

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

-- Load "HP" and "KR" graphics
local hp = love.graphics.newImage('assets/images/ui/spr_hpname_0.png')
local kr = love.graphics.newImage('assets/images/ui/spr_krmeter_0.png')

-- Load assets and intialize variables for fight ui
local target = love.graphics.newImage('assets/images/ui/spr_target_0.png')
local targetChoice = {
    love.graphics.newImage('assets/images/ui/spr_targetchoice_0.png'),
    love.graphics.newImage('assets/images/ui/spr_targetchoice_1.png')}
local slice = {
    love.graphics.newImage('assets/images/ui/slice/spr_slice_o_0.png'),
    love.graphics.newImage('assets/images/ui/slice/spr_slice_o_1.png'),
    love.graphics.newImage('assets/images/ui/slice/spr_slice_o_2.png'),
    love.graphics.newImage('assets/images/ui/slice/spr_slice_o_3.png'),
    love.graphics.newImage('assets/images/ui/slice/spr_slice_o_4.png'),
    love.graphics.newImage('assets/images/ui/slice/spr_slice_o_5.png')}
local targetX, targetMode, targetFrame = 38, "left", 1
local sliceFrame, sliceTimer = 1, 0
local damage = 0
local targetTimer = 0
local damageTextYvel, damageTextY, damageShow, damageType = 0, 0, false, "miss"
local fightUiAlpha, targetScale = 1, 0
local lastEnemyX, shake, shakeMult, shakeMultTimer = nil, 0, 1, 0

-- Load misc assets
local speechBubble = love.graphics.newImage('assets/images/ui/speechbubble.png')
local dialogueIteration = 1

local function drawText(text, x, y, color, outlineColor)
    for i = -3, 3 do
        love.graphics.setColor(outlineColor)
        for j = -3, 3 do
            if i ~= 3 then
                love.graphics.print(text, x + i, y + j)
            end
        end
    end
    love.graphics.setColor(color)
    love.graphics.print(text, x, y)
end

local function doDialogueStuff()
    if encounter.attacks[battle.turnCount].dialogue[dialogueIteration].bubbleDirection == "left" then
        writer:setParams(
            "[black]" .. encounter.attacks[battle.turnCount].dialogue[dialogueIteration].text,
            encounter.enemies[encounter.attacks[battle.turnCount].dialogue[dialogueIteration].speaker].x + encounter.attacks[battle.turnCount].dialogue[dialogueIteration].bubbleOffset - 224,
            encounter.enemies[encounter.attacks[battle.turnCount].dialogue[dialogueIteration].speaker].y + 12,
            fonts.dialogue,
            0.02,
            writer.voices.menuText
        )
    else
        writer:setParams(
            "[black]" .. encounter.attacks[battle.turnCount].dialogue[dialogueIteration].text,
            encounter.enemies[encounter.attacks[battle.turnCount].dialogue[dialogueIteration].speaker].x + encounter.attacks[battle.turnCount].dialogue[dialogueIteration].bubbleOffset + 40,
            encounter.enemies[encounter.attacks[battle.turnCount].dialogue[dialogueIteration].speaker].y + 12,
            fonts.dialogue,
            0.02,
            writer.voices.menuText
        )
    end
end

function ui.setUpTarget()
    if love.math.random(1, 2) == 1 then -- Randomly place targetchoice left or right
        targetX = 38
        targetMode = "left"
    else
        targetX = 640-38
        targetMode = "right"
    end
    targetFrame = love.math.random(1, 2)
    damageTextY = encounter.enemies[player.chosenEnemy].y + 125
    sliceFrame, sliceTimer = 1, 0
    damage = 0
    targetTimer = 0
    damageTextYvel, damageTextY, damageShow, damageType = 0, 0, false, "miss"
    fightUiAlpha, targetScale = 1, 0
    shake, shakeMult, shakeMultTimer = 0, 1, 1
end

function ui.load()
    -- Set box dimensions
    ui.box = {
        x = 35,
        y = 253,
        width = 570,
        height = 135,
        direction = 0
    }
    fightUiAlpha = 0
end

function ui.update(dt)
    -- Disable item menu if player doesn't have any items
    if #player.inventory < 1 then
        ui.buttons[2].canSelect = false
    end

    -- Update stuff for the fight ui (FAIR WARNING: the code for the fight ui is hot garbage but it works so i'm not gonna do anything about it)
    if battle.state == "fight" then
        if targetMode == "left" then
            targetX = targetX + 12 * dt*30
            if targetX > 640-38 then -- If it goes out of the box, miss
                targetMode = "miss"
                damageType = "miss"
                damageShow = true
                battleEngine.changeBattleState("dialogue", "enemies")
                if encounter.enemies[player.chosenEnemy].hp == 0 then
                    encounter.enemies[player.chosenEnemy].status = "killed"
                    sfx.dust:play()
                end
            end
        end
        if targetMode == "right" then -- If it goes out of the box, miss
            targetX = targetX - 12 * dt*30
            if targetX < 38 then
                targetMode = "miss"
                damageType = "miss"
                damageShow = true
                battleEngine.changeBattleState("dialogue", "enemies")
                if encounter.enemies[player.chosenEnemy].hp == 0 then   -- Kill enemy if hp is 0
                    encounter.enemies[player.chosenEnemy].status = "killed"
                    sfx.dust:play()
                end
            end
        end
        -- When z is pressed while target is moving
        if input.check('confirm', 'pressed') and targetMode ~= "miss" and targetMode ~= "attack" then
            lastEnemyX = encounter.enemies[player.chosenEnemy].x
            shake = encounter.enemies[player.chosenEnemy].dodgeOffset
            if encounter.enemies[player.chosenEnemy].canDodge then
                targetMode = "attack"
                sfx.slice:play()
                damageType = "miss"
            else
                targetMode = "attack"
                damageType = "success"
                sfx.slice:play()
            end
        end
        if targetMode == "attack" then
            -- Animate targetchoice
            targetTimer = targetTimer + dt
            if targetTimer > 0.075 then
                targetTimer = 0
                targetFrame = targetFrame + 1
                if targetFrame > 2 then
                    targetFrame = 1
                end
            end

            -- Animate slice
            sliceTimer = sliceTimer + dt
            if sliceTimer > 0.1 then
                sliceTimer = 0
                sliceFrame = sliceFrame + 1
            end

            if lastEnemyX and sliceFrame > 11 and not encounter.enemies[player.chosenEnemy].canDodge then
                if shake > 0 then
                    shake = shake - 8 * dt*30
                    encounter.enemies[player.chosenEnemy].doAnimation = false
                else
                    shake = 0
                end
                shakeMultTimer = shakeMultTimer + dt
                if shakeMultTimer > 0.05 then
                    shakeMultTimer = 0
                    shakeMult = shakeMult * -1
                    encounter.enemies[player.chosenEnemy].x = lastEnemyX + shake/8 * shakeMult
                end
            end

            -- Trigger enemy damage
            if sliceFrame == 11 then
                -- I know this sucks i'm sorry
                local distFromCenter = math.abs(math.abs(targetX - 320) - 320) / 14
                if encounter.enemies[player.chosenEnemy].canSpare then
                    damage = math.abs(encounter.enemies[player.chosenEnemy].maxHp + math.floor(distFromCenter + (player.stats.attack + itemManager.getPropertyFromID(player.weapon, 'stat') - encounter.enemies[player.chosenEnemy].defense) + 0.5))
                else
                    damage = math.abs(math.floor(distFromCenter + (player.stats.attack + itemManager.getPropertyFromID(player.weapon, 'stat') - encounter.enemies[player.chosenEnemy].defense) + 0.5))
                end
                if encounter.enemies[player.chosenEnemy].canDodge then
                    sliceFrame = 12
                    damageShow = true
                    damageTextYvel = 12
                    damageTextY = encounter.enemies[player.chosenEnemy].y + 0 * dt*30
                else
                    sliceFrame = 12
                    sfx.hit:play()
                    encounter.enemies[player.chosenEnemy].hp = encounter.enemies[player.chosenEnemy].hp - damage
                    damageShow = true
                    damageTextYvel = 12
                    damageTextY = encounter.enemies[player.chosenEnemy].y + 0 * dt*30
                    shake = math.abs(shake)

                    if encounter.enemies[player.chosenEnemy].hp < 0 then
                        encounter.enemies[player.chosenEnemy].hp = 0
                    end
                end
            end

            if sliceFrame > 0 and sliceFrame < 11 then
                -- Animate enemy dodging
                if encounter.enemies[player.chosenEnemy].canDodge and lastEnemyX then
                    encounter.enemies[player.chosenEnemy].x = encounter.enemies[player.chosenEnemy].x + (lastEnemyX+encounter.enemies[player.chosenEnemy].dodgeOffset - encounter.enemies[player.chosenEnemy].x) * 0.3 * dt*30
                end
            else
                if encounter.enemies[player.chosenEnemy].canDodge and lastEnemyX then
                    encounter.enemies[player.chosenEnemy].x = encounter.enemies[player.chosenEnemy].x + (lastEnemyX - encounter.enemies[player.chosenEnemy].x) * 0.3 * dt*30
                end
            end
            -- Start playing enemy animation again after being hit
            if sliceFrame == 21 then
                encounter.enemies[player.chosenEnemy].doAnimation = true
            end

            -- Go to enemy dialogue
            if sliceFrame == 28 then
                sliceFrame = 29
                if encounter.enemies[player.chosenEnemy].hp == 0 then
                    encounter.enemies[player.chosenEnemy].status = "killed"
                    sfx.dust:play()
                end
                if encounter.enemies[player.chosenEnemy].canDodge and lastEnemyX then
                    encounter.enemies[player.chosenEnemy].x = lastEnemyX
                end
                battleEngine.changeBattleState("dialogue", "enemies")
                doDialogueStuff()
            end

            if damageShow then
                if damageType == "miss" and encounter.enemies[player.chosenEnemy].canDodge then
                    damageTextYvel = damageTextYvel - 1 *dt*30
                    damageTextY = damageTextY - damageTextYvel *dt*30
                end
                if damageType ~= "miss" then
                    damageTextYvel = damageTextYvel - 1 *dt*30
                    damageTextY = damageTextY - damageTextYvel *dt*30
                end
            end
            if damageTextY > encounter.enemies[player.chosenEnemy].y + 0 then
                damageTextY = encounter.enemies[player.chosenEnemy].y + 0
            end
        end
    end

    -- Update box
    if battle.turn == "enemies" then
        targetScale = targetScale + dt*4
        fightUiAlpha = fightUiAlpha - dt*4
        ui.box.x = ui.box.x + (encounter.attacks[battle.turnCount].boxDims.x - ui.box.x) * 0.3 * dt*30
        ui.box.y = ui.box.y + (encounter.attacks[battle.turnCount].boxDims.y - ui.box.y) * 0.3 * dt*30
        ui.box.width = ui.box.width + (encounter.attacks[battle.turnCount].boxDims.width - ui.box.width) * 0.3 * dt*30
        ui.box.height = ui.box.height + (encounter.attacks[battle.turnCount].boxDims.height - ui.box.height) * 0.3 * dt*30
    end
    if battle.turn == "player" then
        ui.box.x = ui.box.x + (35 - ui.box.x) * 0.3 * dt*30
        ui.box.y = ui.box.y + (253 - ui.box.y) * 0.3 * dt*30
        ui.box.width = ui.box.width + (570 - ui.box.width) * 0.3 * dt*30
        ui.box.height = ui.box.height + (135 - ui.box.height) * 0.3 * dt*30
    end

    -- Progress through dialogue
    if input.check('confirm', 'pressed') and battle.state == 'dialogue' and writer.isDone then
        if dialogueIteration < #encounter.attacks[battle.turnCount].dialogue then
            dialogueIteration = dialogueIteration + 1
            doDialogueStuff()
        else
            battleEngine.changeBattleState('attack', 'enemies')
            lastEnemyX = nil
            dialogueIteration = 1
        end
    end
end

function ui.drawbox(part)
    love.graphics.push("all")

    love.graphics.translate(ui.box.x, ui.box.y)
    love.graphics.rotate(ui.box.direction)

    if part == "fill" then
        love.graphics.setColor(0, 0, 0) -- Fill
        love.graphics.rectangle('fill', 0, 0, ui.box.width, ui.box.height)
    end
    if part == "line" then
        love.graphics.setColor(1, 1, 1) -- Line
        love.graphics.setLineWidth(5)
        love.graphics.setLineStyle('rough')
        love.graphics.rectangle('line', 0, 0, ui.box.width, ui.box.height)
    end

    love.graphics.pop()
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
    love.graphics.setFont(fonts.ui)
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
            love.graphics.setFont(fonts.ui)
            love.graphics.print('0' .. player.stats.hp .. ' / ' .. player.stats.maxHp, 320 + player.stats.maxHp*1.25, 400)
        else
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(fonts.ui)
            love.graphics.print('0' .. player.stats.hp .. ' / ' .. player.stats.maxHp, 289 + player.stats.maxHp*1.25, 400)
        end
    else
        if player.hasKR then
            if player.kr == 0 then
                love.graphics.setColor(1, 1, 1)
            else
                -- Purple color (I haven't gotten to that part yet)
            end
            love.graphics.setFont(fonts.ui)
            love.graphics.print(player.stats.hp .. ' / ' .. player.stats.maxHp, 320 + player.stats.maxHp*1.25, 400)
        else
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(fonts.ui)
            love.graphics.print(player.stats.hp .. ' / ' .. player.stats.maxHp, 289 + player.stats.maxHp*1.25, 400)
        end
    end

    -- Draw text
    love.graphics.setFont(fonts.main)
    if battle.state == 'choose enemy' then
        local i = 1
        for _, enemy in ipairs(encounter.enemies) do
            local string = '  * ' .. enemy.name
            if enemy.status == "alive" then
                love.graphics.setColor(1, 1, 1)
                if enemy.canSpare then
                    love.graphics.setColor(conf.spareColor)
                end
            else
                love.graphics.setColor(1, 1, 1, .5)
            end
            love.graphics.print('  * ' .. enemy.name, 68, 242 + (i * 32))

            -- Draw enemy HP bar
            if enemy.showHPBar and battle.choice == 0 and enemy.status == "alive" then -- Checks if enemy can show HP bar and if the player is on selection 0 (fight)
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

    -- Draw fight ui
    if battle.state == "fight" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(target, 38, 256)
        if targetMode ~= "miss" then
            love.graphics.draw(targetChoice[targetFrame], targetX, 256)
        end
        if targetMode == "attack" and sliceFrame < 7 then
            love.graphics.draw(slice[sliceFrame], lastEnemyX+35, encounter.enemies[player.chosenEnemy].y)
        end
        if damageShow then
            if damageType ~= "miss" then
                love.graphics.setColor(0, 0, 0)
                love.graphics.rectangle('fill', lastEnemyX-3 - 149/5, encounter.enemies[player.chosenEnemy].y-3+35, 149+6, 13+6)
                love.graphics.setColor(64 / 255, 64 / 255, 64 / 255)
                love.graphics.rectangle('fill', lastEnemyX-149/5, encounter.enemies[player.chosenEnemy].y+35, 149, 13)
                love.graphics.setColor(0, 1, 0)
                love.graphics.rectangle('fill', lastEnemyX-149/5, encounter.enemies[player.chosenEnemy].y+35, encounter.enemies[player.chosenEnemy].hp / encounter.enemies[player.chosenEnemy].maxHp * 149, 13)
                love.graphics.setFont(fonts.attack)
                drawText(damage, lastEnemyX+50 - fonts.attack:getWidth(damage)/2, damageTextY, {1, 0, 0}, {0, 0, 0})
            else
                love.graphics.setFont(fonts.attack)
                drawText("MISS", lastEnemyX, damageTextY, {.5, .5, .5}, {0, 0, 0})
            end
        end
    end
    if battle.state == "dialogue" then
        love.graphics.setColor(1, 1, 1, fightUiAlpha)
        love.graphics.draw(target, 320, 256, 0, 1 - targetScale, 1, target:getWidth()/2)
        if targetMode ~= "miss" then
            love.graphics.draw(targetChoice[targetFrame], targetX, 256)
        end
    end

    -- Draw speech bubbles
    if battle.state == "dialogue" then
        love.graphics.push("all")
        love.graphics.translate(0, ui.box.y - 253)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(
            speechBubble,
            encounter.enemies[encounter.attacks[battle.turnCount].dialogue[dialogueIteration].speaker].x + encounter.attacks[battle.turnCount].dialogue[dialogueIteration].bubbleOffset,
            encounter.enemies[encounter.attacks[battle.turnCount].dialogue[dialogueIteration].speaker].y,
            0,
            encounter.attacks[battle.turnCount].dialogue[dialogueIteration].bubbleDirection == "left" and -1 or 1,
            1
        )
        love.graphics.pop()
    end
end

return ui