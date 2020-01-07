-- TradingSpotItemInfoDlg.lua
-- Created by lixh Des/26/2018
-- 商贾货站货品详情界面

local TradingSpotItemInfoBasicDlg = require('dlg/TradingSpotItemInfoBasicDlg')
local TradingSpotItemInfoDlg = Singleton("TradingSpotItemInfoDlg", TradingSpotItemInfoBasicDlg)

-- 购买数量限制
local BUY_NUM_MAX = 999
local BUY_NUM_MIN = 1

-- 货品总量限制
local ITEM_NUM_MAX = 2000

-- 购买总额上限
local BUY_PRICE_MAX = 2000000000

-- 界面数据类型
local DLG_DATA_TYPE = TradingSpotMgr:getDetailListTypeCfg()

-- 交易类型
local TRADING_STATUS = TradingSpotMgr:getTradingStatusCfg()

function TradingSpotItemInfoDlg:init(data)
    self.goodsInfo = data

    TradingSpotItemInfoBasicDlg.init(self, self.root)

    self.dlgType = nil
    self.radioGroup:setItems(self, { "RecentFloatCheckBox", "HistoryFloatCheckBox", "ProfitRecordCheckBox" }, self.onTypeCheckBox)
    self.radioGroup:selectRadio(DLG_DATA_TYPE.LINE)

    self:bindListener("CollectionButton", self.onCollectionButton)
    self:bindListener("CollectionImage1", self.onCollectionButton)
    self:bindListener("CollectionImage2", self.onCollectionButton)

    self:bindListener("BuyButton", self.onBuyButton)
    self:bindPressForIntervalCallback("AddButton", 0.2, self.onAddButton, "times")
    self:bindPressForIntervalCallback("MinusButton", 0.2, self.onMinusButton, "times")

    self.buyNum = 1

    self.rightPanel = self:getControl("RightPanel")

    self:bindListener("MyMoneyPanel", self.onBuyCashPanel, self.rightPanel)

    self:setRightPanel()

    self:refreshCashPanel()

    self:refreshBuyButton()

    self:hookMsg("MSG_UPDATE")
end

function TradingSpotItemInfoDlg:setGoodsData(data)
    self.goodsInfo = data
    self:refreshGoodsInfo()
end

function TradingSpotItemInfoDlg:refreshGoodsInfo()
    self.buyNum = 1
    self.goodsInfo = TradingSpotMgr:getGoodsInfoById(self.goodsInfo.goods_id)
    self:setRightPanel()
end

function TradingSpotItemInfoDlg:setRightPanel()
    local root = self.rightPanel
    local itemName, itemInfo = TradingSpotMgr:getItemInfo(self.goodsInfo.goods_id)
    if not itemName or not itemInfo then return end

    -- 图标
    self:setImage("ItemImage", ResMgr:getItemIconPath(itemInfo.icon), root)

    -- 名称
    self:setLabelText("NameLabel", itemName, root)

    -- 刷新收藏情况
    self:refreshCollectInfo()

    -- 主营人
    self:setLabelText("OwnerLabel", string.format(CHS[7190469], TradingSpotMgr:getGoodsOwner(self.goodsInfo.goods_id)), root)

    -- 描述
    self:setLabelText("InfoLabel", itemInfo.descript, root)

    -- 单价
    if self.goodsInfo.status == TRADING_STATUS.HALT then
        self:setLabelText("PriceNumLabel1", CHS[7190454], root, COLOR3.TEXT_DEFAULT)
        self:setLabelText("PriceNumLabel2", CHS[7190454], root)
    else
        local priceDes, priceColor = gf:getMoneyDesc(math.floor(self.goodsInfo.price), true)
        self:setLabelText("PriceNumLabel1", priceDes, root, priceColor)
        self:setLabelText("PriceNumLabel2", priceDes, root)

        self.buyPrice = self.goodsInfo.price
    end

    local volumeDes, _ = gf:getMoneyDesc(math.floor(self.goodsInfo.volume), true)
    self:setLabelText("ItemNumLabel1", volumeDes, root)
    self:setLabelText("ItemNumLabel2", volumeDes, root)

    -- 持有总额
    local allPriceDes, allPriceColor = gf:getMoneyDesc(math.floor(self.goodsInfo.all_price), true)
    self:setLabelText("AllPriceLabel1", allPriceDes, root, allPriceColor)
    self:setLabelText("AllPriceLabel2", allPriceDes, root)

    -- 买入数量
    self:refreshBuyNum()
    local numPanel = self:getControl("NumPanel", nil, root)
    self:bindNumInput("NumPanel", root, self.numberLimitCallBack, "NumPanel")
