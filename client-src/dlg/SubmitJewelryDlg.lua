-- SubmitJewelryDlg.lua
-- Created by songcw July/12/2016
-- 提交首饰
-- 目前仅用于合成首饰，选择相应首饰

local SubmitJewelryDlg = Singleton("SubmitJewelryDlg", Dialog)

--  CHS[4000090]:气血   CHS[4000110]:法力    CHS[4000032]:伤害
local MaterialAtt = {
    [EQUIP.BALDRIC] = {att = CHS[4000090], field = "max_life"},
    [EQUIP.NECKLACE] = {att =  CHS[4000110], field = "max_mana"},
    [EQUIP.LEFT_WRIST] = {att =  CHS[4000032], field = "phy_power"},
    [EQUIP.RIGHT_WRIST] = {att =  CHS[4000032], field = "phy_power"},

    [EQUIP.BACK_BALDRIC] = {att = CHS[4000090], field = "max_life"},
    [EQUIP.BACK_NECKLACE] = {att =  CHS[4000110], field = "max_mana"},
    [EQUIP.BACK_LEFT_WRIST] = {att =  CHS[4000032], field = "phy_power"},
    [EQUIP.BACK_RIGHT_WRIST] = {att =  CHS[4000032], field = "phy_power"},
}

function SubmitJewelryDlg:init()
    self:bindListener("SubmitButton", self.onSubmitButton)

    self.singelPanel = self:getControl("SingelPanel", nil, "JewelryPanel")
    self.singelPanel:retain()
    self.singelPanel:removeFromParent()

    self.selectImage = self:getControl("ChoseImage", nil, self.singelPanel)
    self.selectImage:retain()
    self.selectImage:removeFromParent()
    self.selectImage:setVisible(true)

    self.jewelry = nil
    self.isTask = nil
end

function SubmitJewelryDlg:cleanup()
    self:releaseCloneCtrl("singelPanel")
    self:releaseCloneCtrl("selectImage")
end

function SubmitJewelryDlg:getJewelryByLevel(level)
    local jewelries = EquipmentMgr:getJewelryFromBag()
    if not level then return jewelries end
    local ret = {}
    for i = 1, #jewelries do
        local item = jewelries[i]
        if item.req_level == level then
            table.insert(ret, item)
        end
    end

    return ret
end

function SubmitJewelryDlg:getJewelryByName(name)
    local jewelries = EquipmentMgr:getJewelryFromBag()
    if not name then return jewelries end
    local ret = {}
    for i = 1, #jewelries do
        local item = jewelries[i]
        if item.name == name then
            table.insert(ret, item)
        end
    end

    return ret
end

function SubmitJewelryDlg:setDataByName(name)
    local jewelries = self:getJewelryByName(name)
    self:pushData(jewelries)
end

function SubmitJewelryDlg:setData(level)
    local jewelries = self:getJewelryByLevel(level)
    self:pushData(jewelries)
end

