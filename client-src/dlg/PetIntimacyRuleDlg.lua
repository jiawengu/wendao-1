-- PetIntimacyRuleDlg.lua
-- Created by songcw Sep/20/2017
-- 亲密效果总览界面

local PetIntimacyRuleDlg = Singleton("PetIntimacyRuleDlg", Dialog)

local PANEL_DISPLAY_MAP = {
    SelectButton1 = {"ExcelPanel1", "SelectImage1", "InfoLabel1"},
    SelectButton2 = {"ExcelPanel2", "SelectImage2", "InfoLabel2"},
    SelectButton3 = {"ExcelPanel3", "SelectImage3", "InfoLabel3"},
}

function PetIntimacyRuleDlg:init()
    self:bindListener("SelectButton1", self.onSelectButton)
    self:bindListener("SelectButton2", self.onSelectButton)
    self:bindListener("SelectButton3", self.onSelectButton)
    
    self:onSelectButton(self:getControl("SelectButton1"))
end

function PetIntimacyRuleDlg:setUnSelectState()
    for i = 1, 3 do
        self:setCtrlVisible("SelectImage" .. i, false)
        self:setCtrlVisible("ExcelPanel" .. i, false)
        self:setCtrlVisible("InfoLabel" .. i, false)
    end
end

function PetIntimacyRuleDlg:onSelectButton(sender, eventType)
    self:setUnSelectState()
    
    for _, pName in pairs(PANEL_DISPLAY_MAP[sender:getName()]) do
    
        self:setCtrlVisible(pName, true)
    end
end

function PetIntimacyRuleDlg:onSelectButton2(sender, eventType)
    self:setUnSelectState()
end

return PetIntimacyRuleDlg
