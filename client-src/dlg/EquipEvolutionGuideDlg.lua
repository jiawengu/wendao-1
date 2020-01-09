-- EquipEvolutionGuideDlg.lua
-- Created by
--

local EquipEvolutionGuideDlg = Singleton("EquipEvolutionGuideDlg", Dialog)

function EquipEvolutionGuideDlg:init()

    self:setCtrlFullClient("TouchPanel")
    self:bindListener("KnowButton", self.onCloseButton)

    self:setImage("EquipImage", InventoryMgr:getIconFileByName(CHS[3001025]), "EquipPanel_1")

    self:setImage("MaterialImage", InventoryMgr:getIconFileByName(CHS[3001501]))

    self:setImage("EquipImage", InventoryMgr:getIconFileByName(CHS[3001025]), "EquipPanel_2")
end

function EquipEvolutionGuideDlg:onKnowButton(sender, eventType)
end

return EquipEvolutionGuideDlg
