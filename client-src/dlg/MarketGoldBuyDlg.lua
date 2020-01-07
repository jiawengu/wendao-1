-- MarketGoldBuyDlg.lua
-- Created by zhengjh Apr/20/2016
-- 珍宝逛摊
local MarketBuyDlg = require('dlg/MarketBuyDlg')
local MarketGoldBuyDlg = Singleton("MarketGoldBuyDlg", MarketBuyDlg)
local RewardContainer = require("ctrl/RewardContainer")

function MarketGoldBuyDlg:getCfgFileName()
    return ResMgr:getDlgCfg("MarketBuyDlg")
end

function MarketGoldBuyDlg:cleanClassData()
    MarketMgr:MSG_GOLD_STALL_GOODS_LIST({})
end

function MarketGoldBuyDlg:setTradeTypeUI()
    -- 设置商品单元格为货币为金元宝
    self:setCtrlVisible("GoldImage", true, self.itemCellCtrl)
    self:setCtrlVisible("CoinImage", false, self.itemCellCtrl)

    -- 设置玩家身上的金元宝
    local moneyPanel = self:getControl("MoneyPanel")
    self:setCtrlVisible("GoldImage", true, moneyPanel)
    self:setCtrlVisible("MoneyImage", false, moneyPanel)

    -- 珍宝标题
    self:setLabelText("TitleLabel_1", CHS[6000243])
    self:setLabelText("TitleLabel_2", CHS[6000243])

    self:setCtrlVisible("ViewButton", true)
    self:bindListener("ViewButton", self.onViewButton)


    -- 通过名片打开时，可能没有设置
    MarketMgr:setTradeType(MarketMgr.TradeType.goldType)
end

function MarketGoldBuyDlg:setSafeLockInfo()
    self:setCtrlVisible("UnlockButton", false)
    self:setCtrlVisible("BuyButton", false)
end

function MarketGoldBuyDlg:setLockBtn()
    self:setCtrlVisible("UnlockButton", SafeLockMgr:isNeedUnLock())

    self:setCtrlVisible("BuyButton", false)
    self:setCtrlVisible("PublicInfoPanel", false)
end

-- 设置所有hook消息
function MarketGoldBuyDlg:setAllHookMsgs()
    self:hookMsg("MSG_GOLD_STALL_GOODS_LIST")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_GOLD_STALL_UPDATE_GOODS_INFO")
    self:hookMsg("MSG_GOLD_STALL_GOODS_STATE")
    self:hookMsg("MSG_GOLD_STALL_CASH_GOODS_LIST")
    self:hookMsg("MSG_SAFE_LOCK_INFO")
end

function MarketGoldBuyDlg:defaultCol()
    local gid = string.match(FriendMgr.requestInfo.gid, CHS[4010212])
    if FriendMgr.requestInfo and gid then
        self:onCollectionButton()
    end
end

-- 设置金钱
function MarketGoldBuyDlg:setCashView()
    local goldText = gf:getArtFontMoneyDesc(Me:queryBasicInt('gold_coin'))
    self:setNumImgForPanel("MoneyValuePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.MID, 23)
end

function MarketGoldBuyDlg:onMoneyPanel()
    DlgMgr:openDlg("OnlineRechargeDlg")
end

-- 获取一级菜单的列表
function MarketGoldBuyDlg:getFirstItemList()
    return MarketMgr:getTreasureList()
end

function MarketGoldBuyDlg:openSearchDlg()
    DlgMgr:openDlg("MarketGoldSearchDlg")
end

-- 某一类物品逛摊数据
function MarketGoldBuyDlg:MSG_GOLD_STALL_GOODS_LIST(data)
	self:MSG_STALL_ITEM_LIST(data)
end

-- 刷新某个物品状态
function MarketGoldBuyDlg:MSG_GOLD_STALL_UPDATE_GOODS_INFO()
    self:MSG_STALL_UPDATE_GOODS_INFO()
end

function MarketGoldBuyDlg:tradeType()
    return MarketMgr.TradeType.goldType
end

-- 收藏某个，返回的数据
function MarketGoldBuyDlg:MSG_GOLD_STALL_GOODS_STATE(data)
    self:MSG_MARKET_CHECK_RESULT(data)
end

function MarketGoldBuyDlg:onViewButton(sender, eventType)
    if not self.selectItemData then
        gf:ShowSmallTips(CHS[4010213])
        return
    end

    MarketMgr:requireMarketGoodCard(self.selectItemData.id.."|"..self.selectItemData.endTime,
        MARKET_CARD_TYPE.VIEW_OTHERS, self.selectItemData, nil, true, self:tradeType())
end

-- 通知金钱商品列表
function MarketGoldBuyDlg:MSG_GOLD_STALL_CASH_GOODS_LIST(data)
    if self.needTipForCashList then
        gf:ShowSmallTips(CHS[5420259])
        self.needTipForCashList = false
    end

    self:setMoneyListPanel()
end

function MarketGoldBuyDlg:setMoneyListPanel()
    local myCash = Me:queryBasicInt("cash")
    local cashText, fontColor = gf:getArtFontMoneyDesc(myCash)
    self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 21, "MoneyPanel2")

    local moneyPanel = self:getControl("SellMoneyPanel")
    if not MarketMgr:getIsCanSellCash() then
        self:setCtrlVisible("NoticePanel2", true, moneyPanel)
        self:setCtrlVisible("NoticePanel", false, moneyPanel)
        self:setCtrlVisible("MoneyScrollView", false, moneyPanel)
        return
    else
        self:setCtrlVisible("NoticePanel2", false, moneyPanel)
        self:setCtrlVisible("MoneyScrollView", true, moneyPanel)
    end

    self:swichCancelAndCollectBtn(true)
    self.isFromSearch = false
    local itemList = MarketMgr:getCurSellCashList()
    self.curPage = 0
    self.totalPage = 0

    local scrollview = self:getControl("MoneyScrollView")
    scrollview:removeAllChildren()

    if not itemList or #itemList == 0 then
        self:setCtrlVisible("NoticePanel", true, moneyPanel)
        self:refreshPageInfo()
        return
    else
        self:setCtrlVisible("NoticePanel", false, moneyPanel)
    end

    self:setCtrlVisible("MarketCheaterPanel", false, moneyPanel)

    self:initListPanel(itemList, self.moneyCellCtrl, self.setMoneyItemData, scrollview, true)

    self:refreshPageInfo()
