-- HomeMaterialTabDlg.lua
-- Created by 
-- 


local TabDlg = require('dlg/TabDlg')
local HomeMaterialTabDlg = Singleton("HomeMaterialTabDlg", TabDlg)

-- 按钮与对话框的映射表
HomeMaterialTabDlg.dlgs = {
    AskPanelCheckBox = "HomeMaterialAskDlg",
    GivePanelCheckBox = "HomeMaterialGiveDlg",
}

return HomeMaterialTabDlg
