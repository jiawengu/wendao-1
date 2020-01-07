-- MarketSellMoneyDlg.lua
-- Created by huangzz Dec/23/2017
-- 金钱摆摊

local MarketSellItemDlg = require('dlg/MarketSellItemDlg')
local MarketSellMoneyDlg = Singleton("MarketSellMoneyDlg", MarketSellItemDlg)
local RewardContainer = require("ctrl/RewardContainer")

local VALUE_FLOAT = 10 -- 摆摊波动费用的百分比
local VALUE_SECTION_MAX = 20
local VALUE_SECTION_MIN = 20

function MarketSellMoneyDlg:init()
    self:initBaisc()
    self:bindListener("HideButton", self.onHideButton)
    self:bindListener("ShowButton", self.onShowButton)
    self:bindListener("SellReduceButton", self.onSellReduceButton)
    self:bindListener("SellAddButton", self.onSellAddButton)

    self:hookMsg("MSG_GOLD_STALL_CASH_PRICE")
    self:hookMsg("MSG_GOLD_STALL_CASH_GOODS_LIST")

    self.rate = 0
    self.isSetTouchEnabelFalse = false
    self.price = 1
    self.inputNum  = 0
    self.floatPrice = nil

    -- 金钱条目
    self.itemCell = self:retainCtrl("ItemCell")
    self.selectImg = self:retainCtrl("ChosenEffectImage", self.itemCell)
end

function MarketSellMoneyDlg:getMaxValueSection()
    return VALUE_SECTION_MAX
end

function MarketSellMoneyDlg:getMinValueSection()
    return VALUE_SECTION_MIN
end

function MarketSellMoneyDlg:setSellMoney(data, type, goodId)
    local itemPanel = self:getControl("ItemPanel")
    self:setLabelText("NameLabel", CHS[3002143], itemPanel)
    self:setImagePlist("IconImage", ResMgr.ui.big_cash, itemPanel)
    self:setColorText(CHS[3002144], "DescriptionPanel", itemPanel)

    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(data.name))
    self:setNumImgForPanel("MoneyNumPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 21, itemPanel)

    local iconPanel = self:getControl("IconPanel", nil, itemPanel)
    local function showFloatPanel(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            sender.reward = {CHS[3002143], CHS[3002143]}
            RewardContainer:imagePanelTouch(sender, eventType)
        end
    end

    iconPanel:addTouchEventListener(showFloatPanel)

    self.goodId = goodId
    self.itemName =  data.name
    self.curItem = data
    self.data = data

    self:exchangeView(type, false)
    if self.VIEW_TYPE.ON_SELL == type or self.VIEW_TYPE.ON_PUBILC == type then
        local pubicPanel = self:getControl("OnSellPanel")
        local moneyPanel = self:getControl('FreePricePanel', nil, pubicPanel)
        local unitPanel = self:getControl("UnitPricePanel", nil, pubicPanel)
        local item = self.curItem
        local cashText, fontColor = gf:getArtFontMoneyDesc(item.price or 1000)
        self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, moneyPanel)

        local unitPrice = math.floor(tonumber(item.name) / item.price)
        local cashText, fontColor = gf:getArtFontMoneyDesc(unitPrice)
        self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, unitPanel)
        if self.VIEW_TYPE.ON_PUBILC == type then
            local timePanel = self:getControl("TimePanel", nil, "PublicityInfoPanel")
            local item = self.curItem
            if not item.endTime then return end
            local leftTime = item.endTime - gf:getServerTime()
            local timeStr = MarketMgr:getTimeStr(leftTime)
            self:setLabelText("StateLabel", timeStr, timePanel)
        elseif self.VIEW_TYPE.ON_SELL == type then
            local infoPanel = self:getControl("InfoPanel")
            local timePanel = self:getControl("TimePanel", nil, infoPanel)
            local item = self.curItem
            if not item.endTime then return end
            local leftTime = item.endTime - gf:getServerTime()
            local timeStr = MarketMgr:getTimeStr(leftTime)
            self:setLabelText("StateLabel", timeStr, timePanel)
        end
    elseif self.VIEW_TYPE.PRE_SELL == type then
        -- 等待标准价格
        self:setWaitingForStdPrice(true)

        -- 请求对比列表
        if not MarketMgr:getIsCanShowCashTag() or not MarketMgr:tryGetCurSellCashList() then
            -- 请求失败，直接使用客户端缓存的旧数据显示
            self:MSG_GOLD_STALL_CASH_GOODS_LIST()
        end

        -- 请求商品价格
        MarketMgr:requestMoneyItemStdPrice(self.itemName)

        self.standPrice = 0
        self.sellFloatNum = 0
        self:refreshUnPublicCash("")
    elseif self.VIEW_TYPE.OVER_SELL == type  then
        -- 等待标准价格
        self:setWaitingForStdPrice(true)

        -- 请求对比列表
        if not MarketMgr:tryGetCurSellCashList() then
            -- 请求失败，直接使用客户端缓存的旧数据显示
            self:MSG_GOLD_STALL_CASH_GOODS_LIST()
        end

        -- 请求商品价格
        MarketMgr:requestMoneyItemStdPrice(self.itemName)

        local item = self.curItem
        self.standPrice = item.price or 1000
        self.sellFloatNum = 0
        self:refreshUnPublicCash("")
    else
        self.standPrice = 0
        self.sellFloatNum = 0
    end
