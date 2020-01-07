-- ChargeDrawGiftRuleDlg.lua
-- Created by 
-- 

local ChargeDrawGiftRuleDlg = Singleton("ChargeDrawGiftRuleDlg", Dialog)

function ChargeDrawGiftRuleDlg:init()
    self:bindListener("ChargeDrawGiftRulePanel", self.onCloseButton)
end

return ChargeDrawGiftRuleDlg
