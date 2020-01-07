-- EquipmentRuleNewUpgradeDlg.lua
-- Created by
--

local EquipmentRuleNewUpgradeDlg = Singleton("EquipmentRuleNewUpgradeDlg", Dialog)

function EquipmentRuleNewUpgradeDlg:init()
    self:bindListener("PictureLink", self.onPictureLink)
    self:bindListener("GongmingLink", self.onGongmingLink)
    self:bindListener("InheritLink", self.onInheritLink)
end

function EquipmentRuleNewUpgradeDlg:onPictureLink(sender, eventType)
    DlgMgr:openDlg("EquipReformGuideDlg")
end

function EquipmentRuleNewUpgradeDlg:onGongmingLink(sender, eventType)

    DlgMgr:sendMsg("EquipmentRuleNewDlg", "onGotoMenu", CHS[4200592], CHS[4200595])
end

function EquipmentRuleNewUpgradeDlg:onInheritLink(sender, eventType)

    DlgMgr:sendMsg("EquipmentRuleNewDlg", "onGotoMenu", CHS[4200592], CHS[4200593])
end

return EquipmentRuleNewUpgradeDlg
