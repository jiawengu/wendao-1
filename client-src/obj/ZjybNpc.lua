-- ZjybNpc.lua
-- Created by haungzz, July/13/2018
-- 真假月饼NPC

local Npc = require("obj/Npc")
local ZjybNpc = class("ZjybNpc", Npc)

local WALK_PATH = {
    cc.p(79,71),
    cc.p(74,73),
    cc.p(72,78),
    cc.p(74,83),
    cc.p(79,85),
    cc.p(84,83),
    cc.p(86,78),
    cc.p(84,73),
}

--[[cc.p(74, 73),
    cc.p(70, 76),
    cc.p(70, 82),
    cc.p(75, 83),
    cc.p(80, 83),
    cc.p(84, 81),
    cc.p(87, 78),
    cc.p(86, 74),
    cc.p(80, 72),]]

local TALK_TEXT = {
    CHS[5450292],
    CHS[5450293],
    CHS[5450294],
}

local TALK_INTERVAL = 4 -- 喊话间隔

local TALK_INTERVAL = 4 -- 喊话间隔

local SHOW_TIME = 3

local ZJYBNPC_ORDER = {
    [CHS[5450289]] = 1,
    [CHS[5450290]] = 2,
    [CHS[5450291]] = 3,

    [1] = CHS[5450289],
    [2] = CHS[5450290],
    [3] = CHS[5450291],
}
function ZjybNpc:init()
    self.curIndex = 0
    self.isStartCircleWalk = nil
    self.isFirstWalk = nil

    Npc.init(self)
end

function ZjybNpc:isCanTouch()
    return false
end

function ZjybNpc:updateDestination()
end

function ZjybNpc:setStartCircleWalk(lastIndex, lastOrder)
    local curOrder = ZJYBNPC_ORDER[self:getName()]
    if not curOrder or not lastOrder then
        return
    end

   --[[ local cOrder
    if curOrder > lastOrder then 
        cOrder = curOrder - lastOrder
    else  
        cOrder = curOrder - lastOrder + 3
    end

    self.curIndex = (lastIndex + cOrder * 3 - 1) % 9 + 1]]
    if lastOrder == 1 then
        if curOrder == 3 then
            self.curIndex = (lastIndex + 5) % 8
        else
            self.curIndex = (lastIndex + 2) % 8
        end
    elseif lastOrder == 2 then
        if curOrder == 1 then
            self.curIndex = (lastIndex + 6) % 8
        else
            self.curIndex = (lastIndex + 3) % 8
        end
    else
        if curOrder == 1 then
            self.curIndex = (lastIndex + 3) % 8
        else
            self.curIndex = (lastIndex + 5) % 8
        end
    end

    if self.curIndex == 0 then self.curIndex = 8 end

    local pos = WALK_PATH[self.curIndex]
    self:setPos(gf:convertToClientSpace(pos.x, pos.y))

    self.isStartCircleWalk = true
    self:setAct(Const.FA_STAND)
end

-- 真假月饼 当前是否有 ZjybNpc 在跑
function ZjybNpc:hasZjybNpcStartWalk()
    for _, char in pairs(CharMgr.chars) do
        if char and char:getType() == "ZjybNpc" and char.isStartCircleWalk then
            return true
        end
    end

    return false
end

-- 真假月饼 通知还没有开始跑的 ZjybNpc 开始跑
function ZjybNpc:talkOtherZjybNpcToWalk(index, order)
    for _, char in pairs(CharMgr.chars) do
        if char and char:getType() == "ZjybNpc" and char.charAction and char ~= self and not char.isFirstWalk then
            char:setStartCircleWalk(index, order)
        end
    end
end

function ZjybNpc:setAct(act, callBack)
    if self.isStartCircleWalk and act == Const.FA_STAND then
        -- 开始下一步行走
        if self.isFirstWalk then
            self:talkOtherZjybNpcToWalk(self.curIndex, ZJYBNPC_ORDER[self:getName()])
        end

        self.curIndex = self.curIndex % #WALK_PATH + 1

        local pos = WALK_PATH[self.curIndex]
        self:setEndPos(pos.x, pos.y)
    elseif act == Const.FA_STAND then
        Npc.setAct(self, act, callBack)
        if not self:hasZjybNpcStartWalk() then
            -- 第一个开始跑的
            self.isFirstWalk = true
            self:setStartCircleWalk(1, 1)
            self:playAction()
        end
    else
        Npc.setAct(self, act, callBack)
    end
end

function ZjybNpc:playAction()
    if self.delayToTalk then
        self.topLayer:stopAction(self.delayToTalk)
    end

    self.delayToTalk = performWithDelay(self.topLayer, function() 
        local name = ZJYBNPC_ORDER[math.random(1, 3)]
        local text = TALK_TEXT[math.random(1, 3)]
        local char = CharMgr:getCharByName(name)
        if char then
            char:setChat({msg = text, show_time = SHOW_TIME}, nil, true)
        end

        self.delayToTalk = nil
        self:playAction()
    end, TALK_INTERVAL)
end

function ZjybNpc:getSpeed()
    local speed = Npc.getSpeed(self)
    return speed * 1.2
end

function ZjybNpc:cleanup()
    self.isStartCircleWalk = nil
    if self.isFirstWalk then
        self.isFirstWalk = nil
        for _, char in pairs(CharMgr.chars) do
            if char and char:getType() == "ZjybNpc" and char.charAction and char.isStartCircleWalk then
                char.isFirstWalk = true
                char:playAction()
                break
            end
        end
    end

    Npc.cleanup(self)
end

return ZjybNpc
