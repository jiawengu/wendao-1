-- MarketSellBasicDlg.lua
-- Created by zhengjh Aug/20/2015
-- 摆摊基类
local MarketSellBasicDlg = Singleton("MarketSellBasicDlg", Dialog)

local VALUE_FLOAT = 5 -- 摆摊波动费用的百分比
local VALUE_SECTION = 90

MarketSellBasicDlg.VIEW_TYPE = {
    ON_SELL = 1,    -- 正在摆摊
    OVER_SELL = 2,  -- 超过时间
    PRE_SELL = 3,   -- 准备摆摊
    ON_PUBILC = 4,  -- 公示中
}


function MarketSellBasicDlg:initBaisc()
    self:bindListener("SellButton", self.onSellButton)
    self:bindListener("ReSellButton", self.onReSellButton)
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("CancelSellButton", self.onCancelSellButton)
    self:bindListener("ChangePriceButton", self.onChangePriceButton)
    self.inputNum  = 0

    self:hookMsg("MSG_GOLD_STALL_MINE")
    self:hookMsg("MSG_STALL_MINE")
end

function MarketSellBasicDlg:setTradeTypeUI()
    local isTreasureTradeType = MarketMgr:isGoldtype(self:getTradeType())
    local sellPanel = self:getControl("PublicitySellPanel")
    local sellPricePanel = self:getControl("FreePricePanel", nil, sellPanel)
    self:setCtrlVisible("MoneyImage", not isTreasureTradeType, sellPricePanel)
    self:setCtrlVisible("GoldImage", isTreasureTradeType, sellPricePanel)
    local onSellPanel = self:getControl("OnSellPanel")
    sellPricePanel = self:getControl("FreePricePanel", nil, onSellPanel)
    self:setCtrlVisible("GoldImage", isTreasureTradeType, sellPricePanel)
    self:setCtrlVisible("MoneyImage", not isTreasureTradeType, sellPricePanel)

    -- 摆摊标题可以为“集市摆摊”或者“珍宝摆摊”
    self:setCtrlVisible("MarketTitlePanel", not isTreasureTradeType)
    self:setCtrlVisible("TreasureTitlePanel", isTreasureTradeType)
end

function MarketSellBasicDlg:exchangeBasicView(type)

    if self.VIEW_TYPE.ON_SELL == type then
        self:setCtrlVisible("InfoPanel", true)
        self:setCtrlVisible("OnSellPanel", true)
        if self.isPet then
            if MarketMgr:isPublicityItem(self.data:queryBasic("raw_name")) then
                self:setCtrlVisible("ChangePriceButton", true)
            end
        else
            if MarketMgr:isPublicityItem(self.data.name) and self.data.unidentified ~= 1 then                
                self:setCtrlVisible("ChangePriceButton", true)
            else
                self:setCtrlVisible("ChangePriceButton", false)
            end
        end
        self:setCtrlVisible("CancelSellButton", true)
        self:setCtrlVisible("CancelButton", true)
        local cancelBtn = self:getControl("CancelSellButton")
        local sellBtn = self:getControl("SellButton")
        cancelBtn:setPosition(sellBtn:getPosition())
  
    elseif self.VIEW_TYPE.OVER_SELL == type then
        self:setCtrlVisible("PublicitySellPanel", true)
        --self:setCtrlVisible("InfoPanel", true)
        self:setCtrlVisible("TimeoutPanel", true)
        --self:setLabelText("StateLabel", CHS[3003068])
        self:setCtrlVisible("CancelSellButton", true)
        self:setCtrlVisible("ReSellButton", true)
        self:bindSellNumInput()
        -- 默认文字
        local pubicPanel = self:getControl("PublicitySellPanel")
        local moneyPanel = self:getControl('FreePricePanel', nil, pubicPanel)
        self:setCtrlVisible("Label", false, moneyPanel)
    elseif self.VIEW_TYPE.PRE_SELL == type then
        self:setCtrlVisible("PublicitySellPanel", true)
        self:bindSellNumInput()
        self:setCtrlVisible("SellButton", true)
        self:setCtrlVisible("CancelButton", true)
   elseif self.VIEW_TYPE.ON_PUBILC == type then
        self:setCtrlVisible("PublicityInfoPanel", true)
        self:setCtrlVisible("OnSellPanel", true)

        if self.isPet then
            if MarketMgr:isPublicityItem(self.data:queryBasic("raw_name")) then
                self:setCtrlVisible("ChangePriceButton", true)
            end
        elseif self.data.stall_item_type == TRANSFER_ITEM_TYPE.CASH then
            self:setCtrlVisible("CancelButton", true)
        else            
            if MarketMgr:isPublicityItem(self.data.name) and self.data.unidentified ~= 1 then                
                self:setCtrlVisible("ChangePriceButton", true)
            else
                self:setCtrlVisible("ChangePriceButton", false)
            end
        end

        --[[
        if self:getTradeType() == MarketMgr.TradeType.goldType then
            self:setCtrlVisible("ChangePriceButton", true)
        else
            self:setCtrlVisible("CancelButton", true)
        end
        --]]

        self:setCtrlVisible("CancelSellButton", true)
        local cancelBtn = self:getControl("CancelSellButton")
        local sellBtn = self:getControl("SellButton")
        cancelBtn:setPosition(sellBtn:getPosition())
   end
