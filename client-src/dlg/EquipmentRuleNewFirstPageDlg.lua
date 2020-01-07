-- EquipmentRuleNewFirstPageDlg.lua
-- Created by Oct/2018/9
-- 装备规则总览

local EquipmentRuleNewFirstPageDlg = Singleton("EquipmentRuleNewFirstPageDlg", Dialog)


local MARGIN_Y = 42
local MARGIN_CONTENT_Y = 40

local STENCIL_MAP = {
    [1] = {pos = cc.p(24, 185), size = {width = 233, height = 142}, level = 50},        -- 拆分
    [2] = {pos = cc.p(24, 241), size = {width = 233, height = 84}, level = 50},         -- 重组
    [3] = {pos = cc.p(24, 185), size = {width = 233, height = 56}, level = 50},         -- 炼化
    [4] = {pos = cc.p(24, 17), size = {width = 233, height = 112}, level = 40},         -- 改造
    [5] = {pos = cc.p(24, 129), size = {width = 233, height = 56}, level = 70},         -- 套装
    [6] = {pos = cc.p(10, 352), size = {width = 263, height = 34}, level = 70},         -- 进化
}

function EquipmentRuleNewFirstPageDlg:init()
    for i = 1, 6 do
        local panel = self:getControl("UnitPanel" .. i)
        panel:setTag(i)
        self:bindListener("UnitPanel" .. i, self.onSelectRedLine)

        if Me:queryBasicInt("level") < STENCIL_MAP[i].level then
            panel.notActive = true
            local imgCtl = self:getControl("BKImage", nil, panel)
            local imgCtl2 = self:getControl("NumImage", nil, panel)
            gf:grayImageView(imgCtl)
            gf:grayImageView(imgCtl2)
        end
    end

    -- 拆分
    self:bindListener("GotoLink", self.onChaifen, "UnitPanel1")

    -- 重组
    self:bindListener("GotoLink2", self.onChongzu, "UnitPanel2")

    -- 炼化
    self:bindListener("GotoLink", self.onLianhua, "UnitPanel3")

    -- 强化
    self:bindListener("GotoLink2", self.onQianghua, "UnitPanel3")

    -- 套装
    self:bindListener("GotoLink", self.onGaizao, "UnitPanel4")

    -- 改造
    self:bindListener("GotoLink", self.onSuit, "UnitPanel5")

    -- 进化
    self:bindListener("GotoLink", self.onJinhua, "UnitPanel6")

    self:lightEffInit()

    if Me:queryBasicInt("level") < STENCIL_MAP[1].level then
        -- 不延迟表现异常
        performWithDelay(self.root, function ( )
            self:onSelectRedLine(self:getControl("UnitPanel4"), nil, true)
        end, 0)
    else
        self:onSelectRedLine(self:getControl("UnitPanel1"), nil, true)
    end
end

function EquipmentRuleNewFirstPageDlg:setStencil(size, pos, panel, stencilName)

    if not panel then panel = self:getControl("EquipPicPanel") end

    local stencil = panel:getChildByName("stencilLayer")
    if not stencil then
        stencil = cc.Node:create()
        panel:addChild(stencil)
        self.clipNode:setStencil(stencil)
        self.clipNode.stencil = stencil
        stencil:setName("stencilLayer")
    end

    local touming1 = stencil:getChildByName(stencilName)
    if not touming1 then
        touming1 = cc.LayerColor:create(cc.c4b(0, 0, 0, 0))
        stencil:addChild(touming1)
        touming1:setName(stencilName)

    end

    touming1:setContentSize(size)
    touming1:setPosition(pos)
    touming1:setOpacity(0)

end


-- 高亮初始化
function EquipmentRuleNewFirstPageDlg:lightEffInit()

    self.darkImage = self:getControl("DarkImage")
    self.darkImage:removeFromParent()

    self.clipNode = cc.ClippingNode:create()
    self.clipNode:setInverted(true)

    local panel = self:getControl("EquipPicPanel")
    panel:addChild(self.clipNode)
    self.clipNode:addChild(self.darkImage)
    self.clipNode:setAnchorPoint(0, 0)

    self:setStencil({width = 1, height = 1}, cc.p(-100, -100), panel, "stencil")
    self:setStencil({width = 1, height = 1}, cc.p(-100, -100), panel, "stencil_ex")
end

function EquipmentRuleNewFirstPageDlg:onChaifen(sender, eventType)
    DlgMgr:sendMsg("EquipmentRuleNewDlg", "onGotoMenu", CHS[4200599])
end

function EquipmentRuleNewFirstPageDlg:onChongzu(sender, eventType)
    DlgMgr:sendMsg("EquipmentRuleNewDlg", "onGotoMenu", CHS[4200597])
end

function EquipmentRuleNewFirstPageDlg:onLianhua(sender, eventType)
    DlgMgr:sendMsg("EquipmentRuleNewDlg", "onGotoMenu", CHS[4200594], CHS[4200594])
end

function EquipmentRuleNewFirstPageDlg:onQianghua(sender, eventType)
    DlgMgr:sendMsg("EquipmentRuleNewDlg", "onGotoMenu", CHS[4200594], CHS[4200602])
end

function EquipmentRuleNewFirstPageDlg:onSuit(sender, eventType)
    DlgMgr:sendMsg("EquipmentRuleNewDlg", "onGotoMenu", CHS[4200596])
end

function EquipmentRuleNewFirstPageDlg:onGaizao(sender, eventType)
    DlgMgr:sendMsg("EquipmentRuleNewDlg", "onGotoMenu", CHS[4200592])
end

function EquipmentRuleNewFirstPageDlg:onJinhua(sender, eventType)
    DlgMgr:sendMsg("EquipmentRuleNewDlg", "onGotoMenu", CHS[4200591])
end

function EquipmentRuleNewFirstPageDlg:resetUnitPanelPosY(sender)
    local panel = self:getControl("UnitPanel1")
    local initY = panel:getPositionY()

    local disHeight = 0
    for i = 1, 6 do
        local panel = self:getControl("UnitPanel" .. i)

        panel:setPositionY(initY - (i - 1) * MARGIN_Y - disHeight)

        if sender:getName() == "UnitPanel" .. i then
            local size = self:getCtrlContentSize("ContentPanel", sender)
            disHeight = size.height - 10
        end
    end
end

function EquipmentRuleNewFirstPageDlg:onSelectRedLine(sender, eventType, isDefault)
    local tag = sender:getTag()

    if not isDefault and sender.notActive then
        gf:ShowSmallTips(string.format( CHS[4200608], STENCIL_MAP[tag].level))
        return
    end

    for i = 1, 6 do
        self:setCtrlVisible("UnitRedLinePanel" .. i, i == tag)

        local panel = self:getControl("UnitPanel" .. i)
        self:setCtrlVisible("ChooseEffectImage", sender:getName() == ("UnitPanel" .. i), panel)
        self:setCtrlVisible("ContentPanel", sender:getName() == ("UnitPanel" .. i), panel)

        self:resetUnitPanelPosY(sender)
    end

    local panel = self:getControl("EquipPicPanel")
    local size = STENCIL_MAP[tag].size
    local pos = STENCIL_MAP[tag].pos
    self:setStencil(size, pos, panel, "stencil")

    if tag ~= 4 then
        self:setStencil({width = 1, height = 1}, cc.p(-100, -100), panel, "stencil_ex")
    else
        self:setStencil({width = 168, height = 26}, cc.p(89, 413), panel, "stencil_ex")
    end
end

return EquipmentRuleNewFirstPageDlg
