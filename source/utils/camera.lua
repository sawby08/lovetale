-- camera.lua
local Camera = {}
Camera.__index = Camera

yourCanvasName = love.graphics.newCanvas(640, 480)
yourCanvasName:setFilter('nearest', 'nearest')

function Camera.new(width, height)
    local self = setmetatable({}, Camera)
    self.width = width
    self.height = height
    self.scale = 1
    self.zoom = 1
    self.x = 0
    self.y = 0
    self.rotation = 0
    self.shakeAmountX = 0 
    self.shakeAmountY = 0 
    self.shakeOffsetX = 0
    self.shakeOffsetY = 0
    return self
end

function Camera:update(dt)
    local shakeScale = love.graphics.getWidth() / self.width
    
    if self.shakeAmountX > 0 then
        self.shakeOffsetX = math.random(-self.shakeAmountX * shakeScale, self.shakeAmountX * shakeScale)
        self.shakeAmountX = self.shakeAmountX - dt * 10
        if self.shakeAmountX < 0 then
            self.shakeAmountX = 0
        end
    else
        self.shakeOffsetX = 0
    end
    
    if self.shakeAmountY > 0 then
        self.shakeOffsetY = math.random(-self.shakeAmountY * shakeScale, self.shakeAmountY * shakeScale)
        self.shakeAmountY = self.shakeAmountY - dt * 10
        if self.shakeAmountY < 0 then
            self.shakeAmountY = 0
        end
    else
        self.shakeOffsetY = 0
    end

end

function Camera:shake(amountX, amountY)
    self.shakeAmountX = math.max(self.shakeAmountX, amountX)
    self.shakeAmountY = math.max(self.shakeAmountY, amountY)
end

function Camera:attachLetterBox()
    love.graphics.setCanvas({yourCanvasName, stencil=true})
    love.graphics.clear()
end

function Camera:detachLetterBox()
    love.graphics.setCanvas()
    local border_exists = 0
    if border then
        border_exists = 1
    end

    if love.window.getFullscreen() then
        local screenW, screenH = love.graphics.getDimensions()
        local canvasW, canvasH = yourCanvasName:getDimensions()
        local scale = math.min(screenW / canvasW, screenH / canvasH) * (conf.useBorders and 0.89 or 1)
        local offsetX = math.floor((screenW - canvasW * scale) / 2)
        local offsetY = math.floor((screenH - canvasH * scale) / 2)

        love.graphics.push()
        love.graphics.translate(offsetX, offsetY)
        love.graphics.scale(scale, scale)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(yourCanvasName, 0, 0)
        love.graphics.pop()
    else
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(yourCanvasName, 0, 0)
    end
end

function Camera:apply()
    local shakeX = self.shakeOffsetX
    local shakeY = self.shakeOffsetY

    local cx = self.width / 2
    local cy = self.height / 2

    love.graphics.push()
    love.graphics.translate(cx, cy)
    love.graphics.scale(self.zoom)
    love.graphics.rotate(self.rotation)
    love.graphics.translate(-cx + self.x + shakeX, -cy + self.y + shakeY) -- Move world relative to center
end

function Camera:reset()
    love.graphics.pop()
end

function Camera:move(x, y)
    self.x = self.x + x
    self.y = self.y + y
end

function Camera:set(x, y)
    self.x = x
    self.y = y
end

function Camera:setRotation(rotation)
    self.rotation = rotation
end

function Camera:setZoom(zoom)
    self.zoom = zoom
end

function Camera:getRotation()
    return self.rotation
end

function Camera:getPosition()
    return self.x, self.y
end

function Camera:getZoom()
    return self.zoom
end

return Camera
