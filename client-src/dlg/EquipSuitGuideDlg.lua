-- EquipSuitGuideDlg.lua
-- Created by
--

local EquipSuitGuideDlg = Singleton("EquipSuitGuideDlg", Dialog)

function EquipSuitGuideDlg:init()
    self:setCtrlFullClient("TouchPanel")

    self:bindListener("Button_1", self.onButton_1)
    self:bindListener("KnowButton", self.onCloseButton)


    self:setImage("EquipImage", InventoryMgr:getIconFileByName(CHS[3001026]), "EquipPanel_1")

    self:setImage("MaterialImage", InventoryMgr:getIconFileByName(CHS[3001103]), "MaterialPanel_1")

    self:setImage("EquipImage", InventoryMgr:getIconFileByName(CHS[3001026]), "EquipPanel_2")
end

function EquipSuitGuideDlg:onButton_1(sender, eventType)

    DlgMgr:openDlg("EquipXiangXingGuideDlg")
end

function EquipSuitGuideDlg:onKnowButton(sender, eventType)
end

return EquipSuitGuideDlg
