-- MarketSellItemDlg.lua
-- Created by liuhb Apr/22/2015
-- 确认摆摊界面
local MarketSellBasicDlg = require('dlg/MarketSellBasicDlg')
local MarketSellItemDlg = Singleton("MarketSellItemDlg", MarketSellBasicDlg)

MarketSellItemDlg.VIEW_TYPE = {
    ON_SELL = 1,    -- 正在摆摊
    OVER_SELL = 2,  -- 超过时间
    PRE_SELL = 3,   -- 准备摆摊
    ON_PUBILC = 4,  -- 公示中
    BUY_ITEM = 5,   -- 购买
}

local MAX_RATE_TIME = 6


local SELL_RATE = 0.01

local MIN_PUBLIC__BOOTH_COST = 100000
local MAX_UNPUBLIC_BOOTH_COST = 100000

local MaterialAtt = {
    [EQUIP.BALDRIC] = {att = CHS[4000090], field = "max_life"},
    [EQUIP.NECKLACE] = {att =  CHS[4000110], field = "max_mana"},
    [EQUIP.LEFT_WRIST] = {att =  CHS[4000032], field = "phy_power"},
    [EQUIP.RIGHT_WRIST] = {att =  CHS[4000032], field = "phy_power"},
}

local VALUE_FLOAT = 10 -- 摆摊波动费用的百分比
local VALUE_SECTION_MAX = 90
local VALUE_SECTION_MIN = 50

local BTN_FUNC = {
    ["SellReduceButton"]    = "onSellReduceButton",
    ["SellAddButton"]       = "onSellAddButton",
    ["SellNumAddButton"]    = "onSellNumReduceButton",
    ["SellNumReduceButton"] = "onSellNumAddButton",
    ["ReSellReduceButton"]  = "onReSellReduceButton",
    ["ReSellAddButton"]     = "onReSellAddButton",
}

function MarketSellItemDlg:init()
    self:initBaisc()
    self:bindListener("HideButton", self.onHideButton)
    self:bindListener("ShowButton", self.onShowButton)
    self:bindListener("SellReduceButton", self.onSellReduceButton)
    self:bindListener("SellAddButton", self.onSellAddButton)

    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_MARKET_SEARCH_RESULT")

    self.rate = 0
    self.isSetTouchEnabelFalse = false
    self.price = 1
    self.inputNum  = 0


    -- 单元格
    self.itemCell = self:retainCtrl("ItemCell")
    self.selectImg = self:retainCtrl("ChosenEffectImage", self.itemCell)
end

function MarketSellItemDlg:cleanup()
    self.floatPrice = nil
    MarketSellBasicDlg.cleanup(self)

end

-- 等待标准价格 该状态下，置灰 "+"、"-"号按钮 重新摆摊按钮
function MarketSellItemDlg:setWaitingForStdPrice(isWaiting)
    self.isWaitingStdPrice = isWaiting
    self:setCtrlEnabled("SellAddButton", not isWaiting)
    self:setCtrlEnabled("SellReduceButton", not isWaiting)
    self:setCtrlEnabled("ReSellButton", not isWaiting)
end

function MarketSellItemDlg:onHideButton()
    self:setCtrlVisible("ShowButton", true)
    self:setCtrlVisible("HideButton", false)
    self:setCtrlVisible("PriceComparePanel", false)

    local sellItemPanel = self:getControl("SellItemPanel")
    sellItemPanel:setAnchorPoint(0.5, 0)
    sellItemPanel:setPositionX(sellItemPanel:getParent():getContentSize().width / 2)
end

function MarketSellItemDlg:onShowButton()
    self:setCtrlVisible("HideButton", true)
    self:setCtrlVisible("ShowButton", false)
    self:setCtrlVisible("PriceComparePanel", true)

    local sellItemPanel = self:getControl("SellItemPanel")
    sellItemPanel:setAnchorPoint(1, 0)
    sellItemPanel:setPositionX(sellItemPanel:getParent():getContentSize().width)
end

-- 切换摆摊和撤摊界面
function MarketSellItemDlg:exchangeView(type, isPubic)
    self.viewType = type
    local reSellCtrl = self:getControl("ReSellPanel")
    local sellCtrl = self:getControl("SellPanel")
    self:setCtrlVisible("ReSellButton", false)
    self:setCtrlVisible("CancelSellButton", false)
    self:setCtrlVisible("SellButton", false)
    self:setCtrlVisible("CancelButton", false)
    self:setCtrlVisible("PriceComparePanel", false)
    self:setCtrlVisible("SellPanel", false)
    self:setCtrlVisible("PublicityInfoPanel", false)

    if self.VIEW_TYPE.ON_SELL == type then
        self:exchangeBasicView(type)
        self:changePanelToMiddle()
    elseif self.VIEW_TYPE.OVER_SELL == type then
        if isPubic then
            self:exchangeBasicView(type)
            self:changePanelToMiddle()
        else
            --self:setCtrlVisible("InfoPanel", false)
            --:setLabelText("StateLabel", CHS[3003086])
            self:setResellInfo()
        end

    elseif self.VIEW_TYPE.PRE_SELL == type then
        if isPubic then
            self:setCtrlVisible("PublicitySellPanel", true)
            self:bindSellNumInput()
            self:changePanelToMiddle()
        else
            self:setCtrlVisible("PriceComparePanel", true)
            self:setCtrlVisible("HideButton", true)
            self:setCtrlVisible("SellPanel", true)
        end
        self:setCtrlVisible("SellButton", true)
        self:setCtrlVisible("CancelButton", true)
    elseif self.VIEW_TYPE.ON_PUBILC == type then
        self:exchangeBasicView(type)
        self:changePanelToMiddle()
    elseif self.VIEW_TYPE.BUY_ITEM == type then
        self:setLabelText("TitleLabel_1", CHS[6200052])
        self:setLabelText("TitleLabel_2", CHS[6200052])
        self:setCtrlVisible("BuyPanel", true)
        self:setCtrlVisible("BuyButton", true)
        self:setCtrlVisible("CancelButton", true)
    end
