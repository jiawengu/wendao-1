-- EquipmentEvolveDlg.lua
-- Created by songcw July/16/2016
-- 装备进化

local EquipmentEvolveDlg = Singleton("EquipmentEvolveDlg", Dialog)

function EquipmentEvolveDlg:init()
    self:bindListener("EvolveButton", self.onEvolveButton)
    self:bindListener("OtherEvolveButton", self.onEvolveButton)
    self:bindListener("DegenerationButton", self.onDegenerationButton, "EquipmentEvolveMaxPanel")
    self:bindListener("DegenerationButton", self.onDegenerationButton, "EquipmentEvolvePanel")
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("CostImage", self.onCostImage)
    self:bindListener("EquipmentImage", self.onEquipmentImage, "EquipmentEvolvePanel")
    self:bindListener("EquipmentImage", self.onEquipmentImage, "EquipmentEvolveMaxPanel")
    self:bindListener("BindCheckBox", self.onBindCheckBox)

    self:bindListener("GuideButton", self.onGuideButton)
    self:setCtrlVisible("GuideButton", EquipmentMgr:isShowGuideButton(self.name))


    self:setCtrlVisible("EquipmentEvolvePanel", true)
    self:setCtrlVisible("EquipmentEvolveMaxPanel", false)

    self.equip = nil
    EquipmentMgr:setTabList("EquipmentEvolveDlg")

    local node = self:getControl("BindCheckBox", Const.UICheckBox)
    if InventoryMgr.UseLimitItemDlgs[self.name] == 1 then
        self:setCheck("BindCheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 0 then
        self:setCheck("BindCheckBox", false)
    end

    self:initNotData()
    self:hookMsg("MSG_PRE_UPGRADE_EQUIP")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_UPDATE")
end

function EquipmentEvolveDlg:onGuideButton()
    DlgMgr:openDlg("EquipEvolutionGuideDlg")
end

function EquipmentEvolveDlg:initNotData()
    EquipmentMgr:setEvolveStar(self, {evolve_level = 0})
    self:setNewAtt({})
    self:setOldAtt({})
    self:setCost({req_level = 0})
    self:setDisplayType("evolve")
    self:setDisplayType("evolveAndDegeneration")
    self:setCtrlVisible("NoneEquipImage", true, "LeftEquipPanel")
    self:setCtrlVisible("NoneEquipImage", true, "RightEquipPanel")
    self:setCtrlVisible("NoneEquipImage", true, "EquipmentEvolveMaxPanel")
end

function EquipmentEvolveDlg:setDisplayType(type)
    if type == "evolve" then
        self:setCtrlVisible("EvolveButton", true)
        self:setCtrlVisible("OtherEvolveButton", false)
        self:setCtrlVisible("DegenerationButton", false)
    elseif type == "evolveAndDegeneration" then
        self:setCtrlVisible("EvolveButton", false)
        self:setCtrlVisible("OtherEvolveButton", true)
        self:setCtrlVisible("DegenerationButton", true)
    end
end

function EquipmentEvolveDlg:setInfoByPos(pos)
    if not pos then return end
    self.equip = InventoryMgr:getItemByPos(pos)
    if not self.equip then return end

    local nowEvolveLevel = self.equip.evolve_level
    local nowLevel = self.equip.req_level
    local maxEvolveLevel = EquipmentMgr:getEquipEvolveLevelMax()
    local maxEquipLevel = EquipmentMgr:getEquipMaxLevel()
    if nowEvolveLevel < maxEvolveLevel and nowLevel < maxEquipLevel then
        self:setCtrlVisible("EquipmentEvolvePanel", true)
        self:setCtrlVisible("EquipmentEvolveMaxPanel", false)
        self:setCtrlVisible("NoneEquipImage", false, "LeftEquipPanel")
        self:setCtrlVisible("NoneEquipImage", false, "RightEquipPanel")

        -- 设置装备属性
        self:setEquip(self.equip)

        -- 设置进化进度星星
        EquipmentMgr:setEvolveStar(self, self.equip, "EquipmentEvolvePanel")


        -- 设置消耗
        self:setCost(self.equip)

        -- 设置界面显示格式
        if self.equip.evolve_level > 0 then
            self:setDisplayType("evolveAndDegeneration")
        else
            self:setDisplayType("evolve")
        end
    else
        self:setCtrlVisible("EquipmentEvolvePanel", false)
        self:setCtrlVisible("EquipmentEvolveMaxPanel", true)
        self:setCtrlVisible("NoneEquipImage", false, "EquipmentEvolveMaxPanel")

        -- 设置进化进度星星
        EquipmentMgr:setEvolveStar(self, self.equip, "EquipmentEvolveMaxPanel")

        -- 设置装备基本属性
        self:setEvolveMaxEquip(self.equip)
    end
end

-- 设置消耗信息
function EquipmentEvolveDlg:setCost(equip)

    if not equip then equip = {req_level = 0} end

    self:setImage("CostImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[2000062])))
    self:setItemImageSize("CostImage")

    local cashCostText, costfontColor = gf:getArtFontMoneyDesc(EquipmentMgr:getEvolveCost(equip.req_level))
    self:setNumImgForPanel("CostMoneyPanel", costfontColor, cashCostText, false, LOCATE_POSITION.CENTER, 23)

    -- 拥有
    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("OwnMoneyPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 23)

    local amount = InventoryMgr:getAmountByNameIsForeverBind(CHS[2000062], self:isCheck("BindCheckBox"))


    local costNum = EquipmentMgr:getEvolveCostItem(equip.req_level)
    if amount < costNum then
        self:setLabelText("OwnNumLabel", amount, "CostPanel", COLOR3.RED)
    else
        self:setLabelText("OwnNumLabel", amount, "CostPanel", COLOR3.TEXT_DEFAULT)
    end
    self:setLabelText("CostNumLabel", "/" .. costNum, "CostPanel")

    self:updateLayout("CostPanel")
end

function EquipmentEvolveDlg:getPreEquip()
    if not self.equip then return end
    return EquipmentMgr.preEvolveEquip[self.equip.pos]
end

function EquipmentEvolveDlg:setOldEquip(equip)
    -- 旧图标
    local oldEquipPanel = self:getControl("LeftEquipPanel")
    self:setImage("EquipmentImage", InventoryMgr:getIconFileByName(equip.name), oldEquipPanel)
    self:setItemImageSize("EquipmentImage", oldEquipPanel)
    local color = InventoryMgr:getEquipmentNameColor(equip)
    self:setLabelText("EquipmentNameLabel", equip.name, oldEquipPanel, color)
    self:setNumImgForPanel("EquipmentImagePanel", ART_FONT_COLOR.NORMAL_TEXT, equip.req_level, false, LOCATE_POSITION.LEFT_TOP, 21, oldEquipPanel)

    local oldAtt = EquipmentMgr:getAttInfoForEvolve(equip)
    self:setOldAtt(oldAtt)
end

function EquipmentEvolveDlg:setPreEquip(equip)
    -- 新图标
    local newEquip = self:getPreEquip(equip)
    if not newEquip then return end
    local newEquipPanel = self:getControl("RightEquipPanel")
    local color = InventoryMgr:getEquipmentNameColor(newEquip)
    self:setImage("EquipmentImage", InventoryMgr:getIconFileByName(newEquip.name), newEquipPanel)
    self:setItemImageSize("EquipmentImage", newEquipPanel)
    self:setLabelText("EquipmentNameLabel", newEquip.name, newEquipPanel, color)
    self:setNumImgForPanel("EquipmentImagePanel", ART_FONT_COLOR.NORMAL_TEXT, newEquip.req_level, false, LOCATE_POSITION.LEFT_TOP, 21, newEquipPanel)

    local newAtt = EquipmentMgr:getAttInfoForEvolve(newEquip)
    self:setNewAtt(newAtt)
end

-- 设置装备信息
function EquipmentEvolveDlg:setEquip(equip)
    -- 设置旧装备
    self:setOldEquip(equip)

    -- 如果当前状态已经升级最高，预览装备时，直接取当前装备
    if equip.evolve_level == EquipmentMgr:getEquipEvolveLevelMax() or equip.req_level == Const.PLAYER_MAX_LEVEL then
        EquipmentMgr.preEvolveEquip[equip.pos] = equip
    end

    local preEquip = self:getPreEquip(equip)
    if preEquip then
        -- 设置新装备
        self:setPreEquip(preEquip)
    else
        EquipmentMgr:evolvePreEquip(equip.pos)
    end
end

-- 设置新装备属性
function EquipmentEvolveDlg:setNewAtt(allAttribTab)
    local attPanel = self:getControl("NewPanel")
    for i = 1, 11 do
        local att = allAttribTab[i]
        if att then
            if att.basic then
                self:setLabelText("valueLabel" .. i, att.value, attPanel, att.value_color)
            else
                self:setLabelText("valueLabel" .. i, att.str, attPanel, att.color)
            end
        else
            self:setLabelText("valueLabel" .. i, "", attPanel)
            self:setCtrlVisible("Label_" .. i, false, "ArrowPanel")
        end
    end
    attPanel:requestDoLayout()
    local attribScrollView = self:getControl("AttribScrollView", Const.UIListView, "EquipmentEvolvePanel")
    attribScrollView:jumpToPercentVertical(0)
end

-- 设置旧装备属性
function EquipmentEvolveDlg:setOldAtt(allAttribTab)
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

function EquipmentEvolveDlg:setEvolveMaxEquip(equip)
    if not equip then
        return
    end

    local panel = self:getControl("EquipmentEvolveMaxPanel")
    self:setImage("EquipmentImage", InventoryMgr:getIconFileByName(equip.name), panel)

    local equipmentColor = InventoryMgr:getEquipmentNameColor(equip)
    self:setLabelText("EquipmentNameLabel", equip.name, panel, equipmentColor)

    self:setNumImgForPanel("EquipmentImagePanel", ART_FONT_COLOR.NORMAL_TEXT, equip.req_level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- 各属性值
    local allAttribTab = EquipmentMgr:getAttInfoForEvolve(equip)
    local attMainPanel = self:getControl("AttributePanel", nil, panel)
    for i = 1, 11 do
        local att = allAttribTab[i]
        local attPanelName = "ValuePanel" .. i
        if att then
            self:setColorText(att.str, attPanelName, panel, nil, nil, att.color, nil, true)
        else
            local panel = self:getControl(attPanelName)
            panel:removeAllChildren()
        end
    end
    attMainPanel:requestDoLayout()

    local attribScrollView = self:getControl("AttribScrollView", Const.UIListView, "EquipmentEvolveMaxPanel")
    attribScrollView:jumpToPercentVertical(0)
end

function EquipmentEvolveDlg:onInfoButton(sender, eventType)
    local data = {one = CHS[4200591], two = CHS[4200591], isScrollToDef = true}
    DlgMgr:openDlgEx("EquipmentRuleNewDlg", data)
end

function EquipmentEvolveDlg:onBindCheckBox(sender, eventType)
    self:setCost(self.equip)
    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
    end
end


function EquipmentEvolveDlg:onEquipmentImage(sender, eventType)
    if not self.equip then return end
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showEquipByEquipment(self.equip, rect, true)
end

function EquipmentEvolveDlg:onCostImage(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[2000062], rect)
end

function EquipmentEvolveDlg:onEvolveButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if not self.equip then
        gf:ShowSmallTips(CHS[4100271])
        return
    end

    -- 限时装备
    if InventoryMgr:isTimeLimitedItem(self.equip) then
        gf:ShowSmallTips(CHS[5420219])
        return
    end

    if GameMgr.inCombat and EquipmentMgr:isValidEquipPos(self.equip.pos) then
        gf:ShowSmallTips(CHS[4300099])
        return
    end

    if self.equip.color ~= CHS[3002403] then
        gf:ShowSmallTips(CHS[4100272])
        return
    end

    if self.equip.req_level < 70 then
        gf:ShowSmallTips(CHS[4100273])
        return
    end

    if self.equip.req_level > Me:queryBasicInt("level") then
        gf:ShowSmallTips(CHS[4100274])
        return
    end

    if self.equip.req_level >= Const.PLAYER_MAX_LEVEL then
        gf:ShowSmallTips(CHS[4100275])
        return
    end

    if self.equip.evolve_level >= EquipmentMgr:getEquipEvolveLevelMax() then
        gf:ShowSmallTips(CHS[4100276])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onEvolveButton") then
        return
    end

    self:confirmStep(1)
end

function EquipmentEvolveDlg:confirmStep(step)
    if step == 1 then
        -- 等级差导致丢失绿属性
        local isConfirm, tips = EquipmentMgr:evolvePreEquipLoseGreen(self.equip, 1)
        if isConfirm then
            gf:confirm(tips, function ()
                return self:confirmStep(2)
            end)
            return
        end
        return self:confirmStep(2)
    elseif step == 2 then
        local isConfirm, tips = EquipmentMgr:evolvePreEquipLoseGreen(self.equip, 2)
        if isConfirm then
            gf:confirm(tips, function ()
                return self:confirmStep(3)
            end)
            return
        end
        return self:confirmStep(3)
    elseif step == 3 then
        local limiTab, str, day = InventoryMgr:getLimitAtt(self.equip)
        local amount = InventoryMgr:getAmountByNameForeverBind(CHS[2000062])
        local costAmount = EquipmentMgr:getEvolveCostItem(self.equip.req_level)
        local useAmount = math.min(amount, costAmount)
        if self:isCheck("BindCheckBox") and amount > 0 and day <= 59 then
            gf:confirm(string.format(CHS[4200166], useAmount * 10), function ()
                EquipmentMgr:evolveEquip(self.equip.pos, 1)
            end)
        else
            if self:isCheck("BindCheckBox") then
                EquipmentMgr:evolveEquip(self.equip.pos, 1)
            else
                EquipmentMgr:evolveEquip(self.equip.pos, 0)
            end
        end
    end
end

function EquipmentEvolveDlg:onDegenerationButton()
    if not self.equip then
        return
    end


    -- 进化界面，物品可能被析构但是界面不刷新（因为 99升100就是先析构物品在创建物品）
    -- 所以需要再次检测下该位置物品是否有效
    local equip = InventoryMgr:getItemByPos(self.equip.pos)
    if not equip or equip.item_type ~= ITEM_TYPE.EQUIPMENT then
        -- 若物品不是装备，通知左侧刷新
        DlgMgr:sendMsg("EquipmentChildDlg", "setListType", EquipmentMgr:getLastTabKey(), true)
        return
    end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 限时装备
    if InventoryMgr:isTimeLimitedItem(self.equip) then
        gf:ShowSmallTips(CHS[5420219])
        return
    end

    if GameMgr.inCombat and EquipmentMgr:isValidEquipPos(self.equip.pos) then
        gf:ShowSmallTips(CHS[7002060])
        return
    end

    -- 请求一下当前装备的退化预览信息
    EquipmentMgr:degenerationPreEquip(self.equip.pos)

    local dlg = DlgMgr:openDlg("EquipmentDegenerationDlg")
    dlg:setEquipByPos(self.equip.pos)
end

function EquipmentEvolveDlg:MSG_GENERAL_NOTIFY(data)
    if not self.equip then return end
    if NOTIFY.NOTIFY_EQUIP_EVOLVE_OK == data.notify or NOTIFY.NOTIFY_EQUIP_DEGENERATION_OK then
        self:setInfoByPos(self.equip.pos)
    end
end

function EquipmentEvolveDlg:MSG_UPDATE(data)
    self:setCost(self.equip)
end

function EquipmentEvolveDlg:MSG_INVENTORY(data)
    self:setCost(self.equip)
end

function EquipmentEvolveDlg:MSG_PRE_UPGRADE_EQUIP(data)
    if not self.equip or data.upgrade_type ~= Const.EQUIP_EVOLVE_PREVIEW then return end
    if self.equip.pos ~= data.pos then return end
    self:setPreEquip(data)
end

return EquipmentEvolveDlg
