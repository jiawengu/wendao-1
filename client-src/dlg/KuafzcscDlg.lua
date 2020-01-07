-- KuafzcsjDlg.lua
-- Created by songcw Aug/7/2017
-- 跨服战场，赛程

local KuafzcscDlg = Singleton("KuafzcscDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local TEAM_CHECKBOX = {
    "TeamCheckBox_1",
    "TeamCheckBox_2",
    "TeamCheckBox_3",
    "TeamCheckBox_4",
}

local LIST_MARGIN = 8

function KuafzcscDlg:init()
    self:bindListener("SessionButton", self.onSessionButton)
    self:bindListener("SelectButton", self.onSelectButton)
    self:bindListener("LevelButton", self.onLevelButton)
    self:bindListener("MatchTypeCheckBox_1", self.onMatchTypeCheckBox_1)
    self:bindListener("MatchTypeCheckBox_2", self.onMatchTypeCheckBox_2)
    self:bindListener("AreaButton", self.onAreaButton)
    self:bindListener("MatchTypeCheckBox_1", self.onMatchTypeCheckBox_1)
    self:bindListener("MatchTypeCheckBox_2", self.onMatchTypeCheckBox_2)
    self:bindListener("MatchTypeButton", self.onMatchTypeButton)
    self:bindListener("MatchTypeXHButton", self.onMatchTypeXHButton)
    self:bindListener("MatchTypeTTButton", self.onMatchTypeTTButton)
    self:bindListener("ViewCombatButton", self.onViewCombatButton)
    self:bindListener("ViewCombatButton", self.onViewCombatButton, "NeiCeFinalMatchPanel")

    self:bindListener("MatchTypeCheckBox_1", self.onMatchTypeCheckBox_1)
    self:bindListener("MatchTypeCheckBox_2", self.onMatchTypeCheckBox_2)
    
    for i = 1, 8 do
        local btn = self:getControl("ViewButton", nil, "MatchPanel_" .. i)
        self:bindTouchEndEventListener(btn, self.onViewButton)
    end
    
    self.selectButton = self:retainCtrl("SelectButton")
    self:bindTouchEndEventListener(self.selectButton, self.onSelectFloatButton)
    self.sessionPanelSize = self.sessionPanelSize or self:getControl("SessionPanel"):getContentSize()
    self.sessionListSize = self.sessionListSize or self:getControl("NumberListView"):getContentSize()
    
    -- 界面中4个悬浮Panel
    self:bindFloatPanelListener("SessionPanel", nil, nil, function ()
        self:setExpandState("SessionButton", false)
    end)
    
    self:bindFloatPanelListener("LevelPanel", nil, nil, function ()
        self:setExpandState("LevelButton", false)
    end)
    
    self:bindFloatPanelListener("AreaPanel", nil, nil, function ()
        self:setExpandState("AreaButton", false)
    end)
    
    self:bindFloatPanelListener("MatchTypePanel", nil, nil, function ()
        self:setExpandState("MatchTypeButton", false)
    end)
    
    -- 初始化隐藏，避免界面闪一下
    for _, name in pairs(TEAM_CHECKBOX) do
        self:setCtrlVisible(name, false)
    end
    
    -- 小组赛checkBox
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, TEAM_CHECKBOX, self.onTeamCheckBox)
    
    self:onMatchTypeXHButton(self:getControl("MatchTypeXHButton"))
    
    -- 请求数据
    local data = KuafzcMgr:getAllSimpleDara()
    if not data then
        KuafzcMgr:queryAllSimple()
    else
        self:MSG_CSL_ALL_SIMPLE(data)
    end
    
    self:hookMsg("MSG_CSL_ALL_SIMPLE")
    self:hookMsg("MSG_CSL_LEAGUE_DATA")
end

-- 小组赛的checkBox
function KuafzcscDlg:onTeamCheckBox(sender, eventType)
    local key = KuafzcMgr:getKeyStr(self.seasonNo, self.level, self.area)
    local data = KuafzcMgr:getLeagueDataByKey(key)

    -- 设置循环赛
    self:setLeagueData(data, eventType) 
