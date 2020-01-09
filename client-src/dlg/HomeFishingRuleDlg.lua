-- HomeFishingRuleDlg.lua
-- Created by huangzz Aug/21/2017
-- 居所钓鱼规则界面

local HomeFishingRuleDlg = Singleton("HomeFishingRuleDlg", Dialog)

local RadioGroup = require("ctrl/RadioGroup")

function HomeFishingRuleDlg:init()
    local panel = self:retainCtrl("InstructionsPanel")
    local scrollView = self:getControl("ScrollView")
    panel:setPosition(0, 0)
    panel:setAnchorPoint(0, 0)
    scrollView:addChild(panel)
    
    self.group = RadioGroup.new()
    self.group:setItems(self, {"InstructionsCheckBox", "RuleCheckBox"}, self.onCheckBox)
    
    self.group:setSetlctByName("InstructionsCheckBox", self.onCheckBox)
    self:setCtrlVisible("ScrollView", true)
    self:setCtrlVisible("RuleScrollView", false)
end

function HomeFishingRuleDlg:onCheckBox(sender, eventType)
    if sender:getName() ~= "InstructionsCheckBox" then
        self:setCtrlVisible("ScrollView", false)
        self:setCtrlVisible("RuleScrollView", true)
    else
        self:setCtrlVisible("ScrollView", true)
        self:setCtrlVisible("RuleScrollView", false)
    end
end

return HomeFishingRuleDlg
