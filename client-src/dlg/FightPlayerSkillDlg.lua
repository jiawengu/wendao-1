-- FightPlayerSkillDlg.lua
-- Created by cheny Dec/2/2014
-- 战斗中 me 技能选择界面

local Bitset = require('core/Bitset')
local FightPlayerSkillDlg = Singleton("FightPlayerSkillDlg", Dialog)

local DEFENCE_NO = 9167
local PHYATTACT_NO = 9166

local SKILL_TYPE_LIST = {"DType", "CType", "BType", "PhyType"}
local SKILL_SUBCLASS = {SKILL.SUBCLASS_D, SKILL.SUBCLASS_C, SKILL.SUBCLASS_B, SKILL.SUBCLASS_J}
local SKILL_LIST_PANEL_HEIGHT = 74 + 8

function FightPlayerSkillDlg:init()
    self:setFullScreen()
    self:bindListener("ReturnButton", self.onReturnButton)
    self.listView = self:getControl("MainListView", Const.UIListView, "MainPanel")
    self.qinMiWuJianListView = self:getControl("MainListView", Const.UIListView, "QinmiwujianPanel")

    self.skillListPanel = {
        self:getControl("SkillListPanel1", Const.UIPanel, "MainPanel"),
        self:getControl("SkillListPanel2", Const.UIPanel, "MainPanel"),
        self:getControl("SkillListPanel3", Const.UIPanel, "MainPanel"),
        self:getControl("SkillListPanel4", Const.UIPanel, "MainPanel"),
                            }

    self.qinMiWuJianListPanel = {
        self:getControl("SkillListPanel1", Const.UIPanel, "QinmiwujianPanel"),
        self:getControl("SkillListPanel2", Const.UIPanel, "QinmiwujianPanel"),
    }

    for k,v in pairs(self.skillListPanel) do
        v:retain()
        v:removeFromParent()
    end

    for k,v in pairs(self.qinMiWuJianListPanel) do
        v:retain()
        v:removeFromParent()
    end

    self:initSkill()
    self.curNo = nil
end

function FightPlayerSkillDlg:resetCtrl()
    self.listView:removeAllItems()
    local backImage = self:getControl("BackImage", Const.UIImage)
    local size = backImage:getContentSize()
    size.height = 430
    backImage:setContentSize(size)
end

function FightPlayerSkillDlg:resetQinMiWuJianCtrl()
    self.qinMiWuJianListView:removeAllItems()
    local backImage = self:getControl("BackImage", Const.UIImage, "QinmiwujianPanel")
    local size = backImage:getContentSize()
    size.height = 248
    backImage:setContentSize(size)

    local qinmiwujianPanel = self:getControl("QinmiwujianPanel", Const.UIPanel)
    local qinmiwujianPanelSize = qinmiwujianPanel:getContentSize()
    qinmiwujianPanelSize.height =size.height
    qinmiwujianPanel:setContentSize(size)
    self:updateLayout("QinmiwujianPanel")
end

