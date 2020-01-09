-- PetDunWuDlg.lua
-- Created by yangym Nov/23/2016
-- 宠物顿悟界面
local PetDunWuDlg = Singleton("PetDunWuDlg", Dialog)

local DELAY_TIME = 0.5

local INNATE_SKILLS = {
    CHS[3003416], CHS[3003417], CHS[3003418], CHS[3003419], CHS[3003420], CHS[3003421], CHS[3003422],
    CHS[3003423], CHS[3003424], CHS[3003425], CHS[3003426], CHS[3003427], CHS[3003428], CHS[3003429],
}

function PetDunWuDlg:init()
    self:bindListener("BindCheckBox", self.onForgetPanelCheckBox, "ForgetPanel")
    self:bindListener("BindCheckBox", self.onDunWuPanelCheckBox, "DunWuPanel")
    self:bindListener("DunWuButton", self.onDunWuButton)
    self:bindListener("ForgetButton", self.onForgetButton)
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindListener("CostImage", self.onCostImagePanel, "DunWuPanel")
    self:bindListener("CostImage", self.onCostImagePanel, "ForgetPanel")


    -- 遗忘技能：永久限制交易
    if InventoryMgr.UseLimitItemDlgs[self.name .. "_Forget"] == 1 then
        self:setCheck("BindCheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name .. "_Forget"] == 0 then
        self:setCheck("BindCheckBox", false)
    end
    self:onForgetPanelCheckBox(self:getControl("BindCheckBox"))

    -- 顿悟技能：永久限制交易
    if InventoryMgr.UseLimitItemDlgs[self.name .. "_DunWu"] == 1 then
        self:setCheck("BindCheckBox", true, "DunWuPanel")
    elseif InventoryMgr.UseLimitItemDlgs[self.name .. "_DunWu"] == 0 then
        self:setCheck("BindCheckBox", false, "DunWuPanel")
    end
    self:onDunWuPanelCheckBox(self:getControl("BindCheckBox", nil, "DunWuPanel"))

    self.curSelectedSkillName = nil
    self.pet = nil

    self:hookMsg("MSG_UPDATE_PETS")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_DUNWU_SKILL")
    self:hookMsg("MSG_INVENTORY")
end

function PetDunWuDlg:onForgetPanelCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name .. "_Forget", 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name .. "_Forget", 0)
    end
    if self.pet then
        self:updateForgetPanel()
    end
end

function PetDunWuDlg:onDunWuPanelCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name .. "_DunWu", 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name .. "_DunWu", 0)
    end
    if self.pet then
        self:updateDunWuPanel()
    end
end

function PetDunWuDlg:onRuleButton(sender, eventType)
    DlgMgr:openDlg("PetDunWuRuleDlg")
end

-- 清除所有选中效果
function PetDunWuDlg:clearAllSelectEffect()
    self:setCtrlVisible("ChosenEffectImage", false, "DunWuPanel_1")
    self:setCtrlVisible("ChosenEffectImage", false, "DunWuPanel_2")
end

-- 当前技能panel是否可用
function PetDunWuDlg:setPanelEnabled(panelName, enable)
    self:setCtrlVisible("SkillImage", enable, panelName)
end

function PetDunWuDlg:getPanelEnabled(panelName)
    if self:getCtrlVisible("SkillImage", panelName) then
        return true
    else
        return false
    end
end

-- 当前技能panel是否可学习
function PetDunWuDlg:isCanLearnSkillPanel(panelName)
    if self:getCtrlVisible("AddImage", panelName) then
        return true
    else
        return false
    end
end

