-- WatchCentreBattleInterfaceDlg.lua
-- Created by songcw Feb/14/2017
-- 观看录像操作界面

local WatchCentreBattleInterfaceDlg = Singleton("WatchCentreBattleInterfaceDlg", Dialog)

local BARRAGE_LEN = 20 * 2

function WatchCentreBattleInterfaceDlg:init()
    self:bindListener("ExitButton", self.onExitButton)
    self:bindListener("NextRoundButton", self.onNextRoundButton)
    self:bindListener("PlayButton", self.onPlayButton)
    self:bindListener("SuspendButton", self.onSuspendButton)
    self:bindListener("LastRoundButton", self.onLastRoundButton)
    self:bindListener("InstallButton", self.onInstallButton)
    self:bindListener("InputBarrageButton", self.onInputBarrageButton)
    self:bindListener("BarrageButton", self.onBarrageButton)
    self:bindListener("InstallCheckBox1", self.onCheckBox)
    self:bindListener("SendButton", self.onSendButton)
    self:bindListener("CleanFieldButton", self.onCleanFieldButton)

    self:bindListener("BarrageOpenButton", self.onBarrageOpenButton)
    self:bindListener("BarrageCloseButton", self.onBarrageCloseButton)
    self:bindListener("SpeedButton1", self.onSpeedButton1)
    self:bindListener("SpeedButton2", self.onSpeedButton2)
    self:bindListener("SpeedButton5", self.onSpeedButton5)

    self:setFullScreen()

    self:setPlayState(WatchRecordMgr:isPause())

    if InventoryMgr.UseLimitItemDlgs[self.name] == 1 then
        self:setCheck("InstallCheckBox1", true)
        WatchRecordMgr:setSkipReady(true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 0 then
        self:setCheck("InstallCheckBox1", false)
        WatchRecordMgr:setSkipReady(false)
    end

    self:setCtrlVisible("CleanFieldButton", false)
    self:bindFloatPanelListener("InstallPanel", "InstallButton")

   -- self:bindEditFieldForSafe("WordPanel", BARRAGE_LEN, "CleanFieldButton")
   self:bindEditBoxInPanel()

    self:setCtrlVisible("BarragePanel", false)
    self:setCtrlVisible("PlayButton", false)
    self:setCtrlVisible("NextRoundButton", false)
    self:setCtrlVisible("SuspendButton", true)

    self:setCtrlVisible("SpeedButton1", true)
    self:setCtrlVisible("SpeedButton2", false)
    self:setCtrlVisible("SpeedButton5", false)

    -- 是否隐藏弹幕
    self:barrageBtnState()

    -- 如果是直播，隐藏相关按钮
    local data = WatchCenterMgr:getCombatData()
    if data and data.isNow then
        self:setFightingDisplay()
    end

    -- 创建弹幕层
    BarrageTalkMgr:creatBarrageLayer()

    self:hookMsg("MSG_SET_SETTING")
end

function WatchCentreBattleInterfaceDlg:cleanup()
    cc.Director:getInstance():getScheduler():setTimeScale(1)
end

-- 绑定发送消息弹幕panel
function WatchCentreBattleInterfaceDlg:bindEditBoxInPanel()
    self.newNameEdit = self:createEditBox("WordPanel", nil, nil, function(sender, type)
        if type == "end" then

        elseif type == "changed" then
            local newName = self.newNameEdit:getText()
            -- 若输入内容为空，则将按钮置灰；若不为空，使按钮可用。
            if newName == "" then
                self:setCtrlVisible("CleanFieldButton", false)
            else
                self:setCtrlVisible("CleanFieldButton", true)
            end

            if gf:getTextLength(newName) > BARRAGE_LEN then
                gf:ShowSmallTips(CHS[4000224])
                newName = gf:subString(newName, BARRAGE_LEN)
                self.newNameEdit:setText(newName)
            end
        end
    end)
    self.newNameEdit:setPlaceholderFont(CHS[3003794], 23)
    self.newNameEdit:setFont(CHS[3003794], 23)
    self.newNameEdit:setPlaceHolder("点击输入弹幕内容")
    self.newNameEdit:setPlaceholderFontColor(COLOR3.GRAY)
    self.newNameEdit:setFontColor(COLOR3.BROWN)
end

function WatchCentreBattleInterfaceDlg:barrageBtnState()
    -- 是否隐藏弹幕
    if not WatchCenterMgr:canShowShareAndBarrage() or MingrzbjcMgr.isReadyToVideo then
        self:setCtrlVisible("BarrageOpenButton", false)
        self:setCtrlVisible("BarrageCloseButton", false)
        self:setCtrlVisible("InputBarrageButton", false)
        if MingrzbjcMgr.isReadyToVideo then MingrzbjcMgr.isReadyToVideo = false end
    else
        self:setCtrlVisible("BarrageOpenButton", SystemSettingMgr:getSettingStatus("refuse_lookon_msg", 1) == 0)
        self:setCtrlVisible("BarrageCloseButton", SystemSettingMgr:getSettingStatus("refuse_lookon_msg", 1) == 1)
    end
end

-- 设置直播节目
function WatchCentreBattleInterfaceDlg:setFightingDisplay()
    self:setCtrlVisible("InstallButton", false)
    self:setCtrlVisible("NextRoundButton", false)
    self:setCtrlVisible("LastRoundButton", false)
    self:setCtrlVisible("SuspendButton", false)
    self:setCtrlVisible("PlayButton", false)

    self:setCtrlVisible("SpeedButton1", false)
    self:setCtrlVisible("SpeedButton2", false)
    self:setCtrlVisible("SpeedButton5", false)
end

-- 根据是否暂停，显示 暂停or播放
function WatchCentreBattleInterfaceDlg:setPlayState(isPause)
    self:setCtrlVisible("SuspendButton", not isPause)
    self:setCtrlVisible("PlayButton", isPause)
end

function WatchCentreBattleInterfaceDlg:onCheckBox(sender, eventType)
    if sender:getSelectedState() then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
    end
    gf:ShowSmallTips(CHS[4100446])
    WatchRecordMgr:setSkipReady(sender:getSelectedState())
end

function WatchCentreBattleInterfaceDlg:onExitButton(sender, eventType)
    local msg = {MSG = 2557, flag = 0}
    MessageMgr:pushMsg(msg)

    WatchCenterMgr:quitLookOnWatchCombat()
    WatchRecordMgr:cleanData()
    WatchCenterMgr:MSG_LOOKON_BROADCAST_COMBAT_STATUS({combat_id = ""})
    self:onCloseButton()
end

function WatchCentreBattleInterfaceDlg:onNextRoundButton(sender, eventType)
 --   WatchRecordMgr:gotoNextRound()
end

function WatchCentreBattleInterfaceDlg:onPlayButton(sender, eventType)
    WatchRecordMgr:setPause(false)
    self:setPlayState(WatchRecordMgr:isPause())
end

function WatchCentreBattleInterfaceDlg:onSuspendButton(sender, eventType)
    WatchRecordMgr:setPause(true)
    self:setPlayState(WatchRecordMgr:isPause())
end

function WatchCentreBattleInterfaceDlg:onLastRoundButton(sender, eventType)
 --  WatchRecordMgr:gotoLastRound()
--    WatchRecordMgr:gotoLastRoundForTest()
end

function WatchCentreBattleInterfaceDlg:onInstallButton(sender, eventType)
    local isVisible = self:getCtrlVisible("InstallPanel")
    self:setCtrlVisible("InstallPanel", not isVisible)
end

function WatchCentreBattleInterfaceDlg:onInputBarrageButton(sender, eventType)
    local isVisible = self:getCtrlVisible("BarragePanel")
    self:setCtrlVisible("BarragePanel", not isVisible)
end

function WatchCentreBattleInterfaceDlg:onBarrageButton(sender, eventType)
end

function WatchCentreBattleInterfaceDlg:onSendButton(sender, eventType)
    local combatId
    local interval_tick

    local data = WatchCenterMgr:getCombatData()
    if not data then
        self:onCloseButton()
        return
    end

    combatId = data.combat_id
    if data.isNow then
        -- 直播
        interval_tick = (gf:getServerTime() - data.start_time) * 1000
    else
        -- 录像
        interval_tick = WatchRecordMgr:getCurReocrdCombatTime()
    end
    local msg = self.newNameEdit:getText()
    if not combatId or interval_tick == 0 or msg == "" then return end

    if BarrageTalkMgr:sendBarrageMessage(combatId, interval_tick, msg) then
        -- 发送成功，清空
        self:onCleanFieldButton(self:getControl("CleanFieldButton"))
        self:setCtrlVisible("BarragePanel", false)
    end
end

function WatchCentreBattleInterfaceDlg:onSpeedButton1(sender, eventType)
    cc.Director:getInstance():getScheduler():setTimeScale(2)

    self:setCtrlVisible("SpeedButton1", false)
    self:setCtrlVisible("SpeedButton2", true)
    self:setCtrlVisible("SpeedButton5", false)
end

function WatchCentreBattleInterfaceDlg:onSpeedButton2(sender, eventType)
    cc.Director:getInstance():getScheduler():setTimeScale(5)

    self:setCtrlVisible("SpeedButton1", false)
    self:setCtrlVisible("SpeedButton2", false)
    self:setCtrlVisible("SpeedButton5", true)
end

function WatchCentreBattleInterfaceDlg:onSpeedButton5(sender, eventType)
    cc.Director:getInstance():getScheduler():setTimeScale(1)

    self:setCtrlVisible("SpeedButton1", true)
    self:setCtrlVisible("SpeedButton2", false)
    self:setCtrlVisible("SpeedButton5", false)
end

function WatchCentreBattleInterfaceDlg:onBarrageOpenButton(sender, eventType)
    SystemSettingMgr:sendSeting("refuse_lookon_msg", 1)
    BarrageTalkMgr:removeAllBarrages()
end

function WatchCentreBattleInterfaceDlg:onBarrageCloseButton(sender, eventType)
    SystemSettingMgr:sendSeting("refuse_lookon_msg", 0)

    local interval_tick
    local data = WatchCenterMgr:getCombatData()
    if data.isNow then
        -- 直播
        interval_tick = gf:getServerTime() - data.start_time
    else
        -- 录像
        interval_tick = WatchRecordMgr:getCurReocrdCombatTime()
    end

    if not interval_tick or not BarrageTalkMgr:getBarrageData(data.combat_id, interval_tick) then
        BarrageTalkMgr:queryBarrageDataByTime(data.combat_id, interval_tick)
    end
end

function WatchCentreBattleInterfaceDlg:onCleanFieldButton(sender, eventType)
    self.newNameEdit:setText("")
    sender:setVisible(false)

 --   self:setCtrlVisible("DefaultLabel", true, parentPanel)
end

function WatchCentreBattleInterfaceDlg:MSG_SET_SETTING(data)
    if data.setting and data.setting.refuse_lookon_msg then
        if data.setting.refuse_lookon_msg == 0 then
            gf:ShowSmallTips(CHS[4200240])
        else
            gf:ShowSmallTips(CHS[4200241])
        end
    end
end

return WatchCentreBattleInterfaceDlg
