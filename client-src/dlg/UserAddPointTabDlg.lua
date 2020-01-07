-- UserAddPointTabDlg.lua
-- Created by lixh2 Dec/26/2017
-- 人物加点，相性加点tab界面

local TabDlg = require('dlg/TabDlg')
local UserAddPointTabDlg = Singleton("UserAddPointTabDlg", TabDlg)

UserAddPointTabDlg.lastDlg = "UserAddPointDlg"

-- 外层 Tab 对话框
UserAddPointTabDlg.outerTabDlg = "UserTabDlg"

-- 按钮与对话框的映射表
UserAddPointTabDlg.dlgs = {
    UserAddPointDlgCheckBox  = "UserAddPointDlg",
    PolarAddPointDlgCheckBox = "PolarAddPointDlg",
}

return UserAddPointTabDlg
