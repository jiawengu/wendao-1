-- ScreenRecordingDlg.lua
-- Created by sujl

local ScreenRecordingDlg = Singleton("ScreenRecordingDlg", Dialog)

RecordingState = {
    NotRecord = 0,            -- 不处在录像中
    StartRecording = 1,       -- 开始录制中
    Recording = 2,            -- 录像中
    SilenceRecording = 3,     -- 录像中
    StopRecording = 4,        -- 停止录像中
    Fade = 5
}

local ANDROID_STOP_INTERVAL = 2 -- Android停止录屏时距开始录屏的时间间隔

function ScreenRecordingDlg:init()
    self:setFullScreen()
    --self:bindListener("RecordingButton", self.onRecordingButton)
    self.recordingBtn = self:getControl("RecordingButton")
    self.normalRecordImage = self:getControl("RecordingImage1")
    self.transparentRecordImage = self:getControl("RecordingImage2")
    self.redDot = self:getControl("RedDotImage1")
    self.timePanel = self:getControl("TimePanel")
    self.normalTimeLabel = self:getControl("TimeLabel1")
    self.transparentLabel = self:getControl("TimeLabel2")
    self.recordState = RecordingState.NotRecord
    self.panel = self:getControl("RecordingPanel")
    self.recordTime = 0
    --[[
    self:bindDragListener(self.recordingBtn, function(x, y)
        local posX, posY = self.panel:getPosition()
        self.panel:setPosition(cc.p(posX + x, posY + y))
    end, self.onRecordingButton)
    --]]
    local winSize = self:getWinSize()
    self.rootWidth = winSize.width / Const.UI_SCALE
    self.rootHeight = winSize.height / Const.UI_SCALE

    local panelSize = self.panel:getContentSize()

    self:bindDragListener(self.panel, function(x, y)
        local posX, posY = self.panel:getPosition()
        posX = math.max(math.min(posX + x, self.rootWidth - panelSize.width), 0)
        posY = math.max(math.min(posY + y, self.rootHeight - panelSize.height), 0)

        self.panel:setPosition(cc.p(posX, posY))
    end, self.onRecordingButton)

    self.updateId = -1

    -- 更新外观
    self:updateFade()

    -- 设置层级
    self.blank:setLocalZOrder(Const.ZORDER_SCREEN_RECORD)

    EventDispatcher:addEventListener("ENTER_BACKGROUND", self.onEnterBackground, self)
end

function ScreenRecordingDlg:setVisible(visible)
    if DlgMgr:isDlgOpened("WaitDlg") then
        Dialog.setVisible(self, false)
    else
        Dialog.setVisible(self, visible)
    end
end

function ScreenRecordingDlg:bindDragListener(widget, func, click)
    if type(widget) ~= "userdata" then
        return
    end

    if not widget then
        Log:W("Dialog:ScreenRecordingDlg no control " .. self.name)
        return
    end

    local lastTouchPos
    local moveDis = 0
    local function listener(sender, eventType)
        self.lastOperTime = gf:getServerTime()
        if RecordingState.SilenceRecording == self.recordState or RecordingState.Fade == self.recordState then
            self.recordState = RecordingState.Recording;
            self.normalRecordImage:stopAllActions()
            self.transparentRecordImage:stopAllActions()
        end
        self:updateFade()
        if eventType == ccui.TouchEventType.began then
            lastTouchPos = GameMgr.curTouchPos
            moveDis = 0
        elseif eventType == ccui.TouchEventType.ended then
            if not self:playExtraSound(sender) then
                SoundMgr:playEffect("button")
            end

            if click and moveDis <= 5 then 
                click(self, sender, eventType)
            end
        elseif eventType == ccui.TouchEventType.moved then
            local touchPos = GameMgr.curTouchPos
            local offsetX, offsetY = touchPos.x - lastTouchPos.x, touchPos.y - lastTouchPos.y
            
            if moveDis <= 5 then 
                moveDis = moveDis + gf:distance(touchPos.x, touchPos.y, lastTouchPos.x, lastTouchPos.y)
            end

            if func and moveDis > 5 then 
                func(offsetX, offsetY)
            end

            lastTouchPos = touchPos
        end
    end

    widget:addTouchEventListener(listener)
end

function ScreenRecordingDlg:cleanup()
    if -1 ~= self.updateId then
        gf:Unschedule(self.updateId)
    end

    EventDispatcher:removeEventListener("ENTER_BACKGROUND", self.onEnterBackground, self)
end

