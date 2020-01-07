-- GuardTabDlg.lua
-- Created by chenyq Jan/26/2015
-- 守护标签页对话框

local TabDlg = require('dlg/TabDlg')
local GuardTabDlg = Singleton("GuardTabDlg", TabDlg)

GuardTabDlg.defDlg = "GuardAttribDlg"

GuardTabDlg.orderList = {
    ["GuardAttribDlgCheckBox"]              = 1,
    ["GuardDevelopDlgCheckBox"]             = 2,
    ["GuardCallDlgCheckBox"]                = 5,
}

-- 按钮与对话框的映射表
GuardTabDlg.dlgs = {
    GuardAttribDlgCheckBox = "GuardAttribDlg",
    GuardDevelopDlgCheckBox = "GuardDevelopDlg",
    GuardCallDlgCheckBox = "GuardCallDlg",
}

return GuardTabDlg
