-- AutoFightDlg.lua
-- Created by zhengjh Mar/31/2015
-- 自动战斗

local RadioGroup = require('ctrl/RadioGroup')
local AutoFightDlg = Singleton("AutoFightDlg", Dialog)
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
local SKILL_PET_TYPE_LIST = {"PartyType", "InnerType", "BType", "PhyType"}
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

function AutoFightDlg:init()

    self:bindCheckBox()

    self:bindListener("SetButton", self.onSetButton, "PlayerSettingPanel")
    self:bindListener("SetButton", self.onSetButton, "ChildSettingPanel")
    self:bindListener("SetButton", self.onSetButton, "PetSettingPanel")

    self:bindListener("RuleButton", self.onRuleButton)
    self:bindListener("LastButton", self.onLastButton)
    self:bindListener("SaveButton", self.onSaveButton)

    local pSettingPanel = self:getControl("SkillListPanel5", nil, "PlayerSettingPanel")
    local childSettingPanel = self:getControl("SkillListPanel5", nil, "ChildSettingPanel")
    local petSettingPanel = self:getControl("SkillListPanel5", nil, "PetSettingPanel")
    self:bindListener("SkillPanel1", self.onZHPlayerSkillButton, pSettingPanel)
    self:bindListener("SkillPanel1", self.onZHPetSkillButton, childSettingPanel)
    self:bindListener("SkillPanel1", self.onZHPetSkillButton, petSettingPanel)

    for i = 1, 3 do
        local panel = self:getControl("SkillZHPanel" .. i)
        panel:setTag(i)
        self:bindListener("SkillButton", self.onSkillButton, "SkillZHPanel" .. i)
        self:bindListener("DelButton", self.onDelButton, "SkillZHPanel" .. i)
    end


    self.initBKImageSize = self.initBKImageSize or self:getCtrlContentSize("BackImage", "PetSettingPanel")

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

    self.display = nil

    self:setCtrlVisible("QinmiwujianPanel", false)
    self:setCombinationVisible(false)
    self:setCtrlVisible("ChildAutoFightPanel", false)

    self:bindFloatPanelListener("RulePanel")

    -- 组合技能选择图片
    self.selectSkillImage = self:retainCtrl("SkillbuttonImage")

    self.zhSkillsData = {[1] = {}, [2] = {}, [3] = {}}

    -- 设置组合技能回合数
    for i = 1, 3 do
        self:bindNumInput("TimeValuePanel", "SkillZHPanel" .. i, nil, "SkillZHPanel" .. i)
        self:onDelButton(self:getControl("DelButton", nil, "SkillZHPanel" .. i))
    end
end

-- 数字键盘插入数字,组合技能回合数
function AutoFightDlg:insertNumber(num, key)
    if num < 1 then
        num = 1
        gf:ShowSmallTips(CHS[4100974])  -- 每个指令至少要执行1回合。
    end

    if num > 50 then
        num = 50
        gf:ShowSmallTips(CHS[4100975])    -- 每个指令最多可执行50回合。
    end

    local panel = self:getControl(key)
    self:setNumImgForPanel("TimeValuePanel", ART_FONT_COLOR.NORMAL_TEXT, num, false, LOCATE_POSITION.MID, 21, panel)
    self.zhSkillsData[panel:getTag()].round = num

    DlgMgr:sendMsg('SmallNumInputDlg', 'setInputValue', num)
end

function AutoFightDlg:initSkill(type)
    self:setCtrlVisible("PlayerSettingPanel", false)
    self:setCtrlVisible("ChildSettingPanel", false)
    self:setCtrlVisible("PetSettingPanel", false)

    if type == "me" then
        self.display = "PlayerSettingPanel"
        self:initPlayerSkill()
        self:setCtrlVisible("PlayerSettingPanel", true)
    elseif type == "kid" then
        self.display = "ChildSettingPanel"
        self.curShowKid = HomeChildMgr:getFightKid()
        self:initKidSkill()
        self:setCtrlVisible("ChildSettingPanel", true)
    else
        self.display = "PetSettingPanel"
        self.curShowPet = PetMgr:getFightPet()
        self:initPetSkill()
        self:setCtrlVisible("PetSettingPanel", true)
    end
end

-- 增加选择组合技能按钮的选中图片
function AutoFightDlg:addSelectImage(sender)
    self.selectSkillImage:removeFromParent()
    local panel = sender:getParent()
    panel:addChild(self.selectSkillImage)
end

-- 删除按钮
function AutoFightDlg:onDelButton(sender)
    local panel = sender:getParent()

    local function delete(tag)
        self.selectSkillImage:removeFromParent()
        self:setImagePlist("SkillImage", ResMgr.ui.touming, panel)
        self:setLabelText("NameLabel", CHS[4100976], panel)   -- 点击设置
        local timePanel = self:getControl("TimeValuePanel", nil, panel)
        self:removeNumImgForPanel(timePanel, LOCATE_POSITION.MID)
        self.zhSkillsData[tag] = {}
    end

    if self.zhSkillsData[panel:getTag()] and next(self.zhSkillsData[panel:getTag()]) then
        gf:confirm(string.format(CHS[4200476], panel:getTag()), function ()
            delete(panel:getTag())
        end, nil, nil, nil, nil, nil, nil, "set_auto_fight")
        return
    end

    delete(panel:getTag())
