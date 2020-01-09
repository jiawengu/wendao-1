-- Kid.lua
-- Created by lixh Apr/09/2019
-- 场景中娃娃对应的类

local Char = require("obj/Char")
local Pet = require("obj/Pet")
local Kid = class("Kid", Pet)

function Kid:onBeforeAbsorbBasicFields()
    -- 保存吸收基础数据之前的等级与亲密度
    self.levelBeforeAbsorbField = self:getLevel()
    self.intimacyBeforeAbsorbField = self:queryBasicInt("intimacy")
end

function Kid:onAbsorbBasicFields(tbl)
    Char.onAbsorbBasicFields(self)

    if (self.levelBeforeAbsorbField and self:getLevel() > self.levelBeforeAbsorbField)
        or self.intimacyBeforeAbsorbField and self:queryBasicInt("intimacy") > self.intimacyBeforeAbsorbField then
        -- 吸收数据后，等级、亲密度有提升时，检测飞升提示
        PromoteMgr:checkPromote(PROMOTE_TYPE.TAG_KID_FLY, nil, nil, true)
    end
end

-- 返回娃娃属性点分配
function Kid:getLeftAttribPoint()
    local str = self:queryInt("attrib_assign/str")
    local wiz = self:queryInt("attrib_assign/wiz")
    local con = self:queryInt("attrib_assign/con")
    local dex = self:queryInt("attrib_assign/dex")

    local leftPoint = 4 - str - wiz - con - dex

    return leftPoint
end

-- 返回娃娃总成成长
function Kid:getAllShape()
    local lifeShape = self:queryInt("life_shape")
    local manaShape = self:queryInt("mana_shape")
    local speedShape = self:queryInt("speed_shape")
    local phyShape = self:queryInt("phy_shape")
    local magShape = self:queryInt("mag_shape")
    return lifeShape + manaShape + speedShape + phyShape + magShape
end

return Kid
