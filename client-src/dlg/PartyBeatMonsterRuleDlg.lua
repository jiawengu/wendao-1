-- PartyBeatMonsterRuleDlg.lua
-- Created by 
-- 

local PartyBeatMonsterRuleDlg = Singleton("PartyBeatMonsterRuleDlg", Dialog)

function PartyBeatMonsterRuleDlg:init()
    self:bindListener("PartyBeatMonsterRulePanel", self.onCloseButton)
end

return PartyBeatMonsterRuleDlg
