Bullet = {}
Bullet.__index = Bullet

local bulletImage = love.graphics.newImage('encounters/Test enemies/images/bullet.png')

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function Bullet:create(x, y, xvel, yvel, xscale, yscale, color, isMasked, damage)
    local bullet = setmetatable({}, Bullet)
    bullet.x = x
    bullet.y = y
    bullet.xvel = xvel
    bullet.yvel = yvel
    bullet.xscale = xscale
    bullet.yscale = yscale
    bullet.color = color
    bullet.isMasked = isMasked
    bullet.damage = damage
    bullet.remove = false
    return bullet
end

function Bullet:update(dt)
    self.x = self.x + self.xvel * dt*30
    self.y = self.y + self.yvel * dt*30

    if CheckCollision(self.x, self.y, 16*self.xscale, 16*self.yscale, player.heart.x+conf.hitboxLenience, player.heart.y+conf.hitboxLenience, 16 - conf.hitboxLenience*2, 16 - conf.hitboxLenience*2) then
        if (self.color == 'orange' and not player.isMoving) or (self.color == 'blue' and player.isMoving) or self.color == 'white' then
            if not player.hasKR then
                local lasthp = player.stats.hp
                player.hurt(self.damage)
                self.remove = lasthp ~= player.stats.hp
            else
                player.hurt(self.damage)
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
                love.graphics.setColor(0, 162 / 255, 232 / 255)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.draw(bulletImage, self.x, self.y, 0, self.xscale, self.yscale)
        love.graphics.setStencilTest()
    else
        if self.color == 'orange' then
            love.graphics.setColor(1, 0.5, 0)
        elseif self.color == 'blue' then
            love.graphics.setColor(0, 162 / 255, 232 / 255)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.draw(bulletImage, self.x, self.y, 0, self.xscale, self.yscale)
    end
end

return Bullet