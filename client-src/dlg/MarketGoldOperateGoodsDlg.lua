-- MarketGoldOperateGoodsDlg.lua
-- Created by songcw
-- 珍宝展示界面，操作

local MarketGoldOperateGoodsDlg = Singleton("MarketGoldOperateGoodsDlg", Dialog)

function MarketGoldOperateGoodsDlg:init()
    self:bindListener("TakeBackButton", self.onTakeBackButton, "DesignatedOperatePanel")
    self:bindListener("ChangePriceButton", self.onCommonChangePriceButton, "CommonOperatePanel")
    self:bindListener("ChangePriceButton", self.onVendueChangePriceButton, "VendueOperatePanel")
    self:bindListener("TakeBackButton", self.onTakeBackButton, "CommonOperatePanel")
    self:bindListener("TakeBackButton", self.onTakeBackButton, "VendueOperatePanel")
    self:bindListener("ChangePriceButton", self.onDesignatedChangePriceButton, "DesignatedOperatePanel")
    self:bindListener("NoteButton", self.onNoteButton)

    self:bindListener("NoteButton", self.onVendueNoteButton, "VendueOperatePanel")
    self:bindListener("VendueButton", self.onVendueButton)

    self.tradeInfo = nil
    self.parentDlg = nil

    self:hookMsg("MSG_GOLD_STALL_MINE")
end

function MarketGoldOperateGoodsDlg:closeParentDlg()
    if self.parentDlg then
        DlgMgr:closeDlg(self.parentDlg.name)
    end
end

function MarketGoldOperateGoodsDlg:setData(item, tradeInfo)
    local paraExtra = tradeInfo.extra or tradeInfo.para_str
    local goodsData = json.decode(paraExtra)
    for field, value in pairs(goodsData) do
        tradeInfo[field] = value
    end

    self.tradeInfo = tradeInfo

    local isVisibleCommonResell = (tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_NONE or tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_CONTINUE)
    self:setCtrlVisible("CommonOperatePanel", isVisibleCommonResell, "RightPanel")
    self:setCtrlVisible("DesignatedOperatePanel", tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_SELL, "RightPanel")
    self:setCtrlVisible("VendueOperatePanel", tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_AUCTION, "RightPanel")

    if tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_SELL then
        self:setOperateDesignated(tradeInfo)
    elseif isVisibleCommonResell then
        self:setOperateCommon(tradeInfo)
    elseif tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_AUCTION then
        self:setOperateVendue(tradeInfo)
    end
end

function MarketGoldOperateGoodsDlg:setOperateVendue(tradeInfo)

    local panel = self:getControl("VendueOperatePanel")

    -- 拍卖底价
    local pricePanel = self:getControl("PricePanel", nil, panel)
    local cashText, fonColor = gf:getArtFontMoneyDesc(tradeInfo.price)
    self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, pricePanel)

    -- 公示剩余时间
    if tradeInfo.status == MARKET_STATUS.STALL_GS_AUCTION_SHOW then
        -- 公示期
        self:setCtrlVisible("PublicInfoPanel", true)
        self:setCtrlVisible("SaleInfoPanel", false)
        local leftTime = tradeInfo.endTime - gf:getServerTime()
        self:setLabelText("LeftLabel", string.format(CHS[4101221], MarketMgr:getTimeStr(leftTime)), "PublicInfoPanel") -- 公示中，剩余时间：
    elseif tradeInfo.status == MARKET_STATUS.STALL_GS_AUCTION then
        -- 寄售期
        self:setCtrlVisible("PublicInfoPanel", false)
        self:setCtrlVisible("SaleInfoPanel", true)

        -- 当前出价
        local pricePanel = self:getControl("NowPricePanel", nil, commonViewPanel)
        local cashText, fonColor = gf:getArtFontMoneyDesc(tradeInfo.buyout_price)
        self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, pricePanel)

        -- 竞拍次数
        local paraExtra = tradeInfo.extra or tradeInfo.para_str
        local extraInfo = json.decode(paraExtra)
        self:setLabelText("OfferTimeLabel", string.format(CHS[4101222], extraInfo.auction_count), "SaleNoticePanel") -- 竞拍次数：%d

        -- 竞拍剩余时间
        local leftTime = tradeInfo.endTime - gf:getServerTime()
        self:setLabelText("LeftLabel", string.format(CHS[4101223], MarketMgr:getTimeStr(leftTime)), "SaleNoticePanel")-- 拍卖剩余时间：%s
    end
end

