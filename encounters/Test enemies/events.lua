-- encounter. is being used instead of data. because the enemy data has already been loaded by the encounter handler when these functions are called!
function eventsSetup(data)

    data.onDeath = function(enemy)       -- Function that's run when an enemy dies (enemy is the enemy that's dead)
        if enemy == 1 then
            battle.turnCount = 1
            encounter.enemies[2].acts = {}
            encounter.enemies[2].canSpare = true
            encounter.attacks = {}
            encounter.attacks[1] = {
                boxDims = {
                    x = math.floor(320 - 135/2),
                    y = 253,
                    width = 135,
                    height = 135
                },
                dialogue = {
                    {
                        speaker = 2,
                        text = "heh. i don't believe\nin you anymore..",
                        bubbleDirection = "left",
                        bubbleOffset = 0,
                        font = fonts.papyrus,
                        voice = data.voices.papyrus
                    }
                },
                init = function()
                    -- Init attack stuff (don't worry about this)
                    attackTimer = 0
                    timeSince = 0
                    bullets = {}
                    player.mode = 2
                    -- Everything below this is your custom code
                end,
                update = function(dt)
                    -- Update attack stuff (don't worry about this)
                    timeSince = timeSince + 1 * dt*30
                    if timeSince >= 1 then
                        attackTimer = attackTimer + 1
                        timeSince = 0
                    end

                    local i = 1 -- here to remove bullets
                    for _, bullet in ipairs(bullets) do
                        bullet:update(dt)
                        if bullet.remove then
                            table.remove(bullets, i)
                        end
                        i = i + 1
                    end
                    -- Everything below this is your custom code

                    if attackTimer == 15 then
                        ui.goToMenu()
                        bullets = {}
                    end
                end,
                draw = function()
                end
            }
            encounter.text = "[clear]* Get a load of this guy[break]:face_holding_back_tears:"
        elseif enemy == 2 then
            battle.turnCount = 1
            encounter.bgm:setPitch(0.25)
            encounter.attacks = {
                {
                    boxDims = {
                        x = math.floor(320 - 135/2),
                        y = 253,
                        width = 135,
                        height = 135
                    },
                    dialogue = {
                        {
                            speaker = 1,
                            text = "[shake]oh... :-(",
                            bubbleDirection = "right",
                            bubbleOffset = 125,
                            font = fonts.dialogue,
                            voice = data.voices.default
                        }
                    },
                    init = function()
                        -- Init attack stuff (don't worry about this)
                        attackTimer = 0
                        timeSince = 0
                        bullets = {}
                        player.mode = 2
                        -- Everything below this is your custom code
                    end,
                    update = function(dt)
                        -- Update attack stuff (don't worry about this)
                        timeSince = timeSince + 1 * dt*30
                        if timeSince >= 1 then
                            attackTimer = attackTimer + 1
                            timeSince = 0
                        end

                        local i = 1 -- here to remove bullets
                        for _, bullet in ipairs(bullets) do
                            bullet:update(dt)
                            if bullet.remove then
                                table.remove(bullets, i)
                            end
                            i = i + 1
                        end
                        -- Everything below this is your custom code

                        if attackTimer == 15 then
                            ui.goToMenu()
                            bullets = {}
                        end
                    end,
                    draw = function()
                    end
                    }
                }
            encounter.text = "[clear]* You feel an overwhelming\n  sense of regret."
            encounter.enemies[1].canSpare = true
            encounter.enemies[1].canDodge = false
            encounter.enemies[1].showHPBar = true
            encounter.enemies[1].defense = -99
            encounter.enemies[1].description = "* Devoid of anything without\n  their friend."
            encounter.enemies[1].acts = {}
        end
    end

    data.onSpare = function(enemy)
        if enemy == 1 then
            battle.turnCount = 1
            encounter.attacks = {}
            encounter.attacks[1] = {
                boxDims = {
                    x = math.floor(320 - 135/2),
                    y = 253,
                    width = 135,
                    height = 135
                },
                dialogue = {
                    {
                        speaker = 2,
                        text = "this is cool i\nguess",
                        bubbleDirection = "left",
                        bubbleOffset = 0,
                        font = fonts.dialogue,
                        voice = data.voices.default
                    }
                },
                init = function()
                    -- Init attack stuff (don't worry about this)
                    attackTimer = 0
                    timeSince = 0
                    bullets = {}
                    player.mode = 2
                    -- Everything below this is your custom code
                end,
                update = function(dt)
                    -- Update attack stuff (don't worry about this)
                    timeSince = timeSince + 1 * dt*30
                    if timeSince >= 1 then
                        attackTimer = attackTimer + 1
                        timeSince = 0
                    end

                    local i = 1 -- here to remove bullets
                    for _, bullet in ipairs(bullets) do
                        bullet:update(dt)
                        if bullet.remove then
                            table.remove(bullets, i)
                        end
                        i = i + 1
                    end
                    -- Everything below this is your custom code

                    if attackTimer == 15 then
                        ui.goToMenu()
                        bullets = {}
                    end
                end,
                draw = function()
                end
            }
            encounter.text = "* Enemy 2 is filled with\n  conptemtness."
            encounter.enemies[2].canSpare = true
            encounter.enemies[2].canDodge = false
            encounter.enemies[2].showHPBar = true
            encounter.enemies[2].acts = {}

        elseif enemy == 2 then
            battle.turnCount = 1
            encounter.attacks = {
                {
                    boxDims = {
                        x = math.floor(320 - 135/2),
                        y = 253,
                        width = 135,
                        height = 135
                    },
                    dialogue = {
                        {
                            speaker = 1,
                            text = ":-) !!",
                            bubbleDirection = "right",
                            bubbleOffset = 125,
                            font = fonts.dialogue,
                            voice = data.voices.default
                        }
                    },
                    init = function()
                        -- Init attack stuff (don't worry about this)
                        attackTimer = 0
                        timeSince = 0
                        bullets = {}
                        player.mode = 2
                        -- Everything below this is your custom code
                    end,
                    update = function(dt)
                        -- Update attack stuff (don't worry about this)
                        timeSince = timeSince + 1 * dt*30
                        if timeSince >= 1 then
                            attackTimer = attackTimer + 1
                            timeSince = 0
                        end

                        local i = 1 -- here to remove bullets
                        for _, bullet in ipairs(bullets) do
                            bullet:update(dt)
                            if bullet.remove then
                                table.remove(bullets, i)
                            end
                            i = i + 1
                        end
                        -- Everything below this is your custom code

                        if attackTimer == 15 then
                            ui.goToMenu()
                            bullets = {}
                        end
                    end,
                    draw = function()
                    end
                    }
                }
            encounter.text = "[clear]* Enemy 1 is enjoying themself."
            encounter.enemies[1].canSpare = true
            encounter.enemies[1].canDodge = false
            encounter.enemies[1].showHPBar = true
            encounter.enemies[1].acts = {}
        end
    end
    
end