end

-- 设置重新摆摊信息
function MarketSellItemDlg:setResellInfo()
    self:setCtrlVisible("TimeoutPanel", true)
    self:setCtrlVisible("PriceComparePanel", true)
    self:setCtrlVisible("HideButton", true)
    self:setCtrlVisible("SellPanel", true)
    self:setCtrlVisible("CancelSellButton", true)
    self:setCtrlVisible("ReSellButton", true)
end


-- 把界面居中
function MarketSellItemDlg:changePanelToMiddle()
    local sellItemPanel = self:getControl("SellItemPanel")
    sellItemPanel:setAnchorPoint(0.5, 0)
    sellItemPanel:setPositionX(sellItemPanel:getParent():getContentSize().width / 2)
end

-- 设置数据
-- goodId 撤摊 和 重新摆摊所需要的 物品 id
function MarketSellItemDlg:setItemInfo(data, type, goodId)
    self.goodId = goodId

    local requireName

    -- 不同类型传的name不一样，装备要区分鉴定未鉴定，时装等
    if data.item_type == ITEM_TYPE.EQUIPMENT and data.unidentified == 1 then
        -- 未鉴定装备
        self.itemName = data.name..CHS[3003087]
        requireName = data.name
    elseif (data.item_type == ITEM_TYPE.EQUIPMENT and data.equip_type == EQUIP_TYPE.FASHION_SUIT and data.fasion_type == FASION_TYPE.FASION) or
        (data.item_type == ITEM_TYPE.CUSTOM and data.equip_type == EQUIP_TYPE.FASHION_SUIT and data.fasion_type == FASION_TYPE.FASION) then
        -- 时装
        self.itemName = data.alias
    else
        self.itemName =  data.name
    end

    self.curItem = data
    self.data = data

    local isPublic = MarketMgr:isPublicityItem(self.itemName)
    self:exchangeView(type, isPublic)
    if self.VIEW_TYPE.ON_SELL == type or self.VIEW_TYPE.ON_PUBILC == type then
        local pubicPanel = self:getControl("OnSellPanel")
        local moneyPanel = self:getControl('FreePricePanel', nil, pubicPanel)
        local item = MarketMgr:getSelectGoodInfo()
        local cashText, fontColor = gf:getArtFontMoneyDesc(item.price or 1000)
        self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, moneyPanel)
        if self.VIEW_TYPE.ON_PUBILC == type then
            local publicInfo = self:getControl("PublicityInfoPanel")
            local timePanel = self:getControl("TimePanel", nil, publicInfo)
            local item = MarketMgr:getSelectGoodInfo()
            if not item.endTime then return end
            local leftTime = item.endTime - gf:getServerTime()
            local timeStr = MarketMgr:getTimeStr(leftTime)
            self:setLabelText("StateLabel", timeStr, timePanel)
        elseif self.VIEW_TYPE.ON_SELL == type then
            local infoPanel = self:getControl("InfoPanel")
            local timePanel = self:getControl("TimePanel", nil, infoPanel)
            local item = MarketMgr:getSelectGoodInfo()
            if not item.endTime then return end
            local leftTime = item.endTime - gf:getServerTime()
            local timeStr = MarketMgr:getTimeStr(leftTime)
            self:setLabelText("StateLabel", timeStr, timePanel)
            self:setOnsellNumInfo()
        end
    elseif self.VIEW_TYPE.PRE_SELL == type then
        if isPublic then
            -- 初值化公示信息
            local pubicPanel = self:getControl("PublicitySellPanel")
            local moneyPanel = self:getControl('FreePricePanel', nil, pubicPanel)
            local boothPanel = self:getControl("BoothPricePanel", nil, pubicPanel)
            local cashText, fontColor = gf:getArtFontMoneyDesc(self:getBoothCost(1))
            self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, boothPanel)
        else
            -- 初值化非公示信息
            self:startSearch(self.itemName)
            if data.fasion_type == FASION_TYPE.FASION then
                -- 时装需要发送别名
                MarketMgr:requestItemPrice(self:getRequiePriceName(data.alias))
            else
                MarketMgr:requestItemPrice(self:getRequiePriceName(data.name))
            end

            self.standPrice = 0
            self.sellFloatNum = 0
            self:refreshUnPublicCash()
        end
    elseif self.VIEW_TYPE.OVER_SELL == type  then
        local pubicPanel = nil

        if isPublic then
            pubicPanel = self:getControl("PublicitySellPanel")
            local moneyPanel = self:getControl('FreePricePanel', nil, pubicPanel)
            local boothPanel = self:getControl("BoothPricePanel", nil, pubicPanel)
            self:setCtrlVisible("Label", false, moneyPanel)
            local item = MarketMgr:getSelectGoodInfo()
            self.inputNum = item.price or 1
            local cashText, fontColor = gf:getArtFontMoneyDesc(self.inputNum)
            self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, moneyPanel)

            local boothCashText, boothfontColor = gf:getArtFontMoneyDesc(self:getBoothCost(self.inputNum))
            self:setNumImgForPanel("MoneyValuePanel", boothfontColor, boothCashText, false, LOCATE_POSITION.MID, 23, boothPanel)
        else
            -- 等待标准价格
            self:setWaitingForStdPrice(true)

            self:startSearch(self.itemName)
            MarketMgr:requestItemPrice(self:getRequiePriceName(requireName or self.itemName))
            pubicPanel = self:getControl("SellPanel")
            local item = MarketMgr:getSelectGoodInfo()
            self.standPrice = item.price or 1000
            self.sellFloatNum = 0
            self:refreshUnPublicCash("")
        end
    else
        self.standPrice = 0
        self.sellFloatNum = 0
    end

    self.bagPos = data.bagPos
    self.sellPos = data.sellPos
    self.amount = data.amount
    self.data = data
    -- 设置item描述等
    -- 设置等级、图标、数量
    local iconPanel = self:getControl("IconPanel")
    if nil == data.level or 0 == data.level then
        self:removeNumImgForPanel(iconPanel, LOCATE_POSITION.LEFT_TOP)
    else
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21)
    end

    local iconPath = ResMgr:getItemIconPath(data.icon)
    self:setImage("IconImage", iconPath)
    self:setItemImageSize("IconImage")

    if data.item_type == ITEM_TYPE.EQUIPMENT and data.req_level and data.req_level > 0 then
        self:removeNumImgForPanel(iconPanel, LOCATE_POSITION.LEFT_TOP)
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, data.req_level, false, LOCATE_POSITION.LEFT_TOP, 21)
    end

    if data.item_type == ITEM_TYPE.ARTIFACT and data.item_polar then
        InventoryMgr:addArtifactPolarImage(self:getControl("IconImage", nil, iconPanel), data.item_polar)
    end

    local function showFloatPanel(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.VIEW_TYPE.PRE_SELL == type then
                local rect = self:getBoundingBoxInWorldSpace(iconPanel)
                InventoryMgr:showItemByItemData(data, rect)
            else
                local item  = MarketMgr:getSelectGoodInfo()
                local rect = self:getBoundingBoxInWorldSpace(iconPanel)
                self:requireMarketGoodCard(goodId.."|"..(item.endTime or ""), MARKET_CARD_TYPE.FLOAT_DLG, rect, false)
            end
        end
    end

    iconPanel:addTouchEventListener(showFloatPanel)

    local funStr = nil
    self:setCtrlVisible("BlackPositionPanel", false)
    -- 设置物品名称
    if string.match(data.name, CHS[3003088]) then
        -- 带属性黑水晶
        local name = string.gsub(data.name,CHS[3003089],"")
        self:setLabelText("NameLabel", name)
        local field = EquipmentMgr:getAttribChsOrEng(name)
        local str = field .. "_" .. Const.FIELDS_EXTRA1
        local value = 0
        local maxValue = 0
        local bai = ""
        if data.extra[str] then
            value = data.extra[str]
            local equip = {req_level = data.level, equip_type = data.upgrade_type}
            maxValue = EquipmentMgr:getAttribMaxValueByField(equip, field) or ""
            if EquipmentMgr:getAttribsTabByName(CHS[3003090])[field] then bai = "%" end

        end

        local fieldStr = value .. bai .. "/" .. maxValue .. bai

        funStr = CHS[3003091] .. EquipmentMgr:getEquipChs(data.upgrade_type) .. " \n"

        funStr = funStr ..  name .. " " .. fieldStr

        self:setLabelText("NameLabel2", fieldStr)

        -- 设置部位
        self:setCtrlVisible("BlackPositionPanel", true)
        self:setLabelText("BlackPositionLabel", CHS[3002824] .. EquipmentMgr:getEquipChs(data.upgrade_type))
    elseif (data.item_type == ITEM_TYPE.EQUIPMENT and data.equip_type == EQUIP_TYPE.FASHION_SUIT and data.fasion_type == FASION_TYPE.FASION) or
        (data.item_type == ITEM_TYPE.CUSTOM and data.equip_type == EQUIP_TYPE.FASHION_SUIT and data.fasion_type == FASION_TYPE.FASION) then
        -- 时装显示别名
        self:setLabelText("NameLabel", data.alias)
        self:setCtrlVisible("NameLabel2",false)
    elseif EquipmentMgr:isJewelry(data) then
        self:setLabelText("NameLabel", data.name)
        local developStr = EquipmentMgr:getJewelryDevelopInfo(data)
        self:setLabelText("NameLabel2", developStr, nil, COLOR3.BLUE)
        local label = self:getControl("NameLabel2")
        label:setFontSize(19)
    else
        -- 设置物品名称
        self:setLabelText("NameLabel", data.name)
        self:setCtrlVisible("NameLabel2",false)
    end

    -- 设置描述
    self:setDesc(data)
end

-- 批量出售需要显示数量
function MarketSellItemDlg:setOnsellNumInfo()

end

function MarketSellItemDlg:setDesc(data)
    self:setCtrlVisible("ArtifactDescriptionPanel", false)
    self:setCtrlVisible("JewelryDescriptionPanel", false)
    self:setCtrlVisible("DesPanel", false)

    -- 法宝属性
    if data.equip_type and data.equip_type == EQUIP_TYPE.ARTIFACT then
        self:setCtrlVisible("ArtifactDescriptionPanel", true)
        local panel = self:getControl("ArtifactDescriptionPanel")
        panel:setVisible(true)
        -- 名称与类型
        local nameLabel = self:getControl("NameLabel", nil, "ItemPanel")
        local nameLabel2 = self:getControl("NameLabel2", nil, "ItemPanel")
        nameLabel:setColor(COLOR3.YELLOW)
        nameLabel:setFontSize(23)
        nameLabel2:setString(CHS[7000145])
        nameLabel2:setFontSize(19)
        nameLabel2:setVisible(true)

        local expStr = string.format(CHS[7000185], data.exp, data.exp_to_next_level) -- 道法
        local nimbusStr = string.format(CHS[7000186], data.nimbus, Formula:getArtifactMaxNimbus(data.level)) -- 灵气
        local intimacyStr = string.format(CHS[7000187], data.intimacy) -- 亲密度
        local polarStr = string.format(CHS[7000188], gf:getPolar(data.item_polar),
            EquipmentMgr:getPolarAttribByArtifact(data)) -- 相性
        local skillStr = string.format(CHS[7000189], EquipmentMgr:getArtifactSkillDesc(data.name))  -- 法宝技能
        local extraSkillStr  -- 法宝特殊技能
        if data.extra_skill and data.extra_skill ~= "" then
            local extraSkillName = SkillMgr:getArtifactSpSkillName(data.extra_skill)
            local extraSkillLevel = data.extra_skill_level
            local extraSkillDesc = SkillMgr:getSkillDesc(extraSkillName).desc
            extraSkillStr = string.format(CHS[7000311], extraSkillName, extraSkillLevel)
                           .. CHS[7000078] .. extraSkillDesc
        else
            extraSkillStr = string.format(CHS[7000151], CHS[7000153]) .. CHS[7000078]
                           .. CHS[3001385].. "\n" .. CHS[7000310]
        end

        local height1 = self:setDescript(expStr, self:getControl("BaseAttributePanel1", nil, panel), COLOR3.TEXT_DEFAULT)
        local height2 = self:setDescript(nimbusStr, self:getControl("BaseAttributePanel2", nil, panel), COLOR3.TEXT_DEFAULT)
        local height3 = self:setDescript(intimacyStr, self:getControl("BaseAttributePanel3", nil, panel), COLOR3.TEXT_DEFAULT)
        local height4 = self:setDescript(polarStr, self:getControl("BaseAttributePanel4", nil, panel), COLOR3.TEXT_DEFAULT)
        local height5 = self:setDescript(skillStr, self:getControl("BaseAttributePanel5", nil, panel), COLOR3.TEXT_DEFAULT)
        local height6 = self:setDescript(extraSkillStr, self:getControl("BaseAttributePanel6", nil, panel), COLOR3.TEXT_DEFAULT)
        local totalHeight = height1 + height2 + height3 + height4 + height5 + height6

        local scollCtrl = self:getControl("ScrollView", nil, panel)
        local container = self:getControl("ArtifactInfoPanel", nil, panel)
        container:setContentSize({width = container:getContentSize().width, height = totalHeight})
        scollCtrl:setInnerContainerSize(container:getContentSize())
    elseif InventoryMgr:isJewelry(data.equip_type) then
        self:setCtrlVisible("JewelryDescriptionPanel", true)

        local panel = self:getControl("JewelryDescriptionPanel")
        local itemDesc = InventoryMgr:getDescript(data.name)
        self:setColorText(itemDesc, "DescriptionPanel", panel, nil, nil, COLOR3.TEXT_DEFAULT, 19)

        -- 属性
        local attValueStr = string.format("%s_%d", MaterialAtt[data.equip_type].field, Const.FIELDS_NORMAL)
        local attValue = data.extra[attValueStr] or 0

        -- 基础属性

        local totalAtt = {}

        local _, __, funStr = EquipmentMgr:getJewelryAttributeInfo(data)
        table.insert(totalAtt, {str = funStr, color = COLOR3.LIGHT_WHITE})

        local blueAtt = EquipmentMgr:getJewelryBule(data)

        -- 蓝属性
        for i = 1, #blueAtt do
            table.insert(totalAtt, {str = blueAtt[i], color = COLOR3.BLUE})
        end

        -- 转换次数
        if data.transform_num and data.transform_num > 0 then
            table.insert(totalAtt, {str = string.format(CHS[4010062], data.transform_num), color = COLOR3.LIGHT_WHITE})
        end

        -- 冷却时间
        if EquipmentMgr:isCoolTimed(data) then
            table.insert(totalAtt, {str = string.format(CHS[4010063], EquipmentMgr:getCoolTimedByDay(data)), color = COLOR3.LIGHT_WHITE})
        end

        for i = 1, Const.JEWELRY_ATTRIB_MAX do
            if totalAtt[i] then
                local attPanel = self:getControl("BaseAttributePanel" .. i, nil, panel)
                if attPanel then
                    self:setColorTextEx(totalAtt[i].str, attPanel, totalAtt[i].color, 17)
                else
                    self:setLabelText("BaseAttributeLabel" .. i, totalAtt[i].str, panel, totalAtt[i].color)
                end
            else
                self:setLabelText("BaseAttributeLabel" .. i, "", panel)
            end
        end

        local scrollView = self:getControl("ScrollView", nil, panel)
        local scrollViewSz = scrollView:getContentSize()
        local desHeight = self:getControl("DescriptionPanel", nil, panel):getContentSize().height
        local attHeight = (self:getControl("BaseAttributeLabel1", nil, panel):getContentSize().height + 2) * (#totalAtt + 1)
        scrollView:setInnerContainerSize({width = scrollViewSz.width, height = desHeight + attHeight})
    elseif data.item_type == ITEM_TYPE.CHANGE_LOOK_CARD then
        self:setChanegeCardInfo(data)
    else
        self:setCtrlVisible("DesPanel", true)

        -- 获取道具描述
        local itemDesc = InventoryMgr:getDescriptByItem(data)

        -- 获取道具功效
        local itemEffect = InventoryMgr:getFuncStr(data)

        local scrollView = self:getControl("ScrollView", Const.UIScrollView, "DesPanel")
        local scrollViewSz = scrollView:getContentSize()
        self:setColorText(itemDesc, "DescriptionPanel", "DesPanel", nil, nil, COLOR3.TEXT_DEFAULT, 19)
        self:setColorText(itemEffect, "DescriptionPanel2", "DesPanel", nil, nil, COLOR3.TEXT_DEFAULT, 19)
        local desPanelSz = self:getControl("DescriptionPanel"):getContentSize()
        local desPanelSz2 = self:getControl("DescriptionPanel2"):getContentSize()
        scrollView:setInnerContainerSize({width = scrollViewSz.width, height = desPanelSz.height + desPanelSz2.height + 10})
    end
end

function MarketSellItemDlg:setDescript(descript, panel, defaultColor)
    panel:removeAllChildren()
    local textCtrl = CGAColorTextList:create()
    if defaultColor then
        textCtrl:setDefaultColor(defaultColor.r, defaultColor.g, defaultColor.b)
    end

    textCtrl:setFontSize(19)
    textCtrl:setString(descript)
    textCtrl:setContentSize(panel:getContentSize().width, 0)
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition((panel:getContentSize().width - textW) * 0.5,textH)

    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
    panel:setContentSize(panel:getContentSize().width, textH)
    return textH
end

function MarketSellItemDlg:setChanegeCardInfo(data)
    local info = InventoryMgr:getChangeCardEff(data.name)
    local panel = self:getControl("ChangeCardDescriptionPanel")
    for i = 1, 10 do
        if info[i] then
            self:setLabelText("BaseAttributeLabel" .. i, info[i].str, panel, info[i].color)
        else
            self:setLabelText("BaseAttributeLabel" .. i, "", panel)
        end
    end

    local icon = InventoryMgr:getIconByName(data.name)
    local imgPath = ResMgr:getItemIconPath(icon)
    local goodsImage = self:getControl("IconImage", Const.UIImage, "ChangeCardPanel")
    goodsImage:loadTexture(imgPath)
    self:setItemImageSize("IconImage", "ChangeCardPanel")

    -- 名字
    self:setLabelText("NameLabel", data.name, "ChangeCardPanel")

    self:setCtrlVisible("ItemPanel", data.item_type ~= ITEM_TYPE.CHANGE_LOOK_CARD, "SellItemPanel")
    self:setCtrlVisible("ChangeCardPanel", data.item_type == ITEM_TYPE.CHANGE_LOOK_CARD, "SellItemPanel")

    local iconPanel = self:getControl("IconPanel", nil, "ChangeCardPanel")
    iconPanel.data = data
    local function showFloatPanel(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local rect = self:getBoundingBoxInWorldSpace(iconPanel)
            StoreMgr:showHasStoreDlg(data.pos, rect)
        end
    end

    iconPanel:addTouchEventListener(showFloatPanel)
end

function MarketSellItemDlg:startSearch(itemName)
    local itemInfo = MarketMgr:getSellItemInfo(itemName)

    -- 修行卷轴已经不产出，原有的摆摊的必须兼容下
    if not itemInfo and itemName == CHS[4300001] then
        itemInfo = {subClass = CHS[3001137]}
    end

    if itemInfo.subClass == CHS[4100000] then
        -- 变身卡
        MarketMgr:startSearch(self:getNormalSearchKey(itemName), string.format("size:5;name:%s;", itemName), 1)
    elseif itemInfo.subClass == CHS[3001107] and itemInfo.secondClass == CHS[5400066] then
        -- 纪念宠元神碎片
        MarketMgr:startSearch(self:getNormalSearchKey(itemName), string.format("size:5;name:%s;", itemName), 1)
    elseif itemInfo.subClass == CHS[5000270] and itemInfo.secondClass == CHS[5000271] then
        -- 时装
        MarketMgr:startSearch(self:getNormalSearchKey(itemName), string.format("size:5;name:%s;", itemInfo.keyName), 1)
    elseif itemInfo.subClass == CHS[3001137] and itemInfo.secondClass == CHS[5420176] then
        -- 家具
        MarketMgr:startSearch(self:getNormalSearchKey(itemName), string.format("size:5;name:%s;", itemName), 1)
    elseif itemInfo.subClass == CHS[3001137] and (itemName == CHS[8000010] or itemName == CHS[8000011]) and self.data then
        -- 经验心得 or 道武心得
        MarketMgr:startSearch(self:getNormalSearchKey(itemName), string.format("size:5;near_level:%d;", self.data.level or 0), 1)
    else
        MarketMgr:startSearch(self:getNormalSearchKey(itemName), "size:5", 1)
    end
end

-- 获取非公示的key
function MarketSellItemDlg:getNormalSearchKey(item)
    local itemInfo = MarketMgr:getSellItemInfo(item)

    -- 修行卷轴已经不产出，原有的摆摊的必须兼容下
    if not itemInfo and item == CHS[4300001] then
        itemInfo = {subClass = CHS[3001137], level = 0}
    end

    local key = ""
    if itemInfo.subClass == CHS[4100000] then -- 变身卡
        self.searchSecondClass = itemInfo.secondClass
        local polar = InventoryMgr:getCardInfoByName(item).polar
        self.searchThirdClass = MarketMgr:getChangeCardThirdClass(polar)
        key = itemInfo.subClass .. "_" .. itemInfo.secondClass .. "_" .. self.searchThirdClass
    elseif itemInfo.subClass == CHS[3003093] then
        key = itemInfo.subClass .. "_" .. item .. "_" ..self:getStoneClassLevel()
    elseif itemInfo.subClass == CHS[3001107] and itemInfo.secondClass == CHS[5400066] then
        -- 纪念宠元神碎片特殊处理
        key = itemInfo.subClass.."_"..itemInfo.secondClass .. "_" .. item
    elseif itemInfo.secondClass == CHS[4100655] then
        local day = tonumber(string.match(item, CHS[4100664]))
        local dayStr
        if day then
            dayStr = day .. CHS[4100665]
        else
            dayStr = CHS[5410269]
        end

        key = itemInfo.subClass.."_" ..itemInfo.secondClass.."_" ..dayStr
    elseif itemInfo.subClass == CHS[2000369] then
        -- 菜肴
        local str = string.match(item, ".*%((.+)%)")
        key = itemInfo.subClass.."_"..itemInfo.secondClass .. "_" .. str
    elseif itemInfo.secondClass == CHS[5420176] then
        -- 家具
        local furnitureInfo = HomeMgr:getFurnitureInfo(item)
        local levelStr = HomeMgr:furnitureLevelToChs()[furnitureInfo.level]
        key = itemInfo.subClass.."_" ..itemInfo.secondClass.."_" ..levelStr.."_" ..item
    elseif itemInfo.secondClass then
        if itemInfo.level ~= 0 then
            key = itemInfo.subClass.."_"..itemInfo.secondClass.."_"..itemInfo.level
        else
            key = itemInfo.subClass.."_" ..itemInfo.secondClass.."_" ..item
        end
    elseif type(item) == "string" and string.match(item, CHS[2100031]) and self.curItem then
        -- 骑宠灵魄
        key = itemInfo.subClass.."_".. CHS[2100031] .. "_" .. string.match(item, CHS[4300150]) .. CHS[3002813]
    else
        local levelRange = ""
        if type(item) == "string" and string.match(item, CHS[4200213]) and self.curItem then
            levelRange = "_" .. MarketMgr:getXindeLVByLevel(self.curItem.level, item)
        end
        key = itemInfo.subClass.."_".. item .. levelRange
    end

    return key
end


-- 获取请求价格名字格式
function MarketSellItemDlg:getRequiePriceName(item)
    local itemInfo = MarketMgr:getSellItemInfo(item)

    -- 修行卷轴已经不产出，原有的摆摊的必须兼容下
    if not itemInfo and item == CHS[4300001] then
        itemInfo = {subClass = CHS[3001137], level = 0}
    end

    local name = ""
    if itemInfo.subClass == CHS[3003093] then
        name = self:getStoneClassLevel()..CHS[3003094]..item
    else
        name = item
    end

    return name
end

-- 获取玩家妖石适合等级
function MarketSellItemDlg:getStoneClassLevel()

    return self.curItem.level
end

function MarketSellItemDlg:operAddReduceBtn(label, operNum, maxNum)
    -- 获取控件
    if nil == self.rate then
        self.rate = 0
    end

    if nil == self.price then
        self.price = 1
    end

    -- local num = tonumber(self:getLabelText(label))
    local cash = MarketMgr:getItemAddCash(self.price)
    local maxCash = MarketMgr:getItemAddMaxCash(self.price)
    local num = self.price + cash * (self.rate + operNum)

    if self.price + maxCash < num then
        num = self.price + maxCash
        return
    end

    if self.price - maxCash > num then
        num = self.price - maxCash
        return
    end

    self.rate = self.rate + operNum

    if num <= 0 then
        num = 1
    end

    if nil ~= maxNum then
        if num >= maxNum then
            num = maxNum
        end
    end

    self:setPanelMoney(label, num)
    self:updateSellCash()
    self:updateCashLabel()
end

function MarketSellItemDlg:operAddReduceNumBtn(label, operNum, maxNum)
    -- 获取控件
    local num = tonumber(self:getLabelText(label))
    num = num + operNum

    if num <= 0 then
        num = 1
    end

    if nil ~= maxNum then
        if num >= maxNum then
            num = maxNum
        end
    end

    self:setLabelText(label, num)

    self:updateSellCash()
    self:updateBtnView(label, maxNum)
end

function MarketSellItemDlg:updateBtnView(label, maxNum)
    local num = tonumber(self:getLabelText(label))
    if nil == num then
        num = 0
    end

    if num >= maxNum then
        local Ctrl = self:getControl("SellNumAddButton")
        gf:grayImageView(Ctrl)
        if self.isTouch then
            self.isSetTouchEnabelFalse = true
        else
            Ctrl:setTouchEnabled(false)
        end
    else
        local Ctrl = self:getControl("SellNumAddButton")
        gf:resetImageView(Ctrl)
        Ctrl:setTouchEnabled(true)
    end

    if 1 >= num then
        local Ctrl = self:getControl("SellNumReduceButton")
        gf:grayImageView(Ctrl)
        if self.isTouch then
            self.isSetTouchEnabelFalse = true
        else
            Ctrl:setTouchEnabled(false)
        end
    else
        local Ctrl = self:getControl("SellNumReduceButton")
        gf:resetImageView(Ctrl)
        Ctrl:setTouchEnabled(true)
    end
end

function MarketSellItemDlg:refreshUnPublicCash(displayCash)

    local reduceBtn = self:getControl("SellReduceButton")
    local addBtn = self:getControl("SellAddButton")

    if self.sellFloatNum > 0 - self:getMinValueSection() then
        if not self.isWaitingStdPrice then
        gf:resetImageView(reduceBtn)
        reduceBtn:setEnabled(true)
        end
    else
        gf:grayImageView(reduceBtn)
        reduceBtn:setEnabled(false)
    end

    if self.sellFloatNum < self:getMaxValueSection() then
        if not self.isWaitingStdPrice then
        gf:resetImageView(addBtn)
        addBtn:setEnabled(true)
        end
    else
        gf:grayImageView(addBtn)
        addBtn:setEnabled(false)
    end

    if self.sellFloatNum < 0 then
        self:setLabelText("SellFloatLabel", string.format(CHS[3003095], self.sellFloatNum), nil, COLOR3.RED)
    elseif self.sellFloatNum == 0 then
        self:setLabelText("SellFloatLabel", CHS[3003096], nil, COLOR3.TEXT_DEFAULT)
    elseif self.sellFloatNum > 0 then
        self:setLabelText("SellFloatLabel",  string.format(CHS[3003097], self.sellFloatNum), nil, COLOR3.GREEN)
    end

    local price = self:getUnPublicPrice()
    local pubicPanel = self:getControl("SellPanel")
    local moneyPanel = self:getControl('PricePanel', nil, pubicPanel)
    local boothPanel = self:getControl("BoothPricePanel", nil, pubicPanel)

    if displayCash then
        self:removeNumImgForPanel("MoneyValuePanel", LOCATE_POSITION.MID, moneyPanel)
        self:removeNumImgForPanel("MoneyValuePanel", LOCATE_POSITION.MID, boothPanel)
    else
        local cashText, fontColor = gf:getArtFontMoneyDesc(price)
        self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, moneyPanel)

        cashText, fontColor = gf:getArtFontMoneyDesc(self:getBoothCost(price, true))
        self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, boothPanel)
    end

    self:reFreshPrice()
end

function MarketSellItemDlg:setDouleBoothCost(price)
    local pubicPanel = self:getControl("SellPanel")
    local boothPanel = self:getControl("BoothPricePanel", nil, pubicPanel)
    local cashText, fontColor = gf:getArtFontMoneyDesc(self:getBoothCost(price, true))
    self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, boothPanel)
