-- TeamTabDlg.lua
-- Created by sujl, Oct/12/2018
-- 组队选项界面

local TabDlg = require('dlg/TabDlg')
local TeamTabDlg = Singleton("TeamTabDlg", TabDlg)

TeamTabDlg.orderList = {
    ['TeamDlgCheckBox']             = 1,
    ['TeanFixedTabDlgCheckBox']     = 2,
    ['TeamEnlistCheckBox']         = 3,
}

TeamTabDlg.dlgs = {
    TeamDlgCheckBox             = 'TeamDlg',
    TeanFixedTabDlgCheckBox     = 'TeamFixedDlg',
    TeamEnlistCheckBox          = 'TeamEnlistDlg',
}

function TeamTabDlg:init()
    TabDlg.init(self)

    self:setPreCallBack(self.onPreSelect)
end

function TeamTabDlg:onPreSelect(sender, idx)
    local name = sender:getName()
    if name ~= "TeamDlgCheckBox" and not DistMgr:checkCrossDist() then
        return
    end

    if name == "TeamEnlistCheckBox" and not DlgMgr:getDlgByName("TeamEnlistDlg") then
        gf:CmdToServer("CMD_FIXED_TEAM_CHECK", {})
        return false
    end

    return true
end

function TeamTabDlg:cleanup()
    DlgMgr:sendMsg("TeamDlg", "putDown")
end

return TeamTabDlg