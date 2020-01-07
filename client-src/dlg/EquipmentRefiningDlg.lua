-- EquipmentRefiningDlg.lua
-- Created by songcw July/30/2015
-- 装备炼化信息

local EquipmentRefiningDlg = Singleton("EquipmentRefiningDlg", Dialog)

local refiningBlue   = 1
local refiningPink   = 2
local refiningYellow = 3

function EquipmentRefiningDlg:init()
    for i = 1, 3 do
        self:bindListener("AttributeButton" .. i, self.onAttributeBlueButton)
        self:getControl("AttributeButton" .. i):setTag(i)
    end
    --    self:bindListener("CloseButton", self.onCloseButton)
    self:bindListener("AttributeButton4", self.onAttributePinkButton)
    self:getControl("AttributeButton4"):setTag(4)
    self:bindListener("AttributeButton5", self.onAttributeYellowButton)
    self:getControl("AttributeButton5"):setTag(5)

    self.selectAttButton = nil

    self:bindListener("RefiningButton", self.onRefiningButton)
    self:bindListener("StrengthenButton", self.onStrengthenButton)
    self:bindListener("BlueStrengthenButton", self.onBlueStrengthenButton)
    self:bindListener("InfoButton", self.onInfoButton)

    self:bindListener("GuideButton", self.onGuideButton)
    self:setCtrlVisible("GuideButton", EquipmentMgr:isShowGuideButton(self.name))

    local btnPanel = self:getControl("AttributeButton1")
    self.selectEff = self:getControl("BackImage", nil, btnPanel)
    self.selectEff:retain()
    self.selectEff:removeFromParent()
    self.selectEff:setLocalZOrder(0)
    self.selectEff:setVisible(true)


    self.refiningType = nil
    self:buttonInit()

    --    DlgMgr:openDlg("EquipmentChildDlg")
    EquipmentMgr:setTabList("EquipmentReformDlg")
end

function EquipmentRefiningDlg:onGuideButton()
    DlgMgr:openDlg("EquipArtificeGuideDlg")
end

function EquipmentRefiningDlg:cleanup()
    self:releaseCloneCtrl("selectEff")
end

function EquipmentRefiningDlg:buttonInit(refiningType)
    if not refiningType then
        self:setCtrlVisible("BlueStrengthenButton", true)
        self:setCtrlEnabled("BlueStrengthenButton", false)
        self:setCtrlVisible("StrengthenButton", false)
        self:setCtrlVisible("RefiningButton", false)
    elseif refiningType == refiningBlue then
        self:setCtrlEnabled("BlueStrengthenButton", true)
        self:setCtrlVisible("BlueStrengthenButton", true)
        self:setCtrlVisible("StrengthenButton", false)
        self:setCtrlVisible("RefiningButton", false)
    elseif refiningType == refiningPink then
        self:setCtrlEnabled("BlueStrengthenButton", true)
        self:setCtrlVisible("BlueStrengthenButton", false)
        self:setCtrlVisible("StrengthenButton", true)
        self:setCtrlVisible("RefiningButton", true)

        if self.pinkTab and self.pinkTab[1] then
            self:setCtrlEnabled("StrengthenButton", true)
        else
            self:setCtrlEnabled("StrengthenButton", false)
        end
    elseif refiningType == refiningYellow then
        self:setCtrlEnabled("BlueStrengthenButton", true)
        self:setCtrlVisible("BlueStrengthenButton", false)
        self:setCtrlVisible("StrengthenButton", true)
        self:setCtrlVisible("RefiningButton", true)

        if self.yellowTab and self.yellowTab[1] then
            self:setCtrlEnabled("StrengthenButton", true)
        else
            self:setCtrlEnabled("StrengthenButton", false)
        end
    end
end

