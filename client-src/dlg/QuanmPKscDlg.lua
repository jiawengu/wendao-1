-- QuanmPKscDlg.lua
-- Created by yangym Mar/21/2017
-- 全民PK赛程界面

local QuanmPKscDlg = Singleton("QuanmPKscDlg", Dialog)

local MAX_PAGE = 4

local MATCH_TYPE =
{
    to16Match = 1,
    finalMatch = 2,
}

function QuanmPKscDlg:init()
    self:bindListener("MatchTypeButton", self.onMatchTypeButton)
    self:bindListener("MatchTypeCheckBox_1", self.onTo16MatchButton)
    self:bindListener("MatchTypeCheckBox_2", self.onFinalMatchButton)
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("ViewCombatButton", self.onViewCombatButton)

    self:hookMsg("MSG_QMPK_MATCH_PLAN_INFO")
    self:hookMsg("MSG_QMPK_MATCH_LEADER_INFO")
    self:hookMsg("MSG_QMPK_MATCH_TEAM_INFO")
    self:hookMsg("MSG_QMPK_MATCH_TIME_INFO")

    self.page = 1

    if not QuanminPKMgr:getQMPKMatchTimeInfo() then
        gf:CmdToServer("CMD_QMPK_MATCH_TIME_INFO")
    end

    gf:CmdToServer("CMD_QMPK_MATCH_INFO")
end

function QuanmPKscDlg:onMatchTypeButton(sender, eventType)
    local isPanelVisibleBefore = self:getCtrlVisible("MatchTypePanel")
    self:setCtrlVisible("MatchTypePanel", not isPanelVisibleBefore)
    self:setCtrlVisible("ExpandImage", isPanelVisibleBefore)
    self:setCtrlVisible("ShrinkImage", not isPanelVisibleBefore)
end

function QuanmPKscDlg:onTo16MatchButton(sender, eventType)
    self:setCtrlVisible("MatchTypePanel", false)
    self:getControl("MatchTypeButton"):setTitleText(CHS[7002180])
    self:setCtrlVisible("ExpandImage", true)
    self:setCtrlVisible("ShrinkImage", false)

    self.matchType = MATCH_TYPE.to16Match
    self:displayMatch(self.matchType)
    self:setPage()
end

function QuanmPKscDlg:onFinalMatchButton(sender, eventType)
    self:setCtrlVisible("MatchTypePanel", false)
    self:getControl("MatchTypeButton"):setTitleText(CHS[7002181])
    self:setCtrlVisible("ExpandImage", true)
    self:setCtrlVisible("ShrinkImage", false)

    self.matchType = MATCH_TYPE.finalMatch
    self:displayMatch(self.matchType)
end

function QuanmPKscDlg:displayMatch(matchType)
    if matchType == MATCH_TYPE.finalMatch then
        self:setCtrlVisible("64To16Panel", false)
        self:setCtrlVisible("FinalsPanel", true)
        self:displayFinalMatch()
    elseif matchType == MATCH_TYPE.to16Match then
        self:setCtrlVisible("64To16Panel", true)
        self:setCtrlVisible("FinalsPanel", false)
        self:displayTo16Match(self.page)
    end
end

-- 64进16强相关 <<<<<<<