end


-- 点击某个组合 技能按钮
function AutoFightDlg:onSkillButton(sender)
    self:setCtrlVisible("ChildAutoFightPanel", false)
    self:addSelectImage(sender)
    if self.display == "PlayerSettingPanel" then
        local dlg = DlgMgr:openDlg("ZuheSkillSelectDlg")
        dlg:setTitle("me")
        dlg:initSkill(Me:getId())
        dlg:setCallBcak(self, self.onZHSelectSkill, sender)
        local rect = self:getBoundingBoxInWorldSpace(self:getControl("CombinationPanel"))
        dlg:setPositionByRect(rect)
    elseif self.display == "ChildSettingPanel" then
        local kid = HomeChildMgr:getFightKid()
        if kid then
            local dlg = DlgMgr:openDlg("ZuheSkillSelectDlg")
            dlg:setTitle("kid")
            dlg:initSkill(kid:getId())
            dlg:setCallBcak(self, self.onZHSelectSkill, sender)
            local rect = self:getBoundingBoxInWorldSpace(self:getControl("CombinationPanel"))
            dlg:setPositionByRect(rect)
        end
    elseif self.display == "PetSettingPanel" then
        local pet = PetMgr:getFightPet()
        if pet then
            local dlg = DlgMgr:openDlg("ZuheSkillSelectDlg")
            dlg:setTitle("pet")
            dlg:initSkill(pet:getId())
            dlg:setCallBcak(self, self.onZHSelectSkill, sender)
            local rect = self:getBoundingBoxInWorldSpace(self:getControl("CombinationPanel"))
            dlg:setPositionByRect(rect)
        end
    end
end

-- 选择好技能后，组合技能panel上回调显示接口
function AutoFightDlg:onZHSelectSkill(skillNo, obType, sender)
    local panel = sender:getParent()
    local skill = SkillMgr:getskillAttrib(skillNo)
    local iconPath = SkillMgr:getSkillIconPath(skillNo)
    self:setImage("SkillImage", iconPath, panel)
    self:setLabelText("NameLabel", skill.name, panel)

    self.selectSkillImage:removeFromParent()

    self.zhSkillsData[panel:getTag()].no = skillNo
    if not self.zhSkillsData[panel:getTag()].round then
        self:insertNumber(1, panel:getName())
    end
end

function AutoFightDlg:getSkillZHdata(skillData)
    local autoSkillType, autoSkiillParam

    if skillData.no == DEFENCE_NO then
        autoSkillType = FIGHT_ACTION.DEFENSE
        autoSkiillParam = 0
    elseif skillData.no == PHYATTACT_NO then
        autoSkillType = FIGHT_ACTION.PHYSICAL_ATTACK
        autoSkiillParam = FIGHT_ACTION.PHYSICAL_ATTACK
    elseif skillData.no == LIFE_NO then
        if InventoryMgr:isHaveLifeItem() then
            autoSkillType = FIGHT_ACTION.APPLY_ITEM
            autoSkiillParam = 0
        else
            gf:ShowSmallTips(CHS[3002287])
            return
        end
    elseif skillData.no == MANA_NO then
        if InventoryMgr:isHaveManaItem() then
            autoSkillType = FIGHT_ACTION.APPLY_ITEM
            autoSkiillParam = 1
        else
            gf:ShowSmallTips(CHS[3002288])
            return
        end
    elseif SkillMgr:isArtifactSpSkillByNo(skillData.no) then
        autoSkillType = FIGHT_ACTION.ACTION_USE_ARTIFACT_EXTRA_SKILL
        autoSkiillParam = skillData.no
    else
        autoSkillType = FIGHT_ACTION.CAST_MAGIC
        autoSkiillParam = skillData.no
    end

    return autoSkillType, autoSkiillParam
end

function AutoFightDlg:getZHFirstSkill()
    local fristSkill
    for i = 1, 3 do
        if self.zhSkillsData[i] and next(self.zhSkillsData[i]) then
            if self.zhSkillsData[i].round and self.zhSkillsData[i].no then
                if not fristSkill then fristSkill = gf:deepCopy(self.zhSkillsData[i]) end
            end
        end
    end

    return fristSkill
end

-- 点击组合技能图标
function AutoFightDlg:onZHPlayerSkillButton(sender)
    local petAutoData = AutoFightMgr:getPlayerAutoFightData()
    if petAutoData and next(petAutoData)  and petAutoData.multi_count > 0 then
        if AutoFightMgr:isNotTargetFightObj(petAutoData) then
            -- 组合技能，对应技能不需要选中目标
            AutoFightMgr:setAutoFightTarget(Me:getId(), "", "")
        else
            DlgMgr:openDlgEx("ZHSkillTargetChoseDlg", "player")
        end
        self:onCloseButton()
    else
        gf:ShowSmallTips(CHS[4100977]) -- "你还未设置任何组合指令，请点击组合指令图标右侧#R设置#n按钮进行组合指令设置。
    end
end

