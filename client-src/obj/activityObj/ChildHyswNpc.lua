-- ChildHyswNpc.lua
-- Created by songcw, Jan/19/2018
-- 娃娃日常-踩影子

local Char = require("obj/Char")
local ChildHyswNpc = class("ChildHyswNpc", Char)

local LIMIT_TIME = {2, 1.5, 1, 0.5, 0.5}

-- 对象进入场景,慧眼识娃
function ChildHyswNpc:onEnterScene(x, y, layer)
    -- 将对象的 3 层分别添加到角色层对应的子层中
    if self.bottomLayer:getParent() == nil then
        layer:addChild(self.bottomLayer)
    end

    if self.middleLayer:getParent() == nil then
        layer:addChild(self.middleLayer)
    end

    if self.topLayer:getParent() == nil then
        layer:addChild(self.topLayer)
    end

    self:setPos(x, y)

    -- 更新名字
    self:updateName()

    -- 添加阴影
    self:addShadow()
end


function ChildHyswNpc:setEndPos(x, y, fun, round)
    local srcX, srcY = self.bottomLayer:getPosition()
    local dir = gf:defineDir(cc.p(srcX, srcY), cc.p(x, y), self:getIcon())
    self:setDir(dir)
    self:setAct(Const.FA_WALK)

    local function getMoveAct( )
        return cc.MoveTo:create(LIMIT_TIME[round], cc.p(x, y))
    end

    self.bottomLayer:runAction(getMoveAct())
    self.middleLayer:runAction(getMoveAct())
    self.topLayer:runAction(cc.Sequence:create(getMoveAct(), cc.CallFunc:create(function()
        self:setPos(x, y)
        if fun then
            fun.func()
        else
            self:setAct(Const.FA_STAND)
        end
    end)))

end

function ChildHyswNpc:onClickChar()
    if not self.flag then self.flag = 0 end

    DlgMgr:sendMsg("ChildDailyMission5Dlg", "onCharPanel", self.flag)
end

-- 点击对象时添加选中特效
function ChildHyswNpc:addFocusMagic()

    if self:queryBasicInt("icon") == Me:queryBasicInt("org_icon") then return end

    if DlgMgr:sendMsg("ChildDailyMission5Dlg", "getGaussSatge") then
        Char.addFocusMagic(self)
    end


end

return ChildHyswNpc
