-- EquipmentSelectDlg.lua
-- Created by songcw July/29/2015
-- 选中黑水晶

local EquipmentSelectCrystalDlg = Singleton("EquipmentSelectCrystalDlg", Dialog)

EquipmentSelectCrystalDlg.takePos = {}

local reform_type = 1
local strength_type = 2

function EquipmentSelectCrystalDlg:init()
    self.itemPanel = self:getControl("ItemPanel")
    self.itemPanel:retain()
    self.itemPanel:removeFromParent()

    self.dlgType = nil
    self.equip = nil
end

function EquipmentSelectCrystalDlg:cleanup()
    self:releaseCloneCtrl("itemPanel")
end

function EquipmentSelectCrystalDlg:setCrystalInfoByAttribute(attributeInfo)
    self.dlgType = strength_type
    local crystals = InventoryMgr:getBlackCrystalByLevelAndField(attributeInfo.req_level, attributeInfo.field)
    local count = #crystals
    if count == 0 then
        self:setCtrlVisible("ItemListView", false)
        self:setCtrlVisible("NoticePanel", true)
    else
        self:setCtrlVisible("ItemListView", true)
        self:setCtrlVisible("NoticePanel", false)
    end

    local panelCount = math.floor(count / 2) + count % 2
    local crystalListView = self:resetListView("ItemListView")
    for i = 1,panelCount do
        local panel = self.itemPanel:clone()
        self:setCrystalPanel((i - 1) * 2 + 1, crystals, panel)
        crystalListView:pushBackCustomItem(panel)
    end
    local labelPanel = self:getControl("LabelPanel")
    self:setLabelText("InfoLabel2", CHS[3002535], labelPanel)
    self:setLabelText("InfoLabel3", CHS[3002536], labelPanel)
    self:setLabelText("InfoLabel", CHS[3002537])
end

function EquipmentSelectCrystalDlg:setCrystalInfo(equip, index, haveAtt)
    self.parentIndex = index
    self.dlgType = reform_type
    self.haveAtt = haveAtt
    for i = 1,3 do
        if not haveAtt[i] then self.takePos[i] = nil end
    end
    self.equip = equip
    local crystals = InventoryMgr:getBlackCrystalByLevelAndPart(equip.req_level, EquipmentMgr:getEquipParentType(equip.equipType))
    crystals = self:getOrserCrystals(crystals)

    local count = #crystals
    if count == 0 then
        self:setCtrlVisible("ItemListView", false)
        self:setCtrlVisible("NoticePanel", true)
    else
        self:setCtrlVisible("ItemListView", true)
        self:setCtrlVisible("NoticePanel", false)
    end

    local panelCount = math.floor(count / 2) + count % 2
    local crystalListView = self:resetListView("ItemListView")
    for i = 1,panelCount do
        local panel = self.itemPanel:clone()
        self:setCrystalPanel((i - 1) * 2 + 1, crystals, panel)
        crystalListView:pushBackCustomItem(panel)
    end

    local labelPanel = self:getControl("LabelPanel")
    self:setLabelText("InfoLabel2", CHS[3002538], labelPanel)
    self:setLabelText("InfoLabel3", CHS[3002539], labelPanel)
    self:setLabelText("InfoLabel", CHS[3002540])

    self:updateLayout("LabelPanel")
end

function EquipmentSelectCrystalDlg:setCrystalPanel(index, crystals, panel)
    for i = 1,2 do
        local crystalPanel = self:getControl("CrystalPanel" .. i, nil, panel)
        if (index + i - 1) <= #crystals then
            local cutPos = gf:findStrByByte(crystals[index + i - 1].name, CHS[3002541])
            local strAtt
            if cutPos then
                strAtt = string.sub(crystals[index + i - 1].name, cutPos + 2, -1)
            else
                strAtt = crystals[index + i - 1].name
            end
            crystalPanel:setTag(index + i - 1)
            self:setLabelText("NameLabel", strAtt, crystalPanel)
            self:setImage("IconImage", ResMgr:getItemIconPath(crystals[index + i - 1].icon), crystalPanel)
            self:setItemImageSize("IconImage", crystalPanel)
            self:setNumImgForPanel("IconImage", ART_FONT_COLOR.NORMAL_TEXT, crystals[index + i - 1].level, false, LOCATE_POSITION.LEFT_TOP, 21, crystalPanel)

            local strValue = self:getAttValue(crystals[index + i - 1])
            self:setLabelText("ValueLabel", strValue, crystalPanel)

            local item = crystals[index + i - 1]
            local data = {strValue = strValue, strAtt = strAtt, icon = item.icon, pos = item.pos, gift = item.gift, item_unique = item.item_unique,level = item.level}
            local button = self:getControl("RealButton", nil, crystalPanel)
            self:bindTouchEndEventListener(button, self.onChooseCrystal, data)
            self:bindListener("ButtonBackImage", function ()
                gf:ShowSmallTips(CHS[3002542])
            end, crystalPanel)

            local iconPanel = self:getControl("IconPanel", Const.UIPanel, crystalPanel)
            self:bindTouchEndEventListener(iconPanel, self.showItemInfo, item.pos)

            for i = 1, 3 do
                if self.dlgType == reform_type and self.takePos[i] == item.pos and self.parentIndex ~= i then
                    local iPanel = self:getControl("IconPanel", nil, crystalPanel)
                    self:setCtrlEnabled("IconImage", false, iPanel)
                    self:setCtrlEnabled("BackImage", false, iPanel)
                    local buttonBackImage = self:getControl("ButtonBackImage", nil, crystalPanel)
                    buttonBackImage:setVisible(true)
                    gf:grayImageView(buttonBackImage)
                    button:setVisible(false)
                end
            end
        else
            crystalPanel:setVisible(false)
        end
    end