-- 点击组合技能图标
function AutoFightDlg:onZHPetSkillButton(sender)
    local obj = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    if not obj then return end
    local petAutoData = AutoFightMgr:changePetDataToCmd()
    if petAutoData and next(petAutoData)  and petAutoData.multi_count > 0 then
        if AutoFightMgr:isNotTargetFightObj(petAutoData) then
            AutoFightMgr:setAutoFightTarget(obj:getId(), "", "")
        else
            if HomeChildMgr:getFightKid() then
                DlgMgr:openDlgEx("ZHSkillTargetChoseDlg", "kid")
            else
                DlgMgr:openDlgEx("ZHSkillTargetChoseDlg", "pet")
            end
        end

        self:onCloseButton()
    else
        gf:ShowSmallTips(CHS[4100977])
    end
end

function AutoFightDlg:saveMeAutoFightCmd()
    local data = AutoFightMgr:changeMeDataToCmd()
    data.multi_count = 0
    data.autoFightData = {}
    for i = 1, 3 do
        if self.zhSkillsData[i] and next(self.zhSkillsData[i]) then
            if self.zhSkillsData[i].round and self.zhSkillsData[i].no then
                data.multi_count = data.multi_count + 1
                local act, para = self:getSkillZHdata(self.zhSkillsData[i])
                table.insert(data.autoFightData, {action = act, para = para, round = self.zhSkillsData[i].round})
            end
        end
    end

    AutoFightMgr:setMeAutoFightAction(nil, nil, data)
    gf:ShowSmallTips(CHS[4100978])
end

-- 保存组合
function AutoFightDlg:onSaveButton(sender)
    -- 保存角色
    if self.display == "PlayerSettingPanel" then
        self:saveMeAutoFightCmd()
        return
    end

    -- 保存娃娃组合技能
    if self.display == "ChildSettingPanel" and not self.isExitFightKid() then
        gf:ShowSmallTips(CHS[7120208])
        DlgMgr:closeDlg(self.name)
        return
    end

    -- 保存宠物组合技能
    if self.display == "PetSettingPanel" and not self.isExitFightPet() then
        gf:ShowSmallTips(CHS[3002285])
        DlgMgr:closeDlg(self.name)
        return
    end

    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    local data = AutoFightMgr:changePetDataToCmd()
    data.multi_count = 0
    data.autoFightData = {}
    local fristSkill
    for i = 1, 3 do
        if self.zhSkillsData[i] and next(self.zhSkillsData[i]) then
            if self.zhSkillsData[i].round and self.zhSkillsData[i].no then
                data.multi_count = data.multi_count + 1
                local act, para = self:getSkillZHdata(self.zhSkillsData[i])
                table.insert(data.autoFightData, {action = act, para = para, round = self.zhSkillsData[i].round})
                if not fristSkill then fristSkill = gf:deepCopy(self.zhSkillsData[i]) end
            end
        end
    end

    AutoFightMgr:setPetAutoFightAction(nil, nil, data)
    gf:ShowSmallTips(CHS[4100978])  -- 组合指令保存成功
--    self.fuc(self.obj, fristSkill, "pet")
end


-- 返回按钮
function AutoFightDlg:onLastButton(sender)
    self:setCtrlVisible(self.display, true)
    self:setCombinationVisible(false)
end

-- 规则
function AutoFightDlg:onRuleButton(sender)
    self:setCtrlVisible("RulePanel", true)
end

function AutoFightDlg:setCombinationVisible(visible)
    self:setCtrlVisible("CombinationPanel", visible)
end

-- 点击设置组合技能
function AutoFightDlg:onSetButton(sender)
    self:setCtrlVisible(self.display, false)
    self:setCombinationVisible(true)
    self.zhSkillsData = {[1] = {}, [2] = {}, [3] = {}}
    if "PlayerSettingPanel" == self.display then
        local data = AutoFightMgr:getPlayerAutoFightData()
        if not data or not data.autoFightData then return end
        for _ = 1, 3 do
            local panel = self:getControl("SkillZHPanel" .. _)
            if data.autoFightData[_] then
                local value = data.autoFightData[_]
                local no = AutoFightMgr:getSkillNoByData(value)
                local skill = SkillMgr:getskillAttrib(no)
                local iconPath = SkillMgr:getSkillIconPath(no)
                self:setImage("SkillImage", iconPath, panel)
                self:setLabelText("NameLabel", skill.name, panel)
                self.zhSkillsData[panel:getTag()].no = no
                self.zhSkillsData[panel:getTag()].round = value.round
                self:insertNumber(value.round, "SkillZHPanel" .. _)
            else
                local ctl = self:getControl("DelButton", nil, panel)
                self:onDelButton(ctl)
            end
        end

    else
        local data = AutoFightMgr:getPetAutoFightData()
        if not data or not data.zhSkillsData then return end
        for _ = 1, 3 do
            local panel = self:getControl("SkillZHPanel" .. _)
            if data.zhSkillsData[_] then
                local value = data.zhSkillsData[_]
                local no = AutoFightMgr:getSkillNoByData(value)
                local skill = SkillMgr:getskillAttrib(no)
                local iconPath = SkillMgr:getSkillIconPath(no)
                self:setImage("SkillImage", iconPath, panel)
                self:setLabelText("NameLabel", skill.name, panel)
                self.zhSkillsData[panel:getTag()].no = no
                self.zhSkillsData[panel:getTag()].round = value.round
                self:insertNumber(value.round, "SkillZHPanel" .. _)
            else
                local ctl = self:getControl("DelButton", nil, panel)
                self:onDelButton(ctl)
            end
        end
    end