end

function MarketSellItemDlg:setMoneyDesc(ctrlName, cash)
    local num = tonumber(cash) or 0
    local ctrl = self:getControl(ctrlName)
    local cashText, cashColor = gf:getMoneyDesc(num, true)
    ctrl:setString(cashText)
    ctrl:setColor(cashColor)
end

function MarketSellItemDlg:onSellReduceButton(sender, eventType)

    if self.sellFloatNum > 0 - self:getMinValueSection() then
        self.sellFloatNum = self.sellFloatNum - VALUE_FLOAT
        self:refreshUnPublicCash()
    end

end

function MarketSellItemDlg:onSellAddButton(sender, eventType)

    if self.sellFloatNum < self:getMaxValueSection() then
        self.sellFloatNum = self.sellFloatNum + VALUE_FLOAT
        self:refreshUnPublicCash()
    end

end

function MarketSellItemDlg:getMaxValueSection()
    local max = 0
    if self.floatPrice then
        for start = 0, 200 , 10 do
            if self.floatPrice[start] and start >= max then
                max = start
            end
    end
    end

    return max - 100
end

function MarketSellItemDlg:getMinValueSection()
    local min = 200
    if self.floatPrice then
        for start = 0, 200 , 10 do
            if self.floatPrice[start] and start <= min then
                min = start
            end
    end
    end

    return 100 - min
