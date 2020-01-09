-- BlogSignDlg.lua
-- Created by sujl, Sept/25/2017
-- 空间签名界面

local BlogSignDlg = Singleton("BlogSignDlg", Dialog)

local MSG_LIMIT = 60

function BlogSignDlg:init(gid)
    self:bindListener("ConfirmButton", self.onConfirmButton, "TextTypePanel")
    self:bindListener("ChangeButton", self.onChangeToVoiceButton, "TextTypePanel")
    self:bindListener("DelButton", self.onDelMsgButton, "TextTypePanel")
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


    self.gid = gid

    self.newNameEdit = self:createEditBox("TextPanel", "TextTypePanel", nil, function(sender, type)
        if type == "ended" then
            self.newNameEdit:setText("")
            self:setCtrlVisible("TextLabel", true, "TextTypePanel")
        elseif type == "began" then
            local msg = self:getLabelText("TextLabel", "TextTypePanel")
            self.newNameEdit:setText(msg)
            self:setCtrlVisible("TextLabel", false, "TextTypePanel")
        elseif type == "changed" then
            local newName = self.newNameEdit:getText()
            if gf:getTextLength(newName) > MSG_LIMIT then
                newName = gf:subString(newName, MSG_LIMIT)
                self.newNameEdit:setText(newName)
                gf:ShowSmallTips(CHS[4000224])
            end

            if gf:getTextLength(newName) == 0 then
                self:setCtrlVisible("DelButton", false, "TextTypePanel")
                self:setCtrlVisible("NoneLabel", true, "TextTypePanel")
            else
                self:setCtrlVisible("NoneLabel", false, "TextTypePanel")
                self:setCtrlVisible("DelButton", true, "TextTypePanel")
            end

            self:setLabelText("TextLabel", newName, "TextTypePanel")
            -- self.newNameEdit:setText("")
        end
    end)
    local editContentSize = self.newNameEdit:getContentSize()
    self.newNameEdit:setLocalZOrder(1)
    self.newNameEdit:setFont(CHS[3003597], 19)
    self.newNameEdit:setFontColor(cc.c3b(76, 32, 0))
    self.newNameEdit:setText("")
    local signText, voice, time = BlogMgr:getSignatureByGid(self.gid)
    if string.isNilOrEmpty(voice) then
        self:switchToText(signText)
    else
        self:switchToVoice(voice, signText, time or 0)
    end

    -- 创建语音面板
    self.voicePanel1 = self:createVoicePanel("TypePanel1", "VoiceTypePanel")
    self.voicePanel2 = self:createVoicePanel("TypePanel2", "VoiceTypePanel")
end

function BlogSignDlg:cleanup()
    if not string.isNilOrEmpty(self.mediaFile) then
        os.remove(self.mediaFile)
        self.mediaFile = nil
    end
    local btn = self:getControl("RecordButton", nil, self:getControl("TypePanel1", nil, "VoiceTypePanel"))
    ChatMgr:cancelRecord(self, btn)
    ChatMgr:clearRecord()
    self:stopPlayVoice()
end

function BlogSignDlg:stopPlayVoice()
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
function BlogSignDlg:createVoicePanel(typeName, root)
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
function BlogSignDlg:playVoiceCountDown(panel, time)
    local sec = time
    local progressTimer = panel:getChildByName("ProgressTimer")
    local progressTo = cc.ProgressTo:create(time, 100)
    progressTimer:setPercentage(0)
    self:setLabelText("TimeLabel", string.format(CHS[2000462], 30), panel:getParent())
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
function BlogSignDlg:initVoiceType3()
end

-- 切换到语音
function BlogSignDlg:switchToVoice(voice, text, time)
    self:setCtrlVisible("TextTypePanel", false)
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

-- 切换到文本
function BlogSignDlg:switchToText(showText)
    self:setCtrlVisible("TextTypePanel", true)
    self:setCtrlVisible("VoiceTypePanel", false)
    self:setLabelText("TextLabel", showText, "TextTypePanel")
    showText = self:getLabelText("TextLabel", "TextTypePanel")
    self:setCtrlVisible("DelButton", not string.isNilOrEmpty(showText), "TextTypePanel")
    self:setCtrlVisible("NoneLabel", string.isNilOrEmpty(showText), "TextTypePanel")
end

function BlogSignDlg:onDelMsgButton(sender, eventType)
    self:setLabelText("TextLabel", "", "TextTypePanel")
    self.newNameEdit:setText("")
    self:setCtrlVisible("DelButton", false, "TextTypePanel")
    self:setCtrlVisible("NoneLabel", true, "TextTypePanel")
end

-- 切换到语音
function BlogSignDlg:onChangeToVoiceButton(sender, eventType)
    self:switchToVoice()
end

-- 切换到文本
function BlogSignDlg:onChangeToTextButton(sender, eventType)
    self:switchToText()
end

