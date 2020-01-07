-- MatchmakingSignDlg.lua
-- Created by sujl, Sept/27/2018
-- 相亲平台录音界面

local MatchmakingSignDlg = Singleton("MatchmakingSignDlg", Dialog)

local RECORD_TIME_LIMIT = 60 -- 录制时长

function MatchmakingSignDlg:init()
    local voiceTypePanel = self:getControl("VoiceTypePanel")
    self:bindListener("RecordButton", self.onRecordButton, self:getControl("TypePanel1", nil, voiceTypePanel))
    self:bindListener("ChangeButton", self.onChangeToTextButton, self:getControl("TypePanel1", nil, voiceTypePanel))
    self:bindListener("ConfirmButton", self.onConfirmVoiceButton, self:getControl("TypePanel2", nil, voiceTypePanel))
    self:bindListener("CancelButton", self.onCancelVoiceButton, self:getControl("TypePanel2", nil, voiceTypePanel))
    self:bindListener("AgainButton", self.onAgainButton, self:getControl("TypePanel3", nil, voiceTypePanel))
    self:bindListener("SendButton", self.onSendVoiceButton, self:getControl("TypePanel3", nil, voiceTypePanel))
    self:bindListener("AgainButton", self.onAgainButton, self:getControl("TypePanel4", nil, voiceTypePanel))
    self:bindListener("DeleteButton", self.onDeleteButton, self:getControl("TypePanel4", nil, voiceTypePanel))
    self:bindListener("ShowPanel", self.onClickVoice1, self:getControl("TypePanel3", nil, voiceTypePanel))
    self:bindListener("ShowPanel", self.onClickVoice2, self:getControl("TypePanel4", nil, voiceTypePanel))

    local mySetting = MatchMakingMgr:getMySetting()
    self:switchToVoice(mySetting and mySetting.voice_addr, mySetting and mySetting.voice_text, mySetting and mySetting.voice_time or 0)

    -- 创建语音面板
    self.voicePanel1 = self:createVoicePanel("TypePanel1", "VoiceTypePanel")
    self.voicePanel2 = self:createVoicePanel("TypePanel2", "VoiceTypePanel")
end

function MatchmakingSignDlg:cleanup()
    if not string.isNilOrEmpty(self.mediaFile) then
        os.remove(self.mediaFile)
        self.mediaFile = nil
    end
    local btn = self:getControl("RecordButton", nil, self:getControl("TypePanel1", nil, "VoiceTypePanel"))
    ChatMgr:cancelRecord(self, btn)
    ChatMgr:clearRecord()
    self:stopPlayVoice()
end

function MatchmakingSignDlg:stopPlayVoice()
    ChatMgr:setIsPlayingVoice(false)
    SoundMgr:replayMusicAndSound()
    ChatMgr:stopPlayRecord()
    if self.playAction then
        local actionImg = self.playAction
        if actionImg then
            self:setCtrlVisible("TimeIconImage", true, actionImg:getParent())
            actionImg:stopAllActions()
            actionImg:removeFromParent()
        end
    end
    self.playAction = nil
end

-- 显示语音面板
function MatchmakingSignDlg:createVoicePanel(typeName, root)
    local panel = self:getControl("ProgressPanel", nil, self:getControl(typeName, nil, root))
    panel:removeAllChildren()
    local progressTimer = cc.ProgressTimer:create(cc.Sprite:create(ResMgr.ui.blog_voice_progressTimer))
    progressTimer:setName("ProgressTimer")
    progressTimer:setReverseDirection(false)
    panel:addChild(progressTimer)

    local contentSize = panel:getContentSize()
    progressTimer:setPosition(contentSize.width / 2, contentSize.height / 2)

    progressTimer:setPercentage(0)
    return panel
end

-- 播放语音面板倒计时效果
function MatchmakingSignDlg:playVoiceCountDown(panel, time)
    local sec = time
    local progressTimer = panel:getChildByName("ProgressTimer")
    local progressTo = cc.ProgressTo:create(time, 100)
    progressTimer:setPercentage(0)
    self:setLabelText("TimeLabel", string.format(CHS[2000462], RECORD_TIME_LIMIT), panel:getParent())
    progressTimer:runAction(progressTo)
    schedule(panel, function()
        sec = sec - 1
        if sec > 0 then
            self:setLabelText("TimeLabel", string.format(CHS[2000462], sec), panel:getParent())
        else
            self:setLabelText("TimeLabel", string.format(CHS[2000462], sec), panel:getParent())
            panel:stopAllActions()
        end
    end, 1)