function QuanmPKscDlg:getTo16Data()
    -- 队伍编号 no
    -- 队伍名称 name
    -- 队伍标识 gid
    -- 队伍等级 level (1,2,3 = 64强，32强，16强）
    local data = QuanminPKMgr:getTo16Data()
    return data
end

function QuanmPKscDlg:displayTo16Match(page)
    local data = self:getTo16Data()
    if (not data) or (#data == 0) then
        return
    end

    local start = 16 * (page - 1)

    -- 初始化比赛时间（32强）
    local time32Match = QuanminPKMgr:getTimeInfoByStage("64X32") or {}
    local time32 = time32Match[1]
    if time32 then
        local timeList = gf:getServerDate("*t", time32)
        local timeStr = string.format(CHS[7002205], timeList.month, timeList.day, timeList.hour, timeList.min)
        self:setLabelText("4TitleLabel", timeStr, "4TitleImage")
    else
        self:setLabelText("4TitleLabel", "", "4TitleImage")
    end
    
    -- 初始化比赛时间（16强）
    local time16Match = QuanminPKMgr:getTimeInfoByStage("32X16") or {}
    local time16 = time16Match[1]
    if time16 then
        local timeList = gf:getServerDate("*t", time16)
        local timeStr = string.format(CHS[7001044], timeList.month, timeList.day, timeList.hour, timeList.min)
        self:setLabelText("4TitleLabel", timeStr, "4TitleImage_0")
    else
        self:setLabelText("4TitleLabel", "", "4TitleImage_0")
    end
    
    for i = 1, 4 do
        -- 每页有四组队伍，对每组的四只队伍作同样处理
        local panel = self:getControl("64To16Panel_" .. i)
        local team1Data = data[start + (i - 1) * 4 + 1]
        local team2Data = data[start + (i - 1) * 4 + 2]
        local team3Data = data[start + (i - 1) * 4 + 3]
        local team4Data = data[start + (i - 1) * 4 + 4]
        local panel1 = self:getControl("64To32Panel_1", nil, panel)
        local panel2 = self:getControl("64To32Panel_2", nil, panel)
        local VSImage = self:getControl("VS16Image", nil, panel)
        local VSImage1 = self:getControl("VSImage", nil, panel1)
        local VSImage2 = self:getControl("VSImage", nil, panel2)

        local to32Team1 = self:doDoubleTeam(team1Data, team2Data, panel1)
        local to32Team2 = self:doDoubleTeam(team3Data, team4Data, panel2)

        -- 处理line和VSImage

        -- 先重置所有的line
        self:redLine(false, self:getControl("TeamPanel_1", nil, panel1))
        self:redLine(false, self:getControl("TeamPanel_2", nil, panel1))
        self:redLine(false, self:getControl("TeamPanel_1", nil, panel2))
        self:redLine(false, self:getControl("TeamPanel_2", nil, panel2))
        self:redLine(false, panel1, "64To32")
        self:redLine(false, panel2, "64To32")

        local to32Team1No
        local to32Team2No

        if to32Team1 or to32Team2 then
            -- 32强比赛的结果（line和VSImage）

            -- 如果某两只队伍已经决出了32强，那么认为32强已经全部决出，没有决出32强的两只队伍视作全部被淘汰
            if to32Team1 then
                to32Team1No = start + (i - 1) * 4 + to32Team1
                self:setCtrlVisible("Image", false, VSImage1)
                self:setCtrlVisible("Label32", false, VSImage1)
                self:setCtrlVisible("ResultImage", true, VSImage1)
                self:setLabelText("Label", to32Team1No, VSImage1)
                self:redLine(true, self:getControl("TeamPanel_" .. to32Team1, nil, panel1))
            else
                self:setCtrlVisible("Image", false, VSImage1)
                self:setCtrlVisible("ResultImage", false, VSImage1)
                self:setCtrlVisible("Label32", true, VSImage1)
            end

            if to32Team2 then
                to32Team2No = start + (i - 1) * 4 + 2 + to32Team2
                self:setCtrlVisible("Image", false, VSImage2)
                self:setCtrlVisible("Label32", false, VSImage2)
                self:setCtrlVisible("ResultImage", true, VSImage2)
                self:setLabelText("Label", to32Team2No, VSImage2)
                self:redLine(true, self:getControl("TeamPanel_" .. to32Team2, nil, panel2))
            else
                self:setCtrlVisible("Image", false, VSImage2)
                self:setCtrlVisible("ResultImage", false, VSImage2)
                self:setCtrlVisible("Label32", true, VSImage2)
            end
        else
            -- 32强比赛尚未结束
            self:setCtrlVisible("Image", false, VSImage1)
            self:setCtrlVisible("ResultImage", false, VSImage1)
            self:setCtrlVisible("Label32", true, VSImage1)
            self:setCtrlVisible("Image", false, VSImage2)
            self:setCtrlVisible("ResultImage", false, VSImage2)
            self:setCtrlVisible("Label32", true, VSImage2)
        end

        -- 是否已经决出16强
        local to16TeamNo
        if (to32Team1No and data[to32Team1No] and data[to32Team1No].level >= 3) then
            to16TeamNo = to32Team1No
            self:redLine(true, panel1, "64To32")
        elseif (to32Team2No and data[to32Team2No] and data[to32Team2No].level >= 3) then
            to16TeamNo = to32Team2No
            self:redLine(true, panel2, "64To32")
        end

        if to16TeamNo then
            -- 16强已经决出
            local image = self:getControl("Image", nil, VSImage)
            self:setCtrlVisible("MatchTimeLabel", false, VSImage)
            self:setCtrlVisible("Image", true, VSImage)
            self:setLabelText("Label", to16TeamNo, self:getControl("Label", nil, image))
        else
            -- 16强尚未决出，显示?
            local image = self:getControl("Image", nil, VSImage)
            self:setCtrlVisible("MatchTimeLabel", false, VSImage)
            self:setCtrlVisible("Image", true, VSImage)
            self:setLabelText("Label", CHS[7001046], self:getControl("Label", nil, image))
        end
    end
end

function QuanmPKscDlg:redLine(needToRedLine, panel, ctrlNamePrefix)
    -- ctrlNamePrefix：控件名前缀
    -- 用于区分父控件的直接子控件（XXXTeamLineImage_1)和其子控件的子控件（TeamLineImage_1)
    -- PS.取同名子控件时不一定会取到第一个子控件
    local image1Name = "TeamLineImage_1"
    local image2Name = "TeamLineImage_2"
    if ctrlNamePrefix then
        image1Name = ctrlNamePrefix .. image1Name
        image2Name = ctrlNamePrefix .. image2Name
    end
    
    if needToRedLine then
        gf:addRedEffect(self:getControl(image1Name, nil, panel))
        gf:addRedEffect(self:getControl(image2Name, nil, panel))
    else
        gf:removeRedEffect(self:getControl(image1Name, nil, panel))
        gf:removeRedEffect(self:getControl(image2Name, nil, panel))
    end
