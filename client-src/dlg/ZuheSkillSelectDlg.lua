-- AutoFightTalkDlg.lua
-- Created by songcw Dec/21/2017
-- 组合技能选择

local AutoFightTalkDlg = require('dlg/AutoFightTalkDlg')
local ZuheSkillSelectDlg = Singleton("ZuheSkillSelectDlg", AutoFightTalkDlg)

local SKILL_TYPE_LIST = {"DType", "CType", "BType", "PhyType"}
local SKILL_KID_TYPE_LIST = {"DType", "CType", "BType", "PhyType"}
local SKILL_PET_TYPE_LIST = {"PartyType", "InnerType", "BType", "PhyType"}

local meConfig = {name = "me"}
local petConfig = {name = "pet"}
local kidConfig = {name = "kid"}

local SKILL_LIST_PANEL_HEIGHT = 82

local DEFENCE_NO = 9167
local PHYATTACT_NO = 9166

function ZuheSkillSelectDlg:getCfgFileName()
    return ResMgr:getDlgCfg("AutoFightTalkDlg")
end

function ZuheSkillSelectDlg:setTitle(objType)
    if objType == "pet" then
        self:setLabelText("Label", CHS[4100980], "PetSettingPanel") -- "选择宠物组合技能"
    elseif objType == "kid" then
        self:setLabelText("Label", CHS[7120209], "ChildSettingPanel") -- "选择娃娃组合技能"
    else
        self:setLabelText("Label", CHS[4100981], "PlayerSettingPanel") -- 选择角色组合技能
    end
end

function ZuheSkillSelectDlg:getKidActionData(name)
    local actionData = {}
    local skill = {}
    local attackId = HomeChildMgr:getFightKid():getId()

    if name == "PhyType" then
        local phyAttact = {}
        phyAttact["no"] = PHYATTACT_NO
        phyAttact["icon"] = PHYATTACT_NO
        phyAttact["name"] = CHS[3002286]
        phyAttact["ladder"] = 0
        table.insert(skill, phyAttact)

        -- 防御
        local defence = {}
        defence["no"] = DEFENCE_NO
        defence["icon"] = DEFENCE_NO
        defence["name"] = CHS[3002275]
        defence["ladder"] = 0
        table.insert(skill, defence)

        -- 力破千钧
        local phySkill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_J)
        if phySkill then
            table.insert(skill, phySkill[1])
        end

        actionData["skills"] = skill
    elseif name == "BType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_B)

        if #skill > 0 then
            actionData["skills"] = skill
        end
    elseif name == "CType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_C)

        if #skill > 0 then
            actionData["skills"] = skill
        end
    elseif name == "DType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_D)

        if #skill > 0 then
            actionData["skills"] = skill
        end
    end

    return actionData
end

