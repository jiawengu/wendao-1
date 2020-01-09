-- PetHuanHuaRuleDlg.lua
-- Created by songcw Sep/18/2016
-- 宠物幻化规则说明界面

local PetHuanHuaRuleDlg = Singleton("PetHuanHuaRuleDlg", Dialog)

function PetHuanHuaRuleDlg:init()
    self:bindListener("PetHuanHuaRulePanel", self.onCloseButton)
end

return PetHuanHuaRuleDlg