end

function KuafzcscDlg:getMyDistArea()     
    local data = KuafzcMgr:getAllSimpleDara()
    local levelData = data.seasonData[self.seasonNo].levelData
    for i = 1, #levelData do
        if levelData[i].minLevel == self.level then
            return levelData[i].league_no, levelData[i].group_no
        end
    end
end

function KuafzcscDlg:getDefaultArea()    
    local data = KuafzcMgr:getAllSimpleDara()
    local levelData = data.seasonData[self.seasonNo].levelData
    for i = 1, #levelData do
        if levelData[i].minLevel == self.level then
            return math.max(levelData[i].league_no, 1), math.max(levelData[i].group_no, 1)
        end
    end
    
    return 1, 1
end

-- 点击悬浮框中的按钮
function KuafzcscDlg:onSelectFloatButton(sender, eventType)        
    local btn = self:getControl(sender.relationBtn)
    btn:setTitleText(sender:getTitleText())
    self:setExpandState(sender.relationBtn, false)    
    self:setCtrlVisible(sender.relationPanel, false)

    local data = KuafzcMgr:getAllSimpleDara()
    if sender.relationBtn == "SessionButton" then           
        -- 点击赛季
        local destSeason = sender:getTag()
        local level, levelStr = self:getMaxLevelRangeBySeason(destSeason)
        self.seasonNo = destSeason
        self.level = level        
        self.area = self:getDefaultArea()

        -- 设置默认的等级段和区组
        local btn = self:getControl("LevelButton")
        btn:setTitleText(levelStr)
        local btn = self:getControl("AreaButton")
        btn:setTitleText(string.format(CHS[4100713], self:getLetter(self.area)))

        -- 请求数据
        local key = KuafzcMgr:getKeyStr(self.seasonNo, self.level, self.area)
        local data = KuafzcMgr:getLeagueDataByKey(key)
        if not data then
            KuafzcMgr:queryLeagueData(self.seasonNo, self.level, self.area)
        else
            local destData = {seasonNo = self.seasonNo, level = self.level, area = self.area}
            self:MSG_CSL_LEAGUE_DATA(destData)
        end
    elseif sender.relationBtn == "LevelButton" then
        -- 点击等级段
        -- 请求数据
        self.level = sender:getTag()
        self.area = self:getDefaultArea()
        local key = KuafzcMgr:getKeyStr(self.seasonNo, self.level, self.area)
        local data = KuafzcMgr:getLeagueDataByKey(key)
        if not data then
            KuafzcMgr:queryLeagueData(self.seasonNo, self.level, self.area)
        else
            self.radioGroup:setSetlctByName("TeamCheckBox_1")
        end
    elseif sender.relationBtn == "AreaButton" then
        -- 点击赛区
        self.area = sender:getTag()
        local key = KuafzcMgr:getKeyStr(self.seasonNo, self.level, self.area)
        local data = KuafzcMgr:getLeagueDataByKey(key)
        if not data then
            KuafzcMgr:queryLeagueData(self.seasonNo, self.level, self.area)
        else
            self.radioGroup:setSetlctByName("TeamCheckBox_1")
            
            -- 设置淘汰赛       
            self:setKnockoutData(data)
        end
    end
end

-- 设置届数悬浮框
function KuafzcscDlg:setSessionPanel(data)
    local list, size = self:resetListView("NumberListView", LIST_MARGIN, ccui.ListViewGravity.centerHorizontal)
    for i = 1, data.seasonNo do
        local btn = self.selectButton:clone()
        btn.relationBtn = "SessionButton"
        btn.relationPanel = "SessionPanel"
        btn:setTag(data.seasonNo - i + 1)
        btn:setTitleText(string.format(CHS[5400353], data.seasonNo - i + 1))
        list:pushBackCustomItem(btn)
    end   
    
    local panel = self:getControl("SessionPanel")
    self:setFloatContentSize(panel, list, data.seasonNo)
end

