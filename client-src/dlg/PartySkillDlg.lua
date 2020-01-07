-- PartySkillDlg.lua
-- Created by songcw May/4/2015
-- 帮派技能界面

local PartySkillDlg = Singleton("PartySkillDlg", Dialog)

local SELECT_TAG = 766                 -- ListView选择TAG

function PartySkillDlg:init()
    self:bindListener("TypeButton", self.onTypeButton)
    self:bindListener("AllSkillButton", self.onSkillTypeButton)
    self:bindListener("RawSkillButton", self.onSkillTypeButton)
    self:bindListener("DevelopSkillButton", self.onSkillTypeButton)
    self:bindListener("GoToLearnButton", self.onGoToLearnButton)

    self:bindListener("DevelopButton", self.onDevelopButton)
    self:bindListener("BatchDevelopButton", self.onBatchDevelopButton)
    self:bindListener("StudyButton", self.onStudyButton)
    self:bindListViewListener("ShillListView", self.onSelectShillListView)

    self:bindListener("BKPanel", self.onBKPanel)

    -- 默认列表技能类型          类型一共有   "所有类型"  "天生技能" "研发技能"
    self.skillType = CHS[3003278]
    self.curSkill = nil
    -- 设置标题
    if Me:queryBasic("party/name") ~= "" then
        self:setLabelText("TitleLabel_1", Me:queryBasic("party/name"))
        self:setLabelText("TitleLabel_2", Me:queryBasic("party/name"))
    end
    -- 克隆帮派技能panel
    local skillPanel = self:getControl("SkillPanel", Const.UIPanel)
    self.skillPanel = skillPanel:clone()
    self.skillPanel:retain()
    self:getControl("SkillPanel"):removeFromParent()

    -- petList单个panel
    self.petUnitPanel = self:getControl("PetPanel", Const.UIPanel)
    self.petUnitPanel:retain()
    self.petUnitPanel:removeFromParent()

    -- 添加监听
    self:addSliderMoveFun("DevelopSlider", self.sliderMove)

    self.isUpdateSlider = false
    self.slider = self:getControl("DevelopSlider", Const.UISlider)

    self:getPartyInfo()


end

function PartySkillDlg:cleanup()
    self:releaseCloneCtrl("skillPanel")
    self:releaseCloneCtrl("petUnitPanel")
end

function PartySkillDlg:getPartyInfo()
    self.partyInfo = PartyMgr:getPartyInfo()
    if self.partyInfo == nil then
        PartyMgr:queryPartyInfo()
        return
    end

    -- 显示技能listview
    self:setSkillList()
end

function PartySkillDlg:setSkillList(isUpdate)
    if not self.partyInfo then return end

    local displaySkill = PartyMgr:getPartySkillByType(self.skillType)
    if isUpdate then
        local skillListView = self:getControl("ShillListView")
        local items = skillListView:getItems()
        for i, panel in pairs(items) do
            local skillName = self:getLabelText("NameLabel", panel)
            local skill = self:getSkillByName(skillName, self.partyInfo) or {no = 0, name = skillName, level = 0, currentScore = 0, levelupScore = 0}

            self:setLabelText("LevelLabel", string.format("%d/%d", skill.level, PartyMgr:getPartyLevelMax()), panel)
            self:setLabelText("DevelopProcessLabel_1", skill.currentScore, panel)
            self:setLabelText("DevelopProcessLabel_3", skill.levelupScore, panel)
            self:setProgressBar("ProgressBar", skill.currentScore, skill.levelupScore, panel)
            panel.curSkill = skill
            if self.curSkill.name == skill.name then
                self:chooseSkill(panel)
            end
        end
    else
        local skillListView = self:resetListView("ShillListView")
        -- 按PARTY_SKILL表中技能顺序排列
        for index = 1, #displaySkill do
            local skillName = displaySkill[index]
        --for index, skillName in pairs(displaySkill) do
            local skillPanel = self.skillPanel:clone()
            local skill = self:getSkillByName(skillName, self.partyInfo) or {no = 0, name = skillName, level = 0, currentScore = 0, levelupScore = 0}
            local skillIconPath = SkillMgr:getSkillIconPath(skill.no) or ""
            self:setImage("Image", skillIconPath, skillPanel)
            self:setItemImageSize("Image", skillPanel)
            self:setLabelText("NameLabel", skill.name, skillPanel)
            self:setLabelText("LevelLabel", string.format("%d/%d", skill.level, PartyMgr:getPartyLevelMax()), skillPanel)
            self:setLabelText("DevelopProcessLabel_1", skill.currentScore, skillPanel)
            self:setLabelText("DevelopProcessLabel_3", skill.levelupScore, skillPanel)
            self:setProgressBar("ProgressBar", skill.currentScore, skill.levelupScore, skillPanel)
            skillPanel.curSkill = skill
            self:bindTouchEndEventListener(skillPanel, self.chooseSkill)
            skillListView:pushBackCustomItem(skillPanel)
        end

        self:chooseSkill()
    end
