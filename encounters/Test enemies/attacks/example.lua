Bullet = {}
Bullet.__index = Bullet

local bulletImage = love.graphics.newImage('encounters/Test enemies/images/bullet.png')

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function Bullet:create(x, y, xvel, yvel, color, isMasked)
    local bullet = setmetatable({}, Bullet)
    bullet.x = x
    bullet.y = y
    bullet.xvel = xvel
    bullet.yvel = yvel
    bullet.color = color
    bullet.isMasked = isMasked
    return bullet
end

function Bullet:update(dt)
    self.x = self.x + self.xvel * dt*30
    self.y = self.y + self.yvel * dt*30

    if CheckCollision(self.x, self.y, 16, 16, player.heart.x+player.hitboxLenience, player.heart.y+player.hitboxLenience, 16 - player.hitboxLenience*2, 16 - player.hitboxLenience*2) then
        if (self.color == 'orange' and not player.isMoving) or (self.color == 'blue' and player.isMoving) or self.color == 'white' then
            camera:shake(1, 1)
            if not player.hasKR then
                self.remove = true
                player.hurt()
            end
        end
    end
end

function Bullet:draw()
    if self.isMasked then
        local function stencilFunction()
            love.graphics.push()
                love.graphics.translate(ui.box.x + 2.5, ui.box.y + 2.5)
                love.graphics.rectangle('fill', 0, 0, ui.box.width - 5, ui.box.height - 5)
            love.graphics.pop()
        end

        love.graphics.stencil(stencilFunction, 'replace', 1)
        
        love.graphics.setStencilTest('equal', 1)
            if self.color == 'orange' then
                love.graphics.setColor(1, 0.5, 0)
            elseif self.color == 'blue' then
                love.graphics.setColor(0.25, 0.25, 1)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.draw(bulletImage, self.x, self.y)
        love.graphics.setStencilTest()
    else
        if self.color == 'orange' then
            love.graphics.setColor(1, 0.5, 0)
        elseif self.color == 'blue' then
            love.graphics.setColor(0.25, 0.25, 1)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.draw(bulletImage, self.x, self.y)
    end
end

return Bullet