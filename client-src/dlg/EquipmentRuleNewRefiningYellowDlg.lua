-- EquipmentRuleNewRefiningYellowDlg.lua
-- Created by
--

local EquipmentRuleNewRefiningYellowDlg = Singleton("EquipmentRuleNewRefiningYellowDlg", Dialog)

function EquipmentRuleNewRefiningYellowDlg:init()
    self:bindListener("RecommendLink", self.onRecommendLink)
    self:bindListener("AllAttributeLink", self.onAllAttributeLink)
end

function EquipmentRuleNewRefiningYellowDlg:onRecommendLink(sender, eventType)
    DlgMgr:openDlgEx("EquipmentRuleRecommendDlg", "PinkYellowAttributePanel")
end

function EquipmentRuleNewRefiningYellowDlg:onAllAttributeLink(sender, eventType)
    DlgMgr:openDlg("EquipmentRuleAttributeDlg")
end

return EquipmentRuleNewRefiningYellowDlg
