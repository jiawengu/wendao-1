-- EquipmentRefiningYellowDlg.lua
-- Created by songcw July/30/2015
-- 黄属性属性炼化界面

local EquipmentRefiningYellowDlg = Singleton("EquipmentRefiningYellowDlg", Dialog)

local MAX_COUNT = 6
local MIN_COUNT = 3

local REFING_STATE = {
    NOMAL = 1,          -- 正常状态
    HAS_REPLACE = 2,    -- 有可以替换
}

function EquipmentRefiningYellowDlg:init()
    self:bindListener("ReduceButton", self.onReduceButton)
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("MaxButton", self.onMaxButton)
    self:bindListener("RefiningButton", self.onRefiningButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("PreviewMaterialPanel", self.onGemItem)
    self:bindListener("CostImagePanel", self.onCrystal)
    self:bindListener("PreviewItemCheckBox", self.onGemCheckBox)
    self:bindListener("RestoreButton", self.onRestoreButton)    -- 重新炼化
    self:bindListener("ReplaceButton", self.onReplaceButton)    -- 替换属性


    self:bindListener("BindCheckBox", self.onBindCheckBox)
    self.costCount = MAX_COUNT
    self:setCountNum()
    self:MSG_UPDATE()
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:MSG_INVENTORY()

    local node = self:getControl("BindCheckBox", Const.UICheckBox)
    if InventoryMgr.UseLimitItemDlgs[self.name] == 1 then
        self:setCheck("BindCheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 0 then
        self:setCheck("BindCheckBox", false)
    end

    if InventoryMgr.UseLimitItemDlgs[self.name .. "Gem"] == 1 then
        self:setCheck("PreviewItemCheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name .. "Gem"] == 0 then
        self:setCheck("PreviewItemCheckBox", false)
    end
    self:onBindCheckBox(node, 2)
end

function EquipmentRefiningYellowDlg:setDlgInfo(equip, yellowTab)
    self.equip = equip
    self.yellowTab = yellowTab
    local panel = self:getControl("CostImagePanel")
    self:setImage("CostImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[3002522])), panel)
    self:setItemImageSize("CostImage", panel)

    local cashText, fontColor = gf:getArtFontMoneyDesc(self:getCostCash(equip))
    self:setNumImgForPanel("CostMoneyPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 19)
    if yellowTab and yellowTab[1] then
        self:setAttrib(yellowTab[1].chsStr)
    else
        self:setAttrib()
    end

    -- 设置预览属性信息
    local pre = EquipmentMgr:getEquipPre(equip, Const.FIELDS_PROP3_PREVIEW)
    if pre then
        local strChs = EquipmentMgr:getAttribChs(pre, true, equip)
        self:setPreAttrib(strChs)

        EquipmentRefiningYellowDlg:setDisplayBtn(REFING_STATE.HAS_REPLACE)
    else
        EquipmentRefiningYellowDlg:setDisplayBtn(REFING_STATE.NOMAL)
    end


    -- 设置宝石是否显示
    if (equip.req_level - equip.evolve_level) >= 70 and next(yellowTab) then
        self:setGemPanelVisible(true)
    else
        self:setGemPanelVisible(false)
    end

    self:MSG_INVENTORY()
end

function EquipmentRefiningYellowDlg:getSelectItemBox(clickItem)
    if clickItem == "BindCheckBox" then
        if self:isCheck("BindCheckBox") then
            return
        else
            return self:getBoundingBoxInWorldSpace(self:getControl("BindCheckBox"))
        end
    end
end

function EquipmentRefiningYellowDlg:setAttrib(strChs)
    local attPanel = self:getControl("AttributePanel")
    self:setLabelText("AttributeLabel1", "", attPanel)
    self:setLabelText("CompletionLabel", "", attPanel)
    self:setCtrlVisible("InfoImage", false, attPanel)
    if strChs == nil then
        self:setCtrlVisible("InfoImage", true, attPanel)
        return
    end
    local cutPos = gf:findStrByByte(strChs, ":")
    local attChs = string.sub(strChs, 1, cutPos - 1)
    local attValue = string.sub(strChs, cutPos + 1, -1)

    self:setLabelText("AttributeLabel1", strChs, attPanel, COLOR3.YELLOW)

    local value = EquipmentMgr:getAttribCompletion(self.equip, self.yellowTab[1].field, 3)
    if value and value ~= 0 then
        self:setLabelText("CompletionLabel", "(+" .. (value * 0.01) .. "%)")
    end
    self:updateLayout("AttributePanel")
end

function EquipmentRefiningYellowDlg:setPreAttrib(strChs)
    self:setLabelText("PreviewAttributeLabel1", "")
    self:setLabelText("PreviewCompletionLabel", "")

    local attPanel = self:getControl("PreviewAttributePanel")
    self:setCtrlVisible("InfoImage", false, attPanel)
    if strChs == nil then
        self:setCtrlVisible("InfoImage", true, attPanel)
        return
    end
    local cutPos = gf:findStrByByte(strChs, ":")
    local attChs = string.sub(strChs, 1, cutPos - 1)
    local attValue = string.sub(strChs, cutPos + 1, -1)
    self:setLabelText("PreviewAttributeLabel1", strChs, attPanel, COLOR3.YELLOW)

    self:updateLayout("PreviewAttributePanel")
end

function EquipmentRefiningYellowDlg:setValueStr(str, defColor, panel)
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

function EquipmentRefiningYellowDlg:getCostCash(equip)
    if not equip then return 0 end
    return EquipmentMgr:getRefiningYellowCost(equip.req_level)
end

function EquipmentRefiningYellowDlg:setCountNum()
    self:setLabelText("NumLabel", self.costCount)
    self:setLabelText("NumLabel2", self.costCount)
    if self.costCount == MIN_COUNT then
        gf:grayImageView(self:getControl("ReduceButton"))
    elseif self.costCount == MAX_COUNT then
        gf:grayImageView(self:getControl("AddButton"))
        self:setCtrlEnabled("ReduceButton", true)
    else
        self:setCtrlEnabled("ReduceButton", true)
        self:setCtrlEnabled("AddButton", true)
    end
end

function EquipmentRefiningYellowDlg:onReduceButton(sender, eventType)
    if self.costCount == MIN_COUNT then
        gf:ShowSmallTips(CHS[3002523])
        return
    end
    if self.costCount > MIN_COUNT then
        self.costCount = self.costCount - 1
    end
    self:setCountNum()
    self:MSG_INVENTORY()
end

function EquipmentRefiningYellowDlg:onAddButton(sender, eventType)
    if self.costCount == MAX_COUNT then
        gf:ShowSmallTips(CHS[3002524])
        return
    end

    if self.costCount < MAX_COUNT then
        self.costCount = self.costCount + 1
    end

    self:setCountNum()
    self:MSG_INVENTORY()
end

function EquipmentRefiningYellowDlg:onMaxButton(sender, eventType)
    self.costCount = MAX_COUNT
    self:setCountNum()
    self:MSG_INVENTORY()
end

function EquipmentRefiningYellowDlg:onCrystal(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[3002522], rect)
end

function EquipmentRefiningYellowDlg:onGemItem(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    if not self.equip then return end
    local gem = EquipmentMgr:getRefiningGemByEquip(self.equip)
    InventoryMgr:showBasicMessageDlg(gem, rect)
end

function EquipmentRefiningYellowDlg:onBindCheckBox(sender, eventType)
    self:MSG_INVENTORY()

    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
    end
end

function EquipmentRefiningYellowDlg:onRefiningButton(sender, eventType)
    if nil == self.equip then return end

    if not EquipmentMgr:judgeEquipAttribRefining(self.equip.pos, 3) then
        return
    end

    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    -- 道具不足判断
    local superCount = InventoryMgr:getAmountByNameIsForeverBind(CHS[3002522], self:isCheck("BindCheckBox"))
    local miniCount = InventoryMgr:getMiniBylevel(CHS[3002525], self.equip.req_level, self:isCheck("BindCheckBox"))
    if superCount + miniCount < self.costCount then
        gf:askUserWhetherBuyItem({[CHS[3002522]] = self.costCount - (superCount + miniCount) })
        return
    end

    -- 金钱不足
    local costCash = self:getCostCash(self.equip)
    if costCash > Me:queryBasicInt("cash") then
        gf:askUserWhetherBuyCash()
        return
    end

    -- 宝石状态
    local gemStr = "|0"

    -- 宝石不足判断
    if self:isCheck("PreviewItemCheckBox") and self:getCtrlVisible("PreviewItemCheckBox") then
        local gem = EquipmentMgr:getRefiningGemByEquip(self.equip)
        local gemCount = InventoryMgr:getAmountByNameIsForeverBind(gem, self:isCheck("BindCheckBox"))
        if gemCount < 1 then
            gf:ShowSmallTips(string.format(CHS[4100435], gem))
            return
        end

        gemStr = "|1"
    end


    local value
    if self.yellowTab and self.yellowTab[1] then
        value = EquipmentMgr:getAttribCompletion(self.equip, self.yellowTab[1].field, 3)
    end
    local bindCount = InventoryMgr:getAmountByNameForeverBind(CHS[3002522]) + InventoryMgr:getAmountByNameForeverBindLevel(CHS[3002525], self.equip.req_level)
    if value and value ~= 0 then
        -- 有完成度
        gf:confirm((CHS[3002526]), function()
            if self:isCheck("BindCheckBox") and bindCount > 0 then
                local days = 0
                if bindCount >= self.costCount then days = self.costCount * 10 else days = bindCount * 10 end
                local para = string.format("1|%d", self.costCount)
                local str, day = gf:converToLimitedTimeDay(self.equip.gift)
                if not InventoryMgr:isLimitedItemForever(self.equip) and day <= Const.LIMIT_TIPS_DAY then
                    gf:confirm(string.format(CHS[3002527], days), function()
                        EquipmentMgr:equipRefining("EquipmentRefiningYellowDlg", self.equip.pos, para .. gemStr)
                    end)
                else
                    EquipmentMgr:equipRefining("EquipmentRefiningYellowDlg", self.equip.pos, para .. gemStr)
                end
            else
                local para = string.format("0|%d", self.costCount)
                EquipmentMgr:equipRefining("EquipmentRefiningYellowDlg", self.equip.pos, para .. gemStr)
            end
        end)
    else
        -- 没有完成度
        if self:isCheck("BindCheckBox") and bindCount > 0 then
            local days = 0
            if bindCount >= self.costCount then days = self.costCount * 10 else days = bindCount * 10 end
            local para = string.format("1|%d", self.costCount)
            local str, day = gf:converToLimitedTimeDay(self.equip.gift)
            if not InventoryMgr:isLimitedItemForever(self.equip) and day <= Const.LIMIT_TIPS_DAY then
                gf:confirm(string.format(CHS[3002527], days), function()
                    EquipmentMgr:equipRefining("EquipmentRefiningYellowDlg", self.equip.pos, para .. gemStr)
                end)
            else
                EquipmentMgr:equipRefining("EquipmentRefiningYellowDlg", self.equip.pos, para .. gemStr)
            end
        else
            local para = string.format("0|%d", self.costCount)
            EquipmentMgr:equipRefining("EquipmentRefiningYellowDlg", self.equip.pos, para .. gemStr)
        end
    end
end

function EquipmentRefiningYellowDlg:onInfoButton(sender, eventType)
    local data = {one = CHS[4200594], two = CHS[4200601], isScrollToDef = true}
    DlgMgr:openDlgEx("EquipmentRuleNewDlg", data)
end

function EquipmentRefiningYellowDlg:MSG_INVENTORY(data)
    local level = 0
    if self.equip then
        level = self.equip.req_level

        if data then
            for i = 1, data.count do
                if data[i].pos == self.equip.pos then
                    self.equip = data[i]
                end
            end
        end
    end
    self:setImage("CostImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[3002522])))
    self:setItemImageSize("CostImage")
    local amountSuper = InventoryMgr:getAmountByNameIsForeverBind(CHS[3002522], self:isCheck("BindCheckBox"))
    local amountMini = InventoryMgr:getMiniBylevel(CHS[3002525], level, self:isCheck("BindCheckBox"))
    local amount = amountSuper + amountMini
    if amount > 999 then amount = "*" end

    local panel = self:getControl("CostImagePanel")
    if tonumber(amount) and amount < self.costCount then
        self:setNumImgForPanel("CostImage", ART_FONT_COLOR.RED, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21, panel)
    else
        self:setNumImgForPanel("CostImage", ART_FONT_COLOR.NORMAL_TEXT, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21, panel)
    end

    -- 设置宝石信息
    self:setGemPanelInfo(self.equip)
end

function EquipmentRefiningYellowDlg:MSG_UPDATE(data)
    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("OwnMoneyPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 19)
end

function EquipmentRefiningYellowDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_EQUIP_REFINE_OK == data.notify  then
        local equip = InventoryMgr:getItemByPos(self.equip.pos)
        if equip then
            local color, greenTab, yellowTab, pinkTab, blueTab = InventoryMgr:getEquipmentNameColor(equip)
            local strChs = EquipmentMgr:getAttribChs(yellowTab[1], true, equip)
            self.yellowTab = yellowTab
            self:setAttrib(strChs)

            -- 设置预览属性信息
            local pre = EquipmentMgr:getEquipPre(equip, Const.FIELDS_PROP3_PREVIEW)
            if pre then
                local strChs = EquipmentMgr:getAttribChs(pre, true, equip)
                self:setPreAttrib(strChs)

                EquipmentRefiningYellowDlg:setDisplayBtn(REFING_STATE.HAS_REPLACE)
            else
                EquipmentRefiningYellowDlg:setDisplayBtn(REFING_STATE.NOMAL)
                self:setPreAttrib()
            end

            -- 设置宝石是否显示
            if (equip.req_level - equip.evolve_level) >= 70 and next(yellowTab) then
                self:setGemPanelVisible(true)
            else
                self:setGemPanelVisible(false)
            end
        end
        DlgMgr:sendMsg("EquipmentRefiningDlg", "setInfoByPos", equip.pos, true)
        DlgMgr:sendMsg("EquipmentChildDlg", "updateListRefining")
    end
end

-- 设置宝石相关是否隐藏
function EquipmentRefiningYellowDlg:setGemPanelVisible(isVisible)
    self:setCtrlVisible("PreviewMaterialPanel", isVisible)
    self:setCtrlVisible("PreviewItemCheckBox", isVisible)
    self:setCtrlVisible("PreviewItemLabel", isVisible)
end

-- 点击宝石checkBox
function EquipmentRefiningYellowDlg:onGemCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        local gem = EquipmentMgr:getRefiningGemByEquip(self.equip)

        gf:ShowSmallTips(string.format(CHS[4100436], InventoryMgr:getUnit(gem), gem))

        InventoryMgr:setLimitItemDlgs(self.name .. "Gem", 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name .. "Gem", 0)
    end
end

-- 设置按钮状态
function EquipmentRefiningYellowDlg:setDisplayBtn(state)
    self:setCtrlVisible("RefiningButton", state == REFING_STATE.NOMAL)
    self:setCtrlVisible("RestoreButton", state == REFING_STATE.HAS_REPLACE)
    self:setCtrlVisible("ReplaceButton", state == REFING_STATE.HAS_REPLACE)
end

-- 设置宝石信息
function EquipmentRefiningYellowDlg:setGemPanelInfo(equip)
    local gemName = EquipmentMgr:getRefiningGemByEquip(equip)
    if not gemName then return end

    -- icon
    self:setImage("PreviewMaterialImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(gemName)))
    self:setItemImageSize("PreviewMaterialImage")
    -- 名称
    self:setLabelText("PreviewItemLabel", gemName)
    local amount = InventoryMgr:getAmountByNameIsForeverBind(gemName, self:isCheck("BindCheckBox"))
    if amount < 1 then
        self:setNumImgForPanel("PreviewMaterialPanel", ART_FONT_COLOR.RED, amount .. "/1", false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
    else
        if amount > 999 then
            self:setNumImgForPanel("PreviewMaterialPanel", ART_FONT_COLOR.DEFAULT, "*/1", false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
        else
            self:setNumImgForPanel("PreviewMaterialPanel", ART_FONT_COLOR.DEFAULT, amount .. "/1", false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
        end
    end

    self:updateLayout("CostPanel")
end

-- 还原属性
function EquipmentRefiningYellowDlg:onRestoreButton(sender, eventType)
--[[
    if not self.equip then return end
    EquipmentMgr:equipClearRefining(self.equip.pos, CHS[3002402])
    --]]
    self:onRefiningButton()
end

-- 替换属性
function EquipmentRefiningYellowDlg:onReplaceButton(sender, eventType)
    if not self.equip then return end

    gf:confirm(CHS[7200009], function()
        EquipmentMgr:equipApplyRefining(self.equip.pos, CHS[3002402])
    end)
end

return EquipmentRefiningYellowDlg