-- 开始录音
function BlogSignDlg:onRecordButton(sender, eventType)
    if not ChatMgr:beginRecord(sender, self, 30, true) then return end

    self:setCtrlVisible("TextTypePanel", false)
    self:setCtrlVisible("VoiceTypePanel", true)
    self:setCtrlVisible("TypePanel1", false, "VoiceTypePanel")
    self:setCtrlVisible("TypePanel2", true, "VoiceTypePanel")
    self:setCtrlVisible("TypePanel3", false, "VoiceTypePanel")
    self:setCtrlVisible("TypePanel4", false, "VoiceTypePanel")
    self:setCtrlEnabled("SendButton", true, self:getControl("TypePanel3", nil, voiceTypePanel))

    local panel = self:getControl("TypePanel2", nil, "VoiceTypePanel")
    self:setCtrlVisible("NoneLabel", false, panel)
    self:setCtrlVisible("ShowPanel", true, panel)

    self:playVoiceCountDown(self.voicePanel2, 30)
end

function BlogSignDlg:resetVoiceAction()
    local panel = self.voicePanel2
    panel:stopAllActions()
    local progressTimer = panel:getChildByName("ProgressTimer")
    progressTimer:stopAllActions()
end

-- 播放语音
function BlogSignDlg:playVoice(filePath)
    if not self.playAction or string.isNilOrEmpty(filePath) then
        self:stopPlayVoice()
        return
    end

    ChatMgr:stopPlayRecord()
    local actionImg = self.playAction
    actionImg:setVisible(true)
    self:setCtrlVisible("TimeIconImage", false, actionImg:getParent())
    local _, _, time  = BlogMgr:getSignatureByGid(self.gid)
    schedule(actionImg, function()
        time = time - 0.1
        if time <= 0 then
            self:stopPlayVoice()
        end
    end, 0.1)

    ChatMgr:setIsPlayingVoice(true)
    ChatMgr:playRecord(filePath, 1, time, true, function()
        DlgMgr:sendMsg("BlogSignDlg", "stopPlayVoice")
    end)
    ChatMgr:clearPlayVoiceList()
    SoundMgr:stopMusicAndSound()
end

-- 确认语音
function BlogSignDlg:onConfirmVoiceButton(sender, eventType)
    local btn = self:getControl("RecordButton", nil, self:getControl("TypePanel1", nil, "VoiceTypePanel"))
    ChatMgr:endRecord(self, btn)
    self:resetVoiceAction()
end

-- 取消语音
function BlogSignDlg:onCancelVoiceButton(sender, eventType)
    self:switchToVoice()
    local btn = self:getControl("RecordButton", nil, self:getControl("TypePanel1", nil, "VoiceTypePanel"))
    ChatMgr:cancelRecord(self, btn)
    self:resetVoiceAction()
end

-- 发布文本
function BlogSignDlg:onConfirmButton(sender, eventType)
    local signText = self:getLabelText("TextLabel", "TextTypePanel")
    local editText = self.newNameEdit:getText()
    if not string.isNilOrEmpty(editText) then
        -- 输入框内容不为空，以输入框为准，用于处理关闭键盘时没有写入的情况
        signText = editText
    end
    local oriText, _, _ = BlogMgr:getSignatureByGid(self.gid)
    if signText == oriText then
        self:onCloseButton()
        return
    end

    local str = gfFiltrate(signText, true)
    if not string.isNilOrEmpty(str) then
        gf:confirm(CHS[2000426], function()
            self:setLabelText("TextLabel", str, "TextTypePanel")
            if not string.isNilOrEmpty(self.newNameEdit:getText()) then
                self.newNameEdit:setText(str)
            end
            gf:ShowSmallTips(CHS[2100119])
            ChatMgr:sendMiscMsg(CHS[2100119])
        end, nil, nil, nil, nil, nil, true)
        return
    end

    gf:CmdToServer('CMD_BLOG_CHANGE_SIGNATURE', { voice = "", text = signText, voice_duraction = 0 })
    self:onCloseButton()
end

-- 重录
function BlogSignDlg:onAgainButton(sender, eventType)
    self:switchToVoice()
    ChatMgr:clearRecord()
end

function BlogSignDlg:setPanelText(str, panel)
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

function BlogSignDlg:getPanelText(panel)
    local scrollView = self:getControl("ScrollView", nil, panel)
    local children = scrollView:getChildren()
    if children and #children > 0 then
        return children[1].strContent
    end

    return ""
end

