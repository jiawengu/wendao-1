-- ReserveRechargeDlg.lua
-- Created by lixh2 Mar/08/2019
-- 预充值界面

local ReserveRechargeDlg = Singleton("ReserveRechargeDlg", Dialog)

-- 奖励需要的最小热度
local HOT_VALUE_MIN = 15000

-- 奖励需要的热度
local HOT_VALUE_REWARD = 105000

-- 热度的上限
local HOT_VALUE_MAX = 275000

-- 公测热度的上限
local OFFICE_HOT_VALUE_MAX = 1800000

-- 更多精彩
local MORE_CONTENT_URL = "http://activity.leiting.com/wd/201904/welfare/"

-- 公布第4阶段奖励时间
local SHOW_FOURTH_REWARD_TIME = "20190425200000"

-- 进度条长度
local BAR_PROGRESS_LENTH = 726

local EFF_PERCENT1 = math.floor(53 * 100 / 726)
local EFF_PERCENT2 = math.floor(200 * 100 / 726)
local EFF_PERCENT3 = math.floor(408 * 100 / 726)
local EFF_PERCENT4 = math.floor(676 * 100 / 726)

function ReserveRechargeDlg:init()
    self:bindListener("ShareButton", self.onShareButton, "MainPanel")
    self:bindListener("MoreButton", self.onMoreButton, "MainPanel")
    self:bindListener("RechargeButton", self.onRechargeButton, "MainPanel")
    self:bindListener("CommunityButton", self.onCommunityButton, "MainPanel")
    self:bindListener("ShareButton", self.onShareButton, "MainPanel_2")
    self:bindListener("MoreButton", self.onMoreButton, "MainPanel_2")
    self:bindListener("RechargeButton", self.onRechargeButton, "MainPanel_2")
    self:bindListener("CommunityButton", self.onCommunityButton, "MainPanel_2")

    self.temperaturePanel = self:getControl("TemperaturePanel", nil, "MainPanel")
    self.barprogress = self:getControl("TemperatureProgressBar", nil, self.temperaturePanel)
    self.openServicePanel = self:getControl("OpenServicePanel", nil, "MainPanel")
    self.endTimePanel = self:getControl("EndTimePanel", nil, "MainPanel")

    self.lowRewardPanel = self:getControl("InfoPanel_2", nil, "MainPanel")
    self:setImage("CompleteImage", ResMgr.ui.task_unfinish, self.lowRewardPanel)

    self.midRewardPanel = self:getControl("InfoPanel_3", nil, "MainPanel")
    self:setImage("CompleteImage", ResMgr.ui.task_unfinish, self.midRewardPanel)

    self.highRewardPanel = self:getControl("InfoPanel_4", "MainPanel")
    self:setImage("CompleteImage", ResMgr.ui.task_unfinish, self.highRewardPanel)

    DlgMgr:setVisible("LoginChangeDistDlg", false)

    self:setCtrlVisible("MainPanel", false)
    self:setCtrlVisible("MainPanel_2", false)
    self:updateBarByPercent(0)

    self:hookMsg("MSG_AAA_CONNECTED")
    self:hookMsg("MSG_L_GOLD_COIN_DATA")
    self:hookMsg("MSG_L_START_LOGIN")
    self:hookMsg("MSG_L_GET_COMMUNITY_ADDRESS")
end

