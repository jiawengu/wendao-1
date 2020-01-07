-- OnlineMallExchangeMoneyDlg.lua
-- Created by songcw Mar/31/2015
-- 元宝兑换游戏币界面

local OnlineMallExchangeMoneyDlg = Singleton("OnlineMallExchangeMoneyDlg", Dialog)

local EXCHARGE_MONEY_DATA = require(ResMgr:getCfgPath("OnlineMallExchangeMoney.lua"))

function OnlineMallExchangeMoneyDlg:init()

    self:bindListener("MoneyImage", self.onMoneyLimit)
    self:bindListener("MoneyValueLabel", self.onMoneyLimit)

    local label = self:getControl("MoneyValueLabel")
    self:bindTouchEndEventListener(label,self.onMoneyLimit)

    local sliverPanel = self:getControl("SliverCoinPanel")
    self:bindListener("AddSilverButton", self.onSliverAddButton, sliverPanel)

  --  local goldPanel = self:getControl("GoldCoinPanel")
    self:bindListener("GoldCoinPanel", self.onGoldAddButton, goldPanel)

    self:setOwnInfo()
    self:setGoodsList(OnlineMallMgr:getMallCashInfo())
    
    -- 没有商城数据，请求商城信息
    if #OnlineMallMgr:getOnlineMallList() == 0 then
        OnlineMallMgr:openOnlineMall("OnlineMallExchangeMoneyDlg")
    end

    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_ONLINE_MALL_CASH_LIST")

    EventDispatcher:addEventListener("doOpenDlgRequestData", self.onOpenDlgRequestData, self)
end

function OnlineMallExchangeMoneyDlg:cleanup()
    EventDispatcher:removeEventListener("doOpenDlgRequestData", self.onOpenDlgRequestData, self)
end

function OnlineMallExchangeMoneyDlg:onOpenDlgRequestData(sender, eventType)
    -- 请求商城数据
    OnlineMallMgr:openOnlineMall("OnlineMallExchangeMoneyDlg")
end

function OnlineMallExchangeMoneyDlg:onMoneyLimit(sender, eventType)
    local str = gf:getMoneyDesc(2000000000, true)
    gf:ShowSmallTips(string.format(CHS[4000296], str))
end

function OnlineMallExchangeMoneyDlg:setGoodsList(data)
    for i = 1 , 6 do
        local goodsPanel = self:getControl(string.format("GoodsPanel_%d", i))
        if data then
            self:setGoodsInfo(i, goodsPanel, data[i])
        else
            self:setGoodsInfo(i, goodsPanel)
        end
        goodsPanel:setVisible(true)
    end
end

function OnlineMallExchangeMoneyDlg:setGoodsInfo(i, panel, data)
    local goldMoney = EXCHARGE_MONEY_DATA[i].gold
    if data then goldMoney = data.costCoin end

    local goldStr = gf:getArtFontMoneyDesc(goldMoney)
    self:setNumImgForPanel("PriceValuePanel", ART_FONT_COLOR.DEFAULT, goldStr, false, LOCATE_POSITION.LEFT_BOTTOM, 23, panel)
    local cashMoney = EXCHARGE_MONEY_DATA[i].cash
    if data then
        cashMoney = data.toMoney
        self:setCtrlVisible("SoldOutImage", data.sale_quota == 0, panel)
    end
    local cashStr, fontColor = gf:getArtFontMoneyDesc(cashMoney)
    self:setNumImgForPanel("CashValuePanel", fontColor, cashStr, false, LOCATE_POSITION.CENTER, 25, panel)

    local buyButton = self:getControl("BuyButton", nil, panel)
    buyButton:setTag(i)
    self:bindTouchEndEventListener(buyButton, self.onBuyButton)
end

function OnlineMallExchangeMoneyDlg:onBuyButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    local tag = sender:getTag()
    local mallData = OnlineMallMgr:getMallCashInfo()
    if mallData then
        if mallData[tag].sale_quota == 0 then
            gf:ShowSmallTips(CHS[4000379])
            return
        end
    end

    if Me:queryBasicInt('cash') + SilverToCash[tag].cash > 2000000000 then
        gf:ShowSmallTips(CHS[4000338])
        return
    end
    local cashStr = gf:getMoneyDesc(SilverToCash[tag].cash)

    -- 修改为金元宝购买
    if Me:queryBasicInt('gold_coin') < SilverToCash[tag].silver then
        gf:askUserWhetherBuyCoin()
    else
        -- 安全锁判断
        if self:checkSafeLockRelease("onBuyButton", sender) then
            return
        end

        local showMessage = string.format(CHS[4000295], SilverToCash[tag].silver, cashStr)
        gf:confirm(showMessage, function()
            local data = {}
            data["barcode"] = SilverToCash[tag]["barcode"]
            if mallData then data["barcode"] = mallData[tag]["barcode"] end

            data["amount"] = 1
            data["coin_pwd"] = ""
            data["coin_type"] = "gold_coin"
            OnlineMallMgr:buyGoods(data)
        end)
    end
end

function OnlineMallExchangeMoneyDlg:setOwnInfo()
    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 21)
    local silverText = gf:getArtFontMoneyDesc(Me:queryBasicInt('silver_coin'))
    self:setNumImgForPanel("SilverCoinValuePanel", ART_FONT_COLOR.DEFAULT, silverText, false, LOCATE_POSITION.CENTER, 21)
    local goldText = gf:getArtFontMoneyDesc(Me:queryBasicInt('gold_coin'))
    self:setNumImgForPanel("GoldCoinValuePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.CENTER, 21)
end

function OnlineMallExchangeMoneyDlg:MSG_UPDATE()
    -- 更新金钱相关信息
    self:setOwnInfo()
end

function OnlineMallExchangeMoneyDlg:MSG_ONLINE_MALL_CASH_LIST()
    self:setGoodsList(OnlineMallMgr:getMallCashInfo())
end

function OnlineMallExchangeMoneyDlg:onGoldAddButton(sender, eventType)
    local onlineTabDlg = DlgMgr.dlgs["OnlineMallTabDlg"]

    -- 需要延迟一帧，释放按钮
    performWithDelay(sender, function()
        if onlineTabDlg then
            onlineTabDlg.group:setSetlctByName("RechargeCheckBox")
        else
            DlgMgr:openDlg("OnlineRechargeDlg")
            DlgMgr.dlgs["OnlineMallTabDlg"].group:setSetlctByName("RechargeCheckBox")
        end
    end, 0)
end

function OnlineMallExchangeMoneyDlg:onSliverAddButton(sender, eventType)
    InventoryMgr:openItemRescourse(CHS[3003182])
end

return OnlineMallExchangeMoneyDlg