function FightPlayerSkillDlg:initSkillBattleSimulator()
    local panel = self:getControl("ListPanel")
    self.listView:setVisible(false)
    panel:setVisible(true)
    panel:removeAllChildren()
    local addCount = 1
    for i = 1, #SKILL_TYPE_LIST do
        local skills = self:getMeActionData(SKILL_TYPE_LIST[i])

        if BattleSimulatorMgr:isRunning() then
            skills.skills = BattleSimulatorMgr:getSkillList(SKILL_SUBCLASS[i])
        end

        local width = self.skillListPanel[1]:getContentSize().width
        panel:setContentSize(width, panel:getContentSize().height)
        local mainPanel = self:getControl("MainPanel")
        mainPanel:setContentSize(width, mainPanel:getContentSize().height)
        local bkImage = self:getControl("BackImage")
        bkImage:setContentSize(width, bkImage:getContentSize().height)
        panel:requestDoLayout()

        if next(skills) and skills.skills and next(skills.skills) then
            local skillListPanel = self.skillListPanel[i]
            local count = 5

            for j = 1, count do
                local skillPanel = self:getControl("SkillPanel" .. j, Const.UIPanel, skillListPanel)
                skillPanel:setTag(0)
                if skills.skills[j] then
                    local iconPath = SkillMgr:getSkillIconPath(skills.skills[j].no)
                    self:setImage("SkillImage", iconPath, skillPanel)
                    self:setItemImageSize("SkillImage", skillPanel)
                    skillPanel:setVisible(true)
                    if skills.skills[j].ladder then
                        local mySkill = SkillMgr:getSkill(Me:getId(), skills.skills[j].no)
                        if skills.skills[j].ladder ~= 0 then
                            local skillTextPath = ResMgr:getLadderPath(skills.skills[j].ladder)

                            local ladderNode = self:getControl("DownImage", Const.UIImage, skillPanel)
                            ladderNode:loadTexture(skillTextPath, ccui.TextureResType.plistType)
                            self:setCtrlVisible("DownImage", true, skillPanel)
                        else
                            local skillTextPath = ResMgr.SkillText[skills.skills[j].name]
                            local ladderNode = self:getControl("DownImage", Const.UIImage, skillPanel)
                            ladderNode:loadTexture(skillTextPath, ccui.TextureResType.plistType)
                            self:setCtrlVisible("DownImage", true, skillPanel)
                        end
                        skillPanel:setTag(skills.skills[j].no)
                        if mySkill then
                            if mySkill.skill_mana_cost > Me:queryInt("mana") then
                                self:setCtrlVisible("NoManaImage", true, skillPanel)
                                self:blindLongPress("SkillPanel" .. j,
                                    function(dlg, sender, eventType)
                                        self:OneSecondLater(sender, eventType, 2)
                                    end, function(dlg, sender, eventType)
                                        self:onSelectSkill(sender, eventType)
                                    end, skillListPanel)
                            else
                                self:setCtrlVisible("NoManaImage", false, skillPanel)
                                skillPanel:setTag(skills.skills[j].no)
                                self:blindLongPress("SkillPanel" .. j,
                                    function(dlg, sender, eventType)
                                        self:OneSecondLater(sender,eventType)
                                    end, function(dlg, sender, eventType)
                                        self:onSelectSkill(sender, eventType)
                                    end, skillListPanel)
                            end

                            -- 设置等级
                            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, mySkill.skill_level, false, LOCATE_POSITION.LEFT_TOP, 19, skillPanel)
                        elseif skills.skills[j].name == CHS[3002611] or skills.skills[j].name == CHS[3002612] then
                            self:setCtrlVisible("NomanaImage", false, skillPanel)
                            skillPanel:setTag(skills.skills[j].no)
                            self:blindLongPress("SkillPanel" .. j,
                                function(dlg, sender, eventType)
                                    self:OneSecondLater(sender,eventType)
                                end, function(dlg, sender, eventType)
                                    self:onSelectSkill(sender, eventType)
                                end, skillListPanel)
                        else
                            self:setCtrlVisible("NomanaImage", false, skillPanel)
                            skillPanel:setTag(skills.skills[j].no)
                            self:blindLongPress("SkillPanel" .. j,
                                function(dlg, sender, eventType)
                                    self:OneSecondLater(sender,eventType)
                                end, function(dlg, sender, eventType)
                                    self:onSelectSkill(sender, eventType)
                                end, skillListPanel)
                        end

                    else
                        self:setCtrlVisible("DownImage", false, skillPanel)
                    end
                else
                    skillPanel:setVisible(false)
                    self:setCtrlVisible("DownImage", false, skillPanel)
                end
            end
            local tempPanel = skillListPanel:clone()
            skillListPanel:setPositionY(panel:getContentSize().height - (addCount * skillListPanel:getContentSize().height) - (addCount) * 17)
            addCount = addCount + 1
            self.listView:pushBackCustomItem(tempPanel)
            panel:addChild(skillListPanel)
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


