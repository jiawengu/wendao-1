-- ShengSiTabDlg.lua
-- Created by haungzz Apr/28/2018
-- 生死状标签页

local TabDlg = require('dlg/TabDlg')
local ShengSiTabDlg = Singleton("ShengSiTabDlg", TabDlg)

ShengSiTabDlg.dlgs = {
    ShengSiRuleDlgCheckBox = "ShengSiRuleDlg",
    ShengSiHistoryDlgCheckBox = "ShengSiHistoryDlg",
}

return ShengSiTabDlg
