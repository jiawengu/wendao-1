-- LineUpOnlineRechargeDlg.lua
-- Created by huangzz Sep/08/2018
-- 充值 - 登录排队

local Bitset = require('core/Bitset')
local LineUpOnlineRechargeDlg = Singleton("LineUpOnlineRechargeDlg", Dialog)
local MAX_GOLD_COIN = 2000000000

local rechargeMoney = {6, 30, 98, 198, 328, 648}
local rechargeGold = {600, 3000, 9800, 19800, 32800, 64800}
local giveGold = {{60, 10}, {300, 60}, {1200, 500}, {2800, 1000}, {6180, 1600}, {12880, 4800}}
local giveNum = {0, 1, 3, 6, 11, 22}

function LineUpOnlineRechargeDlg:getCfgFileName()
    return ResMgr:getDlgCfg("OnlineRechargeDlg")
end

function LineUpOnlineRechargeDlg:init(param)
    local info = Bitset.new(param.para or 0)
    for i = 1 , 6 do
        local goodsPanel = self:getControl(string.format("GoodsPanel_%d", i))
        local buyButton = self:getControl("BuyButton", nil, goodsPanel)
        buyButton:setTag(i)
        self:setCellInfo(goodsPanel, i)
        self:bindTouchEndEventListener(buyButton, self.onBuyButton)

        -- 首充信息默认隐藏，收到服务器消息再显示
        self:setReward(goodsPanel, info:isSet(i), i)

        -- 显示好礼次数
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.MALL_NUM2, giveNum[i], false, LOCATE_POSITION.CENTER, 25, goodsPanel, -4)
    end

    self:updateGoldCoin(0)

    self.lastClickTime = nil

    self:setCtrlVisible("ButtonPanel", false)
    self:setCtrlVisible("NotePanel", true)

    local x, y = self.root:getPosition()
    self.root:setPositionX(x + 10)

    self:hookMsg("MSG_L_START_LOGIN")
    self:hookMsg("MSG_L_CHARGE_DATA")
end

function LineUpOnlineRechargeDlg:startRequestInfo()
    local function update()
        DlgMgr:sendMsg("LineUpDlg", "requestLoginWaitInfo")
    end

    if self.scheduleId then
        self:stopSchedule(self.scheduleId)
        self.scheduleId = nil
    end

    self.scheduleId = self:startSchedule(function()
        update()
    end, 2)
end

function LineUpOnlineRechargeDlg:stopUpdate()
    if self.scheduleId then
        self:stopSchedule(self.scheduleId)
        self.scheduleId = nil
    end
end

function LineUpOnlineRechargeDlg:updateGoldCoin(num)
    if not num then return end

    self.ownGoldCoin = num

    local goldText = gf:getArtFontMoneyDesc(self:getOwnGoldCoin())
    self:setNumImgForPanel("GoldCoinValuePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.CENTER, 21)
end

function LineUpOnlineRechargeDlg:getOwnGoldCoin()
    return self.ownGoldCoin
end

function LineUpOnlineRechargeDlg:setCellInfo(cell, index)
    local cashText = gf:getArtFontMoneyDesc(rechargeGold[index])
    self:setNumImgForPanel("CashValuePanel", ART_FONT_COLOR.DEFAULT, cashText, false, LOCATE_POSITION.CENTER, 23, cell)
    local priceText = gf:getArtFontMoneyDesc(rechargeMoney[index])
    self:setNumImgForPanel("PriceValuePanel2", ART_FONT_COLOR.DEFAULT, priceText, false, LOCATE_POSITION.CENTER, 23, cell)
    self:setNumImgForPanel("PriceValuePanel1", ART_FONT_COLOR.DEFAULT, "$", false, LOCATE_POSITION.MID, 23, cell)
end

function LineUpOnlineRechargeDlg:onBuyButton(sender, eventType)
    local nowTime = gfGetTickCount()
    if self.lastClickTime and nowTime - self.lastClickTime <= 3000 then
        gf:ShowSmallTips(CHS[3003200])
        return
    else
        self.lastClickTime = nowTime
    end

    if self:getOwnGoldCoin() + (rechargeGold[sender:getTag()] or 0) <= MAX_GOLD_COIN then
        DlgMgr:sendMsg("LineUpDlg", "checkCanRequest", function()
            if not DlgMgr:isDlgOpened("LineUpOnlineRechargeDlg") then return end

            gf:CmdToAAAServer("CMD_L_START_RECHARGE", {account = Client:getAccount(), charge_type = sender:getTag()}, CONNECT_TYPE.LINE_UP)
        end)
    else
        gf:ShowSmallTips(CHS[3003201])
    end
end

function LineUpOnlineRechargeDlg:setReward(panel, isFirst, index)
    self:setCtrlVisible("TipImage", isFirst, panel)
    local str = gf:getArtFontMoneyDesc(giveGold[index][isFirst and 1 or 2])
    self:setNumImgForPanel("NumPanel1", ART_FONT_COLOR.MALL_NUM, str, false, LOCATE_POSITION.MID, 25, panel, -4)
end

function LineUpOnlineRechargeDlg:MSG_L_START_LOGIN(data)
    if data.type == ACCOUNT_TYPE.CHARGE then
        -- 收到购买会员数据
        DlgMgr:sendMsg("LineUpDlg", "checkCanRequest", function()
            if not DlgMgr:isDlgOpened("LineUpChangeChannelDlg") then return end

            Client:cmdAccount(0, ACCOUNT_TYPE.CHARGE, CONNECT_TYPE.LINE_UP)
        end)
    end
end

function LineUpOnlineRechargeDlg:MSG_L_CHARGE_DATA(data)
    self:startRequestInfo()
end

return LineUpOnlineRechargeDlg
