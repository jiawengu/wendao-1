-- PetExploreTabDlg.lua
-- Created by lixh Jan/19/2019 
-- 宠物探索页签界面

local TabDlg = require('dlg/TabDlg')
local PetExploreTabDlg = Singleton("PetExploreTabDlg", TabDlg)

PetExploreTabDlg.orderList = {
    ['ExploreCheckBox'] = 1,
    ['SkillCheckBox']   = 2,
}

PetExploreTabDlg.dlgs = {
    ExploreCheckBox = 'PetExploreDlg',
    SkillCheckBox   = 'PetExploreSkillDlg',
}

PetExploreTabDlg.defDlg = "PetExploreDlg"

function PetExploreTabDlg:init()
    TabDlg.init(self)
end

function PetExploreTabDlg:getOpenDefaultDlg()
    return TabDlg.getOpenDefaultDlg(self) or "PetExploreDlg"
end

return PetExploreTabDlg
