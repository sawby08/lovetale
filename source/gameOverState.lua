local gameover = {}

function gameover.load()

end

function gameover.update(dt)
    if input.check('confirm', 'pressed') then
        currentScene = scenes.battleEngine
        love.load()
    end
end

function gameover.draw()
    love.graphics.setFont(fonts.main)
    love.graphics.print("YOU SUCK AT THIS GAME!!!!\npress z to try again")
end

return gameover