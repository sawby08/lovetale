local data = {}


data.encounterPath = "encounters/Test enemies/" -- Makes it less annoying to call for files within the encounter directory
data.text = {
    "[clear]* The test enemies draw near.",
    "[clear]* [red][shake]Lorem [green][wave]ipsum [clear][blue]dolar[clear].",
    "[clear][rainbow]* Happy pride month!"
}
data.startFirst = false
data.canFlee = true
data.encounterType = 'random'
data.bgmPath = "sound/mus_strongermonsters.ogg"
data.backgroundImagePath = "images/backgrounds/spr_battlebg_1.png"
data.backgroundColor = {0, 0, 0}


data.enemyData = {
    {
        ----==== BASIC INFORMATION ====----
        name = "Enemy 1",
        description = "[clear]* The first half of the test\n  site.",
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

        -----==== ACTS ====----
        acts = {
            {
                name = 'Talk',
                execute = function(self)
                   if not self.enemy.canDodge then
                    self.enemy.canSpare = true
                    self.enemy.acts[1].text[1] = "* You and Enemy 1 have a nice[break]  conversation."
                    self.enemy.acts[1].text[2] = "* You two get along!     [break]* Enemy 1 is sparing you."
                   end
                end,
                text = {
                    "* You try to talk to it but it\n  didn't respond."
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

----==== ATTACK BOX POSITIONS ====----
data.attacks = {
    {
        boxDims = {
            x = math.floor(320 - 135/2),
            y = 253,
            width = 135,
            height = 135
        }
    },

    {
        boxDims = {
            x = math.floor(320 - 200/2),
            y = 203,
            width = 200,
            height = 185
        }
    }
}

data.playerLove = 1
data.playerName = "Sawby"
data.playerInventory = {11, 1, 1, 23, 17, 19, 19, 52}
data.playerHasKR = false
data.playerWeapon = 3   -- Use ID from the item manager
data.playerArmor = 4    -- Use ID from the item manager

return data