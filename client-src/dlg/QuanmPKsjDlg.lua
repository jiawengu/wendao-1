-- QuanmPKsjDlg.lua
-- Created by yangym Mar/21/2017
-- 全民PK时间界面

local MATCH_TIME_STAGE = 10

local QuanmPKsjDlg = Singleton("QuanmPKsjDlg", Dialog)

function QuanmPKsjDlg:init()
    -- 重置界面显示的时间
    for i = 1, MATCH_TIME_STAGE do
        local panel = self:getControl("StagePanel_" .. i)
        self:setLabelText("TimeLabel", "", panel)
    end  
    
    self:hookMsg("MSG_QMPK_MATCH_TIME_INFO")
    gf:CmdToServer("CMD_QMPK_MATCH_TIME_INFO")
end

function QuanmPKsjDlg:refreshTimePanel()
    local timeInfo = QuanminPKMgr:getQMPKMatchTimeInfo()
    if not timeInfo then
        return
    end
    
    local matchTimeStage = QuanminPKMgr:getMatchTimeStage()
    for i = 1, #matchTimeStage do
        local panel = self:getControl("StagePanel_" .. i)
        local time = QuanminPKMgr:getTimeInfoByStage(matchTimeStage[i]) or {}
        local startTime = time[1]
        local endTime = time[2]
        local showStr = ""
        if not startTime then
            showStr = CHS[7002202]
        elseif not endTime then
            showStr = self:getTimeStr(startTime)
        else
            showStr = self:getTimeStr(startTime) .. " - " .. self:getTimeStr(endTime)
        end
        
        self:setLabelText("TimeLabel", showStr, panel)
    end
end

function QuanmPKsjDlg:getTimeStr(time)
    local timeInfo = gf:getServerDate("*t", tonumber(time))
    local timeStr = string.format(CHS[7002203], timeInfo.month, timeInfo.day, timeInfo.hour, timeInfo.min)
    return timeStr
end

function QuanmPKsjDlg:MSG_QMPK_MATCH_TIME_INFO(pkt, data)
    self:refreshTimePanel()
end

return QuanmPKsjDlg