-- FollowNpc.lua
-- Created by sujl, Jun/17/2016
-- 跟随角色移动的NPC

local Char = require("obj/Char")
local FollowNpc = class("FollowNpc", Char)

function FollowNpc:setOwner(player)
    self.owner = player
    self.needBindClickEvent = false
end

function FollowNpc:canSend()
    if Me:isChangingRoom() then
        return false
    end

    if self.faAct ~= Const.FA_WALK then
        return false
    end

    if not self:getCanMove() then
        return false
    end

    if self.owner ~= Me then
        return false
    end

    local mapX, mapY = gf:convertToMapSpace(self.curX, self.curY)
    if mapX == self.lastMapPosX and mapY == self.lastMapPosY then
        return false
    end

    return true
end

function FollowNpc:updatePos()
    Char.updatePos(self)

    if self.owner == Me then
        -- Me的宠物可见
        local dist = gf:distance(Me.curX, Me.curY, self.curX, self.curY)
        if dist <= Const.NPC_FOLLOW_DISTANCE / 2 then
            self:setAct(Const.FA_STAND)
        elseif self.faAct == Const.FA_STAND and dist > Const.NPC_FOLLOW_DISTANCE then
            -- 主人走得足够远了，开始走动
            self:setEndPos(gf:convertToMapSpace(Me.curX, Me.curY))
        elseif self.faAct == Const.FA_WALK then
            dist = gf:distance(self.curX, self.curY, self.endX, self.endY)
            if dist < Const.NPC_FOLLOW_DISTANCE then
                -- 快到达终点了，重现设置一下
                self:setEndPos(gf:convertToMapSpace(Me.curX, Me.curY))
            end
        end
    end
end

-- 设置方向
function FollowNpc:setDir(dir)
    if dir % 2 == 0 then
        dir = dir + 1
    end

    Char.setDir(self, dir)
end

function FollowNpc:setAct(act)

    -- 判断如果是第一次setAct那么一定要是FA_STAND
    if not self.faAct then
        Char.setAct(self, Const.FA_STAND)
        return
    end

    if act == Const.FA_STAND and self.owner == Me and Me.faAct ~= Const.FA_STAND then
        -- 主人还在走动，不允许站住
        return
    end

    Char.setAct(self, act)
end

function FollowNpc:onAbsorbBasicFields(tbl)
    Char.onAbsorbBasicFields(self)
end

return FollowNpc
