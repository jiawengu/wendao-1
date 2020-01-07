-- LineUpChangeChannelDlg.lua
-- Created by huangzz Sep/05/2018
-- 更换通道界面 - 登录排队

local LineUpChangeChannelDlg = Singleton("LineUpChangeChannelDlg", Dialog)

local VIP_INFO = {
    [1] = {name = CHS[6000202], price = 3000, flag = ResMgr.ui.lineup_vip_word1, day = 30}, --"位列仙班·月卡",
    [2] = {name = CHS[6000203], price = 9000, flag = ResMgr.ui.lineup_vip_word2, day = 90}, --"位列仙班·季卡",
    [3] = {name = CHS[6000204], price = 36000, flag = ResMgr.ui.lineup_vip_word3, day = 360} --"位列仙班·年卡", 
}

function LineUpChangeChannelDlg:init()
    for i = 1, 3 do
        local panel = self:getControl("VIPPanel_" .. i)
        self:bindListener("ViewButton", self.onViewButton, panel)
        self:bindTouchEndEventListener(panel, self.onSelect)
    end

    self.selectCtrl = nil

    self:updateGoldCoin(0)

    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindListener("HaveTextPanel", self.onHaveTextPanel)
    self:bindListener("HaveCashImage", self.onHaveTextPanel)
    self:bindListener("DiscountButton", self.onDiscountButton)

    self:hookMsg("MSG_L_START_LOGIN")
    self:hookMsg("MSG_L_CHARGE_LIST")
    self:hookMsg("MSG_L_INSIDER_ACT_DATA")
end

function LineUpChangeChannelDlg:updateGoldCoin(num)
    if not num then return end

    self.ownGoldCoin = num

    local goldText = gf:getArtFontMoneyDesc(self.ownGoldCoin)
    self:setNumImgForPanel("HaveTextPanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.CENTER, 21)

    DlgMgr:sendMsg("LineUpOnlineRechargeDlg", "updateGoldCoin", self.ownGoldCoin)
end

function LineUpChangeChannelDlg:getOwnGoldCoin()
    return self.ownGoldCoin or 0
end

function LineUpChangeChannelDlg:setData(data, myInfo)
    local index = 1
    for i = 1, #VIP_INFO do
        local info = VIP_INFO[i]
        if info and data[i] and i > myInfo.indsider_lv then
            local panel = self:getControl("VIPPanel_" .. index)
            panel:setName(info.name)
            panel:setTag(i)

            self:setImage("LevelImage", info.flag, self:getControl("GoodsBackImage", nil, panel))

            self:setLabelText("NameLabel", gf:replaceVipStr(info.name), panel)

             self:setLabelText("ValidTimeLabel", string.format(CHS[4200520], info.day), panel)

            local goldStr = gf:getArtFontMoneyDesc(info.price)
            self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, goldStr, false, LOCATE_POSITION.CENTER, 21, panel)

            -- self:setLabelText("WaitTimeLabel", CHS[5400653] .. self:getTimeStr(data[i].expect_time), panel)
            -- self:setLabelText("SaveTimeLabel", CHS[5400654] .. self:getTimeStr(myInfo.expect_time - data[i].expect_time), panel)

            self:setCtrlVisible("ChosenEffectImage", false, panel)
            
            panel:setVisible(true)
            panel.info = info

            -- 默认选中首个通道
            if (not self.selectCtrl and index == 1) or self.selectCtrl == panel then
                self:onSelect(panel)
            end

            index = index + 1
        end
    end

    for i = index, 3 do
        self:setCtrlVisible("VIPPanel_" .. i, false)
    end
end

-- 显示预计时间
function LineUpChangeChannelDlg:getTimeStr(time)
    -- 排队时间
    local waitTimeStr = ""
    local totalSencods = time

    if totalSencods < 0 then
        waitTimeStr = string.format(CHS[5400655], 0)
    elseif totalSencods < 60 then
        waitTimeStr = CHS[3002907]
    else
        local hours = math.floor(totalSencods / 3600)
        local minute = math.floor((totalSencods % 3600) / 60)
        if hours > 0 then
            waitTimeStr = waitTimeStr .. string.format(CHS[4100093], hours)
            waitTimeStr = waitTimeStr .. string.format(CHS[5400655], minute)
        else
            waitTimeStr = waitTimeStr .. string.format(CHS[5400655], minute)
        end
    end

    return waitTimeStr