end

-- 收藏按钮/收藏图标
function TradingSpotItemInfoDlg:refreshCollectInfo()
    if not self.goodsInfo then
        return
    end

    local collectionBtn = self:getControl("CollectionButton")
    local goodsInfo = TradingSpotMgr:getGoodsInfoById(self.goodsInfo.goods_id)
    self:setCtrlVisible("CollectionImage1", false)
    self:setCtrlVisible("CollectionImage2", false)
    if goodsInfo.is_collected then
        -- 显示取消收藏
        self:setLabelText("Label_1", CHS[7190457], collectionBtn)
        self:setLabelText("Label_2", CHS[7190457], collectionBtn)
        self:setCtrlVisible("CollectionImage2", true)
    else
        -- 显示收藏
        self:setLabelText("Label_1", CHS[7190456], collectionBtn)
        self:setLabelText("Label_2", CHS[7190456], collectionBtn)
        self:setCtrlVisible("CollectionImage1", true)
    end
end

-- 数字键盘，输入回调
function TradingSpotItemInfoDlg:insertNumber(num, key)
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if num < BUY_NUM_MIN then
        -- 数量下限
        gf:ShowSmallTips(CHS[7190470])
        self.buyNum = BUY_NUM_MIN
        self:refreshBuyNum()
        return
    end

    local numMax = 9999
    local volumeMax = 9999
    local priceMax = 9999

    if num > BUY_NUM_MAX then
        -- 数量上限
        numMax = BUY_NUM_MAX
    end

    if num + self.goodsInfo.volume > ITEM_NUM_MAX then
        -- 持有数量上限
        volumeMax = math.min(ITEM_NUM_MAX - self.goodsInfo.volume, setNum or BUY_NUM_MAX)
    end

    local allPrice = num * self.goodsInfo.price
    allPrice = allPrice + math.floor(allPrice / 100) * TradingSpotMgr:getPoundageCfg()

    local meCash = Me:queryBasicInt("cash")
    if allPrice >= meCash then
        -- 购买总价上限
        local toBuyNum = math.floor(meCash / (self.goodsInfo.price + math.floor(self.goodsInfo.price / 100) * TradingSpotMgr:getPoundageCfg()))
        priceMax = math.min(toBuyNum, setNum or BUY_NUM_MAX)
    end

    local setNum = math.min(numMax, volumeMax, priceMax)
    local setNumTips
    if setNum == numMax then
        setNum = numMax
        setNumTips = CHS[7190471]
    elseif setNum == volumeMax then
        setNum = volumeMax
        setNumTips = string.format(CHS[7190473], ITEM_NUM_MAX)
    elseif setNum == priceMax then
        if setNum > 0 then
            setNum = priceMax
            setNumTips = CHS[7120174]
        else
            setNum = 1
            setNumTips = CHS[7120175]
        end
    end

    if setNum ~= 9999  then
        gf:ShowSmallTips(setNumTips)
        self.buyNum = setNum
        self:refreshBuyNum()
        if dlg then dlg:setInputValue(self.buyNum) end
        return
    end

    self.buyNum = num
    self:refreshBuyNum()
end

-- 刷新购买数量
function TradingSpotItemInfoDlg:refreshBuyNum()
    local root = self.rightPanel
    local numPanel = self:getControl("NumPanel", nil, root)
    self:setNumImgForPanel("MoneyValuePanel", ART_FONT_COLOR.NORMAL_TEXT, self.buyNum, false, LOCATE_POSITION.MID, 23, numPanel)

    -- 总价格
    local allPrice = math.floor(self.buyNum * self.goodsInfo.price)

    -- 手续费
    local poundage = math.floor(allPrice / 100) * TradingSpotMgr:getPoundageCfg()

    -- 总花费
    local allCost = allPrice + poundage
    local allCostDes, allCostColor = gf:getArtFontMoneyDesc(tonumber(allCost))
    local allMoneyPanel = self:getControl("AllMoneyPanel", nil, root)
    self:setNumImgForPanel("MoneyValuePanel", allCostColor, allCostDes, false, LOCATE_POSITION.MID, 23, allMoneyPanel)
end

-- 刷新金钱
function TradingSpotItemInfoDlg:refreshCashPanel()
    local moneyPanel = self:getControl("MyMoneyPanel", nil, self.rightPanel)
    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(Me:queryBasicInt("cash")))
    self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, moneyPanel)
