-- ArenaDekaronListDlg.lua
-- Created by songcw Sep/23/2016
-- 擂台调整界面

local ArenaDekaronListDlg = Singleton("ArenaDekaronListDlg", Dialog)

function ArenaDekaronListDlg:init()
    self:bindListener("RefreshButton", self.onRefreshButton)
    self:bindListener("ComparedButton", self.onComparedButton)

    self.unitPlayerPanel = self:getControl("OnePlayerPanel")
    self.unitPlayerPanel:retain()
    self.unitPlayerPanel:removeFromParent()
end

function ArenaDekaronListDlg:setData()
    local data = RingMgr:getChanllengeData()

    -- 设置左边我的排行
    self:setMyInfo(data)

    -- 设置列表
    self:setChanllengeList(data)
end

function ArenaDekaronListDlg:setMyInfo(data)
    local rankingPanel = self:getControl("RankingPanel")

    local myRanl = Me:queryBasicInt("ct_data/top_rank")
    self:setNumImgForPanel("BonusPanel", ART_FONT_COLOR.DEFAULT, myRanl, false, LOCATE_POSITION.MID, 25, rankingPanel)

    -- 设置徽章
    local stage, level, nextScore = RingMgr:getStepAndLevelByScore(Me:queryBasicInt("ct_data/score"))
    self:setImage("SeasonImage", RingMgr:getResIcon(stage), rankingPanel)

    -- 当前阶级
    self:setLabelText("RankStageLabel", RingMgr:getJobChs(stage, level), "StagePanel", RingMgr:getColor(data.curStage))
    self:updateLayout("StagePanel", rankingPanel)

    -- 设置星星
    self:setStar(level, self:getControl("StarPanel"))

    -- 积分进度条
    self:setProgressBar("ExpProgressBar", Me:queryBasicInt("ct_data/score"), nextScore)
    self:setLabelText("ExpvalueLabel", Me:queryBasicInt("ct_data/score") .. "/" .. nextScore)
    self:updateLayout("ExpProgressBarPanel")
end

-- 根据等级设置星星
function ArenaDekaronListDlg:setStar(level, panel)
    for i = 1, 3 do
        self:setCtrlVisible("StarImage_" .. i, (level >= i), panel)
        self:setCtrlVisible("NoneStarImage_" .. i, (level < i), panel)
    end
end

function ArenaDekaronListDlg:setChanllengeList(data)
    local listInfo = data.listInfo
    local list = self:resetListView("SelctionPlayerListView", 3, ccui.ListViewGravity.centerVertical)
    for i = 1, #listInfo do
        local panel = self.unitPlayerPanel:clone()
        self:setUnitPlayerInfo(listInfo[i], panel)
        list:pushBackCustomItem(panel)
    end
end

-- 设置列表单条数据
function ArenaDekaronListDlg:setUnitPlayerInfo(data, panel)
    local stage, level = RingMgr:getStepAndLevelByScore(data.score)
    -- 徽章
    self:setImage("SeasonImage", RingMgr:getResIcon(stage), panel)

    -- 设置星星
    self:setStar(level, panel)

    -- icon
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(data.icon), panel)
    self:setItemImageSize("PortraitImage", panel)
    
    self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- 名称
    self:setLabelText("NameLabel", data.name, panel)

    -- 积分
    self:setLabelText("LeaderboardValueLabel", data.score, panel)

    -- 队伍标志
    self:setCtrlVisible("TeamImage", data.isTeam == 1, panel)

    -- 队伍人数
    if data.isTeam == 1 then
        self:setLabelText("TeamLabel", data.teamMembersCount .. "人", panel)
    else
        self:setLabelText("TeamLabel", "", panel)
    end

    local btn = self:getControl("ComparedButton", nil, panel)
    btn.gid = data.gid

    panel:requestDoLayout()
end

function ArenaDekaronListDlg:cleanup()
    self:releaseCloneCtrl("unitPlayerPanel")
end

function ArenaDekaronListDlg:onRefreshButton(sender, eventType)
    if not self:isOutLimitTime("lastRefreshTime", 5 * 1000) then
        gf:ShowSmallTips(CHS[8000008]);
        return
    end

    self:setLastOperTime("lastRefreshTime", gfGetTickCount())
    RingMgr:refreashChanllengeList()
end

function ArenaDekaronListDlg:onComparedButton(sender, eventType)
    local gid = sender.gid
    RingMgr:chanllengePlayerByGid(gid)
end

function ArenaDekaronListDlg:onSelectSelctionPlayerListView(sender, eventType)
end

return ArenaDekaronListDlg
