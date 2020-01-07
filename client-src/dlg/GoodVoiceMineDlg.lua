-- GoodVoiceMineDlg.lua
-- Created by songcw Mar/22/2019
-- 好声音-我的声音界面

local GoodVoiceMineDlg = Singleton("GoodVoiceMineDlg", Dialog)

local TITLE_LIMINT = 7
local MESSAGE_LIMINT = 20

local STATE =
{
    RECORDING = 1,      -- 录音中
    PLAYING = 2,        -- 播放中
}

function GoodVoiceMineDlg:init()

    self:bindListener("MyCompetitionVoiceButton", self.onMyCompetitionVoiceButton)
    self:bindListener("DelButton", self.onDelVoiceButton, "ButtonPanel")
    self:bindListener("DelButton", self.onFieldDelButton, "MessageInputPanel")
    self:bindListener("DelButton", self.onFieldDelButton, "TitleInputPanel")
    self:bindListener("ReButton1", self.onReButton)
    self:bindListener("ReButton2", self.onReButton)
    self:bindListener("SaveButton", self.onSaveButton)

    self:bindListener("CompetitionButton", self.onCompetitionButton)
    self:bindListener("BeginButton", self.onBeginButton)
    self:bindListener("StopButton", self.onStopButton)
    self:bindListener("PlayPanel", self.onPlayButton)
    self:bindListViewListener("ListView", self.onSelectListView)

    self:setValidClickTime("PlayPanel", 500, "")

    self.voicePanel = self:retainCtrl("VoicePanel")
    self.selectVoiceImage = self:retainCtrl("ChosenEffectImage", self.voicePanel)
    self:bindTouchEndEventListener(self.voicePanel, self.onSelectVoice)

    -- 声音标题
    self:bindEditFieldForSafe("TitleInputPanel", TITLE_LIMINT, "DelButton", cc.TEXT_ALIGNMENT_LEFT, function (dlg, sender, eventType)
        -- 失去焦点时，需要检测敏感字
        if eventType == ccui.TextFiledEventType.detach_with_ime then
            local str = sender:getStringValue()
            local filtTextStr, haveFilt = gf:filtText(str, nil, true)
            if haveFilt then
                sender:setText(filtTextStr)
                self:refreshLocalFile(filtTextStr)
            else
                self:refreshLocalFile(str)
            end
        end
    end, true)

    -- 声音寄语
    self:bindEditFieldForSafe("MessageInputPanel", MESSAGE_LIMINT, "DelButton", cc.TEXT_ALIGNMENT_LEFT, function (dlg, sender, eventType)
        -- 失去焦点时，需要检测敏感字
        if eventType == ccui.TextFiledEventType.detach_with_ime then
            local str = sender:getStringValue()
            local filtTextStr, haveFilt = gf:filtText(str, nil, true)
            if haveFilt then
                sender:setText(filtTextStr)
                self:refreshLocalFile(nil, filtTextStr)
            else
                self:refreshLocalFile(nil, str)
            end
        end
    end, true)

    self.state = nil
    self.selectVoice = nil
	self.curVoice = nil
    self.curTime = 0

    self:setPlayerTime({})

    self:bindListener("AddPanel", self.onAddVoice)

    self:createVoicePanel("VoicePlayerPanel2")

    self:setMyVoiceList()

    -- 主题名字
    self:setLabelText("NameLabel", GoodVoiceMgr.seasonData.theme_name, "NamePanel")

    self:hookMsg("MSG_CLIENT_DISCONNECTED")
end

function GoodVoiceMineDlg:refreshLocalFile(title, message, fileName)
--!!!!!!!!!!!!!!
    local sender = self.selectVoiceImage:getParent()
    if not sender or sender:getName() == "AddPanel" then return end


    local data = sender.data
    if title then
        data.title = title
    end

    if message then
        data.message = message
    end

    sender.data = data
    GoodVoiceMgr:refreshLocalVoice(data)


    local list = self:getControl("ListView")
    local items = list:getItems()
    for i, panel in pairs(items) do
        self:setUnitVoicePanel(panel.data, panel)
    end
end

