-- EquipmentFloatingFrameDlg.lua
-- Created by songcw Feb/11/2015
-- 装备悬浮框

local EquipmentFloatingFrameDlg = Singleton("EquipmentFloatingFrameDlg", Dialog)
local EquipmentAtt = require(ResMgr:getCfgPath("EquipmentAttribute.lua"))
local EquipAllAtt = require(ResMgr:getCfgPath("EquipAttribute.lua"))

local POLAR_METAL   = 1
local POLAR_WOOD    = 2
local POLAR_WATER   = 4
local POLAR_FIRE    = 8
local POLAR_EARTH   = 16

local MARGIN = 2
local FONT_HEIGHT = 25

local menuMore = {}

local MORE_BTN = {
    CHS[3002410],
    CHS[3002411],
}

local BTN_FUNC = {
    [CHS[3002410]] = { normalClick = "onSell" },
    [CHS[7000301]] = { normalClick = "onBaitan" },
    [CHS[7000302]] = { normalClick = "onTreasureBaitan"},
    [CHS[3002816]] = {normalClick = "onSource"}

}

local MainPanelInitSize = nil
local RootInitSize = nil

function EquipmentFloatingFrameDlg:init()
    if not MainPanelInitSize then MainPanelInitSize = self:getControl("MainPanel"):getContentSize() end
    if not RootInitSize then RootInitSize = self.root:getContentSize() end

    self:bindListener("MoreOperateButton", self.onMoreOperateButton)
    self:bindListener("OperateButton", self.onOperateButton)
    self:bindListener("MainPanel", self.onCloseButton)
    self:bindListener("DepositButton", self.onDepositButton)
    self:bindListener("SourceButton", self.onSource)
    self:bindListener("SourceButton", self.onSource, "SourcePanel")


    self:getControl("BttonPanel"):setLocalZOrder(10)

    self.btn = self:getControl("MoreOperateButton"):clone()
    self.btn:setAnchorPoint(0, 0)
    self.btn:retain()

    self.btnLayer = cc.Layer:create()
    self.btnLayer:setAnchorPoint(0, 0)
    self.btnLayer:retain()

    self.root:setAnchorPoint(0,0)
    self.blank:setLocalZOrder(Const.ZORDER_FLOATING)

    self:hookMsg("MSG_INVENTORY")
end

function EquipmentFloatingFrameDlg:cleanup()
    if self.btnLayer then
        self.btnLayer:release()
        self.btnLayer = nil
    end

    if self.btn then
        self.btn:release()
        self.btn = nil
    end

    self.isMore = nil
end

function EquipmentFloatingFrameDlg:setUpgradeAndRequire(equip)
    local mainInfo = EquipmentMgr:getMainInfoMap(equip)
    local count = #mainInfo
    for i = 1,2 do
        if i > count then
            self:setLabelText("MainLabel" .. i, "")
        else
            self:setLabelText("MainLabel" .. i, mainInfo[i].str, nil, mainInfo[i].color)
        end
    end
end

