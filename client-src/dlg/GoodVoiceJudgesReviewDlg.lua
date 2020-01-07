-- GoodVoiceJudgesReviewDlg.lua
-- Created by
--

local GoodVoiceJudgesReviewDlg = Singleton("GoodVoiceJudgesReviewDlg", Dialog)

function GoodVoiceJudgesReviewDlg:init()

    self:bindListener("SelectButton", self.onSelectButton)
    self:bindListViewListener("ListView", self.onSelectListView)
    self:bindListViewListener("LevelListView", self.onSelectLevelListView)

    self.voicePanel = self:retainCtrl("VoicePanel")
    self.selectImage = self:retainCtrl("SelectedImage", self.voicePanel)
    self:bindListener("Button2", self.onButton2, self.voicePanel)
    self:bindListener("Button1", self.onButton1, self.voicePanel)

   -- self:bindTouchEndEventListener(self.voicePanel, self.onVoicePanel)

    gf:CmdToServer("CMD_GOOD_VOICE_FINAL_VOICES", {day_index = 0})

    self:hookMsg("MSG_GOOD_VOICE_FINAL_VOICES")
    self:hookMsg("GOOD_VOICE_FINAL_SHOW_DATA_FOR_JUDGE")


    self:hookMsg("MSG_GOOD_VOICE_SCORE_DATA")
end

function GoodVoiceJudgesReviewDlg:onButton2(sender, eventType)
    local panel = sender:getParent()
    local data = panel.data
    gf:CmdToServer("CMD_GOOD_VOICE_QUERY_VOICE", {voice_id = data.id})
end

function GoodVoiceJudgesReviewDlg:onButton1(sender, eventType)
    DlgMgr:openDlgEx("GoodVoiceJudgesScoringDlg", sender:getParent().data)
end

function GoodVoiceJudgesReviewDlg:onSelectButton(sender, eventType)
end

function GoodVoiceJudgesReviewDlg:onSelectListView(sender, eventType)
end

function GoodVoiceJudgesReviewDlg:onSelectLevelListView(sender, eventType)
end

function GoodVoiceJudgesReviewDlg:setPhoto(path, para)

    local idx = tonumber(para)

    local list = self:getControl("ListView")
    local items = list:getItems()

    local rowPanel = items[idx]
    if not rowPanel then return end
    local destPanel = self:getControl("HeadPanel", nil, rowPanel)
    self:setImage("Image", path, destPanel)

    list:requestRefreshView()
end

function GoodVoiceJudgesReviewDlg:setUnitVoicePanel(data, panel, i)
    panel.data = data

    self:setCtrlVisible("RankingNumPanel", false, panel)

    -- 歌曲信息
    self:setLabelText("VoiceNameLabel", data.voice_title, panel)

    -- 打分
    local scorePanel = self:getControl("FractionPanel", nil, panel)
    if data.score < 0 then
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

    -- 玩家名字
    self:setLabelText("PlayerNameLabel", data.name, panel)

    local headPanel = self:getControl("HeadPanel", nil, panel)
    if string.len( data.icon_img ) <= 5 then
     --   self:setImage("Image", ResMgr:getBigPortrait(tonumber(data.icon_img)), headPanel)
        local resIcon = ResMgr:getSmallPortrait(tonumber(data.icon_img))
        self:setImage("Image", resIcon, headPanel)
    else
        BlogMgr:assureFile("setPhoto", self.name, data.icon_img, nil, i)
    end

    self:setCtrlVisible("BackImage2", i % 2 == 0, panel)
end

function GoodVoiceJudgesReviewDlg:setRankingList(data)
    local list = self:resetListView("ListView")
    local count = #data.voiceData

    for i = 1, count do
        local panel = self.voicePanel:clone()
        list:pushBackCustomItem(panel)
        self:setUnitVoicePanel(data.voiceData[i], panel, i)
    end

    self:setCtrlVisible("NoticePanel", false)
end


function GoodVoiceJudgesReviewDlg:GOOD_VOICE_FINAL_SHOW_DATA_FOR_JUDGE(data)
    self:MSG_GOOD_VOICE_FINAL_VOICES(data)
end

function GoodVoiceJudgesReviewDlg:MSG_GOOD_VOICE_FINAL_VOICES(data)
    -- 列表
    self:setRankingList(data)


end

return GoodVoiceJudgesReviewDlg
