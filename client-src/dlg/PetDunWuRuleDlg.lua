-- PetDunWuRuleDlg.lua
-- Created by yangym Dec/2/2016
-- 宠物顿悟规则对话框

local PetDunWuRuleDlg = Singleton("PetDunWuRuleDlg", Dialog)

local SKILL_LIST =
{
    CHS[3001987],
    CHS[3001988],
    CHS[3001989],
    CHS[3001990],
    CHS[3001991],
}

function PetDunWuRuleDlg:init()
    self:bindListener("Panel", self.onPanelTouch)
    
    for i = 1, 5 do
        local skillPanel = self:getControl("JinJieImage_" .. i)
        local skillName = SKILL_LIST[i]
        local skillAttrib = SkillMgr:getskillAttribByName(skillName)
        local skillIconPath = SkillMgr:getSkillIconPath(skillAttrib.skill_no)
        if not skillIconPath then
            return
        end
        
        self:setImage("JinJieImage_" .. i, skillIconPath)
        self:setItemImageSize("JinJieImage_" .. i)
        local function skillTouchListener(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local rect = self:getBoundingBoxInWorldSpace(sender)
                local dlg = DlgMgr:openDlg("SkillFloatingFrameDlg")
                dlg:setSKillByName(skillName, rect, true)
                
                self.skillFloatingFrameDlgOpened = true
            end
        end
        skillPanel:addTouchEventListener(skillTouchListener)
    end   
end

function PetDunWuRuleDlg:onPanelTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if not self.skillFloatingFrameDlgOpened then
            self:close()
        end

        self.skillFloatingFrameDlgOpened = false
    end
end

return PetDunWuRuleDlg
