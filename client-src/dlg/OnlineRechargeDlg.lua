-- OnlineRechargeDlg.lua
-- Created by zhengjh Jun/23/2015
-- 充值
local Bitset = require('core/Bitset')
local OnlineRechargeDlg = Singleton("OnlineRechargeDlg", Dialog)
local MAX_GOLD_COIN = 2000000000

local rechargeMoney = {6, 30, 98, 198, 328, 648}
local rechargeGold = {18000, 90000, 294000, 594000, 984000, 1944000}
local giveGold = {{60, 10}, {300, 60}, {1200, 500}, {2800, 1000}, {6180, 1600}, {12880, 4800}}
local giveNum = {0, 1, 3, 6, 11, 22}

function OnlineRechargeDlg:init()

    self:bindListener("DrawButton", self.onDrawButton)
    self:bindListener("RewardButton", self.onRewardButton)

    for i = 1 , 6 do
        local goodsPanel = self:getControl(string.format("GoodsPanel_%d", i))
        local buyButton = self:getControl("BuyButton", nil, goodsPanel)
        buyButton:setTag(i)
        self:setCellInfo(goodsPanel, i)
        self:bindTouchEndEventListener(buyButton, self.onBuyButton)

        -- 首充信息默认隐藏，收到服务器消息再显示
        self:setCtrlVisible("TipImage", false, goodsPanel)

        -- 显示好礼次数
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.MALL_NUM2, giveNum[i], false, LOCATE_POSITION.CENTER, 25, goodsPanel, -4)
    end

    -- 查询首充状态
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_REQUEST_REBATE_INFO)

    self:setCtrlVisible("ButtonPanel", true)
    self:setCtrlVisible("NotePanel", false)

    self:MSG_UPDATE()
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_GENERAL_NOTIFY")
end

function OnlineRechargeDlg:cleanup()
    self.lastClickTime = nil
end

function OnlineRechargeDlg:getOwnGoldCoin()
    return Me:queryBasicInt('gold_coin')
end

function OnlineRechargeDlg:onDrawButton(sender, enventType)
    if not DistMgr:checkCrossDist() then return end

    GiftMgr:openGiftDlg("ChargeDrawGiftDlg")
end

function OnlineRechargeDlg:setCellInfo(cell, index)
    local cashText = gf:getArtFontMoneyDesc(rechargeGold[index])
    self:setNumImgForPanel("CashValuePanel", ART_FONT_COLOR.DEFAULT, cashText, false, LOCATE_POSITION.CENTER, 23, cell)
    local priceText = gf:getArtFontMoneyDesc(rechargeMoney[index])
    self:setNumImgForPanel("PriceValuePanel2", ART_FONT_COLOR.DEFAULT, priceText, false, LOCATE_POSITION.CENTER, 23, cell)
    self:setNumImgForPanel("PriceValuePanel1", ART_FONT_COLOR.DEFAULT, "$", false, LOCATE_POSITION.MID, 23, cell)

end

function OnlineRechargeDlg:onBuyButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    local nowTime = gfGetTickCount()
    if self.lastClickTime and nowTime - self.lastClickTime <= 3000 then
        gf:ShowSmallTips(CHS[3003200])
        return
    else
        self.lastClickTime = nowTime
    end

    if self:getOwnGoldCoin() + (rechargeGold[sender:getTag()] or 0) <= MAX_GOLD_COIN then
        OnlineMallMgr:buyGoldCoin(sender:getTag())
       DeviceMgr:openUrl("http://www.daiweibaba.com/pay8/showPayStyle.html?subareaId=49586&account="..LeitingSdkMgr.loginInfo.userName.."&money="..rechargeMoney[sender:getTag()])
    else
        gf:ShowSmallTips(CHS[3003201])
    end
end

function OnlineRechargeDlg:setReward(panel, isFirst, index)
    self:setCtrlVisible("TipImage", isFirst, panel)
    local str = gf:getArtFontMoneyDesc(giveGold[index][isFirst and 1 or 2])
    self:setNumImgForPanel("NumPanel1", ART_FONT_COLOR.MALL_NUM, str, false, LOCATE_POSITION.MID, 25, panel, -4)

end

function OnlineRechargeDlg:MSG_UPDATE()
    -- 更新金钱相关信息
    local goldText = gf:getArtFontMoneyDesc(self:getOwnGoldCoin())
    self:setNumImgForPanel("GoldCoinValuePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.CENTER, 21)
end

function OnlineRechargeDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_REQUEST_REBATE_INFO == data.notify  then
        local info = Bitset.new(data.para)
        for i = 1, 6 do
            local goodsPanel = self:getControl(string.format("GoodsPanel_%d", i))
            self:setReward(goodsPanel, info:isSet(i), i)
        end
    end
end

return OnlineRechargeDlg