function ZuheSkillSelectDlg:initKidSkill()
    self:resetCtrl("kid")

    for i = 1, #SKILL_KID_TYPE_LIST do
        local skills = self:getKidActionData(SKILL_KID_TYPE_LIST[i])
        local skillListPanel = self.kidSkillListPanel[i]
        if next(skills) then
            skillListPanel:setVisible(true)
            for j = 1, 5 do
                local skillPanel = self:getControl("SkillPanel" .. j, Const.UIPanel, skillListPanel)
                if skills.skills[j] then
                    skillPanel:setVisible(true)

                    self:setImage("SkillImage", SkillMgr:getSkillIconPath(skills.skills[j].no), skillPanel)
                    self:setItemImageSize("SkillImage", skillPanel)

                    if skills.skills[j].ladder then
                        local mySkill = SkillMgr:getSkill(self.curShowKid:getId(), skills.skills[j].no)
                        if skills.skills[j].ladder ~= 0 then
                            self:setImagePlist("DownImage", ResMgr:getLadderPath(skills.skills[j].ladder), skillPanel)
                            self:setCtrlVisible("DownImage", true, skillPanel)
                        else
                            self:setImagePlist("DownImage", ResMgr.SkillText[skills.skills[j].name], skillPanel)
                            self:setCtrlVisible("DownImage", true, skillPanel)
                        end
                        if mySkill then
                            skillPanel:setEnabled(true)
                            gf:resetImageView(self:getControl("SkillImage", nil, skillPanel))

                            self:setCtrlVisible("NoManaImage", false, skillPanel)
                            skillPanel:setTag(skills.skills[j].no)
                            self:blindLongPress("SkillPanel" .. j,
                                function(dlg, sender, eventType)
                                    self:OneSecondLater(sender, eventType, nil, skills.skills[j].no, kidConfig)
                                end, function(dlg, sender, eventType)
                                    self:onSelectSkill(sender, eventType, skills.skills[j].no, kidConfig)
                                end, skillListPanel)
                        elseif skills.skills[j].name == CHS[3002286] or skills.skills[j].name == CHS[3002275] then
                            self:setCtrlVisible("NomanaImage", false, skillPanel)
                            skillPanel:setTag(skills.skills[j].no)
                            self:blindLongPress("SkillPanel" .. j,
                                function(dlg, sender, eventType)
                                    self:OneSecondLater(sender, eventType, nil, skills.skills[j].no, kidConfig)
                                end, function(dlg, sender, eventType)
                                    self:onSelectSkill(sender, eventType, skills.skills[j].no, kidConfig)
                                end, skillListPanel)
                        end
                    end
                else
                    skillPanel:setVisible(false)
                end
            end
            self.kidListView:pushBackCustomItem(skillListPanel)
        else
            local backImage = self:getControl("BackImage", Const.UIImage, "ChildSettingPanel")
            local imageSize = backImage:getContentSize()
            imageSize.height = imageSize.height - SKILL_LIST_PANEL_HEIGHT
            backImage:setContentSize(imageSize)

            local mainPanel = self:getControl("ChildSettingPanel", Const.UIPanel)
            local size = mainPanel:getContentSize()
            size.height = imageSize.height
            mainPanel:setContentSize(size)
            self:updateLayout("ChildSettingPanel")
            self:refreshRootSize(size)
        end
    end
end

function ZuheSkillSelectDlg:getPetActionData(name)
    local actionData = {}
    local skill = {}
    local attackId = PetMgr:getFightPet():getId()
    if name == "PhyType" then

        local phyAttact = {}
        phyAttact["no"] = PHYATTACT_NO
        phyAttact["icon"] = PHYATTACT_NO
        phyAttact["name"] = CHS[3002286]
        phyAttact["ladder"] = 0
        table.insert(skill, phyAttact)

        -- 防御
        local defence = {}
        defence["no"] = DEFENCE_NO
        defence["icon"] = DEFENCE_NO
        defence["name"] = CHS[3002275]
        defence["ladder"] = 0
        table.insert(skill, defence)

        local phySkill = SkillMgr:getPetPhySkills(attackId)
        for i = 1, #phySkill do
            table.insert(skill, phySkill[i])
        end

        actionData["skills"] = skill
    elseif name == "BType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_B)

        if #skill > 0 then
            actionData["skills"] = skill
        end
    elseif name == "InnerType" then
        skill = SkillMgr:getPetRawSkillNoAndLadder(attackId)
        local dunWuSkills = SkillMgr:getPetDunWuSkillsInfo(attackId, true) -- 宠物顿悟技能，放在天生技能后面
        for i = 1, #dunWuSkills do
            table.insert(skill, dunWuSkills[i])
        end

        if #skill > 0 then
            for i = 1, #skill do
                skill[i].ladder = 0
            end

            actionData["skills"] = skill
        end
    elseif name == "PartyType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_E, SKILL.CLASS_PET)
        SkillMgr:sortStudySkill(skill)
        if #skill > 0 then
            for i = 1, #skill do
                skill[i].ladder = 0
            end
            actionData["skills"] = skill
        end
    end

    return actionData
end

