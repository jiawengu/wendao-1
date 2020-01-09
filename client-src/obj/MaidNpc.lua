-- MaidNpc.lua
-- Created by sujl, Sept/7/2017
-- 丫鬟NPC

local Npc = require("obj/Npc")
local MaidNpc = class("MaidNpc", Npc)
local STATE1_SHOW_TIMES = 6

function MaidNpc:init()
    Npc.init(self)
    self.curState = 0
end

-- 进入场景
function MaidNpc:onEnterScene(x, y)
    Npc.onEnterScene(self, x, y)
    self.basePos = cc.p(x, y)
    performWithDelay(self.middleLayer, function()
        self.curState = math.random(1)
        self:doAction()
    end, 0)

    EventDispatcher:addEventListener("PUT_FURNITURE", self.doSomeWhenPutFurn, self)
end

function MaidNpc:onExitScene(x, y)
    Npc.onExitScene(self, x, y)

    EventDispatcher:removeEventListener("PUT_FURNITURE", self.doSomeWhenPutFurn, self)
end

function MaidNpc:doSomeWhenPutFurn()
    local curX, curY = self.curX, self.curY
    if GObstacle:Instance():IsObstacle(gf:convertToMapSpace(curX, curY)) then
        -- 如果处于障碍点，则进行移位
        curX, curY = gf:convertToMapSpace(curX, curY)
        local curPos = GObstacle:Instance():GetNearestPos(curX, curY)
        if 0 ~= curPos then
            curX, curY = math.floor(curPos / 1000), curPos % 1000
        end

        self:setLastMapPos(curX, curY)
        self:setPos(gf:convertToClientSpace(curX, curY))
        self:setAct(Const.FA_STAND)
    elseif self:isWalkAction() and self.endX and self.endY then
        -- 重新生成路径信息，防止对象走到家具上
        local mapX, mapY = gf:convertToMapSpace(self.endX, self.endY)
        self:setEndPos(mapX, mapY)
    end
end

-- 随机动作
function MaidNpc:randomAct()
    local expired_time = self:queryBasicInt("expired_time")
    local hireTime = expired_time - gf:getServerTime()
    local v

    if hireTime <= 0 then
        v = gf:weightRandom({100, 0})
    else
        v = gf:weightRandom({30, 70})
    end

    if 1 == v then return Const.SA_STAND
    elseif 2 == v then return Const.SA_CLEAN
    end
end

-- 设置动作
function MaidNpc:setAct(act)
    if self.faAct ~= act then
        Npc.setAct(self, act)
    end
    --[[
    if act == Const.SA_STAND and 1 == self.curState then
        self:playMove()
    end
    ]]
end

-- 播放动作
function MaidNpc:playAction(times)
    if 0 ~= self.curState then return end

    if self.charAction then
        self:setAct(Const.FA_STAND) -- 先切换为站立动作，避免playAction失效
        self.charAction:playAction(function()
            if times <= 0 then
                self.curState = (self.curState + 1) % 2
                self:doAction()
            end
            self:playAction(times - 1)
        end, self:randomAct(), 2)
    end
end

-- 播放移动
function MaidNpc:playMove()
    if 1 ~= self.curState then return end
    local dest = cc.p(self.basePos.x + math.random(-5, 5), self.basePos.y + math.random(-5, 5))
    self:setEndPos(dest.x, dest.y)

    -- 每隔4s随机选择下一个坐标点
    performWithDelay(self.middleLayer, function() self:playMove() end, 4)
end

-- 状态管理
function MaidNpc:doAction()
    if 0 == self.curState then
        -- 状态1
        self:playAction(STATE1_SHOW_TIMES)
    else
        -- 状态2
        self:playMove()
        performWithDelay(self.middleLayer, function()
            self.curState = (self.curState + 1) % 2
            self:doAction()
        end, 8)
    end
end

return MaidNpc