-- EquipmentStrengthenDlg.lua
-- Created by songcw July/30/2015
-- 装备强化界面

local EquipmentStrengthenDlg = Singleton("EquipmentStrengthenDlg", Dialog)

function EquipmentStrengthenDlg:init()
    self:bindListener("StrengthenButton", self.onStrengthenButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("BindCheckBox", self.onBindCheckBox)

    self:bindListener("ItemImagePanel1", self.onAddBlackCrystal)
    self.equipPos = nil
    self.blackCrystal = nil
    -- 超级圣水晶
    local panel = self:getControl("ItemImagePanel2")
    self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[3002566])), panel)
    self:setItemImageSize("ItemImage", panel)
    self:bindTouchEndEventListener(panel, self.onRightCost)
    self:setAmountRightItem()

    self:MSG_UPDATE()
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_INVENTORY")

    local node = self:getControl("BindCheckBox", Const.UICheckBox)
    if InventoryMgr.UseLimitItemDlgs[self.name] == 1 then
        self:setCheck("BindCheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 0 then
        self:setCheck("BindCheckBox", false)
    end
    self:onBindCheckBox(node, 2)
end

-- 设置超级圣水晶
function EquipmentStrengthenDlg:setAmountRightItem()
    local amount = InventoryMgr:getAmountByNameIsForeverBind(CHS[3002566], self:isCheck("BindCheckBox"))
    if amount > 999 then amount = "*" end
    local panel = self:getControl("ItemImagePanel2")
    if amount == 0 then
        self:setNumImgForPanel("ItemImage", ART_FONT_COLOR.RED, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21, panel)
    else
        self:setNumImgForPanel("ItemImage", ART_FONT_COLOR.NORMAL_TEXT, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21, panel)
    end
end

function EquipmentStrengthenDlg:setValueStr(str, defColor, panel)
    panel:removeAllChildren()
    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(21)
    textCtrl:setString(str)
    textCtrl:setDefaultColor(defColor.r, defColor.g, defColor.b)
    textCtrl:setContentSize(size.width, 0)
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition((size.width - textW) * 0.5, (size.height + textH) * 0.5)
    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
end

function EquipmentStrengthenDlg:setAttribInfo(attribInfo, equip, crystal)
    self.equip = equip
    self.attribInfo = attribInfo

    -- 属性值
    local cutPoa = gf:findStrByByte(attribInfo.chsStr, ":")
    local valueStr = string.sub(attribInfo.chsStr, cutPoa + 1, -1)

    local defColor = COLOR3.BLUE
    if self.attribInfo.refiningType == 2 then
        defColor = COLOR3.PURPLE
    elseif self.attribInfo.refiningType == 3 then
        defColor = COLOR3.YELLOW
    end
    -- 完成度
    -- 属性名称
    self:setLabelText("AttributeLabel1", EquipmentMgr:getAttribChsOrEng(attribInfo.field) .. " " .. valueStr, nil, defColor)
    local value = EquipmentMgr:getAttribCompletion(equip, attribInfo.field, attribInfo.refiningType)
    if value and value ~= 0 then
        self:setLabelText("CompletionLabel", "(+" .. (value * 0.01) .. "%)")
    else
        self:setLabelText("CompletionLabel", "")
    end

    self:updateLayout("AttributePanel")

    if not crystal then
        -- 黑水晶
        local panel =self:getControl("ItemImagePanel1")
        self:setLabelText("AttributeLabel1", CHS[3002567], panel)
        --   self:setCtrlVisible("AttributeLabel2", false, panel)
        local image = self:getControl("ItemImage", nil, panel)
        image:loadTexture(ResMgr.ui.add_symbol, ccui.TextureResType.plistType)

        image:ignoreContentAdaptWithSize(true)
        self:getControl("ItemImage", nil, panel):removeAllChildren()
        self.blackCrystal = nil
    end

    -- 金钱消耗
    local cashText, fontColor = gf:getArtFontMoneyDesc(self:getCashCost())
    self:setNumImgForPanel("CostMoneyPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 19)
end

function EquipmentStrengthenDlg:getCashCost()
    if not self.equip then return 0 end
    return EquipmentMgr:getStrengthenCost(self.equip.req_level, self.equip.color)
end

function EquipmentStrengthenDlg:onStrengthenButton(sender, eventType)
    if self.blackCrystal == nil then
        gf:ShowSmallTips(CHS[3002572])
        return
    end

    local equip = {req_level = self.attribInfo.req_level, equip_type = self.attribInfo.equip_type}
    local maxValue = EquipmentMgr:getAttribMaxValueByField(equip, self.attribInfo.field)
    if self.attribInfo.value >= maxValue then
        gf:ShowSmallTips(CHS[3002573])
        return
    end

    if self.attribInfo.refiningType == 1 then
        -- 蓝属性强化
        if not EquipmentMgr:judgeEquipAttribBlueStrengthen(self.equip.pos, self.attribInfo) then
            return
        end
    else
        -- 粉黄属性强化
        if not EquipmentMgr:judgeEquipAttribStrengthen(self.equip.pos, self.attribInfo) then
            return
        end
    end

    -- 道具不足判断
    local superCount = InventoryMgr:getAmountByNameIsForeverBind(CHS[3002566], self:isCheck("BindCheckBox"))
    if superCount  < 1 then
        gf:askUserWhetherBuyItem(CHS[3002566])
        return
    end

    -- 金钱不足
    local costCash = self:getCashCost(self.equip)
    if costCash > Me:queryBasicInt("cash") then
        gf:askUserWhetherBuyCash()
        return
    end

    local costCount = 0
    if InventoryMgr:isLimitedItemForever(self.blackCrystal) then costCount = costCount + 1 end
    if InventoryMgr:getAmountByNameForeverBind(CHS[3002566]) > 0 then costCount = costCount + 1 end

    if self:isCheck("BindCheckBox") and costCount > 0 then
        local str, day = gf:converToLimitedTimeDay(self.equip.gift)
        if not InventoryMgr:isLimitedItemForever(self.equip) and day <= Const.LIMIT_TIPS_DAY then
            gf:confirm(string.format(CHS[3002574], costCount * 10), function()
                -- todo
                local para = string.format("%d|%s|%d", self.blackCrystal.pos, self.attribInfo.field, 1)
                EquipmentMgr:equipStrength(self.attribInfo.refiningType, self.equip.pos, para)
            end)
        else
            local para = string.format("%d|%s|%d", self.blackCrystal.pos, self.attribInfo.field, 1)
            EquipmentMgr:equipStrength(self.attribInfo.refiningType, self.equip.pos, para)
        end
    else
    -- todo
        local para = string.format("%d|%s|%d", self.blackCrystal.pos, self.attribInfo.field, 0)
        EquipmentMgr:equipStrength(self.attribInfo.refiningType, self.equip.pos, para)
    end
end

function EquipmentStrengthenDlg:onInfoButton(sender, eventType)
    local data = {one = CHS[4200594], two = CHS[4200602], isScrollToDef = true}
    DlgMgr:openDlgEx("EquipmentRuleNewDlg", data)
end

function EquipmentStrengthenDlg:onRightCost(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[3002566], rect)
end

function EquipmentStrengthenDlg:onAddBlackCrystal(sender, eventType)

    local dlg = DlgMgr:openDlg("EquipmentSelectCrystalDlg")
    dlg:setCrystalInfoByAttribute(self.attribInfo)
end

function EquipmentStrengthenDlg:onBindCheckBox(sender, eventType)
    self:setAmountRightItem()

    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
    end
end

function EquipmentStrengthenDlg:setCrystalInfo(data)
    self.blackCrystal = data
    local panel = self:getControl("ItemImagePanel1")
    self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[3002575])), panel)
    self:setItemImageSize("ItemImage", panel)
    self:setLabelText("AttributeLabel1", data.strAtt, panel)

    self:setNumImgForPanel("ItemImage", ART_FONT_COLOR.DEFAULT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)