-- 选中某一项
function PetDunWuDlg:onSelectSkill(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:clearAllSelectEffect()
        if not self:getPanelEnabled(sender:getName()) then
            return
        end

        self:setCtrlVisible("ChosenEffectImage", true, sender)

        if self:isCanLearnSkillPanel(sender:getName()) then
            self:setCtrlVisible("DunWuPanel", true)
            self:setCtrlVisible("ForgetPanel", false)
            self:updateDunWuPanel()
            self:clearDunWuPanelSkillInfo()
        else
            self:setCtrlVisible("DunWuPanel", false)
            self:setCtrlVisible("ForgetPanel", true)
            self:updateForgetPanel()
        end
    end

end

function PetDunWuDlg:clearDunWuPanelSkillInfo()
    -- 技能图标、技能名称、技能等级重置
    self:setCtrlVisible("GuardImage", false, "DunWuPanel")
    self:setCtrlVisible("BNoneImage", true, "DunWuPanel")
    self:setLabelText("SkillLabel", CHS[7000217], "DunWuPanel")
    self:setCtrlVisible("SkillUpLabel", false, "DunWuPanel")
end

function PetDunWuDlg:setInfo(pet, skill)
    self.pet = pet

    -- 设置基本信息
    self:setPetBasicInfo(pet)

    -- 珍贵、点化标志
    self:setPetLogoPanel(pet)

    -- 更新技能信息
    self:updateSkillInfo(pet, skill)

    -- 更新顿悟面板
    self:updateDunWuPanel()

    -- 更新遗忘面板
    self:updateForgetPanel()
end

function PetDunWuDlg:updateSkillInfo(pet, skill)
    -- 顿悟技能
    self:setDunWuSkills(pet, skill)

    -- 天生技能
    self:setInnateSkills(pet)

    -- 研发技能
    self:setDevelopSkills(pet)
end

-- 基本信息设置
function PetDunWuDlg:setPetBasicInfo(pet)
    if not pet then
        self:setLabelText("GuardNameLabel", "")
        self:removePortrait("GuardIconPanel")
        self:setCtrlVisible("SuffixImage", false)
        self:setLabelText("UntradeLabel", "")
        self:setLabelText("TimeLimitLabel", "")
        return
    end
    local nameLevel = string.format(CHS[4000391], pet:getShowName(), pet:queryBasicInt("level"))
    self:setLabelText("GuardNameLabel", nameLevel)
    self:setLabelText("PolarLabel", gf:getPolar(pet:queryBasicInt("polar")))
    self:setPortrait("GuardIconPanel", pet:getDlgIcon(nil, nil, true), 0, nil, true)

    if PetMgr:isTimeLimitedPet(pet) then  -- 限时宠物
        local timeLimitStr = PetMgr:convertLimitTimeToStr(pet:queryBasicInt("deadline"))
        self:setLabelText("TradeLabel", "")
        self:setLabelText("UntradeLabel", CHS[7000083])
        self:setLabelText("TimeLimitLabel", timeLimitStr)
    elseif PetMgr:isLimitedPet(pet) then  -- 限制交易宠物
        local limitDesr, day = gf:converToLimitedTimeDay(pet:queryInt("gift"))
        self:setLabelText("TradeLabel", limitDesr)
        self:setLabelText("UntradeLabel", "")
        self:setLabelText("TimeLimitLabel", "")
    else
        self:setLabelText("TradeLabel", "")
        self:setLabelText("UntradeLabel", "")
        self:setLabelText("TimeLimitLabel", "")
    end

    -- 设置类型：野生、宝宝
    self:setCtrlVisible("SuffixImage", true)
    self:setImage("SuffixImage", ResMgr:getPetRankImagePath(pet))
end

function PetDunWuDlg:setPetLogoPanel(pet)
    PetMgr:setPetLogo(self, pet)
end

-- 顿悟技能
function PetDunWuDlg:setDunWuSkills(pet, skill)
    -- 重置状态
    self:clearAllSelectEffect()
    self:setPanelEnabled("DunWuPanel_1", false)
    self:setPanelEnabled("DunWuPanel_2", false)
    self:setCtrlVisible("LevelPanel", false, "DunWuPanel_1")
    self:setCtrlVisible("LevelPanel", false, "DunWuPanel_2")
    self:setCtrlVisible("BackImage", false, "DunWuPanel_1")
    self:setCtrlVisible("BackImage", false, "DunWuPanel_2")

    -- 该宠物拥有的顿悟技能
    local dunWuSkills = SkillMgr:getPetDunWuSkills(pet:getId()) or {}

    local haveSkillNum = #dunWuSkills

    -- 该宠物最多可以拥有的顿悟技能个数
    local maxSkillNum
    local petType = pet:queryInt("rank")
    if petType == Const.PET_RANK_ELITE or petType == Const.PET_RANK_EPIC then
        maxSkillNum = 2
    else
        maxSkillNum = 1
    end

    -- 拥有的技能初始化
    for i = 1, haveSkillNum do
        local skillAttrib = SkillMgr:getskillAttribByName(dunWuSkills[i])
        local skillIconPath = SkillMgr:getSkillIconPath(skillAttrib.skill_no)
        if nil == skillIconPath
            then return
        end

        local panelName = "DunWuPanel_" .. i
        local panel = self:getControl(panelName)
        self:setPanelEnabled(panelName, true)
        self:setCtrlVisible("AddImage", false, panelName)

        -- 技能图标与等级
        self:setImage("SkillImage", skillIconPath, panel)
        self:setItemImageSize("SkillImage", panel)

        self:setCtrlVisible("LevelPanel", true, panel)
        local skillWithPet = SkillMgr:getSkill(pet:getId(), skillAttrib.skill_no)
        self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT,
            skillWithPet.skill_level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

        -- 初始化传入skill参数对应的技能
        if skill and skill == dunWuSkills[i] then
            self.curSelectedSkillName = skill
            self:onSelectSkill(panel, 2)
        end

        -- 点击弹出悬浮框
        local function haveSkillListener(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if sender:getName() == "DunWuPanel_1" and dunWuSkills[1] then
                    self.curSelectedSkillName = dunWuSkills[1]
                elseif sender:getName() == "DunWuPanel_2" and dunWuSkills[2] then
                    self.curSelectedSkillName = dunWuSkills[2]
                end

                self:onSelectSkill(panel, 2)
                local rect = self:getBoundingBoxInWorldSpace(sender)
                SkillMgr:showSkillDescDlg(dunWuSkills[i], pet:getId(), true, rect)
            end
        end
        panel:addTouchEventListener(haveSkillListener)
    end

    -- 可学习技能初始化
    for i = haveSkillNum + 1, maxSkillNum do
        local panelName = "DunWuPanel_" .. i
        local panel = self:getControl(panelName)
        self:setPanelEnabled(panelName, true)
        self:setCtrlVisible("BackImage", true, panelName)
        self:setCtrlVisible("AddImage", true, panelName)
        self:setImagePlist("SkillImage", ResMgr.ui.bag_item_bg_img, panelName)

        -- 如果传入参数skill为nil,选择第一个可学习项
        if i == haveSkillNum + 1 and not skill then
            self.curSelectedSkillName = nil
            self:onSelectSkill(panel, 2)
        end

        local function listener(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self.curSelectedSkillName = nil
                self:onSelectSkill(sender, 2)
            end
        end
        panel:addTouchEventListener(listener)
    end

        -- 剩余技能图标显示为不可学习状态
    for j = maxSkillNum + 1, 2 do
        local panel = self:getControl("DunWuPanel_" .. j)
        panel:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                gf:ShowSmallTips(CHS[7000292])
            end
        end)
    end
end

-- 天生技能
function PetDunWuDlg:setInnateSkills(pet)
    if not pet then
        return
    end

    -- 获取天生技能
    local inateSkill = PetMgr:petHaveRawSkill(pet:queryBasic("raw_name")) or {}
    local hasInnateSkill = SkillMgr:getPetRawSkillNoAndLadder(pet:getId()) or {}
    local inateSkillCount = #inateSkill
    local hasInnateSkillCount = #hasInnateSkill

    -- 在技能列表框 中设置技能图标
    local i = 0
    for j = 1, #INNATE_SKILLS do
        local skillName = false
        for k = 1, #inateSkill do
            if inateSkill[k] == INNATE_SKILLS[j] then
                skillName = inateSkill[k]
            end
        end

        if skillName then
            i = i + 1
            -- 获取技能图标
            local skill = SkillMgr:getskillAttribByName(skillName)
            local skillIconPath = SkillMgr:getSkillIconPath(skill.skill_no)
            if nil == skillIconPath
                then return
            end

            local panel = self:getControl("BornPanel_" .. i)
            self:setCtrlVisible("SkillImage", true, panel)
            self:setImage("SkillImage", skillIconPath, panel)
            self:setItemImageSize("SkillImage", panel)

            -- 判断宠物是否已经拥有这个技能
            local isHas = false;
            for j = 1, hasInnateSkillCount do
                if skill.skill_no == hasInnateSkill[j].no then
                    -- 标志已经拥有
                    isHas = true
                end
            end

            -- 如果宠物未拥有这个技能
            if not isHas then
                -- 图标置灰
                self:setCtrlEnabled("SkillImage", false, panel)
                self:setCtrlVisible("LevelPanel", false, panel)
            else
                self:setCtrlEnabled("SkillImage", true, panel)
                -- 设置等级
                self:setCtrlVisible("LevelPanel", true, panel)
                local skillWithPet = SkillMgr:getSkill(pet:getId(), skill.skill_no)
                self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT,
                                        skillWithPet.skill_level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)
            end

            -- 点击弹出悬浮框
            local function listener(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local rect = self:getBoundingBoxInWorldSpace(sender)
                    SkillMgr:showSkillDescDlg(skillName, pet:getId(), true, rect)
                end
            end
            panel:addTouchEventListener(listener)
        end
    end

    -- 剩余技能图标显示为不可学习状态
    for j = i + 1, 3 do
        local panel = self:getControl("BornPanel_" .. j)
        self:setCtrlVisible("SkillImage", false, panel)
        self:setCtrlVisible("LevelPanel", false, panel)
    end
end

function PetDunWuDlg:setDevelopSkills(pet)
    if pet == nil then return end

    -- 获取 研发技能
    local skillsName = {CHS[3003439], CHS[3003440], CHS[3003441], CHS[3003442]}
    local normalSkills = {}
    for i = 1, #skillsName do
        table.insert(normalSkills, SkillMgr:getskillAttribByName(skillsName[i]))
    end

    if nil == normalSkills then return end

    -- 获取宠物已经拥有的技能
    local petSkills = SkillMgr:getSkillNoAndLadder(pet:getId(), SKILL.SUBCLASS_E, SKILL.CLASS_PET)
    local normalSkillsCount = #normalSkills
    local petSkillsCount = 0
    if nil ~= petSkills then
        petSkillsCount = #petSkills
    end

    -- 在技能列表框 中设置技能图标
    for i = 1, normalSkillsCount do

        -- 获取技能图标
        local skillIconPath = SkillMgr:getSkillIconPath(normalSkills[i].skill_no)
        if nil == skillIconPath then return end

        local panel = self:getControl("MadePanel_" .. i)
        self:setImage("SkillImage", skillIconPath, panel)
        self:setItemImageSize("SkillImage", panel)

        -- 判断宠物是否已经拥有这个技能
        local isHas = false;
        for j = 1, petSkillsCount do
            if normalSkills[i].skill_no == petSkills[j].no then
                -- 标志已经拥有
                isHas = true
            end
        end

        if isHas then
            self:setCtrlEnabled("SkillImage", true, panel)
            self:setCtrlVisible("LevelPanel", true, panel)
            local skillWithPet = SkillMgr:getSkill(pet:getId(), normalSkills[i].skill_no)
            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT,
                skillWithPet.skill_level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)
        else
            self:setCtrlEnabled("SkillImage", false, panel)
            self:setCtrlVisible("LevelPanel", false, panel)
        end

        -- 点击弹出悬浮框
        local function listener(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local rect = self:getBoundingBoxInWorldSpace(sender)
                SkillMgr:showSkillDescDlg(normalSkills[i].name, pet:getId(), true, rect)
            end
        end
        panel:addTouchEventListener(listener)
    end
end

function PetDunWuDlg:updateDunWuPanel()
    if not self.pet then
        return
    end

    -- 顿悟次数
    local dunWuTimes = self.pet:queryBasicInt("dunwu_times")

    if dunWuTimes > 0 then
        self:setCtrlVisible("ItemPanel", false, "DunWuPanel")
        self:setCtrlVisible("DunWuTimesLabel", true, "DunWuPanel")

        local dunWuTimesStr = string.format(CHS[7000215], dunWuTimes)
        self:setLabelText("DunWuTimesLabel", dunWuTimesStr, "DunWuPanel")
    else
        local itemName = CHS[7000210]
        self:setCtrlVisible("ItemPanel", true, "DunWuPanel")
        self:setCtrlVisible("DunWuTimesLabel", false, "DunWuPanel")

        -- 宠物顿悟丹图标
        self:setImage("CostImage", InventoryMgr:getIconFileByName(itemName), "DunWuPanel")
        self:setItemImageSize("CostImage", "DunWuPanel")

        -- 宠物顿悟丹数量
        local isUseLimited = false
        if self:isCheck("BindCheckBox", "DunWuPanel") then
            isUseLimited = true
        else
            isUseLimited = false
        end

        local amount = InventoryMgr:getAmountByNameIsForeverBind(itemName, isUseLimited)
        self:setLabelText("CostLabel", amount .. "/1", "DunWuPanel")
    end

    -- 幸运值
    local luckyValue = self.pet:queryBasicInt("dunwu_rate") / 10
    self:setLabelText("LuckyLabel", string.format(CHS[7000216], luckyValue), "DunWuPanel")
end

-- 当前顿悟/遗忘技能是否正在使用顿悟次数
function PetDunWuDlg:isUsingDunWuTimes()
    local dunWuTimes = self.pet:queryBasicInt("dunwu_times")
    if dunWuTimes > 0 then
        return true
    else
        return false
    end
end

function PetDunWuDlg:updateForgetPanel()
    if not self.pet then
        return
    end

    if not self.curSelectedSkillName then
        return
    end

    -- 技能图标与名字
    local skillName = self.curSelectedSkillName
    local skill = SkillMgr:getskillAttribByName(skillName)
    local skillIconPath = SkillMgr:getSkillIconPath(skill.skill_no)
    self:setImage("GuardImage", skillIconPath, "ForgetPanel")
    self:setItemImageSize("GuardImage", "ForgetPanel")
    self:setCtrlVisible("GuardImage", true, "ForgetPanel")
    self:setCtrlVisible("BNoneImage", false, "ForgetPanel")
    self:setLabelText("SkillLabel", skillName, "ForgetPanel")

    -- 宠物顿悟丹显示区域
    local dunWuTimes = self.pet:queryBasicInt("dunwu_times")
    if dunWuTimes > 0 then
        self:setCtrlVisible("ForgetTimesLabel", true, "ForgetPanel")
        self:setCtrlVisible("ForgetTipsLabel", true, "ForgetPanel")
        self:setCtrlVisible("Image_142", true, "ForgetPanel")
        self:setCtrlVisible("ItemPanel", false, "ForgetPanel")

        local dunWuTimesStr = string.format(CHS[7000215], dunWuTimes)
        self:setLabelText("ForgetTimesLabel", dunWuTimesStr, "ForgetPanel")
    else
        self:setCtrlVisible("ForgetTimesLabel", false, "ForgetPanel")
        self:setCtrlVisible("ForgetTipsLabel", false, "ForgetPanel")
        self:setCtrlVisible("Image_142", false, "ForgetPanel")
        self:setCtrlVisible("ItemPanel", true, "ForgetPanel")
        local itemName = CHS[7000210]
        self:setImage("CostImage", InventoryMgr:getIconFileByName(itemName), "ForgetPanel")
        self:setItemImageSize("CostImage", "ForgetPanel")

        local isUseLimited = false
        if self:isCheck("BindCheckBox", "ForgetPanel") then
            isUseLimited = true
        else
            isUseLimited = false
        end

        local amount = InventoryMgr:getAmountByNameIsForeverBind(itemName, isUseLimited)
        self:setLabelText("CostLabel", amount .. "/1", "ForgetPanel")
    end

    -- 点击弹出悬浮框
    local panel = self:getControl("ShapePanel", nil, "ForgetPanel")
    panel:setTouchEnabled(true)
    local function forgetPanellistener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local rect = self:getBoundingBoxInWorldSpace(sender)
            SkillMgr:showSkillDescDlg(skillName, self.pet:getId(), true, rect)
        end
    end

    panel:addTouchEventListener(forgetPanellistener)

    self:updateLayout("ForgetPanel")
end

function PetDunWuDlg:onDunWuButton()
    if not self.pet then
        return
    end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003333])
        return
    end

    if self.pet:queryInt("rank") == Const.PET_RANK_WILD then
        gf:ShowSmallTips(CHS[7000223])
        return
    end

    if PetMgr:isTimeLimitedPet(self.pet) then
        gf:ShowSmallTips(CHS[7000224])
        return
    end

    if self.pet:queryInt("origin_intimacy") < 50000 then
        gf:ShowSmallTips(CHS[7000225])
        return
    end

    -- 达到标准武学
    local stdMartial = math.floor(Formula:getStdMartial(self.pet:queryBasicInt("level")))
    if self.pet:queryInt("martial") < 2 * stdMartial then
        gf:ShowSmallTips(CHS[7000226])
        return
    end

    -- 顿悟次数已满
    local maxSkillNum
    local petType = self.pet:queryInt("rank")
    if petType == Const.PET_RANK_ELITE or petType == Const.PET_RANK_EPIC then
        maxSkillNum = 2
    else
        maxSkillNum = 1
    end

    local dunWuSkills = SkillMgr:getPetDunWuSkills(self.pet:getId()) or {}
    if #dunWuSkills >= maxSkillNum then
        gf:ShowSmallTips(CHS[7000227])
        return
    end

    if self:isUsingDunWuTimes() then
        -- 使用顿悟次数
        -- 安全锁判断
        if self:checkSafeLockRelease("onDunWuButton") then
            return
        end

        local no = self.pet:queryInt("no")
        gf:CmdToServer("CMD_UPGRADE_PET", {
            type = "pet_insight",
            no = no,
        })
    else
        -- 使用顿悟丹
        local isUseLimited = false
        if self:isCheck("BindCheckBox", "DunWuPanel") then
            isUseLimited = true
        else
            isUseLimited = false
        end

        local itemName = CHS[7000210]
        local amount = InventoryMgr:getAmountByNameIsForeverBind(itemName, isUseLimited)
        if amount < 1 then
            gf:askUserWhetherBuyItem(itemName)
            return
        end

        -- 安全锁判断
        if self:checkSafeLockRelease("onDunWuButton") then
            return
        end

        local item = InventoryMgr:getPriorityUseInventoryByName(itemName, isUseLimited)
        local str, day = gf:converToLimitedTimeDay(self.pet:queryInt("gift"))
        local petName = self.pet:getShowName()
        local petId = self.pet:queryBasicInt("id")
        local no = self.pet:queryInt("no")
        if isUseLimited and InventoryMgr:getAmountByNameForeverBind(itemName) > 0 and day <= Const.LIMIT_TIPS_DAY then
            gf:confirm(string.format(CHS[7000238], 10, petName), function()
                gf:CmdToServer("CMD_UPGRADE_PET", {
                    type = "pet_insight",
                    no = no,
                    pos = item.pos,
                    ids = item.item_unique,
                })
            end)
        else
            gf:CmdToServer("CMD_UPGRADE_PET", {
                type = "pet_insight",
                no = no,
                pos = item.pos,
                ids = item.item_unique,
            })
        end
    end
