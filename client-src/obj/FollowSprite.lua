-- FollowSprite.lua
-- Created by sujl, Jan/16/2017
-- 跟随精灵

local Char = require("obj/Char")
local FollowSprite = class("FollowSprite", Char)
local CharAction = require("animate/CharAction")

local TAG_CHAR = 100

-- 随机走动范围
local RANDOM_WALK_RANGE = 3
local WALK_RANGE_CLIENTSPACE = RANDOM_WALK_RANGE * Const.PANE_WIDTH
local FOLLOW_DISTANCE = math.ceil(math.sqrt(WALK_RANGE_CLIENTSPACE * WALK_RANGE_CLIENTSPACE + WALK_RANGE_CLIENTSPACE * WALK_RANGE_CLIENTSPACE))

-- 跟随最大距离，超过此距离直接修改位置
local MAX_FOLLOW_DISTANCE_RANGE = 18 * Const.PANE_WIDTH

local RANDOM_ACTIONS = {
    [50202] = { 50, 50 },
    [50203] = { 50, 50 },
    [50204] = { 50, 50 },
    [50205] = { 50, 50 },
    [50206] = { 30, 70 },
    [50207] = { 50, 50 },
    [50208] = { 50, 50 },
    [50209] = { 50, 50 },
}

function FollowSprite:init()
    Char.init(self)
    self.needBindClickEvent = false
end

-- 设置主人
function FollowSprite:setOwner(player)
    self.owner = player
end

function FollowSprite:addShadow()
end

-- 是否发送
-- 不需要同步，各走各的
function FollowSprite:canSend()
    return false
end

function FollowSprite:updatePos()
    Char.updatePos(self)

    if not self.owner then return end
    local dist = gf:distance(self.owner.curX, self.owner.curY, self.curX, self.curY)
    if self.isRandomWalk then
        if dist > FOLLOW_DISTANCE then
            -- 主人走得足够远了，开始走动
            self:endRandomWalk()
            self:setEndPos(gf:convertToMapSpace(self.owner.curX, self.owner.curY))
        elseif self.faAct == Const.FA_STAND or (self.endX == self.curX and self.endY == self.curY) then
            self.isRandomWalk = nil -- 清除自动寻路标记
        end
        return
    end

    if dist <= FOLLOW_DISTANCE / 2 then
        self:setAct(Const.FA_STAND)
        self:beginRandomWalk()
    elseif dist > MAX_FOLLOW_DISTANCE_RANGE then
        local mapX, mapY = gf:convertToMapSpace(self.owner.curX, self.owner.curY)
        mapX, mapY = self:findPosByOwner(mapX, mapY, 1)
        self:setPos(gf:convertToClientSpace(mapX,mapY))
        self:setAct(Const.FA_STAND)
        self:beginRandomWalk()
    elseif self.faAct == Const.FA_STAND and dist > FOLLOW_DISTANCE then
        -- 主人走得足够远了，开始走动
        self:endRandomWalk()
        self:setEndPos(gf:convertToMapSpace(self.owner.curX, self.owner.curY))
    elseif self.faAct == Const.FA_WALK then
        dist = gf:distance(self.curX, self.curY, self.endX, self.endY)
        if dist < Const.PET_RESET_DISTANCE then
            -- 快到达终点了，重新设置一下
            self:setEndPos(gf:convertToMapSpace(self.owner.curX, self.owner.curY))
        end
    elseif self.faAct == Const.FA_STAND and self.charAction and self.charAction.action == Const.SA_STAND then
        self:beginRandomWalk()
    end
end

-- 开始随机走动
function FollowSprite:beginRandomWalk()
    if self.randomAction then return end -- 已经启动了
    self.randomAction = performWithDelay(self.middleLayer, function()
        self:tryToRandomWalk()
        self.randomAction = nil
    end, 5)
end