function BlogSignDlg:onFinishUploadVoice(files, uploads)
    if #files ~= #uploads then
        gf:ShowSmallTips(CHS[2000463])
        return
    end

    local panel = self:getControl("ShowPanel", nil, self:getControl("TypePanel3", nil, "VoiceTypePanel"))
    local str = self:getPanelText(panel)
    local str1 = gfFiltrate(str, true)
    if not string.isNilOrEmpty(str1) then
        gf:confirm(CHS[2000426], function()
            -- self:setLabelText("TextLabel", str1, panel)
            self:setPanelText(str1, panel)
            gf:ShowSmallTips(CHS[2000427])
            ChatMgr:sendMiscMsg(CHS[2000427])
            self:setCtrlEnabled("SendButton", false, self:getControl("TypePanel3", nil, voiceTypePanel))
        end, nil, nil, nil, nil, nil, true)
        return
    end

    local voiceData = ChatMgr:getVoiceData()
    assert(not string.isNilOrEmpty(uploads[1]) and voiceData.voiceTime > 0, "Invalid voice data.")
    gf:CmdToServer('CMD_BLOG_CHANGE_SIGNATURE', { voice = uploads[1], text = str, voice_duraction = math.min(30, math.ceil(voiceData.voiceTime / 1000)) })
    if not string.isNilOrEmpty(self.mediaFile) then
        os.remove(self.mediaFile)
        self.mediaFile = nil
    end
    self:onCloseButton()
end

-- 发布语音
function BlogSignDlg:onSendVoiceButton(sender, eventType)
    -- 发送语音
    local voiceData = ChatMgr:getVoiceData()
    BlogMgr:cmdUpload(BLOG_OP_TYPE.BLOG_OP_SIGNATURE, self.name, "onFinishUploadVoice", self.mediaFile)
end

-- 删除语音
function BlogSignDlg:onDeleteButton(sender, eventType)
    gf:confirm(CHS[2000464], function()
        gf:CmdToServer('CMD_BLOG_CHANGE_SIGNATURE', { voice = "", text = "", voice_duraction = 0 })
        self:switchToVoice()
    end)
end

-- 播放本地录制语音
function BlogSignDlg:onClickVoice1(sender, eventType)
    if self.playAction then
        self:stopPlayVoice()
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
            DlgMgr:sendMsg("BlogSignDlg", "stopPlayVoice")
        end)
        ChatMgr:clearPlayVoiceList()
        SoundMgr:stopMusicAndSound()
    end
end

-- 播放签名语音
function BlogSignDlg:onClickVoice2(sender, eventType)
    if self.playAction then
        self:stopPlayVoice()
        return
    end

    local _, voice, _  = BlogMgr:getSignatureByGid(self.gid)
    if voice then
        local voiceSignImg = self:getControl("TimeIconImage", nil, sender)
        local actionImg = gf:createLoopMagic(ResMgr.magic.volume)
        actionImg:setAnchorPoint(0.5, 0.5)
        actionImg:setVisible(false)
        actionImg:setPosition(voiceSignImg:getPosition())
        voiceSignImg:getParent():addChild(actionImg, 0, 997)
        self.playAction = actionImg

        BlogMgr:assureFile("playVoice", self.name, voice)
    end
end

function BlogSignDlg:cancelRecord(showTip)
    local voiceData = ChatMgr:getVoiceData()

    ChatMgr:setCallObj()
    self:switchToVoice()

    if showTip and (not voiceData or not voiceData.voiceTime or voiceData.voiceTime < 1000) then
        gf:ShowSmallTips(CHS[2000465])
        return true
    end
end

-- 发送语音回调
function BlogSignDlg:sendVoiceMsg(mediaFile)
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
    self:setLabelText("TimeLabel", string.format(CHS[2000462], math.min(30, math.ceil(voiceData.voiceTime / 1000))), panel)
    if gf:getTextLength(voiceData.text) > 1000 * 2 then
        self:setPanelText(gf:subString(voiceData.text, 1000 * 2) .. '...', panel)
    else
        self:setPanelText(voiceData.text, panel)
    end

    if not string.isNilOrEmpty(voiceData.token) and not string.isNilOrEmpty(voiceData.text) then
        self:setCtrlVisible("TextTypePanel", false)
        self:setCtrlVisible("VoiceTypePanel", true)
        self:setCtrlVisible("TypePanel1", false, "VoiceTypePanel")
        self:setCtrlVisible("TypePanel2", false, "VoiceTypePanel")
        self:setCtrlVisible("TypePanel3", true, "VoiceTypePanel")
        self:setCtrlVisible("TypePanel4", false, "VoiceTypePanel")
    else
        local panel = self:getControl("TypePanel2", nil, "VoiceTypePanel")
        self:setCtrlVisible("NoneLabel", true, panel)
        self:setCtrlVisible("ShowPanel", false, panel)
    end
end

-- 语音转换失败
function BlogSignDlg:sendVoiceMsgError()
    gf:ShowSmallTips(CHS[2000466])
    self:switchToVoice()
    return true
end

-- 音量变化
function BlogSignDlg:onVolumeChange(volume)
    local panel = self:getControl("ShowPanel", nil, self:getControl("TypePanel2", nil, "VoiceTypePanel"))
    self:setCtrlVisible("VolumeImage1", volume > 10 and volume <= 25, panel)
    self:setCtrlVisible("VolumeImage2", volume > 25 and volume <= 50, panel)
    self:setCtrlVisible("VolumeImage3", volume > 50 and volume <= 75, panel)
    self:setCtrlVisible("VolumeImage4", volume > 75, panel)
    return true
end

return BlogSignDlg