-- 点击录像按钮
function ScreenRecordingDlg:onRecordingButton(sender, eventType)

    if not ScreenRecordMgr:supportRecordScreen() then
        gf:ShowSmallTips(CHS[3003607])
        return
    end

    if RecordingState.StartRecording == self.recordState then
        gf:ShowSmallTips(CHS[3003608])
        return
    elseif RecordingState.StopRecording == self.recordState then
        gf:ShowSmallTips(CHS[3003609])
        return
    end

    if ScreenRecordMgr:isRecording() then
        if gf:isAndroid() and self.recordTime and gf:getServerTime() - self.recordTime < ANDROID_STOP_INTERVAL then
            gf:ShowSmallTips(CHS[2200127])
            return
        end

        ScreenRecordMgr:stopRecord()
        self.recordState = RecordingState.StopRecording

        if gf:isWindows() then
            self:onStopRecord()
        end
    else
        ScreenRecordMgr:startRecord()
        self.recordState = RecordingState.StartRecording

        if gf:isWindows() then
            self:onStartRecord(true)
        end
    end
end

function ScreenRecordingDlg:onEnterBackground(sender, eventType)
    if gf:isAndroid() and ScreenRecordMgr:isRecording() then
        self:onRecordingButton()
        self:onStopRecord()
    end
end

-- 开始录像
function ScreenRecordingDlg:onStartRecord(isOn)
    if not isOn then
        self.recordState = RecordingState.NotRecord
        return
    end

    self.recordState = RecordingState.Recording
    if -1 == self.updateId then
        self.updateId = gf:Schedule(function() ScreenRecordingDlg:updateRecordTime() end, 1)
    end

    self.recordTime = gf:getServerTime()
    self.redDot:setVisible(true)
    self:updateFade()
    gf:ShowSmallTips(CHS[3003610])
end

-- 停止录像
function ScreenRecordingDlg:onStopRecord(msg)
    if -1 ~= self.updateId then
        gf:Unschedule(self.updateId)
        self.updateId = -1
    end
    self.recordState = RecordingState.NotRecord
    self:updateFade()
    if string.isNilOrEmpty(msg) then
        local data = {}
        data.start_time = self.recordTime
        data.duration = gf:getServerTime() - self.recordTime
        gf:CmdToServer("CMD_SCREEN_RECORD_END", data)
        gf:ShowSmallTips(CHS[3003611])
    else
        gf:ShowSmallTips(CHS[2200128])
        gf:ftpUploadEx(string.format("Failed to stop record. msg:%s", msg))
    end
end

-- 更新外观
function ScreenRecordingDlg:updateFade()
    if self.recordingBtn then
        self.recordingBtn:setVisible(RecordingState.NotRecord == self.recordState or RecordingState.StartRecording == self.recordState)
    end

    if self.normalRecordImage then
        self.normalRecordImage:setVisible(RecordingState.Recording == self.recordState or RecordingState.StopRecording == self.recordState)
        if RecordingState.Recording == self.recordState or RecordingState.StopRecording == self.recordState then
            self.normalRecordImage:setOpacity(255)
        end
    end

    if self.normalTimeLabel then
        self.normalTimeLabel:setVisible(true)
    end

    if self.transparentRecordImage then
        self.transparentRecordImage:setVisible(RecordingState.SilenceRecording == self.recordState)
    end

    if self.transparentLabel then
        self.transparentLabel:setVisible(true)
    end

    if RecordingState.SilenceRecording ~= self.recordState and RecordingState.Recording ~= self.recordState then
        self.redDot:setVisible(false)
    end

    self.timePanel:setVisible(RecordingState.SilenceRecording == self.recordState or RecordingState.Recording == self.recordState or RecordingState.StopRecording == self.recordState)

    -- 更新时间
    self:refreshRecordTime()
end

function ScreenRecordingDlg:updateRecordTime()
    self:refreshRecordTime()

    if gf:getServerTime() - self.lastOperTime > 2
        and RecordingState.Recording == self.recordState then
        self.recordState = RecordingState.Fade
        local fadeOut = cc.FadeOut:create(2)
        local delayFunc  = cc.CallFunc:create(function ()
            self.recordState = RecordingState.SilenceRecording
            self:updateFade()
        end);
        local fadeIn = cc.FadeIn:create(2)
        local fadeInAction = cc.Sequence:create(fadeIn, delayFunc)
        self.transparentRecordImage:setVisible(true)
        self.transparentRecordImage:setOpacity(0)
        self.transparentRecordImage:runAction(fadeInAction)
        local fadeOutAction = cc.Sequence:create(fadeOut)
        self.normalRecordImage:runAction(fadeOutAction)
    end

    self.redDot:setVisible(not self.redDot:isVisible())
end

function ScreenRecordingDlg:refreshRecordTime()
    local recordLen = gf:getServerTime() - self.recordTime

    local min = math.modf(recordLen / 60)
    min = math.min(min, 99)
    local sec = recordLen - 60 * min
    if min < 99 then
        sec = sec % 60
    elseif recordLen > 99 * 60 + 99 then
        sec = 99
    else
        sec = math.min(sec, 99)
    end

    self.normalTimeLabel:setString(string.format("%02d:%02d", min, sec))
    self.transparentLabel:setText(string.format("%02d:%02d", min, sec))
end

return ScreenRecordingDlg
