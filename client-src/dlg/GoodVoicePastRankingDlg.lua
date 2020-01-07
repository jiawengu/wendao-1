-- GoodVoicePastRankingDlg.lua
-- Created by
--

local GoodVoicePastRankingDlg = Singleton("GoodVoicePastRankingDlg", Dialog)

function GoodVoicePastRankingDlg:init()

    self:bindListener("SessionButton", self.onSessionButton)
    self.rankingPanel = self:retainCtrl("RankingPanel")
    self.selectImage = self:retainCtrl("SelectedImage", self.rankingPanel)
    self.selectImage:setVisible(true)
    self:bindListener("Button2", self.onButton2, self.rankingPanel)
    self:bindListener("Button1", self.onButton1, self.rankingPanel)

    self:bindTouchEndEventListener(self.rankingPanel, self.onRankingPanel)

    self:queryRanking(GoodVoiceMgr.seasonData.season_no)

    -- 初始化选中
    self:setLabelText("Label", string.format( CHS[4010319], gf:numberToChs(GoodVoiceMgr.seasonData.season_no)), "SessionButton")

    self.seasonBtn = self:retainCtrl("SelectButton")
    self:bindTouchEndEventListener(self.seasonBtn, self.onSeasonBtn)
    local list = self:resetListView("LevelListView", 2, ccui.ListViewGravity.centerHorizontal)
    for i = GoodVoiceMgr.seasonData.season_no, 1, -1 do
        local btn = self.seasonBtn:clone()
        btn:setTag(i)
        local str = string.format( CHS[4010319], gf:numberToChs(i))
        btn:setTitleText(str)
        list:pushBackCustomItem(btn)
    end

    self:bindFloatingEvent("SessionFloatPanel")

    self:hookMsg("MSG_GOOD_VOICE_RANK_LIST")

    self:hookMsg("MSG_GOOD_VOICE_SCORE_DATA")
end

function GoodVoicePastRankingDlg:queryRanking(season_no)
    self.curSeason = season_no
    gf:CmdToServer("CMD_GOOD_VOICE_RANK_LIST", {season_no = season_no})
end


--[[
INF : GoodVoicePastRankingDlg:SelectButton receive event:2
[LUA-print] DEBUG : [SEND CMD : CMD_GOOD_VOICE_RANK_LIST]  [ConnectType:1]
[LUA-print] DEBUG : { season_no=2,  }
[LUA-print] DEBUG : [RECV MSG : MSG_GOOD_VOICE_RANK_LIST]  [ConnectType:1]
[LUA-print] DEBUG : ---- rankInfo={  }
[LUA-print] DEBUG : { timestamp=2124753, MSG=21048, season_no=2, count=0, socket
_no=101, connect_type=1,  }
WARNNING : MSG_GOOD_VOICE_RANK_LIST has no callback func.
Inner width <= scrollview width, it will     be force sized!
Inner height <= scrollview height, it will be force sized!




]]


function GoodVoicePastRankingDlg:setRankingList(data)
    local list = self:resetListView("RankingListView")

    for i = 1, data.count do
        local panel = self.rankingPanel:clone()
        list:pushBackCustomItem(panel)
        self:setUnitRankingPanel(data.rankInfo[i], panel, i)
    end

    self:setCtrlVisible("NoticePanel", data.count == 0)
end

function GoodVoicePastRankingDlg:onRankingPanel(sender, eventType)
    self.selectImage:removeFromParent()
    sender:addChild(self.selectImage)
end

--[[
    [LUA-print] DEBUG : -------- 20={ icon_img=, voice_addr=一二三四五六七八九十一二
三四五六七八九十, voice_id=now_dist|5979A913007A41000100|5C93381100B2B5000E01, v
oice_title=p0059的声音, name=p0059, score=65,  }
]]

