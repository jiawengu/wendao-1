-- EquipmentRuleNewReformDlg.lua
-- Created by
--

local EquipmentRuleNewReformDlg = Singleton("EquipmentRuleNewReformDlg", Dialog)

function EquipmentRuleNewReformDlg:init()
    self:bindListener("PictureLink", self.onPictureLink)
    self:bindListener("RecommendLink", self.onRecommendLink)
end

function EquipmentRuleNewReformDlg:onPictureLink(sender, eventType)
    DlgMgr:openDlg("EquipRecombinationGuideDlg")
end

function EquipmentRuleNewReformDlg:onRecommendLink(sender, eventType)
    DlgMgr:openDlgEx("EquipmentRuleRecommendDlg", "BlueAttributePanel")
end


return EquipmentRuleNewReformDlg
