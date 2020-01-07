-- GoodVoiceReviewDlg.lua
-- Created by
--

local GoodVoiceReviewDlg = Singleton("GoodVoiceReviewDlg", Dialog)

function GoodVoiceReviewDlg:init()
 --   self:bindListener("Button2", self.onButton2)
 --   self:bindListener("Button1", self.onButton1)
    self:bindListener("SelectButton", self.onSelectButton)
    self:bindListener("DayButton", self.onDayButton)
    self:bindListViewListener("ListView", self.onSelectListView)
    self:bindListViewListener("LevelListView", self.onSelectLevelListView)

    self:setLabelText("PublicLabel", "")

    self.voicePanel = self:retainCtrl("VoicePanel")
    self.selectImage = self:retainCtrl("SelectedImage", self.voicePanel)
    self:bindListener("Button2", self.onButton2, self.voicePanel)
    self:bindListener("Button1", self.onButton1, self.voicePanel)

    self:bindTouchEndEventListener(self.voicePanel, self.onVoicePanel)

    self:bindFloatingEvent("DayFloatPanel")

    gf:CmdToServer("CMD_GOOD_VOICE_FINAL_VOICES", {day_index = 1})

    self:hookMsg("MSG_GOOD_VOICE_FINAL_VOICES")

    self:hookMsg("MSG_GOOD_VOICE_SCORE_DATA")

--    self:setData()
end

function GoodVoiceReviewDlg:setData()

end

function GoodVoiceReviewDlg:setRankingList(data)
    local list = self:resetListView("ListView")
    local count = #data.voiceData

    for i = 1, count do
        local panel = self.voicePanel:clone()
        list:pushBackCustomItem(panel)
        self:setUnitVoicePanel(data.voiceData[i], panel, i)
    end

    self:setCtrlVisible("NoticePanel", count == 0)
end


function GoodVoiceReviewDlg:setPhoto(path, para)

    local idx = tonumber(para)

    local list = self:getControl("ListView")
    local items = list:getItems()

    local rowPanel = items[idx]
    if not rowPanel then return end

    headPanel = self:getControl("HeadPanel", nil, rowPanel)
    self:setImage("Image", path, headPanel)

    list:requestRefreshView()
end

function GoodVoiceReviewDlg:setUnitVoicePanel(data, panel, i)
    panel.data = data

    self:setCtrlVisible("RankingNumPanel", false, panel)

    -- 歌曲信息
    self:setLabelText("VoiceNameLabel", data.voice_title, panel)

    -- 打分
    local scorePanel = self:getControl("FractionPanel", nil, panel)

    if data.score <= 0 then
        self:setCtrlVisible("NoScoreImage", true, panel)
        self:setCtrlVisible("NumPanel", false, scorePanel)
    else
        self:setCtrlVisible("NumPanel", true, scorePanel)
        self:setCtrlVisible("NoScoreImage", false, panel)
        local numLayer = GoodVoiceMgr:generateScore(data.score)
        numLayer:setScale(0.6)
        local destPanel = self:getControl("NumPanel", nil, scorePanel)
        numLayer:setPosition(destPanel:getContentSize().width * 0.5, numLayer:getContentSize().height )-- - numLayer:getContentSize().height * 0.5
        destPanel:addChild(numLayer)
    end

    --self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.YELLOW, data.score, false, LOCATE_POSITION.MID, 19, scorePanel)

    -- 玩家名字
    self:setLabelText("PlayerNameLabel", data.name, panel)

    local headPanel = self:getControl("HeadPanel", nil, panel)
    if string.len( data.icon_img ) <= 5 then
        --self:setImage("Image", ResMgr:getBigPortrait(tonumber(data.icon_img)), headPanel)
        local resIcon = ResMgr:getSmallPortrait(tonumber(data.icon_img))
        self:setImage("Image", resIcon, headPanel)
    else
        BlogMgr:assureFile("setPhoto", self.name, data.icon_img, nil, i)
    end

    self:setCtrlVisible("BackImage2", i % 2 == 0, panel)
end

function GoodVoiceReviewDlg:onVoicePanel(sender, eventType)
    self.selectImage:removeFromParent()
    sender:addChild(self.selectImage)
end

function GoodVoiceReviewDlg:onButton2(sender, eventType)
    local panel = sender:getParent()
    local data = panel.data
    gf:CmdToServer("CMD_GOOD_VOICE_QUERY_VOICE", {voice_id = data.id})
end

function GoodVoiceReviewDlg:onButton1(sender, eventType)
    local panel = sender:getParent()

    local data = panel.data
    local season_no = GoodVoiceMgr.seasonData.season_no

    gf:CmdToServer("CMD_GOOD_VOICE_SCORE_DATA", {season_no = season_no, voice_id = data.id})
end

function GoodVoiceReviewDlg:onSelectButton(sender, eventType)
    local curStr = sender:getTitleText()
    local toStr = self:getLabelText("Label", "DayButton")
    sender:setTitleText(toStr)
    self:setLabelText("Label", curStr, "DayButton")

    local idx = curStr == CHS[4200680] and 2 or 1

    gf:CmdToServer("CMD_GOOD_VOICE_FINAL_VOICES", {day_index = idx})

    self:setCtrlVisible("DayFloatPanel", false)
end

function GoodVoiceReviewDlg:onDayButton(sender, eventType)
    self:setCtrlVisible("DayFloatPanel", true)
end

function GoodVoiceReviewDlg:onSelectListView(sender, eventType)
end

function GoodVoiceReviewDlg:onSelectLevelListView(sender, eventType)
end

function GoodVoiceReviewDlg:MSG_GOOD_VOICE_FINAL_VOICES(data)
    -- 列表
    self:setRankingList(data)

    -- 分数公布时间
    local timeStr = gf:getServerDate("%Y-%m-%d %H:%M", data.public_time)
    self:setLabelText("PublicLabel", timeStr .. CHS[4200681])
end

function GoodVoiceReviewDlg:MSG_GOOD_VOICE_SCORE_DATA(data)
    DlgMgr:openDlgEx("GoodVoiceCommentDlg", data)
end


return GoodVoiceReviewDlg
