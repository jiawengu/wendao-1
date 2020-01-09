-- SubmitRefineJewelryDlg.lua
-- Created by huangzz Dec/17/2016
-- 首饰重铸提交界面

local SubmitRefineJewelryDlg = Singleton("SubmitRefineJewelryDlg", Dialog)

function SubmitRefineJewelryDlg:init()
    self:bindListener("SubmitButton", self.onSubmitButton)
    self:bindListViewListener("JewelryView", self.onSelectJewelryView)

    -- 克隆选中效果
    self.selectEff = self:getControl("ChosenEffectImage"):clone()
    self.selectEff:setVisible(true)
    self.selectEff:retain()

    -- 克隆单个Panel
    self.jewelryPanel = self:getControl("SingleJewelryPanel")
    self.jewelryPanel:retain()
    self.jewelryPanel:removeFromParent()
    
    self.checkedJewelry = {}
    self.checkedCount = 0
end

function SubmitRefineJewelryDlg:cleanup()
    self:releaseCloneCtrl("selectEff")
    self:releaseCloneCtrl("jewelryPanel")
end

function SubmitRefineJewelryDlg:setData(jewelrys, checkedJewelry)
    self.lastCheckedJewelry = checkedJewelry or {}
    
    self:initList(jewelrys)
end

function SubmitRefineJewelryDlg:initList(jewelrys)
    if #jewelrys == 0 then
        return
    end

    self.jewelrys = jewelrys

    local listView = self:resetListView("JewelryView", 0, ccui.ListViewGravity.centerHorizontal)

    for id, jewelry in pairs(jewelrys) do
        local singelPanel = self.jewelryPanel:clone()
        singelPanel:setTag(id)
        self:setJewelryPanel(jewelry, singelPanel)
        listView:pushBackCustomItem(singelPanel)
    end

    self:onSelectJewelryView(listView)
end

function SubmitRefineJewelryDlg:setJewelryPanel(jewelry, panel)
    if not jewelry then return end
    
    self:setImage("GuardImage", ResMgr:getItemIconPath(jewelry.icon), panel)
    self:setItemImageSize("GuardImage", panel)
    self:setLabelText("NameLabel", jewelry.name, panel)
    
    if jewelry.equip_type == EQUIP_TYPE.NECKLACE then
        self:setLabelText("TypeLabel", CHS[3003091] .. CHS[3002888], panel)
    elseif jewelry.equip_type == EQUIP_TYPE.BALDRIC then
        self:setLabelText("TypeLabel", CHS[3003091] .. CHS[3002887], panel)
    elseif jewelry.equip_type == EQUIP_TYPE.WRIST then
        self:setLabelText("TypeLabel", CHS[3003091] .. CHS[3002889], panel)
    end
    
    local guardImage = self:getControl("GuardImage", nil, panel)
    if InventoryMgr:isLimitedItem(jewelry)  then             
        InventoryMgr:addLogoBinding(guardImage)
    else
        InventoryMgr:removeLogoBinding(guardImage)
    end
    
    self:bindCheckBoxListener("CheckBox", self.onCheckBox, panel)
    
    local checkBox = self:getControl("CheckBox", Const.UICheckBox, panel)
    for _, v in pairs(self.lastCheckedJewelry) do
        if v.pos == jewelry.pos then
            checkBox:setSelectedState(true)
            self.checkedJewelry[checkBox] = v
            self.checkedCount = self.checkedCount + 1
            return
        end
    end
end

function SubmitRefineJewelryDlg:onCheckBox(sender, eventType)
   
    if sender:getSelectedState() then
        if self.checkedCount >= 3 then
            gf:ShowSmallTips(CHS[5400007])
            sender:setSelectedState(false)
            return
        end
        local parent = sender:getParent()
        local id = parent:getTag()
        if gf:isExpensive(self.jewelrys[id]) then
            gf:confirm(string.format(CHS[5400014]),
            function()
                self.checkedJewelry[sender] = self.jewelrys[id]
                self.checkedCount = self.checkedCount + 1
            end, 
            function()
                sender:setSelectedState(false)
            end)
            return
        end
        
        self.checkedJewelry[sender] = self.jewelrys[id]
        self.checkedCount = self.checkedCount + 1
    else
        self.checkedJewelry[sender] = nil
        
        self.checkedCount = self.checkedCount - 1
    end
end

function SubmitRefineJewelryDlg:onSubmitButton(sender, eventType)
    if self.checkedCount < 3 then
        gf:ShowSmallTips(CHS[5400011])
        return
    end
    
    DlgMgr:sendMsg("JewelryRefineDlg", "showRefineJewelry", self.checkedJewelry)
    self:close()
end

function SubmitRefineJewelryDlg:addSelectEffect(sender)
    self.selectEff:removeFromParent()
    sender:addChild(self.selectEff)
end

function SubmitRefineJewelryDlg:onSelectJewelryView(sender, eventType)
    -- 选中效果
    local panel = self:getListViewSelectedItem(sender)
    self:addSelectEffect(panel)

    local id = self:getListViewSelectedItemTag(sender)
    self:setJewelryAttrib(self.jewelrys[id])
end

function SubmitRefineJewelryDlg:setJewelryAttrib(jewelry)
    if not jewelry then return end

    -- 图标
    self:setImage("JewelryImage", InventoryMgr:getIconFileByName(jewelry.name))
    self:setItemImageSize("JewelryImage")
    
    -- 等级
    self:setNumImgForPanel("JewelryLevelPanel", ART_FONT_COLOR.NORMAL_TEXT, jewelry.req_level, false, LOCATE_POSITION.LEFT_TOP, 21)

    -- 名称
    local color = InventoryMgr:getItemColor(jewelry)
    self:setLabelText("JewelryNameLabel", jewelry.name, nil, color)
    -- 描述
    self:setLabelText("DescLabel", InventoryMgr:getDescript(jewelry.name))

    -- 属性
    local attValue, attStr
    if jewelry.equip_type == EQUIP_TYPE.NECKLACE then
        self:setLabelText("MainLabel2", CHS[3003091] .. CHS[3002888])
        attValue = jewelry.extra["max_mana_1"]
        attStr = CHS[4000110]
    elseif jewelry.equip_type == EQUIP_TYPE.BALDRIC then
        self:setLabelText("MainLabel2", CHS[3003091] .. CHS[3002887])
        attValue = jewelry.extra["max_life_1"]
        attStr = CHS[4000050]
    elseif jewelry.equip_type == EQUIP_TYPE.WRIST then
        self:setLabelText("MainLabel2", CHS[3003091] .. CHS[3002889])
        attValue = jewelry.extra["phy_power_1"]
        attStr = CHS[4000032]
    end

    local totalAtt = {}
    local funStr = string.format("%s: %d", attStr, attValue)
    table.insert(totalAtt, {str = funStr, color = COLOR3.LIGHT_WHITE})


    local blueAtt = EquipmentMgr:getJewelryBule(jewelry)
    for i = 1,#blueAtt do
        table.insert(totalAtt, {str = blueAtt[i], color = COLOR3.BLUE})
    end
    
    -- 限定交易
    local limitTab = InventoryMgr:getLimitAtt(jewelry)
    if next(limitTab) then
        table.insert(totalAtt, {str = limitTab[1].str, color = COLOR3.RED})
    end

    for i = 1, #totalAtt do
        self:setLabelText("BaseAttributeLabel" .. i, totalAtt[i].str, nil, totalAtt[i].color)
    end
    
    for i = #totalAtt + 1, 5 do
        self:setLabelText("BaseAttributeLabel" .. i, "")
    end
end

return SubmitRefineJewelryDlg