function FightPlayerSkillDlg:initSkill()
    self:resetCtrl()
    self:setCtrlVisible("QinmiwujianPanel", false)

    if BattleSimulatorMgr:isRunning() then
        self:initSkillBattleSimulator()
        return
    end

    for i = 1, #SKILL_TYPE_LIST do
        local skills = self:getMeActionData(SKILL_TYPE_LIST[i])

        if BattleSimulatorMgr:isRunning() then
            skills.skills = BattleSimulatorMgr:getSkillList(SKILL_SUBCLASS[i])
        end

        if next(skills) and skills.skills and next(skills.skills) then
            local skillListPanel = self.skillListPanel[i]
            local count = 4

            local isSpecialFight = FightMgr:getCombatMode() == COMBAT_MODE.COMBAT_MODE_TONGTIANTADING and GameMgr.inCombat

            if SkillMgr:isleardedFiveLadderSkill(SKILL.LADDER_5) or isSpecialFight then
                count = 5
                local width = skillListPanel:getContentSize().width
                self.listView:setContentSize(width, self.listView:getContentSize().height)
                local mainPanel = self:getControl("MainPanel")
                mainPanel:setContentSize(width, mainPanel:getContentSize().height)
                local bkImage = self:getControl("BackImage")
                bkImage:setContentSize(width, bkImage:getContentSize().height)
            end

            for j = 1, count do
                local skillPanel = self:getControl("SkillPanel" .. j, Const.UIPanel, skillListPanel)
                skillPanel:setTag(0)
                if skills.skills[j] then
                    local iconPath = SkillMgr:getSkillIconPath(skills.skills[j].no)
                    self:setImage("SkillImage", iconPath, skillPanel)
                    self:setItemImageSize("SkillImage", skillPanel)
                    skillPanel:setVisible(true)
                    if skills.skills[j].ladder then
                        local mySkill = SkillMgr:getSkill(Me:getId(), skills.skills[j].no)
                        if skills.skills[j].ladder ~= 0 then
                            local skillTextPath = ResMgr:getLadderPath(skills.skills[j].ladder)

                            local ladderNode = self:getControl("DownImage", Const.UIImage, skillPanel)
                            ladderNode:loadTexture(skillTextPath, ccui.TextureResType.plistType)
                            self:setCtrlVisible("DownImage", true, skillPanel)
                        else
                            local skillTextPath = ResMgr.SkillText[skills.skills[j].name]
                            local ladderNode = self:getControl("DownImage", Const.UIImage, skillPanel)
                            ladderNode:loadTexture(skillTextPath, ccui.TextureResType.plistType)
                            self:setCtrlVisible("DownImage", true, skillPanel)
                        end
                        skillPanel:setTag(skills.skills[j].no)

                        if mySkill then
                            if mySkill.skill_mana_cost > Me:queryInt("mana")
                                    or not SkillMgr:isArtifactSpSkillCanUse(mySkill.skill_name) then
                                self:setCtrlVisible("NoManaImage", true, skillPanel)
                                self:blindLongPress("SkillPanel" .. j,
                                    function(dlg, sender, eventType)
                                        self:OneSecondLater(sender, eventType, 2)
                                    end, function(dlg, sender, eventType)
                                        self:onSelectSkill(sender, eventType)
                                    end, skillListPanel)
                            else
                                self:setCtrlVisible("NoManaImage", false, skillPanel)
                                skillPanel:setTag(skills.skills[j].no)
                                self:blindLongPress("SkillPanel" .. j,
                                    function(dlg, sender, eventType)
                                        self:OneSecondLater(sender,eventType)
                                    end, function(dlg, sender, eventType)
                                        self:onSelectSkill(sender, eventType)
                                        if j == 1 then
                                            GuideMgr:needCallBack("B1")
                                        end
                                    end, skillListPanel)
                            end

                            -- 设置等级
                            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, mySkill.skill_level, false, LOCATE_POSITION.LEFT_TOP, 19, skillPanel)

                            -- 如果是法宝特殊技能，要加上法宝特殊技能标识
                            if SkillMgr:isArtifactSpSkill(mySkill.skill_name) then
                                SkillMgr:addArtifactSpSkillImage(self:getControl("SkillImage", nil, skillPanel))
                            end
                        elseif skills.skills[j].name == CHS[3002611] or skills.skills[j].name == CHS[3002612] then
                            self:setCtrlVisible("NomanaImage", false, skillPanel)
                            skillPanel:setTag(skills.skills[j].no)
                            self:blindLongPress("SkillPanel" .. j,
                                function(dlg, sender, eventType)
                                    self:OneSecondLater(sender,eventType)
                                end, function(dlg, sender, eventType)
                                    self:onSelectSkill(sender, eventType)
                                end, skillListPanel)
                        else
                            self:setCtrlVisible("NomanaImage", false, skillPanel)
                            skillPanel:setTag(skills.skills[j].no)
                            self:blindLongPress("SkillPanel" .. j,
                                function(dlg, sender, eventType)
                                    self:OneSecondLater(sender,eventType)
                                end, function(dlg, sender, eventType)
                                    self:onSelectSkill(sender, eventType)
                                end, skillListPanel)
                        end

                    else
                        self:setCtrlVisible("DownImage", false, skillPanel)
                    end
                else
                    skillPanel:setVisible(false)
                    self:setCtrlVisible("DownImage", false, skillPanel)
                end
            end
            self.listView:pushBackCustomItem(skillListPanel)
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

