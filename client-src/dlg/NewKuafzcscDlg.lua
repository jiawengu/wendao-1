-- NewKuafzcscDlg.lua
-- Created by songcw Jan/06/2019
-- 跨服战场2019 赛程

local NewKuafzcscDlg = Singleton("NewKuafzcscDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local LIST_MARGIN = 8

local TEAM_CHECKBOX = {
    "TeamCheckBox_1",
    "TeamCheckBox_2",
    "TeamCheckBox_3",
    "TeamCheckBox_4",
}

local MATCH_MAP = {
    [CHS[4010318]] = "RoundMatchPanel",
    [CHS[4010314]] = {"16PromotionPanel", "2PromotionPanel"},
    [CHS[4010315]] = "JuesaiFinalMatchPanel",
}

function NewKuafzcscDlg:init()
    self:bindListener("SessionButton", self.onSessionButton)
    self:bindListener("SelectButton", self.onSelectButton)
    self:bindListener("AreaButton", self.onAreaButton)
    self:bindListener("MatchTypeButton", self.onMatchTypeButton)
    self:bindListener("MatchTypeJJButton", self.onMatchTypeJJButton)
    self:bindListener("MatchTypeXHButton", self.onMatchTypeJJButton)
    self:bindListener("MatchTypeJSButton", self.onMatchTypeJJButton)

    for i = 1, 8 do
        local btn = self:getControl("ViewButton", nil, "MatchPanel_" .. i)
        self:bindTouchEndEventListener(btn, self.onViewButton)
    end

    self:bindListener("ViewCombatButton", self.onViewCombatButton, "2PromotionPanel")
    self:bindListener("ViewCombatButton", self.onViewCombatButton, "JuesaiFinalMatchPanel")


    self.selectButton = self:retainCtrl("SelectButton")
    self:bindTouchEndEventListener(self.selectButton, self.onSelectFloatButton)
    self.sessionPanelSize = self.sessionPanelSize or self:getControl("SessionPanel"):getContentSize()
    self.sessionListSize = self.sessionListSize or self:getControl("NumberListView"):getContentSize()

    self.promotionTitlePanel = self:retainCtrl("TimePanel", "16PromotionPanel")
    self.promotionTeamPanel = self:retainCtrl("TeamPanel", "16PromotionPanel")
    self.promotionLinePanel = self:retainCtrl("BackPanel", "16PromotionPanel")

    self.teamCheckBox = self:retainCtrl("TeamCheckBox")

    -- 初始化相关panel的可见度
    self:initVisiblePanel()

    -- 初始化 3 个float面板
    self:initFloatPanel()

    self.allSimpleData = KuafzcMgr:getKfzcAllSimple2019Data()
    if not self.allSimpleData then
        KuafzcMgr:queryAllSimpleData2019()
    else
        self:MSG_CSML_ALL_SIMPLE(self.allSimpleData)
    end


    local data = KuafzcMgr:getLeagueDataBySeason(self.seasonNo)
    if data then
        self:MSG_CSML_LEAGUE_DATA(data)
    end



    self:hookMsg("MSG_CSML_ALL_SIMPLE")
    self:hookMsg("MSG_CSML_LEAGUE_DATA")
end

function NewKuafzcscDlg:initVisiblePanel()
    self:setCtrlVisible("AreaButton", false)

    -- 初始化隐藏，避免界面闪一下
    for _, name in pairs(TEAM_CHECKBOX) do
        self:setCtrlVisible(name, false)
    end

    for _, name in pairs(MATCH_MAP) do
        if type(name) == "table" then
            for i, pName in pairs(name) do
                self:setCtrlVisible(pName, false)
            end
        else
            self:setCtrlVisible(name, false)
        end
    end
end

function NewKuafzcscDlg:initFloatPanel()
    -- 界面中4个悬浮Panel
    self:bindFloatPanelListener("SessionPanel", nil, nil, function ()
        self:setExpandState("SessionButton", false)
    end)

    self:bindFloatPanelListener("AreaPanel", nil, nil, function ()
        self:setExpandState("AreaButton", false)
    end)

    self:bindFloatPanelListener("MatchTypePanel", nil, nil, function ()
        self:setExpandState("MatchTypeButton", false)
    end)
end



function NewKuafzcscDlg:setFinalMatchPanel(data)
    local knockoutData = data.knockoutInfo
    local list, size = self:resetListView("AreaListView", LIST_MARGIN, ccui.ListViewGravity.centerHorizontal)
    local count = #knockoutData - 1
    local jinjisDescMap = KuafzcMgr:getKuafzcTimeDesc(#knockoutData)
    -- 晋级赛最少显示  4进2，决赛单独的panel显示
    for i = 1, count do
        local btn = self.selectButton:clone()
        btn.relationBtn = "AreaButton"
        btn.relationPanel = "AreaPanel"
        btn:setTag(i)
        btn:setTitleText(jinjisDescMap[i])
        list:pushBackCustomItem(btn)
    end

    local panel = self:getControl("AreaPanel")
    self:setFloatContentSize(panel, list, count)
end

-- 设置届数悬浮框
function NewKuafzcscDlg:setSessionPanel(data)
    local list, size = self:resetListView("NumberListView", LIST_MARGIN, ccui.ListViewGravity.centerHorizontal)
    for i = 1, data.season_no do
        local btn = self.selectButton:clone()
        btn.relationBtn = "SessionButton"
        btn.relationPanel = "SessionPanel"
        btn:setTag(data.season_no - i + 1)
        btn:setTitleText(string.format(CHS[4010319], gf:changeNumToChinese(data.season_no - i + 1)))
        list:pushBackCustomItem(btn)
    end

    local panel = self:getControl("SessionPanel")
    self:setFloatContentSize(panel, list, data.season_no)
end

function NewKuafzcscDlg:setFloatContentSize(panel, list, count)
    -- 策划反复无常，先说最小尺寸为2的，现在要兼容1
    if count < 2 then
        local addHeight = (self.selectButton:getContentSize().height + LIST_MARGIN) -- LIST_MARGIN
        panel:setContentSize(self.sessionPanelSize.width, self.sessionPanelSize.height - addHeight)
        list:setContentSize(self.sessionListSize.width, self.sessionListSize.height - addHeight)
    elseif count == 2 then
        panel:setContentSize(self.sessionPanelSize)
        list:setContentSize(self.sessionListSize)
    else
        local maxCount = math.min(5, count)
        local addHeight = (maxCount - 2) * (self.selectButton:getContentSize().height + LIST_MARGIN) -- LIST_MARGIN
        panel:setContentSize(self.sessionPanelSize.width, self.sessionPanelSize.height + addHeight)
        list:setContentSize(self.sessionListSize.width, self.sessionListSize.height + addHeight)
    end

    panel:requestDoLayout()
	self:updateLayout("MainBodyPanel")
end

function NewKuafzcscDlg:onSessionButton(sender, eventType)
    self:setCtrlVisible("SessionPanel", true)
    self:setExpandState(sender, true)
end

-- 小组赛的checkBox
function NewKuafzcscDlg:onTeamCheckBox(sender, eventType)
    local data = KuafzcMgr:getLeagueDataBySeason(self.seasonNo)

    -- 设置循环赛
    self:setLeagueData(data.ret, eventType)
end

-- 设置循环赛
function NewKuafzcscDlg:setLeagueData(data, group)
    local areaData = data.groupInfo[group]
    local distInfo = data.distInfo
    local groupWarInfo = data.groupWarInfo

    for i = 1, 8 do
        local panel = self:getControl("MatchPanel_" .. i)

        self:setUnitWarInfo(panel, data[i])

        if areaData.distInfo[i] then
            local distName = areaData.distInfo[i].distName
            self:setUnitWarInfo(panel, distInfo[distName], groupWarInfo[distName])
        else
            self:setUnitWarInfo(panel)
        end
    end
end

function NewKuafzcscDlg:onViewButton(sender, eventType)
    if not sender.warInfo then return end
    local dlg = DlgMgr:openDlg("KuafzczkDlg")
    dlg:setData(sender.warInfo)
end

function NewKuafzcscDlg:setUnitWarInfo(panel, unitData, warInfo)
    if not unitData then
        unitData = {distName = "", win = "", lost = "", draw = "", point = "", isWinner = false}
    end

    local viewBtn = self:getControl("ViewButton", nil, panel)
    viewBtn.warInfo = warInfo

    self:setCtrlVisible("ViewButton", unitData.distName ~= "", panel)

    -- 出现
    self:setCtrlVisible("ResultImage", unitData.isWinner, panel)

    -- 区组
    self:setLabelText("DistLabel", unitData.distName, panel)

    -- 胜利次数
    self:setLabelText("WinLabel", unitData.win, panel)

    -- 失败次数
    self:setLabelText("LostLabel", unitData.lost, panel)

    -- 平局
    self:setLabelText("TieLabel", unitData.draw, panel)

    -- 积分
    self:setLabelText("ScoreLabel", unitData.point, panel)
end

function NewKuafzcscDlg:setExpandState(panelName, state)
    local panel = panelName
    if type(panelName) == "string" then
        panel = self:getControl(panelName)
    end

    self:setCtrlVisible("ShrinkImage", state, panel)
    self:setCtrlVisible("ExpandImage", not state, panel)
end

-- 点击悬浮框中的按钮
function NewKuafzcscDlg:onSelectFloatButton(sender, eventType)

    local btn = self:getControl(sender.relationBtn)
    btn:setTitleText(sender:getTitleText())
    self:setExpandState(sender.relationBtn, false)
    self:setCtrlVisible(sender.relationPanel, false)





    if sender.relationBtn == "SessionButton" then
        -- 如果没有当前赛季数据，请求
        local season = sender:getTag()
        self.seasonNo = season
        local data = KuafzcMgr:getLeagueDataBySeason(season)
        if data then
            self:MSG_CSML_LEAGUE_DATA(data)
        else
            KuafzcMgr:queryLeagueData2019(season)
        end



        self:onMatchTypeJJButton(self:getControl("MatchTypeXHButton"))
    elseif sender.relationBtn == "AreaButton" then

        local data = KuafzcMgr:getLeagueDataBySeason(self.seasonNo)
        if not data then return end

        local round = sender:getTag()
        self:setCtrlVisible("2PromotionPanel", (#data.ret.knockoutInfo - 1) == round)
        self:setCtrlVisible("16PromotionPanel", (#data.ret.knockoutInfo - 1) ~= round)
        self:setFinalMatch(round)
    end
end

function NewKuafzcscDlg:onSelectButton(sender, eventType)
end

function NewKuafzcscDlg:onAreaButton(sender, eventType)
    self:setCtrlVisible("AreaPanel", true)
    self:setExpandState(sender, true)
end

function NewKuafzcscDlg:onMatchTypeButton(sender, eventType)
    self:setCtrlVisible("MatchTypePanel", true)
    self:setExpandState(sender, true)
end

function NewKuafzcscDlg:onMatchTypeJJButton(sender, eventType)
    local data = KuafzcMgr:getLeagueDataBySeason(self.seasonNo)

    if not data then return end

    local text = sender:getTitleText()

    local btn = self:getControl("MatchTypeButton")
    btn:setTitleText(text)
    self:setExpandState(btn, false)
    self:setCtrlVisible("MatchTypePanel", false)

    self:setCtrlVisible("AreaButton", false)



    for chs, name in pairs(MATCH_MAP) do
        if text == CHS[4010314] then
            if type(name) == "table" then
                for _, pName in pairs(name) do
                    self:setCtrlVisible(pName, false)
                end
            else
                self:setCtrlVisible(name, false)
            end

        else
            if type(name) == "table" then
                for i, pName in pairs(name) do
                    self:setCtrlVisible(pName, false)
                end
            else
                self:setCtrlVisible(name, chs == text)
            end
        end
    end

    if text == CHS[4010314] then
        self:setCtrlVisible("AreaButton", true)
     --   self:setFinalMatch()

        local list = self:getControl("AreaListView")
        local items = list:getItems()
        if #items == 0 then return end
        self:onSelectFloatButton(items[1])

    elseif text == CHS[4010315] then

        self:setFinalMatch(#data.ret.knockoutInfo)
    end
end

-- 设置晋级赛的赛区、时间
function NewKuafzcscDlg:setPromotionTitle(data, panel, idx)


    if idx == 1 then
        self:setLabelText("Label", CHS[4010369], panel)    -- B赛区
        self:setLabelText("TimeLabel", gf:getServerDate(CHS[4300031], data.start_time), panel)
    else
        self:setLabelText("Label", CHS[4010370], panel)    -- B赛区
        self:setLabelText("TimeLabel", "", panel)
        self:setCtrlVisible("ClockImage", false, panel)
    end

    --self:setLabelText("TimeLabel", gf:getServerDate("%Y年%m月%d日", data.start_time), panel)
end

function NewKuafzcscDlg:setPromotionTeam(data1, data2, panel, defStr)

    local function setVSPanel(data, panel, defStr)
        local leftDist = self:getControl("DistPanel1", nil, panel)
        local rightDist = self:getControl("DistPanel2", nil, panel)

        local str1 = data[1] == "" and defStr or data[1]
        local str2 = data[2] == "" and defStr or data[2]

        local color1, color2
        if data.winner ~= "" then
            color1 = str1 == data.winner and COLOR3.GREEN or COLOR3.GRAY
            color2 = str2 == data.winner and COLOR3.GREEN or COLOR3.GRAY
        end

        self:setLabelText("DistLabel", str1, leftDist, color1)
        self:setLabelText("DistLabel", str2, rightDist, color2)
    end

    local leftPanel = self:getControl("VSPanel1", nil, panel)
    setVSPanel(data1, leftPanel, defStr)

    local rightPanel = self:getControl("VSPanel2", nil, panel)
    setVSPanel(data2, rightPanel, defStr)
end

function NewKuafzcscDlg:setPromotionFinal(data, panel, defStr)
    local str1 = data[1] == "" and defStr or data[1]
    local str2 = data[2] == "" and defStr or data[2]
    local color1, color2
    if data.winner ~= "" then
        color1 = str1 == data.winner and COLOR3.GREEN or COLOR3.GRAY
        color2 = str2 == data.winner and COLOR3.GREEN or COLOR3.GRAY
    end

    local leftPanel = self:getControl("DistPanel1", nil, panel)
    self:setLabelText("DistLabel", data[1] == "" and defStr or data[1], leftPanel, color1)

    local rightPanel = self:getControl("DistPanel2", nil, panel)
    self:setLabelText("DistLabel", data[2] == "" and defStr or data[2], rightPanel, color2)

    local winPanel = self:getControl("WinPanel", nil, panel)
    self:setLabelText("DistLabel", data.winner == "" and CHS[4010321] or data.winner, winPanel)
end

-- 设置晋级赛
function NewKuafzcscDlg:setPromotion(data, round)
    local ret = data[round]
    if not ret then return end

    local defStr = math.pow(2, (#data - round + 1)) .. CHS[4010320]

    local halfCount = math.floor(#ret / 4)
    local twoPromotionPanel = self:getControl("2PromotionPanel")
    if twoPromotionPanel:isVisible() then
        -- 最后一次晋级赛
        local panel1 = self:getControl("VSPanel1", nil, twoPromotionPanel)
        self:setPromotionFinal(ret[1], panel1, defStr)
        local timePanel1 = self:getControl("TimePanel1", nil, twoPromotionPanel)
        self:setLabelText("TimeLabel", gf:getServerDate(CHS[4300031], ret[1].start_time), timePanel1)

        local panel2 = self:getControl("VSPanel2", nil, twoPromotionPanel)
        self:setPromotionFinal(ret[2], panel2, defStr)
        local timePanel2 = self:getControl("TimePanel2", nil, twoPromotionPanel)
        self:setLabelText("TimeLabel", gf:getServerDate(CHS[4300031], ret[2].start_time), timePanel2)
    else
        -- A赛区标题
        local list = self:resetListView("ListView", nil, nil, "16PromotionPanel")
        local aTitlePanel = self.promotionTitlePanel:clone()
        self:setPromotionTitle(ret[1], aTitlePanel, 1)
        list:pushBackCustomItem(aTitlePanel)

        local idx = 1

        -- A赛区比赛队伍
        for i = 1, halfCount do
            local teamPanel = self.promotionTeamPanel:clone()

            self:setPromotionTeam(ret[idx], ret[idx + 1], teamPanel, defStr)
            idx = idx + 2
            list:pushBackCustomItem(teamPanel)
        end

        -- 分割线
        local line = self.promotionLinePanel:clone()
        list:pushBackCustomItem(line)

        -- B 赛区标题
        local bTitlePanel = self.promotionTitlePanel:clone()
        self:setPromotionTitle(ret[idx], bTitlePanel, 2)
        list:pushBackCustomItem(bTitlePanel)

        -- B赛区比赛队伍
        for i = halfCount + 1, halfCount * 2 do
            local teamPanel = self.promotionTeamPanel:clone()
            self:setPromotionTeam(ret[idx], ret[idx + 1], teamPanel, defStr)
            idx = idx + 2
            list:pushBackCustomItem(teamPanel)
        end
    end
end

function NewKuafzcscDlg:setFinalMatch(round)
    round = round or 1
    local data = KuafzcMgr:getLeagueDataBySeason(self.seasonNo)
    if not data then return end
    local knockoutData = data.ret.knockoutInfo
    if round == #knockoutData then
        local viewbtn = self:getControl("ViewCombatButton", nil, "JuesaiFinalMatchPanel")

        if knockoutData[round][1] and knockoutData[round][1][1] ~= "" then
            local panel = self:getControl("2To1Panel", nil, "JuesaiFinalMatchPanel")

            for j = 1, 2 do
                local distPanel = self:getControl("DistPanel_" .. j, nil, "JuesaiFinalMatchPanel")
                self:setLabelText("DistLabel", knockoutData[round][1][j], distPanel)

                local line1 = self:getControl("LineImage_1", nil, distPanel)
                if knockoutData[round][1].winner == knockoutData[round][1][j] then
                    gf:addRedEffect(line1)
                else
                    gf:removeRedEffect(line1)
                end
            end

            self:setLabelText("DistLabel", CHS[4100733] .. " " .. knockoutData[round][1].winner, panel)

            local panel = self:getControl("2To1TimePanel", nil, "JuesaiFinalMatchPanel")
            if knockoutData[round][1].start_time == 0 then
                self:setLabelText("TimeLabel", "", panel)
            else
                self:setLabelText("TimeLabel", gf:getServerDate(CHS[4100715], knockoutData[round][1].start_time), panel)
            end
            viewbtn.noOpen = false
            return
        else
            for j = 1, 2 do
                local distPanel = self:getControl("DistPanel_" .. j, nil, "JuesaiFinalMatchPanel")
                if j == 1 then
                    self:setLabelText("DistLabel", CHS[4010322], distPanel)
                else
                    self:setLabelText("DistLabel", CHS[4010323], distPanel)
                end

                local line1 = self:getControl("LineImage_1", nil, distPanel)
                gf:removeRedEffect(line1)
            end

            local panel = self:getControl("2To1Panel", nil, "JuesaiFinalMatchPanel")
            self:setLabelText("DistLabel", CHS[4100733], panel)

            local panel = self:getControl("2To1TimePanel", nil, "JuesaiFinalMatchPanel")
            self:setLabelText("TimeLabel", gf:getServerDate(CHS[4100715], knockoutData[round][1].start_time), panel)

            viewbtn.noOpen = true
            return
        end
    else
        self:setPromotion(knockoutData, round)
    end
end

function NewKuafzcscDlg:onMatchTypeXHButton(sender, eventType)
end

function NewKuafzcscDlg:onMatchTypeJSButton(sender, eventType)
end

function NewKuafzcscDlg:onViewCombatButton(sender, eventType)
    WatchCenterMgr:setDefTypeMenu(CHS[4100704])
    DlgMgr:sendMsg("GameFunctionDlg", "onWatchCenterButton")
    self:onCloseButton()
end

function NewKuafzcscDlg:onSelectNumberListView(sender, eventType)
end

function NewKuafzcscDlg:onSelectAreaListView(sender, eventType)
end

-- 模拟点击某一届
function NewKuafzcscDlg:onClickSeason(seasonNo)
    local list = self:getControl("NumberListView")
    local btn = list:getChildByTag(seasonNo)

    self:onSelectFloatButton(btn)
end

-- 设置左侧小组checkBox
function NewKuafzcscDlg:setTeamView(count)
    local checkBoxTab = {}

    local list = self:resetListView("TeamListView", 3)
    for i = 1, count do
        local checkBox = self.teamCheckBox:clone()
        self:setLabelText("Label", string.format(CHS[4010371], gf:changeNumToChinese(i)), checkBox)
        local ctlName = "TeamCheckBox_" .. i
        checkBox:setName(ctlName)
        list:pushBackCustomItem(checkBox)

        table.insert( checkBoxTab, ctlName)
    end

    return checkBoxTab
end

-- 收到届数信息
function NewKuafzcscDlg:MSG_CSML_ALL_SIMPLE(data)
    -- 设置届数悬浮面板
    self:setSessionPanel(data)

    -- 模拟点击最近的一届
    self:onClickSeason(data.season_no)

    -- 当前所在
    if data.inGroup[data.season_no] ~= 0 then
        self:setLabelText("NoteLabel", string.format(CHS[4010324], gf:changeNumToChinese(data.inGroup[data.season_no])))
        self:setCtrlVisible("NoteImage", true)
    else
        self:setLabelText("NoteLabel", CHS[4010325])
        self:setCtrlVisible("NoteImage", true)
    end
end

-- 收到届数信息
function NewKuafzcscDlg:MSG_CSML_LEAGUE_DATA(data)
    local ret = data.ret
    -- 开战时间
    if not ret.startWarTime or ret.startWarTime == 0 then
        self:setLabelText("DateLabel", "", "NotePanel")
        self:setLabelText("TimeLabel", "", "NotePanel")
    else
        self:setLabelText("DateLabel", gf:getServerDate(CHS[4300031], ret.startWarTime), "NotePanel")
        local ti1 = gf:getServerDate("%H:%M", ret.startWarTime)
        local ti2 = gf:getServerDate("%H:%M", ret.startWarTime + ret.match_duration)
        local timeStr = string.format("%s - %s", ti1, ti2)
        self:setLabelText("TimeLabel", timeStr, "NotePanel")
    end

    local timeData = KuafzcMgr:getKfzcSjData()
    -- 如果是当前季，开下开始没有
    if data.seasonNo == timeData.season_no and (timeData.group_ti > gf:getServerTime()) then
        self:setCtrlVisible("NoticePanel", true, "RoundMatchPanel")
        self:setCtrlVisible("DistListPanel", false, "RoundMatchPanel")
        self:setCtrlVisible("MatchTypeButton", false)
        self:resetListView("TeamListView", 3)
        return
    end

    self:setCtrlVisible("MatchTypeButton", true)
    self:setCtrlVisible("NoticePanel", false, "RoundMatchPanel")
    self:setCtrlVisible("DistListPanel", true, "RoundMatchPanel")


    local checkBoxs = self:setTeamView(ret.groupInfo.count)
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, checkBoxs, self.onTeamCheckBox)

    -- 设置循环赛
    self.radioGroup:setSetlctByName("TeamCheckBox_1")

    -- 设置淘汰赛
    self:setFinalMatchPanel(ret)

    -- 开战时间
    if not ret.startWarTime or ret.startWarTime == 0 then
        self:setLabelText("DateLabel", "", "NotePanel")
        self:setLabelText("TimeLabel", "", "NotePanel")
    else
        self:setLabelText("DateLabel", gf:getServerDate(CHS[4300031], ret.startWarTime), "NotePanel")
        local ti1 = gf:getServerDate("%H:%M", ret.startWarTime)
        local ti2 = gf:getServerDate("%H:%M", ret.startWarTime + ret.match_duration)
        local timeStr = string.format("%s - %s", ti1, ti2)
        self:setLabelText("TimeLabel", timeStr, "NotePanel")
    end
end

function NewKuafzcscDlg:cleanup()
    self.radioGroup = nil
    self.allSimpleData = nil
    self.sss = 0
end


return NewKuafzcscDlg