-- 设置当前热度对应的效果
function ReserveRechargeDlg:updateBarByPercent(percent)
    local root = self:getControl("MainPanel_2")
    local rechargeLabelPanel = self:getControl("RechargePanel", nil, root)
    for i = 1, 10 do
        self:setCtrlVisible("RechargeLabel_" .. i, false, rechargeLabelPanel)
    end

    for i = 1, 4 do
        self:setCtrlVisible("GetImage_" .. i, false, root)
    end

    if percent >= EFF_PERCENT4 and self.dlgData.hot_value >= OFFICE_HOT_VALUE_MAX then
        self:setCtrlVisible("RechargeLabel_1", true, rechargeLabelPanel)
        self:setCtrlVisible("RechargeLabel_3", true, rechargeLabelPanel)
        self:setCtrlVisible("RechargeLabel_5", true, rechargeLabelPanel)
        if gf:getServerDate("%Y%m%d%H%M%S", gf:getServerTime()) > SHOW_FOURTH_REWARD_TIME then
            self:setCtrlVisible("RechargeLabel_8", true, rechargeLabelPanel)
        else
            self:setCtrlVisible("RechargeLabel_10", true, rechargeLabelPanel)
        end

        self:setCtrlVisible("GetImage_1", true, root)
        self:setCtrlVisible("GetImage_2", true, root)
        self:setCtrlVisible("GetImage_3", true, root)
        self:setCtrlVisible("GetImage_4", true, root)
    else
        if gf:getServerDate("%Y%m%d%H%M%S", gf:getServerTime()) > SHOW_FOURTH_REWARD_TIME then
            self:setCtrlVisible("RechargeLabel_7", true, rechargeLabelPanel)
        else
            self:setCtrlVisible("RechargeLabel_9", true, rechargeLabelPanel)
        end

        if percent <= EFF_PERCENT1 then
            -- 没有达到第1阶段奖励
            self:setCtrlVisible("RechargeLabel_1", true, rechargeLabelPanel)
            self:setCtrlVisible("RechargeLabel_3", true, rechargeLabelPanel)
            self:setCtrlVisible("RechargeLabel_5", true, rechargeLabelPanel)
        elseif percent <= EFF_PERCENT2 and self.dlgData.hot_value >= HOT_VALUE_MIN then
            -- 没有达到第2阶段奖励
            self:setCtrlVisible("RechargeLabel_2", true, rechargeLabelPanel)
            self:setCtrlVisible("RechargeLabel_3", true, rechargeLabelPanel)
            self:setCtrlVisible("RechargeLabel_5", true, rechargeLabelPanel)

            self:setCtrlVisible("GetImage_1", true, root)
        elseif percent <= EFF_PERCENT3 and self.dlgData.hot_value >= HOT_VALUE_REWARD then
            -- 没有达到第3阶段奖励
            self:setCtrlVisible("RechargeLabel_1", true, rechargeLabelPanel)
            self:setCtrlVisible("RechargeLabel_4", true, rechargeLabelPanel)
            self:setCtrlVisible("RechargeLabel_5", true, rechargeLabelPanel)

            self:setCtrlVisible("GetImage_1", true, root)
            self:setCtrlVisible("GetImage_2", true, root)
        elseif percent <= EFF_PERCENT4 and self.dlgData.hot_value >= HOT_VALUE_MAX then
            -- 没有达到第4阶段奖励
            self:setCtrlVisible("RechargeLabel_1", true, rechargeLabelPanel)
            self:setCtrlVisible("RechargeLabel_3", true, rechargeLabelPanel)
            self:setCtrlVisible("RechargeLabel_6", true, rechargeLabelPanel)

            self:setCtrlVisible("GetImage_1", true, root)
            self:setCtrlVisible("GetImage_2", true, root)
            self:setCtrlVisible("GetImage_3", true, root)
        end
    end

    local barProgress = self:getControl("TemperatureProgressBar", nil, root)
    barProgress:setPercent(percent)

    local posEffX = percent * BAR_PROGRESS_LENTH / 100
    if self.barprogressMagic then
        self.barprogressMagic:setPositionX(posEffX + 2)
    end

    if (percent == EFF_PERCENT1 and self.dlgData.hot_value >= HOT_VALUE_MIN)
        or (percent == EFF_PERCENT2 and self.dlgData.hot_value >= HOT_VALUE_REWARD)
        or (percent == EFF_PERCENT3 and self.dlgData.hot_value >= HOT_VALUE_MAX)
        or (percent == EFF_PERCENT4 and self.dlgData.hot_value >= OFFICE_HOT_VALUE_MAX) then
        self:createEffectMagic(posEffX)
    end
end

-- 创建到达进度特效
function ReserveRechargeDlg:createEffectMagic(posX)
    local effPanel = self:getControl("EffectPanel_1", nil, "MainPanel_2")
    local magic = gf:createSelfRemoveMagic(ResMgr.magic.reserve_charge_get_percent, nil, {blendMode = "add"})
    effPanel:addChild(magic)
    magic:setPosition(posX - 75, 155)
end

-- 创建进度特效
function ReserveRechargeDlg:createBarMagic()
    local barPanel = self:getControl("ProgressBarPanel", nil, "MainPanel_2")
    self.barprogressMagic = gf:createLoopMagic(ResMgr.magic.reserve_charge_bar, nil, {blendMode = "add"})
    barPanel:addChild(self.barprogressMagic)
    self.barprogressMagic:setPosition(0, 15)
end

