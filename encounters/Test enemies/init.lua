local data = {}


data.encounterPath = "encounters/Test enemies/"

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
        description = "[clear]* The first half of the test[break]  site.",
        acts = {
            {
                name = 'Talk',
                execute = function(self)
                    -- Nothing
                end,
                text = {
                    "* You try to talk to it but it[break]  didn't respond."
                }
            },
            {
                name = 'Pose',
                execute = function(self)
                    if self.enemy.defense < 7 then
                        self.enemy.defense = self.enemy.defense + 2
                    else -- Act exhaust
                        self.enemy.acts[2].text = {
                            "* You try putting your fists up[break]  again.",
                            "* Enemy 1 doesn't seem to be[break]  interested anymore."
                        }
                    end
                end,
                text = {
                    '[clear]* You put your fists up[break]  defensively.',
                    "[clear]* Enemy 1 joins in.     [break]* Enemy 1's DEF increased by 2!"
                }
            },
        },
        canSpare = false,
        showHPBar = true,
        canDodge = false,
        hp = 100,
        maxHp = 100,
        attack = 2,
        defense = 5,
        imagePath = data.encounterPath .. "images/test1.png",
        imageScale = 1,
        x = 145,
        y = 34,
        yOffset = 0,
        xOffset = 0
    },
    {
        name = "Enemy 2",
        description = "[clear]* The other half of the test[break]  site.",
        acts = {
            {
                name = 'Smile',
                execute = function(self)
                    self.enemy.canSpare = true
                end,
                text = {
                    "* You give Enemy 2 a cute smile.",
                    "* It didn't know what gesture[break]  you made, but appreciated it[break]  regardless."
                }
            }
        },
        canSpare = false,
        showHPBar = true,
        canDodge = false,
        hp = 50,
        maxHp = 50,
        attack = 2,
        defense = 2,
        imagePath = data.encounterPath .. "images/test2.png",
        imageScale = 1,
        x = 345,
        y = 140,
        yOffset = 0,
        xOffset = 0
    }
}

data.playerLove = 8
data.playerName = ": - ]"
if love.math.random(1, 10) == 1 then data.playerName = ": - 3" end
data.playerInventory = {11, 1, 1, 23, 17, 19, 19, 52}
data.playerHasKR = false
data.playerWeapon = 3   -- Use ID from the item manager
data.playerArmor = 4    -- Use ID from the item manager


return data