-- EquipmentRuleNewDegenerationDlg.lua
-- Created by songcw Oct/2018/9
-- 装备退化

local EquipmentRuleNewDegenerationDlg = Singleton("EquipmentRuleNewDegenerationDlg", Dialog)

function EquipmentRuleNewDegenerationDlg:init()
    self:bindListener("PictureLink", self.onPictureLink)
end

function EquipmentRuleNewDegenerationDlg:onPictureLink(sender, eventType)
    DlgMgr:openDlg("EquipEvolutionGuideDlg")
end

return EquipmentRuleNewDegenerationDlg
