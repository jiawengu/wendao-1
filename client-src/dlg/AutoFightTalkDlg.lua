-- AutoFightTalkDlg.lua
-- Created by zhengjh Mar/31/2015
-- 自动战斗

local RadioGroup = require('ctrl/RadioGroup')
local AutoFightTalkDlg = Singleton("AutoFightTalkDlg", Dialog)
local IS_SKILL = "isSkill"
local IS_DEFENCE = "isDefence"
local IS_PHYATTACT = "isPhyAttact"

local DEFENCE_NO = 9167
local PHYATTACT_NO = 9166
local LIFE_NO   = 9169
local MANA_NO   = 9170
local COLUMN_SAPCE = 15
local SKILL_LIST_PANEL_HEIGHT = 82

local meConfig = {name = "me"}
local petConfig = {name = "pet"}
local kidConfig = {name = "kid"}

local SKILL_TYPE_LIST = {"DType", "CType", "BType", "PhyType"}
local SKILL_PET_TYPE_LIST = {"PartyType", "InnerType", "BType", ""}
local SKILL_KID_TYPE_LIST = {"DType", "CType", "BType", "PhyType"}

local PHYSIC_CONFIG =
    {
        [DEFENCE_NO] = CHS[3002275],
        [PHYATTACT_NO] = CHS[3002276],
        [LIFE_NO] = CHS[3002277],
        [MANA_NO] = CHS[3002278],
    }

local SKILL_SHOW_NAME =
    {

        BTypeSkillPanel = {CHS[3002279], CHS[3002280], CHS[3002281], CHS[3002282], CHS[3002283]},
        CTypeSkillPanel = {CHS[3002279], CHS[3002280], CHS[3002281], CHS[3002282], CHS[3002283]},
        DTypeSkillPanel = {CHS[3002279], CHS[3002280], CHS[3002281], CHS[3002282], CHS[3002283]},
        PhySkillPanel = {CHS[3002276], CHS[3002275], CHS[3002284]},
        AttackSkillPanel = {CHS[3002279], CHS[3002280], CHS[3002282]},
        PetPhySkillPanel = {CHS[3002276], CHS[3002275]},
    }

function AutoFightTalkDlg:init()

    self.playerListView = self:getControl("MainListView", Const.UIListView, "PlayerSettingPanel")
    self.playerSkillListPanel = {
        self:getControl("SkillListPanel1", Const.UIPanel, "PlayerSettingPanel"),
        self:getControl("SkillListPanel2", Const.UIPanel, "PlayerSettingPanel"),
        self:getControl("SkillListPanel3", Const.UIPanel, "PlayerSettingPanel"),
        self:getControl("SkillListPanel4", Const.UIPanel, "PlayerSettingPanel"),
    }

    self.petListView = self:getControl("MainListView", Const.UIListView, "PetSettingPanel")
    self.petSkillListPanel = {
        self:getControl("SkillListPanel1", Const.UIPanel, "PetSettingPanel"),
        self:getControl("SkillListPanel2", Const.UIPanel, "PetSettingPanel"),
        self:getControl("SkillListPanel3", Const.UIPanel, "PetSettingPanel"),
        self:getControl("SkillListPanel4", Const.UIPanel, "PetSettingPanel"),
    }

    self.kidListView = self:getControl("MainListView", Const.UIListView, "ChildSettingPanel")
    self.kidSkillListPanel = {
        self:getControl("SkillListPanel1", Const.UIPanel, "ChildSettingPanel"),
        self:getControl("SkillListPanel2", Const.UIPanel, "ChildSettingPanel"),
        self:getControl("SkillListPanel3", Const.UIPanel, "ChildSettingPanel"),
        self:getControl("SkillListPanel4", Const.UIPanel, "ChildSettingPanel"),
    }

    self.qinMiWuJianListView = self:getControl("MainListView", Const.UIListView, "QinmiwujianPanel")
    self.qinMiWuJianListPanel = {
        self:getControl("SkillListPanel1", Const.UIPanel, "QinmiwujianPanel"),
        self:getControl("SkillListPanel2", Const.UIPanel, "QinmiwujianPanel"),
    }

    for k,v in pairs(self.playerSkillListPanel) do
        v:retain()
        v:removeFromParent()
    end

    for k,v in pairs(self.petSkillListPanel) do
        v:retain()
        v:removeFromParent()
    end

    for k,v in pairs(self.kidSkillListPanel) do
        v:retain()
        v:removeFromParent()
    end

    for k,v in pairs(self.qinMiWuJianListPanel) do
        v:retain()
        v:removeFromParent()
    end
