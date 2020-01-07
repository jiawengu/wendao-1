-- AchievementTabDlg.lua
-- Created by 
-- 

local TabDlg = require('dlg/TabDlg')
local AchievementTabDlg = Singleton("AchievementTabDlg", TabDlg)

-- 按钮与对话框的映射表
AchievementTabDlg.dlgs = {
    AchievementDlgCheckBox = "AchievementListDlg",
    ServiceAchievementDlgCheckBox = "ServiceAchievementDlg",
}



return AchievementTabDlg