-- 切换播放状态
function GoodVoiceMineDlg:setPlayState(isPlaying)
    local panel = self:getControl("PlayPanel")

    if isPlaying ~= nil then
        -- 如果有传入isPlaying，直接根据isPlaying值设置
        self:setCtrlVisible("Image1", isPlaying, panel)
        self:setCtrlVisible("Label1", not isPlaying, panel)
        self:setCtrlVisible("Image2", not isPlaying, panel)
        self:setCtrlVisible("Label2", isPlaying, panel)
    else
        -- 没有传入，则切换另一个状态
        local stopImageIsVisible = self:getCtrlVisible("Image1", panel)
        self:setCtrlVisible("Image2", stopImageIsVisible, panel)
        self:setCtrlVisible("Label2", not stopImageIsVisible, panel)
        self:setCtrlVisible("Image1", not stopImageIsVisible, panel)
        self:setCtrlVisible("Label1", stopImageIsVisible, panel)
    end

    return self:getCtrlVisible("Image1", panel)
end

function GoodVoiceMineDlg:isPlayering()
    return self:getCtrlVisible("Image1", panel)
end


function GoodVoiceMineDlg:cleanup()

    if self.state == STATE.RECORDING then
        -- 正在录音中
        SoundMgr:endRecordForGoodVoice()        -- 结束录音
        GoodVoiceMgr:stopPlayGoodVoiceAndReplayMusic()

    elseif self.state == STATE.PLAYING then
        AudioEngine.stopMusic()
        GoodVoiceMgr:stopPlayGoodVoiceAndReplayMusic()

    end

    self.state = nil

    if self.timerId then
        gf:ShowSmallTips(CHS[4200695])
        self:getControl("ProgressPanel", nil, "VoicePlayerPanel2"):stopAllActions()
        self.timerId = nil
    end
end