function ReserveRechargeDlg:setOfficialPanel(root, data)
    -- 当前热度
    self:setLabelText("TemperatureLabel_2", data.hot_value, root)

    -- 创建进度特效
    self:createBarMagic()

    -- 预约活动奖励详情
    local infoPanel5 = self:getControl("InfoPanel_5", nil, root)
    local infoPanel6 = self:getControl("InfoPanel_6", nil, root)
    self:setCtrlVisible("InfoLabel_2", false, infoPanel5)
    self:setCtrlVisible("InfoLabel_3", false, infoPanel5)
    self:setCtrlVisible("InfoLabel_1", false, infoPanel6)
    self:setCtrlVisible("InfoLabel_2", false, infoPanel6)
    if gf:getServerDate("%Y%m%d%H%M%S", gf:getServerTime()) > SHOW_FOURTH_REWARD_TIME then
        self:setCtrlVisible("InfoLabel_3", true, infoPanel5)
        self:setCtrlVisible("InfoLabel_2", true, infoPanel6)
    else
        self:setCtrlVisible("InfoLabel_2", true, infoPanel5)
        self:setCtrlVisible("InfoLabel_1", true, infoPanel6)
    end

    -- 计算热度像素值
    local LEHTH_CFG = {0, 53, 200, 408, 676, 726}
    local lenth = 0
    if data.hot_value >= 3000000 then
        lenth = 726
        self.dlgData.rewardType = 4
    elseif data.hot_value >= OFFICE_HOT_VALUE_MAX then
        lenth = 676 + math.floor((data.hot_value - OFFICE_HOT_VALUE_MAX) / (3000000 - OFFICE_HOT_VALUE_MAX) * (726 - 676))
        self.dlgData.rewardType = 4
    elseif data.hot_value >= HOT_VALUE_MAX then
        lenth = 408 + math.floor((data.hot_value - HOT_VALUE_MAX) / (OFFICE_HOT_VALUE_MAX - HOT_VALUE_MAX) * (676 - 408))
        self.dlgData.rewardType = 3
    elseif data.hot_value >= HOT_VALUE_REWARD then
        lenth = 200 + math.floor((data.hot_value - HOT_VALUE_REWARD) / (HOT_VALUE_MAX - HOT_VALUE_REWARD) * (408 - 200))
        self.dlgData.rewardType = 2
    elseif data.hot_value >= HOT_VALUE_MIN then
        lenth = 53 + math.floor((data.hot_value - HOT_VALUE_MIN) / (HOT_VALUE_REWARD - HOT_VALUE_MIN) * (200 - 53))
        self.dlgData.rewardType = 1
    else
        lenth = math.floor((data.hot_value / HOT_VALUE_MIN) * 53)
        self.dlgData.rewardType = 0
    end

    -- 启动定时器更新进度条
    local maxPercent = math.floor(lenth * 100 / 726)
    if maxPercent > 0 then
        local curPercent = 0
        self.sheduleId = self:startSchedule(function()
            if curPercent > maxPercent then
                self:clearSchedule()
            else
                curPercent = curPercent + 1
                self:updateBarByPercent(curPercent)
            end
        end, 0.05)
    end
end

function ReserveRechargeDlg:clearSchedule()
    if self.sheduleId then
        self:stopSchedule(self.sheduleId)
        self.sheduleId = nil
    end
end

function ReserveRechargeDlg:cleanup()
    self.dlgData = nil
    self:clearSchedule()
    self.barprogressMagic = nil
end

function ReserveRechargeDlg:setData(data)
    self.dlgData = data

    local mainRoot = self:getControl("MainPanel")
    if data.isOffical == 1 and data.hot_value >= HOT_VALUE_MAX then
        -- 官方渠道
        mainRoot = self:getControl("MainPanel_2")
        mainRoot:setVisible(true)
        self:setOfficialPanel(mainRoot, data)
        return
    else
        mainRoot:setVisible(true)
    end

    -- 热度
    self:setLabelText("TemperatureLabel_2", data.hot_value, self.temperaturePanel)

    local toPercentHotValue =  data.hot_value
    if toPercentHotValue > HOT_VALUE_MAX then
        toPercentHotValue = HOT_VALUE_MAX
    end

    -- 热度百分比
    self.barprogress:setPercent(math.floor(toPercentHotValue / HOT_VALUE_MAX * 100))

    -- 开服时间
    local openTimeStr = gf:getServerDate(CHS[7150119], data.start_server_time)
    self:setLabelText("OpenServiceLabel_2", openTimeStr, self.openServicePanel)

    -- 活动结束时间
    local endTimeStr = gf:getServerDate(CHS[7150119], data.end_charge_time)
    self:setLabelText("EndTimeLabel_2", endTimeStr, self.endTimePanel)

    -- 活动达标情况
    self.dlgData.rewardType = 0
    if data.hot_value >= HOT_VALUE_MIN then
        self.dlgData.rewardType = 1
        self:setImage("CompleteImage", ResMgr.ui.finish_target, self.lowRewardPanel)

        if data.hot_value >= HOT_VALUE_REWARD then
            self.dlgData.rewardType = 2
            self:setImage("CompleteImage", ResMgr.ui.finish_target, self.midRewardPanel)

            if data.hot_value >= HOT_VALUE_MAX then
                self.dlgData.rewardType = 3
                self:setImage("CompleteImage", ResMgr.ui.finish_target, self.highRewardPanel)
            end
        end
    end
