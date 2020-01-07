-- MingrzbTeamInfoDlg.lua
-- Created by lixh Mar/05/2018
-- 名人争霸队伍介绍界面

local MingrzbTeamInfoDlg = Singleton("MingrzbTeamInfoDlg", Dialog)

-- 队伍成员最大数量
local TEAM_MEMBER_MAX_COUNT = 5

-- mv最大数量
local MV_MAX_NUM = 5

function MingrzbTeamInfoDlg:init()
    self.jcPanel = self:retainCtrl("MatchPanel_1")

    -- listView分页
    MingrzbjcMgr:bindTouchPanel(self, "TouchPanel", self.tryAddItemToListView)

    self:hookMsg("MSG_LOOKON_COMBAT_RECORD_DATA")
end

-- 设置界面信息
function MingrzbTeamInfoDlg:setData(data)

    self.teamData = data

    -- 队伍名称
    self:setLabelText("NameLabel", data.teamName, "TitleImage")

    -- 设置队员信息
    self:setTeamInfo()

    -- 比赛信息
    self:setCompetListView()
end

-- 设置队员信息
function MingrzbTeamInfoDlg:setTeamInfo()
    for i = 1, TEAM_MEMBER_MAX_COUNT do
        -- 先清空信息
        local panel = self:getControl("UserPanel_" .. i, nil, "TeamPanel")
        self:setCtrlVisible("PlayerImage", false, panel)
        self:setLabelText("NameLabel", "", panel)
        self:setLabelText("TaoLabel", "", panel)
        self:removeNumImgForPanel("LevelPanel", LOCATE_POSITION.LEFT_TOP, panel)
        self:setCtrlVisible("LeaderImage", false, panel)
    end

    local data = self.teamData

    -- 队长信息固定在第一个
    local panelIndex = 2
    for i = 1, TEAM_MEMBER_MAX_COUNT do
        local panel = self:getControl("UserPanel_" .. panelIndex, nil, "TeamPanel")
        local teamInfo = data.memberList[i]
        if teamInfo then
            if teamInfo.isTeamLeader == 1 then
                -- 队长信息固定在第一个
                panel = self:getControl("UserPanel_" .. 1, nil, "TeamPanel")
            else
                -- 队员从第2个panel开始设置
                panel = self:getControl("UserPanel_" .. panelIndex, nil, "TeamPanel")
                panelIndex = panelIndex + 1
            end

            self:setCtrlVisible("PlayerImage", true, panel)
            self:setImage("PlayerImage", ResMgr:getCirclePortraitPathByIcon(teamInfo.icon), panel)
            self:setLabelText("NameLabel", teamInfo.name, panel)
            self:setLabelText("TaoLabel", gf:getTaoStr(teamInfo.tao, 0), panel)
            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, 
                teamInfo.level, false, LOCATE_POSITION.LEFT_TOP, 19, panel)
            self:setCtrlVisible("LeaderImage", teamInfo.isTeamLeader == 1, panel)
        end
    end
end

-- 比赛列表信息
function MingrzbTeamInfoDlg:setCompetListView()
    local data = self.teamData
    local listView = self:resetListView("RankingListView")
    if data and data.competitionCount > 0 then
        self:setCtrlVisible("NoticePanel", false)

        local maxAddCount = MingrzbjcMgr:getScListViewAddNum()
        for i = 1, maxAddCount do
            if not data.competitionList[i] then return end
            local item = self:setItemInfo(data.competitionList[i])
            listView:pushBackCustomItem(item)
        end
    else
        self:setCtrlVisible("NoticePanel", true)
    end
end

-- 尝试给竞猜列表增加item
function MingrzbTeamInfoDlg:tryAddItemToListView()
    local listView = self:getControl('RankingListView', Const.UIListView)
    local data = self.teamData

    local count = listView:getChildrenCount()
    local tryAddCount = MingrzbjcMgr:getScListViewAddNum()
    local needAddItem = {}
    for i = count + 1, count + tryAddCount do
        if data.competitionList[i] then
            table.insert(needAddItem, data.competitionList[i])
        end
    end

    local needAddCount = #needAddItem
    if needAddCount <= 0 then return end

    local itemHeight = self.jcPanel:getContentSize().height
    local innerContainer = listView:getInnerContainerSize()
    innerContainer.height = (count + needAddCount) * itemHeight
    listView:setInnerContainerSize(innerContainer)

    for i = 1, #needAddItem do
        local item = self:setItemInfo(needAddItem[i])
        listView:pushBackCustomItem(item)
    end

    MingrzbjcMgr:jumpToItem(listView, itemHeight * count)
    listView:requestRefreshView()
