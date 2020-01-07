-- Shake.lua
-- Created by sujl, Nov/15/2016

local Shake = class("CharAction", function()
    return cc.Node:create()
end)

local RAND_MAX = 0x7fff

function Shake:ctor(target, duration, strength)
    self.target = target
    self.startX, self.startY = target:getPosition()

    if duration and strength then
        self:initWithStrength(duration, strength)
    end
end

function Shake:initWithStrength(duration, strength)
    self.duration = duration
    if 'table' == strength then
        self.strengthX = strength.x
        self.strengthY = strength.y
    else
        self.strengthX, self.strengthY = tonumber(strength) or 1, tonumber(strength) or 1
    end

    if tonumber(duration) and tonumber(duration) > 0 then
        self.finishTime = gfGetTickCount() + tonumber(duration) * 1000
    else
        self.finishTime = 0
    end

    self.tPosX, self.tPosY = self.target:getPosition()

    local function onNodeEvent(event)
        if Const.NODE_CLEANUP == event then
            self:onNodeCleanup()
        end
    end

    self:registerScriptHandler(onNodeEvent)

    self.updateAction = schedule(self, function() self:update() end, 0)
end

local function fgRangeRand(min, max)
    return math.random(min, max)
end

function Shake:update()
    if not self.target then return end

    if 0~= self.finishTime and gfGetTickCount() > self.finishTime then
        self.target:stopAction(self.updateAction)
    end

    local posX = self.startX + fgRangeRand(-self.strengthX, self.strengthX)
    local posY = self.startY + fgRangeRand(-self.strengthY, self.strengthY)

    self.target:setPosition(posX, posY)
end

function Shake:onNodeCleanup()
    self.target:setPosition(self.tPosX, self.tPosY)
end

return Shake