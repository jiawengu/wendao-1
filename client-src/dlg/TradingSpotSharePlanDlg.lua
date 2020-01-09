-- TradingSpotSharePlanDlg.lua
-- Created by lixh Des/26/2018
-- 商贾货站货品跟买列表界面

local TradingSpotSharePlanDlg = Singleton("TradingSpotSharePlanDlg", Dialog)

function TradingSpotSharePlanDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("SeeButton", self.onSeeButton)
    self:bindListViewListener("ItemsListView", self.onSelectItemsListView)

    self.listView = self:getControl("ItemsListView")
    self.selectEffect = self:retainCtrl("SChosenEffectImage")
    self.itemPanel = self:retainCtrl("ItemsUnitPanel")

    self:refreshRestTimeDes()
    self:hookMsg("MSG_CONFIRM")
    self:hookMsg("MSG_TRADING_SPOT_DATA")
end

function TradingSpotSharePlanDlg:setData(data)
    -- 商品数据
    self.goodsInfo = data

    -- 收市时间
    self.tradingCloseTime = data.close_time

    -- 角色名称
    self:setLabelText("NameLabel", string.format(CHS[7190477], data.char_name), "UpPanel")

    if not self:checkOverTimeTrading() then
        -- 方案未过期,设置列表数据
        self:setListData(data)

        -- 默认选择第1项
        self:setSelectItem(self.listView:getItems()[1])
    else
        self:refreshRestTimeDes()
    end
end

function TradingSpotSharePlanDlg:checkOverTimeTrading(overTime)
    if overTime or (self.goodsInfo and self.goodsInfo.count <= 0) then
        -- 已过期，显示莲花姑娘，影响商品列表
        self:setCtrlVisible("ListPanel", false)
        self:setCtrlVisible("NoticePanel", true)
        return true
    end

    return false
end

function TradingSpotSharePlanDlg:setListData(data)
    self.listView:removeAllItems()

    -- 设置列表数据
    for i = 1, data.count do
        local itemPanel = self.itemPanel:clone()
        self:setSingleItemInfo(itemPanel, data.list[i])

        self:setCtrlVisible("BackImage1", i % 2 ~= 0, itemPanel)
        self:setCtrlVisible("BackImage2", i % 2 == 0, itemPanel)

        self.listView:pushBackCustomItem(itemPanel)
    end
end

function TradingSpotSharePlanDlg:setSingleItemInfo(panel, info)
    local itemName, itemInfo = TradingSpotMgr:getItemInfo(info.goods_id)
    if not itemName or not itemInfo then return end

    -- 图标
    self:setImage("ItemImage", ResMgr:getItemIconPath(itemInfo.icon), panel)

    -- 名称
    self:setLabelText("NameLabel", itemName, panel)

    -- 单价
    local priceDes, _ = gf:getMoneyDesc(math.floor(info.price), true)
    self:setLabelText("PriceLabel", priceDes, panel)

    -- 涨幅
    local valueStr, desColor = TradingSpotMgr:getPriceUpTextInfo(info.range)
    self:setLabelText("FloatLabel", valueStr, panel, desColor)

    -- 持有数量
    local volumeDes, _ = gf:getMoneyDesc(math.floor(info.volume), true)
    self:setLabelText("NumLabel", volumeDes, panel)

    -- 持有总额
    local allPriceDes, _ = gf:getMoneyDesc(math.floor(info.all_price), true)
    self:setLabelText("AllPriceLabel", allPriceDes, panel)

    -- 设置标记
    panel.info = info
end

-- 设置选中
function TradingSpotSharePlanDlg:setSelectItem(panel)
    if self.selectEffect:getParent() then
        self.selectEffect:removeFromParent()
    end

    panel:addChild(self.selectEffect)
    self.selectItem = panel
end

-- 刷新休市，收市时间
function TradingSpotSharePlanDlg:refreshRestTimeDes()
    self:setCtrlVisible("TipsLabel1", false)
    self:setCtrlVisible("TipsLabel2", false)
    if self:checkOverTimeTrading() then return end

    local closeTradingTime = TradingSpotMgr:getTradingCloseTime()
    if closeTradingTime then
        local leftTime = closeTradingTime - gf:getServerTime()
        if leftTime > 0 then
            self:setCtrlVisible("TipsLabel1", true)
            local hour = math.floor(leftTime / 3600)
            local minute = math.ceil(leftTime % 3600 / 60)
            if hour > 0 then
                self:setLabelText("TipsLabel1", string.format(CHS[7190455], hour, minute))
            else
                self:setLabelText("TipsLabel1", string.format(CHS[7190482], minute))
            end

            -- 每隔1分钟刷新一次休市、收市时间
            if self.refreshTimeAction then self.root:stopAction(self.refreshTimeAction) end
            self.refreshTimeAction = performWithDelay(self.root, function()
                self:refreshRestTimeDes()
                self.refreshTimeAction = nil
            end, 60)
        else
            self:checkOverTimeTrading(true)
        end
    else
        -- 没有收市时间，请求数据
        TradingSpotMgr:requestMainSpotData(1)

        -- 由于买入方案界面打开时，有可能还没有请求过主界面数据
        -- 所以在此标记一下，用于在没有主界面数据的情况下请求数据时不关闭本界面
        self.isWaitingMainSpotData = true
    end