end

function MarketSellItemDlg:onSellNumAddButton(sender, eventType)
    self:operAddReduceNumBtn("SellNumLabel", -1, math.min(self.amount, self.overlayTime))
end

function MarketSellItemDlg:onSellNumReduceButton(sender, eventType)
    self:operAddReduceNumBtn("SellNumLabel", 1, math.min(self.amount, self.overlayTime))
end

function MarketSellItemDlg:onReSellReduceButton(sender, eventType)
    self:operAddReduceBtn("ReItemCoinPanel", -1)
end

function MarketSellItemDlg:onReSellAddButton(sender, eventType)
    self:operAddReduceBtn("ReItemCoinPanel", 1)
end

--[[function MarketSellItemDlg:onCancelButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
end]]

--[[function MarketSellItemDlg:onCancelSellButton(sender, eventType)
    gf:confirm(CHS[5000138], function()
        MarketMgr:stopSell(self.sellPos, self.amount)
        DlgMgr:closeDlg(self.name)
    end)

    DlgMgr:closeDlg(self.name)
end]]

function MarketSellItemDlg:onSellButton(sender, eventType)
    self:sellItem(false)
end


function MarketSellItemDlg:sellItem(isRestall)


    if not DistMgr:checkCrossDist() then return end

    local isPublic = MarketMgr:isPublicityItem(self.itemName)

    if isPublic then
        if self:sell(self.inputNum, true, isRestall) then
            -- 只要玩家意图以当前的floatNum去摆摊某商品（点击了摆摊按钮），则记录此floatNum（当前商品）
            -- 下一次如果要摆摊同样的商品，则依据此floatNum确定摆摊价格
            -- WDSY-29848 由于消息还没有来，点击寄售会因为价格原因失败，再次点击就不是上一次寄售价格了，所以再寄售消息发送后在设置
            if self.curItem and self.itemName and self.sellFloatNum then
                MarketMgr:setLastSellUnPublicItem({name = self.itemName, level = self.curItem.level, floatNum = self.sellFloatNum})
            end
        end
    else
        local price = self:getUnPublicPrice()
        if price == 0 then return gf:ShowSmallTips(CHS[3003074]) end
        if self:sell(math.floor(price), false, isRestall) then
            -- 只要玩家意图以当前的floatNum去摆摊某商品（点击了摆摊按钮），则记录此floatNum（当前商品）
            -- 下一次如果要摆摊同样的商品，则依据此floatNum确定摆摊价格
            if self.curItem and self.itemName and self.sellFloatNum then
                MarketMgr:setLastSellUnPublicItem({name = self.itemName, level = self.curItem.level, floatNum = self.sellFloatNum})
    end

        end
    end
