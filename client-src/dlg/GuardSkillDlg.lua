-- GuardSkillDlg.lua
-- Created by liuhb Apr/30/2015
-- 守护技能界面

local GuardSkillDlg = Singleton("GuardSkillDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local CHECKBOXS = {
    "AttackCheckBox",
    "SupplyCheckBox",
}

function GuardSkillDlg:init()

    -- 单选CheckBox
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, CHECKBOXS, self.onCheckBoxClick)

    -- 单条技能panel
    self.singelSkillPanel = self:getControl("SkillPanel_1")
    self.singelSkillPanel:retain()
    self.singelSkillPanel:removeFromParent()

    -- 选中效果
    self.selectEff = self:getControl("ChosenBackImage", nil, self.singelSkillPanel)
    self.selectEff:retain()
    self.selectEff:removeFromParent()
    self.selectEff:setVisible(true)
    local skillPanel = self:getControl("SkillPanel")
    for i = 5, 1, -1 do
        local panel = self.singelSkillPanel:clone()
        panel:setTag( 5 - i + 1)

        panel:setPosition(1, (i - 1) * panel:getContentSize().height + 2)
        skillPanel:addChild(panel)
        self:setCtrlVisible("BackImage_1", (i % 2 == 1), panel)
        self:setCtrlVisible("BackImage_2", (i % 2 == 0), panel)
        panel.tip = ""
        panel.name = ""
        self:bindTouchEndEventListener(panel, self.onClickPanel)
        
       -- if i == 1 then panel:setVisible(false) end
    end
end

function GuardSkillDlg:cleanup()
    self:releaseCloneCtrl("singelSkillPanel")
    self:releaseCloneCtrl("selectEff")
end

function GuardSkillDlg:onClickPanel(sender)
    self:addSelectEff(sender)
    if sender.tip and sender.tip ~= "" then
        gf:ShowSmallTips(sender.tip)
    end

    if sender.name and sender.name ~= "" then
        self:setLabelText("SkillDescLabel", SkillMgr:getSkillDesc(sender.name).tips)
    else
        self:setLabelText("SkillDescLabel", "")
    end

end

function GuardSkillDlg:addSelectEff(sender)
    self.selectEff:removeFromParent()
    sender:addChild(self.selectEff)
end

function GuardSkillDlg:onCheckBoxClick(sender, curIdx)
    if curIdx == 1 then
        self:setAttackSkill(self.selectGuard)
    else
        self:setAssistSkill(self.selectGuard)
    end

    local panel = self:getControl("SkillPanel"):getChildByTag(1)
    self:onClickPanel(panel)
end

function GuardSkillDlg:setSkill(guard)
    self.selectGuard = guard
    if not self.selectGuard then return end
    local checkBoxCtrl = self:getControl("AttackCheckBox")
    checkBoxCtrl:setSelectedState(true)
    self:onCheckBoxClick(checkBoxCtrl, 1)
end

function GuardSkillDlg:setAttackSkill(guard)
    if nil == guard then return end

    -- 获取守护的相性技能B类
    local polar = guard:queryBasicInt("polar")
    local skillsB = {}
    local guardSkills = {}
    -- 如果相性为 火、土则只有"力破千钧"一个技能
    if polar == POLAR.EARTH or polar == POLAR.FIRE then
        local skill = SkillMgr:getskillAttribByName(CHS[5000028]) -- 力破千钧
        table.insert(skillsB, {no = skill.skill_no, ladder = skill.skill_ladder, name = skill.name})
        local hasSkill = SkillMgr:getSkill(guard:queryBasicInt("id"), skill.skill_no)
        if nil ~= hasSkill then
            table.insert(guardSkills, {no = hasSkill.skill_no, ladder = hasSkill.ladder})
        end
    else
        skillsB = SkillMgr:getSkillsByPolarAndSubclass(polar, SKILL.SUBCLASS_B)
        guardSkills = SkillMgr:getSkillNoAndLadder(guard:queryBasicInt("id"), SKILL.SUBCLASS_B)
    end

    if nil == skillsB then return end

    -- 获取守护已经拥有的技能
    local guardSkillsCount = 0
    if nil ~= guardSkills then
        guardSkillsCount = #guardSkills
    end

    local skillPanel = self:getControl("SkillPanel")
    for i = 1,5 do
        local panel = skillPanel:getChildByTag(i)
        self:setSingelSkillInfo(skillsB[i], panel, guard)
    end
