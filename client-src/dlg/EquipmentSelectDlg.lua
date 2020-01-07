-- EquipmentSelectDlg.lua
-- Created by songcw July/28/2015
-- 选中装备

local EquipmentSelectDlg = Singleton("EquipmentSelectDlg", Dialog)

local LEVEL_LIST_COUNT = 8

function EquipmentSelectDlg:init()
    -- 等级列表选中效果克隆
    self.levelSelectEff = self:getControl("BChosenEffectImage")
    self.levelSelectEff:setVisible(true)
    self.levelSelectEff:retain()
    self.levelSelectEff:removeFromParent()

    -- 装备panel
    self.equipPanel = self:getControl("EquipmentUnitPanel")
    self.equipPanel:retain()
    self.equipPanel:removeFromParent()

    self.equipPanelList = self:initEquipList()
    self.selectLevel = math.floor(Me:queryBasicInt("level") / 10) * 10
    if self.selectLevel < 50 then self.selectLevel = 50 end
    if self.selectLevel > EquipmentMgr:getEquipReqLevelMax() then self.selectLevel = EquipmentMgr:getEquipReqLevelMax() end
    for i = 1, LEVEL_LIST_COUNT do
        local panel = self:getControl("LevelPanel" .. i)
        panel:setTag((i + 4) * 10)
        self:bindTouchEndEventListener(panel, self.onChooseLevel)
        if (i + 4) * 10 == self.selectLevel then
            self:onChooseLevel(panel)
        end
    end
end

function EquipmentSelectDlg:cleanup()
    self:releaseCloneCtrl("levelSelectEff")
    self:releaseCloneCtrl("equipPanel")
end

function EquipmentSelectDlg:initEquipList()
    local size = self.equipPanel:getContentSize()
    local equipPanelList = {}
    local listPanel = self:getControl("EquipmentListPanel")
    local index = 0
    for i = 5, 1, -1 do
        local equipPanel = self.equipPanel:clone()
        index = index + 1
        equipPanel:setTag(index)
        equipPanel:setPosition(((index - 1) % 2) * size.width, (i - 1) * size.height)
        listPanel:addChild(equipPanel)
        equipPanel:setVisible(false)
        table.insert(equipPanelList, equipPanel)

        local equipPanel2 = self.equipPanel:clone()
        index = index + 1
        equipPanel:setTag(index)
        equipPanel2:setPosition(((index - 1) % 2) * size.width, (i - 1) * size.height)
        listPanel:addChild(equipPanel2)
        equipPanel2:setVisible(false)
        table.insert(equipPanelList, equipPanel2)
    end

    return equipPanelList
end

function EquipmentSelectDlg:onChooseLevel(sender, eventType, tag)
    self.levelSelectEff:removeFromParent()
    if tag then
        sender = self:getControl("LevelListPanel"):getChildByTag(tag)
        if not sender then
            -- 因为如果等级不够打开界面就会报错，如果没有取道sender，那么就是没有这个等级段的装备
            return
        end
    end
    sender:addChild(self.levelSelectEff)

    self.selectLevel = sender:getTag()
    local equips = self:getOrderEquips(self.selectLevel)

    -- 事件监听
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:setCtrlVisible("ChosenEffectImage", false, sender)
            DlgMgr:sendMsg("EquipmentReformDlg", "setEquipInfo", equips[sender:getTag()])
            self:onCloseButton()
        elseif eventType == ccui.TouchEventType.began then
            self:setCtrlVisible("ChosenEffectImage", true, sender)
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.canceled then
            self:setCtrlVisible("ChosenEffectImage", false, sender)
        end
    end

    for i, panel in pairs(self.equipPanelList) do
        self:setEquipInfo(equips[i], panel)
        panel:setTag(i)
        panel:addTouchEventListener(listener)
    end
end

function EquipmentSelectDlg:onChooseEquip(sender, eventType)
    self:setCtrlVisible("ChosenEffectImage", true)
    self:onCloseButton()
end

function EquipmentSelectDlg:setEquipInfo(info, panel)
    self:setImage("EquipmentImage", ResMgr:getItemIconPath(info.icon), panel)
    self:setItemImageSize("EquipmentImage", panel)
    self:setLabelText("EquipmentNameLabel", info.name, panel)
    self:setLabelText("EquipmentLevelValueLabel", info.req_level, panel)
    self:setLabelText("EquipmentTypeLabel", info.equipType, panel)
    self:setCtrlVisible("TipImage", (info.order ~= 5), panel)
    panel:setVisible(true)
end

function EquipmentSelectDlg:getOrderEquips(level)
    local equips = EquipmentMgr:getEquipmentsByLevel(level)
    for i, equipInfo in pairs(equips) do
        if Me:queryBasicInt("polar") == equipInfo.polar and self:getEquipPos(equipInfo) == EQUIP_TYPE.WEAPON then
            equipInfo.order = 1
        elseif Me:queryBasicInt("gender") == equipInfo.gender and self:getEquipPos(equipInfo) == EQUIP_TYPE.HELMET then
            equipInfo.order = 2
        elseif Me:queryBasicInt("gender") == equipInfo.gender and self:getEquipPos(equipInfo) == EQUIP_TYPE.ARMOR then
            equipInfo.order = 3
        elseif self:getEquipPos(equipInfo) == EQUIP_TYPE.BOOT then
            equipInfo.order = 4
        else
            equipInfo.order = 5
        end
        
        equipInfo.polar = equipInfo.polar or 6
        equipInfo.equip_type = self:getEquipPos(equipInfo)
    end

    table.sort(equips, function(l, r)
        if l.order < r.order then return true end
        if l.order > r.order then return false end
        if l.polar < r.polar then return true end
        if l.polar > r.polar then return false end
        if l.equip_type < r.equip_type then return true end
        if l.equip_type > r.equip_type then return false end
    end)

    return equips
end

function EquipmentSelectDlg:getEquipPos(equipInfo)
    if equipInfo.equipType == CHS[3002545] or equipInfo.equipType == CHS[3002546] or equipInfo.equipType == CHS[3002547] or equipInfo.equipType == CHS[3002548] or equipInfo.equipType == CHS[3002549] then
        return EQUIP_TYPE.WEAPON
    elseif equipInfo.equipType == CHS[3002550] or  equipInfo.equipType == CHS[3002551] then
        return EQUIP_TYPE.ARMOR
    elseif equipInfo.equipType == CHS[3002552] or  equipInfo.equipType == CHS[3002553] then
        return EQUIP_TYPE.HELMET
    elseif equipInfo.equipType == CHS[3002554] then
        return EQUIP_TYPE.BOOT
    end
end

function EquipmentSelectDlg:getSelectItemBox(clickItem)
    local listPanel = self:getControl("EquipmentListPanel")
    local panel = listPanel:getChildByTag(1)
    return self:getBoundingBoxInWorldSpace(panel)
end

return EquipmentSelectDlg
