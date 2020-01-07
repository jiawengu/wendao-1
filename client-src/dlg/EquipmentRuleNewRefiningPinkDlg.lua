-- EquipmentRuleNewRefiningPinkDlg.lua
-- Created by
--

local EquipmentRuleNewRefiningPinkDlg = Singleton("EquipmentRuleNewRefiningPinkDlg", Dialog)

function EquipmentRuleNewRefiningPinkDlg:init()
    self:bindListener("RecommendLink", self.onRecommendLink)
    self:bindListener("AllAttributeLink", self.onAllAttributeLink)
end

function EquipmentRuleNewRefiningPinkDlg:onRecommendLink(sender, eventType)
    DlgMgr:openDlgEx("EquipmentRuleRecommendDlg", "PinkYellowAttributePanel")
end

function EquipmentRuleNewRefiningPinkDlg:onAllAttributeLink(sender, eventType)
    DlgMgr:openDlg("EquipmentRuleAttributeDlg")
end

return EquipmentRuleNewRefiningPinkDlg