function GoodVoicePastRankingDlg:setUnitRankingPanel(data, panel, i)
    panel.data = data

    -- 名次
    local rankingPanel = self:getControl("RankingNumPanel", nil, panel)
    self:setCtrlVisible("RankingImage1", false, rankingPanel)
    self:setCtrlVisible("RankingImage2", false, rankingPanel)
    self:setCtrlVisible("RankingImage3", false, rankingPanel)
    if i <= 3 then
        self:setCtrlVisible("RankingImage" .. i, true, rankingPanel)
    else
      --  self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT, i, false, LOCATE_POSITION.MID, 19, rankingPanel)

        local numLayer = GoodVoiceMgr:generateScore(i)
        local destPanel = self:getControl("NumPanel", nil, rankingPanel)
        numLayer:setPosition(destPanel:getContentSize().width * 0.5, numLayer:getContentSize().height )-- - numLayer:getContentSize().height * 0.5
        destPanel:addChild(numLayer)

    end

    -- 歌曲信息
    self:setLabelText("VoiceNameLabel", data.voice_title, panel)

    -- 打分
    --local scorePanel = self:getControl("FractionPanel", nil, panel)
    --self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT, data.score, false, LOCATE_POSITION.MID, 19, scorePanel)

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
    -- 玩家名字
    self:setLabelText("PlayerNameLabel", data.name, panel)

    self:setCtrlVisible("BackImage2", i % 2 == 0, panel)

    local headPanel = self:getControl("HeadPanel", nil, panel)
    if string.len( data.icon_img ) <= 5 then
        --self:setImage("Image", ResMgr:getBigPortrait(tonumber(data.icon_img)), headPanel)
        local resIcon = ResMgr:getSmallPortrait(tonumber(data.icon_img))
        self:setImage("Image", resIcon, headPanel)
    else
        BlogMgr:assureFile("setPhoto", self.name, data.icon_img, nil, i)
    end
end

function GoodVoicePastRankingDlg:setPhoto(path, para)
    if not path or path == "" then return end

    local row = tonumber(para)
    local list = self:getControl("RankingListView")
    local items = list:getItems()

    local rowPanel = items[row]
    if not rowPanel then return end

    local destPanel = self:getControl("HeadPanel", nil, rowPanel)
    self:setImage("Image", path, destPanel)

    list:requestRefreshView()
end

function GoodVoicePastRankingDlg:onButton2(sender, eventType)
    local panel = sender:getParent()
    local data = panel.data
    --ChatMgr:playRecord(data.voice_addr, 0, true)
    gf:CmdToServer("CMD_GOOD_VOICE_QUERY_VOICE", {voice_id = data.voice_id, open_type = 1})
end

function GoodVoicePastRankingDlg:onButton1(sender, eventType)
    local panel = sender:getParent()

    local data = panel.data
    local season_no = self.curSeason

    gf:CmdToServer("CMD_GOOD_VOICE_SCORE_DATA", {season_no = season_no, voice_id = data.voice_id})
end


function GoodVoicePastRankingDlg:onSessionButton(sender, eventType)
    self:setCtrlVisible("SessionFloatPanel", true)
end

function GoodVoicePastRankingDlg:onSeasonBtn(sender, eventType)
    self:queryRanking(sender:getTag())
    self:setCtrlVisible("SessionFloatPanel", false)

        -- 初始化选中
    self:setLabelText("Label", string.format( CHS[4010319], gf:numberToChs(sender:getTag())), "SessionButton")

    self:resetListView("RankingListView")
end

function GoodVoicePastRankingDlg:onSelectRankingListView(sender, eventType)
end

function GoodVoicePastRankingDlg:MSG_GOOD_VOICE_RANK_LIST(data)
    if self.curSeason ~= data.season_no then return end
    self:setRankingList(data)
end

function GoodVoicePastRankingDlg:MSG_GOOD_VOICE_SCORE_DATA(data)
    DlgMgr:openDlgEx("GoodVoiceCommentDlg", data)
end

return GoodVoicePastRankingDlg


