local data = {}
local timeSince = 0 -- Don't edit this

data.encounterPath = "encounters/Test sans/" -- Makes it less annoying to call for files within the encounter directory
data.text = {
    "[clear]* You feel like you're going to\n  have a bad time."
}
data.startFirst = true
data.canFlee = false
data.encounterType = 'random'
data.bgmPath = nil
data.backgroundImagePath = nil
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
        x = 265,
        y = 34,
        dodgeOffset = -100,

        -----==== ACTS ====----
        acts = {},

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
                text = "heya.",
                bubbleDirection = "right",
                bubbleOffset = 125
            },
            {
                speaker = 1,
                text = "i don't know what to\nwrite here yet i need\nto code the bullets\nfirst",
                bubbleDirection = "right",
                bubbleOffset = 125
            }
        },
        init = function()
            -- Init attack stuff (don't worry about this and don't remove it)
            attackTimer = 0
            timeSince = 0
            bullets = {}
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

            --[[
            if attackTimer == 70 then
                local battleEngine = require 'source.battleEngineState'
                battleEngine.changeBattleState('buttons', 'player')
                bullets = {}
                if not encounter.bgm then
                    encounter.bgm = love.audio.newSource(data.encounterPath .. "/sound/mus_megalovania.ogg", "stream")
                end
            end
            ]]
        end,
        draw = function()
            -- Draw attack stuff (don't worry about this and don't remove it)
            for _, bullet in ipairs(bullets) do
                bullet:draw()
            end
            -- Everything below this is your custom code

        end
    }
}

data.onDeath = function(enemy)       -- Function that's run when an enemy dies (enemy is the enemy that's dead)

end

data.onSpare = function(enemy)

end


data.playerLove = 19
data.playerName = "chara"
data.playerInventory = {11, 1, 1, 23, 17, 19, 19, 52}
data.playerHasKR = true
data.playerWeapon = 3   -- Use ID from the item manager
data.playerArmor = 4    -- Use ID from the item manager
data.playerInvFrames = 15

return data