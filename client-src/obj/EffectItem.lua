-- EffectItem.lua
-- Created by lixh Jan/16/2019
-- 场景中移动的物体(可绑定图片、动画、光效)

local Item = require("obj/Item")

local EffectItem = class("EffectItem", Item)

function EffectItem:init(x, y)
    self:onEnterScene(x, y)
    self.inMoveAction = false
    self.speed = 2
    self.speedPercent = 100
end

function EffectItem:getSpeed()
    return self.speed * self.speedPercent / 100
end

-- 速度，相对与地图每帧移动的距离
function EffectItem:setSpeed(speed)
    self.speed = speed
end

-- 速度百分比
function EffectItem:setSpeedPercent(percent)
    self.speedPercent = percent
end

function EffectItem:addImage(icon)
    local sprite = cc.Sprite:create(icon)
    if sprite then
        self:addToTopLayer(sprite)
        self.image = sprite

        local sz = sprite:getTexture():getContentSize()
        self.width = sz.width
        self.height = sz.height

        return sprite
    end
end

function EffectItem:addMagic(icon)
    local magic = gf:createLoopMagic(icon)
    if magic then
        self:addToTopLayer(magic)
        self.magic = magic

        return magic
    end
end

function EffectItem:updatePos()
    if self.inMoveAction then
        local nextX = self:getNextStep(self.curX, self.tarX, self.speedX)
        local nextY = self:getNextStep(self.curY, self.tarY, self.speedY)
        if nextX == self.curX and nextY == self.curY then
            self.inMoveAction = false
        else
            self:setPos(nextX, nextY)
        end
    end
end

function EffectItem:update()
    self:updatePos()
end

function EffectItem:getNextStep(cur, tar, speed)
    local next = cur
    if cur ~= tar then
        if cur < tar then
            if cur + speed < tar then
                next = cur + speed
            end
        elseif cur > tar then
            if cur - speed > tar then
                next = cur - speed
            end
        end
    end

    return next
end

function EffectItem:moveTo(x, y)
    self.tarX, self.tarY = x, y
    local distance = gf:distance(self.curX, self.curY, self.tarX, self.tarY)
    local ticks = distance / self:getSpeed()
    self.speedX = math.abs((self.tarX - self.curX) / ticks)
    self.speedY = math.abs((self.tarY - self.curY) / ticks)
    self.inMoveAction = true
end

return EffectItem
