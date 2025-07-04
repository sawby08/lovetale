local data = {}
local timeSince = 0 -- Don't edit this

data.encounterPath = "encounters/Test enemies/" -- Makes it less annoying to call for files within the encounter directory
data.text = {
    "[clear]* The test enemies draw near.",
    "[clear]* [red][shake]Lorem [green][wave]ipsum [clear][blue]dolar[clear].",
    "[clear]* I'm not sure what would be funny[break]  to put here so I'm just writing[break]  this out to fill out the empty[break]  space do you like how it's masked"
}
data.startFirst = false
data.canFlee = true
data.encounterType = 'random'
data.bgmPath = "sound/mus_strongermonsters.ogg"
data.backgroundImagePath = "images/backgrounds/spr_battlebg_1.png"
data.backgroundColor = {0, 0, 0}

local exampleBullet = require(data.encounterPath .. 'bullets/example')
local bullets = {}
local attackTimer = 0

data.enemyData = {
    {
        ----==== BASIC INFORMATION ====----
        name = "Enemy 1",
        description = "[clear]* Freakishly tall.",
        status = "alive",
        canSpare = false,
        showHPBar = false,
        canDodge = true,
        hp = 50,
        maxHp = 50,
        attack = 1,
        defense = 2,
        x = 145,
        y = 34,
        dodgeOffset = -100,

        -----==== ACTS ====----
        acts = {
            {
                name = 'Talk',
                execute = function(self)
                   if not self.enemy.canDodge then
                    self.enemy.canSpare = true
                    self.enemy.acts[1].text[1] = "* You and Enemy 1 have a nice[break]  conversation."
                    self.enemy.acts[1].text[2] = "* You two get along!     [break]* Enemy 1 is sparing you."
                    encounter.attacks[1].dialogue[1].text = "i'm happy now :-)"
                    encounter.attacks[1].dialogue[2].text = "i'm happy now :-)"
                    encounter.attacks[2].dialogue[1].text = "i'm happy now :-)"
                   end
                end,
                text = {
                    "* You try to talk to them but\n  they don't respond."
                }
            },
            {
                name = 'Pose',
                execute = function(self)
                    if self.enemy.defense < 3 then
                        self.enemy.defense = self.enemy.defense + 1
                    else -- Act exhaust
                        self.enemy.acts[2].text = {
                            "* You try putting your fists up\n  again.",
                            "* They're already at their best[break]  defensive position."
                        }
                    end
                end,
                text = {
                    '[clear]* You put your fists up\n  defensively.',
                    "[clear]* Enemy 1 joins in.     \n* Enemy 1's DEF increased by 1!"
                }
            },
            {
                name = 'Command',
                execute = function(self)
                    self.enemy.canDodge = false
                    self.enemy.showHPBar = true
                end,
                text = {
                    '[clear]* You tell Enemy 1 to stop[break]  dodging.',
                    '[clear]* They comply!      [break]* Enemy 1 will not dodge any[break]  further attacks.'
                }
            }
        },

        doAnimation = true,
        ----==== ENEMY SPRITE SEGMENTS ====----
        segments = {
            imagePath = data.encounterPath .. "images/test1.png",
            color = {1, 1, 1},
            x = 0,
            y = 0,
            rotation = 0,
            xScale = 1,
            yScale = 1,
            xOrigin = 0,
            yOrigin = 0,
            animation = function(enemy, segment, dt)
                -- nothing
            end
        }
    },

    {
        ----==== BASIC INFORMATION ====----
        name = "Enemy 2",
        description = "[clear]* The other half of the test\n  site.",
        status = "alive",
        canSpare = false,
        showHPBar = true,
        canDodge = false,
        hp = 30,
        maxHp = 30,
        attack = 4,
        defense = 5,
        x = 345,
        y = 140,
        dodgeOffset = -100,

        -----==== ACTS ====----
        acts = {
            {
                name = 'Smile',
                execute = function(self)
                    self.enemy.canSpare = true
                end,
                text = {
                    "* You give Enemy 2 a cute smile.",
                    "* It didn't know what gesture\n  you made, but appreciated it\n  regardless."
                }
            }
        },

        doAnimation = true,
        ----==== ENEMY SPRITE SEGMENTS ====----
        segments = {
            {
            imagePath = data.encounterPath .. "images/test2.png",
            color = {1, 1, 1},
            x = 0,
            y = 0,
            rotation = 0,
            xScale = 1,
            yScale = 1,
            xOrigin = 0,
            yOrigin = 0,
            animation = function(enemy, segment, dt)
                local timer = love.timer.getTime()
                segment.y = (math.sin(timer * 2) * 14) - 7 * dt
            end
            }
        }
    }
}