end

function MarketGoldBuyDlg:setMoneyItemData(cell, data)
    local imgPath
    local isPet = false

    self:setImagePlist("IconImage", ResMgr.ui.big_cash, cell)
    self:setItemImageSize("IconImage", cell)

    -- 名字
    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(data.name))
    self:setNumImgForPanel("MoneyNumPanel", fontColor, cashText, false, LOCATE_POSITION.LEFT_BOTTOM, 21, cell)

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if not data.price then
                gf:ShowSmallTips(CHS[5420257])
            else
                self.selectItemData = data
                self.selectItemCell = cell
                self:addItemSelcelImage(cell, self.moneySelectImg)
            end
        end
    end

    cell:addTouchEventListener(listener)

    local iconPanel = self:getControl("IconPanel", nil, cell)
    local function showFloatPanel(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if not data.price then
                gf:ShowSmallTips(CHS[5420257])
            else
                self.selectItemData = data
                self.selectItemCell = cell
                self:addItemSelcelImage(cell, self.moneySelectImg)
            end

            sender.reward = {CHS[3002143], CHS[3002143]}
            RewardContainer:imagePanelTouch(sender, eventType)
        end
    end

    iconPanel:addTouchEventListener(showFloatPanel)

    if not data.price then
        -- 无此订单，置灰
        local img = self.moneySelectImg:clone()
        cell:addChild(img)
        gf:grayImageView(img)
        gf:grayImageView(self:getControl("IconImage", nil, cell))
        gf:grayImageView(self:getControl("GridImage", nil, cell))

        self:setCtrlVisible("CoinLabel", false, cell)
        self:setCtrlVisible("CoinLabel2", false, cell)
        self:setCtrlVisible("GoldImage", false, cell)
        self:setCtrlVisible("NoneLabel", true, cell)

        local str, color = gf:getMoneyDesc(0, true)
        self:setLabelText("AverageCoinLabel", str, cell, color)
        self:setLabelText("AverageCoinLabel2", str, cell)
        return
    else
        self:setCtrlVisible("CoinLabel", true, cell)
        self:setCtrlVisible("CoinLabel2", true, cell)
        self:setCtrlVisible("GoldImage", true, cell)
        self:setCtrlVisible("NoneLabel", false, cell)
    end

    -- 单价
    local unitPrice = math.floor(tonumber(data.name) / data.price)
    local str, color = gf:getMoneyDesc(unitPrice, true)
    self:setLabelText("AverageCoinLabel", str, cell, color)
    self:setLabelText("AverageCoinLabel2", str, cell)

    -- 总价
    local str, color = gf:getMoneyDesc(data.price, true)
    self:setLabelText("CoinLabel", str, cell, color)
    self:setLabelText("CoinLabel2", str, cell)

    if data.status == 4 then
        self:setCtrlVisible("TipImage", true, cell)
    end

    -- 收藏标签
    if MarketMgr:isCollectedInAll(data.id, self:tradeType()) then
        self:setCtrlVisible("CollectionImage", true, cell)
    else
        self:setCtrlVisible("CollectionImage", false, cell)
    end

    -- 选中刷新前选中
    if self.selectItemData and self.selectItemData.name == data.name then
        listener(cell, ccui.TouchEventType.ended)
    end
end

-- 通知金钱商品列表
function MarketGoldBuyDlg:MSG_SAFE_LOCK_INFO(data)
    -- 如果是金钱，珍宝要显示解锁、或者购买
    self:setCtrlVisible("UnlockButton", SafeLockMgr:isNeedUnLock())
    if SafeLockMgr:isNeedUnLock() then -- 需要解锁
    else
        self:setCtrlVisible("BuyButton", self.firstClass == CHS[3002143])
        self:setCtrlVisible("ViewButton", self.firstClass ~= CHS[3002143])
    end
end


return MarketGoldBuyDlg