function EquipmentFloatingFrameDlg:setFloatingFrameInfo(equip, isCard)
    self.equip = equip
    local size = self:getControl("MainPanel"):getContentSize()

    -- 获取装备名称颜色         各个颜色属性
    local color, greenTab, yellowTab, pinkTab, blueTab = InventoryMgr:getEquipmentNameColor(equip)

    self:setCtrlVisible("WearImage", equip.pos and (equip.pos <= 10))
    self:setLabelText("EquipmentNameLabel", equip.name, nil, color)

    EquipmentMgr:setEvolveStar(self, equip)

    -- 套装相性
    if equip.suit_polar ~= 0 and equip.color == CHS[3002419] then
        self:setImage("PolarImage",  EquipmentMgr:getPolarRes(equip.suit_polar))
    else
        -- self:setCtrlVisible("PolarImage", false)
        self:setImagePlist("PolarImage", ResMgr.ui.touming)
    end
    -- 图标
    self:setImage("EquipmentImage", InventoryMgr:getIconFileByName(equip.name))
    self:setItemImageSize("EquipmentImage")
    self:setNumImgForPanel("EquipShapePanel", ART_FONT_COLOR.NORMAL_TEXT, equip.req_level, false, LOCATE_POSITION.LEFT_TOP, 21)

    -- 是否可以交易标志， 暂时隐藏
    self:setCtrlVisible("ExChangeImage", false, self:getControl("EquipShapePanel"))
    local imageCtl =  self:getControl("EquipmentImage")
    if equip and InventoryMgr:isTimeLimitedItem(equip) then
        InventoryMgr:removeLogoBinding(imageCtl)
        InventoryMgr:addLogoTimeLimit(imageCtl)
    elseif equip and InventoryMgr:isLimitedItem(equip) then
        InventoryMgr:removeLogoTimeLimit(imageCtl)
        InventoryMgr:addLogoBinding(imageCtl)
    else
        InventoryMgr:removeLogoTimeLimit(imageCtl)
        InventoryMgr:removeLogoBinding(imageCtl)
    end

    -- 贵重物品
    if gf:isExpensive(equip, false) then
        self:setCtrlVisible("PreciousImage", true)
    else
        self:setCtrlVisible("PreciousImage", false)
    end

    -- 设置改造和要求
    self:setUpgradeAndRequire(equip)
    local blueAttTab = self:getColorAtt(blueTab, "blue", equip)
    local pinkAttTab = self:getColorAtt(pinkTab, "pink", equip)
    local yellowAttTab = self:getColorAtt(yellowTab, "yellow", equip)
    local greenAttTab = self:getColorAtt(greenTab, "green", equip)
    local upgradeTab = EquipmentMgr:getUpgradeAtt(equip)

    local attribTab = self:getBaseAtt(equip)
    attribTab = self:setBaseAttColor(attribTab, blueTab, pinkTab, yellowTab, upgradeTab, equip)
    local limitTab = InventoryMgr:getLimitAtt(equip)
    local gongmingTab = EquipmentMgr:getGongmingValueAndColor(equip)

    -- 限时道具
      local timeLimit = {}
    if InventoryMgr:isTimeLimitedItem(equip) then

        local timeLimitStr = InventoryMgr:getTimeLimitStr(equip)

        table.insert(timeLimit, {color = COLOR3.RED, str = timeLimitStr})
    end

    local allAttribTab = {}
    for _,v in pairs(attribTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(blueAttTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(pinkAttTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(yellowAttTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(greenAttTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(upgradeTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(gongmingTab) do
        table.insert(allAttribTab, v)
    end

    for _, v in pairs(limitTab) do
        table.insert(allAttribTab, v)
    end

    for _, v in pairs(timeLimit) do
        table.insert(allAttribTab, v)
    end

    local count = #allAttribTab
    local missCount = 0


-- 设置属性
    -- 前三项是基础属性，如果快速切换，可能导致某些控件未被隐藏,先统一设置不可见
    for i = 1,16 do
        self:setLabelText("BaseAttributeLabel" .. i, "")
        self:setCtrlVisible("BaseAttributePanel" .. i, false)
    end

    for i = 1,16 do
        if i > count then
            missCount = missCount + 1
        else
            local desPanel = self:getControl("BaseAttributePanel" .. i)
            if desPanel then
                --self:setCtrlVisible("BaseAttributePanel" .. i, true)
                desPanel:setVisible(true)
                self:setDescript(allAttribTab[i].str, desPanel, allAttribTab[i].color)
            else
                self:setLabelText("BaseAttributeLabel" .. i, allAttribTab[i].str, nil, allAttribTab[i].color)
            end
        end
    end

    if isCard then
        self:setCtrlVisible("BttonPanel", false)
        --[[
        local panel = self:getControl("MainPanel")
        local panelSize = panel:getContentSize()
        local btn = self:getControl("MoreOperateButton", nil)
        local buttonSize = btn:getContentSize()
        btn:setPositionX(panelSize.width * 0.5)
        --]]
    elseif (equip.pos <= 10) then
        self:setButtonText("OperateButton", CHS[3002420])
    else
        self:setButtonText("OperateButton", CHS[3002421])
    end

    menuMore = self:setMenuMore(isCard, equip)
    if #menuMore == 0 and isCard then
        self:setCtrlVisible("SourcePanel", true)
    elseif #menuMore == 1 then
        self:setButtonText("MoreOperateButton", CHS[3002851])
    else
        self:setCtrlVisible("SourcePanel", false)
    end

    self:getControl("MainPanel"):setContentSize(MainPanelInitSize.width, MainPanelInitSize.height - (missCount) * (FONT_HEIGHT + MARGIN))
    self.root:setContentSize(self:getControl("MainPanel"):getContentSize())
end

function EquipmentFloatingFrameDlg:setDescript(descript, panel, color)
    panel:removeAllChildren()
    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(19)
    textCtrl:setString(descript)
    textCtrl:updateNow()
    --
    textCtrl:setDefaultColor(color.r, color.g, color.b)
    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition((size.width - textW) * 0.5, size.height - (size.height - 19) * 0.5)
    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
end

function EquipmentFloatingFrameDlg:getBaseAtt(equip)
    local baseAtt = {}
    local color = COLOR3.EQUIP_NORMAL
    if equip.equip_type == EQUIP.WEAPON then
        -- CHS[4000032]:伤害
        local basePower = equip.extra.phy_power_1 or 0
        local attChs = CHS[4000032]
        local phy_power_isTotal = equip.extra.phy_power_isTotal or 0
        table.insert(baseAtt, {phy_power_isTotal = phy_power_isTotal, attChs = attChs, value = basePower, color = color, field = "phy_power", basic = 1})

        return baseAtt
    end

    -- CHS[4000091]:防御
    local defValue = equip.extra.def_1 or 0
    local defChs = CHS[4000091]
    local def_isTotal = equip.extra.def_isTotal or 0
    table.insert(baseAtt, {def_isTotal = def_isTotal, attChs = defChs,value = defValue, color = color, field = "def", basic = 1})

    -- 最大气血
    local lifeStr = ""
    if equip.extra.max_life_1 ~= nil then
        local max_life_isTotal = equip.extra.max_life_isTotal or 0
        table.insert(baseAtt, {max_life_isTotal = max_life_isTotal, attChs = CHS[3002422], value = equip.extra.max_life_1, color = color, field = "max_life", basic = 1})
    end

    -- 最大魔法
    local manaStr = ""
    if equip.extra.max_mana_1 ~= nil then
        local max_mana_isTotal = equip.extra.max_mana_isTotal or 0
        table.insert(baseAtt, {max_mana_isTotal = max_mana_isTotal, attChs = CHS[3002423], value = equip.extra.max_mana_1, color = color, field = "max_mana", basic = 1})
    end

    -- 速度
    local speedStr = ""
    if equip.extra.speed_1 ~= nil then
        local speed_isTotal = equip.extra.speed_isTotal or 0
        table.insert(baseAtt, {speed_isTotal = speed_isTotal, attChs = CHS[3002424], value = equip.extra.speed_1, color = color, field = "speed", basic = 1})
    end

    return baseAtt
end

function EquipmentFloatingFrameDlg:setBaseAttColor(attribTab, blueTab, pinkTab, yellowTab, upgradeTab, equip)
    local baseTab = {}
    for i = 1, #attribTab do
        local field = attribTab[i].field
        baseTab[i] = {}
        baseTab[i] = gf:deepCopy(attribTab[i])

        local isAdd = false
        for j = 1, #blueTab do
            if blueTab[j].field == "power" then
                if (field == "phy_power" or field == "mag_power") and (not baseTab[i]["phy_power_isTotal"] or baseTab[i]["phy_power_isTotal"] == 0) then
                    baseTab[i].value = baseTab[i].value + blueTab[j].value
                    isAdd = true
                end
            end
            if field == blueTab[j].field and (not baseTab[i][field .. "_isTotal"] or baseTab[i][field .. "_isTotal"] == 0 ) then
                baseTab[i].value = baseTab[i].value + blueTab[j].value
                isAdd = true
            end
        end

        for j = 1, #pinkTab do
            if pinkTab[j].field == "power" then
                if (field == "phy_power" or field == "mag_power") and (not baseTab[i]["phy_power_isTotal"] or baseTab[i]["phy_power_isTotal"] == 0)  then
                    baseTab[i].value = baseTab[i].value + pinkTab[j].value
                    isAdd = true
                end
            end
            if field == pinkTab[j].field and (not baseTab[i][field .. "_isTotal"] or baseTab[i][field .. "_isTotal"] == 0 ) then
                baseTab[i].value = baseTab[i].value + pinkTab[j].value
                isAdd = true
            end
        end

        for j = 1, #yellowTab do
            if yellowTab[j].field == "power" then
                if (field == "phy_power" or field == "mag_power") and (not baseTab[i]["phy_power_isTotal"] or baseTab[i]["phy_power_isTotal"] == 0)  then
                    baseTab[i].value = baseTab[i].value + yellowTab[j].value
                    isAdd = true
                end
            end
            if field == yellowTab[j].field and (not baseTab[i][field .. "_isTotal"] or baseTab[i][field .. "_isTotal"] == 0 ) then
                baseTab[i].value = baseTab[i].value + yellowTab[j].value
                isAdd = true
            end
        end

        for j = 1, #upgradeTab do
            if field == upgradeTab[j].field and (not baseTab[i][field .. "_isTotal"] or baseTab[i][field .. "_isTotal"] == 0 ) then
                baseTab[i].value = baseTab[i].value + upgradeTab[j].value
                isAdd = true
            end
        end

        baseTab[i].str = attribTab[i].attChs .. ":" .. baseTab[i].value
        if isAdd or baseTab[i]["phy_power_isTotal"] == 1 or baseTab[i][field .. "_isTotal"] == 1 then
            baseTab[i].str = attribTab[i].attChs .. ":#B" .. baseTab[i].value .. "#n"
        end
    end

    return baseTab
end

-- 获取装备改造属性
function EquipmentFloatingFrameDlg:getColorAtt(attTab, colorStr, equip)
    local destTab = {}
    local color
    local maxValue
    local colorType = 0         -- 蓝、粉、金   需要显示强化完成度
    if colorStr == "blue" then
        color = COLOR3.EQUIP_BLUE
        colorType = 1
    elseif colorStr == "pink" then
        color = COLOR3.EQUIP_PINK
        colorType = 2
    elseif colorStr == "yellow" then
        color = COLOR3.YELLOW
        colorType = 3
    elseif colorStr == "green" then
        color = COLOR3.EQUIP_GREEN
    elseif colorStr == "upgrade" then
        color = COLOR3.EQUIP_BLUE
    end
    --]]
    for i, att in pairs(attTab) do
        local bai = ""
        if EquipmentAtt[CHS[3002425]][att.field] then bai = "%" end

        if EquipmentAtt[att.field] ~= nil then
            local str = EquipmentAtt[att.field] .. " " .. att.value .. bai
            maxValue = EquipmentMgr:getAttribMaxValueByField(equip, att.field) or ""
            if colorStr == "green" and att.dark == 1 then
                -- 绿属性最大值和其他不一样
                local min , max = EquipmentMgr:getSuitMinAndMax(equip, att.field)
                maxValue = max or maxValue
                -- 绿属性未激活未灰色
                if not equip.suit_enabled or equip.suit_enabled == 0 then
                    color = COLOR3.EQUIP_BLACK
                end
            end
            local completion = EquipmentMgr:getAttribCompletion(equip, att.field, colorType)
            if colorType ~= 0 and completion and completion ~= 0 then
                str = str .. "/" .. maxValue .. bai .. " #R(+" .. completion * 0.01 .. "%)#n"
                table.insert(destTab, {str = str, color = color, basic = 1})
            else
                str = str .. "/" .. maxValue .. bai
                table.insert(destTab, {str = str, color = color})
            end
        end
    end

    return destTab
end

-- 显示字符串
function EquipmentFloatingFrameDlg:setColorText(str, panel)
    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(20)
    textCtrl:setString(str)
    textCtrl:setContentSize(size.width, 0)
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition(0, textH)
    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
    panel:setContentSize(size.width, textH)
    return textH
end

function EquipmentFloatingFrameDlg:onMoreOperateButton(sender, eventType)
    if CHS[3002872] == sender:getTitleText() then
        self:onSource()
        return
    end

    local tag = sender:getTag()
    if not self.isMore then
        self.isMore = true
        local btnSize = self.btn:getContentSize()
        for i,v in pairs(menuMore) do
            local btn = self.btn:clone()
            btn:setTitleText(tostring(v))
            btn:setPosition(0, btnSize.height * i)
            self.btnLayer:addChild(btn)

            self:bindTouchEndEventListener(btn, function(self, sender, eventType)
                local title = sender:getTitleText()
                if BTN_FUNC[title].normalClick and "function" == type(self[BTN_FUNC[title].normalClick]) then
                    self[BTN_FUNC[title].normalClick](self, sender, eventType)
                end
            end)
        end
        self.btnLayer:setPosition(0, 0)
        self.btnLayer:removeFromParent()
        self.btnLayer:setTag(tag)
        sender:addChild(self.btnLayer)
    else
        self.isMore = false
        self.btnLayer:removeFromParent()
    end
end

function EquipmentFloatingFrameDlg:onOperateButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002430])
        return
    end

    local str = sender:getTitleText()
    if str == CHS[3002431] or str == CHS[3002421] then
        local index = 0
        if GuideMgr.equipList then
            for i, equip in ipairs(GuideMgr.equipList) do
                if self.equip.item_unique == equip.equipId then
                    local wearEquip = InventoryMgr:getItemByPos(self.equip.equip_type)
                    if not wearEquip or self.equip.req_level - wearEquip.req_level >= 9 then
                        -- 寻找到当前选择的装备是礼包的装备并且大于卸下的装备9级
                        index = i
                        DlgMgr:sendMsg("BagDlg", "setCleanGuideEquip", true)
                    end
                end
            end
        end

        if index > 0 then
            local pos = GuideMgr:getNextGiftEquipByIndex(index)
            if pos ~= self.equip.pos then
                DlgMgr:sendMsg("BagDlg", "selectByPos", pos)
            end
        end

        EquipmentMgr:CMD_EQUIP(self.equip.pos)
        DlgMgr:sendMsg("BagDlg", "swichFastionAndEquip", false)
    else
        EquipmentMgr:CMD_UNEQUIP(self.equip.pos)
    end

    self:onCloseButton()
end

-- 存入
function EquipmentFloatingFrameDlg:onDepositButton(sender, eventType)
    local str = sender:getTitleText()
    if str == CHS[4300070] then
        StoreMgr:cmdBagToStore(self.equip.pos)
    else
        StoreMgr:cmdStoreToBag(self.equip.pos)
    end
    self:onCloseButton()
end

-- 来源
function EquipmentFloatingFrameDlg:onSource(sender, eventType)

    if not self.equip then
        gf:ShowSmallTips(CHS[4000321])
        return
    end

    -- 物品处理
    if #InventoryMgr:getRescourse(self.equip.name) == 0 then
        gf:ShowSmallTips(CHS[4000321])
        return
    end

    local rect = self:getBoundingBoxInWorldSpace(self.root)
    InventoryMgr:openItemRescourse(self.equip.name, rect, nil, self.equip)
end

-- 出售
function EquipmentFloatingFrameDlg:onSell(sender, eventType)
    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    local tag = self.btnLayer:getTag()
    if self.equip.pos <= 10 then
        gf:ShowSmallTips(CHS[3002432])
        return
    end

    if gf:isExpensive(self.equip) then
        gf:ShowSmallTips(CHS[5420155])
        ChatMgr:sendMiscMsg(CHS[5420155])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onSell") then
        return
    end

    local value = gf:getMoneyDesc(InventoryMgr:getSellPriceValue(self.equip))
    local str = ""

    if InventoryMgr:isLimitedItem(self.equip) then
        str = string.format(CHS[6400047], value, CHS[6400050], self.equip.name)
    else
        str = string.format(CHS[6400047], value, CHS[6400049], self.equip.name)
    end

    gf:confirm(str,
        function ()
            InventoryMgr.sellAllTipsFlag = {}
            gf:sendGeneralNotifyCmd(NOTIFY.SELL_ITEM, self.equip.pos, 1)
            self:onCloseButton()
        end)
end

-- 设置显示存入格式
function EquipmentFloatingFrameDlg:setStoreDisplayType()
    if not self.equip then return end
    if self.equip.pos < 200 then
        self:setButtonText("DepositButton", CHS[4300070])
    else
        self:setButtonText("DepositButton", CHS[4300071])
    end
    self:setCtrlVisible("BttonPanel", false)
    self:setCtrlVisible("SourcePanel", false)
    self:setCtrlVisible("StorePanel", true)
  --[[
    -- 只有在仓库显示存入，StoreMgr:showHasStoreDlg接口中调用此函数，目前的对话框已经裁剪过，需增加一个来源的高度

    local mainNowSize = self:getControl("MainPanel"):getContentSize()
    local rootNowSize = self.root:getContentSize()

    self:getControl("MainPanel"):setContentSize(mainNowSize.width, mainNowSize.height)
    self.root:setContentSize(mainNowSize.width, mainNowSize.height + height)
    --]]
end

-- 摆摊
function EquipmentFloatingFrameDlg:onBaitan(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    local tag = self.btnLayer:getTag()
    if self.equip.pos <= 10 then
        gf:ShowSmallTips(CHS[3002434])
        return
    end

    -- 判断是否可以摆摊
    if InventoryMgr:isLimitedItem(self.item) then
        gf:ShowSmallTips(CHS[5000215])
        return
    end


    -- 摆摊等级限制
    local meLevel = Me:getLevel()
    if meLevel < MarketMgr:getOnSellLevel() then
        gf:ShowSmallTips(string.format(CHS[3002435], MarketMgr:getOnSellLevel()))
        return
    end


    local item = self.equip
    local dlg = DlgMgr:openDlg("MarketSellDlg")
    dlg:setSelectItem(item.pos)

    if item.item_type == ITEM_TYPE.EQUIPMENT and InventoryMgr:isEquip(item.equip_type) and  item.unidentified == 0 then
        local dlg = DlgMgr:openDlg("MarketSellEquipmentDlg")
        dlg:setEquipInfo(item, 3)
    else
        MarketMgr:openSellItemDlg(item, 3)
    end

    self:onCloseButton()
end

function EquipmentFloatingFrameDlg:onTreasureBaitan(sender, eventType)

    if not DistMgr:checkCrossDist() then return end

    local tag = self.btnLayer:getTag()
    if self.equip.pos <= 10 then
        gf:ShowSmallTips(CHS[3002434])
        return
    end

    -- 判断是否可以摆摊
    if InventoryMgr:isLimitedItem(self.item) then
        gf:ShowSmallTips(CHS[5000215])
        return
    end


    -- 摆摊等级限制
    local meLevel = Me:getLevel()
    if meLevel < MarketMgr:getGoldOnSellLevel() then
        gf:ShowSmallTips(string.format(CHS[3002435], MarketMgr:getGoldOnSellLevel()))
        return
    end


    local item = self.equip
    local dlg = DlgMgr:openDlg("MarketGoldSellDlg")
    dlg:setSelectItem(item.pos)

    if item.item_type == ITEM_TYPE.EQUIPMENT and InventoryMgr:isEquip(item.equip_type) and  item.unidentified == 0 then

        MarketMgr:openZhenbaoSellDlg(item)
    else
        MarketMgr:openSellItemDlg(item, 3, MarketMgr.TradeType.goldType)
    end

    self:onCloseButton()
end

function EquipmentFloatingFrameDlg:setMenuMore(isCard, equip)
    local menuTab = {}
    local isInBag = equip.pos and InventoryMgr:isInBagByPos(equip.pos)
    if not isCard then
        if isInBag then
            table.insert(menuTab, CHS[3002410])

            if self.equip.req_level >= 50 then
                table.insert(menuTab, CHS[7000301])
            end

            -- 贵重物品增加珍宝摆摊选项
            if self.equip and gf:isExpensive(self.equip) and MarketMgr:isShowGoldMarket() then
                table.insert(menuTab, CHS[7000302])
            end
        end

        table.insert(menuTab, CHS[3002816])

        -- 创建分享按钮
        self:createShareButton(self:getControl("ShareButton"), SHARE_FLAG.EQUIPATTRIB)
    else
        self:setCtrlVisible("ShareButton", false)
    end

    return menuTab
end

function EquipmentFloatingFrameDlg:MSG_INVENTORY(data)
    for i = 1, data.count do
        if not self.equip or data[i].pos == self.equip.pos then
            self:onCloseButton()
            return
        end
    end
end

return EquipmentFloatingFrameDlg