end

function PetDunWuDlg:onForgetButton()
    if not self.pet then
        return
    end

    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003333])
        return
    end

    if self.pet:queryInt("rank") == Const.PET_RANK_WILD then
        gf:ShowSmallTips(CHS[7000229])
        return
    end

    if PetMgr:isTimeLimitedPet(self.pet) then
        gf:ShowSmallTips(CHS[7000230])
        return
    end

    if self.pet:queryInt("origin_intimacy") < 50000 then
        gf:ShowSmallTips(CHS[7000231])
        return
    end

    -- 达到标准武学
    local stdMartial = math.floor(Formula:getStdMartial(self.pet:queryBasicInt("level")))
    if self.pet:queryInt("martial") < 2 * stdMartial then
        gf:ShowSmallTips(CHS[7000232])
        return
    end

    local petName = self.pet:queryBasic("name")
    local petNo = self.pet:queryInt("no")
    local skillName = self.curSelectedSkillName
    if not skillName then
        return
    end

    local skill = SkillMgr:getskillAttribByName(skillName)
    local skillNo = skill.skill_no

    if self:isUsingDunWuTimes() then
        -- 使用顿悟次数
        -- 安全锁判断
        if self:checkSafeLockRelease("onForgetButton") then
            return
        end

        gf:confirm(string.format(CHS[7000240], skillName), function()
            gf:CmdToServer("CMD_UPGRADE_PET", {
                type = "pet_forget_insight",
                no = petNo,
                cost_type = tostring(skillNo),
            })
        end)
    else
        -- 使用顿悟丹
        local isUseLimited = false
        if self:isCheck("BindCheckBox", "ForgetPanel") then
            isUseLimited = true
        else
            isUseLimited = false
        end

        local itemName = CHS[7000210]
        local amount = InventoryMgr:getAmountByNameIsForeverBind(itemName, isUseLimited)
        if amount < 1 then
            gf:askUserWhetherBuyItem(itemName)
            return
        end

        -- 安全锁判断
        if self:checkSafeLockRelease("onForgetButton") then
            return
        end

        local item = InventoryMgr:getPriorityUseInventoryByName(itemName, isUseLimited)
        local str, day = gf:converToLimitedTimeDay(self.pet:queryInt("gift"))
        if isUseLimited and InventoryMgr:getAmountByNameForeverBind(itemName) > 0 and day <= Const.LIMIT_TIPS_DAY then
            gf:confirm(string.format(CHS[7000239], 10, skillName), function()
                gf:CmdToServer("CMD_UPGRADE_PET", {
                    type = "pet_forget_insight",
                    no = petNo,
                    pos = tostring(item.pos),
                    cost_type = tostring(skillNo),
                    ids = tostring(item.item_unique),
                })
            end)
        else
            gf:confirm(string.format(CHS[7000240], skillName), function()
                gf:CmdToServer("CMD_UPGRADE_PET", {
                    type = "pet_forget_insight",
                    no = petNo,
                    pos = tostring(item.pos),
                    cost_type = tostring(skillNo),
                    ids = tostring(item.item_unique),
                })
            end)
        end
    end
