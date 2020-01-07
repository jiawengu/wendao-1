-- PetEvolveDlg.lua
-- Created by songcw July/1/2016
-- 宠物进化界面

local PetEvolveDlg = Singleton("PetEvolveDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local DataObject = require("core/DataObject")

local CHECKBOS = {
    "SilverCheckBox",
    "GoldCheckBox",
}

function PetEvolveDlg:init()
    self:bindListener("GoOnButton", self.onGoOnButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("EvolveButton", self.onEvolveButton)
    self:bindListener("GoBackButton", self.onGoBackButton)
    self:bindListener("GoldCoinPanel", self.onGoldCoinButton)
    self:bindListener("SliverCoinPanel", self.onSilverAddButton)
    self:bindListener("HeadPanel2", self.onAddOtherPetButton)


    self.preData = nil      -- 预览信息
    self.mainPet = nil      -- 主宠
    self.otherPet = nil     -- 副宠

    self:setCtrlVisible("EvolvePanel", true)
    self:setCtrlVisible("PreviewPanel", false)

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, CHECKBOS, self.onCoinCheckBox)
    local index = InventoryMgr.UseLimitItemDlgs[self.name] or 2
    self.radioGroup:setSetlctByName(CHECKBOS[index])

    self:hookMsg("MSG_PREVIEW_PET_EVOLVE")
    self:hookMsg("MSG_SWITCH_SERVER")

    self:initPet()
end

function PetEvolveDlg:initPet()
    local pet = PetMgr:getLastSelectPet()
    if pet then
        self:setMainPet(pet)
    end
end

-- 设置主宠物
function PetEvolveDlg:setMainPet(pet)
    self.mainPet = pet

    local panel = self:getControl("HeadPanel1")
    -- 小头像
    self:setImage("PetImage", ResMgr:getSmallPortrait(pet:queryBasicInt("portrait")), panel)
    self:setItemImageSize("PetImage", panel)

    -- 等级
    self:setNumImgForPanel("PetImage", ART_FONT_COLOR.NORMAL_TEXT, pet:queryBasicInt("level"), false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- pet 标记（贵重，点化、相性）
    PetMgr:setPetLogo(self, pet)

    -- 主宠基本属性
    self:setMainPetBasicAttrib(pet, "MainPetAttribPanel")
end

function PetEvolveDlg:setPrePetBasicAttrib(pet, panelName)
    local panel = self:getControl(panelName)

    local function getColor(main, pre)
    	if main == pre then
            return COLOR3.TEXT_DEFAULT, ""
    	elseif main < pre then
            return COLOR3.GREEN, "↑"
    	else
            return COLOR3.RED, "↓"
    	end
    end

    -- 魂魄
    local soul = pet:queryBasic("evolve")
    if soul == "" then soul = pet:queryBasic("raw_name") end
    self:setLabelText("SoulLabel", soul , panel)

    -- 携带等级
    self:setLabelText("LevelLabel", pet:queryInt("req_level"), panel)

    -- 气血基础成长
    local basicLife = PetMgr:getPetBasicShape(pet, "life_effect")
    local lifeMax = PetMgr:getPetBasicMax(pet, "life")
    local lifeColor, lifeBuff = getColor(self.mainPetAtt.lifeMax, lifeMax)
    self:setLabelText("LifeLabel", basicLife .. "/" .. lifeMax .. lifeBuff, panel, lifeColor)

    -- 法力基础成长
    local basicMana = PetMgr:getPetBasicShape(pet, "mana_effect")
    local manaMax = PetMgr:getPetBasicMax(pet, "mana")
    local manaColor, manaBuff = getColor(self.mainPetAtt.manaMax, manaMax)
    self:setLabelText("ManaLabel", basicMana .. "/" .. manaMax .. manaBuff, panel, manaColor)

    -- 速度基础成长
    local basicSpeed = PetMgr:getPetBasicShape(pet, "speed_effect")
    local speedMax = PetMgr:getPetBasicMax(pet, "speed")
    local speedColor, speedBuff = getColor(self.mainPetAtt.speedMax, speedMax)
    self:setLabelText("SpeedLabel", basicSpeed .. "/" .. speedMax .. speedBuff, panel, speedColor)

    -- 物攻基础成长
    local basicPhy = PetMgr:getPetBasicShape(pet, "phy_effect")
    local phy_attackdMax = PetMgr:getPetBasicMax(pet, "phy_attack")
    local phyColor, phyBuff = getColor(self.mainPetAtt.phy_attackdMax, phy_attackdMax)
    self:setLabelText("PhyLabel", basicPhy .. "/" .. phy_attackdMax .. phyBuff, panel, phyColor)

    -- 法攻基础成长
    local basicMag = PetMgr:getPetBasicShape(pet, "mag_effect")
    local mag_attackMax = PetMgr:getPetBasicMax(pet, "mag_attack")
    local magColor, magBuff = getColor(self.mainPetAtt.mag_attackMax, mag_attackMax)
    self:setLabelText("MagLabel", basicMag .. "/" .. mag_attackMax .. magBuff, panel, magColor)

    -- 基础总成长
    local total = basicLife + basicMana + basicSpeed + basicPhy + basicMag
    local totalMax = lifeMax + manaMax + speedMax + phy_attackdMax + mag_attackMax
    local totalColor, totalBuff = getColor(self.mainPetAtt.totalMax, totalMax)
    self:setLabelText("TotalLabel", total .. "/" .. totalMax .. totalBuff, panel, totalColor)
end

function PetEvolveDlg:setMainPetBasicAttrib(pet, panelName)
    local panel = self:getControl(panelName)

    -- 魂魄
    local soul = pet:queryBasic("evolve")
    if soul == "" then soul = CHS[5000059] end
    self:setLabelText("SoulLabel", soul, panel)

    -- 携带等级
    self:setLabelText("LevelLabel", pet:queryInt("req_level"), panel)

    self.mainPetAtt = {}

    -- 气血基础成长
    local basicLife = PetMgr:getPetBasicShape(pet, "life_effect")
    local lifeMax = PetMgr:getPetBasicMax(pet, "life")
    self.mainPetAtt.lifeMax = lifeMax
    self:setLabelText("LifeLabel", basicLife .. "/" .. lifeMax, panel)

    -- 法力基础成长
    local basicMana = PetMgr:getPetBasicShape(pet, "mana_effect")
    local manaMax = PetMgr:getPetBasicMax(pet, "mana")
    self.mainPetAtt.manaMax = manaMax
    self:setLabelText("ManaLabel", basicMana .. "/" .. manaMax, panel)

    -- 速度基础成长
    local basicSpeed = PetMgr:getPetBasicShape(pet, "speed_effect")
    local speedMax = PetMgr:getPetBasicMax(pet, "speed")
    self.mainPetAtt.speedMax = speedMax
    self:setLabelText("SpeedLabel", basicSpeed .. "/" .. speedMax, panel)

    -- 物攻基础成长
    local basicPhy = PetMgr:getPetBasicShape(pet, "phy_effect")
    local phy_attackdMax = PetMgr:getPetBasicMax(pet, "phy_attack")
    self.mainPetAtt.phy_attackdMax = phy_attackdMax
    self:setLabelText("PhyLabel", basicPhy .. "/" .. phy_attackdMax, panel)

    -- 法攻基础成长
    local basicMag = PetMgr:getPetBasicShape(pet, "mag_effect")
    local mag_attackMax = PetMgr:getPetBasicMax(pet, "mag_attack")
    self.mainPetAtt.mag_attackMax = mag_attackMax
    self:setLabelText("MagLabel", basicMag .. "/" .. mag_attackMax, panel)

    -- 基础总成长
    local total = basicLife + basicMana + basicSpeed + basicPhy + basicMag
    local totalMax = lifeMax + manaMax + speedMax + phy_attackdMax + mag_attackMax
    self.mainPetAtt.totalMax = totalMax
    self:setLabelText("TotalLabel", total .. "/" .. totalMax, panel)
end

-- 增加副宠按钮
function PetEvolveDlg:setOtherPet(pet)
    self.otherPet = pet

    local panel = self:getControl("HeadPanel2")
    self:setCtrlVisible("NoneImage", false, panel)
    -- 小头像
    self:setImage("PetImage", ResMgr:getSmallPortrait(pet:queryBasicInt("portrait")), panel)
    self:setItemImageSize("PetImage", panel)

    -- 等级
    self:setNumImgForPanel("PetImage", ART_FONT_COLOR.NORMAL_TEXT, pet:queryBasicInt("level"), false, LOCATE_POSITION.LEFT_TOP, 21, panel)


    self:setLabelText("SelectLabel", "", panel)

    -- pet 标记（贵重，点化、相性）
    PetMgr:setPetLogo(self, pet, panel)

    self:setPrePetBasicAttrib(pet, "PrePetAttribPanel")
end

-- 增加副宠按钮
function PetEvolveDlg:onAddOtherPetButton(sender, eventType)
    if not self.mainPet then return end

    if PetMgr:getPetCount() == 1 then
        -- 只有一个宠物。则没有可选择副宠
        gf:ShowSmallTips(CHS[4100153])
        return
    end

    -- 打开选择副宠界面
    -- todo
    local dlg = DlgMgr:openDlg("PetEvolveSubmitPetDlg")
    dlg:setSubType("evolve")
    dlg:setPetList(self.mainPet)
end

-- 通用条件判断
function PetEvolveDlg:isMeetCondition(mainPet, otherPet)
    -- 类型判断
    local rank = ""
    if mainPet:queryInt('rank') == Const.PET_RANK_WILD then
        gf:ShowSmallTips(string.format(CHS[4100154], CHS[3003810]))
        return
    elseif mainPet:queryInt('rank') == Const.PET_RANK_ELITE then
        gf:ShowSmallTips(string.format(CHS[4100154], CHS[3003813]))
        return
    elseif mainPet:queryInt('rank') == Const.PET_RANK_EPIC then
        gf:ShowSmallTips(string.format(CHS[4100154], CHS[3003814]))
        return
    end

    -- 等级
    if mainPet:queryBasicInt("level") > Me:queryBasicInt("level") + 15 then
        gf:ShowSmallTips("")
        return
    end

    if mainPet:queryInt("req_level") > Me:getLevel() or otherPet:queryInt("req_level") > Me:getLevel() then
        gf:ShowSmallTips(CHS[4100155])
        return
    end

    if mainPet:queryInt("req_level") > otherPet:queryInt("req_level") then
        gf:ShowSmallTips(CHS[4100156])
        return
    end

    -- 状态
    local pet_status = otherPet:queryInt("pet_status")
    if pet_status == 1 then
        gf:ShowSmallTips(string.format(CHS[4100157], CHS[2000026]))
        return
    elseif pet_status == 2 then
        gf:ShowSmallTips(string.format(CHS[4100157], CHS[2000027]))
        return
    end

    -- 天书
    if PetMgr:haveGoodbookSkill(otherPet:getId()) then
        gf:ShowSmallTips(CHS[4100158])
        return
    end

    return true
end

function PetEvolveDlg:onGoOnButton(sender, eventType)

    if self.mainPet and PetMgr:isTimeLimitedPet(self.mainPet) then
        gf:ShowSmallTips(CHS[7000088])
        return
    end

    if not self.mainPet or not self.otherPet then
        gf:ShowSmallTips(CHS[4100262])
        return
    end
    if not self:isMeetCondition(self.mainPet, self.otherPet) then return end

    if self.preData and self.preData.mainPetId == self.mainPet:getId() and self.preData.otherPetId == self.otherPet:getId() then
        self:MSG_PREVIEW_PET_EVOLVE(self.preData)
        return
    end
    PetMgr:previewEvolvePet(self.mainPet, self.otherPet)

end

-- 设置预览进化界面
function PetEvolveDlg:setPreView(data)
    if not self.mainPet or not self.otherPet then return end
    local otherPet = self.otherPet

    -- 属性
    self:setLabelText("ValueLabel", data.lifeMax, "LifePanel")
    self:setLabelText("ValueLabel", data.manaMax, "ManaPanel")
    self:setLabelText("ValueLabel", data.speedMax, "SpeedPanel")
    self:setLabelText("ValueLabel", data.defMax, "DefencePanel")
    self:setLabelText("ValueLabel", data.phyMax, "PhyPowerPanel")
    self:setLabelText("ValueLabel", data.magMax, "MagPowerPanel")
    self:setLabelText("ValueLabel", otherPet:queryInt("req_level"), "CatchLevelPanel")

    -- =========成长==============
    -- 气血
    local basicLife = PetMgr:getPetBasicShape(otherPet, "life_effect")
    if data.lifeGrow ~= basicLife then
        self:setLabelText("ValueLabel", string.format("%d(%d + %d)", data.lifeGrow, basicLife, data.lifeGrow - basicLife), "LifeEffectPanel")
    else
        self:setLabelText("ValueLabel", data.lifeGrow, "LifeEffectPanel")
    end

    -- 法力
    local basicMana = PetMgr:getPetBasicShape(otherPet, "mana_effect")
    if data.manaGrow ~= basicMana then
        self:setLabelText("ValueLabel", string.format("%d(%d + %d)", data.manaGrow, basicMana, data.manaGrow - basicMana), "ManaEffectPanel")
    else
        self:setLabelText("ValueLabel", data.manaGrow, "ManaEffectPanel")
    end

    -- 速度
    local basicSpeed = PetMgr:getPetBasicShape(otherPet, "speed_effect")
    if data.speedGrow ~= basicSpeed then
        self:setLabelText("ValueLabel", string.format("%d(%d + %d)", data.speedGrow, basicSpeed, data.speedGrow - basicSpeed), "SpeedEffectPanel")
    else
        self:setLabelText("ValueLabel", data.speedGrow, "SpeedEffectPanel")
    end

    -- 物攻
    local basicPhy = PetMgr:getPetBasicShape(otherPet, "phy_effect")
    if data.phyGrow ~= basicPhy then
        self:setLabelText("ValueLabel", string.format("%d(%d + %d)", data.phyGrow, basicPhy, data.phyGrow - basicPhy), "PhyEffectPanel")
    else
        self:setLabelText("ValueLabel", data.phyGrow, "PhyEffectPanel")
    end

    -- 法功
    local basicMag = PetMgr:getPetBasicShape(otherPet, "mag_effect")
    if data.magGrow ~= basicMag then
        self:setLabelText("ValueLabel", string.format("%d(%d + %d)", data.magGrow, basicMag, data.magGrow - basicMag), "MagEffectPanel")
    else
        self:setLabelText("ValueLabel", data.magGrow, "MagEffectPanel")
    end

    -- 总成长
    local totalAll = data.lifeGrow + data.manaGrow + data.speedGrow + data.phyGrow + data.magGrow
    local totalBasic = basicLife + basicMana + basicSpeed + basicPhy + basicMag
    if totalAll ~= totalBasic then
        self:setLabelText("ValueLabel", string.format("%d(%d + %d)", totalAll, totalBasic, totalAll - totalBasic), "TotalEffectPanel")
    else
        self:setLabelText("ValueLabel", totalAll, "TotalEffectPanel")
    end

    local obj = DataObject.new()
    local data = {}
    data.max_eclosion_nimbus = 0
    data.rank = otherPet:queryBasicInt("rank")
    data.eclosion_stage = self.mainPet:queryBasicInt("eclosion_stage")
    data.raw_name = otherPet:queryBasic("raw_name")
    data.req_level = otherPet:queryInt("req_level")
    obj:absorbBasicFields(data)

    local total = Formula:getPetYuhuaMaxNimbus(obj)
    if PetMgr:isMountPet(self.mainPet) then
        total = Formula:getPetYuhuaMaxNimbus(self.mainPet)
    end

    -- 羽化
    if PetMgr:isYuhuaCompleted(self.mainPet) then
        self:setLabelText("ValueLabel", string.format(CHS[4100987], total, total), "YuHuaPanel")
    else
        local now = self.mainPet:queryBasicInt("eclosion_nimbus")
        self:setLabelText("ValueLabel", string.format("%s %d/%d(%0.2f%%)", PetMgr:getYuhuaStageChs(self.mainPet), now, total, now / total * 100), "YuHuaPanel")
    end

    -- =======强化=========
    local phyStrongTime = self.mainPet:queryInt("phy_rebuild_level")
    local magStrongTime = self.mainPet:queryInt("mag_rebuild_level")
    local phyStrongRate = self.mainPet:queryInt("phy_rebuild_rate")
    local magStrongRate = self.mainPet:queryInt("mag_rebuild_rate")
    if phyStrongRate == 0 then
        self:setLabelText("ValueLabel", phyStrongTime .. CHS[3003367], "PhyStrengthPanel")
    else
        self:setLabelText("ValueLabel", phyStrongTime .. CHS[3003368] .. phyStrongRate / 100 .. "%)", "PhyStrengthPanel")
    end

    -- 攻击强化
    if magStrongRate == 0 then
        self:setLabelText("ValueLabel", magStrongTime .. CHS[3003367], "MagStrengthPanel")
    else
        self:setLabelText("ValueLabel", magStrongTime .. CHS[3003368] .. magStrongRate / 100 .. "%)", "MagStrengthPanel")
    end

    -- 点化
    local now = self.mainPet:queryBasicInt("enchant_nimbus")
    local total = Formula:getPetDianhuaMaxNimbus(otherPet)

    -- 主宠为精怪、御灵，进化后点化上限不变
    local mount_type = self.mainPet:queryInt("mount_type")
    if mount_type == MOUNT_TYPE.MOUNT_TYPE_JINGGUAI or mount_type == MOUNT_TYPE.MOUNT_TYPE_YULING then
        total = Formula:getPetDianhuaMaxNimbus(self.mainPet)
    end

    local pers = math.floor(now / total * 100 * 100) * 0.01
    if self.mainPet:queryBasicInt("enchant") == 2 then
        self:setLabelText("ValueLabel", string.format(CHS[4100987], total, total), "DianHuaValuePanel")
    else
        self:setLabelText("ValueLabel", string.format("%d/%d (%0.2f", now, total, pers) .. "%)", "DianHuaValuePanel")
    end

    -- 魂魄
    local soul = otherPet:queryBasic("evolve")
    if soul == "" then soul = otherPet:queryBasic("raw_name") end
    self:setLabelText("ValueLabel", soul, "EvolveValuePanel")

    -- ==========形象=======
    -- 名字
    local nameLevel = string.format(CHS[4000391], self.mainPet:queryBasic("name"), self.mainPet:queryBasicInt("level"))
    self:setLabelText("PetNameLabel", nameLevel, "NamePanel")

    self:setPortrait("PetIconPanel", self.mainPet:getDlgIcon(), 0, nil, true)

    if ResMgr:getPetRankImagePath(otherPet) == ResMgr.ui.dianhua_word then
        self:setImage("SuffixImage", ResMgr:getPetRankImagePath(otherPet))
    else
        self:setImage("SuffixImage", ResMgr:getPetRankImagePath(self.mainPet))
    end

    -- 消耗元宝
    local cost
    if PetMgr:isMountPet(self.mainPet) and not PetMgr:isEvolved(self.mainPet) then
        cost = Formula:getPetEvolveCost(Const.MOUNT_PET_COST_REQ_LEVEL, otherPet:queryInt("req_level"))
    elseif PetMgr:isJinianPet(self.mainPet) and "" == self.mainPet:queryBasic("evolve") then
        cost = Formula:getPetEvolveCost(Const.JINIAN_PET_COST_REQ_LEVEL, otherPet:queryInt("req_level"))
    elseif not PetMgr:isEvolved(self.mainPet) and self.mainPet:queryBasic("raw_name") == CHS[7190018] then
        cost = Formula:getPetEvolveCost(Const.BAIGUOER_PET_COST_REQ_LEVEL, otherPet:queryInt("req_level"))
    else
        cost = Formula:getPetEvolveCost(self.mainPet:queryInt("req_level"), otherPet:queryInt("req_level"))
    end

    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(cost))
    self:setNumImgForPanel("ValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, "EvolveButton")

    local silverText, silverTextColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('silver_coin'))
    self:setNumImgForPanel("SilverCoinValuePanel", silverTextColor, silverText, false, LOCATE_POSITION.MID, 23)

    local goldText, goldTextColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('gold_coin'))
    self:setNumImgForPanel("GoldCoinValuePanel", goldTextColor, goldText, false, LOCATE_POSITION.MID, 23)

    -- 新宠物logo
    PetMgr:setPetLogo(self, self.mainPet, "PreviewPanel")


    self:updateLayout("AttribPanel")
