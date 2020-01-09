-- QuanmPKgzDlg.lua
-- Created by yangym Mar/21/2017
-- 全民PK规则界面

local QuanmPKgzDlg = Singleton("QuanmPKgzDlg", Dialog)

function QuanmPKgzDlg:init()
    if DistMgr:curIsTestDist() then
        self:setCtrlVisible("GongcBonusPanel", false)
        self:setCtrlVisible("NeicBonusPanel", true)
        self:setCtrlVisible("GongcResourcePanel", false)
        self:setCtrlVisible("NeicResourcePanel", true)
        self:getControl("GongcBonusPanel"):setContentSize(0, 0)
        self:getControl("GongcResourcePanel"):setContentSize(0, 0)
        
        self:setCtrlVisible("BonusWinLabel_1_Test", true, "SchedulePanel_1")
        self:setCtrlVisible("BonusWinLabel_8_Test", true, "SchedulePanel_1")
        self:setCtrlVisible("BonusWinLabel_9_Test", true, "SchedulePanel_2")
        self:setCtrlVisible("BonusWinLabel_1", false, "SchedulePanel_1")
        self:setCtrlVisible("BonusWinLabel_8", false, "SchedulePanel_1")
        self:setCtrlVisible("BonusWinLabel_9", false, "SchedulePanel_2")
    else
        self:setCtrlVisible("GongcBonusPanel", true)
        self:setCtrlVisible("NeicBonusPanel", false)
        self:setCtrlVisible("GongcResourcePanel", true)
        self:setCtrlVisible("NeicResourcePanel", false)
        self:getControl("NeicBonusPanel"):setContentSize(0, 0)
        self:getControl("NeicResourcePanel"):setContentSize(0, 0)
        
        self:setCtrlVisible("BonusWinLabel_1_Test", false, "SchedulePanel_1")
        self:setCtrlVisible("BonusWinLabel_8_Test", false, "SchedulePanel_1")
        self:setCtrlVisible("BonusWinLabel_9_Test", false, "SchedulePanel_2")
        self:setCtrlVisible("BonusWinLabel_1", true, "SchedulePanel_1")
        self:setCtrlVisible("BonusWinLabel_8", true, "SchedulePanel_1")
        self:setCtrlVisible("BonusWinLabel_9", true, "SchedulePanel_2")
    end
end

return QuanmPKgzDlg