-- ActiveVIPDlg.lua
-- Created by yangym Apr/25/2017 
-- 活跃送会员

local ActiveVIPDlg = Singleton("ActiveVIPDlg", Dialog)

local PANEL_NUM = 7
local LEVEL_LIMIT = 60
local ACTIVE_VALUE_LIMIT = 100

function ActiveVIPDlg:init()
    self:bindListener("GetButton", self.onGetButton)
    
    self:setActivityTime()
    self:setConditionInfo()
    
    gf:CmdToServer("CMD_GET_ACTIVE_BONUS_INFO")
    ActivityMgr:CMD_ACTIVITY_LIST()
    
    self:hookMsg("MSG_ACTIVE_BONUS_INFO")
    self:hookMsg("MSG_ACTIVITY_LIST")
end

function ActiveVIPDlg:setActivityTime()
    local activeVIPTimeInfo
    local timeList = ActivityMgr:getStartTimeList()
    if timeList and timeList["activityList"] then
        activeVIPTimeInfo = timeList["activityList"]["active_bonus_vip_2017"]
    end
    
    if not activeVIPTimeInfo then
        return
    end
    
    local startTimeStr = gf:getServerDate(CHS[5420147], tonumber(activeVIPTimeInfo.startTime))
    local endTimeStr = gf:getServerDate(CHS[5420147], tonumber(activeVIPTimeInfo.endTime))
    self:setLabelText("TitleLabel", CHS[5420137] .. startTimeStr .. " - " .. endTimeStr)
end

function ActiveVIPDlg:setConditionInfo()
    local activeVIPInfo = GiftMgr:getActiveVIPInfo()
    if not activeVIPInfo then
        return
    end
    
    for i = 1, PANEL_NUM do
        local panelName = "ConditionInfoPanel_" .. i 
        if i == 1 then
            self:setLabelText("InfoLabel_1", Me:getLevel(), panelName)
            self:setLabelText("InfoLabel_3", LEVEL_LIMIT, panelName)
            
            local levelEnough = (Me:getLevel() >= LEVEL_LIMIT)
            self:setCtrlVisible("StatusLabel", not levelEnough, panelName)
            self:setCtrlVisible("StatusImage", levelEnough, panelName)
        else
            local activeValue = activeVIPInfo["active" .. (i - 1)]
            self:setLabelText("InfoLabel_1", activeValue, panelName)
            self:setLabelText("InfoLabel_3", ACTIVE_VALUE_LIMIT, panelName)

            local activeEnough = (activeValue >= ACTIVE_VALUE_LIMIT)
            self:setCtrlVisible("StatusLabel", not activeEnough, panelName)
            self:setCtrlVisible("StatusImage", activeEnough, panelName)
        end
    end
    
    if activeVIPInfo.fetch_state == 0 then
        self:setCtrlEnabled("GetButton", false)
    elseif activeVIPInfo.fetch_state == 1 then
        self:setCtrlEnabled("GetButton", true)
    elseif activeVIPInfo.fetch_state == 2 then
        self:setCtrlEnabled("GetButton", false)
        self:setLabelText("NumLabel_1", CHS[6000127], "GetButton")
        self:setLabelText("NumLabel_2", CHS[6000127], "GetButton")
    end
end

function ActiveVIPDlg:onGetButton()
    gf:CmdToServer("CMD_FETCH_ACTIVE_BONUS")
end

function ActiveVIPDlg:MSG_ACTIVE_BONUS_INFO()
    self:setConditionInfo()
end

function ActiveVIPDlg:MSG_ACTIVITY_LIST()
    self:setActivityTime()
end


return ActiveVIPDlg