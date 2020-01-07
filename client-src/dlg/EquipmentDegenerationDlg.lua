-- EquipmentDegenerationDlg.lua
-- Created by yangym Feb/16/2016
-- 装备退化

local EquipmentDegenerationDlg = Singleton("EquipmentDegenerationDlg", Dialog)

function EquipmentDegenerationDlg:init()
    self:bindListener("EvolveButton", self.onDegenerationButton)
    self:bindListener("RefiningButton", self.onExitButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("BindCheckBox", self.onBindCheckBox)
    self:bindListener("EquipmentImage", self.onEquipmentImage, "BaseLevelPanel")
    self:bindListener("EquipmentImage", self.onEquipmentImage, "LeftEquipPanel")
    self:bindListener("CostImage", self.onTianXingShiImage, "CostImagePanel1")
    self:bindListener("CostImage", self.onBaoShiImage, "CostImagePanel2")

    self.equip = nil
    self.oldEquipAttTab = {}
    self.attrValueExceedMax = {}

    if InventoryMgr.UseLimitItemDlgs[self.name] == 1 then
        self:setCheck("BindCheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 0 then
        self:setCheck("BindCheckBox", false)
    end

    self:hookMsg("MSG_PRE_UPGRADE_EQUIP")
    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_INVENTORY")
end

-- 永久限制交易勾选框
function EquipmentDegenerationDlg:onBindCheckBox(sender, eventType)
    self:refreshCost()
    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
    end
end

-- 刷新整个界面主函数
function EquipmentDegenerationDlg:setEquipByPos(pos)
    local equip = InventoryMgr:getItemByPos(pos)
    if not equip then
        return
    end

    -- 重置保存的数据
    self.equip = equip
    self.attrValueExceedMax = {}
    self.oldEquipAttTab = {}

    if equip.evolve_level == 0 then
        self:setCtrlVisible("EvolutionLevelPanel", false)
        self:setCtrlVisible("BaseLevelPanel", true)
        self:setCtrlVisible("NoneEquipImage", false, "BaseLevelPanel")
        self:refreshBaseLevelPanel()
    elseif equip.evolve_level > 0 then
        self:setCtrlVisible("EvolutionLevelPanel", true)
        self:setCtrlVisible("BaseLevelPanel", false)
        self:setCtrlVisible("NoneEquipImage", false, "LeftEquipPanel")
        self:setCtrlVisible("NoneEquipImage", false, "RightEquipPanel")
        self:refreshEvolutionLevelPanel()
    end
end

-- 不可退化装备界面显示
function EquipmentDegenerationDlg:refreshBaseLevelPanel()
    local equip = self.equip
    if not equip then
        return
    end

    local mainPanel = self:getControl("BaseLevelPanel")
    self:setEquipmentImage(equip, mainPanel)

    -- 进化等级
    EquipmentMgr:setEvolveStar(self, equip, self:getControl("StarPanel", nil, mainPanel))

    -- 各属性值
    local allAttribTab = EquipmentMgr:getAttInfoForEvolve(equip)
    local attMainPanel = self:getControl("AttributePanel", nil, mainPanel)
    for i = 1, 11 do
        local att = allAttribTab[i]
        local attPanelName = "ValuePanel" .. i
        if att then
            self:setColorText(att.str, attPanelName, mainPanel, nil, nil, att.color, nil, true)
        end
    end
    attMainPanel:requestDoLayout()
end

-- 可退化装备界面
function EquipmentDegenerationDlg:refreshEvolutionLevelPanel()
    local equip = self.equip
    if not equip then
        return
    end

    -- 获取装备退化的预览信息
    local newEquip
    local preDegenerationEquip = EquipmentMgr.preDegenerationEquip
    if preDegenerationEquip then
        newEquip = preDegenerationEquip[equip.pos]
    end

    if not newEquip then
        EquipmentMgr:degenerationPreEquip(equip.pos)
        return
    end

    -- 原装备信息
    self:setOldEquip(equip)

    -- 退化后装备预览信息
    self:setNewEquip(newEquip)

    -- 材料消耗信息
    self:refreshCost()
end

-- 消耗显示
function EquipmentDegenerationDlg:refreshCost()
    if not self.equip then
        return
    end

    -- 金钱相关
    local equip = self.equip
    local costCash = equip.req_level * 10000
    local meCash = Me:queryInt("cash")
    local costCashStr, costCashColor = gf:getArtFontMoneyDesc(costCash)
    local meCashStr, meCashColor = gf:getArtFontMoneyDesc(meCash)
    self:setNumImgForPanel("CostMoneyPanel", costCashColor, costCashStr, false, LOCATE_POSITION.CENTER, 21)
    self:setNumImgForPanel("OwnMoneyPanel", meCashColor, meCashStr, false, LOCATE_POSITION.CENTER, 21)

    -- 天星石
    self:setImage("CostImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[7002061])), "CostImagePanel1")
    local tianxingAmount = InventoryMgr:getAmountByNameIsForeverBind(CHS[7002061], self:isCheck("BindCheckBox"))
    self:setLabelText("CostNumLabel1", "/1", "EvolutionLevelPanel", COLOR3.TEXT_DEFAULT)
    if tianxingAmount < 1 then
        self:setLabelText("OwnNumLabel1", 0, "EvolutionLevelPanel", COLOR3.RED)
    elseif tianxingAmount <= 999 then
        self:setLabelText("OwnNumLabel1", tianxingAmount, "EvolutionLevelPanel", COLOR3.TEXT_DEFAULT)
    else
        self:setLabelText("OwnNumLabel1", "*", "EvolutionLevelPanel", COLOR3.TEXT_DEFAULT)
    end

    -- 芙蓉石/红宝石/蓝宝石
    local costItem = EquipmentMgr:getEquipmentDegenerationCost(equip.req_level)
    self.costItem = costItem
    local costItemName = costItem.name
    local costItemNum = costItem.num
    if not costItemName or not costItemNum then
        return
    end

    self:setImage("CostImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(costItemName)), "CostImagePanel2")
    local amount = InventoryMgr:getAmountByNameIsForeverBind(costItemName, self:isCheck("BindCheckBox"))
    self:setLabelText("CostNumLabel2", "/" .. costItemNum, "EvolutionLevelPanel", COLOR3.TEXT_DEFAULT)
    if amount < costItemNum then
        self:setLabelText("OwnNumLabel2", amount, "EvolutionLevelPanel", COLOR3.RED)
    elseif amount <= 999 then
        self:setLabelText("OwnNumLabel2", amount, "EvolutionLevelPanel", COLOR3.TEXT_DEFAULT)
    else
        self:setLabelText("OwnNumLabel2", "*", "EvolutionLevelPanel", COLOR3.TEXT_DEFAULT)
    end

    self:updateLayout("CostPanel")
end

-- 可退化装备的原始装备显示
function EquipmentDegenerationDlg:setOldEquip(equip)
    local leftEquipPanel = self:getControl("LeftEquipPanel")
    self:setEquipmentImage(equip, leftEquipPanel)

    -- 进化等级
    local mainPanel = self:getControl("EvolutionLevelPanel")
    EquipmentMgr:setEvolveStar(self, equip, self:getControl("StarPanel", nil, mainPanel))

    -- 原始属性值
    local allAttribTab = EquipmentMgr:getAttInfoForEvolve(equip)
    self.oldEquipAttTab = allAttribTab

    local attOldPanel = self:getControl("OldPanel")
    for i = 1, 11 do
        local att = allAttribTab[i]
        local attPanel = self:getControl("AttributePanel" .. i, nil, attOldPanel)
        local arrLabel = self:getControl("Label_" .. i, nil, "ArrowPanel")
        if att then
            if att.basic then
                self:setLabelText("FieldLabel", att.attChs, attPanel, att.field_color)
                self:setLabelText("valueLabel", att.value, attPanel, att.value_color)
            else
                self:setLabelText("FieldLabel", "", attPanel, att.color)
                self:setLabelText("valueLabel", att.str, attPanel, att.color)
            end
            arrLabel:setVisible(true)
        else
            self:setLabelText("FieldLabel", "", attPanel)
            self:setLabelText("valueLabel", "", attPanel)
            arrLabel:setVisible(false)
        end
        attPanel:requestDoLayout()
    end
    attOldPanel:requestDoLayout()
end

-- 可退化装备的退化装备预览
function EquipmentDegenerationDlg:setNewEquip(equip)
    if not equip then
        return
    end

    local rightEquipPanel = self:getControl("RightEquipPanel")
    self:setEquipmentImage(equip, rightEquipPanel)

    -- 退化预览属性值
    local allAttribTab = EquipmentMgr:getAttInfoForEvolve(equip)
    local attPanel = self:getControl("NewPanel")
    for i = 1, 11 do
        local att = allAttribTab[i]
        if att then
            if att.basic then
                self:setLabelText("valueLabel" .. i, att.value, attPanel, att.value_color)
            else
                if self:isSameColor(att.color, COLOR3.EQUIP_BLUE) or
                   self:isSameColor(att.color, COLOR3.EQUIP_PINK) or
                   self:isSameColor(att.color, COLOR3.YELLOW)     then
                    -- 蓝粉金属性退化后可能当前属性值会大于最大属性
                    if self.oldEquipAttTab and att.value < self.oldEquipAttTab[i].value then
                        table.insert(self.attrValueExceedMax, {str = self.oldEquipAttTab[i].str, color = att.color})
                    end
                end

                self:setLabelText("valueLabel" .. i, att.str, attPanel, att.color)
            end
        else
            self:setLabelText("valueLabel" .. i, "", attPanel)
        end
    end
    attPanel:requestDoLayout()
end

function EquipmentDegenerationDlg:isSameColor(color1, color2)
    if color1.r and color1.g and color1.b and color2.r and color2.g and color2.b then
        if color1.r == color2.r and color1.g == color2.g and color1.b == color2.b then
            return true
        end
    end
    return false
end

-- 装备图标、等级、名称显示（通用函数）
function EquipmentDegenerationDlg:setEquipmentImage(equip, panel)
    if not equip then
        return
    end

    self:setImage("EquipmentImage", InventoryMgr:getIconFileByName(equip.name), panel)

    local equipmentColor = InventoryMgr:getEquipmentNameColor(equip)
    self:setLabelText("EquipmentNameLabel", equip.name, panel, equipmentColor)

    self:setNumImgForPanel("EquipmentImagePanel", ART_FONT_COLOR.NORMAL_TEXT, equip.req_level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)
end

-- 点击弹出名片
function EquipmentDegenerationDlg:onEquipmentImage(sender, eventType)
    if not self.equip then
        return
    end

    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showEquipByEquipment(self.equip, rect, true)
end

-- 天星石弹出名片
function EquipmentDegenerationDlg:onTianXingShiImage(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[7002061], rect)
end

-- 其他宝石弹出名片
function EquipmentDegenerationDlg:onBaoShiImage(sender, eventType)
    if self.costItem and self.costItem.name then
        local rect = self:getBoundingBoxInWorldSpace(sender)
        InventoryMgr:showBasicMessageDlg(self.costItem.name, rect)
    end
end

-- 退化按钮
function EquipmentDegenerationDlg:onDegenerationButton()
    local equip = self.equip

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if GameMgr.inCombat and EquipmentMgr:isValidEquipPos(self.equip.pos) then
        gf:ShowSmallTips(CHS[7002060])
        return
    end

    if not self.equip then
        gf:ShowSmallTips(CHS[7002062])
        return
    end

    -- 限时装备
    if InventoryMgr:isTimeLimitedItem(self.equip) then
        gf:ShowSmallTips(CHS[5420219])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onDegenerationButton") then
        return
    end

    -- 一系列确认操作
    self:confirmStep(1)
end

function EquipmentDegenerationDlg:confirmStep(step)
    if step == 1 then
        -- 等级差导致丢失绿属性
        local isConfirm, tips = EquipmentMgr:degenerationPreEquipLoseGreen(self.equip, 1)
        if isConfirm then
            gf:confirm(tips,
            function ()
                return self:confirmStep(2)
            end)
            return
        end

        return self:confirmStep(2)
    elseif step == 2 then
        -- 等级段不同丢失绿属性
        local isConfirm, tips = EquipmentMgr:degenerationPreEquipLoseGreen(self.equip, 2)
        if isConfirm then
            gf:confirm(tips, function ()
                return self:confirmStep(3)
            end)
            return
        end

        return self:confirmStep(3)
    elseif step == 3 then

        -- 是否有预览属性
        local preProp2 = EquipmentMgr:getEquipPre(self.equip, Const.FIELDS_PROP2_PREVIEW)
        local preProp3 = EquipmentMgr:getEquipPre(self.equip, Const.FIELDS_PROP3_PREVIEW)
        local preProp4 = EquipmentMgr:getEquipPre(self.equip, Const.FIELDS_PROP4_PREVIEW)
        local preSuit = EquipmentMgr:getEquipPre(self.equip, Const.FIELDS_SUIT_PREVIEW)
        if preProp2 or preProp3 or preProp4 or preSuit then
            gf:confirm(CHS[7002067], function()
                return self:confirmStep(4)
            end)
            return
        end

        return self:confirmStep(4)
    elseif step == 4 then
        -- 是否有强化进度
        local haveCompetition = false
        local color, greenTab, yellowTab, pinkTab, blueTab = InventoryMgr:getEquipmentNameColor(self.equip)
        local attTab = {blueTab, pinkTab, yellowTab}
        local colorType = {1, 2, 3}
        for i = 1, #attTab do
            for _, att in pairs(attTab[i]) do
                local competition = EquipmentMgr:getAttribCompletion(self.equip, att.field, colorType[i])
                if competition and competition ~= 0 then
                    haveCompetition = true
                end
            end
        end

        if haveCompetition then
            gf:confirm(CHS[7002068], function()
                return self:confirmStep(5)
            end)
            return
        end

        return self:confirmStep(5)
    elseif step == 5 then
        -- 是否属性数值 >= 装备退化后该属性的最大值
        local attribValueExceedMax = self.attrValueExceedMax
        if #attribValueExceedMax > 0 then
            local tip = ""
            for i = 1, #attribValueExceedMax do
                local color = attribValueExceedMax[i].color
                local colorStr

                if self:isSameColor(color, COLOR3.EQUIP_BLUE) then
                    colorStr = "#B"
                elseif self:isSameColor(color, COLOR3.EQUIP_PINK) then
                    colorStr = "#O"
                elseif self:isSameColor(color, COLOR3.YELLOW) then
                    colorStr = "#Y"
                end

                local str = colorStr .. attribValueExceedMax[i].str .. "#n"
                if i == #attribValueExceedMax then
                    tip = tip .. str
                else
                    tip = tip .. str .. CHS[7002070]
                end
            end

            gf:confirm(string.format(CHS[7002077], tip), function()
                return self:confirmStep(6)
            end)
            return
        end

        return self:confirmStep(6)
    elseif step == 6 then
        -- 钱是否足够
        local costCash = self.equip.req_level * 10000
        local meCash = Me:queryInt("cash")
        if costCash > meCash then
            gf:askUserWhetherBuyCash()
        else
            return self:confirmStep(7)
        end
    elseif step == 7 then
        -- 天星石是否足够
        local isTianXingShiReady = true
        local tianxingAmount = InventoryMgr:getAmountByNameIsForeverBind(CHS[7002061], self:isCheck("BindCheckBox"))
        if tianxingAmount < 1 then
            isTianXingShiReady = false
        end

        -- 其他宝石是否足够
        local isBaoShiReady = true
        if not self.costItem or not self.costItem.name or not self.costItem.num then
            return
        end

        local costItemName = self.costItem.name
        local costItemNum = self.costItem.num
        local amount = InventoryMgr:getAmountByNameIsForeverBind(costItemName, self:isCheck("BindCheckBox"))
        if costItemNum > amount then
            isBaoShiReady = false
        end

        local tip
        if isBaoShiReady and not isTianXingShiReady then
            tip = "#R" .. CHS[7002061] .. "#n"
        elseif not isBaoShiReady and isTianXingShiReady then
            tip = "#R" .. costItemName .. "#n"
        elseif not isBaoShiReady and not isTianXingShiReady then
            tip = "#R" .. CHS[7002061] .. "#n" .. CHS[7002070] .. "#R" .. costItemName .. "#n"
        end

        if tip then
            gf:ShowSmallTips(string.format(CHS[7002069], tip))
        else
            self:confirmStep(8)
        end
    elseif step == 8 then
        -- 增加的限制交易时间计算
        local limiTab, str, day = InventoryMgr:getLimitAtt(self.equip)
        local costItemName = self.costItem.name
        local costItemNum = self.costItem.num
        local useLimitedItemAmount = 0
        if self:isCheck("BindCheckBox") then
            local tianXingShi = InventoryMgr:getItemArrayByCostOrder(CHS[7002061], true)
            if InventoryMgr:isLimitedItemForever(tianXingShi[1]) then
                useLimitedItemAmount = useLimitedItemAmount + 1
            end

            local baoShi = InventoryMgr:getItemArrayByCostOrder(costItemName, true)
            local num = 0
            for i = 1, #baoShi do
                if num < costItemNum then
                    local costNum = math.min(costItemNum - num, baoShi[i].amount)
                    if InventoryMgr:isLimitedItemForever(baoShi[i]) then
                        useLimitedItemAmount = useLimitedItemAmount + costNum
                    end

                    num = num + costNum
                end
            end
        end

        if self:isCheck("BindCheckBox") then
            if day <= 59 and useLimitedItemAmount > 0 then
                gf:confirm(string.format(CHS[7002078], useLimitedItemAmount * 10), function ()
                    EquipmentMgr:degenerationEquip(self.equip.pos, 1)
                end)
            else
                EquipmentMgr:degenerationEquip(self.equip.pos, 1)
            end
        else
            EquipmentMgr:degenerationEquip(self.equip.pos, 0)
        end
    end
end

-- 规则按钮
function EquipmentDegenerationDlg:onInfoButton()
    local data = {one = CHS[4200591], two = CHS[4200603], isScrollToDef = true}
    DlgMgr:openDlgEx("EquipmentRuleNewDlg", data)
end

-- 离开按钮
function EquipmentDegenerationDlg:onExitButton()
    self:close()
end

function EquipmentDegenerationDlg:MSG_PRE_UPGRADE_EQUIP()
    if self.equip then
       self:setEquipByPos(self.equip.pos)
    end
end

function EquipmentDegenerationDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_EQUIP_DEGENERATION_OK == data.notify and tonumber(data.para) == 1 and self.equip then
        self:setEquipByPos(self.equip.pos)
    end
end

function EquipmentDegenerationDlg:MSG_INVENTORY(data)
    self:refreshCost()
    if data.count == 0 then return end
    if self.equip and self.equip.pos == data[1].pos then
        local equip = InventoryMgr:getItemByPos(self.pos)

        if not equip or equip.item_type ~= ITEM_TYPE.EQUIPMENT then
            self:onCloseButton()
            return
        end
    end
end

function EquipmentDegenerationDlg:MSG_UPDATE(data)
    self:refreshCost()
end

return EquipmentDegenerationDlg