end

function QuanmPKscDlg:onLeftButton(sender, eventType)
    self.page = self.page - 1

    if self.page < 1 then
        self.page = 1
    end

    self:setPage()
    self:displayTo16Match(self.page)
end

function QuanmPKscDlg:onRightButton(sender, eventType)
    self.page = self.page + 1

    if self.page > MAX_PAGE then
        self.page = MAX_PAGE
    end

    self:setPage()
    self:displayTo16Match(self.page)
end

-- 64进16强相关 >>>>>>


-- 总决赛相关<<<<<
function QuanmPKscDlg:getFinalData()
    -- 队伍编号 no
    -- 队伍名称 name
    -- 队伍标识 gid
    -- 队伍等级 level (1,2,3,4,5 = 16强，8强，4强，2强，冠军）
    local data = QuanminPKMgr:getFinalData()
    return data
end

function QuanmPKscDlg:displayFinalMatch()

    -- 初始化比赛时间
    local function matchTime(labelName, stage, chs)
        local stageTime = QuanminPKMgr:getTimeInfoByStage(stage) or {}
        local time = stageTime[1]
        if time then
            local timeList = gf:getServerDate("*t", time)
            local timeStr = string.format(chs, timeList.month, timeList.day, timeList.hour, timeList.min)
            self:setLabelText(labelName, timeStr)
        end
    end
    matchTime("16To8TimeLabel", "16X8", CHS[7002206])
    matchTime("8To4TimeLabel", "8X4", CHS[7002207])
    matchTime("4To2TimeLabel", "4X2", CHS[7002208])
    matchTime("2To1TimeLabel", "2X1", CHS[7002209])

    local data = self:getFinalData()
    if (not data) or (#data == 0) then
        return
    end

    -- 名次显示

    local to2Team = {}
    for i = 1, 2 do
        -- 分别处理左右两边
        local panel = self:getControl("16To2Panel_" .. i)
        local start = (i - 1) * 8
        local to4Team = {}

        for j = 1, 2 do
            -- 分别处理上下两边
            local fourTeamPanel = self:getControl("16To4Panel_" .. j, nil, panel)
            local team1Data = data[start + (j - 1) * 4 + 1]
            local team2Data = data[start + (j - 1) * 4 + 2]
            local team3Data = data[start + (j - 1) * 4 + 3]
            local team4Data = data[start + (j - 1) * 4 + 4]
            local panel1 = self:getControl("16To8Panel_1", nil, fourTeamPanel)
            local panel2 = self:getControl("16To8Panel_2", nil, fourTeamPanel)
            local to8Team1 = self:doDoubleTeam(team1Data, team2Data, panel1)
            local to8Team2 = self:doDoubleTeam(team3Data, team4Data, panel2)
            local to8Team1Index
            local to8Team2Index

            -- 处理line和VSImage
            -- 先重置所有的line
            self:redLine(false, self:getControl("TeamPanel_1", nil, panel1))
            self:redLine(false, self:getControl("TeamPanel_2", nil, panel1))
            self:redLine(false, self:getControl("TeamPanel_1", nil, panel2))
            self:redLine(false, self:getControl("TeamPanel_2", nil, panel2))
            self:redLine(false, panel1, "16To8")
            self:redLine(false, panel2, "16To8")
            self:redLine(false, fourTeamPanel, "16To4")

            if to8Team1 then
                -- 决出8强
                to8Team1Index = start + (j - 1) * 4 + to8Team1
                self:setCtrlVisible("ResultImage", true, panel1)
                self:setCtrlVisible("VSImage", false, panel1)
                self:setLabelText("Label", data[to8Team1Index].no, self:getControl("ResultImage", nil, panel1))
                self:redLine(true, self:getControl("TeamPanel_" .. to8Team1, nil, panel1))
            else
                --未决出8强
                self:setCtrlVisible("ResultImage", false, panel1)
                self:setCtrlVisible("VSImage", true, panel1)
            end

            if to8Team2 then
                -- 决出8强
                to8Team2Index = start + (j - 1) * 4 + 2 + to8Team2
                self:setCtrlVisible("ResultImage", true, panel2)
                self:setCtrlVisible("VSImage", false, panel2)
                self:setLabelText("Label", data[to8Team2Index].no, self:getControl("ResultImage", nil, panel2))
                self:redLine(true, self:getControl("TeamPanel_" .. to8Team2, nil, panel2))
            else
                -- 未决出8强
                self:setCtrlVisible("ResultImage", false, panel2)
                self:setCtrlVisible("VSImage", true, panel2)
            end

            -- 是否决出四强
            if (to8Team1 and to8Team2 and to8Team1Index and to8Team2Index and data[to8Team1Index].level ~= data[to8Team2Index].level) then
                -- 两只八强队伍战斗决出胜负
                if (data[to8Team1Index].level) > (data[to8Team2Index].level) then
                    to4Team[j] = {localIndex = 1, index = to8Team1Index}
                else
                    to4Team[j] = {localIndex = 2, index = to8Team2Index}
                end
            elseif to8Team1 and to8Team1Index and data[to8Team1Index].level > 2 then
                -- 第一只八强队伍不战而胜
                to4Team[j] = {localIndex = 1, index = to8Team1Index}
            elseif to8Team2 and to8Team2Index and data[to8Team2Index].level > 2 then
                -- 第二只八强队伍不战而胜
                to4Team[j] = {localIndex = 2, index = to8Team2Index}
            end

            if to4Team[j] then
                -- 4强line和VSImage
                self:redLine(true, self:getControl("16To8Panel_" .. to4Team[j].localIndex, nil, fourTeamPanel), "16To8")
                self:setCtrlVisible("Result4Image", true, fourTeamPanel)
                self:setCtrlVisible("VS4Image", false, fourTeamPanel)

                local no = data[to4Team[j].index].no
                self:setLabelText("Label", no, self:getControl("Result4Image", nil, fourTeamPanel))
            else
                -- 未决出4强
                self:setCtrlVisible("Result4Image", false, fourTeamPanel)
                self:setCtrlVisible("VS4Image", true, fourTeamPanel)
            end
        end

        -- 处理2强
        -- 是否决出两强
        if to4Team[1] and to4Team[2] and data[to4Team[1].index].level ~= data[to4Team[2].index].level then
            -- 两只四强队伍战斗决出胜负
            if data[to4Team[1].index].level > data[to4Team[2].index].level then
                to2Team[i] = {localIndex = 1, index = to4Team[1].index}
            else
                to2Team[i] = {localIndex = 2, index = to4Team[2].index}
            end
        elseif to4Team[1] and data[to4Team[1].index].level > 3 then
            -- 第一只四强队伍不战而胜
            to2Team[i] = {localIndex = 1, index = to4Team[1].index}
        elseif to4Team[2] and data[to4Team[2].index].level > 3 then
            -- 第二只四强队伍不战而胜
            to2Team[i] = {localIndex = 2, index = to4Team[2].index}
        end

        if to2Team[i] then
            self:redLine(true, self:getControl("16To4Panel_" .. to2Team[i].localIndex, nil, panel), "16To4")
            self:setCtrlVisible("Result2Image", true, panel)
            self:setCtrlVisible("VS2Image", false, panel)

            local no = data[to2Team[i].index].no
            self:setLabelText("Label", no, self:getControl("Result2Image", nil, panel))
        else
            -- 未决出2强
            self:setCtrlVisible("Result2Image", false, panel)
            self:setCtrlVisible("VS2Image", true, panel)
        end
    end

    -- 处理冠军相关
    local finalTeamLine1 = self:getControl("FinalTeamLineImage_1", nil, "16To2Panel_1")
    local finalTeamLine2 = self:getControl("FinalTeamLineImage_1", nil, "16To2Panel_2")
    if to2Team[1] and to2Team[2] and data[to2Team[1].index].level ~= data[to2Team[2].index].level then
        -- 两强战斗决出冠军
        if (data[to2Team[1].index].level) > (data[to2Team[2].index].level) then
            gf:addRedEffect(finalTeamLine1)
            self:setLabelText("Label", string.format(CHS[7002183], data[to2Team[1].index].name), "2To1Panel")
        else
            gf:addRedEffect(finalTeamLine2)
            self:setLabelText("Label", string.format(CHS[7002183], data[to2Team[2].index].name), "2To1Panel")
        end
    elseif to2Team[1] and data[to2Team[1].index].level > 4 then
        -- 第一只两强队伍不战而胜
        gf:addRedEffect(finalTeamLine1)
        self:setLabelText("Label", string.format(CHS[7002183], data[to2Team[1].index].name), "2To1Panel")
    elseif to2Team[2] and data[to2Team[2].index].level > 4 then
        -- 第二只两强队伍不战而胜
        gf:addRedEffect(finalTeamLine2)
        self:setLabelText("Label", string.format(CHS[7002183], data[to2Team[2].index].name), "2To1Panel")
    else
        -- 未决出冠军
        gf:removeRedEffect(finalTeamLine1)
        gf:removeRedEffect(finalTeamLine2)
        self:setLabelText("Label", CHS[7002182], "2To1Panel")
    end
end

function QuanmPKscDlg:onViewCombatButton(sender, eventType)
    local dlg = DlgMgr:openDlg("WatchCentreDlg")
    dlg:selectWatchType(CHS[7002193])
end

-- 总决赛相关>>>>>

function QuanmPKscDlg:doDoubleTeam(team1Data, team2Data, panel)
    -- 每两个队伍的处理逻辑
    if not team1Data or not team2Data then
        return
    end

    local winTeam
    local team1Panel = self:getControl("TeamPanel_1", nil, panel)
    local team2Panel = self:getControl("TeamPanel_2", nil, panel)

    -- 队伍名字
    self:setLabelText("TeamLabel", team1Data.name, team1Panel)
    self:setLabelText("TeamLabel", team2Data.name, team2Panel)

    -- 队伍编号
    self:setLabelText("Label", team1Data.no, team1Panel)
    self:setLabelText("Label", team2Data.no, team2Panel)


    -- 点击队伍弹出信息
    local function team1PanelTouch(sender, enventType)
        if enventType == ccui.TouchEventType.ended then
            self:showTeamMessage(team1Data.gid)
        end
    end

    team1Panel:addTouchEventListener(team1PanelTouch)

    local function team2PanelTouch(sender, enventType)
        if enventType == ccui.TouchEventType.ended then
            self:showTeamMessage(team2Data.gid)
        end
    end

    team2Panel:addTouchEventListener(team2PanelTouch)

    -- 队伍是否被淘汰
    if team1Data.level <= 1 and team2Data.level <= 1 then
        -- 第一队、第二队的比赛尚未开始
        self:setCtrlEnabled("BKImage", true, team1Panel)
        self:setCtrlEnabled("BKImage", true, team2Panel)
    else
        -- 第一队、第二队已经决出胜负
        if (team1Data.level) > (team2Data.level) then
            winTeam = 1
        else
            winTeam = 2
        end

        self:setCtrlEnabled("BKImage", winTeam == 1, team1Panel)
        self:setCtrlEnabled("BKImage", winTeam == 2, team2Panel)
    end

    -- 返回这两只队伍中的胜利者
    return winTeam
end

function QuanmPKscDlg:doInit()
    -- 初始默认选择
    if QuanminPKMgr:isTo16MatchFinish() then
        -- 16强比赛已经结束
        self:onFinalMatchButton()
    else
        -- 16强比赛尚未结束
        self.page = 1
        self:onTo16MatchButton()
        self:setPage()
    end
end

function QuanmPKscDlg:showTeamMessage(gid)
    gf:CmdToServer("CMD_QMPK_MATCH_TEAM_INFO", {gid = gid})
end

function QuanmPKscDlg:setPage()
    self:setColorText(self.page or 1, "PageInfoPanel", nil, nil, nil, nil, 23, true)
end

function QuanmPKscDlg:MSG_QMPK_MATCH_TEAM_INFO(data)
    local dlg = DlgMgr:openDlg("QuanmPKTeamInfoDlg")
    dlg:setData(data)
end

function QuanmPKscDlg:MSG_QMPK_MATCH_LEADER_INFO()
    if QuanminPKMgr:getQMPKMatchData() and QuanminPKMgr:getQMPKLeaderData() then
        self:doInit()
    end
end

function QuanmPKscDlg:MSG_QMPK_MATCH_PLAN_INFO()
    if QuanminPKMgr:getQMPKMatchData() and QuanminPKMgr:getQMPKLeaderData() then
        self:doInit()
    end
end

function QuanmPKscDlg:cleanup()
    self.page = 1
end

return QuanmPKscDlg