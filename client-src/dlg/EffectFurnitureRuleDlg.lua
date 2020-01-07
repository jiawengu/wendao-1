-- EffectFurnitureRuleDlg.lua
-- Created by lixh Sep/08/2017
-- 金丝鸟笼，白玉观音像，七宝如意， 规则介绍界面

local EffectFurnitureRuleDlg = Singleton("EffectFurnitureRuleDlg", Dialog)

function EffectFurnitureRuleDlg:init()
    self.ruleOne = self:getControl("RulePanel1", nil, "MainPanel")
end

function EffectFurnitureRuleDlg:setRuleByType(type)
    self:setCtrlVisible("RulePanel1", type == 1, "MainPanel")
    self:setCtrlVisible("RulePanel2", type == 2, "MainPanel")
    self:setCtrlVisible("RulePanel3", type == 3, "MainPanel")
end

return EffectFurnitureRuleDlg