end

function LineUpChangeChannelDlg:onViewButton(sender, eventType)
    local tag = sender:getParent():getTag()
    DlgMgr:openDlgEx("LineUpSowVIPRuleDlg", tag)
end

function LineUpChangeChannelDlg:onSelect(sender, eventType)
    if self.selectCtrl == sender then
        return
    end

    self:setCtrlVisible("ChosenEffectImage", false, self.selectCtrl)
    self:setCtrlVisible("ChosenEffectImage", true, sender)

    self.selectCtrl = sender
end

function LineUpChangeChannelDlg:onBuyButton(sender, eventType)
    if not self.selectCtrl then
        gf:ShowSmallTips(CHS[5400656])
        return
    end

    local info = self.selectCtrl.info
    gf:confirm(string.format(CHS[5400657], Client:getWantLoginDistName(), gf:replaceVipStr(info.name)), function()
        if not DlgMgr:isDlgOpened("LineUpChangeChannelDlg") then
            return
        end

        if info.price > self:getOwnGoldCoin() then
            -- 元宝不足
            gf:confirm(CHS[4000359], function()
                DlgMgr:sendMsg("LineUpDlg", "checkCanRequest", function()
                    if not DlgMgr:isDlgOpened("LineUpChangeChannelDlg") then return end
                    
                    gf:CmdToAAAServer("CMD_L_CHARGE_LIST", {account = Client:getAccount()}, CONNECT_TYPE.LINE_UP)
                end)
            end)

            return
        else
            DlgMgr:sendMsg("LineUpDlg", "checkCanRequest", function()
                if not DlgMgr:isDlgOpened("LineUpChangeChannelDlg") then return end

                gf:CmdToAAAServer("CMD_L_START_BUY_INSIDER", {account = Client:getAccount(), type = self.selectCtrl:getTag()}, CONNECT_TYPE.LINE_UP)
            end)
        end
    end)
end

function LineUpChangeChannelDlg:onHaveTextPanel(sender, eventType)
    DlgMgr:sendMsg("LineUpDlg", "checkCanRequest", function()
        if not DlgMgr:isDlgOpened("LineUpChangeChannelDlg") then return end
        
        gf:CmdToAAAServer("CMD_L_CHARGE_LIST", {account = Client:getAccount()}, CONNECT_TYPE.LINE_UP)
    end)
end

function LineUpChangeChannelDlg:onDiscountButton(sender, eventType)
    DlgMgr:sendMsg("LineUpDlg", "checkCanRequest", function()
        if not DlgMgr:isDlgOpened("LineUpChangeChannelDlg") then return end
        
        gf:CmdToAAAServer("CMD_L_GET_INSIDER_ACT", {account = Client:getAccount()}, CONNECT_TYPE.LINE_UP)
    end)
end

function LineUpChangeChannelDlg:onRuleButton(sender, eventType)
    gf:showTipInfo(CHS[5400648], sender)
end

function LineUpChangeChannelDlg:cleanup()
    DlgMgr:closeDlg("LineUpOnlineRechargeDlg")
    DlgMgr:closeDlg("LineUpSowVIPRuleDlg")
end

function LineUpChangeChannelDlg:MSG_L_START_LOGIN(data)
    if data.type == ACCOUNT_TYPE.INSIDER then
        -- 收到购买会员数据
        DlgMgr:sendMsg("LineUpDlg", "checkCanRequest", function()
            if not DlgMgr:isDlgOpened("LineUpChangeChannelDlg") then return end

            Client:cmdAccount(0, ACCOUNT_TYPE.INSIDER, CONNECT_TYPE.LINE_UP)
        end)
    end
end

function LineUpChangeChannelDlg:MSG_L_CHARGE_LIST(data)
    local dlg = DlgMgr:openDlgEx("LineUpOnlineRechargeDlg", {para = data.result})
    dlg:updateGoldCoin(self:getOwnGoldCoin())
end

function LineUpChangeChannelDlg:MSG_L_INSIDER_ACT_DATA(data)
    local dlg = DlgMgr:getDlgByName("LineUpChangeChannelDiscountDlg")
    if not dlg then
        dlg = DlgMgr:openDlg("LineUpChangeChannelDiscountDlg")
        dlg:setInfo(data)
    end
end

return LineUpChangeChannelDlg
