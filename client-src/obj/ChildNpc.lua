-- ChildNpc.lua
-- Created by sujl, Sept/7/2017
-- 居所娃娃

local Npc = require("obj/Npc")
local ChildNpc = class("ChildNpc", Npc)
local STATE1_SHOW_TIMES = 1

local CHILD_STATE_NORMAL            = 0 --
local CHILD_STATE_ILL               = 1                   -- 生病
local CHILD_STATE_SLEEPLESSNESS     = 2                   -- 失眠

function ChildNpc:init()
    Npc.init(self)
    self.curState = 0
end

-- 进入场景
function ChildNpc:onEnterScene(x, y)
    Npc.onEnterScene(self, x, y)
    self.basePos = cc.p(x, y)

    self:setSpeed()

    performWithDelay(self.middleLayer, function()
        self.curState = math.random(1)
        self:doAction()
    end, 0)

    EventDispatcher:addEventListener("PUT_FURNITURE", self.doSomeWhenPutFurn, self)
end

function ChildNpc:onExitScene(x, y)
    Npc.onExitScene(self, x, y)

    EventDispatcher:removeEventListener("PUT_FURNITURE", self.doSomeWhenPutFurn, self)
end

function ChildNpc:doSomeWhenPutFurn()
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

function ChildNpc:setSpeed(speed)
    if self:queryBasicInt("stage") == HomeChildMgr.CHILD_TYPE.KID then
        -- 儿童期娃娃正常速度的0.5倍
        self.speed = 0.2 * 0.5
        return
    end

    if self:queryBasicInt("icon") == 51536 or self:queryBasicInt("icon") == 51535 then
        self.speed = 0.15
    else
        self.speed =0.06  --    0.15
    end
end

-- 随机动作
function ChildNpc:randomAct()
    if self:queryBasicInt("stage") == HomeChildMgr.CHILD_TYPE.KID then
        -- 儿童期娃娃的动作始终为stand
        return Const.SA_STAND
    end

    if self:queryBasicInt("npc_state") ~= CHILD_STATE_NORMAL then

        return Const.SA_CRY
    end

    return Const.SA_STAND
end

-- 设置动作
function ChildNpc:setAct(act)
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
function ChildNpc:playAction(times)

    if 0 ~= self.curState then return end

    if self.charAction then
        self:setAct(Const.FA_STAND) -- 先切换为站立动作，避免playAction失效
        self.charAction:playAction(function()
            if times <= 0 then
                self.curState = (self.curState + 1) % 2
                self:doAction()
            end
            self:playAction(times - 1)
        end, self:randomAct(), 1)
    end
end

-- 播放移动
function ChildNpc:playMove()
    if 1 ~= self.curState then return end
    local dest = cc.p(self.basePos.x + math.random(-5, 5), self.basePos.y + math.random(-5, 5))
    self:setEndPos(dest.x, dest.y)

    -- 每隔4s随机选择下一个坐标点
    local nextTime = math.random( 3, 5 )
    performWithDelay(self.middleLayer, function() self:playMove() end, nextTime)
end

-- 状态管理
function ChildNpc:doAction()
    if 0 == self.curState then
        -- 状态1
        if self.faAct ~= Const.FA_STAND then

            self:setAct(Const.FA_STAND)
            performWithDelay(self.middleLayer, function()
                self:playAction(STATE1_SHOW_TIMES)
            end, 1)
        else
            self:playAction(STATE1_SHOW_TIMES)
        end
    else
        -- 状态2
        self:playMove()
        performWithDelay(self.middleLayer, function()
            self.curState = (self.curState + 1) % 2
            self:doAction()
        end, 8)
    end
end


return ChildNpc