end

-- 请求连接上AAA
function ReserveRechargeDlg:checkCanRequest(callback)
    self.callback = callback

    DlgMgr:closeDlg("WaitDlg")

    local aaa = DistMgr:getDistInfoByName(Client:getWantLoginDistName())["aaa"]
    Client:connetAAA(aaa, nil, nil, CONNECT_TYPE.LINE_UP)
end

-- 连接上AAA
function ReserveRechargeDlg:MSG_AAA_CONNECTED(map)
    if map.result and map.connect_type == CONNECT_TYPE.LINE_UP then
        if self.callback then
            self.callback()
            self.callback = nil
        end
    end
end

-- 收到预充值数据
function ReserveRechargeDlg:MSG_L_GOLD_COIN_DATA(data)
    local dlg = DlgMgr:getDlgByName("ReserveRechargeRuleDlg")
    if not dlg then
        local dlg = DlgMgr:openDlg("ReserveRechargeRuleDlg")
        dlg:setData(data, self.dlgData)
    end
end

-- 预充值
function ReserveRechargeDlg:onRechargeButton(sender, eventType)
    if not self.dlgData then
        return
    end

    if gf:getServerTime() > self.dlgData.end_charge_time then
        -- 活动已结束
        gf:ShowSmallTips(CHS[7150120])
        return
    end

    self:checkCanRequest(function()
        gf:CmdToAAAServer("CMD_L_GET_GOLD_COIN_DATA", {account = Client:getAccount()}, CONNECT_TYPE.LINE_UP)
    end)
end

-- 分享图片
function ReserveRechargeDlg:onShareButton(sender, eventType)
    if ShareMgr:isOffice() then
        ShareMgr:sharePic(ResMgr.ui.reserver_charge_share_official)
    else
        ShareMgr:sharePic(ResMgr.ui.reserver_charge_share_unOfficial)
    end

    -- 通知服务器记录分享日志
    self:checkCanRequest(function()
        gf:CmdToAAAServer("CMD_L_PRECHARGE_PRESS_BTN", {account = Client:getAccount(), type = 1}, CONNECT_TYPE.LINE_UP)
    end)
end

-- 更多精彩
function ReserveRechargeDlg:onMoreButton(sender, eventType)
    gf:confirm(CHS[7150122], function()
        DeviceMgr:openUrl(MORE_CONTENT_URL)

        -- 通知服务器记录前往官网日志
        self:checkCanRequest(function()
            gf:CmdToAAAServer("CMD_L_PRECHARGE_PRESS_BTN", {account = Client:getAccount(), type = 2}, CONNECT_TYPE.LINE_UP)
        end)
    end)
end

-- 社区
function ReserveRechargeDlg:onCommunityButton(sender, eventType)
    if not CommunityMgr:getCommunityURL() then
        self:checkCanRequest(function()
            if not CommunityMgr:getCommunityURL() then
                gf:CmdToAAAServer("CMD_L_GET_COMMUNITY_ADDRESS", {account = Client:getAccount()}, CONNECT_TYPE.LINE_UP)
            end
        end)
    else
        CommunityMgr:setLastAcesss(nil, 0)
        DlgMgr:openDlgEx("CommunityDlg", {"visitor=yes"})
    end
end

-- 微社区url数据
function ReserveRechargeDlg:MSG_L_GET_COMMUNITY_ADDRESS()
    if not CommunityMgr:getCommunityURL() then
        gf:ShowSmallTips(CHS[5410319])
        return
    end

    CommunityMgr:setLastAcesss(nil, 0)
    DlgMgr:openDlgEx("CommunityDlg", {"visitor=yes"})
end

-- 走一遍登陆流程
function ReserveRechargeDlg:MSG_L_START_LOGIN(data)
    if data.type == ACCOUNT_TYPE.GETCOIN then
        self:checkCanRequest(function()
            if not DlgMgr:isDlgOpened("ReserveRechargeDlg") and not DlgMgr:isDlgOpened("ReserveRechargeExDlg") then
                return
            end

            Client:cmdAccount(0, ACCOUNT_TYPE.GETCOIN, CONNECT_TYPE.LINE_UP)
        end)
    end
end

function ReserveRechargeDlg:onCloseButton(sender, eventType)
    if not DlgMgr:isDlgOpened("LoginChangeDistDlg") then
        DlgMgr:setVisible("UserLoginDlg", true)
    else
        DlgMgr:setVisible("LoginChangeDistDlg", true)
    end

    DlgMgr:closeDlg("WaitDlg")
    DlgMgr:closeDlg("CreateCharDlg")
    DlgMgr:closeDlg(self.name)
end

return ReserveRechargeDlg
