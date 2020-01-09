-- MaintenanceConfirmDlg
-- Created by yangym Nov/03/2016
-- 维护提示界面

local MaintenanceConfirmDlg = Singleton("MaintenanceConfirmDlg", Dialog)

function MaintenanceConfirmDlg:init()
    self:bindListener("ConfrimButton", self.onConfrimButton)
end

function MaintenanceConfirmDlg:getCfgFileName()
    return ResMgr:getDlgCfg("LoginConfrimDlg")
end

function MaintenanceConfirmDlg:setText(str)
    self:setLabelText("NoteLabel", str)
end

function MaintenanceConfirmDlg:onConfrimButton(sender, eventType)
    self:close()
end

return MaintenanceConfirmDlg