end

function AutoFightDlg:bindCheckBox()
    local palyerSelectPanel = self:getControl("PlayerSettingPanel" )
    local radioGroup = RadioGroup.new()
    radioGroup:setItems(self, {"AutoRecoverManaCheckBox", "PhyAttackCheckBox"}, self.onClickSelectCheckBox)
    radioGroup:selectRadio(AutoFightMgr:getMeSelectManaIndex(), true)

    local childSettingPanel = self:getControl("ChildSettingPanel" )
    local kidRadioGroup = RadioGroup.new()
    kidRadioGroup:setItems(self, {"AutoRecoverManaCheckBox", "PhyAttackCheckBox"}, self.onClickPetSelectCheckBox, childSettingPanel)
    kidRadioGroup:selectRadio(AutoFightMgr:getPetSelectManaIndex(), true)

    local petSelectPanel = self:getControl("PetSettingPanel" )
    local petRadioGroup = RadioGroup.new()
    petRadioGroup:setItems(self, {"AutoRecoverManaCheckBox", "PhyAttackCheckBox"}, self.onClickPetSelectCheckBox, petSelectPanel)
    petRadioGroup:selectRadio(AutoFightMgr:getPetSelectManaIndex(), true)
end

function AutoFightDlg:setParam(name)
end

function AutoFightDlg:onClickSelectCheckBox(sender, eventType)
    if sender:getName() == "AutoRecoverManaCheckBox" then
        AutoFightMgr:sendMeSelelctManaIndex(1)
    else
        AutoFightMgr:sendMeSelelctManaIndex(2)
    end
end

function AutoFightDlg:onClickPetSelectCheckBox(sender, eventType)
    if sender:getName() == "AutoRecoverManaCheckBox" then
        AutoFightMgr:sendPetSelectManaIndex(1)
    else
        AutoFightMgr:sendPetSelectManaIndex(2)
    end
end

function AutoFightDlg:onPlayerSkillPanel()
    self:getControl("PetSettingPanel", Const.UIPanel):setVisible(false)
    self:getControl("PlayerSettingPanel", Const.UIPanel):setVisible(true)
    self:createMeAction()
end

function AutoFightDlg:onPetSkillPanel()
    self:getControl("PetSettingPanel", Const.UIPanel):setVisible(true)
    self:getControl("PlayerSettingPanel", Const.UIPanel):setVisible(false)
    self:createPetAction()
end

function AutoFightDlg:onMeActSlecet()

end

function AutoFightDlg:setCallBcak(obj, fuc)
    self.fuc = nil
    self.obj = nil

    self.fuc = fuc
    self.obj = obj
end


function AutoFightDlg:getMeActionData(name)
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

function AutoFightDlg:resetCtrl(type)
    local backImage
    if type == "me" then
        self.playerListView:removeAllItems()
        backImage = self:getControl("BackImage", Const.UIImage, "PlayerSettingPanel")
    elseif type == kid then
        self.kidListView:removeAllItems()
        backImage = self:getControl("BackImage", Const.UIImage, "ChildSettingPanel")
    else
        self.petListView:removeAllItems()
        backImage = self:getControl("BackImage", Const.UIImage, "PetSettingPanel")
    end

    local size = backImage:getContentSize()
    size.height = self.initBKImageSize.height
    backImage:setContentSize(size)
end

function AutoFightDlg:resetQinMiWuJianCtrl()
    if not self.qinMiWuJianListView then
        return
    end

    self.qinMiWuJianListView:removeAllItems()
    local backImage = self:getControl("BackImage", Const.UIImage, "QinmiwujianPanel")
    local size = backImage:getContentSize()
    size.height = 248
    backImage:setContentSize(size)
end

function AutoFightDlg:onPetActionButtonButton(sender, eventType)
end

