-- MasterRuleDlg.lua
-- Created by 
-- 

local MasterRuleDlg = Singleton("MasterRuleDlg", Dialog)

function MasterRuleDlg:init()
    -- 有一条需要替换
    local str = string.format(CHS[4101060], MasterMgr:getBeMasterLevel())
    self:setLabelText("Label_12", str)
end

return MasterRuleDlg
