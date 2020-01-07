-- ReserveOnlineRechargeDlg.lua
-- Created by lixh2 Mar/08/2019
-- 预充值活动充值界面

local Bitset = require('core/Bitset')
local ReserveOnlineRechargeDlg = Singleton("ReserveOnlineRechargeDlg", Dialog)
local MAX_GOLD_COIN = 2000000000

local rechargeMoney = {6, 30, 98, 198, 328, 648}
local rechargeGold = {600, 3000, 9800, 19800, 32800, 64800}
local giveGold = {{60, 10}, {300, 60}, {1200, 500}, {2800, 1000}, {6180, 1600}, {12880, 4800}}
local giveNum = {0, 1, 3, 6, 11, 22}

function ReserveOnlineRechargeDlg:getCfgFileName()
    return ResMgr:getDlgCfg("OnlineRechargeDlg")
end

function ReserveOnlineRechargeDlg:init(param)
    self.endTime = param.endTime

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
    self:setCtrlVisible("NotePanel", false)

    local x, y = self.root:getPosition()
    self.root:setPositionX(x + 10)

    self:hookMsg("MSG_L_CHARGE_DATA")
    self:hookMsg("MSG_L_GOLD_COIN_DATA")
    self:hookMsg("MSG_L_START_LOGIN")
    self:hookMsg("MSG_L_CHARGE_LIST")
end

-- 每隔2s请求一次元宝数据
function ReserveOnlineRechargeDlg:startRequestInfo()
    local function update()
        local dlgName = "ReserveRechargeDlg"
        if DlgMgr:isDlgOpened("ReserveRechargeExDlg") then
            dlgName = "ReserveRechargeExDlg"
        end

        DlgMgr:sendMsg(dlgName, "checkCanRequest", function()
            if not DlgMgr:isDlgOpened("ReserveOnlineRechargeDlg") then
                return
            end

            gf:CmdToAAAServer("CMD_L_GET_GOLD_COIN_DATA", {account = Client:getAccount()}, CONNECT_TYPE.LINE_UP)
        end)
    end

    if self.scheduleId then
        self:stopSchedule(self.scheduleId)
        self.scheduleId = nil
    end

    self.scheduleId = self:startSchedule(function()
        update()
    end, 2)
end

function ReserveOnlineRechargeDlg:stopUpdate()
    if self.scheduleId then
        self:stopSchedule(self.scheduleId)
        self.scheduleId = nil
    end
end

function ReserveOnlineRechargeDlg:updateGoldCoin(num)
    if not num then return end

    self.ownGoldCoin = num

    local goldText = gf:getArtFontMoneyDesc(self:getOwnGoldCoin())
    self:setNumImgForPanel("GoldCoinValuePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.CENTER, 21)
end

function ReserveOnlineRechargeDlg:getOwnGoldCoin()
    return self.ownGoldCoin or 0
end

function ReserveOnlineRechargeDlg:setCellInfo(cell, index)
    local cashText = gf:getArtFontMoneyDesc(rechargeGold[index])
    self:setNumImgForPanel("CashValuePanel", ART_FONT_COLOR.DEFAULT, cashText, false, LOCATE_POSITION.CENTER, 23, cell)

    local priceText = gf:getArtFontMoneyDesc(rechargeMoney[index])
    self:setNumImgForPanel("PriceValuePanel2", ART_FONT_COLOR.DEFAULT, priceText, false, LOCATE_POSITION.CENTER, 23, cell)
    self:setNumImgForPanel("PriceValuePanel1", ART_FONT_COLOR.DEFAULT, "$", false, LOCATE_POSITION.MID, 23, cell)
end

function ReserveOnlineRechargeDlg:onBuyButton(sender, eventType)
    local nowTime = gfGetTickCount()
    if self.lastClickTime and nowTime - self.lastClickTime <= 3000 then
        gf:ShowSmallTips(CHS[3003200])
        return
    else
        self.lastClickTime = nowTime
    end

    if self.endTime and gf:getServerTime() > self.endTime then
        -- 活动已结束
        gf:ShowSmallTips(CHS[7150121])
        return
    end

    if self:getOwnGoldCoin() + (rechargeGold[sender:getTag()] or 0) <= MAX_GOLD_COIN then
        local dlgName = "ReserveRechargeDlg"
        if DlgMgr:isDlgOpened("ReserveRechargeExDlg") then
            dlgName = "ReserveRechargeExDlg"
        end

        DlgMgr:sendMsg(dlgName, "checkCanRequest", function()
            if not DlgMgr:isDlgOpened("ReserveOnlineRechargeDlg") then
                return
            end

            gf:CmdToAAAServer("CMD_L_PRECHARGE_CHARGE", {account = Client:getAccount(), charge_type = sender:getTag()}, CONNECT_TYPE.LINE_UP)
        end)
    else
        gf:ShowSmallTips(CHS[3003201])
    end
end

function ReserveOnlineRechargeDlg:setReward(panel, isFirst, index)
    self:setCtrlVisible("TipImage", isFirst, panel)

    local str = gf:getArtFontMoneyDesc(giveGold[index][isFirst and 1 or 2])
    self:setNumImgForPanel("NumPanel1", ART_FONT_COLOR.MALL_NUM, str, false, LOCATE_POSITION.MID, 25, panel, -4)
end

function ReserveOnlineRechargeDlg:MSG_L_CHARGE_DATA(data)
    self:startRequestInfo()
end

function ReserveOnlineRechargeDlg:MSG_L_START_LOGIN(data)
    if data.type == ACCOUNT_TYPE.CHARGE then
        local dlgName = "ReserveRechargeDlg"
        if DlgMgr:isDlgOpened("ReserveRechargeExDlg") then
            dlgName = "ReserveRechargeExDlg"
        end

        DlgMgr:sendMsg(dlgName, "checkCanRequest", function()
            if not DlgMgr:isDlgOpened(dlgName) then
                return
            end

            Client:cmdAccount(0, ACCOUNT_TYPE.CHARGE, CONNECT_TYPE.LINE_UP)
        end)
    end
end

-- 元宝数量变化了，充值成功，关闭本界面
function ReserveOnlineRechargeDlg:MSG_L_GOLD_COIN_DATA(data)
    local newGoldCoin = data.gold_coin + data.gift_gold_coin
    if self:getOwnGoldCoin() < newGoldCoin then
        -- 充值成功了
        self:updateGoldCoin(newGoldCoin)

        if self.scheduleId then
            self:stopSchedule(self.scheduleId)
            self.scheduleId = nil
        end
    end
end

function ReserveOnlineRechargeDlg:MSG_L_CHARGE_LIST(data)
    local info = Bitset.new(data.result)
    for i = 1, 6 do
        local goodsPanel = self:getControl(string.format("GoodsPanel_%d", i))
        self:setReward(goodsPanel, info:isSet(i), i)
    end
end

return ReserveOnlineRechargeDlg