end

function PetEvolveDlg:onCoinCheckBox(sender, eventType)
    self:setCtrlVisible("SilverImage", self.radioGroup:getSelectedRadioName() == "SilverCheckBox", "EvolveButton")
    self:setCtrlVisible("GoldImage", self.radioGroup:getSelectedRadioName() == "GoldCheckBox", "EvolveButton")

    if self.radioGroup:getSelectedRadioName() == "SilverCheckBox" then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name, 2)
    end
    if not self.mainPet then return end

    local strLimitedTime
    if self.radioGroup:getSelectedRadioName() == "SilverCheckBox" then
        if self.mainPet:query("gift") ~= "2" and Me:queryBasicInt('silver_coin') ~= 0 then
            if self.mainPet:queryBasicInt("gift") == 0 then
                local time = -(60 * 60 * 24 * 30 + gf:getServerTime() + Const.DELAY_TIME_BALANCE)
                strLimitedTime = gf:converToLimitedTimeDay(time)
            else
                strLimitedTime = gf:converToLimitedTimeDay(self.mainPet:queryBasicInt("gift") - 60 * 60 * 24 * 30)
            end
        else
            strLimitedTime = gf:converToLimitedTimeDay(self.mainPet:query("gift"))
        end
        gf:ShowSmallTips(CHS[4100159])
    elseif self.radioGroup:getSelectedRadioName() == "GoldCheckBox" then
        gf:ShowSmallTips(CHS[4100160])
        strLimitedTime = gf:converToLimitedTimeDay(self.mainPet:query("gift"))
    else
        strLimitedTime = gf:converToLimitedTimeDay(self.mainPet:query("gift"))
    end

    if not strLimitedTime then
        -- 隐藏
        self:setLabelText("LimitLabel", "")
    else
        self:setLabelText("LimitLabel", strLimitedTime)
    end
