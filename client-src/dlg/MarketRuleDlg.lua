-- MarketRuleDlg.lua
-- Created by zhengjh Aug/22/2015
-- 摆摊规则

local MarketRuleDlg = Singleton("MarketRuleDlg", Dialog)

function MarketRuleDlg:init()
    self:bindListener("NormalSearchRulePanel", self.onCloseButton)
    self:bindListener("EquipmentSearchRulePanel", self.onCloseButton)
    self:bindListener("AttributeSearchRulePanel", self.onCloseButton)
    self:bindListener("PetSearchRulePanel", self.onCloseButton)
    self:bindListener("BoothRulePanel", self.onCloseButton)
    self:bindListener("AuctionRulePanel", self.onCloseButton)

    self:bindListener("JubaoPlayerSearchRulePanel", self.onCloseButton)
    self:bindListener("JubaoPetSearchRulePanel", self.onCloseButton)
    self:bindListener("JubaoEquipmentSearchRulePanel", self.onCloseButton)
    self:bindListener("JubaoJewelrySearchRulePanel", self.onCloseButton)
end

function MarketRuleDlg:setRuleType(type)
    self:setCtrlVisible("NormalSearchRulePanel", false)
    self:setCtrlVisible("EquipmentSearchRulePanel", false)
    self:setCtrlVisible("AttributeSearchRulePanel", false)
    self:setCtrlVisible("PetSearchRulePanel", false)
    self:setCtrlVisible("BoothRulePanel", false)
    self:setCtrlVisible("AuctionRulePanel", false)
    self:setCtrlVisible("JewelrySearchRulePanel", false)

    self:setCtrlVisible("JubaoPlayerSearchRulePanel", false)
    self:setCtrlVisible("JubaoPetSearchRulePanel", false)
    self:setCtrlVisible("JubaoEquipmentSearchRulePanel", false)
    self:setCtrlVisible("JubaoJewelrySearchRulePanel", false)
    self:setCtrlVisible("DesignatedRulePanel", false)
    self:setCtrlVisible("ViewDesignatedRulePanel", false)
    self:setCtrlVisible("MarketGoldVendueRulePanel", false)

    if type == "normalSearchRule" then
        self:setCtrlVisible("NormalSearchRulePanel", true)
    elseif type == "equipmentSearchRule" then
        self:setCtrlVisible("EquipmentSearchRulePanel", true)
    elseif  type == "attributeSearchRule" then
        self:setCtrlVisible("AttributeSearchRulePanel", true)
    elseif  type == "petSearchRule" then
        self:setCtrlVisible("PetSearchRulePanel", true)
    elseif type == "boothRule" then
        self:setCtrlVisible("BoothRulePanel", true)
    elseif type == "AuctionRulePanel" then
        self:setCtrlVisible("AuctionRulePanel", true)
    elseif type == "JewelrySearchCheckBox" then
        self:setCtrlVisible("JewelrySearchRulePanel", true)

    elseif type == "JuBaoPlayer" then
        self:setCtrlVisible("JubaoPlayerSearchRulePanel", true)
    elseif type == "JuBaoEquip" then
        self:setCtrlVisible("JubaoEquipmentSearchRulePanel", true)
    elseif type == "JuBaoEquipJewelry" then
        self:setCtrlVisible("JubaoJewelrySearchRulePanel", true)
    elseif type == "JuBaoEquipPet" then
        self:setCtrlVisible("JubaoPetSearchRulePanel", true)
    elseif type == "MarketGoldItemInfoDlg" then
        self:setCtrlVisible("DesignatedRulePanel", true)
    elseif type == "onViewNoteButton" then
        self:setCtrlVisible("ViewDesignatedRulePanel", true)
    elseif type == "VendueReSellPanel" then
        self:setCtrlVisible("MarketGoldVendueRulePanel", true)
    end
end

return MarketRuleDlg
