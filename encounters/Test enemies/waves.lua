-- Don't edit these!
-- encounter. is being used instead of data. because the enemy data has already been loaded by the encounter handler when these functions are called!
local timeSince = 0
local bullets = {}
local attackTimer = 0

function wavesSetup(data)
    local exampleBullet = require(data.encounterPath .. 'bullets/example')

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
                    font = fonts.dialogue,
                    voice = data.voices.default
                },
                {
                    speaker = 1,
                    text = "how we doin today",
                    bubbleDirection = "right",
                    bubbleOffset = 125,
                    font = fonts.sans,
                    voice = data.voices.sans
                },
                {
                    speaker = 2,
                    text = "SHUT YOUR FUCKING\nMOUTH!!!!!",
                    bubbleDirection = "left",
                    bubbleOffset = 0,
                    font = fonts.papyrus,
                    voice = data.voices.papyrus
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

                for i = #bullets, 1, -1 do
                    local bullet = bullets[i]
                    bullet:update(dt)
                    if bullet.remove then
                        table.remove(bullets, i)
                    end
                end
                -- Everything below this is your custom code

                if attackTimer == 15 then
                    table.insert(
                        bullets,
                        exampleBullet:create(231, 312, 4, 0, 1, 1, "white", true, 2)
                    )
                    table.insert(
                        bullets,
                        exampleBullet:create(312 + (312 - 231), 312, -4, 0, 1, 1, "white", true, 2)
                    )
                    table.insert(
                        bullets,
                        exampleBullet:create(312, 253-24, 0, 4, 1, 1, "white", true, 2)
                    )
                    table.insert(
                        bullets,
                        exampleBullet:create(312, 253 + 135 + 8, 0, -4, 1, 1, "white", true, 2)
                    )
                    attackTimer = 16    -- Prevents multiple insances of an attack at once
                end
                if attackTimer == 30 then
                    for i=1, 16 do
                        table.insert(
                            bullets,
                            exampleBullet:create(231 + i*17, 253 + 135 + 8, 0, -4, 1, 1, "orange", true, 2)
                        )
                    end
                    for i=1, 16 do
                        table.insert(
                            bullets,
                            exampleBullet:create(231 + i*17, 253 - 24, 0, 4, 1, 1, "blue", true, 2)
                        )
                    end
                    table.insert(
                        bullets,
                        exampleBullet:create(231, 253-24, 4, 4, 1, 1, "white", true, 2)
                    )
                    table.insert(
                        bullets,
                        exampleBullet:create(312 + (312 - 231), 253-24, -4, 4, 1, 1, "white", true, 2)
                    )
                    table.insert(
                        bullets,
                        exampleBullet:create(312, 253 + 135 + 8, 0, -4, 1, 1, "white", true, 2)
                    )
                    attackTimer = 31
                end

                if attackTimer == 70 then
                    ui.goToMenu()
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
                    font = fonts.dialogue,
                    voice = data.voices.default
                },
                {
                    speaker = 2,
                    text = "shut up",
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

                for i = #bullets, 1, -1 do
                    local bullet = bullets[i]
                    bullet:update(dt)
                    if bullet.remove then
                        table.remove(bullets, i)
                    end
                end

                -- Everything below this is your custom code

                if attackTimer == 25 then
                    local rand = love.math.random(1, 6)
                    for i=1, 6 do
                        if i ~= rand then
                            table.insert(
                                bullets,
                                exampleBullet:create(184 + i*34, 187, 0, 4, 2, 1, "white", true, 2)
                            )
                            attackTimer = 26
                        end
                    end
                end

                if attackTimer == 50 then
                    local rand = love.math.random(1, 6)
                    for i=1, 6 do
                        if i ~= rand then
                            table.insert(
                                bullets,
                                exampleBullet:create(184 + i*34, 187, 0, 4, 2, 1, "white", true, 2)
                            )
                            attackTimer = 51
                        end
                    end
                end
        
                if attackTimer == 75 then
                    local rand = love.math.random(1, 6)
                    for i=1, 6 do
                        if i ~= rand then
                            table.insert(
                                bullets,
                                exampleBullet:create(184 + i*34, 187, 0, 4, 2, 1, "white", true, 2)
                            )
                            attackTimer = 76
                        end
                    end
                end

                if attackTimer == 100 then
                    local rand = love.math.random(1, 6)
                    for i=1, 6 do
                        if i ~= rand then
                            table.insert(
                                bullets,
                                exampleBullet:create(184 + i*34, 187, 0, 4, 2, 1, "white", true, 2)
                            )
                            attackTimer = 101
                        end
                    end
                end

                if attackTimer == 130 then
                    ui.goToMenu()
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
end