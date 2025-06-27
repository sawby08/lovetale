local data = {}

data.encounterPath = "encounters/Test enemies/" -- Makes it less annoying to call for files within the encounter directory

data.text = {
    "[clear]* The test enemies draw near.",
    "[clear]* [red][shake]Lorem [green][wave]ipsum [clear][blue]dolar[clear].",
    "[clear][rainbow]* Happy pride month!"
}
data.startFirst = false
data.canFlee = true
data.encounterType = 'random' -- Can either be 'random' (ex. Froggit) or 'countTurns' (ex. Sans)
--                               Nothing requires me to implement these yet this is just futureproofing
data.bgmPath = "sound/mus_strongermonsters.ogg"
data.backgroundImagePath = "images/backgrounds/spr_battlebg_1.png"
data.backgroundColor = {0, 0, 0}

data.enemyData = {
    {
        name = "Enemy 1",
        description = "[clear]* The first half of the test\n  site.",
        status = "alive",
        acts = {
            {
                name = 'Talk',
                execute = function(self)
                    -- Nothing
                end,
                text = {
                    "* You try to talk to it but it\n  didn't respond."
                }
            },
            {
                name = 'Pose',
                execute = function(self)
                    if self.enemy.defense < 7 then
                        self.enemy.defense = self.enemy.defense + 2
                    else -- Act exhaust
                        self.enemy.acts[2].text = {
                            "* You try putting your fists up\n  again.",
                            "* Enemy 1 doesn't seem to be\n  interested anymore."
                        }
                    end
                end,
                text = {
                    '[clear]* You put your fists up\n  defensively.',
                    "[clear]* Enemy 1 joins in.     \n* Enemy 1's DEF increased by 2!"
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
        canSpare = true,
        showHPBar = false,
        canDodge = true,

        hp = 80,
        maxHp = 80,
        attack = 2,
        defense = 5,

        x = 145,
        y = 34,
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
        name = "Enemy 2",
        description = "[clear]* The other half of the test\n  site.",
        status = "alive",
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
        canSpare = false,
        showHPBar = true,
        canDodge = false,

        hp = 100,
        maxHp = 100,
        attack = 2,
        defense = 2,

        x = 345,
        y = 140,
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

data.attacks = {
    {
        boxDims = {
            x = math.floor(320 - 135/2),
            y = 253,
            width = 135,
            height = 135
        },
        init = function()

        end,
        update = function(dt)
            if input.check('menu', 'pressed') then
                local battleEngine = require 'source.battleEngineState'
                input.refresh()
                battleEngine.changeBattleState('buttons', 'player')
            end
            if love.keyboard.isDown('1') then
                player.mode = 1
            elseif love.keyboard.isDown('2') then
                player.mode = 2
            end
        end,
        draw = function()
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Press C/CTRL to go back to the menu\nPress 1 to use red soul\nPress 2 to use blue soul\nVariation 1")
        end
    },

    {
        boxDims = {
            x = math.floor(320 - 200/2),
            y = 203,
            width = 200,
            height = 185
        },
        init = function()

        end,
        update = function(dt)
            if input.check('menu', 'pressed') then
                local battleEngine = require 'source.battleEngineState'
                input.refresh()
                battleEngine.changeBattleState('buttons', 'player')
            end
            if love.keyboard.isDown('1') then
                player.mode = 1
            elseif love.keyboard.isDown('2') then
                player.mode = 2
            end
        end,
        draw = function()
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Press C/CTRL to go back to the menu\nPress 1 to use red soul\nPress 2 to use blue soul\nVariation 2")
        end
    }
}

data.playerLove = 1
data.playerName = "Sawby"
data.playerInventory = {11, 1, 1, 23, 17, 19, 19, 52}
data.playerHasKR = false
data.playerWeapon = 3   -- Use ID from the item manager
data.playerArmor = 4    -- Use ID from the item manager

return data