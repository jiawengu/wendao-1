-- Pet.lua
-- Created by chenyq Nov/14/2014
-- 场景中玩家宠物对应的类

local Char = require("obj/Char")

local Pet = class("Pet", Char)

function Pet:init()
    Char.init(self)
    self.levelBeforeAbsorbField = 10000
end
--
function Pet:getDlgIcon()
    -- 优先取时装
    if self:queryBasicInt("fasion_id") ~= 0 and self:queryBasicInt("fasion_visible") == 1 then
        return self:queryBasicInt("fasion_id")
    end

    -- 取换色
    if self:queryBasicInt("dye_icon") ~= 0 then
        return self:queryBasicInt("dye_icon")
    end

    return self:queryBasicInt("icon")
end
--]]

-- 设置该宠物所属的角色
function Pet:setOwner(player)
    self.owner = player
end

function Pet:canSend()
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

function Pet:updatePos()
    Char.updatePos(self)

    if self.owner == Me then
        -- Me的宠物可见
        local dist = gf:distance(Me.curX, Me.curY, self.curX, self.curY)
        if dist <= Const.PET_FOLLOW_DISTANCE / 2 then
            self:setAct(Const.FA_STAND)
        elseif self.faAct == Const.FA_STAND and dist > Const.PET_FOLLOW_DISTANCE then
            -- 主人走得足够远了，开始走动
            self:setEndPos(gf:convertToMapSpace(Me.curX, Me.curY))
        elseif self.faAct == Const.FA_WALK then
            dist = gf:distance(self.curX, self.curY, self.endX, self.endY)
            if dist < Const.PET_RESET_DISTANCE then
                -- 快到达终点了，重现设置一下
                self:setEndPos(gf:convertToMapSpace(Me.curX, Me.curY))
            end
        end
    end
end


-- 获取血池加血后的血量
function Pet:getExtraRecoverLife()
    -- 如果存储量大于等于max_life - life，直接显示最大血量
    local maxLife = tonumber(self:query("max_life"))
    local curLife = tonumber(self:query("life"))
    local extraLife = tonumber(Me:query("extra_life"))

    if GameMgr.inCombat then
        return curLife
    end

    if extraLife >= maxLife - curLife then
        return maxLife
    else
        return curLife + extraLife
    end
end

-- 获取补充灵池后的灵气
function Pet:getExtraRecoverMana()
    local maxMana = tonumber(self:query("max_mana"))
    local curMana = tonumber(self:query("mana"))
    local extraMana = tonumber(Me:query("extra_mana"))

    if GameMgr.inCombat then
        return curMana
    end

    if extraMana >= maxMana - curMana then
        return maxMana
    else
        return curMana + extraMana
    end
end

-- 设置方向
function Pet:setDir(dir)
    if dir % 2 == 0 then
        dir = dir + 1
    end

    Char.setDir(self, dir)
end

function Pet:setAct(act)

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

function Pet:onBeforeAbsorbBasicFields()
    -- 保存吸收基础数据之前的宠物等级
    self.levelBeforeAbsorbField = self:getLevel()
end

function Pet:onAbsorbBasicFields(tbl)
    Char.onAbsorbBasicFields(self)

    local currentPetLevel = self:getLevel()
    -- 吸收数据后升级且有剩余加点数则检测提升界面的显示
    if tbl and tbl.attrib_point and (self:queryBasicInt('pet_status') == 1 or self:queryBasicInt('pet_status') == 2) and
        (self.levelBeforeAbsorbField < currentPetLevel or self:queryBasicInt("attrib_point") == 0) then
        local petData = {["id"] = self:getId()}
        PromoteMgr:checkPromote(PROMOTE_TYPE.TAG_PET_ADD_POINT, petData)
    end

    -- 吸收数据后升级且有剩余抗性加点数则检测提升界面的显示
    if tbl and tbl.resist_point and (self:queryBasicInt('pet_status') == 1 or self:queryBasicInt('pet_status') == 2) and
        ((self.levelBeforeAbsorbField < currentPetLevel and currentPetLevel >= 70) or self:queryBasicInt("resist_point") == 0) then
        local petData = {["id"] = self:getId()}
        PromoteMgr:checkPromote(PROMOTE_TYPE.TAG_PET_RESIST_POINT, petData)
    end
end

function Pet:getMaxLevel()
    local meLevel = Me:getLevel()
    if meLevel > Const.PLAYER_MAX_LEVEL_NOT_FLY
        and not PetMgr:isFlyPet(self) then
        -- 如果玩家已经超过飞升等级
        -- 并且宠物未飞升
        return Const.PLAYER_MAX_LEVEL_NOT_FLY
    end

    return meLevel
end

-- 返回宠物总成长
function Pet:getAllPromote()
    -- 气血成长
    local lifeShape = self:queryInt("pet_life_shape")
    -- 法力成长
    local manaShape = self:queryInt("pet_mana_shape")
    -- 速度成长
    local speedShape = self:queryInt("pet_speed_shape")
    -- 物攻成长
    local phyShape = self:queryInt("pet_phy_shape")
    -- 法攻成长
    local magShape = self:queryInt("pet_mag_shape")
    -- 总成长
    local totalAll = lifeShape + manaShape + speedShape + phyShape + magShape

    return totalAll
end

return Pet
