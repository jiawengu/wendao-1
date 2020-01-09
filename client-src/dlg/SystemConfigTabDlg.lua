-- SystemConfigTabDlg.lua
-- Created by 
-- 

local TabDlg = require('dlg/TabDlg')
local SystemConfigTabDlg = Singleton("SystemConfigTabDlg", TabDlg)

SystemConfigTabDlg.dlgs = {
    SystemConfigDlgCheckBox = "SystemConfigDlg",
    SystemPushDlgCheckBox = "SystemPushDlg",
    SystemAccManageDlgCheckBox = "SystemAccManageDlg",
    SystemAutoTalkDlgCheckBox_0 = "AutoTalkDlg",
  --  SystemSwitchLineDlgCheckBox = "SystemSwitchLineDlg"
}

function SystemConfigTabDlg:onSelected(sender, idx)
    if GameMgr.inCombat then         
        if sender:getName() == "SystemSwitchDistDlgCheckBox" then
            gf:ShowSmallTips(CHS[3003689])
            self:setSelectDlg(self.lastDlg)  
            return
        end 
    end

    TabDlg.onSelected(self, sender, idx)  
end

function SystemConfigTabDlg:getOpenDefaultDlg()
    return TabDlg.getOpenDefaultDlg(self) or "SystemConfigDlg"
end


return SystemConfigTabDlg