end

function MarketSellMoneyDlg:refreshUnPublicCash(displayCash)
    -- 刷新单价
    local unitPanel = self:getControl("UnitPricePanel", nil, "SellPanel")
    if displayCash then
        self:removeNumImgForPanel("MoneyValuePanel", LOCATE_POSITION.MID, unitPanel)
    elseif self.data then
        local price = self:getUnPublicPrice()
        local unitPrice = math.floor(tonumber(self.data.name) / price)
        local cashText, fontColor = gf:getArtFontMoneyDesc(unitPrice)
        self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, unitPanel)
    end

    MarketSellItemDlg.refreshUnPublicCash(self, displayCash)
end

function MarketSellMoneyDlg:onSellButton(sender, eventType)
    self.isRestall = false
    self:sellItem(false)
end

function MarketSellMoneyDlg:onReSellButton(sender, eventType)
    self.isRestall = true
    self:sellItem(true)
end

function MarketSellMoneyDlg:onCancelSellButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if Me:queryBasicInt('cash') + tonumber(self.itemName) > 2000000000 then
        gf:ShowSmallTips(CHS[5420254])
        return
    end

    local item = self.curItem
    if item.status == 1 then
        local tradeType = self:getTradeType()
        gf:confirm(CHS[3003073], function()
            MarketMgr:stopSell(self.goodId, tradeType)
        end, nil, nil, nil, nil, true)
    else
        MarketMgr:stopSell(self.goodId, self:getTradeType())
    end

    DlgMgr:closeDlg(self.name)
end

function MarketSellMoneyDlg:sellItem(isRestall)
    -- 只要玩家意图以当前的floatNum去摆摊某商品（点击了摆摊按钮），则记录此floatNum（当前商品）
    -- 下一次如果要摆摊同样的商品，则依据此floatNum确定摆摊价格
    if self.curItem and self.itemName and self.sellFloatNum then
        MarketMgr:setLastSellUnPublicItem({name = self.itemName, level = self.curItem.level, floatNum = self.sellFloatNum})
    end

    local price = self:getUnPublicPrice()
    if price == 0 then
        return gf:ShowSmallTips(CHS[3003074])
    end

    self:sell(math.floor(price), false, isRestall)
end

function MarketSellMoneyDlg:sell(price, isPublic, isReStall)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if not DistMgr:checkCrossDist() then return end

    if Me:getAdultStatus() == 2 then
        -- 未完成实名认证
        if LeitingSdkMgr:isOverseas() then
            -- 海外版本
            gf:confirmEx(CHS[4300453], CHS[4300455], function ()
                gf:copyTextToClipboard("gmservice@leiting.com")
                gf:ShowSmallTips(CHS[4300456])
            end, nil, nil, nil, nil, nil, nil, true)
        else
            -- 非海外版本
            gf:confirm(CHS[4300454], function ()
                -- body
            end, nil, nil, nil, nil, nil, true)
        end

        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("sell", price, isPublic, isReStall) then
        return
    end

    local sellNum = MarketMgr:getSellPosCount(self:getTradeType())
    local allNum = MarketMgr:getMySellNum(self:getTradeType())

    if not sellNum then
        gf:ShowSmallTips("222"..CHS[3003075])
        return
    end

    if not isReStall then
        if sellNum >= allNum then
            if Me:getVipType() ~= 3 then
                gf:ShowSmallTips(CHS[3003076])
                return
            else
                gf:ShowSmallTips(CHS[3003077])
                return
            end
        end

    end

    if self:getBoothCost(price, not isPublic) > Me:queryBasicInt('cash') then
        gf:askUserWhetherBuyCash(self.inputNum  - Me:queryBasicInt('cash'))
        return
    end

    local sellPos = MarketMgr:getSellPos(self:getTradeType())
    local data = self.data
    if isReStall then
        MarketMgr:reStartSell(self.goodId, price, self:getTradeType())
    elseif sellPos then
        MarketMgr:startSell(tonumber(data.name), price, sellPos, 3, self:getTradeType())
    end

    DlgMgr:closeDlg(self.name)
    return true