-- 亲密无间复制的宠物技能
function FightPlayerSkillDlg:initQinMiWuJianSkill()
    self:resetQinMiWuJianCtrl()

    for i = 1, 2 do
        local skills = self:getPetSkillData()
        local skillListPanel = self.qinMiWuJianListPanel[i]
        if next(skills[i]) then
            for j = 1, 5 do
                local skillPanel = self:getControl("SkillPanel" .. j, Const.UIPanel, skillListPanel)
                if skills[i][j] then
                    local iconPath = SkillMgr:getSkillIconPath(skills[i][j].no)
                    self:setImage("SkillImage", iconPath, skillPanel)
                    self:setItemImageSize("SkillImage", skillPanel)
                    skillPanel:setVisible(true)
                    if next(skills) and skills[i][j].ladder then
                        local mySkill = SkillMgr:getSkill(Me:getId(), skills[i][j].no)
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

                        if mySkill then
                            if mySkill.skill_mana_cost > Me:queryInt("mana")
                                  or not SkillMgr:isArtifactSpSkillCanUse(CHS[3001947]) then
                                -- 自身法力或者法宝灵气不足，则无法使用亲密无间复制的技能
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

                            -- 如果是顿悟技能，要加上顿悟标记
                            local pet = PetMgr:getFightPet()
                            if pet and SkillMgr:isPetDunWuSkill(pet:getId(), skills[i][j].name) then
                                SkillMgr:addDunWuSkillImage(self:getControl("SkillImage", nil, skillPanel))
                            end
                        end
                    else
                        self:setCtrlVisible("DownImage", false, skillPanel)
                    end
                else
                    skillPanel:setVisible(false)
                    self:setCtrlVisible("DownImage", false, skillPanel)
                end
            end
            self.qinMiWuJianListView:pushBackCustomItem(self.qinMiWuJianListPanel[i])
        else
            local backImage = self:getControl("BackImage", Const.UIImage, "QinmiwujianPanel")
            local imageSize = backImage:getContentSize()
            imageSize.height = imageSize.height - SKILL_LIST_PANEL_HEIGHT
            backImage:setContentSize(imageSize)

            local mainPanel = self:getControl("QinmiwujianPanel", Const.UIPanel)
            local size = mainPanel:getContentSize()
            size.height = imageSize.height
            mainPanel:setContentSize(size)
            self:updateLayout("QinmiwujianPanel")
        end
    end
end

-- 获取亲密无间复制的宠物技能
function FightPlayerSkillDlg:getPetSkillData()
    local studySkills = SkillMgr:getQinMiWuJianStudySkills()

    local rawSkills = SkillMgr:getQinMiWuJianRawSkills(PetMgr:getFightPet())

    local retValue = {studySkills, rawSkills}
    return retValue
