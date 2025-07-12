local gameover = {}
local playerx, playery

function gameover.load(x, y)
    love.audio.stop()
    sfx.hurt:play()
    playerx = x
    playery = y
end

function gameover.update(dt)
    if input.check('confirm', 'pressed') then
        sceneman.switchScene('battleEngineState', 'Test enemies')
    end
end

function gameover.draw()
    love.graphics.setFont(fonts.main)
    love.graphics.print("YOU SUCK AT THIS GAME!!!!\npress z to try again")
end

return gameover