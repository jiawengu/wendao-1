-- FightPetSkillDlg.lua
-- Created by cheny Dec/2/2014
-- 战斗中宠物技能选择界面

local Bitset = require('core/Bitset')
local FightPetSkillDlg = Singleton("FightPetSkillDlg", Dialog)

local SKILL_LIST_PANEL_HEIGHT = 82
local MARGIN_ITEM = 6

function FightPetSkillDlg:init()
    self:setFullScreen()
    self:bindListener("ReturnButton", self.onReturnButton)
    self.listView = self:getControl("MainListView", Const.UIListView)
    self.skillListPanel = {
        self:getControl("SkillListPanel1", Const.UIPanel),
        self:getControl("SkillListPanel2", Const.UIPanel),
        self:getControl("SkillListPanel3", Const.UIPanel),
        self:getControl("SkillListPanel4", Const.UIPanel),
    }

    for _, v in pairs(self.skillListPanel) do
        v:retain()
        v:removeFromParent()
    end

    -- 颠倒乾坤相关控件
    self.ddqkListView = self:getControl("MenuListView", nil, "DiandqkPanel")
    self.btnCell = self:getControl("MenuButton1", nil, "DiandqkPanel")
    self.btnCell:retain()
    self.btnCell:removeFromParent()

    -- 颠倒乾坤的目标/目标属性/持续回合数
    self.ddqkTargetId = nil
    self.ddqkTargetAttrib = nil
    self.ddqkRound = nil
    self:initSkill()

    self:hookMsg("MSG_VIEW_DDQK_ATTRIB")
end

function FightPetSkillDlg:onReturnButton(sender, eventType)
    self:resetDianDaoQianKunState()
    self:setVisible(false)
    local dlg = DlgMgr:showDlg("FightPetMenuDlg", true)
    if dlg then
        dlg:updateFastSkillButton()
    end
end

function FightPetSkillDlg:onSelectSkillListView(sender, eventType)
    local skillNo = self:getListViewSelectedItemTag(sender)
    Me.op = ME_OP.FIGHT_SKILL
    Me:setBasic('sel_skill_no', skillNo)

    self:setVisible(false)

    local dlg = DlgMgr:openDlg('FightTargetChoseDlg')
    dlg:setTips(SkillMgr:getSkillName(skillNo))
end

-- 选中了某个技能
function FightPetSkillDlg:onSelectSkill(sender, eventType)
    local skillNo = sender:getTag()
    local skillName = SkillMgr:getSkillName(skillNo)
    local pet = PetMgr:getFightPet()

    -- 如果是顿悟技能是否可以使用，并给出相应提示
    if SkillMgr:isPetDunWuSkill(pet:queryBasicInt("id"), skillName) then
        local skillInfo = SkillMgr:getSkill(pet:queryBasicInt("id"), skillNo)
        if skillInfo.skill_nimbus < SkillMgr.DUNWU_SKILL_COST_NIMBUS then
            -- 当前技能灵气不足
            gf:ShowSmallTips(CHS[7000257])
            return
        end

        if SkillMgr:getPetSkillType(skillName) == SkillMgr.PET_SKILL_TYPE.JINJIE
                and pet:queryBasicInt("pet_anger") < Formula:getCostAnger(skillInfo.skill_level) then
            -- 怒气不足
            gf:ShowSmallTips(CHS[7000258])
            return
        end
    end

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

    -- 选中只能对宠物自身释放的技能(法力护盾、移花接木、养精蓄锐)
    if SkillMgr:canUseSkillOnlyToSelf(skillNo, "pet") then
        local curRoundLeftTime = FightMgr:getRoundLeftTime()
        self.confirmDlg = gf:confirm(string.format(CHS[7150020], skillName), function ()
            -- 玩家确认后直接选择宠物自身
            Me.op = ME_OP.FIGHT_SKILL
            Me:setBasic('sel_skill_no', skillNo)
            self:setVisible(false)

            FightMgr:getObjectById(pet:getId()):onSelectChar()
        end, function()
            if self.confirmDlg and self.confirmDlg.hourglassTime < 1 then
                -- 倒计时确认框自动取消时，不需要重新显示技能选择界面
                self:setVisible(false)
                return
            end

            Me.op = ME_OP.FIGHT_ATTACK
            Me:setBasic('sel_skill_no', 0)
            self:setVisible(true)
        end, nil, curRoundLeftTime - 1)

        if self.confirmDlg then
            self.confirmDlg:setCombatOpenType()
        end

        return
    end

    Me.op = ME_OP.FIGHT_SKILL
    Me:setBasic('sel_skill_no', skillNo)

    self:setVisible(false)

    local dlg = DlgMgr:openDlg('FightTargetChoseDlg')
    local cmdDesc = SkillMgr:getSkillCmdDesc(pet:getId(), skillNo)
    dlg:setTips(SkillMgr:getSkillName(skillNo), cmdDesc)
