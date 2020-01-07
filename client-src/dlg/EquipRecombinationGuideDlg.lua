-- EquipRecombinationGuideDlg.lua
-- Created by
--

local EquipRecombinationGuideDlg = Singleton("EquipRecombinationGuideDlg", Dialog)

function EquipRecombinationGuideDlg:init()
    self:setCtrlFullClient("TouchPanel")

    self:bindListener("KnowButton", self.onCloseButton)

    self:setImage("EquipImage", InventoryMgr:getIconFileByName(CHS[3001026]), "EquipPanel")

    for i = 1, 3 do
        self:setImage("MaterialImage", InventoryMgr:getIconFileByName(CHS[3001096]), "MaterialPanel_" .. i)
    end

    self:setImage("AttributeImage", InventoryMgr:getIconFileByName(CHS[3001026]))
end

function EquipRecombinationGuideDlg:onKnowButton(sender, eventType)
end

return EquipRecombinationGuideDlg
