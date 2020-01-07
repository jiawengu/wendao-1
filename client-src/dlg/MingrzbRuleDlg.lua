-- MingrzbRuleDlg.lua
-- Created by 
-- 

local MingrzbRuleDlg = Singleton("MingrzbRuleDlg", Dialog)

function MingrzbRuleDlg:init()
    self:setCtrlVisible("RulePanel1", false)
    self:setCtrlVisible("RulePanel2", false)
    self:setCtrlVisible("RulePanel3", false)
end

function MingrzbRuleDlg:showRulePanel(warClass)
    if warClass == MINGREN_ZHENGBA_CLASS.YUXUAN then
        self:setCtrlVisible("RulePanel1", true)
    elseif warClass == MINGREN_ZHENGBA_CLASS.JUESAI then
        self:setCtrlVisible("RulePanel3", true)
    else
        self:setCtrlVisible("RulePanel2", true)
    end
end


return MingrzbRuleDlg