end

function GuardSkillDlg:setSingelSkillInfo(skillInfo, panel, guard)
    panel.tip = ""
    panel.name = ""

    if not skillInfo then
        self:setLabelText("NameLabel", "", panel)
        self:setLabelText("TypeLabel", "", panel)
        self:setLabelText("LevelLabel", "", panel)
        self:setLabelText("TargetLabel", "", panel)
        self:setCtrlVisible("Image", false, panel)
        local iconPanel = self:getControl("IconPanel", nil, panel)
        iconPanel:setBackGroundImage(ResMgr.ui.bag_can_not_use_item_img, ccui.TextureResType.plistType)
        return
    end
    local iconPanel = self:getControl("IconPanel", nil, panel)
    iconPanel:setBackGroundImage(ResMgr.ui.bag_item_bg_img, ccui.TextureResType.plistType)
    -- 图片
    self:setCtrlVisible("Image", true, panel)
    local skillIconPath = SkillMgr:getSkillIconPath(skillInfo.no)
    self:setImage("Image", skillIconPath, panel)
    self:setItemImageSize("Image", panel)

    -- 名称
    self:setLabelText("NameLabel", skillInfo.name, panel)
    panel.name = skillInfo.name

    -- 类型
    local skillType = self:getSkillType(skillInfo.name)
    self:setLabelText("TypeLabel", skillType, panel)

    -- 等级 目标
    local skillWithPet = SkillMgr:getSkill(guard:queryBasicInt("id"), skillInfo.no)
    if not skillWithPet then
        local openLevelTab = SkillMgr:getGuardSkillOpenLevel()
        local polar = guard:queryBasicInt("polar")
        if not openLevelTab[polar] or not openLevelTab[polar][skillInfo.name] then
            self:setLabelText("LevelLabel", "", panel)
            self:setLabelText("TargetLabel", "", panel)
            return
        end

        if openLevelTab[polar][skillInfo.name].openLevel == -1 then
            self:setLabelText("LevelLabel", CHS[3002805], panel)
            panel.tip = CHS[3002806]
        elseif openLevelTab[polar][skillInfo.name].openLevel > guard:queryBasicInt("level") then
            self:setLabelText("LevelLabel", openLevelTab[polar][skillInfo.name].openLevel .. CHS[3002807], panel)
            panel.tip = CHS[3002808] .. openLevelTab[polar][skillInfo.name].openLevel .. CHS[3002809]
        else
            self:setLabelText("LevelLabel", "", panel)
        end

        if openLevelTab[polar][skillInfo.name].maxRange == 1 then
            self:setLabelText("TargetLabel", openLevelTab[polar][skillInfo.name].maxRange, panel)
        else
            self:setLabelText("TargetLabel", openLevelTab[polar][skillInfo.name].minRange ..  CHS[3002810] .. openLevelTab[polar][skillInfo.name].maxRange, panel)
        end

        self:setCtrlEnabled("Image", false, panel)
    else
        self:setLabelText("LevelLabel", skillWithPet.skill_level, panel)
        self:setLabelText("TargetLabel", skillWithPet.range, panel)
        self:setCtrlEnabled("Image", true, panel)
    end

end

function GuardSkillDlg:getSkillType(skillName)
    if skillName == CHS[3002811] then return CHS[3002812] end

    local skillTypeStr = SkillMgr:getSkillDesc(skillName).type
    local pos = gf:findStrByByte(skillTypeStr, CHS[3002813])
    if not pos then return end
    return string.sub(skillTypeStr, 0, pos + 2)  or ""
end

function GuardSkillDlg:setAssistSkill(guard)
    if nil == guard then return end

    -- 获取守护的辅助技能
    local skillsD = SkillMgr:getSkillsByPolarAndSubclass(guard:queryBasicInt("polar"), SKILL.SUBCLASS_D)
    if nil == skillsD then return end

    -- 获取守护已经拥有的技能
    local guardSkills = SkillMgr:getSkillNoAndLadder(guard:queryBasicInt("id"), SKILL.SUBCLASS_D)
    local guardSkillsCount = 0
    if nil ~= guardSkills then
        guardSkillsCount = #guardSkills
    end
    local skillPanel = self:getControl("SkillPanel")
    for i = 1,5 do
        local panel = skillPanel:getChildByTag(i)
        self:setSingelSkillInfo(skillsD[i], panel, guard)
    end
end

return GuardSkillDlg