function EquipmentRefiningDlg:setInfoByPos(pos, isUpdara, attInfo)
    if not isUpdara then
        self.blueTab = {}
        self.pinkTab = {}
        self.yellowTab = {}
        self:buttonInit()
        self.selectEff:removeFromParent()
    end

    if not pos then return end
    self.pos = pos
    local equip = InventoryMgr:getItemByPos(pos)
    if nil == equip then return end

        -- 容错处理
    if not EquipmentMgr:isEquipment(equip) then
        self:onCloseButton()
        return
    end

    -- 设置图标和名字
    local equipShap = self:getControl("OnePanel")
    self:setImage("EquipmentImage", ResMgr:getItemIconPath(equip.icon), equipShap)
    self:setItemImageSize("EquipmentImage", equipShap)
    local color = InventoryMgr:getEquipmentNameColor(equip)
    local suit = EquipmentMgr:getEquipPolarChs(equip.suit_polar)
    if not suit then suit = "" else suit = "(" .. suit .. ")" end
    self:setLabelText("EquipmentNameLabel", equip.name .. suit, equipShap, color)
    equipShap:requestDoLayout()

    -- 装备悬浮框
    local equipImage = self:getControl("EquipmentImage")
    self:bindTouchEndEventListener(equipImage, self.showEquipmentInfo, pos)

    local color, greenTab, yellowTab, pinkTab, blueTab = InventoryMgr:getEquipmentNameColor(equip)

    self.blueTab = blueTab
    -- 蓝属性
    for i = 1, 3 do
        local button = self:getControl("AttributeButton" .. i)
        button:setTag(i)
        local panel = self:getControl("Panel1", nil, button)
        if blueTab[i] then
            local str = self:getAttribChs(blueTab[i], true)
            blueTab[i].chsStr = str
            local displayPanel = self:getControl("Panel1", nil, panel)
            displayPanel:setVisible(true)
            local completion = EquipmentMgr:getAttribCompletion(equip, blueTab[i].field, refiningBlue)
            if completion and completion ~= 0 then
                -- 有完成度
                self:setValueStr(str .. "#R(+" .. (completion * 0.01) .. "%)#n", COLOR3.BLUE, panel)
            else
                self:setLabelText("AttributeLabel1", str, displayPanel)
                self:setValueStr(str, COLOR3.BLUE, panel)
            end
            self:setCtrlEnabled("AttributeButton" .. i, true)
        else
            self:setCtrlVisible("Panel1", false, panel)
            self:setCtrlEnabled("AttributeButton" .. i, false)
        end
    end

    -- 粉属性
    self.pinkTab = pinkTab
    local button = self:getControl("AttributeButton4")
    local displayPanel = self:getControl("Panel1", nil, button)
    displayPanel:setVisible(true)


    if #pinkTab == 1 then
        local str = self:getAttribChs(pinkTab[1], true)
        pinkTab[1].chsStr = str
        local completion = EquipmentMgr:getAttribCompletion(equip, pinkTab[1].field, refiningPink)
        if completion and completion ~= 0 then
            --[[ 有完成度
            local displayPanel = self:getControl("Panel2", nil, panel)
            displayPanel:setVisible(true)
            self:setCtrlVisible("Panel1", false, panel)
            self:setLabelText("AttributeLabel1", str, displayPanel, COLOR3.PURPLE)
            self:setLabelText("CompletionLabel", "(+" .. (completion * 0.01) .. "%)", displayPanel)
            --]]
            self:setValueStr(str .. "#R(+" .. (completion * 0.01) .. "%)#n", COLOR3.PURPLE, displayPanel)
        else
            local displayPanel = self:getControl("Panel1", nil, displayPanel)
            displayPanel:setVisible(true)
       --     self:setLabelText("AttributeLabel1", str, displayPanel, COLOR3.PURPLE)

            self:setValueStr(str, COLOR3.PURPLE, displayPanel)
        end
    else

   --     self:setLabelText("AttributeLabel1", "点击此处炼化粉属性", displayPanel, COLOR3.GRAY)
        self:setValueStr(CHS[3002485], COLOR3.GRAY, displayPanel)
    end

    -- 黄属性
    self.yellowTab = yellowTab
    local panel = self:getControl("AttributeButton5")
    local displayPanel = self:getControl("Panel1", nil, panel)
    displayPanel:setVisible(true)

    self:setCtrlVisible("Panel2", false, panel)
    if #yellowTab == 1 then
        local str = self:getAttribChs(yellowTab[1], true)
        yellowTab[1].chsStr = str
        local completion = EquipmentMgr:getAttribCompletion(equip, yellowTab[1].field, refiningYellow)
        if completion and completion ~= 0 then
            --[[ 有完成度
            local displayPanel = self:getControl("Panel2", nil, panel)
            displayPanel:setVisible(true)
            self:setCtrlVisible("Panel1", false, panel)
            self:setLabelText("AttributeLabel1", str, displayPanel, COLOR3.YELLOW)
            self:setLabelText("CompletionLabel", "(+" .. (completion * 0.01) .. "%)", displayPanel)

            --]]
            self:setValueStr(str .. "#R(+" .. (completion * 0.01) .. "%)#n", COLOR3.YELLOW, displayPanel)
        else

      --      self:setLabelText("AttributeLabel1", str, displayPanel, COLOR3.YELLOW)
            self:setValueStr(str, COLOR3.YELLOW, displayPanel)
        end
    else
        self:setCtrlVisible("Panel1", true, panel)

        self:setValueStr(CHS[3002486], COLOR3.GRAY, displayPanel)
    end

    if self.selectAttButton then
        if self.refiningType == refiningBlue then
            self:onAttributeBlueButton(self.selectAttButton)
        elseif self.refiningType == refiningPink then
            self:onAttributePinkButton(self.selectAttButton)
        elseif self.refiningType == refiningYellow then
            self:onAttributeYellowButton(self.selectAttButton)
        end
    end
