-- EquipSplitGuideDlg.lua
-- Created by
--

local EquipSplitGuideDlg = Singleton("EquipSplitGuideDlg", Dialog)

function EquipSplitGuideDlg:init()
    self:setCtrlFullClient("TouchPanel")
    self:bindListener("KnowButton", self.onCloseButton)

    self:setImage("EquipImage", InventoryMgr:getIconFileByName(CHS[3001036]))
    self:setItemImageSize("EquipImage")

    self:setImage("MaterialImage", InventoryMgr:getIconFileByName(CHS[3001096]))
    self:setItemImageSize("MaterialImage")

    self:setImage("AttributeImage", InventoryMgr:getIconFileByName(CHS[3001096]))
    self:setItemImageSize("AttributeImage")
end


return EquipSplitGuideDlg
