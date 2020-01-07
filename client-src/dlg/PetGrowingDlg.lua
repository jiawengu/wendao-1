-- PetGrowingDlg.lua
-- Created by zhegngjh Sep/24/2015
-- 宠物成长

local PetGrowingDlg = Singleton("PetGrowingDlg", Dialog)
local GROWING_NOTING_STRING = "???"

local GROW_TYPE = {
    DEVELOPING = 1,
    GOD_SKILL  = 2,
}

local INNATE_SKILLS = {
    CHS[3003416], CHS[3003417], CHS[3003418], CHS[3003419], CHS[3003420], CHS[3003421], CHS[3003422],
    CHS[3003423], CHS[3003424], CHS[3003425], CHS[3003426], CHS[3003427], CHS[3003428], CHS[3003429],
}

local curType = nil

function PetGrowingDlg:init()
    self:bindListener("UseButton", self.onUseButton)
    self:bindListener("RewashButton", self.onRewashButton)
    self:bindListener("ReplaceButton", self.onReplaceButton)
    self:bindListener("WashGrowingRuleButton", self.onWashGrowingRuleButton)

    self:bindListener("GrowingButton", self.onGrowingButton)
    self:bindListener("SkillButton", self.onSkillButton)

    self:bindListener("ItemPanel", self.onItemPanel, "WildPetPanel")
    self:bindListener("ItemPanel", self.onItemPanel, "BabyPetPanel")

    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_UPDATE_PETS")
    self:hookMsg("MSG_PREVIEW_SPECIAL_SKILL")
    self:hookMsg("MSG_UPDATE_SKILLS")
    self:hookMsg("MSG_REFINE_PET_RESULT")

    self.totalAddValue = 0

    -- 初值化道具信息
    self:bindCheckBox()

    if InventoryMgr.UseLimitItemDlgs[self.name] == 1 then
        self:setCheckBoxInfo(true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 0 then
        self:setCheckBoxInfo(false)
    end

    self:MSG_INVENTORY()

    self:switchTab(self:getControl("GrowingButton"), GROW_TYPE.DEVELOPING)

    self:initPet()
end

function PetGrowingDlg:initPet()
    local pet = PetMgr:getLastSelectPet()
    if pet then

        self:setPetInfo(pet)
    end

    -- 请求宠物天技
    PetMgr:requestPetGodSkill(pet:queryBasicInt("id"), "preview")
    PetMgr:getCanFeedSuperLuLimit()
end

-- 清理
function PetGrowingDlg:cleanup()
    PetMgr:resetCanFeedLimit()
end

-- 切换标签
function PetGrowingDlg:switchTab(sender, type)
    self:setCtrlVisible("Image", false, self:getControl("GrowingButton"))
    self:setCtrlVisible("Image", false, self:getControl("SkillButton"))
    self:setCtrlVisible("WashGrowingPanel", false, self:getControl("BabyPetPanel"))
    self:setCtrlVisible("WashSkillPanel", false)
    self:setCtrlVisible("WashSkillNoticePanel", false)
    self:setCtrlVisible("WashGrowingNoticePanel", false)
    self:setCtrlVisible("Image", true, sender)
    if GROW_TYPE.DEVELOPING == type then
        curType = GROW_TYPE.DEVELOPING
        self:setCtrlVisible("WashGrowingPanel", true, self:getControl("BabyPetPanel"))
        self:setCtrlVisible("WashGrowingNoticePanel", true)
        self:setLabelText("Label_1", CHS[4200004], "ReplaceButton")
        self:setLabelText("Label_2", CHS[4200004], "ReplaceButton")
    elseif GROW_TYPE.GOD_SKILL == type then
        curType = GROW_TYPE.GOD_SKILL
        self:setCtrlVisible("WashSkillPanel", true)
        self:setCtrlVisible("WashSkillNoticePanel", true)
        self:setLabelText("Label_1", CHS[4200005], "ReplaceButton")
        self:setLabelText("Label_2", CHS[4200005], "ReplaceButton")
    end

    self:updateBtnStatus()
end

-- 是否存在洗成长缓存
function PetGrowingDlg:haveGrowTemp()
    if GROW_TYPE.DEVELOPING == curType and self.haveTemp then
        return true
    end

    return false
end

-- 是否存在洗天技缓存
function PetGrowingDlg:haveGodSkillTemp()
    if not self.selectPet then return end
    if GROW_TYPE.GOD_SKILL == curType and PetMgr:isHasPetGodSkill(self.selectPet:queryBasicInt("no")) then
        return true
    end

    return false
end

-- 判断是否是三个天技
function PetGrowingDlg:isFullSkills()
    local pet = self.selectPet
    if not pet then return false end
    local washSkills = PetMgr:getGrowGodSkill(pet:queryBasicInt("id"))
    if not washSkills then return false end
    local rawSkills = PetMgr:petHaveRawSkill(pet:queryBasic("raw_name")) or {}

    if #washSkills == #rawSkills then
        return true
    end

    return false
end

-- 是否包含新的天技
function PetGrowingDlg:getNewGodSkill()
    local pet = self.selectPet
    if not pet then return end
    local washSkills = PetMgr:getGrowGodSkill(pet:queryBasicInt("id"))
    if not washSkills then return end

    local inateSkill = SkillMgr:getPetRawSkillNoAndLadder(pet:getId()) or {}

    local newSkills = {}
    for i = 1, #washSkills do
        local skillName = washSkills[i].skillName
        local flag = true
        for j = 1, #inateSkill do
            if skillName == inateSkill[j].name then
                flag = false
            end
        end

        if flag then
            table.insert(newSkills, skillName)
        end
    end

    if 0 == #newSkills then
        return false
    else
        return true
    end
end

-- 当前宠物是否存在天技
function PetGrowingDlg:isHaveGodSkill()
    local pet = self.selectPet
    if not pet then return end

    local skills = SkillMgr:getPetRawSkillNoAndLadder(pet:getId()) or {}

    if 0 == #skills then
        return false
    else
        return true
    end
end

-- 更新按钮状态
function PetGrowingDlg:updateBtnStatus()
    local isReFresh = false
    if self:haveGrowTemp() then
        isReFresh = true
    elseif self:haveGodSkillTemp() then
        isReFresh = true
    end

    if isReFresh then
        self:setLabelText("Label_1", CHS[3003392], self:getControl("RewashButton"))
        self:setLabelText("Label_2", CHS[3003392], self:getControl("RewashButton"))
    else
        self:setLabelText("Label_1", CHS[3003393], self:getControl("RewashButton"))
        self:setLabelText("Label_2", CHS[3003393], self:getControl("RewashButton"))
    end
end

function PetGrowingDlg:setPetInfo(pet)
    self.selectPet = pet
    local rank = Const.PET_RANK_WILD
    local cfg = nil
    if pet ~= nil then
        rank = pet:queryInt("rank")
    end

    if rank == Const.PET_RANK_WILD then
        self:setWildInfo(pet)
        self:setCtrlVisible("WildPetPanel", true)
        self:setCtrlVisible("BabyPetPanel", false)
    else
        self:setCtrlVisible("WildPetPanel", false)
        self:setCtrlVisible("BabyPetPanel", true)
        self:setOtherInfo(pet)
    end

    PetMgr:setPetLogo(self, pet)

    -- 设置类型：野生、宝宝
    self:setImage("SuffixImage", ResMgr:getPetRankImagePath(pet))
end

function PetGrowingDlg:setWildInfo(pet)
    local life_shape = nil
    local mana_shape = nil
    local speed_shape = nil
    local phy_shape = nil
    local mag_shape = nil
    local total_shape = 0
    if pet ~= nil then
        local raw_name = pet:queryBasic("raw_name")
        life_shape = PetMgr:getPetStdValue(raw_name, "life")
        mana_shape = PetMgr:getPetStdValue(raw_name, "mana")
        speed_shape = PetMgr:getPetStdValue(raw_name, "speed")
        phy_shape = PetMgr:getPetStdValue(raw_name, "phy_attack")
        mag_shape = PetMgr:getPetStdValue(raw_name, "mag_attack")
        total_shape = life_shape + mana_shape + speed_shape + phy_shape + mag_shape
    end

    local function setGrowInfo(valueLabelName, value, range)

        local beforePanel = self:getControl("NowGrowingPanel", Const.UIPanel)
        local afterPanel = self:getControl("WashGrowingPanel", Const.UIPanel)


        if value == nil or range == nil then
            self:setLabelText(valueLabelName .. "_1", "", beforePanel)
            self:setLabelText(valueLabelName .. "_2", "", beforePanel)
        else
            self:setLabelText(valueLabelName .. "_1", value - range, beforePanel)
            self:setLabelText(valueLabelName .. "_2", value, beforePanel)
            self:setLabelText(valueLabelName .. "_1", value, afterPanel)
            self:setLabelText(valueLabelName .. "_2", value + range, afterPanel)
        end
    end

    setGrowInfo("LifeEffectLabel", life_shape, 10)
    setGrowInfo("ManaEffectLabel", mana_shape, 10)
    setGrowInfo("SpeedEffectLabel", speed_shape, 5)
    setGrowInfo("PhyEffectLabel", phy_shape, 10)
    setGrowInfo("MagEffectLabel", mag_shape, 10)
    setGrowInfo("TotalEffectLabel", total_shape, 45)
end

function PetGrowingDlg:setOtherInfo(pet)
    self:setCtrlVisible("RestWildPanel", false)
    self:setCtrlVisible("ResetEffectPanel", true)
    self:setCtrlVisible("StrengthEffectPanel", true)

    -- 设置既基本信息
    PetGrowingDlg:setPetBasicInfo(pet)
    self:setGorwPanelInfo()

    local hasInnateSkill = SkillMgr:getPetRawSkillNoAndLadder(pet:getId()) or {}
    self:setGodSkillInfo(self:getControl("BeforePanel"), hasInnateSkill)
end

-- 基本信息设置
function PetGrowingDlg:setPetBasicInfo(pet)
    if not pet then
        self:setLabelText("GuardNameLabel", "")
        self:setLabelText("LevelLabel", "")
        self:setLabelText("PolarLabel", "")
        self:removePortrait("GuardIconPanel")
        self:setCtrlVisible("SuffixImage", false)
        self:setLabelText("UntradeLabel", "")
        self:setLabelText("TimeLimitLabel", "")
        return
    end
    local nameLevel = string.format(CHS[4000391], pet:getShowName(), pet:queryBasicInt("level"))
    self:setLabelText("GuardNameLabel", nameLevel)
    self:setLabelText("LevelLabel", pet:queryBasicInt("level") .. CHS[3003391])
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

function PetGrowingDlg:setGorwPanelInfo()

    local life_shape = 0
    local mana_shape = 0
    local speed_shape = 0
    local phy_shape = 0
    local mag_shape = 0
    local lifeAdd = 0
    local manaAdd = 0
    local speedAdd = 0
    local phyAdd = 0
    local magAdd = 0
    local life_add_temp = 0
    local mana_add_temp = 0
    local phy_power_add_temp = 0
    local mag_power_add_temp = 0
    local speed_add_temp = 0
    local def_add_temp = 0
    local haveTemp = false
    local phy_power = 0
    local speed = 0
    local mag_power = 0
    local defence = 0
    local maxLife = 0
    local maxMana = 0
    local petLife = 0
    local petMana = 0

    local pet = self.selectPet
    if pet ~= nil then
        life_shape = pet:queryBasicInt("life_effect") + 40
        mana_shape = pet:queryBasicInt("mana_effect") + 40
        speed_shape = pet:queryBasicInt("speed_effect") + 40
        phy_shape = pet:queryBasicInt("phy_effect") + 40
        mag_shape = pet:queryBasicInt("mag_effect") + 40
        lifeAdd = pet:queryBasicInt("pet_life_shape_temp")
        manaAdd = pet:queryBasicInt("pet_mana_shape_temp")
        speedAdd = pet:queryBasicInt("pet_speed_shape_temp")
        phyAdd = pet:queryBasicInt("pet_phy_shape_temp")
        magAdd = pet:queryBasicInt("pet_mag_shape_temp")

        haveTemp = lifeAdd ~= 0 or manaAdd ~= 0 or speedAdd ~= 0 or
            phyAdd ~= 0 or magAdd ~= 0 or life_add_temp ~= 0 or
            mana_add_temp ~= 0 or phy_power_add_temp ~= 0 or
            mag_power_add_temp ~= 0 or speed_add_temp ~= 0 or
            def_add_temp ~= 0

    end

    self.haveTemp = haveTemp

    local raw_name = pet:queryBasic("evolve") -- 从魂魄中
    if raw_name == "" then raw_name = pet:queryBasic("raw_name") end
    local life_max = PetMgr:getPetStdValue(raw_name, "life") + 10
    local mana_max = PetMgr:getPetStdValue(raw_name, "mana") + 10
    local speed_max = PetMgr:getPetStdValue(raw_name, "speed") + 5
    local phy_max = PetMgr:getPetStdValue(raw_name, "phy_attack") + 10
    local mag_max = PetMgr:getPetStdValue(raw_name, "mag_attack") + 10
    local phyRebuildAdd = pet:queryInt("phy_rebuild_add")
    local magRebuildAdd = pet:queryInt("mag_rebuild_add")

    local babyPetPanel = self:getControl("BabyPetPanel")
    local rootPanel = self:getControl("WashGrowingPanel", nil, babyPetPanel)
    local rewashButton = self:getControl("RewashButton")

    if haveTemp then
        -- 气血成长
        self:setSliderInfo("Life", life_shape , life_max, "WashGrowingPanel", lifeAdd)

        -- 法力成长
        self:setSliderInfo("Mana", mana_shape , mana_max, "WashGrowingPanel", manaAdd)

        -- 速度成长
        self:setSliderInfo("Speed", speed_shape , speed_max, "WashGrowingPanel", speedAdd)

        -- 物攻成长
        self:setSliderInfo("Phy", phy_shape, phy_max, "WashGrowingPanel", phyAdd)

        -- 法攻成长
        self:setSliderInfo("Mag", mag_shape, mag_max, "WashGrowingPanel", magAdd)

        -- 总成长
        local totalAdd = lifeAdd + manaAdd + speedAdd + phyAdd + magAdd
        local growTotal =  life_shape+mana_shape+speed_shape+phy_shape+mag_shape
        self:setLabelText("TotalEffectLabel", growTotal, rootPanel)
        self:setLabelColorByValue("TotalEffectLabel_1", totalAdd, nil, rootPanel)

        self.totalAddValue = totalAdd
    else

        -- 气血成长
        self:setSliderInfo("Life", life_shape, life_max, "NowGrowingPanel", 0)

        -- 法力成长
        self:setSliderInfo("Mana", mana_shape, mana_max, "NowGrowingPanel", 0)

        -- 速度成长
        self:setSliderInfo("Speed", speed_shape, speed_max, "NowGrowingPanel", 0)

        -- 物攻成长
        self:setSliderInfo("Phy", phy_shape, phy_max, "NowGrowingPanel", 0)

        -- 法攻成长
        self:setSliderInfo("Mag", mag_shape, mag_max, "NowGrowingPanel", 0)

        local growTotal = life_shape+mana_shape+speed_shape+phy_shape+mag_shape
        self:setLabelText("TotalEffectLabel", growTotal, rootPanel)
        self:setLabelColorByValue("TotalEffectLabel_1", 0, nil, rootPanel)

        self.totalAddValue = 0
    end

    self:updateBtnStatus()
end

function PetGrowingDlg:setGodSkillInfo(panel, hasInnateSkill)
    if nil == hasInnateSkill then return end

    local pet = self.selectPet
    if not pet then return end

    -- 获取技能
    local inateSkill = PetMgr:petHaveRawSkill(pet:queryBasic("raw_name")) or {}
    local inateSkillCount = #inateSkill
    local hasInnateSkillCount = #hasInnateSkill
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
            if nil == skillIconPath then return end

            local skillPanel = self:getControl("SkillPanel" .. i, nil, panel)
            local imgCtrl = self:getControl("SkillImage", nil, skillPanel)
            imgCtrl:setVisible(true)
            self:setImage("SkillImage", skillIconPath, skillPanel)
            self:setItemImageSize("SkillImage", skillPanel)
            skillPanel:setTouchEnabled(true)
            self:bindTouchEndEventListener(skillPanel, function()
                -- 显示技能悬浮框
                local rect = self:getBoundingBoxInWorldSpace(imgCtrl)
                SkillMgr:showSkillDescDlg(skillName, pet:getId(), true, rect)
            end)

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
                -- 进行图标置灰操作
                self:setCtrlEnabled("SkillImage", false, skillPanel)
            else
                self:setCtrlEnabled("SkillImage", true, skillPanel)
            end
        end
    end
end

-- 清除天技
function PetGrowingDlg:clearGodSkillInfo(panel)
    for i = 1, 3 do
        local skillPanel = self:getControl("SkillPanel" .. i, nil, panel)
        self:getControl("SkillImage", nil, skillPanel):setVisible(false)
        skillPanel:setTouchEnabled(false)
    end

    self:updateBtnStatus()
end

function PetGrowingDlg:setSliderInfo(name, curValue, maxValue, rootName, addValue)
    -- 设置进度数据
    local babyPetPanel = self:getControl("BabyPetPanel")
    local rootPanel = self:getControl(rootName, nil, babyPetPanel)
    self:setLabelText(name.."Label", (curValue + addValue).."/"..maxValue, rootPanel)
    self:setLabelText(name.."Label_1", (curValue + addValue).."/"..maxValue, rootPanel)

    -- 设置变化值
    self:setLabelColorByValue(name.."ChangeLabel", addValue)

    -- 设置进度条
    local backImg = nil
    local folatImg = nil
    local backValue, value

    if addValue > 0 then
        backImg = ResMgr.ui.progressbar43
        backValue = addValue + curValue
        value = curValue

        if backValue > maxValue then
            backValue = maxValue
        end
    elseif addValue < 0 then
        backImg = ResMgr.ui.progressbar44
        backValue = curValue
        value = curValue + addValue
        if value < 0 then
            value = 0
        end
    else
        backImg = ResMgr.ui.progressbar41
        backValue = curValue
        value = curValue
    end

    self:setProgressBar(name.."Bar", value, maxValue, rootPanel)

    local bar = self:getControl(name.."Bar_1", Const.UIProgressBar, rootPanel)
    bar:loadTexture(backImg, ccui.TextureResType.plistType)
    self:setProgressBar(name.."Bar_1", backValue, maxValue, rootPanel)

    -- 更新布局
    self:updateLayout(name.."EffectPanel")
end

function PetGrowingDlg:setLabelColorByValue(name, valueAdd, color, root)
    if valueAdd == nil  then  return end

    if valueAdd < 0 then
        self:setLabelText(name, valueAdd, root, color or COLOR3.RED)
    elseif valueAdd > 0 then
        self:setLabelText(name, string.format("+%d", valueAdd), root, color or COLOR3.GREEN)
    else
        self:setLabelText(name, "", root)
    end
end


function PetGrowingDlg:setItemInfo(panelName)
    local panel = self:getControl(panelName)
    local itemName = CHS[3003394]
    local icon = InventoryMgr:getIconByName(itemName)
    self:setImage("ItemImage", ResMgr:getItemIconPath(icon), panel)
    self:setItemImageSize("ItemImage", panel)

    local amount = InventoryMgr:getAmountByNameIsForeverBind(itemName, self:isUseLimitedItem())

    if amount > 999 then amount = "*" end

    self:setLabelText("ItemUseNumLabel", amount, panel)
    if amount == 0 then
        self:getControl("ItemUseNumLabel", Const.UITextField, panel):setColor(COLOR3.RED)
    else
        self:getControl("ItemUseNumLabel", Const.UITextField, panel):setColor(COLOR3.BROWN)
    end

    self:updateLayout("Panel", panel)
end

function PetGrowingDlg:isUseLimitedItem()
    local panel = self:getControl("WildPetPanel")
    return self:isCheck("CheckBox", panel)
end

function PetGrowingDlg:setCheckBoxInfo(boolValue)
    local panel = self:getControl("WildPetPanel")
    self:setCheck("CheckBox", boolValue, panel)
    panel = self:getControl("BabyPetPanel")
    self:setCheck("CheckBox", boolValue, panel)
end


function PetGrowingDlg:bindCheckBox()
    local panel = self:getControl("WildPetPanel")
    self:bindCheckBoxListener("CheckBox", self.onCheckBox, panel)
    panel = self:getControl("BabyPetPanel")
    self:bindCheckBoxListener("CheckBox", self.onCheckBox, panel)
end

function PetGrowingDlg:onCheckBox(sender, type)
    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
        self:setCheckBoxInfo(true)
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
        self:setCheckBoxInfo(false)
    end

    self:MSG_INVENTORY()
end

function PetGrowingDlg:MSG_INVENTORY(sender, eventType)
    self:setItemInfo("WildPetPanel")
    self:setItemInfo("BabyPetPanel")
end

function PetGrowingDlg:onUseButton(sender, eventType)
    self:useItem(CHS[2000049])
end

function PetGrowingDlg:onRewashButton(sender, eventType)
    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    if GROW_TYPE.DEVELOPING == curType then
        if self.totalAddValue and self.totalAddValue > 0 then
            gf:confirm(CHS[3003395], function()
                self:useItem(CHS[2000049])
            end, function() gf:ShowSmallTips(CHS[3003396]) end)
        else
            self:useItem(CHS[2000049])
        end
    elseif GROW_TYPE.GOD_SKILL == curType then
        if self:isFullSkills() then
            gf:ShowSmallTips(CHS[5000232])
            return
        end

        if self:haveGodSkillTemp() and self:getNewGodSkill() then
            gf:confirm(CHS[5000226], function()
                self:useItem(CHS[2000049])
            end, function()
                gf:ShowSmallTips(CHS[5000227])
            end)
        else
            self:useItem(CHS[2000049])
        end
    end
end

function PetGrowingDlg:onReplaceButton(sender, eventType)
    if self.selectPet == nil then return end

    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    if GROW_TYPE.DEVELOPING == curType then
        if not self.haveTemp then
            gf:ShowSmallTips(CHS[3003397])
            return
        end

        -- 安全锁判断
        if self:checkSafeLockRelease("onReplaceButton", sender, eventType) then
            return
        end

        -- 保存
        gf:CmdToServer("CMD_SET_SHAPE_TEMP", {
            no = self.selectPet:queryBasicInt("no"),
            is_set = 1
        })
    elseif GROW_TYPE.GOD_SKILL == curType then
        if Me:isInJail() then   -- 处于监禁状态
            gf:ShowSmallTips(CHS[5000228])
            return
        end

        if Me:isInCombat() then -- 处于战斗状态
            gf:ShowSmallTips(CHS[5000229])
            return
        end

        if not self:haveGodSkillTemp() then -- 未进行洗炼技能
            gf:ShowSmallTips(CHS[5000230])
            return
        end

        local washSkill = PetMgr:getGrowGodSkill(self.selectPet:getId())
        if not washSkill or #washSkill == 0 then    -- 未洗炼出技能
            gf:ShowSmallTips(CHS[7200017])
            return
        end

        if #SkillMgr:getPetRawSkillNoAndLadder(self.selectPet:getId()) == 3 then    -- 天生技能已满
            gf:ShowSmallTips(CHS[8000007])
            return
        end

        -- 安全锁判断
        if self:checkSafeLockRelease("onReplaceButton", sender, eventType) then
            return
        end

        if self:isHaveGodSkill() then
            gf:confirm(CHS[5000231], function()
                PetMgr:requestPetGodSkill(self.selectPet:queryBasicInt("id"), "save")
                if DlgMgr:isDlgOpened("PetGrowingDlg") then
                self:clearGodSkillInfo(self:getControl("AfterPanel"))
                end
            end, function()
            end)
        else
            PetMgr:requestPetGodSkill(self.selectPet:queryBasicInt("id"), "save")
            self:clearGodSkillInfo(self:getControl("AfterPanel"))
        end
    end
end

function PetGrowingDlg:onWashGrowingRuleButton(sender, eventType)
    DlgMgr:openDlg("ResetRuleDlg")
end

function PetGrowingDlg:onGrowingButton(sender, eventType)
    self:switchTab(sender, GROW_TYPE.DEVELOPING)
end

function PetGrowingDlg:onSkillButton(sender, eventType)
    self:switchTab(sender, GROW_TYPE.GOD_SKILL)
end

function PetGrowingDlg:onItemPanel(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[3003394], rect)
end

function PetGrowingDlg:useItem(name)
    local pet = self.selectPet

    if PetMgr:isTimeLimitedPet(pet) then
        gf:ShowSmallTips(CHS[7000085])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003398])
        return
    end

    if pet == nil then return end

    local para = nil
    local func = function()
        if not PetMgr:getCanFeedSuperLuLimit() then
            gf:ShowSmallTips(CHS[5000233])
            return false
        end

        return true
    end

    if GROW_TYPE.DEVELOPING == curType then
        para = "refine"
    elseif GROW_TYPE.GOD_SKILL == curType then
        para = "refresh"
    end

    if pet:queryInt("rank") == Const.PET_RANK_WILD then
        para = "reset"
        func = nil
    end

    InventoryMgr:feedPetByIsLimitItem(name, pet, para, self:isUseLimitedItem(), nil, func)
end

function PetGrowingDlg:MSG_UPDATE_PETS(data)
    if not self.selectPet then return end
    for i = 1, data.count do
        if data[i].no == self.selectPet:queryBasicInt("no") then
            self.selectPet = PetMgr:getPetByNo(data[i].no)
        end
    end

    PetGrowingDlg:setPetInfo(self.selectPet)
end

function PetGrowingDlg:MSG_REFINE_PET_RESULT(data)
end

function PetGrowingDlg:MSG_UPDATE_SKILLS(data)
    if not self.selectPet then return end
    self:setOtherInfo(self.selectPet)
end

function PetGrowingDlg:MSG_PREVIEW_SPECIAL_SKILL()
    if not self.selectPet then return end

    self:setGodSkillInfo(self:getControl("AfterPanel"), PetMgr:getGrowGodSkill(self.selectPet:queryBasicInt("id")))
end

return PetGrowingDlg
