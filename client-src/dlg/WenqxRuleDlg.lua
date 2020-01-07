-- WenqxRuleDlg.lua
-- Created by
--

local WenqxRuleDlg = Singleton("WenqxRuleDlg", Dialog)

function WenqxRuleDlg:init(data)
    self:setCtrlVisible("RulePanel_1", data.has_verify == 1)
    self:setCtrlVisible("RulePanel_2", data.has_verify == 0)
end

return WenqxRuleDlg
