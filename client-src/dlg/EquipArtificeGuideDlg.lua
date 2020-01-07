-- EquipArtificeGuideDlg.lua
-- Created by
--

local EquipArtificeGuideDlg = Singleton("EquipArtificeGuideDlg", Dialog)

function EquipArtificeGuideDlg:init()
    self:setCtrlFullClient("TouchPanel")

    self:bindListener("KnowButton", self.onKnowButton)

    self:bindListener("NextPagePanel", self.onNextPagePanel)

    self:setImage("EquipImage", InventoryMgr:getIconFileByName(CHS[3001026]), "EquipPanel_1")

    self:setImage("MaterialImage", InventoryMgr:getIconFileByName(CHS[3001101]))

    self:setImage("EquipImage", InventoryMgr:getIconFileByName(CHS[3001026]), "EquipPanel_2")

    local effPanel1 = self:getControl("NextPagePanel")
    gf:createArmatureMagic(ResMgr.ArmatureMagic.sjb_arrow_left, effPanel1, Const.ARMATURE_MAGIC_TAG, 8)
end

function EquipArtificeGuideDlg:onKnowButton(sender, eventType)
    self:onCloseButton()
end

function EquipArtificeGuideDlg:onNextPagePanel(sender, eventType)
    DlgMgr:openDlg("EquipStrengthenGuideDlg")
    self:onCloseButton()
end

return EquipArtificeGuideDlg