end

function MarketSellMoneyDlg:startSearch(itemName)
    local itemInfo = MarketMgr:getSellItemInfo(itemName)

    MarketMgr:startSearch(CHS[3002143] .. itemName, "", 1)
end

-- 刷新摆摊价格
function MarketSellMoneyDlg:MSG_GOLD_STALL_CASH_PRICE(data)
    if not self.data then return end
    self:setWaitingForStdPrice(false)

    self.floatPrice = json.decode(data.class_str)

    if tostring(data.name) ~= self.data.name then
        -- 当前选中的和服务器下发的不一致，不理
        return
    end

    self.standPrice = self.floatPrice[100]

    -- 如果本次摆摊的非公示道具与上一次意图摆摊的非公示道具相同，则floatNum沿用上一次的值
    local itemName = self.data.name
    local lastSellUnPublicItem = MarketMgr:getLastSellUnPublicItem()
    local level = self.data.level
    local lastFloatNum
    if itemName and lastSellUnPublicItem.name == itemName and lastSellUnPublicItem.level == level then
        lastFloatNum = lastSellUnPublicItem.floatNum
    end

    if lastFloatNum then
        self.sellFloatNum = lastFloatNum
    else
        self.sellFloatNum = 0
    end

    self:refreshUnPublicCash()
end

-- 获取摊位费
function MarketSellMoneyDlg:getBoothCost(sellPrice, isUnpublic)
    return MarketMgr:getBoothCost(sellPrice, isUnpublic, self:getTradeType(), true)
end

-- 刷新对比列表
function MarketSellMoneyDlg:MSG_GOLD_STALL_CASH_GOODS_LIST(data)
    local itemLsit =  MarketMgr:getCurSellCashList()
    local list = self:resetListView("ItemListView", 5)

    if not MarketMgr:getIsCanShowCashTag() then
        self:setCtrlVisible("NoticePanel", true)
    else
        self:setCtrlVisible("NoticePanel", false)
        for i = 1, #itemLsit do
            list:pushBackCustomItem(self:cerateItemCell(itemLsit[i]))
        end
    end
end

-- 创建对比单元格
function MarketSellMoneyDlg:cerateItemCell(data)
    local cell = self.itemCell:clone()

    self:setImagePlist("IconImage", ResMgr.ui.big_cash, cell)

    -- 名字
    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(data.name))
    self:setNumImgForPanel("MoneyNumPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 21, cell)


    -- 金钱
    if data.price then
        local txt, color = gf:getMoneyDesc(data.price, true)
        self:setLabelText("CoinLabel", txt, cell, color)
        self:setLabelText("CoinLabel2", txt, cell)
        self:setCtrlVisible("CoinLabel", true, cell)
        self:setCtrlVisible("CoinLabel2", true, cell)
        self:setCtrlVisible("CoinImage", true, cell)
        self:setCtrlVisible("NoneLabel", false, cell)
    else
        -- 无此订单，置灰
        self:setCtrlVisible("CoinLabel", false, cell)
        self:setCtrlVisible("CoinLabel2", false, cell)
        self:setCtrlVisible("CoinImage", false, cell)
        self:setCtrlVisible("NoneLabel", true, cell)

        local img = self.selectImg:clone()
        cell:addChild(img)
        gf:grayImageView(img)
        gf:grayImageView(self:getControl("IconImage", nil, cell))
        gf:grayImageView(self:getControl("GridImage", nil, cell))
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if data.price then
                self:addSelcelImage(cell)
                self.selectItemData = data
            end
        end
    end

    local iconPanel = self:getControl("IconPanel", nil, cell)
    local function showFloatPanel(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if data.price then
                self:addSelcelImage(cell)
                self.selectItemData = data
            end

            sender.reward = {CHS[3002143], CHS[3002143]}
            RewardContainer:imagePanelTouch(sender, eventType)
        end
    end

    iconPanel:addTouchEventListener(showFloatPanel)

    cell:addTouchEventListener(listener)

    return cell
end

function MarketSellMoneyDlg:cleanup()
    MarketSellItemDlg.cleanup(self)
end

return MarketSellMoneyDlg
