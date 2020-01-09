-- MingrzbInfoDlg.lua
-- Created by songcw Mar/8/2018
-- 名人争霸信息界面

local MingrzbInfoDlg = Singleton("MingrzbInfoDlg", Dialog)
local margin_precent = 4.4

local MAIN_STATE = {
    READY = 1,          -- 准备
    IN_GAME = 2,        -- 比赛中
}

local STATE_PANEL = {
    "YuXuanPanel",        "TaoTaiPanel",        "TaoTaiPanel", "JueSaiPanel"
}

local STATE_DIAPLAY = {
    [1] = "YuXuanPanel",        
    [2] = "YuXuanPanel",            
}

local WAR_CLASS = {
    YUXUAN      = 1,    -- 预选赛
    TAOTAI      = 2,    -- 淘汰赛
    BAN_JUESAI      = 3,    -- 半决赛
    JUESAI      = 4,    -- 决赛
}

function MingrzbInfoDlg:init()
    self:bindListener("SmallButton", self.onSmallButton)
    
    self:setFullScreen()
    self.root:setPositionY(self.root:getPositionY() - self:getWinSize().height  * margin_precent / 100)

    self:hookMsg("MSG_CSB_KICKOUT_TEAM_MATCH_INFO")
    self:hookMsg("MSG_CSB_PRE_KICKOUT_TEAM_MATCH_INFO")
    self:hookMsg("MSG_CSB_MATCH_TIME_INFO")
end

function MingrzbInfoDlg:onUpdate()
    if not self.timeData then return end

    self:setLeftTime(self.timeData)

    self:setTitle(self.timeData)

    -- 10秒请求新数据
    local curTime = gfGetTickCount()
    if not self:getLastOperTime("lastTime") then self:setLastOperTime("lastTime", curTime) end
    if self:isOutLimitTime("lastTime", 10 * 1000) then
        self:setLastOperTime("lastTime", curTime)

        gf:CmdToServer("CMD_CSB_MATCH_INFO", {
        })
    end
end

function MingrzbInfoDlg:setTimeData(data)
    self.timeData = data
end

-- 设置title
function MingrzbInfoDlg:setTitle(data)
    local titlePanel = self:getControl("BKPanel")
    for i = 3, 7 do
        self:setCtrlVisible("TitleImage_" .. i, false, titlePanel)
    end

    -- 决赛一致显示这个就好
    if data.warClass == WAR_CLASS.JUESAI then
        self:setCtrlVisible("TitleImage_7", true, titlePanel)
        return
    end

    -- 准备阶段
    if gf:getServerTime() < data.startTime then
        self:setCtrlVisible("TitleImage_3", true, titlePanel)
        return
    end

    -- 比赛中
    if data.warClass == WAR_CLASS.YUXUAN then
        self:setCtrlVisible("TitleImage_4", true, titlePanel)
    elseif data.warClass == WAR_CLASS.TAOTAI then
        self:setCtrlVisible("TitleImage_5", true, titlePanel)
    elseif data.warClass == WAR_CLASS.BAN_JUESAI then
        self:setCtrlVisible("TitleImage_6", true, titlePanel)
    elseif data.warClass == WAR_CLASS.JUESAI then
        self:setCtrlVisible("TitleImage_7", true, titlePanel)
    end
end

-- 设置预选信息
function MingrzbInfoDlg:setYuxuanData(data)
    -- 晋级条件
    self:setLabelText("WinConditionLabel", string.format(CHS[4101031], data.condition))

    -- 晋级名额
    self:setLabelText("LimitLabel", string.format(CHS[4101032], data.places))

    -- 我的队伍排名
    self:setLabelText("MyTeamRankLabel", string.format(CHS[4101033], data.myTeamRank))

    -- 我的队伍积分
    self:setLabelText("MyTeamPointLabel", string.format(CHS[4101034], data.myTeamPoint))
    
    -- 根据不同的state显示不同panel
    for _, panelName in pairs(STATE_PANEL) do
        self:setCtrlVisible(panelName, panelName == STATE_PANEL[data.warClass])
    end
end