end

function PetDunWuDlg:onCostImagePanel(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[7000210], rect)
end

function PetDunWuDlg:MSG_UPDATE_PETS(data)
    if not self.pet then
        return
    end

    -- 设置基本信息
    self:setPetBasicInfo(self.pet)

    -- 珍贵、点化标志
    self:setPetLogoPanel(self.pet)

    self:updateDunWuPanel()
    self:updateForgetPanel()
end

function PetDunWuDlg:MSG_UPDATE(data)
    if not self.pet then
        return
    end

    -- 设置基本信息
    self:setPetBasicInfo(self.pet)

    -- 珍贵、点化标志
    self:setPetLogoPanel(self.pet)

    self:updateDunWuPanel()
    self:updateForgetPanel()
end

function PetDunWuDlg:MSG_INVENTORY(data)
    if not self.pet then
        return
    end

    self:updateDunWuPanel()
    self:updateForgetPanel()
end

function PetDunWuDlg:MSG_DUNWU_SKILL(data)
    if not self.pet then
        return
    end

    local type = data.type
    -- type参数含义：1.学习新技能；2.遗忘技能；3.提升技能等级

    if type == 2 then
        self:updateSkillInfo(self.pet)
        return
    end

    local petId = data.pet_id
    local skillNo = data.skill_no
    local skillWithPet = SkillMgr:getSkill(data.pet_id, data.skill_no)
    local level = skillWithPet.skill_level

    -- type参数含义：1.学习新技能；2.遗忘技能；3.提升技能等级
    if type == 1 or type == 3 then
        local skillName = SkillMgr:getSkillName(skillNo)

        if type == 1 then
            if skillWithPet.skill_nimbus and skillWithPet.skill_nimbus > 0 then  -- 学习的新技能是顿悟技能
                self:updateSkillInfo(self.pet, skillName)
            else
                self:updateSkillInfo(self.pet)
            end
        elseif type == 3 then
            self:updateSkillInfo(self.pet)
        end

        local skillIconPath = SkillMgr:getSkillIconPath(skillNo)
        self:setImage("GuardImage", skillIconPath, "DunWuPanel")
        self:setItemImageSize("GuardImage", "DunWuPanel")
        self:setCtrlVisible("GuardImage", true, "DunWuPanel")
        self:setCtrlVisible("BNoneImage", false, "DunWuPanel")
        self:setLabelText("SkillLabel", skillName, "DunWuPanel")

        -- 点击弹出悬浮框
        local panel = self:getControl("GuardImage", nil, "DunWuPanel")
        panel:setTouchEnabled(true)
        local function panelTouch(sender, enventType)
            if enventType == ccui.TouchEventType.ended then
                local rect = self:getBoundingBoxInWorldSpace(sender)
                SkillMgr:showSkillDescDlg(skillName, petId, true, rect)
            end
        end
        panel:addTouchEventListener(panelTouch)

        -- 技能等级提升信息
        if type == 3 then
            self:setCtrlVisible("SkillUpLabel", true, "DunWuPanel")
            local levelBefore = level - data.delta
            self:setLabelText("SkillUpLabel", string.format(CHS[7000214], levelBefore, data.delta), "DunWuPanel")
        elseif type == 1 then
            self:setLabelText("SkillUpLabel", "", "DunWuPanel")
        end
    end
end

function PetDunWuDlg:cleanup()
    self.curSelectedSkillName = nil
    self.pet = nil
end

return PetDunWuDlg