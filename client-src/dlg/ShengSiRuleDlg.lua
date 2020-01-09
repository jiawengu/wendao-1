-- ShengSiRuleDlg.lua
-- Created by huangzz Apr/28/2018
-- 生死状规则界面

local ShengSiRuleDlg = Singleton("ShengSiRuleDlg", Dialog)

function ShengSiRuleDlg:init()
    self:bindListViewListener("ListView", self.onSelectListView)
end

function ShengSiRuleDlg:onSelectListView(sender, eventType)
end

return ShengSiRuleDlg