----==== ATTACK BOX POSITIONS AND DIALOGUE ====----
data.attacks = {
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
                text = "hey lads",
                bubbleDirection = "right",
                bubbleOffset = 125,
                font = fonts.dialogue
            },
            {
                speaker = 1,
                text = "how we doin today",
                bubbleDirection = "right",
                bubbleOffset = 125,
                font = fonts.sans
            },
            {
                speaker = 2,
                text = "SHUT YOUR FUCKING\nMOUTH!!!!!",
                bubbleDirection = "left",
                bubbleOffset = 0,
                font = fonts.papyrus
            }
        },
        init = function()
            -- Init attack stuff (don't worry about this and don't remove it)
            attackTimer = 0
            timeSince = 0
            bullets = {}
            player.mode = 1
            -- Everything below this is your custom code
        end,
        update = function(dt)
            -- Update attack stuff (don't worry about this and don't remove it)
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
                table.insert(
                    bullets,
                    exampleBullet:create(231, 312, 4, 0, "white", true, 2)
                )
                table.insert(
                    bullets,
                    exampleBullet:create(312 + (312 - 231), 312, -4, 0, "white", true, 2)
                )
                table.insert(
                    bullets,
                    exampleBullet:create(312, 253-24, 0, 4, "white", true, 2)
                )
                table.insert(
                    bullets,
                    exampleBullet:create(312, 253 + 135 + 8, 0, -4, "white", true, 2)
                )
                attackTimer = 16    -- Prevents multiple insances of an attack at once
            end
            if attackTimer == 30 then
                for i=1, 16 do
                    table.insert(
                        bullets,
                        exampleBullet:create(231 + i*17, 253 + 135 + 8, 0, -4, "orange", true, 2)
                    )
                end
                for i=1, 16 do
                    table.insert(
                        bullets,
                        exampleBullet:create(231 + i*17, 253 - 24, 0, 4, "blue", true, 2)
                    )
                end
                table.insert(
                    bullets,
                    exampleBullet:create(231, 253-24, 4, 4, "white", true, 2)
                )
                table.insert(
                    bullets,
                    exampleBullet:create(312 + (312 - 231), 253-24, -4, 4, "white", true, 2)
                )
                table.insert(
                    bullets,
                    exampleBullet:create(312, 253 + 135 + 8, 0, -4, "white", true, 2)
                )
                attackTimer = 31
            end

            if attackTimer == 70 then
                local battleEngine = require 'source.battleEngineState'
                battleEngine.changeBattleState('buttons', 'player')
                bullets = {}
            end
        end,
        draw = function()
            -- Draw attack stuff (don't worry about this and don't remove it)
            for _, bullet in ipairs(bullets) do
                bullet:draw()
            end
        end
    },

    {
        boxDims = {
            x = math.floor(320 - 200/2),
            y = 203,
            width = 200,
            height = 185
        },
        dialogue = {
            {
                speaker = 1,        -- Enemy number from the enemies array
                text = "why are you saying\nsuch rude things\nto me",
                bubbleDirection = "right",
                bubbleOffset = 125,
                font = fonts.dialogue
            },
            {
                speaker = 2,
                text = "shut up",
                bubbleDirection = "left",
                bubbleOffset = 0,
                font = fonts.dialogue
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
                local rand1 = love.math.random(1, 12)
                local rand2 = love.math.random(1, 12)
                for i=1, 12 do
                    if i ~= rand1 and i ~= rand2 then
                        table.insert(
                            bullets,
                            exampleBullet:create(204 + i*17, 187, 0, 4, "white", true, 2)
                        )
                        attackTimer = 16
                    end
                end
            end

            if attackTimer == 30 then
                local rand1 = love.math.random(1, 12)
                local rand2 = love.math.random(1, 12)
                for i=1, 12 do
                    if i ~= rand1 and i ~= rand2 then
                        table.insert(
                            bullets,
                            exampleBullet:create(204 + i*17, 187, 0, 4, "white", true, 2)
                        )
                        attackTimer = 31
                    end
                end
            end

            if attackTimer == 45 then
                local rand1 = love.math.random(1, 12)
                local rand2 = love.math.random(1, 12)
                for i=1, 12 do
                    if i ~= rand1 and i ~= rand2 then
                        table.insert(
                            bullets,
                            exampleBullet:create(204 + i*17, 187, 0, 4, "white", true, 2)
                        )
                        attackTimer = 46
                    end
                end
            end

            if attackTimer == 60 then
                local rand1 = love.math.random(1, 12)
                local rand2 = love.math.random(1, 12)
                for i=1, 12 do
                    if i ~= rand1 and i ~= rand2 then
                        table.insert(
                            bullets,
                            exampleBullet:create(204 + i*17, 187, 0, 4, "white", true, 2)
                        )
                        attackTimer = 61
                    end
                end
            end

            if attackTimer == 100 then
                local battleEngine = require 'source.battleEngineState'
                battleEngine.changeBattleState('buttons', 'player')
                bullets = {}
            end
        end,
        draw = function()
            -- Draw attack stuff (don't worry about this)
            for _, bullet in ipairs(bullets) do
                bullet:draw()
            end
            -- Everything below this is your custom code
        end
    }
}

data.onDeath = function(enemy)       -- Function that's run when an enemy dies (enemy is the enemy that's dead)
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
                    text = "heh. i don't believe\nin you anymore..",
                    bubbleDirection = "left",
                    bubbleOffset = 0,
                    font = fonts.dialogue
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
                    local battleEngine = require 'source.battleEngineState'
                    battleEngine.changeBattleState('buttons', 'player')
                    bullets = {}
                end
            end,
            draw = function()
            end
        }
        encounter.text = "[clear]shut up dude"
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
                        font = fonts.dialogue
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
                        local battleEngine = require 'source.battleEngineState'
                        battleEngine.changeBattleState('buttons', 'player')
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
                    font = fonts.dialogue
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
                    local battleEngine = require 'source.battleEngineState'
                    battleEngine.changeBattleState('buttons', 'player')
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
                        font = fonts.dialogue
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
                        local battleEngine = require 'source.battleEngineState'
                        battleEngine.changeBattleState('buttons', 'player')
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


data.playerLove = 1
data.playerName = "Sawby"
data.playerInventory = {11, 1, 1, 23, 17, 19, 19, 52}
data.playerHasKR = false
data.playerWeapon = 3   -- Use ID from the item manager
data.playerArmor = 4    -- Use ID from the item manager
data.playerInvFrames = 15

return data