end

function PartySkillDlg:chooseSkill(sender, eventType)
    self:onBKPanel()
    local skillListView = self:getControl("ShillListView")
    -- 找上一个选择项，取消选择效果
    local lastPanel = skillListView:getChildByTag(SELECT_TAG)
    if lastPanel ~= nil then
        lastPanel:setTag(0)
        self:setCtrlVisible("ChosenEffectImage", false, lastPanel)
    end

    -- 设置当前选择项的选择效果
    sender = sender or skillListView:getItem(0)
    sender:setTag(SELECT_TAG)
    self:setCtrlVisible("ChosenEffectImage", true, sender)


    -- 技能描述
    self.curSkill = sender.curSkill
    self:setSliderPercent("DevelopSlider", self.curSkill.currentScore / self.curSkill.levelupScore * 100)
    self:setSkillDesc(self.curSkill.name)

    -- 研发
    self:setStudy(self.curSkill.currentScore)

end

function PartySkillDlg:getSkillByName(name, party)
    if not party then return end

    for index, skill in pairs(party.skill) do
        if skill.name == name then return skill end
    end
end

--
function PartySkillDlg:getSkillTypeBySkillName(skillName)
    local studySkill = PartyMgr:getPartySkillByType(CHS[3003279])
    for i = 1, #studySkill do
        if studySkill[i] == skillName then return CHS[3003279] end
    end

    return CHS[3003280]
end

function PartySkillDlg:setSkillDesc(skillName)
    local skillPanel = self:getControl("SkillInfoPanel")
    local skill = self:getSkillByName(skillName, self.partyInfo) or {no = 0, name = skillName, level = 0, currentScore = 0, levelupScore = 0}
    local skillIconPath = SkillMgr:getSkillIconPath(skill.no) or ""
    self:setImage("Image", skillIconPath, skillPanel)
    self:setItemImageSize("Image", skillPanel)
    if self.skillType ~= CHS[3003278] then
        self:setLabelText("SkillTypeValueLabel", self.skillType)
    else
        local studySkill = PartyMgr:getPartySkillByType(CHS[3003279])
        local isStudy = false
        for i = 1, #studySkill do
            if studySkill[i] == skillName then isStudy = true end
        end

        if isStudy then
            self:setLabelText("SkillTypeValueLabel", CHS[3003279])
        else
            self:setLabelText("SkillTypeValueLabel", CHS[3003280])
        end
    end
    self:setLabelText("NameLabel", skillName, skillPanel)
    self:setLabelText("DescLabel", SkillMgr:getSkillDesc(skillName).pet_desc, skillPanel)

    self:setLabelText("LevelLabel", string.format(CHS[3003281], skill.level), skillPanel)
    self:setProgressBar("ProgressBar", skill.currentScore, skill.levelupScore, skillPanel)
    self:setLabelText("DevelopProcessLabel_1", skill.currentScore, skillPanel)
    self:setLabelText("DevelopProcessLabel_3", skill.levelupScore, skillPanel)
    self:setLabelText("DevelopProcessLabel_4", "(" .. math.floor(skill.currentScore/skill.levelupScore * 100) .. "%)", skillPanel)

    local constCashStr = gf:getMoneyDesc(PartySkillDlg:getCanUseMoneyByLevel(), true)
    self:setLabelText("OwnMoneyValueLabel", constCashStr, skillPanel)

    -- 可用建设度
    local canUseConstru = self:getCanUseConstuByLevel()
    local construStr = gf:getMoneyDesc(canUseConstru, true)
    self:setLabelText("OwnConstructionValueLabel", construStr, skillPanel)

end