end

function FightPetSkillDlg:openDianDaoQianKunPanel(id)
    self:setVisible(true)
    self:setCtrlVisible("MainPanel", false)
    self:setCtrlVisible("DiandqkPanel", true)
    self.ddqkTargetId = id
    self:initDDQKAttribSelect()
end

-- 更新滚动条
function FightPetSkillDlg:updateSlider(sender, eventType)

    if ccui.ScrollviewEventType.scrolling == eventType then
        -- 获取控件
        local listViewCtrl = sender

        local listInnerContent = listViewCtrl:getInnerContainer()
        local innerSize = listInnerContent:getContentSize()
        local listViewSize = listViewCtrl:getContentSize()

        -- 计算滚动的百分比
        local totalHeight = innerSize.height - listViewSize.height

        local innerPosY = listInnerContent:getPositionY()
        local persent = 1 - (-innerPosY) / totalHeight
        persent = math.floor(persent * 100)
        if totalHeight > MARGIN_ITEM then
            if innerPosY <= - MARGIN_ITEM  then
                self:addMagic("MagicPanel", ResMgr:getMagicDownIcon())
            else
                if not self.first then
                    self:removeMagic("MagicPanel", ResMgr:getMagicDownIcon())
                end

                self.first = false
            end
        end
    end
end

