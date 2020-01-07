-- EquipmentRuleNewSuitDlg.lua
-- Created by
--

local EquipmentRuleNewSuitDlg = Singleton("EquipmentRuleNewSuitDlg", Dialog)

function EquipmentRuleNewSuitDlg:init()
    self:bindListener("PictureLink", self.onPictureLink)
    self:bindListener("AllAttributeLink", self.onAllAttributeLink)
end

function EquipmentRuleNewSuitDlg:onPictureLink(sender, eventType)
    DlgMgr:openDlg("EquipSuitGuideDlg")
end

function EquipmentRuleNewSuitDlg:onAllAttributeLink(sender, eventType)
    DlgMgr:openDlgEx("EquipmentRuleAttributeDlg", "Suit")
end

return EquipmentRuleNewSuitDlg