end

function EquipmentStrengthenDlg:MSG_UPDATE(data)
    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("OwnMoneyPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 19)
end

function EquipmentStrengthenDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_EQUIP_STRENGTHEN_OK == data.notify  then
        local equip = InventoryMgr:getItemByPos(self.equip.pos)
        if equip then
            local color, greenTab, yellowTab, pinkTab, blueTab = InventoryMgr:getEquipmentNameColor(equip)
            if self.attribInfo.refiningType == 1 then
                for i, att in pairs(blueTab) do
                    if att.field == self.attribInfo.field then
                        self.attribInfo.chsStr = EquipmentMgr:getAttribChs(blueTab[i], true, equip)
                        self.attribInfo.value = blueTab[i].value
                    end
                end
            elseif self.attribInfo.refiningType == 2 then
                self.attribInfo.chsStr = EquipmentMgr:getAttribChs(pinkTab[1], true, equip)
                self.attribInfo.value = pinkTab[1].value
            elseif self.attribInfo.refiningType == 3 then
                self.attribInfo.chsStr = EquipmentMgr:getAttribChs(yellowTab[1], true, equip)
                self.attribInfo.value = yellowTab[1].value
            end
            local crystal = InventoryMgr:getItemById(self.blackCrystal.item_unique)
            self:setAttribInfo(self.attribInfo, equip, crystal)
        end
        self:setAmountRightItem()
        DlgMgr:sendMsg("EquipmentRefiningDlg", "setInfoByPos", equip.pos, true, self.attribInfo)
        DlgMgr:sendMsg("EquipmentChildDlg", "updateListRefining")
    end
end

function EquipmentStrengthenDlg:MSG_INVENTORY(data)
    if self.equip and data then
        for i = 1, data.count do
            if data[i].pos == self.equip.pos then
                self.equip = data[i]
            end
        end
    end
    self:setAmountRightItem()
end

return EquipmentStrengthenDlg
