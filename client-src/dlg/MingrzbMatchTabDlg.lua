-- MingrzbMatchTabDlg.lua
-- Created by lixh Api/16 2018
-- 名人争霸赛赛程菜单界面

local TabDlg = require('dlg/TabDlg')
local MingrzbMatchTabDlg = Singleton("MingrzbMatchTabDlg", TabDlg)

MingrzbMatchTabDlg.lastDlg = "MingrzbscExDlg"
MingrzbMatchTabDlg.orderList = {
    ['SaiChengDlgCheckBox']   = 1,
    ['GuiZeDlgCheckBox']     = 2,
}

-- 按钮与对话框的映射表
MingrzbMatchTabDlg.dlgs = {
    SaiChengDlgCheckBox = "MingrzbscExDlg",
    GuiZeDlgCheckBox    = "MingrzbMatchRuleDlg",
}

function MingrzbMatchTabDlg:onPreCallBack(sender, idx)
    local name = sender:getName()
    self.lastSelectDlg = self.dlgs[name]

    if name == "SaiChengDlgCheckBox" and not DlgMgr:getDlgByName("MingrzbscExDlg") then
        gf:CmdToServer("CMD_CG_CAN_OPEN_SECHEDULE")
        return
    end

    return true
end

function MingrzbMatchTabDlg:getOpenDefaultDlg()
    return TabDlg.getOpenDefaultDlg(self) or "MingrzbscExDlg"
end

function MingrzbMatchTabDlg:cleanup()
    self.lastSelectDlg = nil
end

return MingrzbMatchTabDlg
