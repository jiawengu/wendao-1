-- EquipmentRuleNewEvovleDlg.lua
-- Created by
--

local EquipmentRuleNewEvovleDlg = Singleton("EquipmentRuleNewEvovleDlg", Dialog)

function EquipmentRuleNewEvovleDlg:init()
    self:bindListener("PictureLink", self.onPictureLink)
end

function EquipmentRuleNewEvovleDlg:onPictureLink(sender, eventType)
    DlgMgr:openDlg("EquipEvolutionGuideDlg")
end

return EquipmentRuleNewEvovleDlg