end

-- 比赛item信息
function MingrzbTeamInfoDlg:setItemInfo(data)
    local item = self.jcPanel:clone()
    
    -- 比赛日信息
    local titlePanel = self:getControl("TitlePanel", nil, item)
    local str = self:getItemTitle(data.day, data.time)
    self:setLabelText("TipsLabel", str, titlePanel)

    -- 队伍名称
    local teamAPanel = self:getControl("LeftTeamPanel", nil, item)
    if self.teamData and self.teamData.teamName then
        self:setLabelText("TeamLabel", self.teamData.teamName, teamAPanel)
    else
        self:setLabelText("TeamLabel", "", teamAPanel)
    end

    local teamBPanel = self:getControl("RightTeamPanel", nil, item)
    if data.otherName then
        self:setLabelText("TeamLabel", data.otherName, teamBPanel)
    else
        self:setLabelText("TeamLabel", "", teamBPanel)
    end
    
    -- 胜利，失败标记
    if data.isWin == 1 then
        self:setImage("LeftResultImage", ResMgr.ui.mingrzb_jc_win, item)
        self:setImage("RightResultImage", ResMgr.ui.mingrzb_jc_lose, item)
    elseif data.isWin == 2 then
        self:setImage("LeftResultImage", ResMgr.ui.mingrzb_jc_lose, item)
        self:setImage("RightResultImage", ResMgr.ui.mingrzb_jc_win, item)
    else
        self:setImage("LeftResultImage", ResMgr.ui.mingrzb_jc_lose, item)
        self:setImage("RightResultImage", ResMgr.ui.mingrzb_jc_lose, item)
    end

    -- 支持数
    local supportAPanel = self:getControl("LeftSupportButton", nil, item)
    if data.mySupports then
        self:setLabelText("WordLabel", string.format(CHS[7120051], data.mySupports), supportAPanel)
    else
        self:setLabelText("WordLabel", "", supportAPanel)
    end

    local supportBPanel = self:getControl("RightSupportButton", nil, item)
    if data.otherSupports then
        self:setLabelText("WordLabel", string.format(CHS[7120051], data.otherSupports), supportBPanel)
    else
        self:setLabelText("WordLabel", "", supportBPanel)
    end
    
    -- 对比条
    local maxSz = self:getCtrlContentSize("LeftImage", item)
    local rate = data.otherSupports * 100 / (data.mySupports + data.otherSupports) / 100
    self:setCtrlContentSize("RightImage", maxSz.width * rate, maxSz.height, item)

    -- 录像
    for i = 1, MV_MAX_NUM do
        local btn = self:getControl("RecordButton_" .. i, nil, item)
        local mvInfo = data.mvList[i]
        if mvInfo then
            btn:setVisible(true)
            self:setImagePlist("Image_483", mvInfo.result == 0 and ResMgr.ui.party_war_win or ResMgr.ui.party_war_lose, btn)
            btn.data = {id = mvInfo.id, competName = data.competName}
            self:bindTouchEndEventListener(btn, self.onRecordButtn)
        else
            btn:setVisible(false)
        end
    end

    return item
end

-- 设置比赛日名称
function MingrzbTeamInfoDlg:getItemTitle(day, time)
    local type = MingrzbjcMgr:getScTypeByDay(day)
    local scName = MingrzbjcMgr:getScListItemName(math.floor(type / 100) * 100)
    local ret = string.format(CHS[7100197], gf:getServerDate(CHS[7100196], time), scName)
    return ret
end

-- 点击录像按钮
function MingrzbTeamInfoDlg:onRecordButtn(sender, eventType)
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[7100040])
        return
    end

    local data = sender.data
    if data then
        MingrzbjcMgr:fetchScMv(data.competName, data.id)
    end
end

-- 进入观战，关闭界面
function MingrzbTeamInfoDlg:MSG_LOOKON_COMBAT_RECORD_DATA()
    self:onCloseButton()
end

return MingrzbTeamInfoDlg
