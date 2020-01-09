-- GiveRuleDlg.lua
-- Created by 
-- 

local GiveRuleDlg = Singleton("GiveRuleDlg", Dialog)

function GiveRuleDlg:init()
    self:bindListener("BackImage", self.onCloseButton)
end

return GiveRuleDlg
