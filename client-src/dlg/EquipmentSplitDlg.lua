-- EquipmentSplitDlg.lua
-- Created by songcw Jul/24/2015
-- 装备拆分界面

local EquipmentSplitDlg = Singleton("EquipmentSplitDlg", Dialog)

function EquipmentSplitDlg:init()
    self:bindListener("SplitButton", self.onSplitButton)
    self:bindListener("InfoButton", self.onInfoButton)

    self:bindListener("CostImage", self.onCostImage)

    self:bindListener("BindCheckBox", self.onBindCheckBox)
    self:bindListener("ChaosJadeCheckBox", self.onChaosJadeCheckBox)

    self:bindListener("GuideButton", self.onGuideButton)
    self:setCtrlVisible("GuideButton", EquipmentMgr:isShowGuideButton(self.name))

    EquipmentMgr:setTabList("EquipmentSplitDlg")

    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_UPDATE")
    self:MSG_UPDATE()

    local node = self:getControl("BindCheckBox", Const.UICheckBox)
    if InventoryMgr.UseLimitItemDlgs[self.name] == 1 then
        self:setCheck("BindCheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 0 then
        self:setCheck("BindCheckBox", false)
    end

    if InventoryMgr.UseLimitItemDlgs[self.name .. "hundunyu"] == 1 then
        self:setCheck("ChaosJadeCheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name .. "hundunyu"] == 0 then
        self:setCheck("ChaosJadeCheckBox", false)
    end

    self:onBindCheckBox(node, 2)
end

function EquipmentSplitDlg:onGuideButton()
    DlgMgr:openDlg("EquipSplitGuideDlg")
end

function EquipmentSplitDlg:setInfoByPos(pos)
    self.pos = pos
    local equipImagePanel = self:getControl("EquipmentImagePanel")
    if not pos then
        self:setCtrlVisible("EquipmentImage", false, equipImagePanel)
        self:setCtrlVisible("NoneEquipImage", true, equipImagePanel)
        self:setCtrlVisible("FrameImage", false, equipImagePanel)
        self:setLabelText("EquipmentNameLabel", "")
        for i = 1,5 do
            local panel = self:getControl("AttributePanel" .. i)
            self:setValueStr("", COLOR3.TEXT_DEFAULT, panel)
        end
        self:MSG_INVENTORY()

        local cashCostText, costfontColor = gf:getArtFontMoneyDesc(0)
        self:setNumImgForPanel("CostMoneyPanel", costfontColor, cashCostText, false, LOCATE_POSITION.CENTER, 23)
        self:updateLayout("OnePanel")
        return
    end
    self:setCtrlVisible("FrameImage", true, equipImagePanel)
    self:setCtrlVisible("NoneEquipImage", false)
    local equip = InventoryMgr:getItemByPos(pos)
    if nil == equip then return end
    local color = InventoryMgr:getEquipmentNameColor(equip)
    self:setLabelText("EquipmentNameLabel", equip.name, nil, color)
    self:setImage("EquipmentImage", InventoryMgr:getIconFileByName(equip.name))
    self:setItemImageSize("EquipmentImage")

    -- 装备悬浮框
    local equipImage = self:getControl("EquipmentImage")
    self:bindTouchEndEventListener(equipImage, self.showEquipmentInfo, pos)

    self:setAttrib(equip)
    self:setSplitCondition(equip)
    self:updateLayout("OnePanel")
end

function EquipmentSplitDlg:getSelectItemBox(clickItem)
    if clickItem == "BindCheckBox" then
        if self:isCheck("BindCheckBox") then
            return
        else
            return self:getBoundingBoxInWorldSpace(self:getControl("BindCheckBox"))
        end
    elseif clickItem == "ChaosJadeCheckBox" then
        if self:isCheck("ChaosJadeCheckBox") then
            return
        else
            return self:getBoundingBoxInWorldSpace(self:getControl("ChaosJadeCheckBox"))
        end
    end

end

function EquipmentSplitDlg:showEquipmentInfo(sender, eventType, pos)
    local equipImage = self:getControl("EquipmentImage")
    local rect = self:getBoundingBoxInWorldSpace(equipImage)
    local equip = InventoryMgr:getItemByPos(pos)
    InventoryMgr:showEquipByEquipment(equip, rect, true)
end

function EquipmentSplitDlg:setAttrib(equip)
    local blueAtt = EquipmentMgr:getBlueAttrib(equip.pos)
    local pinkAtt = EquipmentMgr:getPinkAttrib(equip.pos)
    local yellowAtt = EquipmentMgr:getYellowAttrib(equip.pos)

    local attrib = {}
    for i,att in pairs(blueAtt) do
        local bai = ""
        local attChs = EquipmentMgr:getAttribChsOrEng(att.field)
        local value = att.value
        if EquipmentMgr:getAttribsTabByName(CHS[3002555])[att.field] then bai = "%" end
        local maxValue = EquipmentMgr:getAttribMaxValueByField(equip, att.field) or ""
        local strChs = attChs .. " " .. value .. bai .. "/" .. maxValue .. bai
        table.insert(attrib, {attChs = strChs, color = COLOR3.BLUE, attType = 1, field = att.field})
    end

    for i,att in pairs(pinkAtt) do
        local bai = ""
        local attChs = EquipmentMgr:getAttribChsOrEng(att.field)
        local value = att.value
        if EquipmentMgr:getAttribsTabByName(CHS[3002555])[att.field] then bai = "%" end
        local maxValue = EquipmentMgr:getAttribMaxValueByField(equip, att.field) or ""
        local strChs = attChs .. " " .. value .. bai .. "/" .. maxValue .. bai
        table.insert(attrib, {attChs = strChs, color = COLOR3.PURPLE, attType = 2, field = att.field})
    end

    for i,att in pairs(yellowAtt) do
        local bai = ""
        local attChs = EquipmentMgr:getAttribChsOrEng(att.field)
        local value = att.value
        if EquipmentMgr:getAttribsTabByName(CHS[3002555])[att.field] then bai = "%" end
        local maxValue = EquipmentMgr:getAttribMaxValueByField(equip, att.field) or ""
        local strChs = attChs .. " " .. value .. bai .. "/" .. maxValue .. bai
        table.insert(attrib, {attChs = strChs, color = COLOR3.YELLOW, attType = 3, field = att.field})
    end

    self.attrib = attrib

    for i = 1,5 do
        local panel = self:getControl("AttributePanel" .. i)
        if attrib[i] then
            local comp = EquipmentMgr:getAttribCompletion(equip, attrib[i].field, attrib[i].attType)
            if comp and comp ~= 0 then
           --     self:setLabelText("CompletionLabel" .. i, "(+" .. (comp * 0.01) .. "%)", nil, COLOR3.RED)
                self:setValueStr(attrib[i].attChs .. "#R(+" .. (comp * 0.01) .. "%)#n", attrib[i].color, panel)
            else
           --     self:setLabelText("CompletionLabel" .. i, "", nil, COLOR3.RED)
                self:setValueStr(attrib[i].attChs, attrib[i].color, panel)
            end
        else
            self:setValueStr("", COLOR3.TEXT_DEFAULT, panel)
        end
    end
end

function EquipmentSplitDlg:setValueStr(str, defColor, panel)
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

function EquipmentSplitDlg:refreshBlackCrystal(equip)
    if not equip then equip = InventoryMgr:getItemByPos(self.pos) or {req_level = 0} end
    self:setImage("CostImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[3002556])))
    self:setItemImageSize("CostImage")

    local amountSuper = InventoryMgr:getAmountByNameIsForeverBind(CHS[3002556], self:isCheck("BindCheckBox"))
    local amountMini = InventoryMgr:getMiniBylevel(CHS[3002557], equip.req_level, self:isCheck("BindCheckBox"))
    local amount = amountSuper + amountMini
    if amount > 999 then amount = "*" end
    if amount == 0 then
        self:setNumImgForPanel("CostImage", ART_FONT_COLOR.RED, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
    else
        self:setNumImgForPanel("CostImage", ART_FONT_COLOR.NORMAL_TEXT, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
    end
end

function EquipmentSplitDlg:setSplitCondition(equip)
    if not equip then equip = InventoryMgr:getItemByPos(self.pos) end
    self:refreshBlackCrystal(equip)

    -- 拥有
    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("OwnMoneyPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 23)

    -- 消耗
    if equip then
        local cashCostText, costfontColor = gf:getArtFontMoneyDesc(EquipmentMgr:getSplitCostMoney(equip))
        self:setNumImgForPanel("CostMoneyPanel", costfontColor, cashCostText, false, LOCATE_POSITION.CENTER, 23)
    else
        local cashCostText, costfontColor = gf:getArtFontMoneyDesc(0)
        self:setNumImgForPanel("CostMoneyPanel", costfontColor, cashCostText, false, LOCATE_POSITION.CENTER, 23)
    end
end

function EquipmentSplitDlg:onBindCheckBox(sender, eventType)
    self:MSG_INVENTORY()

    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
    end
end

function EquipmentSplitDlg:onChaosJadeCheckBox(sender, eventType)
    if self:isCheck("ChaosJadeCheckBox") then
        gf:ShowSmallTips(CHS[3002558])
    end

    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name .. "hundunyu", 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name .. "hundunyu", 0)
    end
end

function EquipmentSplitDlg:getSplitPara()
    local isGift = self:isCheck("BindCheckBox")
    local isCostYu = self:isCheck("ChaosJadeCheckBox")

    if not isGift and not isCostYu then
        return "0"
    elseif isGift and isCostYu then
        return "3"
    elseif not isGift and isCostYu then
        return "2"
    else
        return "1"
    end
end

function EquipmentSplitDlg:isCompletion(equip)
    if self.attrib and self.attrib[1] then
        for i = 1,5 do
            if self.attrib[i] then
                local comp = EquipmentMgr:getAttribCompletion(equip, self.attrib[i].field, self.attrib[i].attType)
                if comp and comp ~= 0 then
                    return true
                end
            end
        end
    end
    return false
end

function EquipmentSplitDlg:checkEnough(equip)
    local isGift = self:isCheck("BindCheckBox")
    local isCostYu = self:isCheck("ChaosJadeCheckBox")
    local items = {}

    if isCostYu then
        local superYu = InventoryMgr:getAmountByNameIsForeverBind(CHS[3002559], self:isCheck("BindCheckBox"))
        local miniYu = InventoryMgr:getMiniBylevel(CHS[3002560], equip.req_level, self:isCheck("BindCheckBox"))
        if superYu + miniYu < 1 then
            items[CHS[3002559]] = 1
        end
    end

    local superCrystal = InventoryMgr:getAmountByNameIsForeverBind(CHS[3002556], self:isCheck("BindCheckBox"))
    local miniCrystal = InventoryMgr:getMiniBylevel(CHS[3002557], equip.req_level, self:isCheck("BindCheckBox"))
    if superCrystal + miniCrystal < 1 then
        items[CHS[3002556]] = 1
    end

    if next(items) ~= nil then
        gf:askUserWhetherBuyItem(items)
        return false
    end

    local cash = EquipmentMgr:getSplitCostMoney(equip)
    if cash > Me:queryBasicInt("cash") then
        gf:askUserWhetherBuyCash()
        return false
    end

    return true
end

function EquipmentSplitDlg:onSplitButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if not self.pos then
        gf:ShowSmallTips(CHS[3002562])
        return
    end

    local equip = InventoryMgr:getItemByPos(self.pos)
    if nil == equip then return end

    -- 限时装备
    if InventoryMgr:isTimeLimitedItem(equip) then
        gf:ShowSmallTips(CHS[5420219])
        return
    end

    if not InventoryMgr:getFirstEmptyPos() then
        gf:ShowSmallTips(CHS[3002563])
        return
    end

    -- 道具不足检查
    if not self:checkEnough(equip) then return end

    local limitCount = 0
    local num = 0
    if self:isCheck("ChaosJadeCheckBox") then
        limitCount = InventoryMgr:getAmountByNameForeverBindLevel(CHS[3002560], equip.req_level) + InventoryMgr:getAmountByNameForeverBind(CHS[3002559])
        if InventoryMgr:getAmountByNameForeverBindLevel(CHS[3002560], equip.req_level) + InventoryMgr:getAmountByNameForeverBind(CHS[3002559]) > 0 then
            -- 如果使用的是限制交易的混沌玉
            num = num + 1
        end
    end

    limitCount = limitCount + InventoryMgr:getAmountByNameForeverBind(CHS[3002556]) + InventoryMgr:getAmountByNameForeverBindLevel(CHS[3002557], equip.req_level)
    if InventoryMgr:getAmountByNameForeverBind(CHS[3002556]) + InventoryMgr:getAmountByNameForeverBindLevel(CHS[3002557], equip.req_level) > 0 then
        -- 如果使用的限制交易的黑水晶
        num = num + 1
    end

    if self:isCompletion(equip) then
        gf:confirm(CHS[3002564], function()
            if self:isCheck("BindCheckBox") and limitCount > 0 then
                gf:confirm(string.format(CHS[5000241], 10 * num), function()
                    EquipmentMgr:cmdSplitEquip(self.pos, self:getSplitPara())
                end)
            else
                EquipmentMgr:cmdSplitEquip(self.pos, self:getSplitPara())
            end
        end)
    else
        if self:isCheck("BindCheckBox") and limitCount > 0 then
            gf:confirm(string.format(CHS[5000241], 10 * num), function()
                EquipmentMgr:cmdSplitEquip(self.pos, self:getSplitPara())
            end)
        else
            EquipmentMgr:cmdSplitEquip(self.pos, self:getSplitPara())
        end
    end
end

function EquipmentSplitDlg:cleanup()
    self.pos = nil
end

function EquipmentSplitDlg:onCostImage(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[3002556], rect)
end

function EquipmentSplitDlg:onInfoButton(sender, eventType)
    local data = {one = CHS[4200599], isScrollToDef = true}
    DlgMgr:openDlgEx("EquipmentRuleNewDlg", data)
end

function EquipmentSplitDlg:MSG_INVENTORY(data)
    self:refreshBlackCrystal()
end

function EquipmentSplitDlg:MSG_UPDATE(data)
    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("OwnMoneyPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 23)
end

return EquipmentSplitDlg
