-- InvadeRuleDlg.lua
-- Created by sujl, Apr/7/2017
-- 异族入侵规则说明

local InvadeRuleDlg = Singleton("InvadeRuleDlg", Dialog)

function InvadeRuleDlg:setDlgType(dlgType)
    local isRecruit = "recruit" == dlgType
    self:setCtrlVisible("RecruitRulePanel", isRecruit)
    self:setCtrlVisible("SupplyRulePanel", not isRecruit)
end

return InvadeRuleDlg