-- MarketGoldViewGoodsDlg.lua
-- Created by songcw
-- 珍宝展示界面，查看


local MarketGoldViewGoodsDlg = Singleton("MarketGoldViewGoodsDlg", Dialog)

function MarketGoldViewGoodsDlg:init()
    self:bindListener("BuyButton", self.onBuyButton, "CommonViewPanel")
    self:bindListener("BuyButton", self.onBuyButton, "DesignatedViewPanel")
    self:bindListener("PanicBuyButton", self.onPanicBuyButton)

    self:bindListener("UnlockButton", self.onUnlockButton, "CommonViewPanel")
    self:bindListener("UnlockButton", self.onUnlockButton, "DesignatedViewPanel")
    self:bindListener("UnlockButton", self.onUnlockButton, "VendueViewPanel")

    self:setCtrlVisible("UnlockButton", SafeLockMgr:isNeedUnLock(), "CommonViewPanel")
    self:setCtrlVisible("UnlockButton", SafeLockMgr:isNeedUnLock(), "DesignatedViewPanel")
    self:setCtrlVisible("UnlockButton", SafeLockMgr:isNeedUnLock(), "VendueViewPanel")

    self:bindListener("PayDepositButton", self.onPayDepositButton, "DesignatedViewPanel")

    self:bindListener("NoteButton", self.onNoteButton)

    self:bindListener("NoteButton", self.onNoteButton)
    self:bindListener("NoteButton", self.onVendueNoteButton, "VendueViewPanel")
    self:bindListener("OfferButton", self.onOfferButton, "VendueViewPanel")
    self:bindListener("VendueButton", self.onVendueButton)

    self:hookMsg("MSG_GOLD_STALL_MINE")
    self:hookMsg("MSG_GOLD_STALL_BUY_RESULT")
    self:hookMsg("MSG_SAFE_LOCK_INFO")

    self.data = nil
    self.tradeInfo = nil
end


function MarketGoldViewGoodsDlg:setData(item, tradeInfo)
    local paraExtra = tradeInfo.extra or tradeInfo.para_str
    local goodsData = json.decode(paraExtra)
    for field, value in pairs(goodsData) do
        tradeInfo[field] = value
    end

    self.data = item
    self.tradeInfo = tradeInfo

    local isVisibleCommonResell = (tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_NONE or tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_CONTINUE)
    self:setCtrlVisible("CommonViewPanel", isVisibleCommonResell, "RightPanel")
    self:setCtrlVisible("DesignatedViewPanel", tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_SELL, "RightPanel")
    self:setCtrlVisible("VendueViewPanel", tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_AUCTION, "RightPanel")

    if tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_SELL then
        self:setDesignatedByPanelName(tradeInfo, "DesignatedViewPanel")
    elseif isVisibleCommonResell then
        self:setCommonView(tradeInfo)
    elseif tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_AUCTION then
        self:setVendueView(tradeInfo)
    end
end

-- 设置 查看已经上架的普通类型的交易信息
function MarketGoldViewGoodsDlg:setVendueView(data)
    local commonViewPanel = self:getControl("VendueViewPanel")
    -- 拍卖底价
    local pricePanel = self:getControl("OriginalPricePanel", nil, commonViewPanel)
    local cashText, fonColor = gf:getArtFontMoneyDesc(data.price)
    self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, pricePanel)

    -- 公示剩余时间
    if data.status == MARKET_STATUS.STALL_GS_AUCTION_SHOW then
        -- 公示期
        self:setCtrlVisible("PublicInfoPanel", true)
        self:setCtrlVisible("SaleInfoPanel", false)
        local leftTime = data.endTime - gf:getServerTime()
        self:setLabelText("LeftLabel", string.format(CHS[4101221], MarketMgr:getTimeStr(leftTime)), "PublicInfoPanel") -- 公示中，剩余时间：

        self:setCtrlEnabled("OfferButton", false, nil, true)
    elseif data.status == MARKET_STATUS.STALL_GS_AUCTION then
        -- 寄售期
        self:setCtrlVisible("PublicInfoPanel", false)
        self:setCtrlVisible("SaleInfoPanel", true)

        -- 当前出价
        local pricePanel = self:getControl("NowPricePanel", nil, commonViewPanel)
        local cashText, fonColor = gf:getArtFontMoneyDesc(data.buyout_price)
        self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, pricePanel)

        -- 竞拍次数
        local paraExtra = data.extra or data.para_str
        local extraInfo = json.decode(paraExtra)
        self:setLabelText("OfferTimeLabel", string.format(CHS[4101222], extraInfo.auction_count), "SaleNoticePanel")

        -- 竞拍剩余时间
        local leftTime = data.endTime - gf:getServerTime()
        self:setLabelText("LeftLabel", string.format(CHS[4101223], MarketMgr:getTimeStr(leftTime)), "SaleNoticePanel")
    end