end

-- 刷新购买按钮状态
function TradingSpotItemInfoDlg:refreshBuyButton()
    local buyButton = self:getControl("BuyButton")
    if TradingSpotMgr:isInRestTime() then
        self:setLabelText("Label_1", CHS[7190474], buyButton)
        self:setLabelText("Label_2", CHS[7190474], buyButton)
        gf:grayCtrlAndTouchEnabled(buyButton, false)
    else
        self:setLabelText("Label_1", CHS[7190475], buyButton)
        self:setLabelText("Label_2", CHS[7190475], buyButton)
        gf:grayCtrlAndTouchEnabled(buyButton, true)
    end
end

-- 获取当前列表下一个商品的goods_id
function TradingSpotItemInfoDlg:getNextGoodsId(goodsId, isLeft)

    if DlgMgr:getDlgByName("TradingSpotInfoDlg") then
        return DlgMgr:sendMsg("TradingSpotInfoDlg", "getNextGoodsId", goodsId, isLeft)
    end

    return DlgMgr:sendMsg("TradingSpotItemDlg", "getNextGoodsId", goodsId, isLeft)
end

function TradingSpotItemInfoDlg:onBuyCashPanel(sender, eventType)
    OnlineMallMgr:openOnlineMall("OnlineMallExchangeMoneyDlg")
end

-- 收藏/取消收藏
function TradingSpotItemInfoDlg:onCollectionButton(sender, eventType)
    if not self.goodsInfo then
        gf:ShowSmallTips(CHS[7190458])
        return
    end

    local goodsInfo = TradingSpotMgr:getGoodsInfoById(self.goodsInfo.goods_id)
    if goodsInfo then
        TradingSpotMgr:requestCollectGoods(self.goodsInfo.goods_id, not goodsInfo.is_collected)
    end
end

function TradingSpotItemInfoDlg:onAddButton(sender, eventType)
    if self.buyNum + 1 > BUY_NUM_MAX then
        -- 数量上限
        gf:ShowSmallTips(CHS[7190471])
        return
    end

    if self.buyNum + 1 + self.goodsInfo.volume > ITEM_NUM_MAX then
        -- 持有数量上限
        gf:ShowSmallTips(string.format(CHS[7190473], ITEM_NUM_MAX))
        return
    end

    local allPrice = (self.buyNum + 1) * self.goodsInfo.price
    allPrice = allPrice + math.floor(allPrice / 100) * TradingSpotMgr:getPoundageCfg()
    local meCash = Me:queryBasicInt("cash")
    if allPrice >= meCash then
        -- 购买总价上限
        if meCash < (self.goodsInfo.price + math.floor(self.goodsInfo.price / 100) * TradingSpotMgr:getPoundageCfg()) then
            gf:ShowSmallTips(CHS[7190472])
        else
            gf:ShowSmallTips(CHS[7120174])
        end

        return
    end

    self.buyNum = self.buyNum + 1
    self:refreshBuyNum()
end

function TradingSpotItemInfoDlg:onMinusButton(sender, eventType)
    if self.buyNum - 1 < BUY_NUM_MIN then
        gf:ShowSmallTips(CHS[7190470])
        return
    end

    self.buyNum = self.buyNum - 1
    self:refreshBuyNum()
end

function TradingSpotItemInfoDlg:onBuyButton(sender, eventType)
    if not TradingSpotMgr:isTradingSpotEnable() then
        gf:ShowSmallTips(CHS[7190461])
        return
    end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[7190462])
        return
    end

    if not self.goodsInfo then return end
    if self.goodsInfo.status == TRADING_STATUS.HALT then
        gf:ShowSmallTips(CHS[7190496])
        return
    end

    if self:checkSafeLockRelease("onBuyButton") then
        return
    end

    -- 请求买入货品
    TradingSpotMgr:requestBuyGoods(self.goodsInfo.goods_id, self.buyNum, self.buyPrice or 0)
end

function TradingSpotItemInfoDlg:cleanup()
    self.dlgType = nil
    self.buyNum = 1
    self.buyPrice = nil
    self.goodsInfo = nil
    self.startNum = nil
    self.goodsListInfo = nil

    if self.pen then
        self.pen:clear()
        self.pen:removeFromParent()
        self.pen = nil
    end
end

function TradingSpotItemInfoDlg:MSG_UPDATE(data)
    if data and data.cash then
        self:refreshCashPanel()
    end
end

return TradingSpotItemInfoDlg
