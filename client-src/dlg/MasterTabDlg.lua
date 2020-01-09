-- MasterTabDlg.lua
-- Created by 
-- 



local TabDlg = require('dlg/TabDlg')
local MasterTabDlg = Singleton("MasterTabDlg", TabDlg)

-- 按钮与对话框的映射表
MasterTabDlg.dlgs = {
    MasterDlgCheckBox = "MasterDlg",
    RelationDlgCheckBox = "MasterRelationDlg",
    RuleDlgCheckBox = "MasterRuleDlg",
}

return MasterTabDlg