end

function EquipmentSelectCrystalDlg:showItemInfo(sender, eventType, pos)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local argTable = {}
    argTable.sell = false
    argTable.use = false

 --   InventoryMgr:showItemDescDlg(pos, rect, argTable)
  --  InventoryMgr:showBasicMessageDlg(name, rect)
    local item = InventoryMgr:getItemByPos(pos)
    InventoryMgr:showBasicMessageByItem(item, rect)
end


function EquipmentSelectCrystalDlg:getAttValue(crystalInfo)
    local equip = {req_level = crystalInfo.level, equip_type = crystalInfo.upgrade_type}
    local field, value
    local bai = ""
    for _,v in pairs(EquipmentMgr:getAttribsTabByName(CHS[4000098])) do
        -- 是否有蓝属性
        local blueAtt = string.format("%s_%d", v, Const.FIELDS_EXTRA1)
        if crystalInfo.extra[blueAtt] ~= nil then
            field = v
            value = crystalInfo.extra[blueAtt]
            if EquipmentMgr:getAttribsTabByName(CHS[3002543])[v] then bai = "%" end
            value = value .. bai
        end
    end
    local maxValue = EquipmentMgr:getAttribMaxValueByField(equip, field) or ""

    return value .. "/" .. maxValue .. bai
end

function EquipmentSelectCrystalDlg:getOrserCrystals(crystals)
    local orderCrystal = {}
    for i,v in pairs(crystals) do
        table.insert(orderCrystal, v)
    end

    table.sort(orderCrystal, function(l, r)
        if l.pos < r.pos then return true end
        if l.pos > r.pos then return false end
    end)

    return orderCrystal
end

function EquipmentSelectCrystalDlg:onChooseCrystal(sender, eventType, data)
    if sender.isPick then
        gf:ShowSmallTips(CHS[3002542])
        return
    end

    for i = 1, 3 do
        if self.dlgType == reform_type and self.haveAtt and self.haveAtt[i] and self.haveAtt[i].strAtt == data.strAtt and i ~= self.parentIndex then
            gf:ShowSmallTips(CHS[3002544])
            return
        end
    end

    data.index = self.parentIndex
    if self.dlgType == reform_type then
        self.takePos[data.index] = data.pos
    end
    DlgMgr:sendMsg("EquipmentReformDlg", "setCrystalInfo", data)
    DlgMgr:sendMsg("EquipmentStrengthenDlg", "setCrystalInfo", data)
    self:onCloseButton()
end

function EquipmentSelectCrystalDlg:onRealButton(sender, eventType)
end

function EquipmentSelectCrystalDlg:onSelectItemListView(sender, eventType)
end

function EquipmentSelectCrystalDlg:getSelectItemBox(clickItem)
    if self.dlgType == reform_type then
        local tag = 0
        local crystals = InventoryMgr:getBlackCrystalByLevelAndPart(self.equip.req_level, EquipmentMgr:getEquipParentType(self.equip.equipType))
        crystals = self:getOrserCrystals(crystals)
        local count = #crystals

        for i, cry in pairs(crystals) do
            if cry.attrib:isSet(ITEM_ATTRIB.ITEM_APPLY_ON_GUIDE) and clickItem == cry.name then
                tag = i
            end
        end

        local crystalListView = self:getControl("ItemListView")
        local items = crystalListView:getItems()
        local size = crystalListView:getInnerContainer():getContentSize()
        for i, item in pairs(items) do
            local panel = item:getChildByTag(tag)
            if panel then
                if (i + 1) * panel:getContentSize().height >= size.height then
                    crystalListView:getInnerContainer():setPositionY(-(#items - i) * panel:getContentSize().height)
                end
                return self:getBoundingBoxInWorldSpace(panel)
            end
        end
    else
    end


end

return EquipmentSelectCrystalDlg
