-- EquipmentRuleNewRefiningDlg.lua
-- Created by
--

local EquipmentRuleNewRefiningDlg = Singleton("EquipmentRuleNewRefiningDlg", Dialog)

function EquipmentRuleNewRefiningDlg:init()
    self:bindListener("PictureLink", self.onPictureLink)
end

function EquipmentRuleNewRefiningDlg:onPictureLink(sender, eventType)
    DlgMgr:openDlg("EquipArtificeGuideDlg")
end

return EquipmentRuleNewRefiningDlg
