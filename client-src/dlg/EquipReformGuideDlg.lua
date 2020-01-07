-- EquipReformGuideDlg.lua
-- Created by
--

local EquipReformGuideDlg = Singleton("EquipReformGuideDlg", Dialog)

function EquipReformGuideDlg:init()
    self:setCtrlFullClient("TouchPanel")
    self.root:setContentSize(self.blank:getContentSize())

    self:bindListener("KnowButton", self.onCloseButton)

    self:setImage("EquipImage", InventoryMgr:getIconFileByName(CHS[3001036]), "EquipPanel_1")

    self:setImage("MaterialImage", InventoryMgr:getIconFileByName(CHS[3001099]))

    self:setImage("EquipImage", InventoryMgr:getIconFileByName(CHS[3001036]), "EquipPanel_2")
end

function EquipReformGuideDlg:onKnowButton(sender, eventType)
end

return EquipReformGuideDlg