end

-- 获取当前列表下一个商品的goods_id
function TradingSpotSharePlanDlg:getNextGoodsId(goodsId, isLeft)
    for i = 1, #self.goodsInfo.list do
        if goodsId == self.goodsInfo.list[i].goods_id then
            if isLeft then
                if self.goodsInfo.list[i - 1] then
                    return self.goodsInfo.list[i - 1].goods_id
                end
            else
                if self.goodsInfo.list[i + 1] then
                    return self.goodsInfo.list[i + 1].goods_id
                end
            end

            break
        end
    end
end

function TradingSpotSharePlanDlg:onSelectItemsListView(sender, eventType)
    local item = self:getListViewSelectedItem(sender)
    if not item then return end

    -- 选中
    self:setSelectItem(item)
end

function TradingSpotSharePlanDlg:cleanup()
    self.selectItem = nil
    self.goodsInfo = nil
    self.isWaitingMainSpotData = nil
end

-- 打开角色的货品名片
function TradingSpotSharePlanDlg:requestItemInfo(goodsId)
    local para1 = string.format(CHS[7190493], self.goodsInfo.card_gid, goodsId)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTICE_QUERY_CARD_INFO, para1, "")
end

function TradingSpotSharePlanDlg:onSeeButton(sender, eventType)
    local function notOpenCallCb()
        self:onCloseButton()
    end

    if not TradingSpotMgr:checkCanOepnTradingSpot(notOpenCallCb) then return end

    if self:checkOverTimeTrading() then
        gf:ShowSmallTips(CHS[7190499])
        return
    end

    if not self.selectItem then
        gf:ShowSmallTips(CHS[7190463])
        return
    end

    -- 打开角色的货品名片
    self:requestItemInfo(self.selectItem.info.goods_id)
end

function TradingSpotSharePlanDlg:onBuyButton(sender, eventType)
    local function notOpenCallCb()
        self:onCloseButton()
    end

    if not TradingSpotMgr:checkCanOepnTradingSpot(notOpenCallCb) then return end

    if not self.goodsInfo then return end

    if self.goodsInfo.gid == Me:queryBasic("gid") then
        gf:ShowSmallTips(CHS[7190494])
        return
    end

    if self:checkOverTimeTrading() then
        gf:ShowSmallTips(CHS[7190499])
        return
    end

    local goodsTable = {}
    for i = 1, self.goodsInfo.count do
        table.insert(goodsTable, string.format("%d=%d", self.goodsInfo.list[i].goods_id, self.goodsInfo.list[i].volume))
    end

    local allPrice = TradingSpotMgr:getAllGoodsPrice(self.goodsInfo.list)
    local wasteMoney = TradingSpotMgr:getAllGoodsPoundage(self.goodsInfo.list)
    local totalPrice = allPrice + wasteMoney

    if totalPrice > Const.MAX_MONEY_IN_BAG then
        gf:ShowSmallTips(CHS[7120176])
        return
    end

    local buyPlan = table.concat(goodsTable, ",")

    TradingSpotMgr:requestBuyGoodsByPlan(self.goodsInfo.trading_no, buyPlan, totalPrice,
        self.goodsInfo.gid, self.goodsInfo.char_name)
end

function TradingSpotSharePlanDlg:MSG_CONFIRM(data)
    if data.tips == "trading_spot_bid_one_plan" then
        DlgMgr:sendMsg("TradingSpotShareBuyPlanDlg", "setData", self.goodsInfo)
    end
end

-- 成功买入商品，数据发送变化，关闭本界面，打开货站主界面，选中我的持有菜单
function TradingSpotSharePlanDlg:MSG_TRADING_SPOT_DATA()
    if self.isWaitingMainSpotData then
        -- 正在等待主界面数据的情况下，主界面数据回来，不关闭界面
        self.isWaitingMainSpotData = nil
        return
    end

    self:onCloseButton()
    TradingSpotMgr:openTradingSpotByType(2)
end

return TradingSpotSharePlanDlg