end

function FightPlayerSkillDlg:onReturnButton(sender, eventType)
    self:setVisible(false)
    self:setCtrlVisible("QinmiwujianPanel", false)

    local dlg = DlgMgr:showDlg("FightPlayerMenuDlg", true)
    if dlg then
        dlg:updateFastSkillButton()
    end
end

function FightPlayerSkillDlg:getMeActionData(name)
    local actionData = {}
    local skill = {}
    local attackId =  Me:getId()

    -- 通天塔塔顶战斗，需要显示特定技能
    if FightMgr:getCombatMode() == COMBAT_MODE.COMBAT_MODE_TONGTIANTADING and GameMgr.inCombat then
        if name == "PhyType" or name == "CType" or name == "DType" then
        elseif name == "BType" then
            skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_B)

            for i = #skill, 1, -1 do
                if skill[i].no < 1001 or skill[i].no > 1005 then
                    table.remove( skill, i )
                end
            end

            table.sort(skill, function(l, r)
                if l.no < r.no then return true end
                if l.no > r.no then return false end
            end)

            if #skill > 0 then
                actionData["name"] = "BTypeSkillPanel"
                actionData["skills"] = skill
            end
        end
        return actionData
    end



    if name == "PhyType" then
        --[[
        -- 物理攻击
        local phyAttact = {}
        phyAttact["no"] = PHYATTACT_NO
        phyAttact["icon"] = PHYATTACT_NO
        phyAttact["name"] = CHS[3002611]
        phyAttact["ladder"] = 0
        table.insert(skill, phyAttact)

        -- 防御
        local defence = {}
        defence["no"] = DEFENCE_NO
        defence["icon"] = DEFENCE_NO
        defence["name"] = CHS[3002612]
        defence["ladder"] = 0
        table.insert(skill, defence)
        --]]

        -- 力破千钧
        local phySkill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_J)
        if phySkill then
            table.insert(skill, phySkill[1])
        end

        -- 法宝特殊技能
        if not BattleSimulatorMgr:isRunning() then
            local artifactSpSkill = SkillMgr:getArtifactSpSkillInfo()
            for i = 1, #artifactSpSkill do
                table.insert(skill, artifactSpSkill[i])
            end
        end

        actionData["name"] = "PhySkillPanel"
        actionData["skills"] = skill
    elseif name == "BType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_B)

        if #skill > 0 then
            actionData["name"] = "BTypeSkillPanel"
            actionData["skills"] = skill
        end
    elseif name == "CType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_C)

        if #skill > 0 then
            actionData["name"] = "CTypeSkillPanel"
            actionData["skills"] = skill
        end
    elseif name == "DType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_D)

        if #skill > 0 then
            actionData["name"] = "DTypeSkillPanel"
            actionData["skills"] = skill
        end
    end

    if BattleSimulatorMgr:isRunning() then
        return actionData
    end

    -- 特殊处理：“人物身上由亲密无间获得的技能”不算作人物技能
    local result = {}
    if actionData["skills"] then
        local skills = {}
        for i = 1, #actionData["skills"] do
            local skillInfo = actionData["skills"][i]
            local skillName = skillInfo.name
            local skill = SkillMgr:getSkill(Me:getId(), skillInfo.no)
            if skill and (not skill.isTempSkill or skill.isTempSkill == 0)
                 or (skillName == CHS[3002286] or skillName == CHS[3002275]) then
                table.insert(skills, skillInfo)
            end
        end

        if #skills > 0 then
            result["name"] = actionData["name"]
            result["skills"] = skills
        end
    end

    return result
end