end

-- 初始面板
function MatchmakingSignDlg:initVoiceType3()
end

-- 切换到语音
function MatchmakingSignDlg:switchToVoice(voice, text, time)
    self:setCtrlVisible("VoiceTypePanel", true)
    self:setCtrlVisible("TypePanel1", string.isNilOrEmpty(voice), "VoiceTypePanel")
    self:setCtrlVisible("TypePanel2", false, "VoiceTypePanel")
    self:setCtrlVisible("TypePanel3", false, "VoiceTypePanel")
    self:setCtrlVisible("TypePanel4", not string.isNilOrEmpty(voice), "VoiceTypePanel")

    local panel = self:getControl("TypePanel4", nil, "VoiceTypePanel")
    self:setLabelText("TimeLabel", string.format(CHS[2000462], time or 0), panel)
    local scrollView = self:getControl("ScrollView", nil, panel)
    scrollView:removeAllChildren()
    local panel = ccui.Layout:create()
    panel:setContentSize(scrollView:getContentSize())
    scrollView:addChild(panel)
    local panelHeight = self:setColorText(text, panel, nil, nil, nil, cc.c3b(0x66, 0x66, 0x66), 19)
    scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, panelHeight))
    local px, py = panel:getPosition()
    panel:setPosition(px, math.max(0, scrollView:getContentSize().height - panelHeight))
end

-- 切换到语音
function MatchmakingSignDlg:onChangeToVoiceButton(sender, eventType)
    self:switchToVoice()
end

-- 开始录音
function MatchmakingSignDlg:onRecordButton(sender, eventType)
    if not ChatMgr:beginRecord(sender, self, RECORD_TIME_LIMIT, true) then return end

    self:setCtrlVisible("VoiceTypePanel", true)
    self:setCtrlVisible("TypePanel1", false, "VoiceTypePanel")
    self:setCtrlVisible("TypePanel2", true, "VoiceTypePanel")
    self:setCtrlVisible("TypePanel3", false, "VoiceTypePanel")
    self:setCtrlVisible("TypePanel4", false, "VoiceTypePanel")
    self:setCtrlEnabled("SendButton", true, self:getControl("TypePanel3", nil, voiceTypePanel))

    local panel = self:getControl("TypePanel2", nil, "VoiceTypePanel")
    self:setCtrlVisible("NoneLabel", false, panel)
    self:setCtrlVisible("ShowPanel", true, panel)

    self:playVoiceCountDown(self.voicePanel2, RECORD_TIME_LIMIT)
end

function MatchmakingSignDlg:resetVoiceAction()
    local panel = self.voicePanel2
    panel:stopAllActions()
    local progressTimer = panel:getChildByName("ProgressTimer")
    progressTimer:stopAllActions()
end

-- 播放语音
function MatchmakingSignDlg:playVoice(filePath, time)
    if not self.playAction or string.isNilOrEmpty(filePath) then
        self:stopPlayVoice()
        return
    end

    if not GameMgr:isYayaImEnabled() then
        self:stopPlayVoice()
        gf:ShowSmallTips(CHS[3004450]) -- 操作失败，语音功能暂时无法使用。
        return
    end

    ChatMgr:stopPlayRecord()

    local actionImg = self.playAction
    actionImg:setVisible(true)
    self:setCtrlVisible("TimeIconImage", false, actionImg:getParent())
    schedule(actionImg, function()
        time = time - 0.1
        if time <= 0 then
            self:stopPlayVoice()
        end
    end, 0.1)

    ChatMgr:setIsPlayingVoice(true)
    ChatMgr:playRecord(filePath, 1, time, true, function()
        DlgMgr:sendMsg("MatchmakingSignDlg", "stopPlayVoice")
    end)
    ChatMgr:clearPlayVoiceList()
    SoundMgr:stopMusicAndSound()
end

-- 确认语音
function MatchmakingSignDlg:onConfirmVoiceButton(sender, eventType)
    local btn = self:getControl("RecordButton", nil, self:getControl("TypePanel1", nil, "VoiceTypePanel"))
    ChatMgr:endRecord(self, btn)
    self:resetVoiceAction()
end

-- 取消语音
function MatchmakingSignDlg:onCancelVoiceButton(sender, eventType)
    self:switchToVoice()
    local btn = self:getControl("RecordButton", nil, self:getControl("TypePanel1", nil, "VoiceTypePanel"))
    ChatMgr:cancelRecord(self, btn)
    self:resetVoiceAction()
