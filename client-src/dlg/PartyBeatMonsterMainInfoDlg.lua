-- PartyBeatMonsterMainInfoDlg.lua
-- Created by songcw Oct/09/2017
-- 挑战巨兽排行榜

local PartyBeatMonsterMainInfoDlg = Singleton("PartyBeatMonsterMainInfoDlg", Dialog)

function PartyBeatMonsterMainInfoDlg:init(data)


    self:bindListener("BeatPanel", self.onBeatPanel, "ShrinkPanel")
	self:bindListener("BeatPanel", self.onBeatPanel, "ExpandPanel")
    self:bindListener("PartyWarButton", self.onPartyWarButton)
    self:bindListener("ShrinkTimePanel", self.onShrinkTimePanel)
    self:bindListener("ExpandTimePanel", self.onExpandTimePanel)
    self:bindListViewListener("RankingListView", self.onSelectRankingListView)

    self.unitPlayerPanel = self:retainCtrl("ContentPanel")

    self.lastTime = nil
    self.data = data

    self:setPlayersContribution(data)
    self:hookMsg("MSG_PARTY_TZJS_RANK_INFO")

    self:showMainPanel()
    self:onExpandTimePanel()
end

function PartyBeatMonsterMainInfoDlg:onUpdate()
    if not self.data then return end
    if gf:getServerTime() > self.data.end_time then
        DlgMgr:closeDlg(self.name)
        return
    end

    local time = math.min(30, math.ceil((self.data.end_time - gf:getServerTime()) / 60))
    time = math.max(1, time)

    self:setLabelText("LeftTimeLabel_1", string.format(CHS[4300223], time), "ShrinkTimePanel")
    self:setLabelText("LeftTimeLabel_2", string.format(CHS[4300223], time), "ShrinkTimePanel")

    self:setLabelText("LeftTimeLabel_1", string.format(CHS[4300223], time), "ExpandTimePanel")
    self:setLabelText("LeftTimeLabel_2", string.format(CHS[4300223], time), "ExpandTimePanel")

    if not self.lastTime then
        self.lastTime = gf:getServerTime()
    else
        if gf:getServerTime() - self.lastTime >= 10 then
            -- 10秒请求数据
            PartyMgr:queryTZJSInfo()
            self.lastTime = gf:getServerTime()
        end
    end
end


-- 设置贡献度排名
function PartyBeatMonsterMainInfoDlg:setPlayersContribution(data)
    local list = self:resetListView("RankingListView")

    if not data or data.count <= 0 then
        self:setCtrlVisible("NoneLabel", true)
        local myRankInfo = {name = Me:queryBasic("name"), contrib = 0}
        local expPanel = self:getControl("MyRankingPanel", nil, "ExpandPanel")
        self:setUnitPanel(myRankInfo, 0, expPanel)

        local shrinkPanel = self:getControl("MyRankingPanel", nil, "ShrinkPanel")
        self:setUnitPanel(myRankInfo, 0, shrinkPanel)
        return
    end

    self:setCtrlVisible("NoneLabel", false)

    local myRankInfo
    local myRank
    for i = 1, data.count do
        if data[i].contrib > 0 then
            local panel = self.unitPlayerPanel:clone()
            panel.userInfo = data[i]
            self:setUnitPanel(data[i], i, panel)
            list:pushBackCustomItem(panel)
        end

        if data[i].name == Me:queryBasic("name") then
            myRankInfo = data[i]
            myRank = i
        end
    end

    if myRankInfo then
        local expPanel = self:getControl("MyRankingPanel", nil, "ExpandPanel")
        self:setUnitPanel(myRankInfo, myRank, expPanel)

        local shrinkPanel = self:getControl("MyRankingPanel", nil, "ShrinkPanel")
        self:setUnitPanel(myRankInfo, myRank, shrinkPanel)
    else
        myRankInfo = {name = Me:queryBasic("name"), contrib = 0}
        local expPanel = self:getControl("MyRankingPanel", nil, "ExpandPanel")
        self:setUnitPanel(myRankInfo, 0, expPanel)

        local shrinkPanel = self:getControl("MyRankingPanel", nil, "ShrinkPanel")
        self:setUnitPanel(myRankInfo, 0, shrinkPanel)
    end

    if #list:getItems() == 0 then
        self:setCtrlVisible("NoneLabel", true)
    end
end

function PartyBeatMonsterMainInfoDlg:setUnitPanel(data, rank, panel)
    if not rank or data.contrib <= 0 then
        self:setLabelText("TitleLabel1", CHS[4100388], panel)
    else
        self:setLabelText("TitleLabel1", rank, panel)
        self:setCtrlVisible("BKImage", rank % 2 == 1, panel)
    end

    self:setLabelText("TitleLabel2", data.name, panel)

    self:setLabelText("TitleLabel3", data.contrib, panel)
end

-- 隐藏主要面板
function PartyBeatMonsterMainInfoDlg:hideMainPanel()
    self:setCtrlVisible("MainPanel", false)

    self:setCtrlVisible("PartyWarButton", true)
end

-- 显示主要面板
function PartyBeatMonsterMainInfoDlg:showMainPanel()
    self:setCtrlVisible("MainPanel", true)

    self:setCtrlVisible("PartyWarButton", false)
end

function PartyBeatMonsterMainInfoDlg:onCloseButton(sender, eventType)
    self:hideMainPanel()

    self:setCtrlVisible("PartyWarButton", true)
end

function PartyBeatMonsterMainInfoDlg:onBeatPanel(sender, eventType)
    local task = TaskMgr:getTaskByName(CHS[4100784])
    if not task then
		DlgMgr:closeDlg(self.name)
        return
    end
    local decStr = task.task_prompt
    AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
end


function PartyBeatMonsterMainInfoDlg:onPartyWarButton(sender, eventType)
    self:showMainPanel()
    PartyMgr:queryTZJSInfo()

    self:setCtrlVisible("PartyWarButton", false)
end

function PartyBeatMonsterMainInfoDlg:onShrinkTimePanel(sender, eventType)
    self:setCtrlVisible("ExpandPanel", true)
    self:setCtrlVisible("ShrinkPanel", false)


end

function PartyBeatMonsterMainInfoDlg:onExpandTimePanel(sender, eventType)
    self:setCtrlVisible("ExpandPanel", false)
    self:setCtrlVisible("ShrinkPanel", true)

end

function PartyBeatMonsterMainInfoDlg:onSelectRankingListView(sender, eventType)
end

function PartyBeatMonsterMainInfoDlg:MSG_PARTY_TZJS_RANK_INFO(data)
    self.data = data

    self:setPlayersContribution(data)
end


return PartyBeatMonsterMainInfoDlg