function ZuheSkillSelectDlg:initPetSkill()
    self:resetCtrl("pet")

    for i = 1, #SKILL_PET_TYPE_LIST do
        local skills = self:getPetActionData(SKILL_PET_TYPE_LIST[i])
        local skillListPanel = self.petSkillListPanel[i]
        if next(skills) then
            skillListPanel:setVisible(true)
            for j = 1, 5 do
                local skillPanel = self:getControl("SkillPanel" .. j, Const.UIPanel, skillListPanel)
                if skills.skills[j] then
                    skillPanel:setVisible(true)
                    local iconPath = SkillMgr:getSkillIconPath(skills.skills[j].no)
                    self:setImage("SkillImage", iconPath, skillPanel)
                    self:setItemImageSize("SkillImage", skillPanel)
                    if skills.skills[j].ladder then
                        local mySkill = SkillMgr:getSkill(self.curShowPet:getId(), skills.skills[j].no)
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

                        if mySkill then

                            skillPanel:setEnabled(true)
                            gf:resetImageView(self:getControl("SkillImage", nil, skillPanel))

                            self:setCtrlVisible("NoManaImage", false, skillPanel)
                            skillPanel:setTag(skills.skills[j].no)
                            self:blindLongPress("SkillPanel" .. j,
                                function(dlg, sender, eventType)
                                    self:OneSecondLater(sender, eventType, nil, skills.skills[j].no, petConfig)
                                end, function(dlg, sender, eventType)
                                    self:onSelectSkill(sender, eventType, skills.skills[j].no, petConfig)
                                end, skillListPanel)


                            -- 设置等级
                          --  self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, mySkill.skill_level, false, LOCATE_POSITION.LEFT_TOP, 19, skillPanel)

                            -- 如果是顿悟技能，要加上顿悟标记
                            if SkillMgr:isPetDunWuSkill(self.curShowPet:getId(), mySkill.skill_name) then
                                SkillMgr:addDunWuSkillImage(self:getControl("SkillImage", nil, skillPanel))
                            end

                            -- 如果是法宝特殊技能，要加上法宝特殊技能标识
                            if SkillMgr:isArtifactSpSkill(mySkill.skill_name) then
                                SkillMgr:addArtifactSpSkillImage(self:getControl("SkillImage", nil, skillPanel))
                            end

                        elseif skills.skills[j].name == CHS[3002286] or skills.skills[j].name == CHS[3002275] then
                            self:setCtrlVisible("NomanaImage", false, skillPanel)
                            skillPanel:setTag(skills.skills[j].no)
                            self:blindLongPress("SkillPanel" .. j,
                                function(dlg, sender, eventType)
                                    self:OneSecondLater(sender, eventType, nil, skills.skills[j].no, petConfig)
                                end, function(dlg, sender, eventType)
                                    self:onSelectSkill(sender, eventType, skills.skills[j].no, petConfig)
                                end, skillListPanel)
                        end
                    end
                else
                    skillPanel:setVisible(false)
                end
            end
            self.petListView:pushBackCustomItem(skillListPanel)
        else
            local backImage = self:getControl("BackImage", Const.UIImage, "PetSettingPanel")
            local imageSize = backImage:getContentSize()
            imageSize.height = imageSize.height - SKILL_LIST_PANEL_HEIGHT
            backImage:setContentSize(imageSize)

            local mainPanel = self:getControl("PetSettingPanel", Const.UIPanel)
            local size = mainPanel:getContentSize()
            size.height = imageSize.height
            mainPanel:setContentSize(size)
            self:updateLayout("PetSettingPanel")
            self:refreshRootSize(size)
        end
    end
end

