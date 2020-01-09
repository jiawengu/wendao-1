-- GMStopMonitoringDlg.lua
-- Created by songcw Mar/24/2016
-- 解除监听对话框

local GMStopMonitoringDlg = Singleton("GMStopMonitoringDlg", Dialog)

function GMStopMonitoringDlg:init()
    self:setFullScreen()
    self:bindListener("StopMonitoringCheckBox", self.onStopButton)
end

function GMStopMonitoringDlg:onStopButton()
    -- 解除接听
    GMMgr:cmdSniffAT("")
end

return GMStopMonitoringDlg