-- 属性选择
function FightPetSkillDlg:initDDQKAttribSelect()
    self.ddqkListView:removeAllChildren()
    self:removeMagic("MagicPanel", ResMgr:getMagicDownIcon())
    local data = SkillMgr:getDDQKAttrib(self.ddqkTargetId)

    -- 提示语
    local tips
    local name = ""
    local obj = FightMgr:getObjectById(self.ddqkTargetId)
    if obj then
        name = obj:queryBasic("name")
    end

    tips = string.format(CHS[7000319], name, data["maxAttrib"]["name"], data["maxAttrib"]["num"])
    self:setColorText(tips, "TextLabel", "DiandqkPanel")

    -- 按钮列表
    for i = 1, #data do
        local btn = self.btnCell:clone()
        btn:setTag(i)
        btn:setTitleText(string.format(CHS[7000321], data[i].name, data[i].num))
        btn:setName(data[i].name)

        local function btnTouch(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local name = sender:getName()
                self.ddqkTargetAttrib = name
                self:initDDQKRoundSelect()
            end
        end

        btn:addTouchEventListener(btnTouch)
        self.ddqkListView:pushBackCustomItem(btn)
    end
end

-- 回合数选择
function FightPetSkillDlg:initDDQKRoundSelect()
    self.ddqkListView:removeAllChildren()
    self.ddqkListView:addScrollViewEventListener(function(sender, eventType) self:updateSlider(sender, eventType) end)
    self.first = true

    local maxRound = SkillMgr:getDDQKMaxRound(self.ddqkTargetId)
    if maxRound and maxRound > 3 then
        self:addMagic("MagicPanel", ResMgr:getMagicDownIcon())
    end

    -- 提示语
    local tips = string.format(CHS[7000320], maxRound)
    self:setColorText(tips, "TextLabel", "DiandqkPanel")

    -- 按钮列表
    for i = 1, maxRound do
        local btn = self.btnCell:clone()
        btn:setTag(i)
        btn:setTitleText(string.format(CHS[7000322], i))
        local function btnTouch(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local round = sender:getTag()
                self.ddqkRound = round

                -- 使用 颠倒乾坤技能
                if not self.ddqkTargetId then
                    return
                end

                if Me:queryInt("diandqk_frozen_round") >= FightMgr:getCurRound() then
                    -- 颠倒乾坤处于冷却中
                    gf:ShowSmallTips(CHS[7000328])
                    return
                end

                local skillNo = SkillMgr:getskillAttribByName(CHS[3001942]).skill_no
                local ddqkMaxAttrib = SkillMgr:getDDQKAttrib(self.ddqkTargetId)["maxAttrib"]["name"]
                FightMgr:setFastSkill(skillNo, true)
                gf:sendFightCmd(Me:queryBasicInt('c_attacking_id'), self.ddqkTargetId, FIGHT_ACTION.ACTION_USE_ARTIFACT_EXTRA_SKILL, skillNo,
                                ddqkMaxAttrib, self.ddqkTargetAttrib, tostring(self.ddqkRound))
                FightMgr:changeMeActionFinished()
                self:resetDianDaoQianKunState()
                self:close()
            end
        end
        btn:addTouchEventListener(btnTouch)
        self.ddqkListView:pushBackCustomItem(btn)
    end
end

-- 重置颠倒乾坤状态
function FightPetSkillDlg:resetDianDaoQianKunState()
    self:setCtrlVisible("MainPanel", true)
    self:setCtrlVisible("DiandqkPanel", false)
    self.ddqkTargetId = nil
    self.ddqkTargetAttrib = nil
    self.ddqkRound = nil
end

-- 设置技能列表
function FightPetSkillDlg:setSkillList(ctrlName, skills, itemPanel)
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

function FightPetSkillDlg:getPetSkillData()
    local petId = Me:queryBasicInt('c_attacking_id')
    local partySkills = SkillMgr:getSkillNoAndLadder(petId, SKILL.SUBCLASS_E, SKILL.CLASS_PET);
    SkillMgr:sortStudySkill(partySkills)
    for i = 1, #partySkills do
        -- 临时设置为0，因为在后续中用不到
        partySkills[i].ladder = 0
    end

    local innerSkills = SkillMgr:getPetRawSkillNoAndLadder(petId)
    local dunWuSkills = SkillMgr:getPetDunWuSkillsInfo(petId, true) -- 宠物顿悟技能，放在天生技能后面
    for i = 1, #dunWuSkills do
        table.insert(innerSkills, dunWuSkills[i])
    end

    for i = 1, #innerSkills do
        -- 临时设置为0，因为在后续中用不到
        innerSkills[i].ladder = 0
    end

    local magicSkills = SkillMgr:getSkillNoAndLadder(petId, SKILL.SUBCLASS_B)

    table.sort(magicSkills, function(l, r)
        if l.ladder < r.ladder then return true end
    end)

    -- 宠物物攻技能（ 目前只包含颠倒乾坤）
    local phySkills = SkillMgr:getPetPhySkills(petId)

    local retValue = {partySkills, innerSkills, magicSkills, phySkills}
    return retValue
end

function FightPetSkillDlg:resetCtrl()
    self.listView:removeAllItems()
    local backImage = self:getControl("BackImage", Const.UIImage)
    local size = backImage:getContentSize()
    size.height = 430
    backImage:setContentSize(size)
end

function FightPetSkillDlg:initSkill()
    self:resetDianDaoQianKunState()
    self:resetCtrl()
    for i = 1, 4 do
        local skills = self:getPetSkillData()
        local skillListPanel = self.skillListPanel[i]
        if next(skills[i]) then
            for j = 1, 5 do
                local skillPanel = self:getControl("SkillPanel" .. j, Const.UIPanel, skillListPanel)
                if skills[i][j] then
                    local iconPath = SkillMgr:getSkillIconPath(skills[i][j].no)
                    self:setImage("SkillImage", iconPath, skillPanel)
                    self:setItemImageSize("SkillImage", skillPanel)
                    skillPanel:setVisible(true)
                    if next(skills) and skills[i][j].ladder then
                        local petId = Me:queryBasicInt('c_attacking_id')
                        local mySkill = SkillMgr:getSkill(petId, skills[i][j].no)
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
                        local pet = PetMgr:getPetById(petId)
                        if mySkill and pet then
                            if mySkill.skill_mana_cost > pet:queryInt("mana")
                                    or not SkillMgr:isPetDunWuSkillCanUse(petId, mySkill)
                                    or not SkillMgr:isArtifactSpSkillCanUse(mySkill.skill_name) then
                                -- 普通技能缺少魔法；顿悟技能缺少怒气/魔法/灵气；法宝特殊技能（目前包括颠倒乾坤）缺少法宝灵气
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
                            if SkillMgr:isPetDunWuSkill(petId, skills[i][j].name) then
                                SkillMgr:addDunWuSkillImage(self:getControl("SkillImage", nil, skillPanel))
                            end

                            -- 如果是法宝特殊技能，要加上法宝特殊技能标识
                            if SkillMgr:isArtifactSpSkill(skills[i][j].name) then
                               SkillMgr:addArtifactSpSkillImage(self:getControl("SkillImage", nil, skillPanel))
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
            self.listView:pushBackCustomItem(self.skillListPanel[i])
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

function FightPetSkillDlg:cleanup()
    if self.skillListPanel then
        for k, v in pairs(self.skillListPanel) do
            if v then
                self.skillListPanel[k]:release()
                self.skillListPanel[k] = nil
            end
        end
        self.skillListPanel = nil
    end

    self:releaseCloneCtrl("btnCell")
end

function FightPetSkillDlg:OneSecondLater(sender, eventType, type)
    local skillNo = sender:getTag()
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local pet = PetMgr:getFightPet()
    SkillMgr:showSkillDescDlg(SkillMgr:getSkillName(skillNo), pet:getId(), true, rect, type)
end

function FightPetSkillDlg:MSG_VIEW_DDQK_ATTRIB(data)
    self:openDianDaoQianKunPanel(data.id)
end

return FightPetSkillDlg
