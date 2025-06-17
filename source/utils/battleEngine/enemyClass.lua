local Enemy = {}
Enemy.__index = Enemy

function Enemy:new(config)
    local self = setmetatable({}, Enemy)

    self.name = config.name or "Unknown"
    self.description = config.description or ""
    self.acts = config.acts or {}

    self.canSpare = config.canSpare or false
    self.showHPBar = config.showHPBar or false
    self.canDodge = config.canDodge or false

    self.hp = config.hp or 0
    self.maxHp = config.maxHp or 0
    self.attack = config.attack or 0
    self.defense = config.defense or 0

    self.image = love.graphics.newImage(config.imagePath)
    self.imageScale = config.imageScale
    self.x = config.x or 0
    self.y = config.y or 0
    self.xOffset = 0
    self.yOffset = 0

    for _, act in ipairs(self.acts) do
        act.enemy = self
    end

    return self
end

function Enemy:draw()
    love.graphics.draw(
        self.image,
        self.x + self.xOffset,
        self.y + self.yOffset,
        0, self.imageScale
    )
end

function Enemy:update(dt)
    for _, attack in ipairs(self.attacks) do
        if type(attack.update) == "function" then
            attack:update(dt)
        end
    end
end

return Enemy