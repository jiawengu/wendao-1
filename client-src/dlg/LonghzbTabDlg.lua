-- LonghzbTabDlg.lua
-- Created by songcw Nov/28/2016
-- 龙争虎斗标签页界面

local TabDlg = require('dlg/TabDlg')
local LonghzbTabDlg = Singleton("LonghzbTabDlg", TabDlg)

LonghzbTabDlg.defDlg = "LonghzbsjDlg"

-- 按钮与对话框的映射表
LonghzbTabDlg.dlgs = {
    LonghzbsjDlgCheckBox = "LonghzbsjDlg",
    LonghzbscDlgCheckBox = "LonghzbscDlg",
    LonghzbycDlgCheckBox = "LonghzbycDlg",
    LonghzbgzDlgCheckBox = "LonghzbgzDlg",
}

return LonghzbTabDlg
