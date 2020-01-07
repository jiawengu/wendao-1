-- FightChildSkillDlg.lua
-- Created by lixh Apr/01/2019
-- 战斗中娃娃技能选择界面

local Bitset = require('core/Bitset')
local FightChildSkillDlg = Singleton("FightChildSkillDlg", Dialog)

local SKILL_LIST_PANEL_HEIGHT = 82
local MARGIN_ITEM = 6

function FightChildSkillDlg:init()
    self:setFullScreen()
    self:bindListener("ReturnButton", self.onReturnButton)
    self.skillListPanel = {
        self:getControl("SkillListPanel1", Const.UIPanel),
        self:getControl("SkillListPanel2", Const.UIPanel),
        self:getControl("SkillListPanel3", Const.UIPanel),
        self:getControl("SkillListPanel4", Const.UIPanel),
    }
    self:initSkill()
end

function FightChildSkillDlg:onReturnButton(sender, eventType)
    self:setVisible(false)
    local dlg = DlgMgr:showDlg("FightPetMenuDlg", true)
    if dlg then
        dlg:updateFastSkillButton()
    end
end

-- 选中了某个技能
function FightChildSkillDlg:onSelectSkill(sender, eventType)
    local skillNo = sender:getTag()
    local skillName = SkillMgr:getSkillName(skillNo)
    local kid = HomeChildMgr:getFightKid()

    -- 如果是法宝特殊技能（目前仅包括颠倒乾坤）
    if SkillMgr:isArtifactSpSkill(skillName) then
        if not SkillMgr:isArtifactSpSkillCanUse(skillName) then
            gf:ShowSmallTips(CHS[7000314])
            return
        end
    
        if Me:queryInt("diandqk_frozen_round") >= FightMgr:getCurRound() then
            -- 颠倒乾坤处于冷却中
            gf:ShowSmallTips(CHS[7003002])
            return
        end
    end

    Me.op = ME_OP.FIGHT_SKILL
    Me:setBasic('sel_skill_no', skillNo)

    self:setVisible(false)

    local dlg = DlgMgr:openDlg('FightTargetChoseDlg')
    local cmdDesc = SkillMgr:getSkillCmdDesc(kid:getId(), skillNo)
    dlg:setTips(SkillMgr:getSkillName(skillNo), cmdDesc)
end

-- 设置技能列表
function FightChildSkillDlg:setSkillList(ctrlName, skills, itemPanel)
    -- 获取控件
    local ctrl = self:getControl(ctrlName, "ccui.ListView")
    if not ctrl then
        return 0
    end

    ctrl:removeAllItems()

    if not skills or #skills == 0 then
        -- 没有相应的技能，隐藏控件
        ctrl:setVisible(false)
        return 0
    end

    ctrl:setVisible(true)

    -- 添加技能图标
    local margin = ctrl:getItemsMargin()
    local imgSz = itemPanel:getContentSize()
    local count = #skills
    for i = 1, count do
        local item = itemPanel:clone()
        self:setImage('Image', SkillMgr:getSkillIconPath(skills[i].no), item)
        self:setItemImageSize("Image", item)
        ctrl:addChild(item)
        item:setTouchEnabled(true)

        -- 技能编号是唯一的，故将技能编号作为 tag，以方便之后获取技能编号
        item:setTag(skills[i].no)
    end

    local h = imgSz.height * count + margin * (count - 1)
    ctrl:setContentSize(cc.size(imgSz.width, h))

    return h
end

function FightChildSkillDlg:getKidSkillData()
    local kidId = Me:queryBasicInt('c_attacking_id')

    local function getSkills(type)
        local skills = SkillMgr:getSkillNoAndLadder(kidId, type)
        table.sort(skills, function(l, r)
            if l.ladder < r.ladder then return true end
        end)

        return skills
    end

    -- 辅助技能
    local fuzhuSkills = getSkills(SKILL.SUBCLASS_D)

    -- 障碍技能
    local zhangaiSkills = getSkills(SKILL.SUBCLASS_C)

    -- 法术技能
    local magSkills = getSkills(SKILL.SUBCLASS_B)

    -- 物理技能
    local phySkills = getSkills(SKILL.SUBCLASS_J)
        -- 颠倒乾坤
    local artifact = EquipmentMgr:getEquippedArtifact()
    if artifact then
        local artifactSpSkillName = SkillMgr:getArtifactSpSkillName(artifact.extra_skill)
        if artifactSpSkillName and artifactSpSkillName == CHS[3001942] then
            local skillNo = SkillMgr:getskillAttribByName(CHS[3001942]).skill_no
            table.insert(phySkills, {no = skillNo, ladder = 0, level = artifact.extra_skill_level, name = artifactSpSkillName})
        end
    end

    return {fuzhuSkills, zhangaiSkills, magSkills, phySkills}