end

-- 设置 查看已经上架的普通类型的交易信息
function MarketGoldViewGoodsDlg:setCommonView(data)
    local commonViewPanel = self:getControl("CommonViewPanel")
    -- 价格
    local pricePanel = self:getControl("PricePanel", nil, commonViewPanel)
    local cashText, fonColor = gf:getArtFontMoneyDesc(data.price)
    self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, pricePanel)

    -- 剩余时间
    -- 剩余时间
    local leftPanel = self:getControl("LeftTimePanel", nil, commonViewPanel)
    -- 处于公示、寄售
    local leftTime = data.endTime - gf:getServerTime()
    if data.status == MarketMgr.TRADE_GOLD_STATE.SHOW then
        self:setLabelText("PublicLabel_1", string.format(CHS[4010214], MarketMgr:getTimeStr(leftTime)), leftPanel) -- 公示中，剩余时间：
        self:setCtrlVisible("PanicBuyButton", true)
    elseif data.status == MarketMgr.TRADE_GOLD_STATE.ON_SELL then
        self:setLabelText("PublicLabel_1", string.format(CHS[4010215], MarketMgr:getTimeStr(leftTime)), leftPanel) -- 公示中，剩余时间：
        self:setCtrlVisible("PanicBuyButton", false)
    end
end

-- 设置 查看已经上架的普通类型的交易信息
function MarketGoldViewGoodsDlg:setDesignatedByPanelName(tradeInfo, panelName)

    local panel = self:getControl(panelName)

    -- 设置名字
    local namePanel = self:getControl("DesignatedNamePanel", nil, panel)
    self:setLabelText("DefaultLabel", tradeInfo.appointee_name, namePanel)

    -- 指定价格
    local pricePanel = self:getControl("PricePanel", nil, panel)
    local cashText, fonColor = gf:getArtFontMoneyDesc(tradeInfo.price)
    self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, pricePanel)

    -- 一口价
    local fixedPanel = self:getControl("FixedPricePanel", nil, panel)
    local cashText, fonColor = gf:getArtFontMoneyDesc(tradeInfo.buyout_price)
    self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, fixedPanel)


    -- 订金
    local depositPanel = self:getControl("DepositPanel", nil, designPanel)
    if not tradeInfo.price then
        self:removeNumImgForPanel("ValuePanel", LOCATE_POSITION.MID, depositPanel)
    else
        local cashText, fonColor = gf:getArtFontMoneyDesc(MarketMgr:getDepositDingJin(tradeInfo.price))
        self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, depositPanel)
    end

    -- 剩余时间
    local leftPanel = self:getControl("LeftTimePanel", nil, panel)
    -- 处于公示、寄售
    local leftTime = tradeInfo.endTime - gf:getServerTime()
    if tradeInfo.status == MarketMgr.TRADE_GOLD_STATE.SHOW then
        self:setLabelText("PublicLabel_1", string.format( CHS[4101208], MarketMgr:getTimeStr(leftTime)), leftPanel) -- 公示中，剩余时间：
        self:setCtrlEnabled("BuyButton", false, panel)
    elseif tradeInfo.status == MarketMgr.TRADE_GOLD_STATE.ON_SELL then
        self:setLabelText("PublicLabel_1", string.format( CHS[4010218], MarketMgr:getTimeStr(leftTime)), leftPanel) -- 指定交易摆摊中,剩余时间：
    end

    -- 指定玩家，半小时内，未支付定金，需要显示支付定金按钮
    if tradeInfo.appointee_name == Me:queryBasic("name") and tradeInfo.deposit_state == 0 then
        self:setCtrlVisible("PayDepositButton", true, panel)
        self:setCtrlVisible("BuyButton", false, panel)
    else
        self:setCtrlVisible("PayDepositButton", false, panel)

    end

    -- 被指定方且支付订金后显示
    if tradeInfo.appointee_name == Me:queryBasic("name") and tradeInfo.deposit_state == 1 then
        local cashText, fonColor = gf:getArtFontMoneyDesc(tradeInfo.price - MarketMgr:getDepositDingJin(tradeInfo.price))
        self:setLabelText("NoteLabel_0", string.format( CHS[4101266], cashText), pricePanel)
    else
        self:setLabelText("NoteLabel_0", "", pricePanel)
    end

    -- 定金支付情况
    if tradeInfo.deposit_state == 1 then
        self:setLabelText("NoteLabel_0", string.format( CHS[4101262]), depositPanel)
    else
        self:setLabelText("NoteLabel_0", string.format( CHS[4101263]), depositPanel)
    end
