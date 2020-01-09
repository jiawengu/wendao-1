-- NewChargeDrawGiftRuleDlg.lua
-- Created by huang Dec/12/2017
-- 新充值好礼规则界面

local NewChargeDrawGiftRuleDlg = Singleton("NewChargeDrawGiftRuleDlg", Dialog)

function NewChargeDrawGiftRuleDlg:init()
    self:bindListener("RulePanel", self.onRulePanel)
end

function NewChargeDrawGiftRuleDlg:onRulePanel()
    self:close()
end

return NewChargeDrawGiftRuleDlg
