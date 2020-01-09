-- PetGrowPandectDlg.lua
-- Created by yangym May/16/2017
-- 宠物成长总览

local PetGrowPandectDlg = Singleton("PetGrowPandectDlg", Dialog)

local INNATE_SKILLS = {
    CHS[3003416], CHS[3003417], CHS[3003418], CHS[3003419], CHS[3003420],
    CHS[3003421], CHS[3003422], CHS[3003423], CHS[3003424], CHS[3003425],
    CHS[3003426], CHS[3003427], CHS[3003428], CHS[3003429],
}

function PetGrowPandectDlg:init()
    self:initPet()
    self:initPageCheckBox()

    self:setFlyInfo()

    local function onScrollView(sender, eventType)
        if ccui.ScrollviewEventType.scrolling == eventType then
            local y = sender:getInnerContainer():getPositionY()
            self:setCtrlVisible("DownImage", y < -3)
        end
    end
    self:getControl("ListView"):addScrollViewEventListener(onScrollView)
    performWithDelay(self.root, function ()
        self:setCtrlVisible("DownImage", true)
    end, 0)
end

local RES_SKILL_FRAME = ResMgr.ui.pet_skill_grid

function PetGrowPandectDlg:initPet()
    local pet = PetMgr:getLastSelectPet()
    if pet then

        self:setPetInfo(pet)
    end
end

function PetGrowPandectDlg:initPageCheckBox()
    local pageCheckBox = self:getControl("PageCheckBox")
    pageCheckBox:setSelectedState(true)
end

function PetGrowPandectDlg:setPetInfo(pet)
    self.pet = pet
    self:setPetPortrait(pet)
    self:setPetGrowing(pet)
    self:setPetSkills(pet)
    self:setPetOthers(pet)
end

function PetGrowPandectDlg:setPetPortrait(pet)
    -- 宠物形象
    local nameLevel = string.format(CHS[4000391], pet:getShowName(), pet:queryBasicInt("level"))
    self:setLabelText("PetNameLabel", nameLevel)
    self:setPortrait("GuardIconPanel", pet:getDlgIcon(nil, nil, true), 0, nil, true)
    PetMgr:setPetLogo(self, pet)

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

function PetGrowPandectDlg:setPetGrowing(pet)

    local lifeShape = pet:queryInt("pet_life_shape")
    local manaShape = pet:queryInt("pet_mana_shape")
    local speedShape = pet:queryInt("pet_speed_shape")
    local phyShape = pet:queryInt("pet_phy_shape")
    local magShape = pet:queryInt("pet_mag_shape")

    -- 气血成长
    local basicLife = PetMgr:getPetBasicShape(pet, "life_effect")
    self:setLabelText("LifeEffectLabel", lifeShape)
    self:setLabelText("LifeEffectLabel_1", string.format("(%d + %d)", basicLife,  lifeShape - basicLife))
    self:setCtrlVisible("LifeEffectLabel_1", lifeShape ~= basicLife)

    -- 法力成长
    local basicMana = PetMgr:getPetBasicShape(pet, "mana_effect")
    self:setLabelText("ManaEffectLabel", manaShape)
    self:setLabelText("ManaEffectLabel_1", string.format("(%d + %d)", basicMana,  manaShape - basicMana))
    self:setCtrlVisible("ManaEffectLabel_1", manaShape ~= basicMana)

    -- 速度成长
    local basicSpeed = PetMgr:getPetBasicShape(pet, "speed_effect")
    self:setLabelText("SpeedEffectLabel", speedShape)
    self:setLabelText("SpeedEffectLabel_1", string.format("(%d + %d)", basicSpeed,  speedShape - basicSpeed))
    self:setCtrlVisible("SpeedEffectLabel_1", speedShape ~= basicSpeed)

    -- 物攻成长
    local basicPhy = PetMgr:getPetBasicShape(pet, "phy_effect")
    self:setLabelText("PhyEffectLabel", phyShape)
    self:setLabelText("PhyEffectLabel_1", string.format("(%d + %d)", basicPhy,  phyShape - basicPhy))
    self:setCtrlVisible("PhyEffectLabel_1", phyShape ~= basicPhy)

    -- 法攻成长
    local basicMag = PetMgr:getPetBasicShape(pet, "mag_effect")
    self:setLabelText("MagEffectLabel", magShape)
    self:setLabelText("MagEffectLabel_1", string.format("(%d + %d)", basicMag,  magShape - basicMag))
    self:setCtrlVisible("MagEffectLabel_1", magShape ~= basicMag)

    -- 总成长
    local totalAll = lifeShape + manaShape + speedShape + phyShape + magShape
    local totalBasic = basicLife + basicMana + basicSpeed + basicPhy + basicMag
    self:setLabelText("TotalEffectLabel", totalAll)
    self:setLabelText("TotalEffectLabel_1", string.format("(%d + %d)", totalBasic,  totalAll - totalBasic))
    self:setCtrlVisible("TotalEffectLabel_1", totalAll ~= totalBasic)
end