end

function AutoFightTalkDlg:initSkill(id)
    self:setCtrlVisible("PlayerSettingPanel", false)
    self:setCtrlVisible("PetSettingPanel", false)
    self:setCtrlVisible("ChildSettingPanel", false)

    if id == Me:getId() then
        self:initPlayerSkill()
        self:setCtrlVisible("PlayerSettingPanel", true)
    elseif HomeChildMgr:getKidById(id) then
        self.curShowKid = HomeChildMgr:getKidById(id)
        self:initKidSkill()
        self:setCtrlVisible("ChildSettingPanel", true)
    else
        self.curShowPet = PetMgr:getPetById(id)
        self:initPetSkill()
        self:setCtrlVisible("PetSettingPanel", true)
    end
end

function AutoFightTalkDlg:setCallBcak(obj, fuc, sender)
    self.fuc = nil
    self.obj = nil
    self.sender = nil

    self.fuc = fuc
    self.obj = obj
    self.sender = sender
end


function AutoFightTalkDlg:getMeActionData(name)
    local actionData = {}
    local skill = {}
    local attackId =  Me:getId()

    if name == "PhyType" then

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

function AutoFightTalkDlg:resetCtrl(type)
    local backImage
    if type == "me" then
        self.playerListView:removeAllItems()
        backImage = self:getControl("BackImage", Const.UIImage, "PlayerSettingPanel")
    elseif type == "kid" then
        self.kidListView:removeAllItems()
        backImage = self:getControl("BackImage", Const.UIImage, "ChildSettingPanel")
    else
        self.petListView:removeAllItems()
        backImage = self:getControl("BackImage", Const.UIImage, "PetSettingPanel")
    end

    local size = backImage:getContentSize()
    backImage:setContentSize(size)
end

function AutoFightTalkDlg:resetQinMiWuJianCtrl()
    if not self.qinMiWuJianListView then
        return
    end

    self.qinMiWuJianListView:removeAllItems()
    local backImage = self:getControl("BackImage", Const.UIImage, "QinmiwujianPanel")
    local size = backImage:getContentSize()
    size.height = 248
    backImage:setContentSize(size)
end



function AutoFightTalkDlg:initPlayerSkill()
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
                            if self.hasData[skills.skills[j].no] then
                                skillPanel:setEnabled(false)
                                gf:grayImageView(self:getControl("SkillImage", nil, skillPanel))
                            else
                                skillPanel:setEnabled(true)
                                gf:resetImageView(self:getControl("SkillImage", nil, skillPanel))
                            end

                            self:setCtrlVisible("NoManaImage", false, skillPanel)
                            skillPanel:setTag(skills.skills[j].no)
                            self:blindLongPress("SkillPanel" .. j,
                                function(dlg, sender, eventType)
                                    self:OneSecondLater(sender, eventType, nil, skills.skills[j].no, meConfig)
                                end, function(dlg, sender, eventType)
                                    self:onSelectSkill(sender, eventType, skills.skills[j].no, meConfig)
                                end, skillListPanel)

                            -- 设置等级
                            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, mySkill.skill_level, false, LOCATE_POSITION.LEFT_TOP, 19, skillPanel)

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

function AutoFightTalkDlg:initKidSkill()
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

                        self:setCtrlVisible("DownImage", true, skillPanel)
                        if skills.skills[j].ladder ~= 0 then
                            self:setImagePlist("DownImage", ResMgr:getLadderPath(skills.skills[j].ladder), skillPanel)
                        else
                            self:setImagePlist("DownImage", ResMgr.SkillText[skills.skills[j].name], skillPanel)
                        end

                        if mySkill then
                            if self.hasData[skills.skills[j].no] then
                                skillPanel:setEnabled(false)
                                gf:grayImageView(self:getControl("SkillImage", nil, skillPanel))
                            else
                                skillPanel:setEnabled(true)
                                gf:resetImageView(self:getControl("SkillImage", nil, skillPanel))
                            end

                            self:setCtrlVisible("NoManaImage", false, skillPanel)
                            skillPanel:setTag(skills.skills[j].no)
                            self:blindLongPress("SkillPanel" .. j,
                                function(dlg, sender, eventType)
                                    self:OneSecondLater(sender, eventType, nil, skills.skills[j].no, kidConfig)
                                end, function(dlg, sender, eventType)
                                    self:onSelectSkill(sender, eventType, skills.skills[j].no, kidConfig)
                                end, skillListPanel)


                            -- 设置等级
                            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, mySkill.skill_level, false, LOCATE_POSITION.LEFT_TOP, 19, skillPanel)
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