end

-- 重录
function MatchmakingSignDlg:onAgainButton(sender, eventType)
    self:switchToVoice()
    ChatMgr:clearRecord()
end

function MatchmakingSignDlg:setPanelText(str, panel)
    local scrollView = self:getControl("ScrollView", nil, panel)
    scrollView:removeAllChildren()
    local panel = ccui.Layout:create()
    panel:setContentSize(scrollView:getContentSize())
    scrollView:addChild(panel)
    local panelHeight = self:setColorText(str, panel, nil, nil, nil, cc.c3b(0x66, 0x66, 0x66), 19)
    scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, panelHeight))
    panel.strContent = str
    local px, py = panel:getPosition()
    panel:setPosition(px, math.max(0, scrollView:getContentSize().height - panelHeight))
end

function MatchmakingSignDlg:getPanelText(panel)
    local scrollView = self:getControl("ScrollView", nil, panel)
    local children = scrollView:getChildren()
    if children and #children > 0 then
        return children[1].strContent
    end

    return ""
end

function MatchmakingSignDlg:onFinishUploadVoice(files, uploads)
    if #files ~= #uploads then
        gf:ShowSmallTips(CHS[2000463])
        return
    end

    local voiceData = ChatMgr:getVoiceData()
    assert(not string.isNilOrEmpty(uploads[1]) and voiceData.voiceTime > 0, "Invalid voice data.")
    DlgMgr:sendMsg("MatchmakingDlg", "onUploadSignVoice", uploads[1], str, math.min(RECORD_TIME_LIMIT, math.ceil(voiceData.voiceTime / 1000)))
    if not string.isNilOrEmpty(self.mediaFile) then
        os.remove(self.mediaFile)
        self.mediaFile = nil
    end
    self:onCloseButton()
end

-- 发布语音
function MatchmakingSignDlg:onSendVoiceButton(sender, eventType)
    local panel = self:getControl("ShowPanel", nil, self:getControl("TypePanel3", nil, "VoiceTypePanel"))
    local str = self:getPanelText(panel)
    local str1 = gfFiltrate(str, true)
    if not string.isNilOrEmpty(str1) then
        gf:confirm(CHS[2000540], function()
            -- self:setLabelText("TextLabel", str1, panel)
            self:setPanelText(str1, panel)
            gf:showTipAndMisMsg(CHS[2000541])
            self:setCtrlEnabled("SendButton", false, self:getControl("TypePanel3", nil, voiceTypePanel))
        end, nil, nil, nil, nil, nil, true)
        return
    end

    -- 显示正在上传中文本


    -- 发送语音
    local voiceData = ChatMgr:getVoiceData()
    BlogMgr:cmdUpload(BLOG_OP_TYPE.MATCH_MAKING_VOICE, self.name, "onFinishUploadVoice", self.mediaFile)
end

-- 删除语音
function MatchmakingSignDlg:onDeleteButton(sender, eventType)
    gf:confirm(CHS[2000538], function()
        gf:CmdToServer('CMD_MATCH_MAKING_OPER_VOICE', { voice_addr = "", voice_text = "", voice_time = 0 })
        self:switchToVoice()
    end)
end

-- 播放本地录制语音
function MatchmakingSignDlg:onClickVoice1(sender, eventType)
    if self.playAction then
        self:stopPlayVoice()
        return
    end

    if not GameMgr:isYayaImEnabled() then
        self:stopPlayVoice()
        gf:ShowSmallTips(CHS[3004450]) -- 操作失败，语音功能暂时无法使用。
        return
    end

    ChatMgr:stopPlayRecord()
    local data = ChatMgr:getVoiceData()
    if data then
        local voiceSignImg = self:getControl("TimeIconImage", nil, sender)
        local actionImg = gf:createLoopMagic(ResMgr.magic.volume)
        actionImg:setAnchorPoint(0.5, 0.5)
        actionImg:setPosition(voiceSignImg:getPosition())
        voiceSignImg:setVisible(false)
        voiceSignImg:getParent():addChild(actionImg, 0, 997)

        local time = math.ceil(data.voiceTime / 1000)
        schedule(sender, function()
            time = time - 0.1
            if time <= 0 then
                sender:stopAllActions()
                self:stopPlayVoice()
            end
        end, 0.1)

        self.playAction = actionImg
        ChatMgr:setIsPlayingVoice(true)
        ChatMgr:playRecord(data.token, 0, time, true, function()
            DlgMgr:sendMsg("MatchmakingSignDlg", "stopPlayVoice")
        end)
        ChatMgr:clearPlayVoiceList()
        SoundMgr:stopMusicAndSound()
    end
