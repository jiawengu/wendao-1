-- MarketChangePriceDlg.lua
-- Created by songcw Feb/08/2017
-- 集市 珍宝 修改价格界面

local MarketChangePriceDlg = Singleton("MarketChangePriceDlg", Dialog)

function MarketChangePriceDlg:init()
    self:bindListener("ComfireButton", self.onComfireButton)
    self:bindListener("CancelButton", self.onCloseButton)

    -- 当前价格
    local item = MarketMgr:getSelectGoodInfo()
    local cashText,fonColor = gf:getArtFontMoneyDesc(item.price or 1000)
    local moneyPanel = self:getControl("PrePricePanel")
    self:setNumImgForPanel("MoneyValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, moneyPanel)

    -- 可修改次数
    self:setLabelText("TimesLabel", string.format(CHS[4100406], item.cg_price_count))

    self.inputNum = nil
    self.tradeType = nil
    self.isGoldVendue = nil
    self:bindSellNumInput()


    self.maxPrice = 2000000000
end


function MarketChangePriceDlg:setTradeType(type, isGoldVendue)
    self.tradeType = type
    self.isGoldVendue = isGoldVendue

    self:setCtrlVisible("GoldImage", type == MarketMgr.TradeType.goldType, "PrePricePanel")
    self:setCtrlVisible("MoneyImage", type == MarketMgr.TradeType.marketType, "PrePricePanel")

    self:setCtrlVisible("GoldImage", type == MarketMgr.TradeType.goldType, "AftPricePanel")
    self:setCtrlVisible("MoneyImage", type == MarketMgr.TradeType.marketType, "AftPricePanel")

    if MarketMgr:isGoldtype(type) then
        self.maxPrice = 100000000
    end
end

-- 设置数字键盘输入
function MarketChangePriceDlg:bindSellNumInput()
    local pubicPanel = self:getControl("AftPricePanel")
    local moneyPanel = self:getControl('MoneyValuePanel', nil, pubicPanel)
    local function openNumIuputDlg()
        local rect = self:getBoundingBoxInWorldSpace(moneyPanel)
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setObj(self)
        dlg.root:setPosition(rect.x + rect.width /2 , rect.y  + rect.height +  dlg.root:getContentSize().height /2 + 10)
        self:setCtrlVisible("Label", false, pubicPanel)
    end
    self:bindListener("MoneyValuePanel", openNumIuputDlg, pubicPanel)
end

-- 数字键盘删除数字
function MarketChangePriceDlg:deleteNumber()
    if not self.inputNum then self.inputNum = 0 end
    self.inputNum = math.floor(self.inputNum / 10)
    self:refreshPublicCash(self.inputNum )
end

-- 数字键盘清空
function MarketChangePriceDlg:deleteAllNumber(key)
    self.inputNum = 0
    self:refreshPublicCash(self.inputNum )
end

-- 数字键盘插入数字
function MarketChangePriceDlg:insertNumber(num)
    if not self.inputNum then self.inputNum = 0 end

    if num == "00" then
        self.inputNum = self.inputNum * 100
    elseif num == "0000" then
        self.inputNum = self.inputNum * 10000
    else
        self.inputNum = self.inputNum * 10 + num
    end

    if self.inputNum >= self.maxPrice then
        self.inputNum = self.maxPrice
        gf:ShowSmallTips(CHS[3003069])
    end
    self:refreshPublicCash(self.inputNum )
end

function MarketChangePriceDlg:closeNumInputDlg(key)
    if not self.inputNum then self:setCtrlVisible("Label", true, "AftPricePanel") end
end

-- 刷新公示的信息
function MarketChangePriceDlg:refreshPublicCash(cash)
    local pubicPanel = self:getControl("AftPricePanel")
    local moneyPanel = self:getControl('MoneyValuePanel', nil, pubicPanel)
    local cashText,fonColor = gf:getArtFontMoneyDesc(cash)
    self:setNumImgForPanel("MoneyValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, moneyPanel)
end

function MarketChangePriceDlg:onComfireButton(sender, eventType)
    local item = MarketMgr:getSelectGoodInfo()

    if not item or not next(item) then return end

    if not self.inputNum then
        gf:ShowSmallTips(CHS[4300207])
        return
    end

    if item.status == MARKET_STATUS.STALL_GS_SHOWING and item.endTime - gf:getServerTime() < 3600 then
        gf:ShowSmallTips(CHS[4300205])
        self:onCloseButton()
        return
    end

    if item.cg_price_count <= 0 then
        gf:ShowSmallTips(CHS[4300206])
        return
    end



    if self.isGoldVendue then



        if self.inputNum < math.floor( item.init_price * 0.8 ) and math.floor( item.init_price * 0.8 ) == math.floor( math.max( MarketMgr:getVendueMin(), item.init_price * 0.8, item.buyout_price * 0.8 ) ) then
            self.inputNum = math.floor( item.init_price * 0.8 )
            self:refreshPublicCash(self.inputNum )
            gf:ShowSmallTips(CHS[4200567])--修改的价格不能小于初始价格的80%，修改价格失败。",
            return
        end

        if self.inputNum < math.floor( item.buyout_price * 0.8 ) and math.floor( item.buyout_price * 0.8 ) == math.floor( math.max( MarketMgr:getVendueMin(), item.init_price * 0.8, item.buyout_price * 0.8 ) ) then
            self.inputNum = math.floor( item.buyout_price * 0.8 )
            self:refreshPublicCash(self.inputNum )
            gf:ShowSmallTips(CHS[4200568])
            return
        end

        if self.inputNum < MarketMgr:getVendueMin() and MarketMgr:getVendueMin() == math.floor( math.max( MarketMgr:getVendueMin(), item.init_price * 0.8, item.buyout_price * 0.8 ) ) then
            self.inputNum =MarketMgr:getVendueMin()
            self:refreshPublicCash(self.inputNum )
            gf:ShowSmallTips(string.format( CHS[4101213], MarketMgr:getVendueMin()))
            return
        end

        if self.inputNum < MarketMgr:getVendueMin() then
            -- 商品价格少于%d元宝，修改价格失败
            gf:ShowSmallTips(string.format( CHS[4101213], MarketMgr:getVendueMin()))
            self.inputNum = MarketMgr:getVendueMin()
            self:refreshPublicCash(self.inputNum )
            return
        end

        if self.inputNum > MarketMgr:getVendueMax() then
            -- 商品价格大于%d元宝，修改价格失败
            gf:ShowSmallTips(string.format( CHS[4101214], MarketMgr:getVendueMax()))
            self.inputNum = MarketMgr:getVendueMax()
            self:refreshPublicCash(self.inputNum )
            return
        end

    else
            -- 最低价格判断
        local num = math.max(1, math.ceil(item.init_price * 0.8))
        if self.inputNum < num then
            if math.ceil(item.init_price * 0.8) < 1 then
                gf:ShowSmallTips(CHS[4300208])
                self.inputNum = 1


            elseif math.ceil(item.init_price * 0.8) >= 1 then
                gf:ShowSmallTips(CHS[4300209])
                self.inputNum = math.ceil(item.init_price * 0.8)
            end

            self:refreshPublicCash(self.inputNum )
            return
        end

        -- 最高价格判断
        local max = math.floor(item.init_price * 1.2)
        if self.inputNum > max then
            gf:ShowSmallTips(CHS[4300210])
            self.inputNum = max
            self:refreshPublicCash(self.inputNum )
            return
        end
    end


    if self.tradeType == MarketMgr.TradeType.goldType then
        local itemNames = gf:split(item.name, "|")
        gf:confirm(string.format(CHS[4300211], itemNames[1], item.price, self.inputNum), function ()
            MarketMgr:changeGoldGoodsPrice(item.id, self.inputNum)

            self:onCloseButton()
        end)
    else
        local costCash = self:getTheCost()
        if costCash > Me:queryBasicInt("cash") then
            gf:askUserWhetherBuyCash()
            return
        end

        local itemNames = gf:split(item.name, "|")
        gf:confirm(string.format(CHS[4100834], itemNames[1], gf:getMoneyDesc(item.price), gf:getMoneyDesc(self.inputNum), gf:getMoneyDesc(costCash)), function ()
            MarketMgr:changeGoodsPrice(item.id, self.inputNum)

            self:onCloseButton()
        end)
    end

end

function MarketChangePriceDlg:getTheCost()
    local item = MarketMgr:getSelectGoodInfo()
    local cost = math.floor(item.init_price * 0.002)
    cost = math.max(cost, 20000)
    cost = math.min(cost, 200000)

    return cost
end

return MarketChangePriceDlg