end

function MarketSellItemDlg:getUnPublicPrice()
    if not self.sellFloatNum or  not self.standPrice or not self.floatPrice then return 0  end
    local price = self.floatPrice[100 + self.sellFloatNum]

    return math.floor(price)
end

function MarketSellItemDlg:getPrice()
    local isPublic = MarketMgr:isPublicityItem(self.itemName)
    local price = 0
    if isPublic then
        price = self.inputNum
    else
        price = self:getUnPublicPrice()
    end
end

function MarketSellItemDlg:reFreshPrice()

end

function MarketSellItemDlg:onReSellButton(sender, eventType)
    if not MarketMgr:isItemCanSell(self.curItem) then
        gf:ShowSmallTips(CHS[4100324])
        return
    end
    self:sellItem(true)
end

function MarketSellItemDlg:setPanelMoney(ctrlName, num, align)
    if nil == align then
        align = LOCATE_POSITION.LEFT_BOTTOM
    end

    local ctrl = self:getControl(ctrlName)
    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(num))
    self:setNumImgForPanel(ctrl, fontColor, cashText, false, align, 23)
end

function MarketSellItemDlg:setPanelNum(ctrlName, num, align)
    if nil == align then
        align = LOCATE_POSITION.LEFT_BOTTOM
    end

    local ctrl = self:getControl(ctrlName)
    self:setNumImgForPanel(ctrl, ART_FONT_COLOR.NORMAL_TEXT, num, false, align, 21)