end

function FightChildSkillDlg:initSkill()
    local skills = self:getKidSkillData()
    for i = 1, 4 do
        local skillListPanel = self.skillListPanel[i]
        if next(skills[i]) then
            for j = 1, 2 do
                local skillPanel = self:getControl("SkillPanel" .. j, Const.UIPanel, skillListPanel)
                if skills[i][j] then
                    local iconPath = SkillMgr:getSkillIconPath(skills[i][j].no)
                    self:setImage("SkillImage", iconPath, skillPanel)
                    self:setItemImageSize("SkillImage", skillPanel)
                    skillPanel:setVisible(true)
                    if next(skills) and skills[i][j].ladder then
                        local kidId = Me:queryBasicInt('c_attacking_id')
                        local mySkill = SkillMgr:getSkill(kidId, skills[i][j].no)
                        if skills[i][j].ladder ~= 0 then
                            local skillTextPath = ResMgr:getLadderPath(skills[i][j].ladder)
                            local ladderNode = self:getControl("DownImage", Const.UIImage, skillPanel)
                            ladderNode:loadTexture(skillTextPath, ccui.TextureResType.plistType)
                            self:setCtrlVisible("DownImage", true, skillPanel)
                        else
                            local skillTextPath = ResMgr.SkillText[skills[i][j].name]
                            local ladderNode = self:getControl("DownImage", Const.UIImage, skillPanel)
                            ladderNode:loadTexture(skillTextPath, ccui.TextureResType.plistType)
                            self:setCtrlVisible("DownImage", true, skillPanel)
                        end

                        local kid = HomeChildMgr:getFightKid()
                        if mySkill and kid then
                            if mySkill.skill_mana_cost > kid:queryInt("mana")
                                or not SkillMgr:isArtifactSpSkillCanUse(mySkill.skill_name) then
                                -- 普通技能缺少魔法
                                self:setCtrlVisible("NoManaImage", true, skillPanel)
                                skillPanel:setTag(skills[i][j].no)
                                self:blindLongPress("SkillPanel" .. j,
                                    function(dlg, sender, eventType)
                                        self:OneSecondLater(sender, eventType, 2)
                                    end, function(dlg, sender, eventType)
                                        self:onSelectSkill(sender, eventType)
                                    end, skillListPanel)
                            else
                                self:setCtrlVisible("NoManaImage", false, skillPanel)
                                skillPanel:setTag(skills[i][j].no)
                                self:blindLongPress("SkillPanel" .. j,
                                    function(dlg, sender, eventType)
                                        self:OneSecondLater(sender,eventType)
                                    end, function(dlg, sender, eventType)
                                        self:onSelectSkill(sender, eventType)
                                    end, skillListPanel)
                            end

                            -- 设置等级
                            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, mySkill.skill_level, false, LOCATE_POSITION.LEFT_TOP, 19, skillPanel)
                        end
                    else
                        self:setCtrlVisible("DownImage", false, skillPanel)
                    end
                else
                    skillPanel:setVisible(false)
                    self:setCtrlVisible("DownImage", false, skillPanel)
                end
            end
        else
            local backImage = self:getControl("BackImage", Const.UIImage)
            local imageSize = backImage:getContentSize()
            imageSize.height = imageSize.height - SKILL_LIST_PANEL_HEIGHT
            backImage:setContentSize(imageSize)

            local mainPanel = self:getControl("MainPanel", Const.UIPanel)
            local size = mainPanel:getContentSize()
            size.height = imageSize.height
            mainPanel:setContentSize(size)
            self:updateLayout("MainPanel")
        end
    end
end

function FightChildSkillDlg:OneSecondLater(sender, eventType, type)
    local skillNo = sender:getTag()
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local kid = HomeChildMgr:getFightKid()
    SkillMgr:showSkillDescDlg(SkillMgr:getSkillName(skillNo), kid:getId(), true, rect, type)
end

return FightChildSkillDlg