function MingrzbInfoDlg:setWarResult(key, result, panel)
    local myPanel = self:getControl("MyResultPanel", nil, panel)
    local oppPanel = self:getControl("OppResultPanel", nil, panel)

    self:setCtrlVisible("Image_" .. key, true, myPanel)
    self:setCtrlVisible("Image_" .. key, true, oppPanel)

    if result then
        if result == 1 then
            self:setImagePlist("Image_" .. key, ResMgr.ui.party_war_win, myPanel)
            self:setImagePlist("Image_" .. key, ResMgr.ui.party_war_lose, oppPanel)
        else
            self:setImagePlist("Image_" .. key, ResMgr.ui.party_war_lose, myPanel)
            self:setImagePlist("Image_" .. key, ResMgr.ui.party_war_win, oppPanel) 
        end
    else
        self:setImagePlist("Image_" .. key, ResMgr.ui.touming, myPanel)
        self:setImagePlist("Image_" .. key, ResMgr.ui.touming, oppPanel) 
    end
end

-- 设置淘汰赛信息
function MingrzbInfoDlg:setTaoTaiData(data)
    local mainPanel = self:getControl("JueSaiPanel")
    if data.warClass ~= MINGREN_ZHENGBA_CLASS.JUESAI then
        mainPanel = self:getControl("TaoTaiPanel")
    end

    -- 我的队伍名
    self:setLabelText("MyTeamLabel", data.myTeamName, mainPanel)

    -- 敌方队伍名
    self:setLabelText("OppTeamLabel", data.oppTeamName, mainPanel)

    -- 根据不同的state显示不同panel
    for _, panelName in pairs(STATE_PANEL) do
        self:setCtrlVisible(panelName, panelName == STATE_PANEL[data.warClass])
    end
    
    for i = 1, 5 do
        if data.myResult[i] and tonumber(data.myResult[i]) then
            self:setWarResult(i, tonumber(data.myResult[i]), mainPanel)
        else
            self:setWarResult(i, nil, mainPanel)
        end
    end
end

-- 设置时间
function MingrzbInfoDlg:setLeftTime(data)

    if data.warClass == MINGREN_ZHENGBA_CLASS.JUESAI then
        local h = math.floor((data.endTime - gf:getServerTime()) / 3600)
        local m = math.floor(((data.endTime - gf:getServerTime()) % 3600) / 60)
        local s = (data.endTime - gf:getServerTime()) % 60

        self:setLabelText("LeftTimeLabel_1", string.format("%02d:%02d:%02d", h, m, s))
        self:setLabelText("LeftTimeLabel_2", string.format("%02d:%02d:%02d", h, m, s))
        return
    end


    if gf:getServerTime() < data.startTime then
        local h = math.floor((data.startTime - gf:getServerTime()) / 3600)
        local m = math.floor(((data.startTime - gf:getServerTime()) % 3600) / 60)
        local s = (data.startTime - gf:getServerTime()) % 60

        self:setLabelText("LeftTimeLabel_1", string.format("%02d:%02d:%02d", h, m, s))
        self:setLabelText("LeftTimeLabel_2", string.format("%02d:%02d:%02d", h, m, s))
        return
    end

    local h = math.floor((data.endTime - gf:getServerTime()) / 3600)
    local m = math.floor(((data.endTime - gf:getServerTime()) % 3600) / 60)
    local s = (data.endTime - gf:getServerTime()) % 60

    self:setLabelText("LeftTimeLabel_1", string.format("%02d:%02d:%02d", h, m, s))
    self:setLabelText("LeftTimeLabel_2", string.format("%02d:%02d:%02d", h, m, s))
end

function MingrzbInfoDlg:onSmallButton(sender, eventType)
    self:setCtrlVisible("MainPanel", true)
    self:setCtrlVisible("SmallButton", false)
end

function MingrzbInfoDlg:MSG_CSB_MATCH_TIME_INFO(data)
    self:setTimeData(data)
end

function MingrzbInfoDlg:MSG_CSB_PRE_KICKOUT_TEAM_MATCH_INFO(data)
    self:setYuxuanData(data)
end

function MingrzbInfoDlg:MSG_CSB_KICKOUT_TEAM_MATCH_INFO(data)
    self:setTaoTaiData(data)
end

function MingrzbInfoDlg:onCloseButton()
    self:setCtrlVisible("MainPanel", false)
    self:setCtrlVisible("SmallButton", true)
end

return MingrzbInfoDlg