end

function PetEvolveDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("PetEvolveRuleDlg")
end

-- confirm step
function PetEvolveDlg:confirmByStep(step)
    if step == 1 then
        -- 主宠点化判断
        if self.mainPet:queryBasicInt("enchant") ~= 2 then
            local mount_type = self.mainPet:queryInt("mount_type")
            if mount_type == MOUNT_TYPE.MOUNT_TYPE_JINGGUAI or mount_type == MOUNT_TYPE.MOUNT_TYPE_YULING then
                -- "当前主宠后缀为精怪或御灵，进化后点化所需灵气将#R不会改变#n，是否继续？"
                gf:confirm(CHS[5410000],function ()
                    return self:confirmByStep(2)
                end)
            else
                -- "当前主宠未完成点化，进化后当前点化灵气不变，但灵气上线将按副宠携带等级重新计算，是否继续？\n#R建议主宠完成点化后再进行进化#n"
                gf:confirm(CHS[4100161],function ()
                    return self:confirmByStep(2)
                end)
            end
            return
        else
            if not PetMgr:isMountPet(self.mainPet) and not PetMgr:isYuhuaCompleted(self.mainPet) then
                gf:confirm(CHS[4100988],function ()
                    return self:confirmByStep(2)
                end)
                return
            elseif PetMgr:isMountPet(self.mainPet) and not PetMgr:isYuhuaCompleted(self.mainPet) then
                gf:confirm(CHS[4100989],function ()
                    return self:confirmByStep(2)
                end)
                return
            end
        end
        return self:confirmByStep(2)
    elseif step == 2 then
        -- 主副宠相性判断
        if self.mainPet:queryBasicInt("polar") == 0 and self.otherPet:queryBasicInt("polar") ~= 0 then
            -- 主宠无相性，副宠有相性
            gf:confirm(CHS[4100162],function ()
                return self:confirmByStep(3)
            end)
            return
        end

        if self.mainPet:queryBasicInt("polar") ~= 0 and self.otherPet:queryBasicInt("polar") == 0 then
            -- 主宠有相性，副宠无相性
            gf:confirm(CHS[4100163],function ()
                return self:confirmByStep(3)
            end)
            return
        end
        return self:confirmByStep(3)
    elseif step == 3 then
        -- 金银元宝是否足够判断
        local cost
        if PetMgr:isMountPet(self.mainPet) and not PetMgr:isEvolved(self.mainPet) then
            cost = Formula:getPetEvolveCost(Const.MOUNT_PET_COST_REQ_LEVEL, self.otherPet:queryInt("req_level"))
        elseif PetMgr:isJinianPet(self.mainPet) and "" == self.mainPet:queryBasic("evolve")  then
            cost = Formula:getPetEvolveCost(Const.JINIAN_PET_COST_REQ_LEVEL, self.otherPet:queryInt("req_level"))
        elseif not PetMgr:isEvolved(self.mainPet) and self.mainPet:queryBasic("raw_name") == CHS[7190018] then
            cost = Formula:getPetEvolveCost(Const.BAIGUOER_PET_COST_REQ_LEVEL, self.otherPet:queryInt("req_level"))
        else
            cost = Formula:getPetEvolveCost(self.mainPet:queryInt("req_level"), self.otherPet:queryInt("req_level"))
        end

        if self.radioGroup:getSelectedRadioName() == "SilverCheckBox" then
            if Me:getSilverCoin() + Me:getGoldCoin() < cost then
                gf:askUserWhetherBuyCoin()
                return
            end
        else
            if Me:getGoldCoin() < cost then
                gf:askUserWhetherBuyCoin("gold_coin")
                return
            end
        end

        return self:confirmByStep(4)
    elseif step == 4 then
        -- 最后确认，
        local cost
        if PetMgr:isMountPet(self.mainPet) and not PetMgr:isEvolved(self.mainPet) then
            cost = Formula:getPetEvolveCost(Const.MOUNT_PET_COST_REQ_LEVEL, self.otherPet:queryInt("req_level"))
        elseif PetMgr:isJinianPet(self.mainPet) and "" == self.mainPet:queryBasic("evolve") then
            cost = Formula:getPetEvolveCost(Const.JINIAN_PET_COST_REQ_LEVEL, self.otherPet:queryInt("req_level"))
        elseif not PetMgr:isEvolved(self.mainPet) and self.mainPet:queryBasic("raw_name") == CHS[7190018] then
            cost = Formula:getPetEvolveCost(Const.BAIGUOER_PET_COST_REQ_LEVEL, self.otherPet:queryInt("req_level"))
        else
            cost = Formula:getPetEvolveCost(self.mainPet:queryInt("req_level"), self.otherPet:queryInt("req_level"))
        end

        local str = ""
        if self.radioGroup:getSelectedRadioName() == "SilverCheckBox"  then
            if Me:queryBasicInt('silver_coin') == 0 then
                str = string.format(CHS[4100164], cost)
            else
                local coin = Me:getSilverCoin() - cost
                if coin >= 0 then
                    str = string.format(CHS[4100165], cost)
                else
                    str = string.format(CHS[4100166], Me:getSilverCoin(), math.abs(coin))
                end
            end
        else
            str = string.format(CHS[4100167], cost)
        end
        gf:confirm(str,function ()
            if self.radioGroup:getSelectedRadioName() == "SilverCheckBox"  then
                PetMgr:evolvePet(self.mainPet, self.otherPet, "")
            else
                PetMgr:evolvePet(self.mainPet, self.otherPet, "gold_coin")
            end
            self:onCloseButton()
        end)
        return
    end