end

function MarketSellItemDlg:blindAddReduceLongClick(name, root)
    local widget = self:getControl(name, nil, root)

    if not widget then
        Log:W("Dialog:bindListViewListener no control " .. name)
        return
    end

    local function updataCount()
        self[BTN_FUNC[name]](self, widget)
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.clickBtn = sender:getName()
            schedule(widget , updataCount, 0.2)
            self.isTouch = true
        elseif eventType == ccui.TouchEventType.ended then
            self.isTouch = false
            updataCount()
            widget:stopAllActions()

            if self.isSetTouchEnabelFalse then
                sender:setTouchEnabled(false)
                self.isSetTouchEnabelFalse = false
            end
        end
    end

    widget:addTouchEventListener(listener)
end

-- 刷新摆摊价格
function MarketSellItemDlg:MSG_GENERAL_NOTIFY(data)
    if not self.data then return end

    if NOTIFY.NOTIFY_STALL_ITEM_PRICE == data.notify then
        self:setWaitingForStdPrice(false)

        self.floatPrice = json.decode(data.para)
        if not string.match(self.floatPrice.name, self.data.name) then
            -- 当前选中的和服务器下发的不一致，不理
            -- 用匹配是因为 时装 这类特殊的
            self.floatPrice = nil
            return
        end

        self.standPrice = self.floatPrice[100]

        -- 如果本次摆摊的非公示道具与上一次意图摆摊的非公示道具相同，则floatNum沿用上一次的值
        local itemName
        if self.data.item_type == ITEM_TYPE.EQUIPMENT and self.data.unidentified == 1 then
            itemName = self.data.name .. CHS[3003087]
        else
            itemName = self.data.name
        end

        local lastSellUnPublicItem = MarketMgr:getLastSellUnPublicItem()
        local level = self.data.level
        local lastFloatNum
        if itemName and lastSellUnPublicItem.name == itemName and lastSellUnPublicItem.level == level then
            lastFloatNum = lastSellUnPublicItem.floatNum
        end

        -- 要判断 self.floatPrice[100 + lastFloatNum]，因为如果玩家先上架一个，在线更新后再上架，会记录上一次
        if lastFloatNum and self.floatPrice[100 + lastFloatNum] then
            self.sellFloatNum = lastFloatNum
        else
            self.sellFloatNum = 0
        end

        self:refreshUnPublicCash()
    end