function AutoFightDlg:initPlayerSkill()
    self:resetCtrl("me")

    local function setContentSize()
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

    for i = 1, #SKILL_TYPE_LIST do
        local skills = self:getMeActionData(SKILL_TYPE_LIST[i])
        local skillListPanel = self.playerSkillListPanel[i]
        if next(skills) then
            local count = 4

            local isSpecialFight = FightMgr:getCombatMode() == COMBAT_MODE.COMBAT_MODE_TONGTIANTADING and GameMgr.inCombat
            if SkillMgr:isleardedFiveLadderSkill(SKILL.LADDER_5) or isSpecialFight then
                count = 5
                local width = skillListPanel:getContentSize().width
                self.playerListView:setContentSize(width, self.playerListView:getContentSize().height)
                local mainPanel = self:getControl("PlayerSettingPanel")
                mainPanel:setContentSize(width, mainPanel:getContentSize().height)
                local bkImage = self:getControl("BackImage", nil, mainPanel)
                bkImage:setContentSize(width, bkImage:getContentSize().height)
                self:refreshRootSize(cc.size(width, mainPanel:getContentSize().height))
                self:setCtrlContentSize("SkillListPanel5", width, nil, mainPanel)
            else
                local mainPanel = self:getControl("PlayerSettingPanel")
                self:refreshRootSize(cc.size(mainPanel:getContentSize().width, mainPanel:getContentSize().height))
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
                            local meMana
                            if Me:isInCombat() then
                                meMana = Me:queryInt("mana")
                            else
                                meMana = Me:getExtraRecoverMana()
                            end

                            if mySkill.skill_mana_cost > meMana
                                    or not SkillMgr:isArtifactSpSkillCanUse(mySkill.skill_name) then
                                self:setCtrlVisible("NoManaImage", true, skillPanel)
                                skillPanel:setTag(skills.skills[j].no)
                                self:blindLongPress("SkillPanel" .. j,
                                    function(dlg, sender, eventType)
                                        self:OneSecondLater(sender, eventType, 2, skills.skills[j].no, meConfig)
                                    end, function(dlg, sender, eventType)
                                        self:onSelectSkill(sender, eventType, skills.skills[j].no, meConfig)
                                    end, skillListPanel)
                            else
                                self:setCtrlVisible("NoManaImage", false, skillPanel)
                                skillPanel:setTag(skills.skills[j].no)
                                self:blindLongPress("SkillPanel" .. j,
                                    function(dlg, sender, eventType)
                                        self:OneSecondLater(sender, eventType, nil, skills.skills[j].no, meConfig)
                                    end, function(dlg, sender, eventType)
                                        self:onSelectSkill(sender, eventType, skills.skills[j].no, meConfig)
                                    end, skillListPanel)
                            end

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
            setContentSize()
        end
    end


    if Me:queryInt("level") < 100 or (FightMgr:getCombatMode() == COMBAT_MODE.COMBAT_MODE_TONGTIANTADING and GameMgr.inCombat) then
        self:setCtrlVisible("SkillListPanel5", false, "PlayerSettingPanel")
        setContentSize()
    end
end

