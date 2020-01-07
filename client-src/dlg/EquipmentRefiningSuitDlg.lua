-- EquipmentRefiningSuitDlg.lua
-- Created by songcw Aug/4/2015
-- 套装

local EquipmentRefiningSuitDlg = Singleton("EquipmentRefiningSuitDlg", Dialog)

local REFING_STATE = {
    NOMAL = 1,          -- 正常状态
    HAS_REPLACE = 2,    -- 有可以替换
}

local polar_info = {
    [0] = {polarChs = CHS[3002500], attChs = "", field = ""},
    [POLAR.METAL] = {polarChs = CHS[3002501], attChs = CHS[3002502], field = "mag_power"},
    [POLAR.WOOD] = {polarChs = CHS[3002503], attChs = CHS[3002504], field = "max_life"},
    [POLAR.WATER] = {polarChs = CHS[3002505], attChs = CHS[3002506], field = "def"},
    [POLAR.FIRE] = {polarChs = CHS[3002507], attChs = CHS[3002508], field = "speed"},
    [POLAR.EARTH] = {polarChs = CHS[3002509], attChs = CHS[3002510], field = "phy_power"},
}

function EquipmentRefiningSuitDlg:init()
    self:bindListener("RefiningButton", self.onRefiningButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("BindCheckBox", self.onBindCheckBox)
    self:bindListener("ItemImagePanel", self.onCostImage)
    self:bindListener("PreviewMaterialPanel", self.onGemItem)
    self:bindListener("PreviewItemCheckBox", self.onGemCheckBox)
    self:bindListener("RestoreButton", self.onRestoreButton)    -- 还原属性
    self:bindListener("ReplaceButton", self.onReplaceButton)    -- 替换属性

    self:bindListener("GuideButton", self.onGuideButton)
    self:setCtrlVisible("GuideButton", EquipmentMgr:isShowGuideButton(self.name))

    local polarPanel = self:getControl("PolarSelectPanel")
    self:bindListener("PolarButton", self.onSelectPolar, polarPanel)
    self:bindListener("AddButton", self.onSelectPolar, polarPanel)
    self.destPolar = nil
    self:dlgClean()
    self:setCrystalInfo()
    self:setCostMoney()
    self:setPolar()

    EquipmentMgr:setTabList("EquipmentRefiningSuitDlg")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:MSG_UPDATE()

    local node = self:getControl("BindCheckBox", Const.UICheckBox)
    if InventoryMgr.UseLimitItemDlgs[self.name] == 1 then
        self:setCheck("BindCheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 0 then
        self:setCheck("BindCheckBox", false)
    end
    self:onBindCheckBox(node, 2)

    if InventoryMgr.UseLimitItemDlgs[self.name .. "Gem"] == 1 then
        self:setCheck("PreviewItemCheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name .. "Gem"] == 0 then
        self:setCheck("PreviewItemCheckBox", false)
    end
end

function EquipmentRefiningSuitDlg:onGuideButton()
    DlgMgr:openDlg("EquipSuitGuideDlg")
end

function EquipmentRefiningSuitDlg:getSelectItemBox(clickItem)
    if clickItem == "BindCheckBox" then
        if self:isCheck("BindCheckBox") then
            return
        else
            return self:getBoundingBoxInWorldSpace(self:getControl("BindCheckBox"))
        end
    end
end

function EquipmentRefiningSuitDlg:dlgClean()
    local leftPanel = self:getControl("LeftAttributePanel")
    self:setLabelText("AttributeLabel1", "", leftPanel)
    self:setLabelText("AttributeLabel2", "", leftPanel)

    local rightPanel = self:getControl("RightAttributePanel")
    self:setLabelText("AttributeLabel1", "", rightPanel)
    self:setLabelText("AttributeLabel2", "", rightPanel)

    self:setCtrlVisible("FrameImage", false, "EquipmentImagePanel")
end

function EquipmentRefiningSuitDlg:setInfoByPos(pos)
    self.pos = pos
    if pos == nil then
        self:setGemPanelVisible(false)
        return
    end
    self:setCtrlVisible("FrameImage", true, "EquipmentImagePanel")
    local equip = InventoryMgr:getItemByPos(pos)
    if nil == equip then return end
    local equipPanel = self:getControl("EquipmentImagePanel")
    self:setImage("EquipmentImage", InventoryMgr:getIconFileByName(equip.name), equipPanel)
    self:setCtrlVisible("EquipmentImage", true, equipPanel)
    self:setItemImageSize("EquipmentImage", equipPanel)
 --   self:setLabelText("EquipmentNameLabel", equip.name, equipPanel)

    -- 装备悬浮框
    local equipImage = self:getControl("EquipmentImage", nil, equipPanel)
    self:bindTouchEndEventListener(equipImage, self.showEquipmentInfo, pos)

    local color = InventoryMgr:getEquipmentNameColor(equip)
    local name = equip.name
    if equip.suit_polar ~= 0 then name = name .. "#G(" .. gf:getPolar(equip.suit_polar) .. ")#n" end
    self:setEquipNameStr(name, color, self:getControl("EquipNamePanel"))

    -- 设置消耗
    self:setCostMoney(equip.req_level)

    -- 设置当前属性
    self:setEquipAttrib(equip)
    self:setCrystalInfo()
    --
    local preAtt = EquipmentMgr:getEquipPre(equip, Const.FIELDS_PROP4_PREVIEW)
    local preSuit = EquipmentMgr:getEquipPre(equip, Const.FIELDS_SUIT_PREVIEW)
    if preAtt then
        -- 设置相性
        self:setPolar(equip.suit_polar_preview)

        local rightPanel = self:getControl("RightAttributePanel")
        local strChs1 = EquipmentMgr:getAttribChs(preAtt, false, equip)
        self:setLabelText("AttributeLabel1", strChs1, rightPanel)
        local strChs2 = EquipmentMgr:getAttribChsSuit(preSuit, false, equip)
        self:setLabelText("AttributeLabel2", strChs2, rightPanel)

        self:setDisplayBtn(REFING_STATE.HAS_REPLACE)
    else
        -- 设置相性
        self:setPolar(equip.suit_polar)

        self:setDisplayBtn(REFING_STATE.NOMAL)
    end

    -- 设置宝石是否显示
    local att = self:getBringtAtt(equip)
    if (equip.req_level - equip.evolve_level) >= 70 and att and next(att) then
        self:setGemPanelVisible(true)
    else
        self:setGemPanelVisible(false)
    end

    -- 设置宝石信息
    self:setGemPanelInfo(equip)
end

function EquipmentRefiningSuitDlg:showEquipmentInfo(sender, eventType, pos)
    local equipImage = self:getControl("EquipmentImage")
    local rect = self:getBoundingBoxInWorldSpace(equipImage)
    local equip = InventoryMgr:getItemByPos(pos)
    if not equip or not self:isSuitEquip(equip) then return end
    InventoryMgr:showEquipByEquipment(equip, rect, true)
end

function EquipmentRefiningSuitDlg:isSuitEquip(equip)
    return equip and equip.item_type == ITEM_TYPE.EQUIPMENT and InventoryMgr:isEquip(equip.equip_type) and equip.req_level >= 70 and (equip.color == CHS[3002402] or equip.color == CHS[3002403])
end

function EquipmentRefiningSuitDlg:onBindCheckBox(sender, eventType)
    self:setCrystalInfo()

    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
    end
end

function EquipmentRefiningSuitDlg:MSG_INVENTORY(data)
    local equip = InventoryMgr:getItemByPos(self.pos)
    if not equip or not self:isSuitEquip(equip) then
        local equipPanel = self:getControl("EquipmentImagePanel")
        self:setCtrlVisible("EquipmentImage", false, equipPanel)
        self:setEquipNameStr("", COLOR3.TEXT_DEFAULT, self:getControl("EquipNamePanel"))
        self:dlgClean()
        self:setCrystalInfo()
        self:setCostMoney()
        self:setPolar()
    else
        self:setCrystalInfo()
    end
end

function EquipmentRefiningSuitDlg:onCostImage(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[3002511], rect)
end

function EquipmentRefiningSuitDlg:onGemItem(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    if not self.pos then return end
    local equip = InventoryMgr:getItemByPos(self.pos)
    if not equip then return end
    local gem = EquipmentMgr:getRefiningGemByEquip(equip)
    InventoryMgr:showBasicMessageDlg(gem, rect)
end

function EquipmentRefiningSuitDlg:onSelectPolar(sender, eventType)
    local equip = InventoryMgr:getItemByPos(self.pos)
    if not equip or not self:isSuitEquip(equip) then
        gf:ShowSmallTips(CHS[3002512])
        return
    end

    -- selectPolarLock == true 表示有预览
    if self.selectPolarLock then
        gf:confirm(CHS[4200234], function ()
            if not self.pos then return end
            local equip = InventoryMgr:getItemByPos(self.pos)
            if not equip then return end
            EquipmentMgr:equipClearRefining(self.pos, CHS[4100437])
            DlgMgr:openDlg("EquipmentChangePolarDlg")
        end)
    else
        DlgMgr:openDlg("EquipmentChangePolarDlg")
    end


end

-- 请选择相性
function EquipmentRefiningSuitDlg:setPolar(polar)
    if not polar then polar = 0 end
    local polarPanel = self:getControl("PolarSelectPanel")
    local imageCtrl = self:getControl("PolarButton", nil, polarPanel)
    local addCtrl = self:getControl("AddButton", nil, polarPanel)
    addCtrl:setVisible(false)
    imageCtrl:setVisible(true)
    self.destPolar = polar
    self:setCtrlVisible("FrameImage", false, polarPanel)
    self:setLabelText("ItemNameLabel", polar_info[polar].polarChs, polarPanel)

    local equip = InventoryMgr:getItemByPos(self.pos)
    if not equip then
        self:dlgClean()
    end

    local rightPanel = self:getControl("RightAttributePanel")
    local preAtt = EquipmentMgr:getEquipPre(equip, Const.FIELDS_PROP4_PREVIEW)
    if not preAtt then
        self:setLabelText("AttributeLabel1", CHS[3002513], rightPanel)

        local min, max = EquipmentMgr:getSuitMinAndMax(equip, polar_info[polar].field)
        if polar_info[polar].attChs ~= "" then
            local range = string.format("%s %d ~ %d", polar_info[polar].attChs, min, max)
            self:setLabelText("AttributeLabel2", range, rightPanel)
        else
            self:setLabelText("AttributeLabel2", "", rightPanel)
        end
    end

    if polar == POLAR.METAL then
        imageCtrl:loadTextureNormal(ResMgr.ui.suit_polar_metal, ccui.TextureResType.plistType)
    elseif polar == POLAR.WOOD then
        imageCtrl:loadTextureNormal(ResMgr.ui.suit_polar_wood, ccui.TextureResType.plistType)
    elseif polar == POLAR.WATER then
        imageCtrl:loadTextureNormal(ResMgr.ui.suit_polar_water, ccui.TextureResType.plistType)
    elseif polar == POLAR.FIRE then
        imageCtrl:loadTextureNormal(ResMgr.ui.suit_polar_fire, ccui.TextureResType.plistType)
    elseif polar == POLAR.EARTH then
        imageCtrl:loadTextureNormal(ResMgr.ui.suit_polar_earth, ccui.TextureResType.plistType)
    else
        addCtrl:setVisible(true)
        imageCtrl:setVisible(false)
        self:setLabelText("ItemNameLabel", CHS[3002514], polarPanel)
        self:setCtrlVisible("FrameImage", true, polarPanel)
    end
end

-- 设置当前属性
function EquipmentRefiningSuitDlg:setEquipAttrib(equip)
    equip = equip or InventoryMgr:getItemByPos(self.pos)
    local brightAttribInfo = self:getBringtAtt(equip)
    local darkAttribInfo = self:getDarkAtt(equip)
    local equipAttPanel = self:getControl("LeftAttributePanel")

    if equip.color ~= CHS[3002515] then
        self:setLabelText("AttributeLabel1", CHS[3002516], equipAttPanel, COLOR3.GRAY)
        self:setLabelText("AttributeLabel2", "", equipAttPanel, COLOR3.GRAY)
        return
    end

    if darkAttribInfo then
        local color = COLOR3.GRAY
        if equip.suit_enabled == 1 and equip.pos <= 10 then color = COLOR3.GREEN end
        self:setLabelText("AttributeLabel2", darkAttribInfo.attChs .. "" .. darkAttribInfo.value, equipAttPanel, color)
    end

    if brightAttribInfo then
        self:setLabelText("AttributeLabel1", brightAttribInfo.attChs .. "" .. brightAttribInfo.value, equipAttPanel, COLOR3.GREEN)
    end
end

-- 获取明属性
function EquipmentRefiningSuitDlg:getDarkAtt(equip)
    local equip = InventoryMgr:getItemByPos(self.pos)
    for _,v in pairs(EquipmentMgr:getAttribsTabByName(CHS[4000096])) do
        local isActive = false
        local attStr = string.format("%s_%d", v.field, Const.FIELDS_SUIT)
        if equip.extra[attStr] ~= nil then
            return {attChs = v.att, field = v.field, value = equip.extra[attStr]}
        end
    end
end

-- 获取暗属性
function EquipmentRefiningSuitDlg:getBringtAtt(equip)
    -- CHS[4000094]:套装特殊附加属性    CHS[4000095]:被放大的属性
    local attChs, value
    for _,v in pairs(EquipmentMgr:getAttribsTabByName(CHS[4000094])) do
        local attStr = string.format("%s_%d", v.field, Const.FIELDS_PROP4)
        if equip.extra[attStr] ~= nil then
            -- 是否被放大100倍
            value = equip.extra[attStr]
            -- 是否百分比显示
            if EquipmentMgr:getAttribsTabByName(CHS[3002517])[v.field] then
                value = value .. "%"
            end

            return {attChs = v.att, field = v.field, value = value}
        end
    end

    return nil
end

-- 设置超级绿水晶数量
function EquipmentRefiningSuitDlg:setCrystalInfo()
    local crystalPanel = self:getControl("ItemImagePanel")
    local equip = InventoryMgr:getItemByPos(self.pos)
    if not self:isSuitEquip(equip) then
        equip = nil
    end
    local crystalLevel = 0
    if equip then crystalLevel = equip.req_level end
    self:setImage("EquipmentImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[3002511])), crystalPanel)
    self:setItemImageSize("EquipmentImage", crystalPanel)
    local amountSuper = InventoryMgr:getAmountByNameIsForeverBind(CHS[3002511], self:isCheck("BindCheckBox"))
    local amountMini = InventoryMgr:getMiniBylevel(CHS[3002518], crystalLevel, self:isCheck("BindCheckBox"))
    local amount = amountSuper + amountMini
    if amount > 999 then amount = "*" end
    if amount == 0 then
        self:setNumImgForPanel("EquipmentImage", ART_FONT_COLOR.RED, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21, crystalPanel)
    else
        self:setNumImgForPanel("EquipmentImage", ART_FONT_COLOR.NORMAL_TEXT, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21, crystalPanel)
    end

    -- 设置宝石信息
    self:setGemPanelInfo(equip)
end

-- 消耗金钱
function EquipmentRefiningSuitDlg:getCostMoney(equipLevel)
    local costNum = 0
    if equipLevel then
        local lv = equipLevel
        if lv < 70 then
           costNum = 0
        else
            costNum = lv * lv * 24 + 7500
        end
    end

    -- 装备炼化套装属性手续费受占卜任务影响
    costNum = costNum * TaskMgr:getNumerologyEffect(NUMEROLOGY.STICK_XYQ_CY_ZBLH)

    return costNum
end

-- 消耗金钱
function EquipmentRefiningSuitDlg:setCostMoney(equipLevel)
    local costNum = self:getCostMoney(equipLevel)

    local cashText, fontColor = gf:getArtFontMoneyDesc(costNum)
    self:setNumImgForPanel("CostMoneyPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 23)
end

-- 已有金钱
function EquipmentRefiningSuitDlg:MSG_UPDATE(data)
    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("OwnMoneyPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 23)
end

function EquipmentRefiningSuitDlg:setEquipNameStr(str, defColor, panel)
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
    textCtrl:setPosition((size.width - textW) * 0.5, size.height  )
    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
end

function EquipmentRefiningSuitDlg:onRefiningButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

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

    local equip = InventoryMgr:getItemByPos(self.pos)
    if not equip then
        gf:ShowSmallTips(CHS[3002512])
        return
    end

    -- 限时装备
    if InventoryMgr:isTimeLimitedItem(equip) then
        gf:ShowSmallTips(CHS[5420219])
        return
    end

    if GameMgr.inCombat and self.pos <= 10 then
        gf:ShowSmallTips(CHS[3002488])
        return
    end

    if self.destPolar == 0 then
        gf:ShowSmallTips(CHS[3002520])
        return
    end

    local isBind
    if self:isCheck("BindCheckBox") then isBind = 1 else isBind = 0 end
    local bindCount = InventoryMgr:getAmountByNameForeverBind(CHS[3002511]) + InventoryMgr:getAmountByNameForeverBindLevel(CHS[3002518], equip.req_level)
    local cash = self:getCostMoney(equip.req_level)
    local amountSuper = InventoryMgr:getAmountByNameIsForeverBind(CHS[3002511], self:isCheck("BindCheckBox"))
    local amountMini = InventoryMgr:getMiniBylevel(CHS[3002518], equip.req_level, self:isCheck("BindCheckBox"))
    local amount = amountSuper + amountMini
    if amount < 1 then
        gf:askUserWhetherBuyItem(CHS[3002511])
        return
    end

    if cash > Me:queryBasicInt("cash") then
        gf:askUserWhetherBuyCash()
        return
    end


    -- 宝石状态
    local gemStr = "|0"

    -- 宝石不足判断
    if self:isCheck("PreviewItemCheckBox") and self:getCtrlVisible("PreviewItemCheckBox") then
        local gem = EquipmentMgr:getRefiningGemByEquip(equip)
        local gemCount = InventoryMgr:getAmountByNameIsForeverBind(gem, self:isCheck("BindCheckBox"))
        if gemCount < 1 then
            gf:ShowSmallTips(string.format(CHS[4100435], gem))
            return
        end

        gemStr = "|1"
    end

    self.destPolar = self.destPolar or equip.suit_polar
    local str, day = gf:converToLimitedTimeDay(equip.gift)
    if self:isCheck("BindCheckBox") and bindCount > 0 then
        -- 使用限定交易物品
        if  InventoryMgr:isLimitedItemForever(equip) or day > Const.LIMIT_TIPS_DAY then
            local para = string.format("%d|%d", isBind, self.destPolar)
            EquipmentMgr:equipSuitRefining(self.pos, para .. gemStr)
        else

            gf:confirm(string.format(CHS[3002521], 10), function()
                local para = string.format("%d|%d", isBind, self.destPolar)
                EquipmentMgr:equipSuitRefining(self.pos, para .. gemStr)
            end)
        end
    else
        local para = string.format("%d|%d", isBind, self.destPolar)
        EquipmentMgr:equipSuitRefining(self.pos, para .. gemStr)
    end
end

function EquipmentRefiningSuitDlg:onInfoButton(sender, eventType)
    local data = {one = CHS[4200596], isScrollToDef = true}
    DlgMgr:openDlgEx("EquipmentRuleNewDlg", data)
end

function EquipmentRefiningSuitDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_EQUIP_REFINE_OK == data.notify  then
        self:setInfoByPos(self.pos)
        DlgMgr:sendMsg("EquipmentChildDlg", "updateListRefining")
    end
end

-- 设置宝石相关是否隐藏
function EquipmentRefiningSuitDlg:setGemPanelVisible(isVisible)
    self:setCtrlVisible("PreviewMaterialPanel", isVisible)
    self:setCtrlVisible("PreviewItemCheckBox", isVisible)
    self:setCtrlVisible("PreviewItemLabel", isVisible)
    self:setCtrlVisible("PreviewItemLabel1", isVisible)
end

-- 设置宝石信息
function EquipmentRefiningSuitDlg:setGemPanelInfo(equip)
    local gemName = EquipmentMgr:getRefiningGemByEquip(equip)
    if not gemName then self:setGemPanelVisible(false) end

    -- icon
    self:setImage("PreviewMaterialImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(gemName)))
    self:setItemImageSize("PreviewMaterialImage")
    -- 名称
    self:setLabelText("PreviewItemLabel", gemName)

    -- 数量
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

    self:updateLayout("RefiningSuitPanel")
end

-- 点击宝石checkBox
function EquipmentRefiningSuitDlg:onGemCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name .. "Gem", 1)

        if not self.pos then return end
        local equip = InventoryMgr:getItemByPos(self.pos)
        local gem = EquipmentMgr:getRefiningGemByEquip(equip)

        gf:ShowSmallTips(string.format(CHS[4100436], InventoryMgr:getUnit(gem), gem))
    else
        InventoryMgr:setLimitItemDlgs(self.name .. "Gem", 0)
    end
end

-- 设置按钮状态
function EquipmentRefiningSuitDlg:setDisplayBtn(state)
    self.selectPolarLock = (state == REFING_STATE.HAS_REPLACE)

    self:setCtrlVisible("RefiningButton", state == REFING_STATE.NOMAL)
    self:setCtrlVisible("RestoreButton", state == REFING_STATE.HAS_REPLACE)
    self:setCtrlVisible("ReplaceButton", state == REFING_STATE.HAS_REPLACE)
end

-- 还原属性
function EquipmentRefiningSuitDlg:onRestoreButton(sender, eventType)
--[[
    if not self.pos then return end
    local equip = InventoryMgr:getItemByPos(self.pos)
    if not equip then return end
    EquipmentMgr:equipClearRefining(self.pos, CHS[4100437])
    --]]
    self:onRefiningButton()
end

-- 替换属性
function EquipmentRefiningSuitDlg:onReplaceButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if not self.pos then return end
    local equip = InventoryMgr:getItemByPos(self.pos)
    if not equip then return end

    gf:confirm(CHS[7200007], function()
        EquipmentMgr:equipApplyRefining(self.pos, CHS[4100437])
    end)
end

return EquipmentRefiningSuitDlg
