-- EquipmentRefiningGongmingDlg.lua
-- Created by lixh2 1/24/2018
-- 装备共鸣界面

local EquipmentRefiningGongmingDlg = Singleton("EquipmentRefiningGongmingDlg", Dialog)

-- 共鸣石最大消耗数量
local GONGMING_STONE_MAX_COST_COUNT = 3

-- 共鸣石默认消耗数量
local GONGMING_STONE_DEFAULT_COST_COUNT = 3

-- 共鸣石最小消耗数量
local GONGMING_STONE_MIN_COST_COUNT = 1

function EquipmentRefiningGongmingDlg:init()
    self:bindListener("ReduceButton", self.onReduceButton)
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("MaxButton", self.onMaxButton)
    self:bindListener("RefiningButton", self.onRefiningButton)
    self:bindListener("RestoreButton", self.onRestoreButton)
    self:bindListener("ReplaceButton", self.onReplaceButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("BindCheckBox", self.onBindCheckBox)
    self:bindListener("PreviewItemCheckBox", self.onGemCheckBox)
    self:bindListener("CostImagePanel", self.onCostImagePanel)
    self:bindListener("PreviewMaterialPanel", self.onGemImagePanel)

    self:setCheck("BindCheckBox", InventoryMgr.UseLimitItemDlgs[self.name] == 1)
    self:setCheck("PreviewItemCheckBox", InventoryMgr.UseLimitItemDlgs[self.name .. "Gem"] == 1)

    self:MSG_UPDATE(nil, true)

    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_UPDATE")
end

function EquipmentRefiningGongmingDlg:onBindCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
    end

    -- 限制交易状态改变，刷新材料数量
    self:refreshMaterialCount()
end

function EquipmentRefiningGongmingDlg:onGemCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        local gem = EquipmentMgr:getRefiningGemByEquip(self.equip)
        gf:ShowSmallTips(string.format(CHS[4100436], InventoryMgr:getUnit(gem), gem))

        InventoryMgr:setLimitItemDlgs(self.name .. "Gem", 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name .. "Gem", 0)
    end
end

function EquipmentRefiningGongmingDlg:setInfoByPos(pos)
    self.pos = pos
    self.equip = InventoryMgr:getItemByPos(self.pos)
    if not self.equip then
        DlgMgr:closeDlg(self.name)
        return
    end

    -- 策划要求共鸣属性从无到有，需要用下面策略显示共鸣石数量
    if not self.gongMingAttrib then
        self.gongMingAttrib = EquipmentMgr:getEquipPre(self.equip, Const.FIELDS_RESONANCE)
        self.costCount = self.gongMingAttrib and GONGMING_STONE_DEFAULT_COST_COUNT or GONGMING_STONE_MIN_COST_COUNT
    end

    local showPreview = true
    if not self.gongMingAttrib then showPreview = false end
    self:setCtrlVisible("PreviewMaterialPanel", showPreview)
    self:setCtrlVisible("PreviewItemCheckBox", showPreview)
    self:setCtrlVisible("PreviewItemLabel", showPreview)

    self:refreshSetNumPanel()
    self:setAttribInfo()
    self:refreshRefiningBtn()
    self:setMaterialInfo()
end

-- 设置属性值：当前属性，预览属性
function EquipmentRefiningGongmingDlg:setAttribInfo()
    local gongMingAttrib = EquipmentMgr:getEquipPre(self.equip, Const.FIELDS_RESONANCE)
    local gongMingPreAttrib = EquipmentMgr:getEquipPre(self.equip, Const.FIELDS_RESONANCE_PREVIEW)
    if gongMingAttrib then
        local str = string.format(CHS[7190143], tonumber(self.equip.rebuild_level), EquipmentMgr:getAttribChsOrEng(gongMingAttrib.field) .. " "
            .. gongMingAttrib.value .. EquipmentMgr:getPercentSymbolByField(gongMingAttrib.field))
        self:setLabelText("AttributeLabel1", str, "AttributePanel")
    end

    if gongMingPreAttrib then
        local str = string.format(CHS[7190143], tonumber(self.equip.rebuild_level), EquipmentMgr:getAttribChsOrEng(gongMingPreAttrib.field) .. " "
            .. gongMingPreAttrib.value .. EquipmentMgr:getPercentSymbolByField(gongMingPreAttrib.field))
        self:setLabelText("PreviewAttributeLabel1", str, "PreviewAttributePanel")
    end

    self:setCtrlVisible("AttributeLabel1", gongMingAttrib and true or false, "AttributePanel")
    self:setCtrlVisible("DefaultInfoLabel", not gongMingAttrib and true or false, "AttributePanel")
    self:setCtrlVisible("PreviewAttributeLabel1", gongMingPreAttrib and true or false, "PreviewAttributePanel")
    self:setCtrlVisible("DefaultInfoLabel", not gongMingPreAttrib and true or false, "PreviewAttributePanel")
end

-- 设置炼化，重新炼化，替换属性按钮状态
function EquipmentRefiningGongmingDlg:refreshRefiningBtn()
    local gongMingPreAttrib = EquipmentMgr:getEquipPre(self.equip, Const.FIELDS_RESONANCE_PREVIEW)
    self:setCtrlVisible("RefiningButton", not gongMingPreAttrib and true or false)
    self:setCtrlVisible("RestoreButton", gongMingPreAttrib and true or false)
    self:setCtrlVisible("ReplaceButton", gongMingPreAttrib and true or false)
end

-- 共鸣石悬浮框
function EquipmentRefiningGongmingDlg:onCostImagePanel(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[7190126], rect)
end

-- 宝石悬浮框
function EquipmentRefiningGongmingDlg:onGemImagePanel(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local gem = EquipmentMgr:getRefiningGemByEquip(self.equip)
    InventoryMgr:showBasicMessageDlg(gem, rect)
end

-- 设置材料，宝石，金钱信息
function EquipmentRefiningGongmingDlg:setMaterialInfo()
    local panel = self:getControl("CostImagePanel")
    self:setImage("CostImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[7190126])), panel)
    self:setItemImageSize("CostImage", panel)

    local panel = self:getControl("PreviewMaterialPanel")
    local gem = EquipmentMgr:getRefiningGemByEquip(self.equip)
    self:setImage("PreviewMaterialImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(gem)), panel)
    self:setItemImageSize("PreviewMaterialImage", panel)

    self:setLabelText("PreviewItemLabel", gem)

    local cashText, fontColor = gf:getArtFontMoneyDesc(self:getCostCash(self.equip))
    self:setNumImgForPanel("CostMoneyPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 19)

    -- 刷新数量
    self:refreshMaterialCount()
end

-- 刷新材料数量，共鸣石，宝石
function EquipmentRefiningGongmingDlg:refreshMaterialCount()
    local amount = tonumber(InventoryMgr:getAmountByNameIsForeverBind(CHS[7190126], self:isCheck("BindCheckBox")))
    local panel = self:getControl("CostImagePanel")
    if amount < self.costCount then
        self:setNumImgForPanel("CostImage", ART_FONT_COLOR.RED, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21, panel)
    elseif amount <= 999 then
        self:setNumImgForPanel("CostImage", ART_FONT_COLOR.NORMAL_TEXT, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21, panel)
    else
        self:setNumImgForPanel("CostImage", ART_FONT_COLOR.NORMAL_TEXT, "*", false, LOCATE_POSITION.RIGHT_BOTTOM, 21, panel)
    end

    local gem = EquipmentMgr:getRefiningGemByEquip(self.equip)
    local gemCount = InventoryMgr:getAmountByNameIsForeverBind(gem, self:isCheck("BindCheckBox"))
    local gemPanel = self:getControl("PreviewMaterialPanel")
    if gemCount < 1 then
        self:setNumImgForPanel("PreviewMaterialImage", ART_FONT_COLOR.RED, gemCount .. "/1", false, LOCATE_POSITION.RIGHT_BOTTOM, 21, gemPanel)
    elseif gemCount <= 999 then
        self:setNumImgForPanel("PreviewMaterialImage", ART_FONT_COLOR.NORMAL_TEXT, gemCount .. "/1", false, LOCATE_POSITION.RIGHT_BOTTOM, 21, gemPanel)
    else
        self:setNumImgForPanel("PreviewMaterialImage", ART_FONT_COLOR.NORMAL_TEXT, "*" .. "/1", false, LOCATE_POSITION.RIGHT_BOTTOM, 21, gemPanel)
    end
end

-- 刷新共鸣石消耗数量
function EquipmentRefiningGongmingDlg:refreshSetNumPanel()
    if not self.costCount then return end
    self.costCount = math.min(math.max(self.costCount, GONGMING_STONE_MIN_COST_COUNT), GONGMING_STONE_MAX_COST_COUNT)
    self:setLabelText("NumLabel", self.costCount, "NumPanel")
    self:setLabelText("NumLabel2", self.costCount, "NumPanel")
    self:refreshMaterialCount()
    local gongMingAttrib = EquipmentMgr:getEquipPre(self.equip, Const.FIELDS_RESONANCE)
    if not gongMingAttrib or self.costCount == GONGMING_STONE_MAX_COST_COUNT then
        -- 没有共鸣属性时，首次共鸣最多使用一个共鸣石
        gf:grayImageView(self:getControl("AddButton", nil, "NumPanel"))
        gf:grayImageView(self:getControl("MaxButton", nil, "NumPanel"))
    else
        gf:resetImageView(self:getControl("AddButton", nil, "NumPanel"))
        gf:resetImageView(self:getControl("MaxButton", nil, "NumPanel"))
    end

    if self.costCount == GONGMING_STONE_MIN_COST_COUNT then
        gf:grayImageView(self:getControl("ReduceButton", nil, "NumPanel"))
    else
        gf:resetImageView(self:getControl("ReduceButton", nil, "NumPanel"))
    end
end

-- 计算当前装备共鸣花费
function EquipmentRefiningGongmingDlg:getCostCash()
    if not self.equip then return 0 end
    return EquipmentMgr:getGongMingCost(self.equip.req_level)
end

function EquipmentRefiningGongmingDlg:onReduceButton(sender, eventType)
    if not self.equip then return end
    if self.costCount and self.costCount == GONGMING_STONE_MIN_COST_COUNT then
        local gongMingAttrib = EquipmentMgr:getEquipPre(self.equip, Const.FIELDS_RESONANCE)
        local tips = gongMingAttrib and CHS[7190127] or CHS[7100169]
        gf:ShowSmallTips(tips)
        return
    end

    self.costCount = self.costCount - 1
    self:refreshSetNumPanel()
end

function EquipmentRefiningGongmingDlg:onAddButton(sender, eventType)
    if not self.equip then return end
    local gongMingAttrib = EquipmentMgr:getEquipPre(self.equip, Const.FIELDS_RESONANCE)
    if not gongMingAttrib or (self.costCount and self.costCount == GONGMING_STONE_MAX_COST_COUNT) then
        local tips = gongMingAttrib and CHS[7190128] or CHS[7190129]
        gf:ShowSmallTips(tips)
        return
    end

    self.costCount = self.costCount + 1
    self:refreshSetNumPanel()
end

function EquipmentRefiningGongmingDlg:onMaxButton(sender, eventType)
    if not self.equip then return end
    local gongMingAttrib = EquipmentMgr:getEquipPre(self.equip, Const.FIELDS_RESONANCE)
    if not gongMingAttrib then
        local tips = CHS[7190129]
        gf:ShowSmallTips(tips)
        return
    end

    self.costCount = GONGMING_STONE_MAX_COST_COUNT
    self:refreshSetNumPanel()
end

function EquipmentRefiningGongmingDlg:cleanup()
    self.pos = nil
    self.equip = nil
    self.gongMingAttrib = nil
    self.costCount = GONGMING_STONE_DEFAULT_COST_COUNT
end

function EquipmentRefiningGongmingDlg:onRefiningButton(sender, eventType)
    local equip = self.equip

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    if Me:getLevel() < EquipmentMgr:getEquipGongmingPlayerLevel() then
        gf:ShowSmallTips(CHS[7190130])
        return
    end

    if not equip then
        gf:ShowSmallTips(CHS[7190131])
        return
    end

    -- 限时装备
    if InventoryMgr:isTimeLimitedItem(equip) then
        gf:ShowSmallTips(CHS[5420219])
        return
    end

    if equip.req_level < EquipmentMgr:getEquipGongmingPlayerLevel() then
        gf:ShowSmallTips(CHS[7190132])
        return
    end

    if GameMgr.inCombat and EquipmentMgr:isValidEquipPos(equip.pos) then
        gf:ShowSmallTips(CHS[7190133])
        return
    end

    -- 改造等级限制
    if equip.rebuild_level and tonumber(equip.rebuild_level) <= 3 or equip.color ~= CHS[3002403] then
        gf:ShowSmallTips(CHS[7190134])
        return
    end

    -- 金钱不足
    local costCash = self:getCostCash()
    if costCash > Me:queryBasicInt("cash") then
        gf:askUserWhetherBuyCash()
        return
    end

    -- 道具不足判断
    local haveCount = InventoryMgr:getAmountByNameIsForeverBind(CHS[7190126], self:isCheck("BindCheckBox"))
    if haveCount < self.costCount then
        gf:askUserWhetherBuyItem({[CHS[7190126]] = self.costCount - haveCount })
        return
    end

    -- 默认为共鸣(用宝石则更新为预览)
    local gongMingType = Const.EQUIP_RESONANCE

    -- 宝石不足判断
    local gem = EquipmentMgr:getRefiningGemByEquip(equip)
    local useGemFlag = self:isCheck("PreviewItemCheckBox") and self:getCtrlVisible("PreviewItemCheckBox")
    if useGemFlag then
        local gemCount = InventoryMgr:getAmountByNameIsForeverBind(gem, self:isCheck("BindCheckBox"))
        if gemCount < 1 then
            gf:ShowSmallTips(string.format(CHS[7190135], gem))
            return
        end

        gongMingType = Const.EQUIP_RESONANCE_PREVIEW
    end

    local gongMingStr = string.format("%d", self.costCount)
    local limitStr = string.format("|%d", self:isCheck("BindCheckBox") and 1 or 0)

    -- 使用限制交易道具
    local foreverBindCount = InventoryMgr:getAmountByNameForeverBind(CHS[7190126])
    local foreverBindGemCount = InventoryMgr:getAmountByNameForeverBind(gem)
    if self:isCheck("BindCheckBox") and (foreverBindCount > 0 or (useGemFlag and foreverBindGemCount > 0)) then
        local str, day = gf:converToLimitedTimeDay(equip.gift)
        if not InventoryMgr:isLimitedItemForever(equip) and day <= Const.LIMIT_TIPS_DAY then
            -- 非永久限制交易，且限制交易天数小于等于限制交易最大提示天数
            local addDays = 0

            -- 装备共鸣石增加的限制交易天数
            if foreverBindCount > 0 then
                if foreverBindCount >= self.costCount then
                    addDays = self.costCount * 10
                else
                    addDays = foreverBindCount * 10
                end
            end

            if useGemFlag and foreverBindGemCount > 0 then
                addDays = addDays + 10
            end

            gf:confirm(string.format(CHS[3002527], addDays), function()
                EquipmentMgr:equipResonance(gongMingType, equip.pos, gongMingStr .. limitStr)
            end)

            return
        end
    end

    EquipmentMgr:equipResonance(gongMingType, equip.pos, gongMingStr .. limitStr)
end

-- 重新共鸣
function EquipmentRefiningGongmingDlg:onRestoreButton(sender, eventType)
    self:onRefiningButton()
end

-- 共鸣属性替换
function EquipmentRefiningGongmingDlg:onReplaceButton(sender, eventType)
    if not self.equip then return end

    gf:confirm(CHS[7190136], function()
        if self.equip then
            EquipmentMgr:equipResonance(Const.EQUIP_RESONANCE_REPLACE, self.equip.pos)
        end
    end)
end

function EquipmentRefiningGongmingDlg:onInfoButton(sender, eventType)
    local data = {one = CHS[4200592], two = CHS[4200595], isScrollToDef = true}
    DlgMgr:openDlgEx("EquipmentRuleNewDlg", data)
end

function EquipmentRefiningGongmingDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_EQUIP_RESONANCE_OK == data.notify  then
        -- 认为此部分暂时客户端不需要处理刷新逻辑，因为equip身上的动态字段更新时，在MSG_UPDATE中会刷新界面，此处不应该做刷新
    end
end

function EquipmentRefiningGongmingDlg:MSG_UPDATE(data, now)
    if (data and data.cash) or now then
        local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
        self:setNumImgForPanel("OwnMoneyPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 19)
    end
end

function EquipmentRefiningGongmingDlg:MSG_INVENTORY(data)
    -- 记得有一情况，会发 count == 0，具体忘记了
    if data.count == 0 then return end
    local updateDlgInfo = false
    local gemName = EquipmentMgr:getRefiningGemByEquip(self.equip)
    for i = 1, data.count do
        if self.equip and data[i].pos == self.equip.pos then
            -- 假如消息延迟后
            -- 位置和当前操作装备位置一样，对比下名字，如果名字变了，肯定装备发生变化了，关闭界面
            if self.equip.name ~= data[i].name then
                self:onCloseButton()
                return
            end

            -- 刷新了装备信息
            self.equip = data[i]
            updateDlgInfo = true
        end

        if not data[i].name or data[i].name == CHS[7190126] or (gemName and data[i].name == gemName) then
            -- 共鸣石用完了，data[i].name为nil
            -- 刷新了共鸣石，预览宝石信息
            updateDlgInfo = true
        end
    end

    if not updateDlgInfo then return end

    self:setInfoByPos(self.equip.pos)

    if self.equip then
        DlgMgr:sendMsg("EquipmentUpgradeDlg", "setInfoByPos", self.equip.pos)
    else
        DlgMgr:sendMsg("EquipmentUpgradeDlg", "onCloseButton")
    end
end

return EquipmentRefiningGongmingDlg
