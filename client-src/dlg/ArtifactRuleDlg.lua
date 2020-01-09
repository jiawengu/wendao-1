-- ArtifactRuleDlg.lua
-- Created by yangym Dec/23/2016
-- 法宝规则

local ArtifactRuleDlg = Singleton("ArtifactRuleDlg", Dialog)

local ARTIFACT_SPSKILL_LIST = 
{
    CHS[3001942],
    CHS[3001943],
    CHS[3001944],
    CHS[3001945],
    CHS[3001946],
    CHS[3001947], 
}
    
function ArtifactRuleDlg:init()
    self:bindListener("SkillUpRulePanel", self.onCloseButton)
    self:bindListener("RefineRulePanel", self.onCloseButton)
end

function ArtifactRuleDlg:setType(type)
    if type == "refine" then
        self:setCtrlVisible("SkillUpRulePanel", false)
        self:setCtrlVisible("RefineRulePanel", true)
        local backImage = self:getControl("BackImage", nil, "RefineRulePanel")
        backImage:setTouchEnabled(false)
        
        for i = 1, 6 do
            local skillName = ARTIFACT_SPSKILL_LIST[i]
            local panelName = "SkillPanel_" .. i
            local skillImage = self:getControl("SkillImage_1", nil, panelName)
            local skillAttrib = SkillMgr:getskillAttribByName(skillName)
            local skillIconPath = SkillMgr:getSkillIconPath(skillAttrib.skill_no) 
            self:setImage("SkillImage_1", skillIconPath, panelName)
            self:setItemImageSize("SkillImage_1", panelName)
            
            local function skillTouchListener(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local rect = self:getBoundingBoxInWorldSpace(sender)
                    local dlg = DlgMgr:openDlg("SkillFloatingFrameDlg")
                    dlg:setSKillByName(skillName, rect)
                end
            end
            skillImage:addTouchEventListener(skillTouchListener)
        end
    elseif type == "skillup" then
        self:setCtrlVisible("SkillUpRulePanel", true)
        self:setCtrlVisible("RefineRulePanel", false)
    end
end

return ArtifactRuleDlg