function AutoFightTalkDlg:initPetSkill()
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

                            if self.hasData[skills.skills[j].no] then
                                skillPanel:setEnabled(false)
                                gf:grayImageView(self:getControl("SkillImage", nil, skillPanel))
                            else
                                skillPanel:setEnabled(true)
                                gf:resetImageView(self:getControl("SkillImage", nil, skillPanel))
                            end

                            self:setCtrlVisible("NoManaImage", false, skillPanel)
                            skillPanel:setTag(skills.skills[j].no)
                            self:blindLongPress("SkillPanel" .. j,
                                function(dlg, sender, eventType)
                                    self:OneSecondLater(sender, eventType, nil, skills.skills[j].no, petConfig)
                                end, function(dlg, sender, eventType)
                                    self:onSelectSkill(sender, eventType, skills.skills[j].no, petConfig)
                                end, skillListPanel)


                            -- 设置等级
                            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, mySkill.skill_level, false, LOCATE_POSITION.LEFT_TOP, 19, skillPanel)

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

function AutoFightTalkDlg:refreshRootSize()
end

function AutoFightTalkDlg:OneSecondLater(sender, eventType, type, skillNo, objType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local ob = nil

    if objType and objType["name"] == "pet" then
        ob = self.curShowPet
    elseif objType and objType["name"] == "kid" then
        ob = self.curShowKid
    else
        ob = Me
    end

    if not ob then return end

    SkillMgr:showSkillDescDlg(SkillMgr:getSkillName(skillNo), ob:getId(), objType and objType["name"] == "pet", rect, type)
end

-- 人物战斗动作
function AutoFightTalkDlg:createMeAction()
    local actionList = {}

    -- 辅助技能
    if self:getMeActionData("auxiliary")["name"] ~= nil then
        table.insert(actionList, self:getMeActionData("auxiliary"))
    end

    -- 障碍技能
    if self:getMeActionData("balk")["name"] ~= nil then
        table.insert(actionList, self:getMeActionData("balk"))
    end

    -- 法功技能
    if self:getMeActionData("magci")["name"] ~= nil then
        table.insert(actionList, self:getMeActionData("magci"))
    end

    -- 物理攻击和防御
    if self:getMeActionData("pyhAttact")["name"] ~= nil then
        table.insert(actionList, self:getMeActionData("pyhAttact"))
    end

    return actionList
end

function AutoFightTalkDlg:setHasData(haveData)
    self.hasData = {}
    for _, data in pairs(haveData) do
        self.hasData[data.para] = 1
    end
end

function AutoFightTalkDlg:getPetActionData(name)
    local actionData = {}
    local skill = {}
    local attackId = self.curShowPet:getId()

    --SkillMgr:getSkill(attackId, skills.skills[j].no)

    if name == "PhyType" then

    elseif name == "BType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_B)
        local destSkills = {}
        for i, sk in pairs(skill) do
            if SkillMgr:getSkill(attackId, sk.no) then
                table.insert(destSkills, sk)
            end
        end
        if #destSkills > 0 then
            actionData["skills"] = destSkills
        end
    elseif name == "InnerType" then
        skill = SkillMgr:getPetRawSkillNoAndLadder(attackId)
        local dunWuSkills = SkillMgr:getPetDunWuSkillsInfo(attackId) -- 宠物顿悟技能，放在天生技能后面

        for i = 1, #dunWuSkills do
            table.insert(skill, dunWuSkills[i])
        end

        local destSkills = {}
        for i, sk in pairs(skill) do
            if SkillMgr:getSkill(attackId, sk.no) then
                table.insert(destSkills, sk)
            end
        end

        if #destSkills > 0 then
            for i = 1, #destSkills do
                destSkills[i].ladder = 0
            end

            actionData["skills"] = destSkills
        end
    elseif name == "PartyType" then
        skill = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_E, SKILL.CLASS_PET)

        local destSkills = {}
        for i, sk in pairs(skill) do
            if SkillMgr:getSkill(attackId, sk.no) then
                table.insert(destSkills, sk)
            end
        end

        SkillMgr:sortStudySkill(destSkills)
        if #destSkills > 0 then
            for i = 1, #destSkills do
                destSkills[i].ladder = 0
            end
            actionData["skills"] = destSkills
        end
    end

    return actionData
