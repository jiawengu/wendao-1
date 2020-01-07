-- TreasureRuleDlg.lua
-- Created by zhengjh Apr/20/2016
-- 珍宝规则

local TreasureRuleDlg = Singleton("TreasureRuleDlg", Dialog)

function TreasureRuleDlg:init()
    self:bindListener("NormalSearchRulePanel", self.onCloseButton)
    self:bindListener("EquipmentSearchRulePanel", self.onCloseButton)
    self:bindListener("PetSearchRulePanel", self.onCloseButton)
    self:bindListener("BoothRulePanel", self.onCloseButton)
    self:bindListener("BoothRulePanel2", self.onCloseButton)
end

function TreasureRuleDlg:setRuleType(type)
    self:setCtrlVisible("NormalSearchRulePanel", false)
    self:setCtrlVisible("EquipmentSearchRulePanel", false)
    self:setCtrlVisible("PetSearchRulePanel", false)
    self:setCtrlVisible("BoothRulePanel", false)
    self:setCtrlVisible("BoothRulePanel2", false)
    if type == "normalSearchRule" then
        self:setCtrlVisible("NormalSearchRulePanel", true)
    elseif type == "equipmentSearchRule" then
        self:setCtrlVisible("EquipmentSearchRulePanel", true)
    elseif  type == "petSearchRule" then
        self:setCtrlVisible("PetSearchRulePanel", true)
    elseif type == "boothRule" then
        if MarketMgr:getIsCanShowCashTag() then
            self:setCtrlVisible("BoothRulePanel2", true)
        else
            self:setCtrlVisible("BoothRulePanel", true)
        end
    end   
end

return TreasureRuleDlg
