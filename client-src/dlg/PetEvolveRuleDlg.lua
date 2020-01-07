-- PetEvolveRuleDlg.lua
-- Created by songcw July/4/2016
-- 宠物进化界面，进化规则

local PetEvolveRuleDlg = Singleton("PetEvolveRuleDlg", Dialog)

function PetEvolveRuleDlg:init()
    self:bindListener("PetEvolveRulePanel", self.onCloseButton)
end

return PetEvolveRuleDlg
