-- PartySkillBatchDevelopDlg.lua
-- Created by songcw Oct/21/2015
-- 批量研发界面

local PartySkillBatchDevelopDlg = Singleton("PartySkillBatchDevelopDlg", Dialog)

function PartySkillBatchDevelopDlg:init()
    self.skillInfo = nil
    self.skillType = nil
    self.num = 0
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)
    
    self:bindListener("TargetBKImage", self.onTargetBKImage)
end

function PartySkillBatchDevelopDlg:onTargetBKImage(sender, eventType)
    local dlg = DlgMgr:openDlg("LittleNumInputDlg")
    dlg:setMax(self.skillInfo.level)
    dlg:align(ccui.RelativeAlign.alignParentTopCenterHorizontal)
    local x, y = dlg.root:getPosition()
    dlg.root:setPosition(x, y + 10)
end

function PartySkillBatchDevelopDlg:getCostPoint(skillInfo, upLevel, skillType)
    if upLevel == 0 then return 0 end
    local point = skillInfo.levelupScore - skillInfo.currentScore
    local skillLevelMax = PartyMgr:getPartyLevelMax()
    local function getCost(level)
        if DistMgr:curIsTestDist() then
            if level <= skillLevelMax then
                return 53 * level + 133
            else
                return 0
            end
        else
            if skillType == CHS[3003276] then
                if level < 180 then
                    return 4 * level * level + 400 * level
                elseif level <= skillLevelMax then
                    return math.floor(0.28 * level * level * level - 45 * level * level + 32000)
                else
                    return 0
                end
            else
                return 4 * level * level + 400 * level
            end
        end
    end
    
    if upLevel > 1 then
        for i = 1, upLevel - 1 do
            point = getCost(skillInfo.level + i) + point
        end
    end
    
    return point
end 

function PartySkillBatchDevelopDlg:setDlgInfo(skillInfo, skillType)
    self.skillInfo = skillInfo
    self.skillType = skillType
    self:setLabelText("NameLabel", skillInfo.name)
    self:setLabelText("LevelLabel", skillInfo.level .. CHS[3003277])
    local skillIconPath = SkillMgr:getSkillIconPath(skillInfo.no) or ""
    self:setImage("Image", skillIconPath)
    self:setItemImageSize("Image")
    
    --[[
    local point = 0
    self:setLabelText("CostMoneyLabel_2", point)
    self:setLabelText("CostContructionLabel_2", point * 74)
    --]]
end

function PartySkillBatchDevelopDlg:setCost(num)
    local point = self:getCostPoint(self.skillInfo, num, self.skillType)
    
    local contentStr = gf:getMoneyDesc(point * 74, true) 
    self:setLabelText("CostMoneyLabel_2", contentStr)
    contentStr = gf:getMoneyDesc(point, true) 
    self:setLabelText("CostConstructionLabel_2", contentStr)
    self:setCtrlVisible("DefaultLabel", false)
end

function PartySkillBatchDevelopDlg:setDestLevel(num)
    self.num = num
    self:setInputText("TextField", num)
    self:setCost(num)
end

function PartySkillBatchDevelopDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

function PartySkillBatchDevelopDlg:onConfrimButton(sender, eventType)
    if self.num ~= 0 then
        PartyMgr:studyPartySkill(-self.num, self.skillInfo.no)
    end
    self:onCloseButton()
end

function PartySkillBatchDevelopDlg:close(now)
    DlgMgr:closeDlg("LittleNumInputDlg")
    Dialog.close(self)
end


return PartySkillBatchDevelopDlg
