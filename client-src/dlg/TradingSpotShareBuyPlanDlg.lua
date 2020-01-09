-- TradingSpotShareBuyPlanDlg.lua
-- Created by lixh Des/26/2018
-- 商贾货站货品一键跟买确认界面

local TradingSpotShareBuyPlanDlg = Singleton("TradingSpotShareBuyPlanDlg", Dialog)

function TradingSpotShareBuyPlanDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("SeeButton", self.onCloseButton)
    self:bindListener("MyMoneyPanel", self.onBuyCashPanel, "PricePanel")

    self:hookMsg("MSG_UPDATE")
end

function TradingSpotShareBuyPlanDlg:setData(data)
    self.goodsInfo = data
    local root = self:getControl("PricePanel")

    -- 跟买对象
    local text = string.format(CHS[7190495], self.goodsInfo.char_name)
    self:setColorText(text, "TextPanel", nil, nil, nil, nil, 21)

    -- 商品总价
    local allPrice = TradingSpotMgr:getAllGoodsPrice(self.goodsInfo.list)
    local allItemMoneyPanel = self:getControl("AllItemMoneyPanel", nil, root)
    local allPriceDes, allPriceColor = gf:getArtFontMoneyDesc(math.floor(allPrice))
    self:setNumImgForPanel("MoneyValuePanel", allPriceColor, allPriceDes, false, LOCATE_POSITION.MID, 23, allItemMoneyPanel)

    -- 手续费
    local wasteMoney = TradingSpotMgr:getAllGoodsPoundage(self.goodsInfo.list)

    -- 总花费
    local allMoneyPanel = self:getControl("AllMoneyPanel", nil, root)
    local allMoney = allPrice + wasteMoney
    local allMoneyDes, allMoneyColor = gf:getArtFontMoneyDesc(allMoney)
    self:setNumImgForPanel("MoneyValuePanel", allMoneyColor, allMoneyDes, false, LOCATE_POSITION.MID, 23, allMoneyPanel)
    self.allMoney = allMoney

    self:refreshCashPanel()
end

-- 刷新金钱
function TradingSpotShareBuyPlanDlg:refreshCashPanel()
    local myMoneyPanel = self:getControl("MyMoneyPanel", nil, "PricePanel")
    local myMoneyDes, myMoneyColor = gf:getArtFontMoneyDesc(Me:queryBasicInt("cash"))
    self:setNumImgForPanel("MoneyValuePanel", myMoneyColor, myMoneyDes, false, LOCATE_POSITION.MID, 23, myMoneyPanel)
end

function TradingSpotShareBuyPlanDlg:cleanup()
    self.goodsInfo = nil
    self.allMoney = nil
end

function TradingSpotShareBuyPlanDlg:onBuyCashPanel(sender, eventType)
    OnlineMallMgr:openOnlineMall("OnlineMallExchangeMoneyDlg")
end

function TradingSpotShareBuyPlanDlg:onBuyButton(sender, eventType)
    gf:CmdToServer("CMD_CONFIRM_RESULT", {select = 1})
    DlgMgr:closeDlg(self.name)
end

function TradingSpotShareBuyPlanDlg:onCloseButton(sender, eventType)
    gf:CmdToServer("CMD_CONFIRM_RESULT", {select = 0})
    DlgMgr:closeDlg(self.name)
end

function TradingSpotShareBuyPlanDlg:MSG_UPDATE(data)
    if data and data.cash then
        self:refreshCashPanel()
    end
end

return TradingSpotShareBuyPlanDlg
