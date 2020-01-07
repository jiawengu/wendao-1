-- WenquangzDlg.lua
-- Created by huangzz Jan/24/2019
-- 玉露仙池-温泉规则界面

local WenquangzDlg = Singleton("WenquangzDlg", Dialog)

function WenquangzDlg:init()
    self:bindListener("RulePanel", self.onCloseButton)
end

return WenquangzDlg