-- 获取帮派可用资金
function PartySkillDlg:getCanUseMoneyByLevel()
    if not self.partyInfo then return 0 end

    local function constMoneyByLevel(level)
    	if level == 1 or level == 2 then
    	   return 500000
    	elseif level == 3 then
    	   return 1000000
    	elseif level == 4 then
    	   return 3000000
    	end
    end

    local canUse = self.partyInfo.money - constMoneyByLevel(self.partyInfo.partyLevel)
    if canUse < 0 then return 0 end

    return canUse
end

-- 获取帮派可用建设度
function PartySkillDlg:getCanUseConstuByLevel()
    if not self.partyInfo then return 0 end

    local function constConstuByLevel(level)
        if level == 1 or level == 2 then
            return 100000
        elseif level == 3 then
            return 500000
        elseif level == 4 then
            return 1000000
        end
    end

    local canUse = self.partyInfo.construct - constConstuByLevel(self.partyInfo.partyLevel)
    if canUse < 0 then return 0 end

    return canUse
end

function PartySkillDlg:setStudy(studyPoint)
    studyPoint = math.floor(studyPoint)
    local studyCount = studyPoint - self.curSkill.currentScore
    if studyCount < 0 then studyCount = 0 end

    self:setLabelText("ProcessValueLabel", studyPoint .. "/" .. self.curSkill.levelupScore)

    local studyPoint = math.floor(self:getSliderPercent("DevelopSlider") * self.curSkill.levelupScore / 100 - self.curSkill.currentScore)
    if studyPoint < 0 then studyPoint = 0 end
    local construStr = gf:getMoneyDesc(self:getCanUseConstuByLevel() - studyPoint, true)
    if self:getCanUseConstuByLevel() > studyPoint then
        self:setLabelText("OwnConstructionValueLabel", construStr, nil, COLOR3.TEXT_DEFAULT)
    else
        self:setLabelText("OwnConstructionValueLabel", construStr, nil, COLOR3.RED)
    end

    local costMoney = self:getCanUseMoneyByLevel() - studyPoint * 74
    local costMoneyStr = gf:getMoneyDesc(costMoney, true)
    if costMoney > 0 then
        self:setLabelText("OwnMoneyValueLabel", costMoneyStr, nil, COLOR3.TEXT_DEFAULT)
    else
        self:setLabelText("OwnMoneyValueLabel", costMoneyStr, nil, COLOR3.RED)
    end
end

--
function PartySkillDlg:sliderMove(sender, eventType)
    --[[
    local point = sender:getPercent() * self.curSkill.levelupScore / 100
    if point < self.curSkill.currentScore then
        self:setSliderPercent("Slider", self.curSkill.currentScore / self.curSkill.levelupScore * 100)
        self.isUpdateSlider = false
        --self:setStudy(self.curSkill.currentScore)
        return
    end

    self:setStudy(point)

    --]]

    self.isUpdateSlider = true

end

function PartySkillDlg:onUpdate()
    if self.isUpdateSlider then
        self.isUpdateSlider = false
        local point = math.floor(self.slider:getPercent() * self.curSkill.levelupScore / 100)
   --     local point = self.slider:getPercent() * self.curSkill.levelupScore / 100
        if point < self.curSkill.currentScore then
            self:setSliderPercent("DevelopSlider", self.curSkill.currentScore / self.curSkill.levelupScore * 100)
            point = self.curSkill.currentScore
        end
        self:setStudy(point)

        -- 悬浮提示
        local effPoint = point - self.curSkill.currentScore
        self:setCtrlVisible("TipImage", true)
        local tipImage = self:getControl("TipImage")
        tipImage:setVisible(true)
        local effStr = gf:getMoneyDesc(effPoint * 74, true)
        self:setLabelText("CostMoneyLabel_2", effStr)
        if self:getCanUseMoneyByLevel() > effPoint * 74 then

            self:setLabelText("CostMoneyLabel_2", effStr, nil, COLOR3.TEXT_DEFAULT)
        else
            self:setLabelText("CostMoneyLabel_2", effStr, nil, COLOR3.RED)
        end

        local effStrPoint = gf:getMoneyDesc(effPoint, true)

        if self:getCanUseConstuByLevel() > effPoint then
            self:setLabelText("CostConstructionLabel_2", effStrPoint, nil, COLOR3.TEXT_DEFAULT)
        else
            self:setLabelText("CostConstructionLabel_2", effStrPoint, nil, COLOR3.RED)
        end

        tipImage:setPositionX(self.slider:getPositionX() - self.slider:getContentSize().width * 0.5 + self.slider:getPercent() * self.slider:getContentSize().width / 100)
       -- self.slider:getWorldPosition()

        local fadeOut = cc.FadeOut:create(1)
        local func = cc.CallFunc:create(function() tipImage:setVisible(false) end)
        local action = cc.Sequence:create(cc.DelayTime:create(1),fadeOut, func)
        tipImage:setOpacity(255)
        tipImage:stopAllActions()
        tipImage:runAction(action)
    end
