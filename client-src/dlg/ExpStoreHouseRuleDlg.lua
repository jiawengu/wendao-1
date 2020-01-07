-- ExpStoreHouseRuleDlg.lua
-- Created by huangzz Aug/30/2018
-- 经验仓库说明界面

local ExpStoreHouseRuleDlg = Singleton("ExpStoreHouseRuleDlg", Dialog)

function ExpStoreHouseRuleDlg:init()
    self:bindListener("MainPanel", self.onCloseButton)

    local str = self:getLabelText("Label1", "RulePanel")
    str = string.gsub(str, "limit", math.floor(Const.PLAYER_MAX_LEVEL / 10) * 10 - 1)
    self:setLabelText("Label1", str, "RulePanel")
end

return ExpStoreHouseRuleDlg