end

-- 播放签名语音
function MatchmakingSignDlg:onClickVoice2(sender, eventType)
    if self.playAction then
        self:stopPlayVoice()
        return
    end

    local mySetting = MatchMakingMgr:getMySetting()
    if mySetting and mySetting.voice_addr then
        local voiceSignImg = self:getControl("TimeIconImage", nil, sender)
        local actionImg = gf:createLoopMagic(ResMgr.magic.volume)
        actionImg:setAnchorPoint(0.5, 0.5)
        actionImg:setVisible(false)
        actionImg:setPosition(voiceSignImg:getPosition())
        voiceSignImg:getParent():addChild(actionImg, 0, 997)
        self.playAction = actionImg

        BlogMgr:assureFile("playVoice", self.name, mySetting.voice_addr, nil, mySetting.voice_time)
    end
end

function MatchmakingSignDlg:cancelRecord(showTip)
    local voiceData = ChatMgr:getVoiceData()

    ChatMgr:setCallObj()
    self:switchToVoice()

    if showTip and (not voiceData or not voiceData.voiceTime or voiceData.voiceTime < 1000) then
        gf:ShowSmallTips(CHS[2000465])
        return true
    end
end

-- 发送语音回调
function MatchmakingSignDlg:sendVoiceMsg(mediaFile)
    if not self:getCtrlVisible("TypePanel2", "VoiceTypePanel") then return end

    local name = ChatMgr:getSenderName()
    local voiceData = ChatMgr:getVoiceData()

    if not voiceData or not voiceData.voiceTime or voiceData.voiceTime < 1000 then
        gf:ShowSmallTips(CHS[2000465])
        ChatMgr:setCallObj()
        self:switchToVoice()
        return
    end

    if mediaFile then
        local ext = gf:getFileExt(mediaFile)
        local newName = string.format("%s_blogs.%s", string.sub(mediaFile, 1, #mediaFile - #ext - 1), ext)
        os.rename(mediaFile, newName)
        self.mediaFile = newName
    end

    local panel = self:getControl("ShowPanel", nil, self:getControl("TypePanel3", nil, "VoiceTypePanel"))

    -- 设置文本
    self:setLabelText("TimeLabel", string.format(CHS[2000462], math.min(RECORD_TIME_LIMIT, math.ceil(voiceData.voiceTime / 1000))), panel)
    if gf:getTextLength(voiceData.text) > 1000 * 2 then
        self:setPanelText(gf:subString(voiceData.text, 1000 * 2) .. '...', panel)
    else
        self:setPanelText(voiceData.text, panel)
    end

    if not string.isNilOrEmpty(voiceData.token) and not string.isNilOrEmpty(voiceData.text) then
        self:setCtrlVisible("VoiceTypePanel", true)
        self:setCtrlVisible("TypePanel1", false, "VoiceTypePanel")
        self:setCtrlVisible("TypePanel2", false, "VoiceTypePanel")
        self:setCtrlVisible("TypePanel3", true, "VoiceTypePanel")
        self:setCtrlVisible("TypePanel4", false, "VoiceTypePanel")
    else
        local panel = self:getControl("TypePanel2", nil, "VoiceTypePanel")
        self:setCtrlVisible("NoneLabel", true, panel)
        self:setCtrlVisible("ShowPanel", false, panel)
        self:runProgressAction("NoneLabel", CHS[2000533], panel)
    end
end

-- 语音转换失败
function MatchmakingSignDlg:sendVoiceMsgError()
    gf:showTipAndMisMsg(CHS[2000466])
    self:switchToVoice()
    return true
end

-- 音量变化
function MatchmakingSignDlg:onVolumeChange(volume)
    local panel = self:getControl("ShowPanel", nil, self:getControl("TypePanel2", nil, "VoiceTypePanel"))
    self:setCtrlVisible("VolumeImage1", volume > 10 and volume <= 25, panel)
    self:setCtrlVisible("VolumeImage2", volume > 25 and volume <= 50, panel)
    self:setCtrlVisible("VolumeImage3", volume > 50 and volume <= 75, panel)
    self:setCtrlVisible("VolumeImage4", volume > 75, panel)
    return true
end

return MatchmakingSignDlg