end

function MarketGoldViewGoodsDlg:onBuyButton(sender, eventType)
    if DlgMgr:getDlgByName("MarketGoldBuyDlg") then
        DlgMgr:sendMsg("MarketGoldBuyDlg", "onBuyButton")
    elseif DlgMgr:getDlgByName("MarketGoldCollectionDlg") then
        DlgMgr:sendMsg("MarketGoldCollectionDlg", "onBuyButton")
    else
        -- 异常，容错
        self:onCloseButton()
    end
end

function MarketGoldViewGoodsDlg:onPanicBuyButton(sender, eventType)
    if DlgMgr:getDlgByName("MarketGlodPublicityDlg") then
        DlgMgr:sendMsg("MarketGlodPublicityDlg", "onPanicBuyButton")
    elseif DlgMgr:getDlgByName("MarketGoldCollectionDlg") then
        DlgMgr:sendMsg("MarketGoldCollectionDlg", "onPanicBuyButton")
    else
        -- 异常，容错
        self:onCloseButton()
    end
end


function MarketGoldViewGoodsDlg:MSG_SAFE_LOCK_INFO(data)
    self:setCtrlVisible("UnlockButton", SafeLockMgr:isNeedUnLock(), "CommonViewPanel")
    self:setCtrlVisible("UnlockButton", SafeLockMgr:isNeedUnLock(), "DesignatedViewPanel")
    self:setCtrlVisible("UnlockButton", SafeLockMgr:isNeedUnLock(), "VendueViewPanel")
end

function MarketGoldViewGoodsDlg:MSG_GOLD_STALL_BUY_RESULT(data)
    if data.result == 1 or data.result == 3 then
        self:onCloseButton()
    end
end

function MarketGoldViewGoodsDlg:MSG_GOLD_STALL_MINE(data)
    if data.result == 1 or data.result == 3 then
        self:onCloseButton()
    end

end


function MarketGoldViewGoodsDlg:onPayDepositButton(sender, eventType)

        -- 角色处于禁闭状态，当前无法进行此操作
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[5000228])
        return
    end

    local path_str
    local page_str
    local type

    local publickDlg = DlgMgr:getDlgByName("MarketGlodPublicityDlg") or DlgMgr:getDlgByName("MarketGoldBuyDlg")
    if not publickDlg then
        -- 异常情况
        publickDlg = DlgMgr:getDlgByName("MarketGoldCollectionDlg")
        if not publickDlg then
            return
        else
            path_str = ""
            page_str = ""
            type = 2    -- 从收藏中购买
        end
    end

    local id = self.tradeInfo.id
    local price = self.tradeInfo.price
    local deposit = MarketMgr:getDepositDingJin(price)


    path_str = path_str or publickDlg:getRequestKey()
    page_str = page_str or publickDlg:getPageStr()
    type  = type or MarketMgr.TradeType.goldType

    if not type then
        return
    end

    gf:CmdToServer("CMD_GOLD_STALL_PAY_DEPOSIT", {goods_gid = id, expect_price = price, deposit = deposit, path_str = path_str, page_str = page_str, type = type})
end


function MarketGoldViewGoodsDlg:onUnlockButton(sender, eventType)
    -- 安全锁判断
    if self:checkSafeLockRelease("onUnlockButton") then
        return
    end
end

function MarketGoldViewGoodsDlg:onOfferButton(sender, eventType)
    if not self.tradeInfo then return end

    if self.tradeInfo.status == MarketMgr.TRADE_GOLD_STATE.SHOW_VENDUE then
        gf:ShowSmallTips(CHS[4101231])
        return
    end

    local dlg = DlgMgr:openDlg("MarketGoldBidDlg")
    dlg:setData(self.data, self.tradeInfo, self.curPage, self.sortType)
end

function MarketGoldViewGoodsDlg:onVendueNoteButton(sender, eventType)
       local dlg = DlgMgr:openDlg("MarketRuleDlg")
        dlg:setRuleType("VendueReSellPanel")
end

function MarketGoldViewGoodsDlg:onNoteButton(sender, eventType)
       local dlg = DlgMgr:openDlg("MarketRuleDlg")
        dlg:setRuleType("MarketGoldItemInfoDlg")
end

function MarketGoldViewGoodsDlg:onVendueButton(sender, eventType)
end

return MarketGoldViewGoodsDlg