end

function AutoFightTalkDlg:getKidActionData(name)
    local actionData = {}
    local skill = {}
    local attackId = self.curShowKid:getId()

    if name == "PhyType" then
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

function AutoFightTalkDlg:onSelectSkill(sender, type, skillNo, object)
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
    elseif object["name"] == "pet" then
        self.fuc(self.obj, skillNo, object.name, self.sender)
    elseif object["name"] == "kid" then
        self.fuc(self.obj, skillNo, object.name, self.sender)
    end

    DlgMgr:closeDlg(self.name)
end

function AutoFightTalkDlg:checkCanSetSkill(skillNo)
    local skillName = SkillMgr:getSkillName(skillNo)
    -- 选中了法宝特殊技能
    if SkillMgr:isArtifactSpSkill(skillName) then
        local nimbus = EquipmentMgr:getEquippedArtifactNimbus()
        if nimbus < SkillMgr:getArtifactSpSkillCostNimbus(skillName) then
            -- 法宝灵气是否充足
            gf:ShowSmallTips(CHS[7000314])
            return false
        end

        if skillName == CHS[3001944] or skillName == CHS[3001945] then
            -- 物极必反/天眼
            gf:ShowSmallTips(CHS[7000313])
            return false
        elseif skillName == CHS[3001947] then
            -- 亲密无间
            gf:ShowSmallTips(CHS[7003001])
            return false
        end
    end

    -- 选中的是亲密无间复制的宠物技能
    if SkillMgr:isQinMiWuJianCopySkill(skillName, skillNo) then
        gf:ShowSmallTips(CHS[7003001])
        return false
    end

    return true
end

function AutoFightTalkDlg:setSelectInfo(skillName, cell)
    local skillNameLabel = self:getControl("SkillNameLabel", Const.UILabel, cell)
    skillNameLabel:setString(skillName)
    local skilClassLabel = self:getControl("SkillTypeLabel", Const.UILabel, cell)
    skilClassLabel:setString(SkillMgr:getSkillDesc(skillName)["type"])
    self:getControl("SkillTypeLabel", Const.UILabel, cell):setVisible(false)

    self:getControl("SkillNameLabel", Const.UILabel, cell):setVisible(true)
    self:getControl("SkillTypeLabel", Const.UILabel, cell):setVisible(true)
    self:getControl("ActionSkillLabel", Const.UILabel, cell):setVisible(false)
end

function AutoFightTalkDlg:setLastSelectInfo(object)
    if object.lastSender and tolua.cast(object.lastSender, "ccui.Layout"):getParent():getName() == IS_SKILL then
        self:getControl("SkillNameLabel", Const.UILabel, object.lastSender:getParent()):setVisible(false)
        self:getControl("SkillTypeLabel", Const.UILabel, object.lastSender:getParent()):setVisible(false)
        self:getControl("ActionSkillLabel", Const.UILabel, object.lastSender:getParent()):setVisible(true)
    end
end

function AutoFightTalkDlg:cleanup()
    self.curShowKid = nil
    self.curShowPet = nil

    if self.playerSkillListPanel then
        for k, v in pairs(self.playerSkillListPanel) do
            if v then
                self.playerSkillListPanel[k]:release()
                self.playerSkillListPanel[k] = nil
            end
        end

        self.playerSkillListPanel = nil
    end

    if self.petSkillListPanel then
        for k, v in pairs(self.petSkillListPanel) do
            if v then
                self.petSkillListPanel[k]:release()
                self.petSkillListPanel[k] = nil
            end
        end

        self.petSkillListPanel = nil
    end

    if self.kidSkillListPanel then
        for k, v in pairs(self.kidSkillListPanel) do
            if v then
                self.kidSkillListPanel[k]:release()
                self.kidSkillListPanel[k] = nil
            end
        end

        self.kidSkillListPanel = nil
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

return AutoFightTalkDlg