end
--]]

-- 研发条件判断   [4000153] = "帮主"
function PartySkillDlg:developConditions(isFive)

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return false
    end

    -- 帮主
    if PartyMgr:getPartyJob() ~= CHS[4000153] then
        gf:ShowSmallTips(CHS[4000162])
        return false
    end

    -- 帮派等级
    if self.partyInfo.partyLevel == 1 then
        gf:ShowSmallTips(CHS[4000163])
        return false
    end

    -- 上限判断
    if self.curSkill.level == PartyMgr:getPartyLevelMax() then
        gf:ShowSmallTips(CHS[4000164])
        return false
    end

    -- 如果是连升5级别，下面两个由服务器判断
    if isFive == true then return true end

    if self:getSliderPercent("DevelopSlider") == 0 then
        gf:ShowSmallTips(CHS[4000165])
        return false
    end

    -- 资金建设度判断
    local studyPoint = math.floor(self:getSliderPercent("DevelopSlider") * self.curSkill.levelupScore / 100 - self.curSkill.currentScore)
    if studyPoint > self:getCanUseConstuByLevel() and studyPoint * 74 > self:getCanUseMoneyByLevel() then
        gf:ShowSmallTips(CHS[3003282])
        return false
    end

    if studyPoint > self:getCanUseConstuByLevel() then
        gf:ShowSmallTips(CHS[3003283])
        return false
    end

    if studyPoint * 74 > self:getCanUseMoneyByLevel() then
        gf:ShowSmallTips(CHS[3003284])
        return false
    end

    return true
end

function PartySkillDlg:onSkillTypeButton(sender, eventType)
    self:onBKPanel()
    self.skillType = sender:getTitleText()
    self:setButtonText("TypeButton", self.skillType)
    self:setSkillList()
end

function PartySkillDlg:onTypeButton(sender, eventType)
    self:setCtrlVisible("SelectPetPanel", false)
    local typePanel = self:getControl("SkillTypePanel")
    typePanel:setVisible(typePanel:isVisible() == false)
end

function PartySkillDlg:onGoToLearnButton(sender, eventType)
    if sender.petId == nil then
        gf:ShowSmallTips(CHS[3003285])
        return
    end
    sender.skillName = self.curSkill.name

    -- self.curSkill在延时后会因为收到其他消息而改变
    local dlg = DlgMgr:openDlg("PetSkillDlg")
    performWithDelay(self.root,function ()
        DlgMgr:sendMsg("PetListChildDlg", "selectPetId", sender.petId)
        local skType = self:getSkillTypeBySkillName(sender.skillName)
        if skType == CHS[3003280] then
            dlg:setShowSkill("BornPanel", sender.skillName)
        else
            dlg:setShowSkill("MadePanel", sender.skillName)
        end
    end, 0)

end

function PartySkillDlg:onDevelopButton(sender, eventType)
    self:onBKPanel()
    if not self:developConditions() then return end
    local point = math.floor(self:getSliderPercent("DevelopSlider") * self.curSkill.levelupScore / 100 - self.curSkill.currentScore)
    local skillNo = self.curSkill.no
    PartyMgr:studyPartySkill(point, skillNo)
end

function PartySkillDlg:onBatchDevelopButton(sender, eventType)
    self:onBKPanel()
    if not self:developConditions(true) then return end

    -- 安全锁判断
    if self:checkSafeLockRelease("onBatchDevelopButton", sender, eventType) then
        return
    end

    local dlg = DlgMgr:openDlg("PartySkillBatchDevelopDlg")
    dlg:setDlgInfo(self.curSkill, self:getSkillTypeBySkillName(self.curSkill.name))
end

