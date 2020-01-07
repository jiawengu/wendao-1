-- EquipmentRuleNewSplitDlg.lua
-- Created by
--

local EquipmentRuleNewSplitDlg = Singleton("EquipmentRuleNewSplitDlg", Dialog)

function EquipmentRuleNewSplitDlg:init()
    self:bindListener("PictureLink", self.onPictureLink)
    self:bindListener("RecommendLink", self.onRecommendLink)
end

function EquipmentRuleNewSplitDlg:onPictureLink(sender, eventType)
    DlgMgr:openDlg("EquipSplitGuideDlg")
end

function EquipmentRuleNewSplitDlg:onRecommendLink(sender, eventType)
    DlgMgr:openDlgEx("EquipmentRuleRecommendDlg", "BlueAttributePanel")
end

return EquipmentRuleNewSplitDlg
