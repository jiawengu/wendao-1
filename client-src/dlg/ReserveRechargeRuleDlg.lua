-- ReserveRechargeRuleDlg.lua
-- Created by lixh2 Mar/08/2019
-- 预充值界面返利介绍界面

local ReserveRechargeRuleDlg = Singleton("ReserveRechargeRuleDlg", Dialog)

local SHOW_FOURTH_REWARD_TIME = "20190425200000"

function ReserveRechargeRuleDlg:init()
    self:bindListener("RechargeButton", self.onRechargeButton)

    self:setCtrlVisible("Label2", false)
    self:setCtrlVisible("Label10", false)
    self:setCtrlVisible("Label4", false)
    self:setCtrlVisible("Label11", false)
    if ShareMgr:isOffice() and gf:getServerDate("%Y%m%d%H%M%S", gf:getServerTime()) > SHOW_FOURTH_REWARD_TIME then
        self:setCtrlVisible("Label10", true)
        self:setCtrlVisible("Label11", true)
    else
        self:setCtrlVisible("Label2", true)
        self:setCtrlVisible("Label4", true)
    end

    self:hookMsg("MSG_L_CHARGE_LIST")
    self:hookMsg("MSG_L_GOLD_COIN_DATA")
end

function ReserveRechargeRuleDlg:setData(data, actData)
    self.dlgData = actData

    -- 当前充值
    local newGoldNum = data.gold_coin + data.gift_gold_coin
    if not self.getGoldNum or self.getGoldNum < newGoldNum then
        self.getGoldNum = newGoldNum
        local goldText = gf:getArtFontMoneyDesc(self.getGoldNum - data.already_return_coin)
        self:setNumImgForPanel("GoldCoinValuePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.MID, 23, "GoldCoinPanel_1")
    end

    -- 预计返利
    local rewardGoinNum = data.precharge_coin
    if actData.rewardType == 2 then
        rewardGoinNum = math.floor(rewardGoinNum * 0.06)
    elseif actData.rewardType == 3 then
        rewardGoinNum = math.floor(rewardGoinNum * 0.1)
    elseif actData.rewardType == 1 then
        rewardGoinNum = math.floor(rewardGoinNum * 0.04)
    elseif actData.rewardType == 4 then
        if gf:getServerDate("%Y%m%d%H%M%S", gf:getServerTime()) > SHOW_FOURTH_REWARD_TIME then
            rewardGoinNum = math.floor(rewardGoinNum * 0.15)
        else
            rewardGoinNum = math.floor(rewardGoinNum * 0.1)
        end
    else
        rewardGoinNum = 0
    end

    if ShareMgr:isOffice() and gf:getServerDate("%Y%m%d%H%M%S", gf:getServerTime()) > SHOW_FOURTH_REWARD_TIME then
        -- 官方返回最大不超过45000
        rewardGoinNum = math.min(45000, rewardGoinNum)
    else
        -- 渠道返回最大不超过30000
        rewardGoinNum = math.min(30000, rewardGoinNum)
    end

    local rewardText = gf:getArtFontMoneyDesc(rewardGoinNum)
    self:setNumImgForPanel("GoldCoinValuePanel", ART_FONT_COLOR.DEFAULT, rewardText, false, LOCATE_POSITION.MID, 23, "GoldCoinPanel_2")
end

function ReserveRechargeRuleDlg:onRechargeButton(sender, eventType)
    if not self.dlgData then
        return
    end

    if gf:getServerTime() > self.dlgData.end_charge_time then
        -- 活动已结束
        gf:ShowSmallTips(CHS[7150120])
        return
    end

    -- 请求充值数据
    local dlgName = "ReserveRechargeDlg"
    if DlgMgr:isDlgOpened("ReserveRechargeExDlg") then
        dlgName = "ReserveRechargeExDlg"
    end

    DlgMgr:sendMsg(dlgName, "checkCanRequest", function()
        if not DlgMgr:isDlgOpened("ReserveRechargeRuleDlg") then
            return
        end

        gf:CmdToAAAServer("CMD_L_CHARGE_LIST", {account = Client:getAccount()}, CONNECT_TYPE.LINE_UP)
    end)
end

function ReserveRechargeRuleDlg:cleanup()
    self.dlgData = nil
    self.getGoldNum = nil
end

function ReserveRechargeRuleDlg:MSG_L_CHARGE_LIST(data)
    local dlg = DlgMgr:getDlgByName("ReserveOnlineRechargeDlg")
    if not dlg then
        dlg = DlgMgr:openDlgEx("ReserveOnlineRechargeDlg", {para = data.result, endTime = self.dlgData.end_charge_time})
        dlg:updateGoldCoin(self.getGoldNum or 0)

        local end_time = Client:getNewDistPreChargeData().end_charge_time
        if end_time - data.server_time < 5 * 60 then
            local m = tonumber(gf:getServerDate("%M", end_time))
            local h = tonumber(gf:getServerDate("%H", end_time))
            gf:ShowSmallTips(string.format( CHS[4200797], h, m))
        end
    end
end

function ReserveRechargeRuleDlg:MSG_L_GOLD_COIN_DATA(data)
    if not self.dlgData then
        return
    end

    self:setData(data, self.dlgData)
end

return ReserveRechargeRuleDlg