end

-- 进化按钮
function PetEvolveDlg:onEvolveButton(sender, eventType)


    if not self.mainPet or not self.otherPet then return end
    -- 战斗中
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3002257])
        return
    end

    -- 常用条件判断
    if not self:isMeetCondition(self.mainPet, self.otherPet) then return end

    -- 安全锁
    if self:checkSafeLockRelease("onEvolveButton") then return end

    self:confirmByStep(1)
end

-- 给予获取银元宝的提示
function PetEvolveDlg:onSilverAddButton(sender, eventType)
    InventoryMgr:openItemRescourse(CHS[3002297])
end

function PetEvolveDlg:onGoldCoinButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    OnlineMallMgr:openOnlineMall("OnlineRechargeDlg")
end

function PetEvolveDlg:onGoBackButton(sender, eventType)
    self:setCtrlVisible("EvolvePanel", true)
    self:setCtrlVisible("PreviewPanel", false)
end

function PetEvolveDlg:MSG_PREVIEW_PET_EVOLVE(data)
    if not self.mainPet or not self.otherPet then return end

    self.mainPet = PetMgr:getPetByNo(self.mainPet:queryBasicInt("no"))
    self.otherPet = PetMgr:getPetByNo(self.otherPet:queryBasicInt("no"))

    if data.mainPetId ~= self.mainPet:getId() or data.otherPetId ~= self.otherPet:getId() then return end
    self.preData = data
    self:setPreView(data)
    self:onCoinCheckBox()
    self:setCtrlVisible("EvolvePanel", false)
    self:setCtrlVisible("PreviewPanel", true)
end

function PetEvolveDlg:MSG_SWITCH_SERVER(data)
    self.preData = nil
end

return PetEvolveDlg
