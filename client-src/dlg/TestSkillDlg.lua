-- TestSkillDlg.lua
-- Created by chenyq Apr/27/2015
-- 技能测试界面

local Group = require('ctrl/RadioGroup')
local TestSkillDlg = Singleton("TestSkillDlg", Dialog)

function TestSkillDlg:init()
    self:bindListener("StartButton", self.onStartButton)
    
    self:getControl("UseHelpSkillCheckBox", Const.UICheckBox):setSelectedState(true)
    self:getControl("ShowDieCheckBox", Const.UICheckBox):setSelectedState(false)

    self.group = Group.new()
    self.group:setItems(self, {"ShowPlayerCheckBox", "ShowPetCheckBox", "ShowDieCheckBox"}, self.onSelected)
    self.group:selectRadio(1)
end

function TestSkillDlg:onSelected(sender, idx)
    self.showType = idx
end

function TestSkillDlg:onStartButton(sender, eventType)
    local para = ''
    
    for i = 1, 10 do
        local ctrl = self:getControl("IconTextField" .. i, Const.UITextField)
        para = para .. (tonumber(ctrl:getStringValue()) or 0) .. ','
    end
    
    local ctrl = self:getControl("UseHelpSkillCheckBox", Const.UICheckBox)
    local useHelpSkill = 0
    if ctrl:getSelectedState() then
        useHelpSkill = 1
    end
    
    para = para .. useHelpSkill .. ','
    para = para .. self.showType
    
    gf:CmdToServer('CMD_ADMIN_TEST_SKILL', { para = para })
end

return TestSkillDlg