-- 亲密无间复制的宠物技能
function AutoFightDlg:initQinMiWuJianSkill()
    if not self.qinMiWuJianListView then
        return
    end

    self:resetQinMiWuJianCtrl()

    for i = 1, 2 do
        local skills = self:getQinMiWuJianCopySkillData()
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
                            local meMana
                            if Me:isInCombat() then
                                meMana = Me:queryInt("mana")
                            else
                                meMana = Me:getExtraRecoverMana()
                            end

                            if mySkill.skill_mana_cost > meMana
                                  or not SkillMgr:isArtifactSpSkillCanUse(CHS[3001947]) then
                                  -- 自身法力或者法宝灵气不足，则无法使用亲密无间复制的技能
                                self:setCtrlVisible("NoManaImage", true, skillPanel)
                                skillPanel:setTag(skills[i][j].no)
                                self:blindLongPress("SkillPanel" .. j,
                                    function(dlg, sender, eventType)
                                        self:OneSecondLater(sender, eventType, 2, skills[i][j].no, meConfig)
                                    end, function(dlg, sender, eventType)
                                        self:onSelectSkill(sender, eventType, skills[i][j].no, meConfig)
                                    end, skillListPanel)
                            else
                                self:setCtrlVisible("NoManaImage", false, skillPanel)
                                skillPanel:setTag(skills[i][j].no)
                                self:blindLongPress("SkillPanel" .. j,
                                    function(dlg, sender, eventType)
                                        self:OneSecondLater(sender,eventType, nil, skills[i][j].no, meConfig)
                                    end, function(dlg, sender, eventType)
                                        self:onSelectSkill(sender, eventType, skills[i][j].no, meConfig)
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
function AutoFightDlg:getQinMiWuJianCopySkillData()
    local studySkills = SkillMgr:getQinMiWuJianStudySkills()

    local rawSkills = SkillMgr:getQinMiWuJianRawSkills(PetMgr:getFightPet())

    local retValue = {studySkills, rawSkills}
    return retValue
end

function AutoFightDlg:initKidSkill()
    self:resetCtrl("kid")

    local function setContentSize()
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
                                if mySkill.skill_mana_cost > self.curShowKid:getExtraRecoverMana() then
                                -- 普通技能缺少魔法
                                self:setCtrlVisible("NoManaImage", true, skillPanel)
                                skillPanel:setTag(skills.skills[j].no)
                                self:blindLongPress("SkillPanel" .. j,
                                    function(dlg, sender, eventType)
                                        self:OneSecondLater(sender, eventType, 2, skills.skills[j].no, kidConfig)
                                    end, function(dlg, sender, eventType)
                                        self:onSelectSkill(sender, eventType, skills.skills[j].no, kidConfig)
                                    end, skillListPanel)
                            else
                                self:setCtrlVisible("NoManaImage", false, skillPanel)
                                skillPanel:setTag(skills.skills[j].no)
                                self:blindLongPress("SkillPanel" .. j,
                                    function(dlg, sender, eventType)
                                        self:OneSecondLater(sender, eventType, nil, skills.skills[j].no, kidConfig)
                                    end, function(dlg, sender, eventType)
                                        self:onSelectSkill(sender, eventType, skills.skills[j].no, kidConfig)
                                    end, skillListPanel)
                            end

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
            self:getControl("ChildSettingPanel", Const.UIPanel)
            local size = self:getCtrlContentSize("ChildSettingPanel")
            self:refreshRootSize(size)
        else
            setContentSize()
        end
    end

    if Me:queryInt("level") < 100 then
        self:setCtrlVisible("SkillListPanel5", false, "ChildSettingPanel")
        setContentSize()
    end
end

function AutoFightDlg:initPetSkill()
    self:resetCtrl("pet")

    local function setContentSize()
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
                                if mySkill.skill_mana_cost > self.curShowPet:getExtraRecoverMana()
                                    or not SkillMgr:isPetDunWuSkillCanUse(self.curShowPet:getId(), mySkill)
                                    or not SkillMgr:isArtifactSpSkillCanUse(mySkill.skill_name) then
                                -- 普通技能缺少魔法，或者顿悟技能缺少怒气/魔法/灵气，或者法宝特殊技能缺少法宝灵气
                                self:setCtrlVisible("NoManaImage", true, skillPanel)
                                skillPanel:setTag(skills.skills[j].no)
                                self:blindLongPress("SkillPanel" .. j,
                                    function(dlg, sender, eventType)
                                        self:OneSecondLater(sender, eventType, 2, skills.skills[j].no, petConfig)
                                    end, function(dlg, sender, eventType)
                                        self:onSelectSkill(sender, eventType, skills.skills[j].no, petConfig)
                                    end, skillListPanel)
                            else
                                self:setCtrlVisible("NoManaImage", false, skillPanel)
                                skillPanel:setTag(skills.skills[j].no)
                                self:blindLongPress("SkillPanel" .. j,
                                    function(dlg, sender, eventType)
                                        self:OneSecondLater(sender, eventType, nil, skills.skills[j].no, petConfig)
                                    end, function(dlg, sender, eventType)
                                        self:onSelectSkill(sender, eventType, skills.skills[j].no, petConfig)
                                    end, skillListPanel)
                            end

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
            self:getControl("PetSettingPanel", Const.UIPanel)
            local size = self:getCtrlContentSize("PetSettingPanel")
            self:refreshRootSize(size)
        else
            setContentSize()
        end
    end

    if Me:queryInt("level") < 100 then
        self:setCtrlVisible("SkillListPanel5", false, "PetSettingPanel")
        setContentSize()
    end
end

function AutoFightDlg:refreshRootSize()
end

function AutoFightDlg:OneSecondLater(sender, eventType, type, skillNo, objType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local ob = Me
    if objType["name"] == "kid" then
        ob = HomeChildMgr:getFightKid()
    elseif objType["name"] == "pet" then
        ob = PetMgr:getFightPet()
    end

    SkillMgr:showSkillDescDlg(SkillMgr:getSkillName(skillNo), ob:getId(), objType["name"] == "pet", rect, type)
end

-- 人物战斗动作
function AutoFightDlg:createMeAction()
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

function AutoFightDlg:getKidActionData(name)
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

function AutoFightDlg:getPetActionData(name)
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

function AutoFightDlg:createPetAction()
    local actionList = {}
    self.curShowPet = PetMgr:getFightPet()

    if not self.curShowPet then   return end
    -- 物理攻击
    if self:getPetActionData("pyhAttact")["name"] ~= nil then
        table.insert(actionList, self:getPetActionData("pyhAttact"))
    end

    -- 法功技能
    if self:getPetActionData("magci")["name"] ~= nil then
        table.insert(actionList, self:getPetActionData("magci"))
    end

    -- 天生技能
    if self:getPetActionData("raw")["name"] ~= nil then
        table.insert(actionList, self:getPetActionData("raw"))
    end

    -- 研发技能
    if self:getPetActionData("develop")["name"] ~= nil then
        table.insert(actionList, self:getPetActionData("develop"))
    end

    self:createSkillSelectLayout(actionList, "PetSettingPanel", petConfig)
end

-- actionName 动作名称
-- skills 技能队列
--
function AutoFightDlg:createSkillSelectLayout(actionList, name, object)
    for k,v in pairs(skillPanel) do
        local panel = self:getControl(k, Const.UIPanel)
        local skillListPanel = self:getControl("SkillListPanel", Const.UIPanel, panel)
        skillListPanel:removeAllChildren()
    end

    local settingPanel = self:getControl(name, Const.UIPanel)
    local skillPanel = self:getControl("AllSkillPanel", Const.UIPanel, settingPanel)
    local skillPanelMaxHeight = 0
    local posintioX = 240

    for i = 1,#actionList do
        local actionData = actionList[i]
        local panel = self:getControl(actionData["name"], Const.UIPanel, skillPanel)
        local skillListPanel = self:getControl("SkillListPanel", Const.UIPanel, panel)
        local number = #actionData["skills"]
        local showNameList = SKILL_SHOW_NAME[actionData["name"]]

        for j = 1, number do
            local showName = actionData["skills"][j]["name"]
            if showNameList then
                showName = showNameList[j] or showName
            end
            local cell = self.skillCell:clone()
            cell:setTag(actionData["skills"][j]["no"])
            self:createCell(cell, actionData["skills"][j], object, showName)
            cell:setAnchorPoint(0, 0)
            local posx = (self.skillCell:getContentSize().width + COLUMN_SAPCE) * (j - 1)
            cell:setPosition(posx, 0)
            skillListPanel:addChild(cell)
        end

    end

    settingPanel:requestDoLayout()
end

function AutoFightDlg:createCell(cell, skillData, object, showName)
    local image = self:getControl("Image", Const.UIImage, cell)
    local path
    if PHYSIC_CONFIG[skillData.no] then
        path = ResMgr:getSkillIconPath(skillData["icon"])
    else
        path = SkillMgr:getSkillIconPath(skillData.no)
    end
    image:loadTexture(path)
    self:setItemImageSize("Image", cell)

    self:setLabelText("SkillNameLabel", showName, cell)

    --使用NumImg（艺术字）显示
    self:setNumImgForPanel(cell, ART_FONT_COLOR.NORMAL_TEXT,
        skillData.level, false, LOCATE_POSITION.LEFT_TOP,
        19)

    local function OneSecondLaterFunc(sender, type)
        local rect = self:getBoundingBoxInWorldSpace(sender)
        if not PHYSIC_CONFIG[skillData.no] then
            if object.name == "me" then
                SkillMgr:showSkillDescDlg(SkillMgr:getSkillName(skillData.no), Me:getId(), false, rect)
            elseif object.name == "pet" then
                local  pet = PetMgr:getFightPet()
                local skillCard = DlgMgr:openDlg("SkillFloatingFrameDlg")
                skillCard:setInfo(SkillMgr:getSkillName(skillData.no), pet:queryBasicInt("id"), true, rect)
               -- SkillMgr:showSkillDescDlg(SkillMgr:getSkillName(skillData.no), 0, true, rect)
            end
        else
            local dlg = DlgMgr:openDlg("SkillFloatingFrameDlg")
            dlg:setSKillByName(PHYSIC_CONFIG[skillData.no], rect)
        end
    end

    local function onclick(sender, type)
        local autoSkillType, autoSkiillParam

        if skillData.no == DEFENCE_NO then
            autoSkillType = FIGHT_ACTION.DEFENSE
            autoSkiillParam = 0
        elseif skillData.no == PHYATTACT_NO then
            autoSkillType = FIGHT_ACTION.PHYSICAL_ATTACK
            autoSkiillParam = FIGHT_ACTION.PHYSICAL_ATTACK
        elseif skillData.no == LIFE_NO then
            if InventoryMgr:isHaveLifeItem() then
                autoSkillType = FIGHT_ACTION.APPLY_ITEM
                autoSkiillParam = 0
            else
                gf:ShowSmallTips(CHS[3002287])
                return
            end
        elseif skillData.no == MANA_NO then
            if InventoryMgr:isHaveManaItem() then
                autoSkillType = FIGHT_ACTION.APPLY_ITEM
                autoSkiillParam = 1
            else
                gf:ShowSmallTips(CHS[3002288])
                return
            end
        elseif SkillMgr:isArtifactSpSkillByNo(skillData.no) then
            autoSkillType = FIGHT_ACTION.ACTION_USE_ARTIFACT_EXTRA_SKILL
            autoSkiillParam = skillData.no
        else
            autoSkillType = FIGHT_ACTION.CAST_MAGIC
            autoSkiillParam = skillData.no
        end

        local skillName = SkillMgr:getSkillName(skillData.no)
        if object["name"] == "me" then
            local isCanSetSkill = self:checkCanSetSkill(skillData.no)
            if not isCanSetSkill then
                return
            end

            -- 本地保存
            AutoFightMgr:setMeAutoSkill(autoSkillType, autoSkiillParam)
            AutoFightMgr:setLastMeAction(skillData.no)

            -- 发送给服务端
            AutoFightMgr:setMeAutoFightAction(autoSkillType, autoSkiillParam)
            self.fuc(self.obj, skillData.no, object.name)
        elseif object["name"] == "pet" then
            local  pet = PetMgr:getFightPet()
            if not self:isExitFightPet() then
                gf:ShowSmallTips(CHS[3002285])
                DlgMgr:closeDlg(self.name)
                return
            end

            if self.curShowPet:getId() == pet:getId()then
                -- 颠倒乾坤技能无法进行自动战斗
                if skillName == CHS[3001942] then
                    gf:ShowSmallTips(CHS[7000323])
                    return
                end

                -- 舍身取义无法进行自动战斗
                if skillName == CHS[3004250] then
                    gf:ShowSmallTips(CHS[5410228])
                    return
                end


                -- 本地保存
                AutoFightMgr:setPetAutoSkill(autoSkillType, autoSkiillParam)
                AutoFightMgr:setLastPetAction(skillData.no)

                -- 发给服务端
                AutoFightMgr:setPetAutoFightAction(autoSkillType, autoSkiillParam)
                self.fuc(self.obj, skillData.no, object.name)
            else
                gf:ShowSmallTips(CHS[3002289])
            end
        end

        DlgMgr:closeDlg(self.name)
    end

    local function cb(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            local callFunc = cc.CallFunc:create(function()
                OneSecondLaterFunc(sender, eventType)
                self.root:stopAction(self.longPress)
                self.longPress = nil
            end)

            self.longPress = cc.Sequence:create(cc.DelayTime:create(GameMgr:getLongPressTime()),callFunc)
            self.root:runAction(self.longPress)
        elseif eventType == ccui.TouchEventType.ended then
            if self.longPress ~= nil then
                self.root:stopAction(self.longPress)
                self.longPress = nil
                onclick(sender, eventType)
            end
        end
    end

    cell:addTouchEventListener(cb)
end

function AutoFightDlg:isExitFightPet()
    local pet = PetMgr:getFightPet()
    if not pet or not FightMgr:getObjectById(pet:getId())then
        return false
    end

    return true
end

function AutoFightDlg:isExitFightKid()
    local kid = HomeChildMgr:getFightKid()
    if not kid or not FightMgr:getObjectById(kid:getId())then
        return false
    end

    return true
end

function AutoFightDlg:onSelectSkill(sender, type, skillNo, object)
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

        -- 本地保存
        AutoFightMgr:setMeAutoSkill(autoSkillType, autoSkiillParam)
        AutoFightMgr:setLastMeAction(skillNo)

        -- 发送给服务端
        AutoFightMgr:setMeAutoFightAction(autoSkillType, autoSkiillParam)
        DlgMgr:sendMsg("AutoFightSettingDlg", "setSecondSkillVisible")
        self.fuc(self.obj, skillNo, object.name)
    elseif object["name"] == "kid" then
        local kid = HomeChildMgr:getFightKid()
        if not self:isExitFightKid() then
            gf:ShowSmallTips(CHS[7120208])
            DlgMgr:closeDlg(self.name)
            return
        end

        if self.curShowKid:getId() == kid:getId()then
            -- 本地保存
            AutoFightMgr:setPetAutoSkill(autoSkillType, autoSkiillParam)
            AutoFightMgr:setLastPetAction(skillNo)

            -- 发给服务端
            AutoFightMgr:setPetAutoFightAction(autoSkillType, autoSkiillParam)
            DlgMgr:sendMsg("AutoFightSettingDlg", "setSecondSkillVisible")
            self.fuc(self.obj, skillNo, object.name)
        else
            gf:ShowSmallTips(CHS[3002289])
        end
    elseif object["name"] == "pet" then
        local  pet = PetMgr:getFightPet()
        if not self:isExitFightPet() then
            gf:ShowSmallTips(CHS[3002285])
            DlgMgr:closeDlg(self.name)
            return
        end

        if self.curShowPet:getId() == pet:getId()then
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

            -- 本地保存
            AutoFightMgr:setPetAutoSkill(autoSkillType, autoSkiillParam)
            AutoFightMgr:setLastPetAction(skillNo)

            -- 发给服务端
            AutoFightMgr:setPetAutoFightAction(autoSkillType, autoSkiillParam)
            DlgMgr:sendMsg("AutoFightSettingDlg", "setSecondSkillVisible")
            self.fuc(self.obj, skillNo, object.name)
        else
            gf:ShowSmallTips(CHS[3002289])
        end
    end

    DlgMgr:closeDlg(self.name)
end

function AutoFightDlg:checkCanSetSkill(skillNo)
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

function AutoFightDlg:setSelectInfo(skillName, cell)
    local skillNameLabel = self:getControl("SkillNameLabel", Const.UILabel, cell)
    skillNameLabel:setString(skillName)
    local skilClassLabel = self:getControl("SkillTypeLabel", Const.UILabel, cell)
    skilClassLabel:setString(SkillMgr:getSkillDesc(skillName)["type"])
    self:getControl("SkillTypeLabel", Const.UILabel, cell):setVisible(false)

    self:getControl("SkillNameLabel", Const.UILabel, cell):setVisible(true)
    self:getControl("SkillTypeLabel", Const.UILabel, cell):setVisible(true)
    self:getControl("ActionSkillLabel", Const.UILabel, cell):setVisible(false)
end

function AutoFightDlg:setLastSelectInfo(object)
    if object.lastSender and tolua.cast(object.lastSender, "ccui.Layout"):getParent():getName() == IS_SKILL then
        self:getControl("SkillNameLabel", Const.UILabel, object.lastSender:getParent()):setVisible(false)
        self:getControl("SkillTypeLabel", Const.UILabel, object.lastSender:getParent()):setVisible(false)
        self:getControl("ActionSkillLabel", Const.UILabel, object.lastSender:getParent()):setVisible(true)
    end
end

function AutoFightDlg:setMeAutoSkill(meAutoSkillType, meAutoSkiillParam)
    self.meAutoSkillType = meAutoSkillType
    self.meAutoSkiillParam = meAutoSkiillParam
end

function AutoFightDlg:setPetAutoSkill(petAutoSkillType, petAutoSkiillParam)
    self.petAutoSkiillParam = petAutoSkiillParam
    self.petAutoSkillType = petAutoSkillType
end

function AutoFightDlg:cleanup()
    self.meAutoSkillType = nil
    self.meAutoSkiillParam = nil
    self.meActionTag = nil
    self.petAutoSkiillParam  = nil
    self.meAutoSkiillParam = nil
    self.petActionTag = nil

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

return AutoFightDlg
