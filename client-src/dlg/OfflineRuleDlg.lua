-- OfflineRuleDlg.lua
-- Created by songcw Sep/09/2015
-- 离线刷道规则界面

local OfflineRuleDlg = Singleton("OfflineRuleDlg", Dialog)

function OfflineRuleDlg:init()
    self:bindListener("OfflineRulePanel", self.onCloseButton)
end

return OfflineRuleDlg
