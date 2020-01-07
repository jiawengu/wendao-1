-- WorldBossRuleDlg.lua
-- Created by huangzz Jan/24/2018
-- 世界BOSS 规则界面

local WorldBossRuleDlg = Singleton("WorldBossRuleDlg", Dialog)

function WorldBossRuleDlg:init()
    self:bindListener("MainPanel", self.onCloseButton)
end

return WorldBossRuleDlg
