-- ChildRuleDlg.lua
-- Created by 
-- 

local ChildRuleDlg = Singleton("ChildRuleDlg", Dialog)

function ChildRuleDlg:init()
    self:bindListener("ChildRulePanel", self.onCloseButton)
end

return ChildRuleDlg
