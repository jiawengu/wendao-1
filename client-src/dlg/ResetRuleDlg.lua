-- ResetRuleDlg.lua
-- Created by 
-- 

local ResetRuleDlg = Singleton("ResetRuleDlg", Dialog)

function ResetRuleDlg:init()
    self:bindListener("ResetRulePanel", self.onCloseButton)
end

return ResetRuleDlg