function ZuheSkillSelectDlg:initPlayerSkill()
    self:resetCtrl("me")

    for i = 1, #SKILL_TYPE_LIST do
        local skills = self:getMeActionData(SKILL_TYPE_LIST[i])
        local skillListPanel = self.playerSkillListPanel[i]
        if next(skills) then
            local count = 4
            if SkillMgr:isleardedFiveLadderSkill(SKILL.LADDER_5) then
                count = 5
                local width = skillListPanel:getContentSize().width
                self.playerListView:setContentSize(width, self.playerListView:getContentSize().height)
                local mainPanel = self:getControl("PlayerSettingPanel")
                mainPanel:setContentSize(width, mainPanel:getContentSize().height)
                local bkImage = self:getControl("BackImage")
                bkImage:setContentSize(width, bkImage:getContentSize().height)
                self:refreshRootSize(cc.size(width, mainPanel:getContentSize().height))
            end

            for j = 1, count do
                local skillPanel = self:getControl("SkillPanel" .. j, Const.UIPanel, skillListPanel)
                if skills.skills[j] then
                    skillPanel:setVisible(true)
                    local iconPath = SkillMgr:getSkillIconPath(skills.skills[j].no)
                    self:setImage("SkillImage", iconPath, skillPanel)
                    self:setItemImageSize("SkillImage", skillPanel)
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

                        if mySkill then
                            skillPanel:setEnabled(true)
                            gf:resetImageView(self:getControl("SkillImage", nil, skillPanel))

                            self:setCtrlVisible("NoManaImage", false, skillPanel)
                            skillPanel:setTag(skills.skills[j].no)
                            self:blindLongPress("SkillPanel" .. j,
                                function(dlg, sender, eventType)
                                    self:OneSecondLater(sender, eventType, nil, skills.skills[j].no, meConfig)
                                end, function(dlg, sender, eventType)
                                    self:onSelectSkill(sender, eventType, skills.skills[j].no, meConfig)
                                end, skillListPanel)

                            -- 如果是法宝特殊技能，要加上法宝特殊技能标识
                            if SkillMgr:isArtifactSpSkill(mySkill.skill_name) then
                                SkillMgr:addArtifactSpSkillImage(self:getControl("SkillImage", nil, skillPanel))
                            end

                        elseif skills.skills[j].name == CHS[3002286] or skills.skills[j].name == CHS[3002275] then
                            self:setCtrlVisible("NomanaImage", false, skillPanel)
                            skillPanel:setTag(skills.skills[j].no)
                            self:blindLongPress("SkillPanel" .. j,
                                function(dlg, sender, eventType)
                                    self:OneSecondLater(sender, eventType, nil, skills.skills[j].no, meConfig)
                                end, function(dlg, sender, eventType)
                                    self:onSelectSkill(sender, eventType, skills.skills[j].no, meConfig)
                                end, skillListPanel)
                        end
                    end
                else
                    skillPanel:setVisible(false)
                end
            end
            self.playerListView:pushBackCustomItem(skillListPanel)
        else
            local backImage = self:getControl("BackImage", Const.UIImage, "PlayerSettingPanel")
            local imageSize = backImage:getContentSize()
            imageSize.height = imageSize.height - SKILL_LIST_PANEL_HEIGHT
            backImage:setContentSize(imageSize)

            local mainPanel = self:getControl("PlayerSettingPanel", Const.UIPanel)
            local size = mainPanel:getContentSize()
            size.height = imageSize.height
            mainPanel:setContentSize(size)
            self:updateLayout("PlayerSettingPanel")
            self:refreshRootSize(size)
        end
    end
end

function ZuheSkillSelectDlg:getMeActionData(name)
    local actionData = {}
    local skill = {}
    local attackId =  Me:getId()

    if name == "PhyType" then
        local phyAttact = {}
        phyAttact["no"] = PHYATTACT_NO
        phyAttact["icon"] = PHYATTACT_NO
        phyAttact["name"] = CHS[3002286]
        phyAttact["ladder"] = 0
        table.insert(skill, phyAttact)

        -- 防御
        local defence = {}
        defence["no"] = DEFENCE_NO
        defence["icon"] = DEFENCE_NO
        defence["name"] = CHS[3002275]
        defence["ladder"] = 0
        table.insert(skill, defence)


        -- 力破千钧
        local phySkill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_J)
        if phySkill then
            table.insert(skill, phySkill[1])
        end

        -- 法宝特殊技能
        local artifactSpSkill = SkillMgr:getArtifactSpSkillInfo()
        for i = 1, #artifactSpSkill do
            table.insert(skill, artifactSpSkill[i])
        end

        actionData["skills"] = skill
    elseif name == "BType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_B)

        if #skill > 0 then
            actionData["skills"] = skill
        end
    elseif name == "CType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_C)

        if #skill > 0 then
            actionData["skills"] = skill
        end
    elseif name == "DType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_D)

        if #skill > 0 then
            actionData["skills"] = skill
        end
    end

    -- 特殊处理：人物身上由亲密无间获得的技能
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
            result["skills"] = skills
        end
    end

    return result