end

-- 刷新对比列表
function MarketSellItemDlg:MSG_MARKET_SEARCH_RESULT(data)
    local itemLsit =  MarketMgr:getSearchSellItemList()
    self:setCtrlVisible("NoticePanel", false)
    self.leftListCtrl, self.leftListSize = self:resetListView("ItemListView",5)

    for i = 1, #itemLsit do
        self.leftListCtrl:pushBackCustomItem(self:cerateItemCell(itemLsit[i]))
    end
end


-- 创建对比单元格
function MarketSellItemDlg:cerateItemCell(data)
    local cell = self.itemCell:clone()

    local icon = InventoryMgr:getIconByName(data.name)
    local imgPath = ResMgr:getItemIconPath(icon)
    local goodsImage = self:getControl("IconImage", Const.UIImage, cell)
    goodsImage:loadTexture(imgPath)
    self:setItemImageSize("IconImage", cell)

     -- 名字
    self:setLabelText("NameLabel", data.name, cell)

    if data.req_level and data.req_level > 0 then
        self:setNumImgForPanel("IconPanel", ART_FONT_COLOR.NORMAL_TEXT, data.req_level, false, LOCATE_POSITION.LEFT_TOP, 21, cell)
    end

    if data.level and data.level > 0 then
        self:setNumImgForPanel("IconPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21, cell)
    end

    if data.amount and data.amount > 1 then
        self:setNumImgForPanel("IconPanel", ART_FONT_COLOR.NORMAL_TEXT, data.amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21, cell)
    end

    if data.item_type == ITEM_TYPE.ARTIFACT and data.item_polar then
        InventoryMgr:addArtifactPolarImage(goodsImage, data.item_polar)
    end

    -- 金钱
    local txt, color = gf:getMoneyDesc(data.price, true)
    local lable = self:getControl("CoinLabel", nil, cell)
    lable:setString(txt)
    lable:setColor(color)


    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:addSelcelImage(cell)
            self.selectItemData = data
        end
    end

    cell:addTouchEventListener(listener)


    local iconPanel = self:getControl("IconPanel", nil, cell)
    local function showFloatPanel(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:addSelcelImage(cell)
            self.selectItemData = data
            local rect = self:getBoundingBoxInWorldSpace(iconPanel)
            MarketMgr:requireMarketGoodCard(data.id.."|"..data.endTime, MARKET_CARD_TYPE.FLOAT_DLG, rect, false)
        end
    end

    iconPanel:addTouchEventListener(showFloatPanel)

    -- 未鉴定
    if  string.match(self.itemName, CHS[3003098]) then
        InventoryMgr:addLogoUnidentified(goodsImage)
    end

    return cell
end


function MarketSellItemDlg:addSelcelImage(item)
    self.selectImg:removeFromParent()
    item:addChild(self.selectImg)
end

return MarketSellItemDlg