end

-- 设置数字键盘输入
function MarketSellBasicDlg:bindSellNumInput()
    local pubicPanel = self:getControl("PublicitySellPanel")
    local moneyPanel = self:getControl('FreePricePanel', nil, pubicPanel)
    local function openNumIuputDlg()
        local rect = self:getBoundingBoxInWorldSpace(moneyPanel)
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setObj(self)
        dlg.root:setPosition(rect.x + rect.width /2 , rect.y  + rect.height +  dlg.root:getContentSize().height /2 - 10)
        self:setCtrlVisible("Label", false, moneyPanel)
    end
    self:bindListener("MoneyValuePanel", openNumIuputDlg, pubicPanel)
end

-- 初值化公示类摆摊信息
function MarketSellBasicDlg:initPublicInfo(data, type, isPet)

    self.data = data
    self.isPet = isPet
    self:exchangeBasicView(type)
    if type == self.VIEW_TYPE.PRE_SELL  then
        -- 初值化公示信息
        local pubicPanel = self:getControl("PublicitySellPanel")
        local moneyPanel = self:getControl('FreePricePanel', nil, pubicPanel)
        local boothPanel = self:getControl("BoothPricePanel", nil, pubicPanel)
        local cashText,fonColor = gf:getArtFontMoneyDesc(self:getBoothCost(1))
        self:setNumImgForPanel("MoneyValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, boothPanel)

    elseif type == self.VIEW_TYPE.ON_SELL  or self.VIEW_TYPE.ON_PUBILC == type  then
        local pubicPanel = self:getControl("OnSellPanel")
        local moneyPanel = self:getControl('FreePricePanel', nil, pubicPanel)
        local item = MarketMgr:getSelectGoodInfo()
        local cashText,fonColor = gf:getArtFontMoneyDesc(item.price or 1000)
        self:setNumImgForPanel("MoneyValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, moneyPanel)
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
        end
    elseif self.VIEW_TYPE.OVER_SELL == type then
        local item = MarketMgr:getSelectGoodInfo()
        self.inputNum = item.price or 1000
        self:refreshPublicCash(self.inputNum )
    end

end


-- 数字键盘删除数字
function MarketSellBasicDlg:deleteNumber()
    local pubicPanel = self:getControl("PublicitySellPanel")
    local moneyPanel = self:getControl('FreePricePanel', nil, pubicPanel)
    self.inputNum = math.floor(self.inputNum / 10)
    self:refreshPublicCash(self.inputNum )
end

-- 数字键盘清空
function MarketSellBasicDlg:deleteAllNumber(key)
    local pubicPanel = self:getControl("PublicitySellPanel")
    local moneyPanel = self:getControl('FreePricePanel', nil, pubicPanel)
    self.inputNum = 0
    self:refreshPublicCash(self.inputNum )
end

-- 数字键盘插入数字
function MarketSellBasicDlg:insertNumber(num)
    if num == "00" then
        self.inputNum = self.inputNum * 100
    elseif num == "0000" then
        self.inputNum = self.inputNum * 10000
    else
        self.inputNum = self.inputNum * 10 + num
    end

    if self.inputNum >= 2000000000 then
        self.inputNum = 2000000000
        gf:ShowSmallTips(CHS[3003069])
    end
    self:refreshPublicCash(self.inputNum )
end

-- 刷新公示的信息
function MarketSellBasicDlg:refreshPublicCash(cash)
    local pubicPanel = self:getControl("PublicitySellPanel")
    local moneyPanel = self:getControl('FreePricePanel', nil, pubicPanel)
    local cashText,fonColor = gf:getArtFontMoneyDesc(cash)
    self:setNumImgForPanel("MoneyValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, moneyPanel)

    local boothPanel = self:getControl("BoothPricePanel", nil, pubicPanel)
    cashText,fonColor = gf:getArtFontMoneyDesc(self:getBoothCost(cash))
    self:setNumImgForPanel("MoneyValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, boothPanel)
end

-- 获取摊位费
function MarketSellBasicDlg:getBoothCost(sellPrice, isUnpublic)
    return MarketMgr:getBoothCost(sellPrice, isUnpublic, self:getTradeType())
end

function MarketSellBasicDlg:onReSellButton(sender, eventType)
    self:sell(self.inputNum, true, true)
end

function MarketSellBasicDlg:onChangePriceButton(sender, eventType)
    local info = MarketMgr:getSelectGoodInfo()

  --  if info.status ~= MARKET_STATUS.STALL_GS_SHOWING or self:getTradeType() ~= MarketMgr.TradeType.goldType then return end -- 正常情况不会

    if info.status == MARKET_STATUS.STALL_GS_SHOWING and info.endTime - gf:getServerTime() < 3600 then
        gf:ShowSmallTips(CHS[4300205])
        return
    end

    if info.cg_price_count <= 0 then
        gf:ShowSmallTips(CHS[4300206])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onChangePriceButton") then
        return
    end

    local dlg = DlgMgr:openDlg("MarketChangePriceDlg")
    dlg:setTradeType(self:getTradeType())
end

function MarketSellBasicDlg:onCancelButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
end

function MarketSellBasicDlg:onCancelSellButton(sender, eventType)
    if not self.isPet then
        if self.data.item_type == ITEM_TYPE.CHANGE_LOOK_CARD then
            if StoreMgr:getChangeCardsAmount() == StoreMgr:getCardSize() and not InventoryMgr:getFirstEmptyPos() then
                gf:ShowSmallTips(CHS[4200012])
                return
            end
        else
            if not InventoryMgr:getFirstEmptyPos() then
                gf:ShowSmallTips(CHS[3003071])
                return
            end
        end

    else
        if PetMgr:getFreePetCapcity() == 0 then
            gf:ShowSmallTips(CHS[3003072])
            return
        end
    end

    local item = MarketMgr:getSelectGoodInfo()
    
    -- 如果为公示商品      或者      寄售商品（需要公示的） 要给予确认框
    if item.status == 1 or (item.status == 2 and MarketMgr:isPublicityItem(item)) then
        -- 1为公示2为寄售，
        local tradeType = self:getTradeType()
        gf:confirm(CHS[3003073], function()
            MarketMgr:stopSell(self.goodId, tradeType)
        end, nil, nil, nil, nil, true)
    else
        MarketMgr:stopSell(self.goodId, self:getTradeType())
    end
    DlgMgr:closeDlg(self.name)
end

function MarketSellBasicDlg:onSellButton()
    if not DistMgr:checkCrossDist() then return end

    self:sell(self.inputNum, true)
end

function MarketSellBasicDlg:sell(price, isPublic, isReStall)
    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    if not isReStall then
		-- 非重新寄售
        -- 任务 WDSY-27647 中，点击摆摊的时候，重新判断条件
        if self.isPet then        
            if not PetMgr:getPetById(tonumber(self.data:queryBasic("id"))) then
                gf:ShowSmallTips(CHS[6200054])
                DlgMgr:closeDlg(self.name)
                return
            end
        
            if not MarketMgr:checkPetSellCondition(PetMgr:getPetById(self.data:queryBasicInt("id")), self:getTradeType()) then return end
        else 
            local item = InventoryMgr:getItemByPos(self.data.pos) or StoreMgr:getCardByPos(self.data.pos)
            if not item then
                gf:ShowSmallTips(CHS[6200054])
                DlgMgr:closeDlg(self.name)
                return
            end
        
            if not MarketMgr:checkItemSellCondition(item, self:getTradeType()) then return end
        end
    end

    if self.inputNum == 0 and isPublic then
        gf:ShowSmallTips(CHS[3003074])
        return
    end

    local sellNum = MarketMgr:getSellPosCount(self:getTradeType())
    local allNum = MarketMgr:getMySellNum(self:getTradeType())

    if not sellNum then
        gf:ShowSmallTips("333"..CHS[3003075])
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
        if not self.isPet then
            if not InventoryMgr:getItemByPos(data.pos) and not StoreMgr:getCardByPos(data.pos)then
                gf:ShowSmallTips(CHS[6200054])
                DlgMgr:closeDlg(self.name)
                return
            end

            MarketMgr:startSell(data.pos, price, sellPos, 1, self:getTradeType(), self.inputCount or 1)
        else
            if not PetMgr:getPetById(tonumber(data:queryBasic("id"))) then
                gf:ShowSmallTips(CHS[6200054])
                DlgMgr:closeDlg(self.name)
                return
            end

            MarketMgr:startSell(data:queryBasic("id"), price, sellPos, 2, self:getTradeType(), 1)
        end
     end

    DlgMgr:closeDlg(self.name)
    return true
end

function MarketSellBasicDlg:setTradeType(tradeType)
    self.tradeType = tradeType
    self:setTradeTypeUI()
end

function MarketSellBasicDlg:getTradeType()
    return self.tradeType or MarketMgr.TradeType.marketType
end

function MarketSellBasicDlg:requireMarketGoodCard(goodId, openType, pram, isPet, isFromBuyItem, tradeType)
    MarketMgr:requireMarketGoodCard(goodId, openType, pram, isPet, false, self:getTradeType())
end

function MarketSellBasicDlg:cleanup()
    self.tradeType = nil
end

function MarketSellBasicDlg:MSG_STALL_MINE(data)
    self:MSG_GOLD_STALL_MINE()
end

function MarketSellBasicDlg:MSG_GOLD_STALL_MINE(data)
    local item = MarketMgr:getSelectGoodInfo()
    if not item or not next(item) then return end

    local pubicPanel = self:getControl("OnSellPanel")
    local moneyPanel = self:getControl('FreePricePanel', nil, pubicPanel)
    local cashText,fonColor = gf:getArtFontMoneyDesc(item.price or 1000)
    self:setNumImgForPanel("MoneyValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, moneyPanel)
end

return MarketSellBasicDlg