end

function EquipmentRefiningDlg:setValueStr(str, defColor, panel)
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

function EquipmentRefiningDlg:showEquipmentInfo(sender, eventType, pos)
    local equipImage = self:getControl("EquipmentImage")
    local rect = self:getBoundingBoxInWorldSpace(equipImage)
    local equip = InventoryMgr:getItemByPos(pos)
    InventoryMgr:showEquipByEquipment(equip, rect, true)
end

function EquipmentRefiningDlg:getAttribChs(attrib, isMax)
    local bai = ""

    if EquipmentMgr:getAttribsTabByName(CHS[3002487])[attrib.field] then bai = "%" end

    if EquipmentMgr:getAttribChsOrEng(attrib.field) ~= nil then
        local str = EquipmentMgr:getAttribChsOrEng(attrib.field) .. ":" .. attrib.value .. bai
        local equip = InventoryMgr:getItemByPos(self.pos)
        local maxValue = EquipmentMgr:getAttribMaxValueByField(equip, attrib.field) or ""
        str = str .. "/" .. maxValue .. bai
        return str
    end
    return ""
end

function EquipmentRefiningDlg:addSelectEff(panel)
    if panel then
        self.selectEff:removeFromParent()
        panel:addChild(self.selectEff)
        self.selectAttButton = panel
    end
end


function EquipmentRefiningDlg:onAttributeBlueButton(sender, eventType)
    self.refiningType = refiningBlue
    self:buttonInit(refiningBlue)
    local data = self.blueTab[sender:getTag()]
    if nil == data then return end
    data.refiningType = refiningBlue

    self.selectAttrib = data
    self:addSelectEff(sender)
end

function EquipmentRefiningDlg:onAttributePinkButton(sender, eventType)
    self.refiningType = refiningPink
    self:buttonInit(refiningPink)
    if self.pinkTab and self.pinkTab[1] then
        local data = self.pinkTab[1]
        data.refiningType = refiningPink
        self.selectAttrib = data
    end

    self:addSelectEff(sender)
end

function EquipmentRefiningDlg:onAttributeYellowButton(sender, eventType)
    self.refiningType = refiningYellow
    self:buttonInit(refiningYellow)

    if self.yellowTab and self.yellowTab[1] then
        local data = self.yellowTab[1]
        data.refiningType = refiningYellow
        self.selectAttrib = data
    end

    self:addSelectEff(sender)
end

function EquipmentRefiningDlg:onRefiningButton(sender, eventType)
    local equip = InventoryMgr:getItemByPos(self.pos)
    if nil == equip then return end

    if not EquipmentMgr:judgeEquipAttribRefining(self.pos, self.refiningType) then
        return
    end

    if self.refiningType == 3 then
        if self.pinkTab and self.pinkTab[1] == nil then
            gf:ShowSmallTips(CHS[3002493])
            return
        end
        local dlg = DlgMgr:openDlg("EquipmentRefiningYellowDlg")
        dlg:setDlgInfo(equip, self.yellowTab)
    else
        local dlg = DlgMgr:openDlg("EquipmentRefiningPinkDlg")
        dlg:setDlgInfo(equip, self.pinkTab)
    end

end

function EquipmentRefiningDlg:onStrengthenButton(sender, eventType)
    local equip = InventoryMgr:getItemByPos(self.pos)
    if nil == equip then return end

    if not EquipmentMgr:judgeEquipAttribStrengthen(self.pos, self.selectAttrib) then
        return
    end

    local dlg = DlgMgr:openDlg("EquipmentStrengthenDlg")
    if self.selectAttrib.refiningType == 2 then
        self:onAttributePinkButton()
    else
        self:onAttributeYellowButton()
    end
    self.selectAttrib.req_level = equip.req_level
    self.selectAttrib.equip_type = equip.equip_type
    dlg:setAttribInfo(self.selectAttrib, equip)
end

function EquipmentRefiningDlg:onBlueStrengthenButton(sender, eventType)
    local equip = InventoryMgr:getItemByPos(self.pos)
    if nil == equip then return end

    if not EquipmentMgr:judgeEquipAttribBlueStrengthen(self.pos, self.selectAttrib) then
        return
    end

    self.selectAttrib.req_level = equip.req_level
    self.selectAttrib.equip_type = equip.equip_type
    local dlg = DlgMgr:openDlg("EquipmentStrengthenDlg")
    dlg:setAttribInfo(self.selectAttrib, equip)
end

function EquipmentRefiningDlg:onInfoButton(sender, eventType)
    local data = {one = CHS[4200594], two = CHS[4200594], isScrollToDef = true}
    DlgMgr:openDlgEx("EquipmentRuleNewDlg", data)
end

return EquipmentRefiningDlg