end

function ZuheSkillSelectDlg:onSelectSkill(sender, type, skillNo, object)

    if object["name"] == "pet" and Me:isInCombat() then
        if not PetMgr:getFightPet() or not FightMgr:getObjectById(PetMgr:getFightPet():getId()) then
            gf:ShowSmallTips(CHS[4200478])
            self:onCloseButton()
            DlgMgr:closeDlg("AutoFightDlg")
            return
        end

        if PetMgr:getFightPet() and self.curShowPet:getId() ~= PetMgr:getFightPet():getId() then
            gf:ShowSmallTips(CHS[4200477])
            self:onCloseButton()
            DlgMgr:closeDlg("AutoFightDlg")
            return
        end
    end

    if object["name"] == "kid" and Me:isInCombat() then
        if not HomeChildMgr:getFightKid() or not FightMgr:getObjectById(HomeChildMgr:getFightKid():getId()) then
            gf:ShowSmallTips(CHS[7120208])
            self:onCloseButton()
            DlgMgr:closeDlg("AutoFightDlg")
            return
        end

        if HomeChildMgr:getFightKid() and self.curShowKid:getId() ~= HomeChildMgr:getFightKid():getId() then
            gf:ShowSmallTips(CHS[4200477])
            self:onCloseButton()
            DlgMgr:closeDlg("AutoFightDlg")
            return
        end
    end

    local autoSkillType, autoSkiillParam

    if skillNo == DEFENCE_NO then
        autoSkillType = FIGHT_ACTION.DEFENSE
        autoSkiillParam = 0
    elseif skillNo == PHYATTACT_NO then
        autoSkillType = FIGHT_ACTION.PHYSICAL_ATTACK
        autoSkiillParam = FIGHT_ACTION.PHYSICAL_ATTACK
    elseif skillNo == LIFE_NO then
        if InventoryMgr:isHaveLifeItem() then
            autoSkillType = FIGHT_ACTION.APPLY_ITEM
            autoSkiillParam = 0
        else
            gf:ShowSmallTips(CHS[3002290])
            return
        end
    elseif skillNo == MANA_NO then
        if InventoryMgr:isHaveManaItem() then
            autoSkillType = FIGHT_ACTION.APPLY_ITEM
            autoSkiillParam = 1
        else
            gf:ShowSmallTips(CHS[3002288])
            return
        end
    elseif SkillMgr:isArtifactSpSkillByNo(skillNo) then
        -- 法宝特殊技能
        autoSkillType = FIGHT_ACTION.ACTION_USE_ARTIFACT_EXTRA_SKILL
        autoSkiillParam = skillNo
    else
        autoSkillType = FIGHT_ACTION.CAST_MAGIC
        autoSkiillParam = skillNo
    end

    if object["name"] == "me" then
        local isCanSetSkill = self:checkCanSetSkill(skillNo)
        if not isCanSetSkill then
            return
        end

        self.fuc(self.obj, skillNo, object.name, self.sender)
    elseif object["name"] == "kid" then
        self.fuc(self.obj, skillNo, object.name, self.sender)
    elseif object["name"] == "pet" then
        -- 颠倒乾坤技能无法进行自动战斗
        local skillName = SkillMgr:getSkillName(skillNo)
        if skillName == CHS[3001942] then
            gf:ShowSmallTips(CHS[7000323])
            return
        end

        -- 舍身取义无法进行自动战斗
        if skillName == CHS[3004250] then
            gf:ShowSmallTips(CHS[5410228])
            return
        end

        self.fuc(self.obj, skillNo, object.name, self.sender)
    end

    DlgMgr:closeDlg(self.name)
end

function ZuheSkillSelectDlg:setPositionByRect(rect)
    self.root:setAnchorPoint(cc.p(1, 0))
    local pos = self.root:getParent():convertToNodeSpace(cc.p(rect.x, rect.y))
    self.root:setPosition(pos)
end


return ZuheSkillSelectDlg