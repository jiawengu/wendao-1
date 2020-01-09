-- MingrzbTabDlg.lua
-- Created by lixh Mar/05/2018
-- 名人争霸赛竞猜Tab界面

local TabDlg = require('dlg/TabDlg')
local MingrzbTabDlg = Singleton("MingrzbTabDlg", TabDlg)

MingrzbTabDlg.orderList = {
    ['JingCaiDlgCheckBox']   = 1,
    ['GeRenDlgCheckBox']     = 2,
    ['SaiChengDlgCheckBox']  = 3,
    ['GuiZeDlgCheckBox']     = 4,
}

MingrzbTabDlg.dlgs = {
    JingCaiDlgCheckBox   = 'MingrzbjcDlg',
    GeRenDlgCheckBox     = 'MingrzbgrDlg',
    SaiChengDlgCheckBox  = 'MingrzbscDlg',
    GuiZeDlgCheckBox     = 'MingrzbgzDlg',
}

MingrzbTabDlg.defDlg = "MingrzbjcDlg"

function MingrzbTabDlg:onPreCallBack(sender, idx)
    local name = sender:getName()
    self.lastSelectDlg = self.dlgs[name]

    if name == "SaiChengDlgCheckBox" and not DlgMgr:getDlgByName("MingrzbscDlg") then
        -- 竞猜主界面，打开赛程时，需通知服务器是在主界面打开的，用0标记
        -- 还有一个赛程界面MingrzbscExDlg，服务器标记为1
        gf:CmdToServer("CMD_CG_REQUEST_SCHEDULE", {openFlag = 0})
        return
    end

    return true
end

function MingrzbTabDlg:getOpenDefaultDlg()
    return TabDlg.getOpenDefaultDlg(self) or "MingrzbjcDlg"
end

function MingrzbTabDlg:cleanup()
    self.lastSelectDlg = nil
end

return MingrzbTabDlg