-- 选中了某个技能
function FightPlayerSkillDlg:onSelectSkill(sender, eventType)
    local skillNo = sender:getTag()
    local skillName = SkillMgr:getSkillName(skillNo)

    -- 选中了法宝特殊技能
    if SkillMgr:isArtifactSpSkill(skillName) then
        local nimbus = EquipmentMgr:getEquippedArtifactNimbus()
        if nimbus < SkillMgr:getArtifactSpSkillCostNimbus(skillName) then
            -- 法宝灵气是否充足
            gf:ShowSmallTips(CHS[7000314])
            return
        end

        if skillName == CHS[3001944] or skillName == CHS[3001945] then
            -- 物极必反/天眼
            gf:ShowSmallTips(CHS[7000313])
            return
        elseif skillName == CHS[3001947] then
            -- 亲密无间
            local fightPet = PetMgr:getFightPet()
            if fightPet and FightMgr:getObjectById(fightPet:getId()) then
                -- 获取亲密无间复制的宠物天生/研发技能
                -- 如果人物技能与宠物的某个天生/研发技能相同，那么此技能不能被亲密无间复制
                local skills = self:getPetSkillData()
                local skillNum = 0
                for i = 1, #skills do
                    if skills[i] then
                        skillNum = skillNum + #skills[i]
                    end
                end

                if skillNum == 0 then
                    gf:ShowSmallTips(CHS[7001010])
                else
                    self:setCtrlVisible("QinmiwujianPanel", true)
                    self:initQinMiWuJianSkill()
                end
            else
                gf:ShowSmallTips(CHS[7000315])
            end
            return
        end
    end

    -- 选中的是亲密无间复制的宠物技能
    if SkillMgr:isQinMiWuJianCopySkill(skillName, skillNo) then
        local pet = PetMgr:getFightPet()
        if EquipmentMgr:getEquippedArtifactNimbus() < SkillMgr:getArtifactSpSkillCostNimbus(CHS[3001947]) then
            -- 法宝灵气不足
            gf:ShowSmallTips(CHS[7000314])
            self:setCtrlVisible("QinmiwujianPanel", false)
            return
        elseif (not pet) or (not SkillMgr:getSkill(pet:getId(),skillNo)) then
            -- 当前出战宠物已经发生了变化
            gf:ShowSmallTips(CHS[7000316])
            self:setCtrlVisible("QinmiwujianPanel", false)
            return
        end
    end

    if skillName == CHS[3002613] then
        Me.op = ME_OP.FIGHT_ATTACK
    elseif skillName == CHS[3002612] then
        gf:sendFightCmd(Me:getId(), Me:getId(), FIGHT_ACTION.DEFENSE, 0)
        FightMgr:changeMeActionFinished()
        return
    else
        Me.op = ME_OP.FIGHT_SKILL
    end

    -- 选中只能对人物自身释放的技能(法力护盾、移花接木)
    if SkillMgr:canUseSkillOnlyToSelf(skillNo, "me") then
        local curRoundLeftTime = FightMgr:getRoundLeftTime()
        self.confirmDlg = gf:confirm(string.format(CHS[7150019], skillName), function()
            -- 玩家确认后直接选择角色自身
            Me:setBasic('sel_skill_no', skillNo)
            self:setVisible(false)
            self:setCtrlVisible("QinmiwujianPanel", false)

            FightMgr:getObjectById(Me:getId()):onSelectChar()
        end, function()
            if self.confirmDlg and self.confirmDlg.hourglassTime < 1 then
                -- 倒计时确认框自动取消时，不需要重新显示技能选择界面
                self:setVisible(false)
                self:setCtrlVisible("QinmiwujianPanel", false)
                return
            end

            Me.op = ME_OP.FIGHT_ATTACK
            Me:setBasic('sel_skill_no', 0)
            self:setVisible(true)
            self:setCtrlVisible("QinmiwujianPanel", true)
        end, nil, curRoundLeftTime - 1)

        if self.confirmDlg then
            self.confirmDlg:setCombatOpenType()
        end

        return
    end

    Me:setBasic('sel_skill_no', skillNo)

    self:setVisible(false)
    self:setCtrlVisible("QinmiwujianPanel", false)

    local dlg = DlgMgr:openDlg('FightTargetChoseDlg')
    local cmdDesc = SkillMgr:getSkillCmdDesc(Me:getId(), skillNo)

    -- 如果是模拟战斗，则从模拟战斗管理器中取
    if BattleSimulatorMgr:isRunning() then
        cmdDesc = BattleSimulatorMgr:getSkillCmdDesc(skillNo)
    end

    dlg:setTips(SkillMgr:getSkillName(skillNo), cmdDesc)