-- 设置level悬浮框
function KuafzcscDlg:setLevelPanel(data)
    local list, size = self:resetListView("LevelListView", LIST_MARGIN, ccui.ListViewGravity.centerHorizontal)
    for i = 1, data.levelCount do
        local btn = self.selectButton:clone()
        btn.relationBtn = "LevelButton"
        btn.relationPanel = "LevelPanel"
        btn:setTag(data.levelData[i].minLevel)
        if data.levelData[i].maxLevel == 0 then
            btn:setTitleText(string.format(CHS[6000113], data.levelData[i].minLevel))
        else
            btn:setTitleText(string.format(CHS[4100712], data.levelData[i].minLevel, data.levelData[i].maxLevel))
        end
        list:pushBackCustomItem(btn)
    end    

    local panel = self:getControl("LevelPanel")
    self:setFloatContentSize(panel, list, data.levelCount)
end

-- 设置赛区悬浮框 
function KuafzcscDlg:setAreaPanel(count)
    local list, size = self:resetListView("AreaListView", LIST_MARGIN, ccui.ListViewGravity.centerHorizontal)
    
    if not count then return end
    for i = 1, count do
        local btn = self.selectButton:clone()
        btn.relationBtn = "AreaButton"
        btn.relationPanel = "AreaPanel"
        btn:setTag(i)
        btn:setTitleText(string.format(CHS[4100713], self:getLetter(i)))
        list:pushBackCustomItem(btn)
    end    

    local panel = self:getControl("AreaPanel")
    self:setFloatContentSize(panel, list, count)
end

function KuafzcscDlg:setFloatContentSize(panel, list, count)
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

function KuafzcscDlg:setExpandState(panelName, state)
    local panel = panelName
    if type(panelName) == "string" then
        panel = self:getControl(panelName)
    end

    self:setCtrlVisible("ShrinkImage", state, panel)
    self:setCtrlVisible("ExpandImage", not state, panel)
end

function KuafzcscDlg:onLevelButton(sender, eventType)
    local data = KuafzcMgr:getAllSimpleDara()
    if not data then return end
    self:setCtrlVisible("LevelPanel", true)    
    self:setExpandState(sender, true)
end

function KuafzcscDlg:onMatchTypeXHButton(sender, eventType)
    self.matchType = sender:getTitleText()
    local btn = self:getControl("MatchTypeButton")
    btn:setTitleText(sender:getTitleText())
    self:setExpandState("MatchTypeButton", false)
    self:setCtrlVisible("MatchTypePanel", false)

    self:setCtrlVisible("RoundMatchPanel", true)
    self:setCtrlVisible("FinalMatchPanel", false)
    self:setCtrlVisible("NeiCeFinalMatchPanel", false)
end