function PetGrowPandectDlg:setPetSkills(pet)
    if nil == pet then return end
    -- 获取宠物的类型
    local petRank = pet:queryInt('rank')

    -- 获取技能
    local inateSkill = PetMgr:petHaveRawSkill(pet:queryBasic("raw_name")) or {}
    local hasInnateSkill = SkillMgr:getPetRawSkillNoAndLadder(pet:getId()) or {}
    local inateSkillCount = #inateSkill
    local hasInnateSkillCount = #hasInnateSkill

    -- 在技能列表框 中设置技能图标
    local i = 0
    local index = 1
    local isDefault = false

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

            local panel = self:getControl("SkillImagePanel_" .. i)
            local image = self:getControl("CostImage", nil, panel)
            self:setImage("CostImage", skillIconPath, panel)
            self:setItemImageSize("CostImage", panel)

            index = index + 1

            -- 判断宠物是否已经拥有这个技能
            local isHas = false
            for j = 1, hasInnateSkillCount do
                if skill.skill_no == hasInnateSkill[j].no then
                    -- 标志已经拥有
                    isHas = true
                end
            end

            -- 如果宠物未拥有这个技能
            if not isHas then
                -- 进行图标置灰操作
                gf:grayImageView(image)
            else
                gf:resetImageView(image)
            end

            image:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local rect = self:getBoundingBoxInWorldSpace(sender)
                    SkillMgr:showSkillDescDlg(skillName, pet:getId(), true, rect)
                end
            end)
        end
    end

    for k = inateSkillCount + 1, 3 do
        self:setImagePlist("BKImage", ResMgr.ui.bag_can_not_use_item_img, "SkillImagePanel_" .. k)
    end
end

function PetGrowPandectDlg:setPetOthers(pet)
    -- 点化情况
    local dianhuaText
    local enchant = pet:queryBasicInt("enchant")
    if enchant == 2 then
        dianhuaText = CHS[7002292]
    elseif enchant == 1 then
        local now = pet:queryBasicInt("enchant_nimbus")
        local total = Formula:getPetDianhuaMaxNimbus(pet)
        dianhuaText = string.format("%0.2f", math.floor(now / total * 100 * 100) * 0.01) .. "%"
    else
        dianhuaText = CHS[7002293]
    end

    if dianhuaText == CHS[7002293] then
        self:setLabelText("Label_80", dianhuaText, "DianHuaPanel", COLOR3.GRAY)
    else
        self:setLabelText("Label_80", dianhuaText, "DianHuaPanel")
    end

    -- 羽化
    local eclosion = pet:queryBasicInt("eclosion")
    -- eclosion 0 未开启羽化                     1  开启羽化             2  完成羽化
    if eclosion == 0 then
        self:setLabelText("Label_80", CHS[4100990], "YuHuaPanel", COLOR3.GRAY)
    elseif eclosion == 1 then
        self:setLabelText("Label_80", string.format("%s (%0.2f%%)", PetMgr:getYuhuaStageChs(pet), PetMgr:getYuhuaPercent(pet)), "YuHuaPanel")
    else
        self:setLabelText("Label_80", CHS[4100991], "YuHuaPanel")
    end

    -- 幻化情况
    local morphedCount = PetMgr:getMorphedCount(pet)
    local morphText = string.format("%d/15", morphedCount)
    self:setLabelText("Label_80", morphText, "HuanHuaPanel")

    -- 法攻/物攻强化
    local developType
    local developKey
    local petPolar = pet:queryBasicInt("polar")
    if petPolar > 0 then
        developType = CHS[7002094]
        developKey = "mag"
        self:setImage("QiangHuaImage", ResMgr.ui.mag_img)
        self:setLabelText("QiangHua_Label", CHS[7003086])
    else
        developType = CHS[7002095]
        developKey = "phy"
        self:setImage("QiangHuaImage", ResMgr.ui.phy_img)
        self:setLabelText("QiangHua_Label", CHS[7003085])
    end

    local developLevel = pet:queryInt(developKey .. "_rebuild_level")
    local developRate = pet:queryInt(developKey .. "_rebuild_rate")
    local developStr = string.format(CHS[7002294], developLevel, developRate / 100)
    if developLevel >= PetMgr:getMaxDevelopLevel(pet) then
        developStr = string.format(CHS[6000179], developLevel)
    end

    local rank = pet:queryBasicInt("rank")
    if rank == Const.PET_RANK_ELITE or rank == Const.PET_RANK_EPIC then
        self:setLabelText("Label_80", CHS[4300345], "QiangHuaPanel")
    else
        self:setLabelText("Label_80", developStr, "QiangHuaPanel")
    end

    -- 进化情况
    local evolveStr
    if PetMgr:isEvolved(pet) then
        evolveStr = pet:queryBasic("evolve")
        self:setLabelText("Label_80", evolveStr, "EvolvePanel")
    else
        if rank == Const.PET_RANK_ELITE or rank == Const.PET_RANK_EPIC then
            self:setLabelText("Label_80", CHS[4300346], "EvolvePanel")
        else
            evolveStr = CHS[7002255]
            self:setLabelText("Label_80", evolveStr, "EvolvePanel", COLOR3.GRAY)
        end
    end
end

function PetGrowPandectDlg:setFlyInfo()
    local id = PetMgr:getFlyTaskPetId()
    local pet = self.pet

    if (not id) or (not pet) then
        return
    end

    -- 飞升情况
    local flyStr
    if pet:getLevel() < 110 then
        flyStr = CHS[7002295]
    elseif PetMgr:isFlyPet(pet) then
        flyStr = CHS[7002287]
    elseif (TaskMgr:getTaskByName(CHS[7002297]) and id == pet:getId()) then
        flyStr = CHS[7002296]
    else
        flyStr = CHS[7002298]
    end

    if flyStr == CHS[7002295] then
        self:setLabelText("Label_80", flyStr, "FlyPanel", COLOR3.GRAY)
    else
        self:setLabelText("Label_80", flyStr, "FlyPanel")
    end

    local flyPanel = self:getControl("FlyPanel")
    local function func()
        if flyStr == CHS[7002296] then
            local decStr = TaskMgr:getTaskByName(CHS[7002297]).task_prompt
            AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
        elseif flyStr == CHS[7002298] then
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[7002291]))
        end
    end

    self:bindTouchEndEventListener(flyPanel, func)
end

return PetGrowPandectDlg
