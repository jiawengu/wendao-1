-- InnMainRuleDlg.lua
-- Created by lixh Jul/17/2018
-- 客栈悬浮框

local InnMainRuleDlg = Singleton("InnMainRuleDlg", Dialog)

function InnMainRuleDlg:init()
    self:setFullScreen()
end

function InnMainRuleDlg:setType(type, str1, str2)
    self:setCtrlVisible("WaitRulePanel", false)
    self:setCtrlVisible("WaitRulePanel2", false)
    self:setCtrlVisible("LevelRulePanel", false)
    self:setCtrlVisible("DeluxeRulePanel", false)
    self:setCtrlVisible("PersonNumRulePanel", false)
    self:setCtrlVisible("PersonTimeRulePanel", false)
    self:setCtrlVisible("TotalTimeRulePanel", false)
    if type == "WaitRule" then
        self:setCtrlVisible("WaitRulePanel", true)
        self:setLabelText("Label1", str1, "WaitRulePanel")
    elseif type == "WaitRule2" then
        local root = self:getControl("WaitRulePanel2")
        root:setVisible(true)
        self:setLabelText("Label1", str1, root)
        if str2 == 1 then
            for i = 1, 6 do
                self:setCtrlVisible("Label9_" .. i, true, root)
                self:setCtrlVisible("Label10_" .. i, false, root)
            end
        else
            for i = 1, 6 do
                self:setCtrlVisible("Label9_" .. i, false, root)
                self:setCtrlVisible("Label10_" .. i, true, root)
            end
        end
    elseif type == "LevelRule" then
        self:setCtrlVisible("LevelRulePanel", true)
        self:setLabelText("Label1", str1, "LevelRulePanel")
        self:setLabelText("Label2", str2, "LevelRulePanel")
    elseif type == "DeluxeRule" then
        self:setCtrlVisible("DeluxeRulePanel", true)
    elseif type == "PersonNumRule" then
        self:setCtrlVisible("PersonNumRulePanel", true)
    elseif type == "PersonTimeRule" then
        self:setCtrlVisible("PersonTimeRulePanel", true)
    elseif type == "TotalTimeRule" then
        self:setCtrlVisible("TotalTimeRulePanel", true)
    end
end

return InnMainRuleDlg
