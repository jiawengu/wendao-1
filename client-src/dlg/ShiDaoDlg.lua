-- ShiDaoDlg.lua
-- Created by 
-- 

local ShiDaoDlg = Singleton("ShiDaoDlg", Dialog)

function ShiDaoDlg:init()
    -- self:bindListViewListener("ListView", self.onSelectListView)
    self.rulePanel = self:retainCtrl("RulePanel")
    self.newRulePanel = self:retainCtrl("NewRulePanel")

    local listView = self:getControl("ListView")
    local activity = ActivityMgr:getActivityByName(CHS[6400001])
    if activity and ActivityMgr:checkLimitActCanShow(activity) then
        listView:pushBackCustomItem(self.rulePanel)
    else
        listView:pushBackCustomItem(self.newRulePanel)
    end
end

function ShiDaoDlg:onSelectListView(sender, eventType)
end

return ShiDaoDlg
