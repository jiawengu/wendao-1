-- FollowElf.lua
-- Created by sujl, Jan/16/2017
-- 跟随精灵

local Char = require("obj/Char")
local FollowSprite = require("obj/FollowSprite")
local FollowElf = class("FollowElf", FollowSprite)

-- 随机走动范围
local RANDOM_WALK_RANGE = 3
local WALK_RANGE_CLIENTSPACE = 2 * Const.PANE_WIDTH
local FOLLOW_DISTANCE = math.ceil(math.sqrt(WALK_RANGE_CLIENTSPACE * WALK_RANGE_CLIENTSPACE + WALK_RANGE_CLIENTSPACE * WALK_RANGE_CLIENTSPACE))

-- 跟随最大距离，超过此距离直接修改位置
local MAX_FOLLOW_DISTANCE_RANGE = 18 * Const.PANE_WIDTH

function FollowElf:init()
    FollowSprite.init(self)
    self.needBindClickEvent = false
    self.isFollowSprite = true          -- 跟随精灵，会在updateFollowSprites中调用update
    self.dontCheckObstacle = true       -- 忽略障碍信息，由于重载了setEndPos实现了忽略障碍信息移动，在setAct时需要屏蔽处于障碍时的逻辑处理
end

function FollowElf:addShadow()
end

function FollowElf:updatePos()
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

    if dist <= FOLLOW_DISTANCE / 1.2 then
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
        if dist < Const.PET_RESET_DISTANCE and not self.isRandomWalk then
            -- 快到达终点了，重新设置一下
            self:setEndPos(gf:convertToMapSpace(self.owner.curX, self.owner.curY))
        end
    elseif self.faAct == Const.FA_STAND then
        self:beginRandomWalk()
    end
end

-- 开始随机走动
function FollowElf:beginRandomWalk()
    if self.startRandWalkTime and gf:getServerTime() - self.startRandWalkTime < 5 then return end
    self:tryToRandomWalk()
    self.startRandWalkTime = gf:getServerTime()
end

--[[
function FollowElf:tryToRandomWalk()
    self:doRandomWalk()
end
]]

function FollowElf:findPath(beginX, beginY, endX, endY, paths)
    local dx, dy = endX - beginX, endY - beginY
    paths = { count = 2 }
    paths["x1"] = beginX
    paths["y1"] = beginY
    paths["len1"] = 0
    paths["x2"] = endX
    paths["y2"] = endY
    paths["len2"] = math.sqrt(dx * dx + dy * dy)

    return paths
end

function FollowElf:setEndPos(mapX, mapY)
    if mapX == nil or mapY == nil then return end

    -- 有可能传进来的地图坐标超出了范围，需要进行修正
    mapX, mapY = MapMgr:adjustPosition(mapX, mapY)

    self.endX, self.endY = gf:convertToClientSpace(mapX, mapY)

    if not self:getCanMove() then
        return
    end

    local paths = self:findPath(self.curX, self.curY, self.endX, self.endY)
    local count = paths["count"]
    if count > 1 then
        -- 复制路径
        self.paths = paths
        self.posCount = paths.count

        self:setAct(Const.FA_WALK)
    end

    self.startTime = GameMgr.lastUpdateTime
    self.lastTime = self.startTime
    self.lastLen = 0
end

-- 随机走动
function FollowElf:doRandomWalk()
    if not self.owner then return end   -- 没有主人，不用随机走了

    -- 先标记处于自动寻走中
    self.isRandomWalk = true

    -- 获取主人当前的位置
    local mapX, mapY = gf:convertToMapSpace(self.owner.curX, self.owner.curY)

    self:setEndPos(self:findPosByOwner(mapX,mapY))
end

function FollowElf:findPosByOwner(mapX, mapY, randomRange)
    local desX, desY
    randomRange = randomRange or RANDOM_WALK_RANGE
    repeat
        desX, desY = math.random(mapX - randomRange, mapX + randomRange), math.random(mapY - randomRange, mapY + randomRange)
    until desX ~= mapX and desY ~= mapY

    return desX, desY
end

return FollowElf