function GoodVoiceMineDlg:setMyVoiceList(defSelectName)
    local data = GoodVoiceMgr:getMyLocalVoiceData()




    local ret = {}
    for _ , info in pairs(data) do
        info.createTime = info.createTime or 0    -- 容错下，旧数据没有创建时间
        table.insert( ret, info )
    end

    table.sort( ret, function(l, r)
        if l.createTime < r.createTime then return true end
        if l.createTime > r.createTime then return false end
        return false
    end)

    local list = self:resetListView("ListView")

    for i = 1, #ret do
        local panel = self.voicePanel:clone()
        self:setUnitVoicePanel(ret[i], panel)
        list:pushBackCustomItem(panel)

        if ret[i].fileName == defSelectName then
            self:onSelectVoice(panel)
        end

        if not defSelectName and i == 1 then
            self:onSelectVoice(panel)
        end
    end

    if #ret == 0 then
        self:onAddVoice(self:getControl("AddPanel"))
    end

    -- 声音数量 < 5 隐藏 AddPanel
    self:setCtrlVisible("AddPanel", #ret < 5, "VoiceListPanel")
    self:setCtrlVisible("NoticePanel", #ret == 0, "VoiceListPanel")
end

function GoodVoiceMineDlg:setUnitVoicePanel(data, panel)
    panel.data = data
    -- 封面
   -- self:setImage("GuardImage", "ui/Icon1551.png", panel)

    -- 声音名字
    self:setLabelText("NameLabel", data.title, panel)

    -- 时长
    local voiceTime = data.voiceTime / 1000
    local m = math.floor( voiceTime / 60 )
    local s = voiceTime % 60
    self:setLabelText("LongLabel", string.format( CHS[4200673], m, s), panel)
end

function GoodVoiceMineDlg:setPlayerTime(data)
    -- 当前
    self:setLabelText("StarTimeLabel", "00:00")

    if not data then
        data = {}
    end

    -- 总时间
    local voiceTime = data.voiceTime
    if not voiceTime then voiceTime = 0 end
	voiceTime = math.floor(voiceTime / 1000)


    local m = math.floor( voiceTime / 60 )
    local s = voiceTime % 60
    self:setLabelText("EndTimeLabel", string.format( "%02d:%02d", m, s))

    -- 清空进度条
    self:setProgressBar("ProgressBar", 0, 100)
    local bar = self:getControl("ProgressBar")
    bar:stopAllActions()

    self:setLabelText("TimeLabel", CHS[4200696], "TimeNumBKImage")
end


function GoodVoiceMineDlg:setVoiceInfo(data)
	if not data then
		self:onFieldDelButton(self:getControl("DelButton", nil, "MessageInputPanel"))
		self:onFieldDelButton(self:getControl("DelButton", nil, "TitleInputPanel"))
		return
	end

    local parentPanel = self:getControl("TitleInputPanel")
    local textCtrl = self:getControl("TextField", nil, parentPanel)
    textCtrl:setText(data.title or "")
    self:setCtrlVisible("DelButton", false, parentPanel)
    self:setCtrlVisible("DefaultLabel", false, parentPanel)

    local parentPanel = self:getControl("MessageInputPanel")
    local textCtrl = self:getControl("TextField", nil, parentPanel)
    textCtrl:setText(data.message or "")
    self:setCtrlVisible("DelButton", false, parentPanel)
    self:setCtrlVisible("DefaultLabel", false, parentPanel)

    self:setPlayerTime(data)
end

function GoodVoiceMineDlg:onSelectVoice(sender, eventType)
	if self.selectVoiceImage:getParent() == sender then
		-- 重复点击
		return
	end

    self.selectVoiceImage:removeFromParent()
    sender:addChild(self.selectVoiceImage)


    self.selectVoice = sender.data
    self.curTime = 0

    if self.state == STATE.RECORDING then
        -- 正在录音中
        SoundMgr:endRecordForGoodVoice()        -- 结束录音
        GoodVoiceMgr:stopPlayGoodVoiceAndReplayMusic()
    elseif self.state == STATE.PLAYING then

        GoodVoiceMgr:stopPlayGoodVoiceAndReplayMusic()
    end
    self.state = nil

    if self.timerId then
        gf:ShowSmallTips(CHS[4200695])    -- 界面状态发生变化，本次录音失败。
        self:getControl("ProgressPanel", nil, "VoicePlayerPanel2"):stopAllActions()
        self.timerId = nil
    end

    if self.coverTimer then
        self:stopSchedule(self.coverTimer)
        self.coverTimer = nil
    end

    self.curVoice = sender.data.fileName

    self:setPlayState(false)
    self:setVoiceInfo(sender.data)
    self:setButtonState(4)
end

function GoodVoiceMineDlg:onAddVoice(sender, eventType)

	if self.selectVoiceImage:getParent() == sender then
		-- 重复点击
		return
	end

    if self.state == STATE.RECORDING then
        -- 正在录音中
        SoundMgr:endRecordForGoodVoice()        -- 结束录音
        GoodVoiceMgr:stopPlayGoodVoiceAndReplayMusic()
    elseif self.state == STATE.PLAYING then
        GoodVoiceMgr:stopPlayGoodVoiceAndReplayMusic()
    end
    self.state = nil


    if self.timerId then
        gf:ShowSmallTips(CHS[4200695])    -- 界面状态发生变化，本次录音失败。
        self:getControl("ProgressPanel", nil, "VoicePlayerPanel2"):stopAllActions()
        self.timerId = nil
    end

    if self.coverTimer then
        self:stopSchedule(self.coverTimer)
        self.coverTimer = nil
    end

    self.selectVoiceImage:removeFromParent()
    sender:addChild(self.selectVoiceImage)

    self.selectVoice = sender.data
--	ChatMgr:clearRecord()
	SoundMgr:replayMusicAndSound()
    self:resetVoiceAction()
    self:setPlayState(false)
    self:setButtonState(1)

	self:setVoiceInfo(sender.data)

    local panel = self:getControl("ProgressPanel")
    panel:stopAllActions()
    local progressTimer = panel:getChildByName("ProgressTimer")
    local progressTo = cc.ProgressTo:create(time, 100)
    progressTimer:setPercentage(0)
end


function GoodVoiceMineDlg:onMyCompetitionVoiceButton(sender, eventType)
    local data = GoodVoiceMgr.myVoiceData
    if not data or data.voice_id == "" then
        gf:ShowSmallTips(CHS[4200674])
        return
    end

    if self.state == STATE.RECORDING then
        -- 正在录音中
        self:onStopButton(self:getControl("StopButton"))
    elseif self.state == STATE.PLAYING then
        self:onPlayButton()
    end
    self.state = nil

    gf:CmdToServer("CMD_GOOD_VOICE_QUERY_VOICE", {voice_id = data.voice_id})
end

function GoodVoiceMineDlg:onFieldDelButton(sender, eventType)
    local parentPanel = sender:getParent()
    local textCtrl = self:getControl("TextField", nil, parentPanel)
    textCtrl:setText("")
    sender:setVisible(false)
    self:setCtrlVisible("DefaultLabel", true, parentPanel)
end

function GoodVoiceMineDlg:onDelVoiceButton(sender, eventType)
    gf:confirm(CHS[4200675], function ()
        --gf:ShowSmallTips("删除该声音")
        GoodVoiceMgr:deleteVoice(self.selectVoice)
        self:setMyVoiceList()
        gf:ShowSmallTips(CHS[4200702])    -- 声音删除成功！
    end)
end

function GoodVoiceMineDlg:onSaveButton(sender, eventType)

    local title = self:getInputText("TextField", "TitleInputPanel")
    local message = self:getInputText("TextField", "MessageInputPanel")

    if title == "" then
        gf:ShowSmallTips(CHS[4200697])      -- 请输入声音标题。
        return
    end

    if message == "" then
        gf:ShowSmallTips(CHS[4200698])    -- 请输入声音寄语。
        return
    end

    if not self.curVoice then
        return
    end

    local voiceTime = SoundMgr:getMusicDurationByNameForGoodVoice(self.curVoice)
    local fileName = self.curVoice
    if voiceTime < 30000 or voiceTime > 63000 then  -- 63秒，容错下
        gf:ShowSmallTips(CHS[4200699])
        return
    end

    gf:confirm(CHS[4200676], function ()
        GoodVoiceMgr:refreshLocalVoice({title = title, message = message, fileName = fileName, voiceTime = voiceTime, createTime = gf:getServerTime()})
        self:setMyVoiceList(fileName)
    end)

end

function GoodVoiceMineDlg:onReButton(sender, eventType)
    gf:confirm(CHS[4200693], function ()
		--ChatMgr:clearRecord()
        if SoundMgr.curMediaFileForGV and SoundMgr.curMediaFileForGV ~= "" then
            os.remove(SoundMgr.curMediaFileForGV)
            SoundMgr.curMediaFileForGV = nil
        end
        self:onBeginButton(self:getControl("BeginButton"), nil, true)
    end)
end

function GoodVoiceMineDlg:onFinishUploadVoice(files, uploads)
    gf:closeConfirmByType("GoodVoiceMineDlgUpLoad")

    if #files ~= #uploads then
        gf:ShowSmallTips(CHS[2000463])
        return
    end

    local title = self:getInputText("TextField", "TitleInputPanel")
    local message = self:getInputText("TextField", "MessageInputPanel")
    local fileName = self.curVoice

	local voiceTime = SoundMgr:getMusicDurationByNameForGoodVoice(self.curVoice)


   -- GoodVoiceMgr:refreshLocalVoice({title = title, message = message, fileName = fileName, voiceTime = voiceData.voiceTime})
	--gf:ShowSmallTips("传服务器，地增" .. uploads[1])
	--gf:ShowSmallTips("实际录音时间" .. voiceData.voiceTime)

   -- gf:ShowSmallTips("传服务器，地址" .. uploads[1])
    gf:CmdToServer("CMD_GOOD_VOICE_UPLOAD", {title = title, voice_desc = message, voice_addr = uploads[1], voice_dur = math.floor(voiceTime / 1000)})
end


-- 保存、上传
function GoodVoiceMineDlg:onCompetitionButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 声音上传时间已过，无法上传声音。
    local timeData = GoodVoiceMgr.seasonData
    if gf:getServerTime() > timeData.upload_end then
        gf:ShowSmallTips(CHS[4200694])
        return
    end

	local title = self:getInputText("TextField", "TitleInputPanel")
    local message = self:getInputText("TextField", "MessageInputPanel")

    if title == "" then
        gf:ShowSmallTips(CHS[4200697])
        return
    end

    if message == "" then
        gf:ShowSmallTips(CHS[4200698])
        return
    end

    gf:confirm(CHS[4200708], nil, nil, nil, nil, nil, nil, true, "GoodVoiceMineDlgUpLoad")

    BlogMgr:cmdUpload(BLOG_OP_TYPE.GOOD_VOICE, self.name, "onFinishUploadVoice", self.curVoice)
end

--==============================--
--desc: 设置按钮状态
--time:2019-03-18 03:16:42
--@stage: 1：待录音         2：录音过程中         3：录音完成      4，选择已经完成的
--@return
--==============================--
function GoodVoiceMineDlg:setButtonState(stage)
    local panel = self:getControl("ButtonPanel")
    self:setCtrlVisible("BeginButton", false, panel)
    self:setCtrlVisible("DelButton", false, panel)
    self:setCtrlVisible("ReButton1", false, panel)
    self:setCtrlVisible("ReButton2", false, panel)

    self:setCtrlVisible("CompetitionButton", false, panel)
    self:setCtrlVisible("StopButton", false, panel)
    self:setCtrlVisible("SaveButton", false, panel)
    self:setCtrlVisible("Image1", true, panel)

    self:setCtrlVisible("VoicePlayerPanel1", false)
    self:setCtrlVisible("VoicePlayerPanel2", false)

    if stage == 1 then
        self:setCtrlVisible("BeginButton", true, panel)
        self:setCtrlVisible("VoicePlayerPanel2", true)
        self:setCtrlVisible("Image1", false, panel)
    elseif stage == 2 then
        self:setCtrlVisible("StopButton", true, panel)
        self:setCtrlVisible("VoicePlayerPanel2", true)
        self:setCtrlVisible("Image1", false, panel)
    elseif stage == 3 then
        self:setCtrlVisible("VoicePlayerPanel1", true)
        --self:setCtrlVisible("DelButton", true, panel)
         self:setCtrlVisible("ReButton2", true, panel)
        self:setCtrlVisible("SaveButton", true, panel)
    elseif stage == 4 then
        self:setCtrlVisible("VoicePlayerPanel1", true)
        self:setCtrlVisible("DelButton", true, panel)
        self:setCtrlVisible("CompetitionButton", true, panel)
    end
end

function GoodVoiceMineDlg:onBeginButton(sender, eventType, isReBegin)
--[[
    if gf:isWindows() then
        self:setButtonState(3)
        self:setPlayState(false)
        SoundMgr.curMediaFileForGV = ChatMgr:getMediaSavePath() .. "forText.mp3"
        self:onEndRecordCallBack()
        return
    end
--]]

    if DeviceMgr:checkEmulator() then
        gf:ShowSmallTips(CHS[4300489])
        return
    end

    if SoundMgr.curMediaFileForGV then
        gf:ShowSmallTips(CHS[3003948])
        return false
    end

	if not SoundMgr:beginRecordForGoodVoice(nil, isReBegin) then return end
end


function GoodVoiceMineDlg:waitForSoundMgrBeginOK()
    -- body
    self.state = STATE.RECORDING
    self:playVoiceCountDown(self:getControl("ProgressPanel", nil, "VoicePlayerPanel2"), 60)
    self:setButtonState(2)
end

-- 显示语音面板
function GoodVoiceMineDlg:createVoicePanel(root)
    local panel = self:getControl("ProgressPanel", nil, root)
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

function GoodVoiceMineDlg:resetVoiceAction()
    local panel = self:getControl("ProgressPanel")
    panel:stopAllActions()
    local progressTimer = panel:getChildByName("ProgressTimer")
    progressTimer:stopAllActions()
    progressTimer:setPercentage(0)
end

function GoodVoiceMineDlg:playVoiceCountDown(panel, time)
    local sec = 0
    local progressTimer = panel:getChildByName("ProgressTimer")
    local progressTo = cc.ProgressTo:create(time, 100)
    progressTimer:setPercentage(0)
    self:setLabelText("TimeLabel", string.format(CHS[2000462], sec), panel:getParent())
    progressTimer:runAction(progressTo)
    self.timerId = schedule(panel, function()
        sec = sec + 1
        if sec <= time then
            self:setLabelText("TimeLabel", string.format(CHS[2000462], sec), panel:getParent())
        else
            self:setLabelText("TimeLabel", string.format(CHS[2000462], sec), panel:getParent())
            panel:stopAllActions()
            self.timerId = nil
            self:setButtonState(3)
            self:setPlayState(false)
            SoundMgr:endRecordForGoodVoice()
            SoundMgr:setLastBGMusicFileName("")
            GoodVoiceMgr:stopPlayGoodVoiceAndReplayMusic()
        end
    end, 1)
end

function GoodVoiceMineDlg:onClickBlank()
    if self.state == STATE.RECORDING then
        return true
    else
        return false
    end
end


-- 点击播放、停止按钮
function GoodVoiceMineDlg:onPlayButton(sender)
    if string.isNilOrEmpty(self.curVoice) then
        return
    end

    local isPlayering = self:setPlayState()

    -- 进度条!!!!!!!!
    local voiceTime = SoundMgr:getMusicDurationByNameForGoodVoice(self.curVoice)
    voiceTime = math.floor(voiceTime / 1000)
    if isPlayering then

        -- 部分手机出现播放音乐立即关闭后，再次播放获取进度一直为0情况，详见WDSY-36841
        gf:frozenScreen(500)

        SoundMgr:stopMusicAndSound()
        SoundMgr:setLastBGMusicFileName(self.curVoice)
        AudioEngine.playMusic(self.curVoice, false)

        if self.curTime > 0 then
            performWithDelay(self.root, function()
                if 'function' == type(AudioEngine.seekMusic) then
                    AudioEngine.seekMusic(self.curTime)
                elseif 'function' == type(cc.SimpleAudioEngine:getInstance().seekMusic) then
                    cc.SimpleAudioEngine:getInstance():seekMusic(self.curTime)
                end
            end, 0)
        end

        self.state = STATE.PLAYING
        local curTicket = gfGetTickCount()

        self.coverTimer = self:startSchedule(function ()
            local curTime = AudioEngine.getMusicPostion()
            local maxTime = AudioEngine.getMusicDuration()
            curTime = math.floor( curTime / 1000 )
            local m = math.floor( curTime / 60 )
            local s = curTime % 60
            -- 当前
            self:setLabelText("StarTimeLabel", string.format( "%02d:%02d", m, s))

            self:setProgressBar("ProgressBar", curTime /  math.floor(maxTime * 0.001) * 100, 100)

            if curTime >= math.floor( maxTime / 1000 ) then
                if self.coverTimer then
                    self:stopSchedule(self.coverTimer)
                    self.coverTimer = nil
                    self:setPlayerTime({voiceTime = voiceTime * 1000})
                    GoodVoiceMgr:stopPlayGoodVoiceAndReplayMusic()
					self:setPlayState(false)
                    self:setProgressBar("ProgressBar", 0, 100)
                    self.state = nil
                end
            end
        end, 0)
    else
        if self.coverTimer then
            self:stopSchedule(self.coverTimer)
            self.coverTimer = nil
        end
        self.state = nil
        self.curTime = AudioEngine.getMusicPostion() or 0
        GoodVoiceMgr:stopPlayGoodVoiceAndReplayMusic()
    end
end

function GoodVoiceMineDlg:stopPlayVoice()
  --  ChatMgr:setIsPlayingVoice(false)
  --  SoundMgr:replayMusicAndSound()
   -- AudioEngine.pauseMusic()
  --  ChatMgr:stopPlayRecord()
  --  self:setPlayState(false)
end

function GoodVoiceMineDlg:onEndRecordCallBack()

    if self.state == STATE.RECORDING then
        self.state = nil
    end

    if self.selectVoiceImage:getParent() and self.selectVoiceImage:getParent():getName() ~= "AddPanel" then
        os.remove(SoundMgr.curMediaFileForGV)
        return
    end

    self.curVoice = SoundMgr.curMediaFileForGV
    local duration = SoundMgr:getMusicDurationByNameForGoodVoice(self.curVoice)

    if duration <= 1000 then
        os.remove(self.curVoice)
        gf:ShowSmallTips(CHS[4300488])
        self:setButtonState(1)
        self.curVoice = nil
        
        self:resetVoiceAction()
        
        return
    end

    self:setPlayerTime({voiceTime = duration})

    if self.selectVoiceImage:getParent() and self.selectVoiceImage:getParent():getName() ~= "AddPanel" then
        os.remove(self.curVoice)
    end
end

function GoodVoiceMineDlg:onStopButton(sender, eventType)
    local voiceData
	if sender then
		-- 玩家主动点击的
		--ChatMgr:endRecord(self, self:getControl("BeginButton"))
        SoundMgr:endRecordForGoodVoice()
        SoundMgr:setLastBGMusicFileName("")
        GoodVoiceMgr:stopPlayGoodVoiceAndReplayMusic()
	end

	self:resetVoiceAction()
    self:setButtonState(3)

  --  local duration = SoundMgr:getMusicDuration(self.curVoice)
  --  self:setPlayerTime({voiceTime = duration})
    if self.timerId then
        self:getControl("ProgressPanel", nil, "VoicePlayerPanel2"):stopAllActions()
        self.timerId = nil
    end
end

function GoodVoiceMineDlg:onSelectListView(sender, eventType)
end

-- 音量变化
function GoodVoiceMineDlg:onVolumeChange(volume)
    local panel = self:getControl("ShowPanel", nil, "VoicePlayerPanel2")
    self:setCtrlVisible("VolumeImage1", volume > 10 and volume <= 25, panel)
    self:setCtrlVisible("VolumeImage2", volume > 25 and volume <= 50, panel)
    self:setCtrlVisible("VolumeImage3", volume > 50 and volume <= 75, panel)
    self:setCtrlVisible("VolumeImage4", volume > 75, panel)
    return true
end

function GoodVoiceMineDlg:MSG_CLIENT_DISCONNECTED(data)
    DlgMgr:closeDlg("GoodVoiceMineDlg")
end


return GoodVoiceMineDlg