function SubmitJewelryDlg:pushData(jewelries)
    local listCtrl = self:resetListView("ListView", 0, ccui.ListViewGravity.centerVertical)
    if #jewelries == 0 then

        return
    end

    local line = math.ceil(#jewelries / 3)

    for i = 1, line do
        local unitPanel = self.singelPanel:clone()
        self:setUnitPanel(jewelries, i, unitPanel)
        listCtrl:pushBackCustomItem(unitPanel)
    end
end

function SubmitJewelryDlg:setUnitPanel(cards, line, linePanel)
    for i = 1, 3 do
        local panel = self:getControl("JewelryShapePanel" .. i, nil, linePanel)
        local item = cards[(line - 1) * 3 + i]
        if item then
            panel.jewelry = item
            self:setImage("JewelryImage", ResMgr:getItemIconPath(item.icon), panel)
            self:setItemImageSize("JewelryImage", panel)
            if InventoryMgr:isLimitedItem(item) then
                local image = self:getControl("JewelryImage", nil, panel)
                InventoryMgr:addLogoBinding(image)
            end

            self:setNumImgForPanel(
                "JewelryImage",
                ART_FONT_COLOR.NORMAL_TEXT,
                item.req_level,
                false,
                LOCATE_POSITION.LEFT_TOP, 21, panel
            )
            self:bindTouchEndEventListener(panel, self.onSelectJewelry)

            if not self.jewelry then self:onSelectJewelry(panel) end
        else
            panel:setVisible(false)
        end
    end
end

function SubmitJewelryDlg:setIsTask()
    self.isTask = true
end

function SubmitJewelryDlg:onSelectJewelry(sender, eventType)
    self.jewelry = sender.jewelry
    self:addSelectEff(sender)
    self:setJewelryInfo()
end

function SubmitJewelryDlg:setJewelryInfo()
    self:setImage("JewelryImage", ResMgr:getItemIconPath(self.jewelry.icon), "SelectJewelryPanel")
    self:setItemImageSize("JewelryImage", "SelectJewelryPanel")
    local image = self:getControl("JewelryImage", nil, "SelectJewelryPanel")
    if InventoryMgr:isLimitedItem(self.jewelry) then
        InventoryMgr:addLogoBinding(image)
    else
        InventoryMgr:removeLogoBinding(image)
    end

    self:setNumImgForPanel(
        "JewelryImage",
        ART_FONT_COLOR.NORMAL_TEXT,
        self.jewelry.req_level,
        false,
        LOCATE_POSITION.LEFT_TOP, 21, "SelectJewelryPanel"
    )

    self:setLabelText("JewelryNameLabel", self.jewelry.name, "JewelryItemPanel")

    local jtype = self.jewelry.equip_type
    if jtype == EQUIP.BALDRIC then
        self:setLabelText("MainLabel2", CHS[3002877])
    elseif jtype == EQUIP.NECKLACE then
        self:setLabelText("MainLabel2", CHS[3002878])
    elseif jtype == EQUIP.LEFT_WRIST then
        self:setLabelText("MainLabel2", CHS[3002879])
    elseif jtype == EQUIP.RIGHT_WRIST then
        self:setLabelText("MainLabel2", CHS[3002879])
    end

    local attValueStr = string.format("%s_%d", MaterialAtt[jtype].field, Const.FIELDS_NORMAL)
    local attValue = self.jewelry.extra[attValueStr] or self.jewelry.fromCardValue or 0

    local totalAtt = {}
    local funStr = string.format("%s: %d", MaterialAtt[jtype].att, attValue)
    table.insert(totalAtt, {str = funStr, color = COLOR3.LIGHT_WHITE})

    local blueAtt = EquipmentMgr:getJewelryBule(self.jewelry)
    for i = 1,#blueAtt do
        table.insert(totalAtt, {str = blueAtt[i], color = COLOR3.BLUE})
    end

    -- 限定交易
    local limitTab = InventoryMgr:getLimitAtt(self.jewelry)
    if next(limitTab) then
        table.insert(totalAtt, {str = limitTab[1].str, color = COLOR3.RED})
    end

    for i = 1, Const.JEWELRY_ATTRIB_MAX - 1 do
        if totalAtt[i] then
            self:setLabelText("BaseAttributeLabel" .. i, totalAtt[i].str, nil, totalAtt[i].color)
        else
            self:setLabelText("BaseAttributeLabel" .. i, "")
        end
    end
end

function SubmitJewelryDlg:addSelectEff(sender)
    if self.selectImage then
        self.selectImage:removeFromParent()
        sender:addChild(self.selectImage)
    end
end

function SubmitJewelryDlg:onSubmitButton(sender, eventType)
    if not self.jewelry then return end

    if self.isTask then
        -- 安全锁判断
        if self:checkSafeLockRelease("onSubmitButton", sender, eventType) then
            return
        end

        local selectEquip = self.jewelry        -- 先记录，否则进入战斗该值会被清除
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SUBMIT_EQUIP, selectEquip.item_unique)
    else
        DlgMgr:sendMsg("JewelryUpgradeDlg", "setSelectJewelry", self.jewelry)
    end
    self:onCloseButton()
end

return SubmitJewelryDlg
