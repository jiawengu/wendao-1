-- ArtifactTabDlg.lua
-- Created by yangym Dec/23/2016
-- 法宝

local TabDlg = require('dlg/TabDlg')
local ArtifactTabDlg = Singleton("ArtifactTabDlg", TabDlg)

ArtifactTabDlg.defDlg = "ArtifactRefineDlg"

ArtifactTabDlg.dlgs = {
    ArtifactRefineTabDlgCheckBox = "ArtifactRefineDlg",
    ArtifactSkillUpTabDlgCheckBox = "ArtifactSkillUpDlg",
}

ArtifactTabDlg.orderList = {
    ["ArtifactRefineTabDlgCheckBox"]        = 1,
    ["ArtifactSkillUpTabDlgCheckBox"]     = 2,
}

-- 2分30秒打开时候要记录选中的法宝id
ArtifactTabDlg.lastSelectItemId = nil

function ArtifactTabDlg:init()
    TabDlg.init(self)
end

function ArtifactTabDlg:setLastSelectItemId(id)
    self.lastSelectItemId = id
end

function ArtifactTabDlg:cleanup()
end

function ArtifactTabDlg:getOpenDefaultDlg()
    return TabDlg.getOpenDefaultDlg(self) or "ArtifactRefineDlg"
end

return ArtifactTabDlg
