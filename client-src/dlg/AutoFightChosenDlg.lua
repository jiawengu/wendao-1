-- AutoFightChosenDlg.lua
-- Created by zhengjh Apr/7/2015
-- 自动战斗技能选择框

local AutoFightChosenDlg = Singleton("AutoFightChosenDlg", Dialog)
local LINE_SPACE = 10

function AutoFightChosenDlg:init()
    self.cell = self:getControl("OneClassPanel", Const.UIPanel)
    self.cell:retain()
    self.cell:removeFromParent()

    self.selectImagePattern = self:getControl("ChosenEffectImage", Const.UIImage)
    self.selectImagePattern:retain()
    self.selectImagePattern:removeFromParent()

    self:setDlgZOrder(-1)
end


function AutoFightChosenDlg:initSkills(skills)
    local chosenPanel = self:getControl("ChosenPanel")

    if  #skills * (self.cell:getContentSize().height + LINE_SPACE) > chosenPanel:getContentSize().height then
        chosenPanel:setContentSize(chosenPanel:getContentSize().width, #skills * (self.cell:getContentSize().height + LINE_SPACE) )
    end


    for i =1,#skills do
        local cell = self.cell:clone()
        self:setCellInfo(skills[i], cell)
        cell:setAnchorPoint(0, 1)
        cell:setPosition(0, chosenPanel:getContentSize().height - (i - 1) * (cell:getContentSize().height + LINE_SPACE))
        chosenPanel:addChild(cell)
    end
end

function AutoFightChosenDlg:setCellInfo(skill, cell)
   local image = self:getControl("OneClassSkillImage", Const.UIImage, cell)
   local path = SkillMgr:getSkillIconPath(skill.no)
   image:loadTexture(path)
   self:setItemImageSize("OneClassSkillImage", cell)

   local skillName = SkillMgr:getSkillName(skill["no"])
   local classNameLabel = self:getControl("OneClassSkillTypeLabel", Const.UILabel, cell)
   classNameLabel:setString(SkillMgr:getSkillDesc(skillName)["type"])
   local skillNameLabel = self:getControl("OneClassSkillNameLabel", Const.UILabel, cell)
   skillNameLabel:setString(skillName)

    local function panelTouch(sender, enventType)
        if enventType == ccui.TouchEventType.ended then
            self:addSelectImage(sender)
            self.fuc(self.obj, self.fightObject, SkillMgr:getSkillDesc(skillName)["type"], skill["no"])
        end
    end

    cell:addTouchEventListener(panelTouch)
end

function AutoFightChosenDlg:addSelectImage(sender)
    if self.selcetImage  then
        self.selcetImage:removeFromParent()
        self.selcetImage = nil
    end

    self.selcetImage = self.selectImagePattern:clone()
    self.selcetImage:setPosition(sender:getContentSize().width / 2, sender:getContentSize().height / 2)
    self.selcetImage:setAnchorPoint(0.5, 0.5)
    self.selcetImage:setVisible(true)
    sender:addChild(self.selcetImage)
end

function AutoFightChosenDlg:setCallBcak(obj, fuc, fightObject)
    self.fuc = fuc
    self.obj = obj
    self.fightObject = fightObject
end


function AutoFightChosenDlg:cleanup()
    self:releaseCloneCtrl("selectImagePattern")
    self:releaseCloneCtrl("cell")
end

return AutoFightChosenDlg