function KuafzcscDlg:onMatchTypeTTButton(sender, eventType)
    local btn = self:getControl("MatchTypeButton")
    self.matchType = sender:getTitleText()
    btn:setTitleText(sender:getTitleText())
    self:setExpandState("MatchTypeButton", false)
    self:setCtrlVisible("MatchTypePanel", false)

    self:setCtrlVisible("RoundMatchPanel", false)
    local key = KuafzcMgr:getKeyStr(self.seasonNo, self.level, self.area)
    local data = KuafzcMgr:getLeagueDataByKey(key)
    if data and data.knockoutInfo then    
        self:setCtrlVisible("FinalMatchPanel", #data.knockoutInfo ~= 1)
        self:setCtrlVisible("NeiCeFinalMatchPanel", #data.knockoutInfo == 1)
    else
        self:setCtrlVisible("FinalMatchPanel", true)
    end
end

function KuafzcscDlg:onViewCombatButton(sender, eventType)
    WatchCenterMgr:setDefTypeMenu(CHS[4100704])
    DlgMgr:sendMsg("GameFunctionDlg", "onWatchCenterButton")    
    self:onCloseButton()
end

function KuafzcscDlg:onMatchTypeButton(sender, eventType)
    local data = KuafzcMgr:getAllSimpleDara()
    if not data then return end

    self:setCtrlVisible("MatchTypePanel", true)    
    self:setExpandState(sender, true)
end


function KuafzcscDlg:onSessionButton(sender, eventType)
    local data = KuafzcMgr:getAllSimpleDara()
    if not data then return end

    self:setCtrlVisible("SessionPanel", true)    
    self:setExpandState(sender, true)
end

function KuafzcscDlg:onAreaButton(sender, eventType)
    self:setCtrlVisible("AreaPanel", true)
    
    self:setExpandState(sender, true)
end

function KuafzcscDlg:setUnitWarInfo(panel, unitData, warInfo)
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

function KuafzcscDlg:onViewButton(sender, eventType)
    if not sender.warInfo then return end
    local dlg = DlgMgr:openDlg("KuafzczkDlg")
    dlg:setData(sender.warInfo)
end


function KuafzcscDlg:MSG_CSL_ALL_SIMPLE(data)
    -- 设置届数
    self:setSessionPanel(data)

    -- 默认选择最近的那届    
    self:onClickSeason(data.seasonNo)
    
    -- 当前所在
    local area, group = self:getMyDistArea()
    if area and group and area ~= 0 and group ~= 0 then
        self:setLabelText("NoteLabel", string.format(CHS[4100714], self:getLetter(area), gf:changeNumber(group)))
        self:setCtrlVisible("NoteImage", true)
    else
        self:setLabelText("NoteLabel", "")
        self:setCtrlVisible("NoteImage", false)
    end
end

-- 获取最大等级段
function KuafzcscDlg:getMaxLevelRangeBySeason(seasonNo)
    local data = KuafzcMgr:getAllSimpleDara()
    local levelRanges = data["seasonData"][seasonNo]
    
    local maxLevel = 0
    for i = 1, levelRanges.levelCount do
        if maxLevel < levelRanges.levelData[i].minLevel then
            maxLevel = levelRanges.levelData[i].minLevel
        end
    end
  
    return maxLevel, string.format(CHS[6000113], maxLevel)
end

-- 模拟点击某一届
function KuafzcscDlg:onClickSeason(seasonNo)
    local data = KuafzcMgr:getAllSimpleDara()
    
    -- 届数
    local btn = self:getControl("SessionButton")
    btn:setTitleText(string.format(CHS[5400353], seasonNo))
    self:setExpandState("SessionButton", false)
    self:setCtrlVisible("SessionPanel", false)
    self.seasonNo = seasonNo
    
    -- 等级
    local level, levelStr = self:getMaxLevelRangeBySeason(seasonNo)
    local btn = self:getControl("LevelButton")
    btn:setTitleText(levelStr)
    self:setExpandState("LevelButton", false)
    self:setCtrlVisible("LevelPanel", false)
    local levelRanges = data["seasonData"][seasonNo]
    self:setLevelPanel(levelRanges)
    self.level = level
    
    -- 该等级段的赛区
    local btn = self:getControl("AreaButton")
    self.area = self:getDefaultArea()
    btn:setTitleText(string.format(CHS[4100713], self:getLetter(self.area)))
    self:setExpandState("AreaButton", false)
    self:setCtrlVisible("AreaPanel", false)
    local areaRange = self:getAreaRange(seasonNo,level)
    self:setAreaPanel(areaRange)

    KuafzcMgr:queryLeagueData(seasonNo, level, self.area)
end

function KuafzcscDlg:getAreaRange(seasonNo, level)
    local data = KuafzcMgr:getAllSimpleDara()
    local levelRanges = data["seasonData"][seasonNo]
    
    for i = 1, levelRanges.levelCount do
        if level == levelRanges.levelData[i].minLevel then
            return levelRanges.levelData[i].areaCount
        end
    end
end

function KuafzcscDlg:getLetter(num)
    if num == 1 then
        return "A"       
    elseif num == 2 then
        return "B"
    elseif num == 3 then
        return "C"
    elseif num == 4 then
        return "D"
    elseif num == 5 then
        return "F"
    end
end

function KuafzcscDlg:MSG_CSL_LEAGUE_DATA(data)
    if data.seasonNo ~= self.seasonNo or data.level ~= self.level or data.area ~= self.area then return end

    local key = KuafzcMgr:getKeyStr(data.seasonNo, data.level, data.area)
    local data = KuafzcMgr:getLeagueDataByKey(key)
    
    -- 设置区组数目
    for i = 1, 4 do
        if data.groupInfo[i] then
            self:setCtrlVisible("TeamCheckBox_" .. i, true)
        else
            self:setCtrlVisible("TeamCheckBox_" .. i, false)
        end
    end

    -- 设置循环赛    
    self.radioGroup:setSetlctByName("TeamCheckBox_1")

    -- 设置淘汰赛       
    self:setKnockoutData(data)
    
    -- 开战时间
    if not data.startWarTime or data.startWarTime == 0 then    
        self:setLabelText("DateLabel", "", "NotePanel")
        self:setLabelText("TimeLabel", "", "NotePanel")
    else
        self:setLabelText("DateLabel", gf:getServerDate(CHS[4300031], data.startWarTime), "NotePanel")
        local ti1 = gf:getServerDate("%H:%M", data.startWarTime)
        local ti2 = gf:getServerDate("%H:%M", data.startWarTime + data.match_duration)
        local timeStr = string.format("%s - %s", ti1, ti2)
        self:setLabelText("TimeLabel", timeStr, "NotePanel")
    end
end

-- 设置循环赛
function KuafzcscDlg:setLeagueData(data, area)
    local areaData = data.groupInfo[area]
    local distInfo = data.distInfo
    local groupWarInfo = data.groupWarInfo

    for i = 1, 8 do
        local panel = self:getControl("MatchPanel_" .. i)
        if areaData.distInfo[i] then
            local distName = areaData.distInfo[i].distName
            self:setUnitWarInfo(panel, distInfo[distName], groupWarInfo[distName])    
        else
            self:setUnitWarInfo(panel)
        end
    end
end

-- 设置淘汰赛
function KuafzcscDlg:setKnockoutData(data)
    local knockoutData = data.knockoutInfo
    if self.matchType == CHS[4100711] then
        self:setCtrlVisible("NeiCeFinalMatchPanel", #knockoutData == 1)
        self:setCtrlVisible("FinalMatchPanel", not (#knockoutData == 1))
    end


    local function endset4to2(fttData, i)
        if not fttData or not next(fttData) then
            fttData = {}
            fttData[1] = ""
            fttData[2] = ""
            fttData.start_time = 0
            fttData.winnerNo = ""
            fttData.winner = ""
        end
    
        local panel = self:getControl("4To2Panel_" .. i)   
        for j = 1, 2 do
            local distPanel = self:getControl("DistPanel_" .. j, nil, panel)
            
            if fttData[j] == "" then
                self:setLabelText("DistLabel", string.format(CHS[4200446], gf:changeNumber((i - 1) * 2 + j)), distPanel)
            else
                self:setLabelText("DistLabel", fttData[j], distPanel)
            end
            
            
        end

        -- 时间
        if fttData.start_time == 0 then
            self:setLabelText("TimeLabel", "", "4To2TimePanel_" .. i)
        else
            self:setLabelText("TimeLabel", gf:getServerDate(CHS[4100715], fttData.start_time), "4To2TimePanel_" .. i)
        end
        
        self:setCtrlVisible("VSImage", fttData.winnerNo == "", panel)
        self:setCtrlVisible("ResultImage", fttData.winnerNo ~= "", panel)

        local resultImage = self:getControl("ResultImage", nil, panel)
        self:setLabelText("Label", fttData.winnerNo, resultImage)
        
        local function setLine(panelName, isRed)
            local distPanel = self:getControl(panelName, nil, panel)
            local line1 = self:getControl("LineImage_1", nil, distPanel)
            local line2 = self:getControl("LineImage_2", nil, distPanel)
            local line3 = self:getControl("2To1LineImage_1", nil, panel)
            if isRed then
                gf:addRedEffect(line1)
                gf:addRedEffect(line2)
                gf:addRedEffect(line3)
            else
                gf:removeRedEffect(line1)
                gf:removeRedEffect(line2)
                gf:removeRedEffect(line3)
            end
        end
        
        setLine("DistPanel_1", false)
        setLine("DistPanel_2", false)
        if fttData.winnerNo == 1 or fttData.winnerNo == 3 then            
            setLine("DistPanel_1", true)
        elseif fttData.winnerNo == 2 or fttData.winnerNo == 4 then
            setLine("DistPanel_2", true)
        end   
    end    

    -- 如果只有一场，比如内测
    if #knockoutData == 1 then
        local viewbtn = self:getControl("ViewCombatButton", nil, "NeiCeFinalMatchPanel")
        if knockoutData[1][1] and knockoutData[1][1][1] ~= "" then
            local panel = self:getControl("2To1Panel", nil, "NeiCeFinalMatchPanel")
    
            for j = 1, 2 do
                local distPanel = self:getControl("DistPanel_" .. j, nil, "NeiCeFinalMatchPanel")
                self:setLabelText("DistLabel", knockoutData[1][1][j], distPanel)
                
                local line1 = self:getControl("LineImage_1", nil, distPanel)
                if knockoutData[1][1].winner == knockoutData[1][1][j] then                
                    gf:addRedEffect(line1)
                else
                    gf:removeRedEffect(line1)
                end
            end
    
            self:setLabelText("DistLabel", CHS[4100733] .. " " .. knockoutData[1][1].winner, panel)
            
            local panel = self:getControl("2To1TimePanel", nil, "NeiCeFinalMatchPanel")
            if knockoutData[1][1].start_time == 0 then
                self:setLabelText("TimeLabel", "", panel)
            else
                self:setLabelText("TimeLabel", gf:getServerDate(CHS[4100715], knockoutData[1][1].start_time), panel)
            end
            viewbtn.noOpen = false
            return
        else
            for j = 1, 2 do
                local distPanel = self:getControl("DistPanel_" .. j, nil, "NeiCeFinalMatchPanel")
                self:setLabelText("DistLabel", string.format(CHS[4200446], gf:changeNumber(j)), distPanel)

                local line1 = self:getControl("LineImage_1", nil, distPanel)
                gf:removeRedEffect(line1)
            end
            
            local panel = self:getControl("2To1Panel", nil, "NeiCeFinalMatchPanel")
            self:setLabelText("DistLabel", CHS[4100733], panel)
            
            local panel = self:getControl("2To1TimePanel", nil, "NeiCeFinalMatchPanel")
            self:setLabelText("TimeLabel", gf:getServerDate(CHS[4100715], knockoutData[1][1].start_time), panel)
            
            viewbtn.noOpen = true
            return
        end
    end


    -- 设置4进2
    local fourToTwoData = knockoutData[1]
    for i = 1, 2 do
        local fttData = fourToTwoData[i]
        endset4to2(fttData, i)
    end

    -- 2进1    
    if not knockoutData[2] or not next(knockoutData[2]) then
        self:setLabelText("DistLabel", CHS[4100733], "2To1Panel")
        self:setLabelText("TimeLabel", "", "2To1TimePanel")
        return
    end
    
    local viewbtn = self:getControl("ViewCombatButton")    
    if knockoutData[2][1].winner == "" then
        viewbtn.noOpen = true
        self:setLabelText("DistLabel", CHS[4100733], "2To1Panel")
    else
        viewbtn.noOpen = false
        self:setLabelText("DistLabel", CHS[4100733] .. " " .. knockoutData[2][1].winner, "2To1Panel")
    end

    

    
    if knockoutData[2][1].start_time == 0 then
        self:setLabelText("TimeLabel", "", "2To1TimePanel")
    else
        self:setLabelText("TimeLabel", gf:getServerDate(CHS[4100715], knockoutData[2][1].start_time), "2To1TimePanel")
    end
end

return KuafzcscDlg
