-- LonghzbycDlg.lua
-- Created by songcw Nov/28/2016
-- 龙争虎斗赛预测界面

local LonghzbycDlg = Singleton("LonghzbycDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local LEVEL_RANGE_CHECKBOX = {
    "LevelCheckBox_1",
    "LevelCheckBox_2",
    "LevelCheckBox_3",
    "LevelCheckBox_4",
}

local LEVEL_KEY = {
    ["LevelCheckBox_1"] = "60-79",
    ["LevelCheckBox_2"] = "80-89",
    ["LevelCheckBox_3"] = "90-99",
    ["LevelCheckBox_4"] = "100-109",
}

LonghzbycDlg.levelKey = ""

function LonghzbycDlg:init()
    self:bindListener("VoteButton", self.onVoteButton)
    
    -- 单选框初始化
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, LEVEL_RANGE_CHECKBOX, self.onLevelCheckBox)
    self.radioGroup:setSetlctByName(LEVEL_RANGE_CHECKBOX[1])    
 
    
    self:hookMsg("MSG_LH_GUESS_CAMP_SCORE")
    self:hookMsg("MSG_LH_GUESS_TEAM_INFO")
end

-- 设置数据
function LonghzbycDlg:setData(data)
    -- 设置青龙阵营
    self:setQLData(data)

    -- 设置白虎阵营
    self:setBHData(data)
end

-- 根据 Camp_index获取数据
function LonghzbycDlg:getDataByCamp_index(Camp_index, data)
    if not data then return end
    for i = 1, 8 do
        if data[i].camp_index == Camp_index then
            return data[i]
        end
    end
    
    return 
end

-- 设置青龙阵营信息
function LonghzbycDlg:setQLData(data)
    local panel = self:getControl("DragonPanel")
    local qlData = data.QLData
    local totalScore = 0
    for i = 1, 8 do
        local teamPanel = self:getControl("TeamInfoPanel_" .. i, nil, panel)
        local infoData = self:getDataByCamp_index(i, qlData)
        if infoData then
            self:setLabelText("NameLabel", infoData.name, teamPanel)
            self:setLabelText("ScoreLabel", infoData.score, teamPanel)
            totalScore = totalScore + infoData.score

            local info = {race_name = data.race_name, camp_type = "camp_qinglong", camp_index = infoData.camp_index}
            teamPanel.info = info
        else
            self:setLabelText("NameLabel", "", teamPanel)
            self:setLabelText("ScoreLabel", "", teamPanel)
            teamPanel.info = nil
        end
        
        self:bindTouchEndEventListener(teamPanel, self.onSelectTeam)
    end
    
    -- 总积分
    self:setLabelText("QLScoreLabel", totalScore)
end

-- 设置白虎阵营信息
function LonghzbycDlg:setBHData(data)
    local panel = self:getControl("TigerPanel")
    local bhData = data.BHData
    local totalScore = 0
    for i = 1, 8 do
        local teamPanel = self:getControl("TeamInfoPanel_" .. i, nil, panel)
        local infoData = self:getDataByCamp_index(i, bhData)
        if infoData then
            self:setLabelText("NameLabel", infoData.name, teamPanel)
            self:setLabelText("ScoreLabel", infoData.score, teamPanel)
            totalScore = totalScore +infoData.score
            
            local info = {race_name = data.race_name, camp_type = "camp_baihu", camp_index = infoData.camp_index}
            teamPanel.info = info
        else
            self:setLabelText("NameLabel", "", teamPanel)
            self:setLabelText("ScoreLabel", "", teamPanel)
            
            teamPanel.info = nil
        end
        self:bindTouchEndEventListener(teamPanel, self.onSelectTeam)
    end
    
    -- 总积分
    self:setLabelText("BHScoreLabel", totalScore)
end

-- 点击某个队伍
function LonghzbycDlg:onSelectTeam(sender, eventType)
    local info = sender.info

    if not info then return end
    LongZHDMgr:queryTeamInfo(info.race_name, info.camp_type, info.camp_index)
end

function LonghzbycDlg:onLevelCheckBox(sender, eventType)
    self.levelKey = LEVEL_KEY[sender:getName()]
    LongZHDMgr:queryCampInfo(self.levelKey)
    
    local data = LongZHDMgr:getScoreDatabyKey(self.levelKey)
    if data then
        -- 设置数据
        self:setData(data)
    else
        self:setData({})
    end   
end

function LonghzbycDlg:onVoteButton(sender, eventType)
    -- 打开预测界面，选中相应的check
    local dlg = DlgMgr:openDlg("LonghzbycczDlg")
    local checkName = self.radioGroup:getSelectedRadioName()
    dlg:initCheckBoxs(checkName)
end

function LonghzbycDlg:MSG_LH_GUESS_CAMP_SCORE(data)
    -- 当前选择的等级段和服务器下发一致，设置数据
    if data.race_name == self.levelKey then
        self:setData(data)
    end
end

-- 打开队伍信息
function LonghzbycDlg:MSG_LH_GUESS_TEAM_INFO(data)
    local dlg = DlgMgr:openDlg("LonghzbTeamInfoDlg")
    dlg:setData(data)
end

return LonghzbycDlg
