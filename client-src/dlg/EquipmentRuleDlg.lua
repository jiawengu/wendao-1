
-- EquipmentRuleDlg.lua
-- Created by songcw July/30/2015
-- 

local EquipmentRuleDlg = Singleton("EquipmentRuleDlg", Dialog)

function EquipmentRuleDlg:init()
    self:setCtrlVisible("SplitRulePanel", false)
    self:setCtrlVisible("ReformRulePanel", false)
    self:setCtrlVisible("RefiningRulePanel", false)
    self:setCtrlVisible("StrengthenRulePanel", false)
    self:setCtrlVisible("RefiningPinkRulePanel", false)
    self:setCtrlVisible("RefiningYellowRulePanel", false)
    self:setCtrlVisible("UpgradeRulePanel", false)
    self:setCtrlVisible("SuitRulePanel", false)
    self:setCtrlVisible("IdentifyRulePanel", false)
    self:setCtrlVisible("EvolveRulePanel", false)
    self:setCtrlVisible("GemIdentifyRulePanel", false)
    self:setCtrlVisible("DegenerationRulePanel", false)
    self:setCtrlVisible("RefiningGongmingRulePanel", false)
    self:setCtrlVisible("TempUpgradeRulePanel", false)
    self:setCtrlVisible("TempEvolveRulePanel", false)
    self:setCtrlVisible("TempDegenerationRulePanel", false)
    
    self:bindListener("SplitRulePanel", self.onCloseButton)
    self:bindListener("ReformRulePanel", self.onCloseButton)
    self:bindListener("RefiningRulePanel", self.onCloseButton)
    self:bindListener("StrengthenRulePanel", self.onCloseButton)
    self:bindListener("RefiningPinkRulePanel", self.onCloseButton)
    self:bindListener("RefiningYellowRulePanel", self.onCloseButton)
    self:bindListener("UpgradeRulePanel", self.onCloseButton)
    self:bindListener("SuitRulePanel", self.onCloseButton)
    self:bindListener("IdentifytRulePanel", self.onCloseButton)
    self:bindListener("EvolveRulePanel", self.onCloseButton)
    self:bindListener("GemIdentifyRulePanel", self.onCloseButton)
    self:bindListener("DegenerationRulePanel", self.onCloseButton)
    self:bindListener("RefiningGongmingRulePanel", self.onCloseButton)
    self:bindListener("TempUpgradeRulePanel", self.onCloseButton)
    self:bindListener("TempEvolveRulePanel", self.onCloseButton)
    self:bindListener("TempDegenerationRulePanel", self.onCloseButton)
end

function EquipmentRuleDlg:showType(dlgName)
    if dlgName == "EquipmentSplitDlg" then
        self:setCtrlVisible("SplitRulePanel", true)
    elseif dlgName == "EquipmentStrengthenDlg" then
        self:setCtrlVisible("StrengthenRulePanel", true)
    elseif dlgName == "EquipmentReformDlg" then
        self:setCtrlVisible("ReformRulePanel", true)
    elseif dlgName == "EquipmentRefiningYellowDlg" then
        self:setCtrlVisible("RefiningYellowRulePanel", true)
    elseif dlgName == "EquipmentRefiningPinkDlg" then
        self:setCtrlVisible("RefiningPinkRulePanel", true)
    elseif dlgName == "EquipmentUpgradeDlg" then
        -- 暂时屏蔽共鸣属性
        if DistMgr:needIgnoreGongming() then
            self:setCtrlVisible("TempUpgradeRulePanel", true)
        else
            self:setCtrlVisible("UpgradeRulePanel", true)
        end
    elseif dlgName == "EquipmentRefiningDlg" then
        self:setCtrlVisible("RefiningRulePanel", true)
    elseif dlgName == "EquipmentRefiningSuitDlg" then
        self:setCtrlVisible("SuitRulePanel", true)
    elseif dlgName == "EquipmentIdentifyDlg" then
        self:setCtrlVisible("IdentifyRulePanel", true)
    elseif dlgName == "EquipmentEvolveDlg" then
        -- 暂时屏蔽共鸣属性
        if DistMgr:needIgnoreGongming() then
            self:setCtrlVisible("TempEvolveRulePanel", true)
        else
            self:setCtrlVisible("EvolveRulePanel", true)
        end
    elseif dlgName == "GemIdentifyRuleDlg" then
        self:setCtrlVisible("GemIdentifyRulePanel", true)
    elseif dlgName == "EquipmentDegenerationDlg" then
        -- 暂时屏蔽共鸣属性
        if DistMgr:needIgnoreGongming() then
            self:setCtrlVisible("TempDegenerationRulePanel", true)
        else
            self:setCtrlVisible("DegenerationRulePanel", true)
        end
    elseif dlgName == "EquipmentRefiningGongmingDlg" then
        self:setCtrlVisible("RefiningGongmingRulePanel", true)
    end
    
end

return EquipmentRuleDlg