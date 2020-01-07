-- PartyInfoTabDlg.lua
-- Created by songcw Feb/26/2015
-- 装备信息标签

local TabDlg = require('dlg/TabDlg')
local PartyInfoTabDlg = Singleton("PartyInfoTabDlg", TabDlg)

PartyInfoTabDlg.defDlg = "PartyInfoDlg"

PartyInfoTabDlg.dlgs = {
    InfoCheckBox = "PartyInfoDlg",
    MemberCheckBox = "PartyMemberDlg",
    --SkillCheckBox = "PartySkillDlg",
    WelfareCheckBox = "PartyWelfareDlg",
    ActiveCheckBox = "PartyActiveDlg",
}

function PartyInfoTabDlg:init()
    TabDlg.init(self)
    if PartyMgr:canApplyAndPro() == false then
        self:setCtrlEnabled("ApplyCheckBox", false)
    end
end

function PartyInfoTabDlg:getOpenDefaultDlg()
    return TabDlg.getOpenDefaultDlg(self) or "PartyInfoDlg"
end

return PartyInfoTabDlg