end

-- 设置技能列表
function FightPlayerSkillDlg:setSkillList(ctrlName, subclass, itemPanel)
    -- 获取控件
    local ctrl = self:getControl(ctrlName, "ccui.ListView")
    if not ctrl then
        return 0
    end

    -- 根据 subclass 查找技能
    local skills = SkillMgr:getSkillNoAndLadder(Me:queryBasicInt('c_attacking_id'), subclass)

    -- 此处，只有模拟战斗的时候有用
    -- 别的时候请无视
    if BattleSimulatorMgr:isRunning() then
        skills = BattleSimulatorMgr:getSkillList(subclass)
    end

    if not skills or #skills == 0 then
        -- 没有相应的技能，隐藏控件
        ctrl:setVisible(false)
        return 0
    end

    ctrl:setVisible(true)
    ctrl:removeAllItems()

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

function FightPlayerSkillDlg:OneSecondLater(sender, eventType, type)
    local skillNo = sender:getTag()
    local rect = self:getBoundingBoxInWorldSpace(sender)
    SkillMgr:showSkillDescDlg(SkillMgr:getSkillName(skillNo), Me:getId(), false, rect, type)
end

function FightPlayerSkillDlg:getSelectItemBox(clickItem)
    local polar = Me:queryBasicInt("polar")
    local skillNo = nil
    local ctrl = nil
    local listPanel = self:getControl("MainListView")
    if BattleSimulatorMgr:isRunning() then
        listPanel = self:getControl("ListPanel")
    end

    if "B3" == clickItem then
        -- 获取B3技能
        skillNo = SkillMgr:getSkillNoByPolarAndLadder(polar, SKILL.SUBCLASS_B, SKILL.LADDER_3)
        ctrl = self:getControl("SkillListPanel3", nil, listPanel)
    elseif "B5" == clickItem then
        -- 获取B3技能
        skillNo = SkillMgr:getSkillNoByPolarAndLadder(polar, SKILL.SUBCLASS_B, SKILL.LADDER_5)
        ctrl = self:getControl("SkillListPanel3", nil, listPanel)
    elseif "B4" == clickItem then
        -- 获取B4技能
        skillNo = SkillMgr:getSkillNoByPolarAndLadder(polar, SKILL.SUBCLASS_B, SKILL.LADDER_4)
        ctrl = self:getControl("SkillListPanel3", nil, listPanel)
    elseif "B1" == clickItem then
        -- 获取B1技能
        skillNo = SkillMgr:getSkillNoByPolarAndLadder(polar, SKILL.SUBCLASS_B, SKILL.LADDER_1)
        ctrl = self:getControl("SkillListPanel3", nil, listPanel)
    elseif CHS[3002614] == clickItem then
        -- 获取力破千钧技能
        skillNo = SkillMgr:getskillAttribByName(CHS[3002614]).skill_no
        ctrl = self:getControl("SkillListPanel4", nil, listPanel)
    end

    if not ctrl then return end
    local child = ctrl:getChildByTag(skillNo)
    if nil ~= child then
        local box = self:getBoundingBoxInWorldSpace(child)
        return box
    else
        return nil
    end
end

function FightPlayerSkillDlg:cleanup()
    if self.skillListPanel then
        for k, v in pairs(self.skillListPanel) do
            if v then
                self.skillListPanel[k]:release()
                self.skillListPanel[k] = nil
            end
        end
        self.skillListPanel = nil
    end

    if self.qinMiWuJianListPanel then
        for k, v in pairs(self.qinMiWuJianListPanel) do
            if v then
                self.qinMiWuJianListPanel[k]:release()
                self.qinMiWuJianListPanel[k] = nil
            end
        end
        self.qinMiWuJianListPanel = nil
    end
end

return FightPlayerSkillDlg
