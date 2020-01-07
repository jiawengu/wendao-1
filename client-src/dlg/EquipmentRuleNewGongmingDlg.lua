-- EquipmentRuleNewGongmingDlg.lua
-- Created by
--

local EquipmentRuleNewGongmingDlg = Singleton("EquipmentRuleNewGongmingDlg", Dialog)

function EquipmentRuleNewGongmingDlg:init()
    self:bindListener("RecommendLink", self.onRecommendLink)
    self:bindListener("AllAttributeLink", self.onAllAttributeLink)
end

function EquipmentRuleNewGongmingDlg:onRecommendLink(sender, eventType)
    DlgMgr:openDlgEx("EquipmentRuleRecommendDlg", "GongmingAttributePanel")
end

function EquipmentRuleNewGongmingDlg:onAllAttributeLink(sender, eventType)
    DlgMgr:openDlgEx("EquipmentRuleAttributeDlg", "Gongming")
end

return EquipmentRuleNewGongmingDlg
