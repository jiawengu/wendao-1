-- MarketGoldPayDlg.lua
-- Created by songcw    Sep/2018/30
-- 珍宝拍卖交易-支付界面

local MarketGoldPayDlg = Singleton("MarketGoldPayDlg", Dialog)

function MarketGoldPayDlg:init()
    self:bindListener("PayButton", self.onPayButton)
    self:bindListener("UnlockButton", self.onUnlockButton)
    self:bindListener("NoteButton", self.onNoteButton)

    self:setCtrlVisible("UnlockButton", SafeLockMgr:isNeedUnLock())

    self:hookMsg("MSG_SAFE_LOCK_INFO")

    self.data = nil
    self.tradeInfo = nil

    self.unitRefresh = 0

    self:setLabelText("TimeLeftLabel", "")
end

function MarketGoldPayDlg:onUpdate()
    if not self.tradeInfo then return end

    self.unitRefresh = self.unitRefresh + 1
    if self.unitRefresh % 5 ~= 0 then return end

    local leftTime = self.tradeInfo.endTime - gf:getServerTime()
    leftTime = math.max( 0, leftTime )
    local h = math.floor( leftTime / 3600 )
    local m = math.floor( leftTime % 3600 / 60)
    local s = leftTime % 60
    local timeStr = string.format( CHS[4101224], h, m, s)    -- 支付剩余时间：%d小时%d分%d秒
    self:setLabelText("TimeLeftLabel", timeStr)
end


function MarketGoldPayDlg:setData(item, tradeInfo)
    self.data = item
    self.tradeInfo = tradeInfo

    -- 成交价格
    local cashText, fonColor = gf:getArtFontMoneyDesc(tradeInfo.buyout_price)
    self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, "PricePanel")

    -- 任需支付
        local cashText, fonColor = gf:getArtFontMoneyDesc(tradeInfo.buyout_price - 2000)
    self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, "PriceRemainPanel")

    -- 先手动调用一下，不然可能会闪一下
    self.unitRefresh = 4
    self:onUpdate()
end

function MarketGoldPayDlg:onPayButton(sender, eventType)

    local path_str = DlgMgr:sendMsg("MarketGoldVendueDlg", "getRequestKey")
    local page_str = DlgMgr:sendMsg("MarketGoldVendueDlg", "getPageStr")

    local type = MarketMgr.STALL_BUY_COMMON
    if path_str == CHS[4101220] then    -- -- 我的竞拍__
        type = MarketMgr.STALL_BUY_AUCTION
        path_str = ""
        page_str = ""
    end

    if DlgMgr:getDlgByName("MarketGoldCollectionDlg") then
        type = MarketMgr.STALL_BUY_COLLECT
        path_str = ""
        page_str = ""
    end

    local data = {goods_id = self.tradeInfo.id, path_str = path_str, page_str = page_str, price = self.tradeInfo.buyout_price, type = type}
    gf:CmdToServer("CMD_GOLD_STALL_BUY_AUCTION_GOODS", data)

end

function MarketGoldPayDlg:onUnlockButton(sender, eventType)
        -- 安全锁判断
    if self:checkSafeLockRelease("onUnlockButton") then
        return
    end
end

function MarketGoldPayDlg:onNoteButton(sender, eventType)
    local dlg = DlgMgr:openDlg("MarketRuleDlg")
    dlg:setRuleType("VendueReSellPanel")
end

function MarketGoldPayDlg:MSG_SAFE_LOCK_INFO(data)
    self:setCtrlVisible("UnlockButton", SafeLockMgr:isNeedUnLock())
end

return MarketGoldPayDlg
