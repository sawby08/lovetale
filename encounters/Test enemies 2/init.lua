local data = {}

data.encounterPath = "encounters/Test enemies 2/" -- Makes it less annoying to call for files within the encounter directory
data.text = {
    "[clear]* The other test enemies draw near."
}
data.startFirst = false
data.canFlee = true
data.encounterType = 'random'
data.bgmPath = "sound/mus_strongermonsters.ogg"
data.backgroundImagePath = "images/backgrounds/spr_battlebg_1.png"
data.backgroundColor = {0, 0, 0}
--                                                                              |
data.voices = {     -- Located in sound/voices                                  v   edit this
    default = love.audio.newSource(data.encounterPath .. 'sound/voices/' .. 'monster.wav', 'static'),
    papyrus = love.audio.newSource(data.encounterPath .. 'sound/voices/' .. 'papyrus.wav', 'static'),
    sans = love.audio.newSource(data.encounterPath  .. 'sound/voices/' .. 'sans.wav', 'static')
}

require(data.encounterPath .. 'events')
require(data.encounterPath .. 'waves')

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

----==== CALL STUFF FROM OTHER FILES ====----
wavesSetup(data)
eventsSetup(data)

----==== PLAYER CONFIGURATION ====----
data.playerLove = 1
data.playerName = "Sawby"
data.playerInventory = {11, 1, 1, 23, 17, 19, 19, 52}
data.playerHasKR = false
data.playerWeapon = 3   -- Use ID from the item manager
data.playerArmor = 4    -- Use ID from the item manager
data.playerInvFrames = 15

return data