-- FightRoundDlg.lua
-- Created by Chang_back Oct/28/2015
-- 战斗回合数
local NumImg = require('ctrl/NumImg')
local FightRoundDlg = Singleton("FightRoundDlg", Dialog)

function FightRoundDlg:init()
    self:setFullScreen()

    self:bindListener("SignalTouchPanel", self.onSignalButton)
    self:bindListener("RecordButton", self.onFightRecordButton)

    if FightCmdRecordMgr:getRecordGuideFlag() then
        gf:createArmatureMagic(ResMgr.ArmatureMagic.fight_record_guide,
            self:getControl("RecordButton"), Const.ARMATURE_MAGIC_TAG)
    end

    self:setCtrlVisible("RecordButton", not Me:isLookOn() and FightCmdRecordMgr:isRecordMagicOpen())

    self.signalImages =  {
        self:getControl("SignalImage_1", nil, "SignalPanel_0"),
        self:getControl("SignalImage_2", nil, "SignalPanel"),
        self:getControl("SignalImage_3", nil, "SignalPanel"),
        self:getControl("SignalImage_4", nil, "SignalPanel"),
    }
    self:refreshSignalColor()

    self:onRefresh()
    schedule(self.root, function() self:onRefresh() end, 1)

    self:setCtrlVisible("TimeLabel_3", false)
    self:setCtrlVisible("TimeLabel_4", false)
end

function FightRoundDlg:isPlayFight()
    if not self.numImg:isVisible() and not self.waitImg:isVisible() then
        return true
    end

    return false
end

-- 更新电池状态
function FightRoundDlg:updateBattery(rawlevel, scale, status, health)
    local level;
    if rawlevel >= 0 and scale > 0 then
        level = (rawlevel * 100) / scale;
    end

    local batterProcessBar = self:getControl("ProgressBar")
    local chargeImage = self:getControl("ChargeImage")

    if BATTERY_STATE.OVERHEAT == health then
        -- gf:ShowSmallTips("电池过热！")
    else
        if BATTERY_STATE.UNKNOWN == status then
            -- gf:ShowSmallTips("这神器没有电池！")
            batterProcessBar:setVisible(false)
            chargeImage:setVisible(false)
        elseif BATTERY_STATE.CHARGING == status then
            -- 充电状态
            batterProcessBar:setVisible(false)
            chargeImage:setVisible(true)
        elseif BATTERY_STATE.DISCHARGING == status
            or BATTERY_STATE.NOT_DISCHARGING == status then
            -- 更新电池状态即可
            batterProcessBar:setVisible(true)
            chargeImage:setVisible(false)
        elseif BATTERY_STATE.FULL == status then
            -- 充满了
            batterProcessBar:setVisible(false)
            chargeImage:setVisible(true)
        end
    end

    -- 更新电池状态
    batterProcessBar:setPercent(level)
end

-- 更新网络状态
function FightRoundDlg:updateNetwork(networkState)

    if not networkState then return end

    if NET_TYPE.WIFI ~= networkState then
        self:setCtrlVisible("SignalPanel", false)
        self:setCtrlVisible("SignalPanel_0", true)
        return
    end

    self:setCtrlVisible("SignalPanel", true)
    self:setCtrlVisible("SignalPanel_0", false)
end

-- 更新wifi状态
-- 0 - -50信号最好， -50 - -70信号差点， 小于 -70 的信号最差
function FightRoundDlg:updateWifiStatus(wifiState, level)
    local levelStatus
    if level < -70 then
        levelStatus = 1
    elseif level < -50 then
        levelStatus = 2
    else
        levelStatus = 3
    end

    self:updateWifiUI(levelStatus)
end


function FightRoundDlg:updateWifiUI(levelStatus)
    local wifiLevelImg = {
        [1] = "SignalImage_2",
        [2] = "SignalImage_3",
        [3] = "SignalImage_4",
    }

    for k, v in pairs(wifiLevelImg) do
        self:setCtrlVisible(v, false)
    end

    self:setCtrlVisible(wifiLevelImg[levelStatus], true)
end

function FightRoundDlg:onRefresh()
    self:updateTime()

    -- 更新电池状态
    local batteryInfo = BatteryAndWifiMgr:getBatteryInfo()

    if batteryInfo then
        self:updateBattery(batteryInfo.rawlevel, batteryInfo.scale, batteryInfo.status, batteryInfo.health)
    end

    -- 更新网络状态
    local networkState = BatteryAndWifiMgr:getNetworkState()

    if networkState then
        self:updateNetwork(networkState)

        -- 是wifi,更新wifi强度
        local wifiInfo = BatteryAndWifiMgr:getWifiInfo()
        if NET_TYPE.WIFI == networkState and wifiInfo then
            FightRoundDlg:updateWifiStatus(wifiInfo.wifiState, wifiInfo.level)
        end
    end

    self:refreshSignalColor()
end

function FightRoundDlg:updateTime()
    local curTime = os.date("%H:%M")
    self:setLabelText("TimeLabel_1", curTime)
    self:setLabelText("TimeLabel_2", curTime)
end

function FightRoundDlg:refreshSignalColor()
    if not self.signalImages or #self.signalImages <= 0 then return end

    local delay = Client:getLastDelayTime()
    local color
    if delay < 500 then
        color = SIGNAL_COLOR.WHITE
    else
        color = SIGNAL_COLOR.RED
    end

    local singleImage
    for i = 1, #self.signalImages do
        singleImage = self.signalImages[i]
        singleImage:setColor(color)
    end
end

function FightRoundDlg:setCurRound(round)
    local roundPanel = self:getControl("NumPanel", Const.UIPanel)
    roundPanel:removeAllChildren()

    local numImg = NumImg.new('sfight_num', round, false, -2)
    numImg:setScale(1)
    numImg:setAnchorPoint(0.5, 0.5)
    numImg:setPosition(roundPanel:getContentSize().width / 2, roundPanel:getContentSize().height / 2)

    roundPanel:addChild(numImg)
end

-- 显示延时
function FightRoundDlg:onSignalButton(sender, eventType)
    self:refreshSignalColor()
    local delay = Client:getLastDelayTime()
    if delay > 5000 then
        gf:showTipInfo(string.format("%s%s%sms#n", CHS[2000125], "#cF22800", "5000+"), sender)
    elseif delay < 200 then
        gf:showTipInfo(string.format("%s%s%sms#n", CHS[2000125], "#c30E50B", tostring(delay)), sender)
    elseif delay >= 200 and delay <= 500 then
        gf:showTipInfo(string.format("%s%s%sms#n", CHS[2000125], "#cF2DF0C", tostring(delay)), sender)
    else
        gf:showTipInfo(string.format("%s%s%sms#n", CHS[2000125], "#cF22800", tostring(delay)), sender)
    end
end

-- 战斗记录
function FightRoundDlg:onFightRecordButton(sender, eventType)
    -- 尝试移除环绕光效
    if sender:getChildByTag(Const.ARMATURE_MAGIC_TAG) then
        sender:removeChildByTag(Const.ARMATURE_MAGIC_TAG)

        FightCmdRecordMgr:setRecordGuideFlag(false)
    end

    DlgMgr:openDlg("FightRecordDlg")
end

return FightRoundDlg
