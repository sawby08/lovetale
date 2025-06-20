local Enemy = {}
Enemy.__index = Enemy

function Enemy:new(config)
    local self = setmetatable({}, Enemy)

    self.name = config.name or "Unknown"
    self.description = config.description or ""
    self.acts = config.acts or {}
    self.status = config.status or "alive"

    self.canSpare = config.canSpare or false
    self.showHPBar = config.showHPBar or false
    self.canDodge = config.canDodge or false

    self.hp = config.hp or 0
    self.maxHp = config.maxHp or 0
    self.attack = config.attack or 0
    self.defense = config.defense or 0

    self.segments = {}

    local segmentConfigs = config.segments
    if not segmentConfigs[1] then
        segmentConfigs = { segmentConfigs }
    end

    for _, segmentConfig in ipairs(segmentConfigs) do
        local segment = {
            image = love.graphics.newImage(segmentConfig.imagePath),
            color = segmentConfig.color or {1, 1, 1},
            imageScale = segmentConfig.imageScale or 1,
            x = segmentConfig.x or 0,
            y = segmentConfig.y or 0,
            xOffset = segmentConfig.xOffset or 0,
            yOffset = segmentConfig.yOffset or 0,
            animation = segmentConfig.animation or function() end
        }

        table.insert(self.segments, segment)
    end


    for _, act in ipairs(self.acts) do
        act.enemy = self
    end

    return self
end

function Enemy:draw()
    for _, segment in ipairs(self.segments) do
        segment.animation(self, segment)
        love.graphics.setColor(segment.color)
        love.graphics.draw(
            segment.image,
            segment.x + (segment.xOffset or 0),
            segment.y + (segment.yOffset or 0),
            0,
            segment.imageScale or 1,
            segment.imageScale or 1
        )
    end
end

function Enemy:update(dt)
    
end

return Enemy