-- Game21PointRuleDlg.lua
-- Created by 
-- 

local Game21PointRuleDlg = Singleton("Game21PointRuleDlg", Dialog)

function Game21PointRuleDlg:init()
    self:bindListener("Game21PointRulePanel", self.onCloseButton)
end

return Game21PointRuleDlg
