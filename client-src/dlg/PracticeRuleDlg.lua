-- PracticeRuleDlg.lua
-- Created by zjh Jul/8/2015
-- 练功说明

local PracticeRuleDlg = Singleton("PracticeRuleDlg", Dialog)

function PracticeRuleDlg:init()
    self:bindListener("MainPanel", self.onCloseButton)
end

return PracticeRuleDlg
