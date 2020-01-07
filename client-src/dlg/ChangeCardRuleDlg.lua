-- ChangeCardRuleDlg.lua
-- Created by 
-- 

local ChangeCardRuleDlg = Singleton("ChangeCardRuleDlg", Dialog)

function ChangeCardRuleDlg:init()
    local panel = self:getControl("PagePanel")
    panel:removeFromParent()
    local scrollview = self:getControl("ScrollView")
    scrollview:addChild(panel)
    scrollview:setInnerContainerSize(panel:getContentSize())
end

return ChangeCardRuleDlg
