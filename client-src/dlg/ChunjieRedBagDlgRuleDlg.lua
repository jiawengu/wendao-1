-- ChunjieRedBagDlgRuleDlg.lua
-- Created by huangzz Dec/20/2016
-- 春节幸运红包规则界面

local ChunjieRedBagDlgRuleDlg = Singleton("ChunjieRedBagDlgRuleDlg", Dialog)

function ChunjieRedBagDlgRuleDlg:init()
    self:bindListener("ChunjieRedBagDlgRulePanel", self.onCloseButton)
end

return ChunjieRedBagDlgRuleDlg