-- 停止随机走动
function FollowSprite:endRandomWalk()
    if self.randomAction then
        self.middleLayer:stopAction(self.randomAction)
        self.randomAction = nil
    end

    if self.charAction then
        self.charAction:resetAction()
    end

    self:setAct(Const.FA_STAND)

    -- 取消自动行走标记
    self.isRandomWalk = nil
end

function FollowSprite:tryToRandomWalk()
    --[[
    if self.charAction:getRealAction(TAG_CHAR) == Const.SA_STAND1 then
        performWithDelay(self.middleLayer, function()
            self:tryToRandomWalk()
        end, 0)
    else
        self:doRandomWalk()
    end
    ]]

    local weights = RANDOM_ACTIONS[self:getIcon()]
    if weights and self.randomActs then
        local index = gf:weightRandom(weights)
        if 1 == index then
            self:doRandomWalk()
        else
            self:doRandomAction()
        end
    else
        self:doRandomWalk()
    end
end

function FollowSprite:doRandomAction()
    local showAct = self.randomActs[math.random(#self.randomActs)]
    if self.charAction then
        self.charAction:playActionOnce(nil, showAct)
    end
end

function FollowSprite:findPosByOwner(mapX, mapY, randomRange)
    local desX, desY
    randomRange = randomRange or RANDOM_WALK_RANGE
    repeat
        desX, desY = math.random(mapX - randomRange, mapX + randomRange), math.random(mapY - randomRange, mapY + randomRange)
    until desX ~= mapX and desY ~= mapY

    local pos = GObstacle:Instance():GetNearestPos(desX, desY)

    if 0 ~= pos then
        desX, desY = math.floor(pos / 1000), pos % 1000
    end

    return desX, desY
end

-- 随机走动
function FollowSprite:doRandomWalk()
    if not self.owner then return end   -- 没有主人，不用随机走了

    -- 先标记处于自动寻走中
    self.isRandomWalk = true

    -- 获取主人当前的位置
    local mapX, mapY = gf:convertToMapSpace(self.owner.curX, self.owner.curY)

    self:setEndPos(self:findPosByOwner(mapX,mapY))
end

function FollowSprite:updateName()
    if self:queryBasicInt("type") == OBJECT_TYPE.CHILD then
        -- 娃娃当前跟随精灵处理，需要显示名字
        Char.updateName(self)
    end
end

function FollowSprite:onEnterScene(mapX, mapY)
    local desX, desY = self:findPosByOwner(mapX,mapY)

    self:setAct(Const.FA_STAND)
    Char.onEnterScene(self, desX, desY)
end

function FollowSprite:onExitScene()
    Char.onExitScene(self)
    self.randomAction = nil
end

-- 设置方向
function FollowSprite:setDir(dir)
    if dir % 2 == 0 then
        dir = dir + 1
    end

    Char.setDir(self, dir)
end

function FollowSprite:getId()
    return self:queryBasicInt('id')
end

function FollowSprite:createCharAction(syncLoad, cb)
    return CharAction.new(syncLoad, cb)
end

function FollowSprite:getFollower()
    if not self.owner then return end
    local follower
    local driverId = self.owner:queryBasicInt("share_mount_leader_id")
    if 0 ~= driverId and driverId ~= self.owner:getId() and self.owner:isShowRidePet() then
        follower = CharMgr:getCharById(driverId)
    end
    if not follower then
        follower = self.owner
    end

    return follower
end

function FollowSprite:getSpeed()
    local follow = self:getFollower()
    if follow and Const.FA_WALK == follow.faAct then
        return follow:getSpeed()
    else
        return Char.getSpeed(self)
    end
end

function FollowSprite:onAbsorbBasicFields()
    Char.onAbsorbBasicFields(self)

    self.randomActs = gf:getAllActionByIcon(self:getIcon(), {[Const.SA_STAND] = true, [Const.SA_WALK] = true, [Const.SA_DIE] = true})
end

return FollowSprite