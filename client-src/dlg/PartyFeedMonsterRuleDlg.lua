-- PartyFeedMonsterRuleDlg.lua
-- Created by 
-- 

local PartyFeedMonsterRuleDlg = Singleton("PartyFeedMonsterRuleDlg", Dialog)

function PartyFeedMonsterRuleDlg:init()
    self:bindListener("PartyFeedMonsterRulePanel", self.onCloseButton)
end

return PartyFeedMonsterRuleDlg