-- 设置 操作摆摊类型 指定交易信息
function MarketGoldOperateGoodsDlg:setOperateDesignated(tradeInfo)
    local panel = self:getControl("DesignatedOperatePanel")

    -- 设置名字
    local namePanel = self:getControl("DesignatedNamePanel", nil, panel)
    self:setLabelText("DefaultLabel", tradeInfo.appointee_name, namePanel)

    -- 指定价格
    local pricePanel = self:getControl("PricePanel", nil, panel)
    local cashText, fonColor = gf:getArtFontMoneyDesc(tradeInfo.price)
    self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, pricePanel)

    -- 订金
    local depositPanel = self:getControl("DepositPanel", nil, designPanel)
    if not tradeInfo.price then
        self:removeNumImgForPanel("ValuePanel", LOCATE_POSITION.MID, depositPanel)
    else
        local cashText, fonColor = gf:getArtFontMoneyDesc(MarketMgr:getDepositDingJin(tradeInfo.price))
        self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, depositPanel)
    end

    -- 一口价
    local fixedPanel = self:getControl("FixedPricePanel", nil, panel)
    local cashText, fonColor = gf:getArtFontMoneyDesc(tradeInfo.buyout_price)
    self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, fixedPanel)

    -- 剩余时间
    local leftPanel = self:getControl("LeftTimePanel", nil, panel)
    -- 处于公示、寄售
    local leftTime = tradeInfo.endTime - gf:getServerTime()
    if tradeInfo.status == MarketMgr.TRADE_GOLD_STATE.SHOW then
        self:setLabelText("PublicLabel_1", string.format( CHS[4101208], MarketMgr:getTimeStr(leftTime)) , leftPanel) -- 指定交易公示中，剩余时间
    elseif tradeInfo.status == MarketMgr.TRADE_GOLD_STATE.ON_SELL then
        self:setLabelText("PublicLabel_1", string.format( CHS[4010218], MarketMgr:getTimeStr(leftTime)) , leftPanel) -- 指定交易摆摊中,剩余时间：
    end

    -- 定金支付情况
    if tradeInfo.deposit_state == 1 or tradeInfo.deposit_state == 3 or tradeInfo.deposit_state == 4 then
        -- 与服务器确认，134都为已支付
        self:setLabelText("NoteLabel_0", string.format( CHS[4101262]), depositPanel)
    else
        self:setLabelText("NoteLabel_0", string.format( CHS[4101263]), depositPanel)
    end
end

function MarketGoldOperateGoodsDlg:setOperateCommon(tradeInfo)

    local panel = self:getControl("CommonOperatePanel")

    -- 价格
    local pricePanel = self:getControl("PricePanel", nil, panel)
    local cashText, fonColor = gf:getArtFontMoneyDesc(tradeInfo.price)
    self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, pricePanel)

        -- 剩余时间
    local leftPanel = self:getControl("LeftTimePanel", nil, panel)
    -- 处于公示、寄售
    local leftTime = tradeInfo.endTime - gf:getServerTime()
    if tradeInfo.status == MarketMgr.TRADE_GOLD_STATE.SHOW then
        self:setLabelText("PublicLabel_1", string.format(CHS[4010214], MarketMgr:getTimeStr(leftTime)) , leftPanel) -- 公示中，剩余时间：
        self:setCtrlVisible("PanicBuyButton", true)
    elseif tradeInfo.status == MarketMgr.TRADE_GOLD_STATE.ON_SELL then
        self:setLabelText("PublicLabel_1", string.format(CHS[4010215], MarketMgr:getTimeStr(leftTime)) , leftPanel) -- 指定交易摆摊中,剩余时间：
        self:setCtrlVisible("PanicBuyButton", false)
    end
end

function MarketGoldOperateGoodsDlg:onDesignatedChangePriceButton(sender, eventType)
    gf:ShowSmallTips(CHS[4010216])
end


function MarketGoldOperateGoodsDlg:onVendueChangePriceButton(sender, eventType)
    self:onCommonChangePriceButton(sender, eventType, true)
end


function MarketGoldOperateGoodsDlg:onCommonChangePriceButton(sender, eventType, isVendue)
    local info = MarketMgr:getSelectGoodInfo()


    if info.status == MARKET_STATUS.STALL_GS_SHOWING and info.endTime - gf:getServerTime() < 3600 then
        gf:ShowSmallTips(CHS[4300205])
        return
    end

    if info.cg_price_count <= 0 then
        gf:ShowSmallTips(CHS[4300206])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onCommonChangePriceButton", sender, eventType, isVendue) then
        return
    end

    local dlg = DlgMgr:openDlg("MarketChangePriceDlg")
    dlg:setTradeType(self:getTradeType(), isVendue)
end

function MarketGoldOperateGoodsDlg:getTradeType()
    return MarketMgr.TradeType.goldType
end

function MarketGoldOperateGoodsDlg:onTakeBackButton(sender, eventType)
end

function MarketGoldOperateGoodsDlg:onChangePriceButton(sender, eventType)
end

function MarketGoldOperateGoodsDlg:onTakeBackButton(sender, eventType)
    gf:confirm(CHS[3003073], function()

        if self.tradeInfo.deposit_state and self.tradeInfo.deposit_state == 1 then
            gf:ShowSmallTips(CHS[4101264])
            return
        end

        MarketMgr:stopSell(self.tradeInfo.id, MarketMgr.TradeType.goldType)

        self:closeParentDlg()
    end, nil, nil, nil, nil, true)
end

function MarketGoldOperateGoodsDlg:onChangePriceButton(sender, eventType)
end

function MarketGoldOperateGoodsDlg:onNoteButton(sender, eventType)
       local dlg = DlgMgr:openDlg("MarketRuleDlg")
        dlg:setRuleType("MarketGoldItemInfoDlg")
end


function MarketGoldOperateGoodsDlg:onVendueNoteButton(sender, eventType)
       local dlg = DlgMgr:openDlg("MarketRuleDlg")
        dlg:setRuleType("VendueReSellPanel")
end


function MarketGoldOperateGoodsDlg:onVendueButton(sender, eventType)
end

function MarketGoldOperateGoodsDlg:MSG_GOLD_STALL_MINE(data)
    if not self.tradeInfo then return end
    for i = 1, data.stallNum do
        if self.tradeInfo.id == data.items[i].id then
            self.tradeInfo = data.items[i]

            local isVisibleCommonResell = (self.tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_NONE or self.tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_CONTINUE)
            if self.tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_SELL then
                self:setOperateDesignated(self.tradeInfo)
            elseif isVisibleCommonResell then
                self:setOperateCommon(self.tradeInfo)
            elseif self.tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_AUCTION then
                self:setOperateVendue(self.tradeInfo)
            end
        end
    end
end


return MarketGoldOperateGoodsDlg