function PartySkillDlg:onBKPanel(sender, eventType)
    self:setCtrlVisible("SelectPetPanel", false)
    self:setCtrlVisible("SkillTypePanel", false)
end

function PartySkillDlg:onStudyButton(sender, eventType)
    self:onBKPanel()

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if self.partyInfo.partyLevel == 1 then
        gf:ShowSmallTips(CHS[3003286])
        return
    end

    if not PetMgr:havePet() then
        gf:ShowSmallTips(CHS[3003287])
        return
    end

    -- 获取符合条件的宠物列表
    local petList = PetMgr:getOrderPets()
    local destPetList = {}
    local skType = self:getSkillTypeBySkillName(self.curSkill.name)
    if skType == CHS[3003280] then
        for i = 1, #petList do
            local boonSkill = PetMgr:petHaveRawSkill(petList[i]:queryBasic("raw_name")) or {}
            for j = 1,#boonSkill do
                if boonSkill[j] == self.curSkill.name then
                    table.insert(destPetList, petList[i])
                end
            end
        end
    else
        for i = 1, #petList do
            if petList[i]:queryInt('rank') ~= Const.PET_RANK_WILD then
                table.insert(destPetList, petList[i])
            end
        end
    end

    if next(destPetList) == nil then
        gf:ShowSmallTips(CHS[3003288])
        return
    end

    -- 显示在listview上
    local selectPetPabel = self:getControl("SelectPetPanel")
    selectPetPabel:setVisible(true)
    local petListCtrl = self:resetListView("PetListView")
    self:getControl("GoToLearnButton").petId = nil
    for i = 1, #destPetList do
        local untiPanel = self.petUnitPanel:clone()
        self:setPetUnit(untiPanel, destPetList[i])
        petListCtrl:pushBackCustomItem(untiPanel)
    end
end

function PartySkillDlg:setPetUnit(panel, pet)
    local function setLabelColor(name, color, panel)
        local ctrl = self:getControl(name, nil, panel)
        ctrl:setColor(color)
    end
    self:setImage("GuardImage", ResMgr:getSmallPortrait(pet:queryBasicInt("portrait")), panel)
    self:setItemImageSize("GuardImage", panel)

    -- 相性
    self:setLabelText("PolarValueLabel", gf:getPolar(pet:queryBasicInt("polar")), panel)

    self:setLabelText("NameLabel", gf:getPetName(pet.basic), panel)

    self:setLabelText("LevelLabel", "LV."..pet:queryBasic("level"), panel)
    -- 状态
    local pet_status = pet:queryInt("pet_status")
    if pet_status == 1 then
        -- 参战
        setLabelColor("PolarValueLabel", COLOR3.GREEN, panel)
        setLabelColor("NameLabel", COLOR3.GREEN, panel)
        setLabelColor("LevelLabel", COLOR3.GREEN, panel)
        self:setImage("StatusImage", ResMgr.ui.canzhan_flag, panel)
    elseif pet_status == 2 then
        setLabelColor("PolarValueLabel", COLOR3.YELLOW, panel)
        setLabelColor("NameLabel", COLOR3.YELLOW, panel)
        setLabelColor("LevelLabel", COLOR3.YELLOW, panel)
        self:setImage("StatusImage", ResMgr.ui.luezhen_flag, panel)
    elseif PetMgr:isRidePet(pet:getId()) then
        -- 骑乘
        self:setImage("StatusImage", ResMgr.ui.ride_flag, panel)
    else
        self:setCtrlVisible("StatusImage", false, panel)
    end
    panel.petId = pet:getId()
    self:bindTouchEndEventListener(panel, self.choosePet)
end

function PartySkillDlg:choosePet(sender, eventType)
    -- 取消选中效果
    local petListCtrl = self:getControl("PetListView")
    local items = petListCtrl:getItems()
    for i, panel in pairs(items) do
        self:setCtrlVisible("ChosenEffectImage", false, panel)
    end
    self:setCtrlVisible("ChosenEffectImage", true, sender)

    local gotoBtn = self:getControl("GoToLearnButton")
    gotoBtn.petId = sender.petId
end

function PartySkillDlg:onSelectShillListView(sender, eventType)
end

function PartySkillDlg:refreshPartyInfo(partyInfo)
    if self.root == nil then return end
    self.partyInfo = partyInfo

    -- 显示技能listview
    self:setSkillList(self.curSkill)
end

return PartySkillDlg
