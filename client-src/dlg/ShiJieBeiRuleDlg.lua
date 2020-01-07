-- ShiJieBeiRuleDlg.lua
-- Created by 
-- 

local ShiJieBeiRuleDlg = Singleton("ShiJieBeiRuleDlg", Dialog)

function ShiJieBeiRuleDlg:init()
    self:bindListViewListener("ListView", self.onSelectListView)
end

function ShiJieBeiRuleDlg:onSelectListView(sender, eventType)
end

return ShiJieBeiRuleDlg
