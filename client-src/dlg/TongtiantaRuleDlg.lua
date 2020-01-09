-- TongtiantaRuleDlg.lua
-- Created by songcw Aug/14/2015
-- 通天塔规则界面

local TongtiantaRuleDlg = Singleton("TongtiantaRuleDlg", Dialog)

function TongtiantaRuleDlg:init()
    self:bindListener("TongtiantaRulePanel", self.onCloseButton)
    self:bindListener("FlyRulePanel", self.onCloseButton)

    self:setCtrlVisible("FlyRulePanel", false)
    self:setCtrlVisible("TongtiantaRulePanel", false)
    self:setCtrlVisible("TongtiantaRulePanel_New", false)
end

function TongtiantaRuleDlg:setRuleType(ruleType)
    if ruleType == "TongtiantaFlyDlg" then
        self:setCtrlVisible("FlyRulePanel", true)
    elseif ruleType == "MissionDlg" then
        self:setCtrlVisible("TongtiantaRulePanel_New", true)
    end
end

return TongtiantaRuleDlg
