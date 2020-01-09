-- EquipStrengthenGuideDlg.lua
-- Created by
--

local EquipStrengthenGuideDlg = Singleton("EquipStrengthenGuideDlg", Dialog)

function EquipStrengthenGuideDlg:init()
    self:setCtrlFullClient("TouchPanel")
    self:bindListener("KnowButton", self.onCloseButton)
    self:bindListener("NextPagePanel", self.onNextPagePanel)

    self:setImage("EquipImage", InventoryMgr:getIconFileByName(CHS[3001026]), "EquipPanel_1")

    self:setImage("MaterialImage", InventoryMgr:getIconFileByName(CHS[3001096]), "MaterialPanel_1")

    self:setImage("EquipImage", InventoryMgr:getIconFileByName(CHS[3001026]), "EquipPanel_2")

    self:setImage("MaterialImage", InventoryMgr:getIconFileByName(CHS[3001104]), "MaterialPanel_2")

    local effPanel1 = self:getControl("NextPagePanel")
    gf:createArmatureMagic(ResMgr.ArmatureMagic.sjb_arrow_right, effPanel1, Const.ARMATURE_MAGIC_TAG, -8)
end

function EquipStrengthenGuideDlg:onNextPagePanel(sender, eventType)
    DlgMgr:openDlg("EquipArtificeGuideDlg")
    self:onCloseButton()
end

return EquipStrengthenGuideDlg
