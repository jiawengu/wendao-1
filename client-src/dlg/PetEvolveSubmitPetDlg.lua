-- PetEvolveSubmitPetDlg.lua
-- Created by songcw July/4/2016
-- 宠物进化、宠物提交界面
-- 宠物继承副宠提交界面

local PetEvolveSubmitPetDlg = Singleton("PetEvolveSubmitPetDlg", Dialog)

-- 宠物状态:参战，掠阵
local PET_STATE_TO_STR = {CHS[2000026], CHS[2000027]}

function PetEvolveSubmitPetDlg:init()
    
    self:bindListener("SubmitButton", self.onSubmitButton)
    
    self.selectPet = nil
    self.mainPet = nil
    self.subType = nil
    
    self.singlePetPanel = self:getControl("SinglePetPanel")
    self.singlePetPanel:removeFromParent()
    self.singlePetPanel:retain()
    
    self.selectEffectImage = self:getControl("ChosenEffectImage", nil, self.singlePetPanel)
    self.selectEffectImage:removeFromParent()
    self.selectEffectImage:setVisible(true)
    self.selectEffectImage:retain()

    self:hookMsg("MSG_SET_CURRENT_PET")
    self:hookMsg("MSG_SET_CURRENT_MOUNT")
end

function PetEvolveSubmitPetDlg:setSubType(subType)
    self.subType = subType
end

function PetEvolveSubmitPetDlg:setPetList(mainPet)
    -- mainPet为主宠，需要排除
    self.mainPet = mainPet
    local pets = PetMgr:getOrderPets()
    local list = self:resetListView("PetListView")
    for _, pet in pairs(pets) do
        if pet:getId() ~= mainPet:getId() then
            local panel = self.singlePetPanel:clone()
            self:setPetUnitPanel(pet, panel)
            list:pushBackCustomItem(panel)
            
            if not self.selectPet then
                self.selectPet = pet
                self:onSelectPet(panel)
            end
        end
    end
end

function PetEvolveSubmitPetDlg:setPetUnitPanel(pet, panel)
    panel.pet = pet
    self:setLabelText("NameLabel", gf:getPetName(pet.basic), panel)
    self:setLabelText("LevelLabel", "LV." .. pet:queryBasic("level"), panel)
    self:setImage("GuardImage", ResMgr:getSmallPortrait(pet:queryBasicInt("portrait")), panel)
    self:setItemImageSize("GuardImage", panel)
    
    local polar = gf:getPolar(pet:queryBasicInt("polar"))
    self:setImagePlist("LogoImage", ResMgr:getPolarImagePath(polar), panel)
    
    -- 参战、掠阵
    local pet_status = pet:queryInt("pet_status")
    if pet_status == 1 then
        -- 参战
        self:setImage("StatusImage", ResMgr.ui.canzhan_flag, panel)
    elseif pet_status == 2 then
        -- 掠阵
        self:setImage("StatusImage", ResMgr.ui.luezhen_flag, panel)
    elseif PetMgr:isRidePet(pet:getId()) then
        -- 骑乘
        self:setCtrlVisible("StatusImage", true, panel)
        self:setImage("StatusImage", ResMgr.ui.ride_flag, panel)
    else
        -- 透明图片
        self:setImagePlist("StatusImage", ResMgr.ui.touming, panel)
    end
    
    self:bindListener("InfoButton", function ()
        local dlg =  DlgMgr:openDlg("PetCardDlg")
        dlg:setPetInfo(pet, true)    	
    end, panel)
    
    self:bindTouchEndEventListener(panel, function ()        
        self.selectPet = pet
        self:onSelectPet(panel)
    end)
end

function PetEvolveSubmitPetDlg:onSelectPet(sender)
    self:addSelectEff(sender)
    
    if self.subType == "inherit" then
        self:setInheritPetInfo(self.selectPet)
        return
    end
    
    self:setPetInfo(self.selectPet)
end

function PetEvolveSubmitPetDlg:addSelectEff(panel)
    if not self.selectEffectImage then return end
    self.selectEffectImage:removeFromParent()
    panel:addChild(self.selectEffectImage)
end

function PetEvolveSubmitPetDlg:setPetInfo(pet)
    local shapePanel = self:getControl("PetItemPanel")
    self:setLabelText("NameLabel", gf:getPetName(pet.basic), shapePanel)
    self:setLabelText("LevelLabel", "LV." .. pet:queryBasic("level"), shapePanel)
    self:setImage("PetIconImage", ResMgr:getSmallPortrait(pet:queryBasicInt("portrait")), shapePanel)
    self:setItemImageSize("PetIconImage", shapePanel)
    
    -- 携带等级
    self:setLabelText("ValueLabel", pet:queryInt("req_level"), "LevelPanel")
    
    -- 气血成长
    local basicLife = PetMgr:getPetBasicShape(pet, "life_effect")
    local lifeMax = PetMgr:getPetBasicMax(pet, "life")
    self:setLabelText("ValueLabel", basicLife .. "/" .. lifeMax, "LifeGrowingPanel")
    
    -- 法力
    local basicMana = PetMgr:getPetBasicShape(pet, "mana_effect")
    local manaMax = PetMgr:getPetBasicMax(pet, "mana")
    self:setLabelText("ValueLabel", basicMana .. "/" .. manaMax, "ManaGrowingPanel")
    
    -- 速度基础成长
    local basicSpeed = PetMgr:getPetBasicShape(pet, "speed_effect")
    local speedMax = PetMgr:getPetBasicMax(pet, "speed")
    self:setLabelText("ValueLabel", basicSpeed .. "/" .. speedMax, "SpeedGrowingPanel")
    
    -- 物攻基础成长
    local basicPhy = PetMgr:getPetBasicShape(pet, "phy_effect")
    local phy_attackdMax = PetMgr:getPetBasicMax(pet, "phy_attack")
    self:setLabelText("ValueLabel", basicPhy .. "/" .. phy_attackdMax, "PhysicalPowerPanel")

    -- 法攻基础成长
    local basicMag = PetMgr:getPetBasicShape(pet, "mag_effect")
    local mag_attackMax = PetMgr:getPetBasicMax(pet, "mag_attack")
    self:setLabelText("ValueLabel", basicMag .. "/" .. mag_attackMax, "MagicPowerPanel")
    
    -- 基础总成长
    local total = basicLife + basicMana + basicSpeed + basicPhy + basicMag
    local totalMax = lifeMax + manaMax + speedMax + phy_attackdMax + mag_attackMax
    self:setLabelText("ValueLabel", total .. "/" .. totalMax, "TotalGrowingPanel")
    
    self:setLabelText("ValueLabel", "", "DianhuaPanel")
    self:setLabelText("TypeLabel", "", "DianhuaPanel")
    self:setLabelText("ValueLabel", "", "YuhuaPanel")
    self:setLabelText("TypeLabel", "", "YuhuaPanel")
end

function PetEvolveSubmitPetDlg:setInheritPetInfo(pet)
    local shapePanel = self:getControl("PetItemPanel")
    self:setLabelText("NameLabel", gf:getPetName(pet.basic), shapePanel)
    self:setLabelText("LevelLabel", "LV." .. pet:queryBasic("level"), shapePanel)
    self:setImage("PetIconImage", ResMgr:getSmallPortrait(pet:queryBasicInt("portrait")), shapePanel)
    self:setItemImageSize("PetIconImage", shapePanel)

    -- 武学
    self:setLabelText("TypeLabel", CHS[7190071], "LevelPanel")
    self:setLabelText("ValueLabel", pet:queryInt("martial"), "LevelPanel")

    -- 飞升
    self:setLabelText("TypeLabel", CHS[7190072], "TotalGrowingPanel")
    if PetMgr:isFlyPet(pet) then
        self:setLabelText("ValueLabel", CHS[7002287], "TotalGrowingPanel")
    else
        self:setLabelText("ValueLabel", CHS[7002286], "TotalGrowingPanel")
    end
    
    -- 气血成长
    self:setLabelText("TypeLabel", CHS[7190074], "ManaGrowingPanel")
    local lifeShape = pet:queryInt("pet_life_shape")
    self:setLabelText("ValueLabel", lifeShape, "ManaGrowingPanel")

    -- 法力
    self:setLabelText("TypeLabel", CHS[7190075], "SpeedGrowingPanel")
    local manaShape = pet:queryInt("pet_mana_shape")
    self:setLabelText("ValueLabel", manaShape, "SpeedGrowingPanel")

    -- 速度成长
    self:setLabelText("TypeLabel", CHS[7190076], "PhysicalPowerPanel")
    local speedShape = pet:queryInt("pet_speed_shape")
    self:setLabelText("ValueLabel", speedShape, "PhysicalPowerPanel")

    -- 物攻成长
    self:setLabelText("TypeLabel", CHS[7190077], "MagicPowerPanel")
    local phyShape = pet:queryInt("pet_phy_shape")
    self:setLabelText("ValueLabel", phyShape, "MagicPowerPanel")

    -- 法攻成长
    self:setLabelText("TypeLabel", CHS[7190078], "DianhuaPanel")
    local magShape = pet:queryInt("pet_mag_shape")
    self:setLabelText("ValueLabel", magShape, "DianhuaPanel")

    -- 总成长
    self:setLabelText("TypeLabel", CHS[7190073], "LifeGrowingPanel")
    local total = lifeShape + manaShape + speedShape + phyShape + magShape
    self:setLabelText("ValueLabel", total, "LifeGrowingPanel")
    
    -- 羽化、
    self:setLabelText("ValueLabel", "", "YuhuaPanel")
    self:setLabelText("TypeLabel", "", "YuhuaPanel")
end

function PetEvolveSubmitPetDlg:cleanup()
    self:releaseCloneCtrl("singlePetPanel")
    self:releaseCloneCtrl("selectEffectImage")
end

function PetEvolveSubmitPetDlg:onSubmitButton(sender, eventType)
    if not self.subType or self.subType == "evolve" then
        -- 如果没有设置和self.subType == "evolve"，则走进化
        self:onSubmitForEvolve(sender,eventType)
    elseif self.subType == "huanhua" then
        -- 幻化提交宠物
        self:onSubmitForHuanhua(sender,eventType)
    elseif self.subType == "inherit" then
        -- 继承提交宠物
        self:onSubmitForInherit(sender,eventType)
    end
end

function PetEvolveSubmitPetDlg:onSubmitForInherit(sender, eventType)
    if not self.selectPet or not self.mainPet then return end
    
    if self.selectPet:queryInt('rank') == Const.PET_RANK_WILD then
        -- 副宠为野生宠物
        gf:ShowSmallTips(CHS[7190064])
        return false
    end
    
    if PetMgr:isTimeLimitedPet(self.selectPet) then
        -- 副宠为限时宠物
        gf:ShowSmallTips(CHS[7190065])
        return
    end
    
    if PetMgr:isLimitedForeverPet(self.selectPet) then
        -- 副宠为永久限制交易状态
        gf:ShowSmallTips(CHS[7190066])
        return
    end
    
    if PetMgr:isFeedStatus(self.selectPet) then
        -- 副宠正处于#R元神分离饲养#n状态
        gf:ShowSmallTips(CHS[7190067])
        return
    end
    
    if self.selectPet:queryBasicInt("lock_exp") == 1 then
        -- 副宠已锁定经验
        gf:ShowSmallTips(CHS[7190068])
        return
    end
    
    if math.abs(self.mainPet:queryInt('level') - self.selectPet:queryInt('level')) > 15 then
        -- 主副宠差15级以上
        gf:ShowSmallTips(CHS[7190069])
        return
    end
    
    if PetMgr:isFlyPet(self.mainPet) ~= PetMgr:isFlyPet(self.selectPet) then
        -- 主宠，副宠飞升状态不同
        gf:ShowSmallTips(CHS[7120017])
        return
    end

    local pet_status = self.selectPet:queryInt("pet_status")
    local isRide = PetMgr:isRidePet(self.selectPet:getId())
    if pet_status == 1 or pet_status == 2 then
        -- 参战或掠阵
        gf:confirm(string.format(CHS[7190070], PET_STATE_TO_STR[pet_status], PET_STATE_TO_STR[pet_status]), function()
            PetMgr:setPetStatus(self.selectPet:getId(), 0)
        end)
        return
    elseif isRide then
        gf:confirm(string.format(CHS[7190070], CHS[5420167], CHS[5420167]), function()
            self.needRefreshRidePet = self.selectPet
            gf:CmdToServer("CMD_SELECT_CURRENT_MOUNT", {pet_id = 0})
        end)
        return
    end
    
    gf:CmdToServer("CMD_PREVIEW_PET_INHERIT", {no1 = self.mainPet:queryBasicInt("no"), no2 = self.selectPet:queryBasicInt("no")})
    
    DlgMgr:sendMsg("PetInheritDlg", "setOtherPet", self.selectPet)
    self:onCloseButton()
end

function PetEvolveSubmitPetDlg:onSubmitForHuanhua(sender, eventType)
    if not self.selectPet or not self.mainPet then return end

    -- 百年黑熊 或 血幻豪猪 或 赤血幼猿 或 魅影毒蝎
    if self.selectPet:queryBasic("raw_name") ~= CHS[4100344]
          and self.selectPet:queryBasic("raw_name") ~= CHS[7000136]
          and self.selectPet:queryBasic("raw_name") ~= CHS[7002095]
          and self.selectPet:queryBasic("raw_name") ~= CHS[7002303] then
        gf:ShowSmallTips(CHS[4100345])
        return
    end
    
    -- 是否进化过
    if PetMgr:isEvolved(self.selectPet) then
        gf:ShowSmallTips(CHS[4100346])
        return
    end 
    
    -- 贵重宠物不能作为副宠
    if gf:isExpensive(self.selectPet, true) then
        gf:ShowSmallTips(CHS[7100060])
        return
    end
    
    -- 是不是满成长宠物判断
    if not PetMgr:isGrowUpPerfect(self.selectPet) then
        gf:ShowSmallTips(CHS[4100348])
        return
    end
    
    -- 状态
    local pet_status = self.selectPet:queryInt("pet_status")
    if pet_status == 1 then
        -- 参战
        gf:ShowSmallTips(CHS[4100349])
        return
    elseif pet_status == 2 then
        -- 掠阵
        gf:ShowSmallTips(CHS[4100350])
        return
    elseif PetMgr:isFeedStatus(self.selectPet) then
        gf:ShowSmallTips(CHS[5410091])
        return
    end
    
    -- 天书
    if PetMgr:haveGoodbookSkill(self.selectPet:getId()) then
        gf:ShowSmallTips(CHS[4100351])
        return 
    end
    
    -- 强化、点化、天生技能判断
    if PetMgr:getPetDevelopLevel(self.selectPet) > 0 or PetMgr:isDianhuaOK(self.selectPet) or self.selectPet:queryBasicInt("enchant_nimbus") > 0 or next(SkillMgr:getPetRawSkillNoAndLadder(self.selectPet:getId())) then
        gf:confirm(CHS[4300259],function ()
    DlgMgr:sendMsg("PetHuanHuaDlg", "setOtherPet", self.selectPet)
    self:onCloseButton()
            end)
    else
        DlgMgr:sendMsg("PetHuanHuaDlg", "setOtherPet", self.selectPet)
        self:onCloseButton()
    end
end

function PetEvolveSubmitPetDlg:onSubmitForEvolve(sender, eventType)
    if not self.selectPet or not self.mainPet then return end
    
    -- 贵重宠物不能作为副宠
    if gf:isExpensive(self.selectPet, true) then
        gf:ShowSmallTips(CHS[7100058])
        return
    end
    
    if PetMgr:isTimeLimitedPet(self.selectPet) then
        gf:ShowSmallTips(CHS[7000087])
        return
    end
    
    -- 类型判断
    local rank = ""
    if self.selectPet:queryInt('rank') == Const.PET_RANK_WILD then
        gf:ShowSmallTips(string.format(CHS[4100168], CHS[3003810]))
        return
    elseif self.selectPet:queryInt('rank') == Const.PET_RANK_ELITE then
        gf:ShowSmallTips(string.format(CHS[4100168], CHS[3003813]))
        return
    elseif self.selectPet:queryInt('rank') == Const.PET_RANK_EPIC then
        gf:ShowSmallTips(string.format(CHS[4100168], CHS[3003814]))
        return
    elseif self.selectPet:queryInt('mount_type') == MOUNT_TYPE.MOUNT_TYPE_YULING or self.selectPet:queryInt('mount_type') == MOUNT_TYPE.MOUNT_TYPE_JINGGUAI then
        if not PetMgr:isEvolved(self.selectPet) then
            gf:ShowSmallTips(CHS[6000514])
            return
        end
    elseif PetMgr:isJinianPet(self.selectPet) then
        if not PetMgr:isEvolved(self.selectPet) then
            gf:ShowSmallTips(CHS[7002148])
            return
        end
    elseif self.selectPet:queryBasic("raw_name") == CHS[7190018] then
        if not PetMgr:isEvolved(self.selectPet) then
            gf:ShowSmallTips(CHS[7190019])
            return
        end
    elseif PetMgr:isFeedStatus(self.selectPet) then
        gf:ShowSmallTips(CHS[5410091])
        return
    end
    
    --if (self.selectPet:queryBasic('evolve') ~= "" and 
    local mainSoul = self.mainPet:queryBasic('evolve')
    local mainSourStr = CHS[4100258] -- 主宠魂魄
    if mainSoul == "" then
        mainSourStr = CHS[4100259] -- 主宠
        mainSoul = self.mainPet:queryBasic('raw_name') 
    end
    
    local selectSoul = self.selectPet:queryBasic('evolve')
    local otherSourStr = CHS[4100260] -- 副宠魂魄
    if selectSoul == "" then
        otherSourStr = CHS[4100261] -- 副宠
        selectSoul = self.selectPet:queryBasic('raw_name')         
    end
    
    if mainSoul == selectSoul then
        gf:ShowSmallTips(string.format(CHS[4100169], mainSourStr, otherSourStr))
        return
    end
    
    -- 等级
    if self.selectPet:queryInt("req_level") > Me:queryBasicInt("level") then
        gf:ShowSmallTips(CHS[4100170])
        return
    end
    
    -- 如果主宠的携带等级大于副宠的携带等级
    if self.mainPet:queryInt("req_level") > self.selectPet:queryInt("req_level") then
        if not PetMgr:isEvolved(self.mainPet) and (self.mainPet:queryInt('mount_type') == MOUNT_TYPE.MOUNT_TYPE_YULING or self.mainPet:queryInt('mount_type') == MOUNT_TYPE.MOUNT_TYPE_JINGGUAI) then 
            gf:ShowSmallTips(CHS[6000515])
        else
            gf:ShowSmallTips(CHS[4100171])
        end
        
        return
    end
    
    if not PetMgr:isEvolved(self.mainPet) and (self.mainPet:queryInt('mount_type') == MOUNT_TYPE.MOUNT_TYPE_YULING or self.mainPet:queryInt('mount_type') == MOUNT_TYPE.MOUNT_TYPE_JINGGUAI)
            and self.selectPet:queryInt("req_level") < Const.MOUNT_PET_COST_REQ_LEVEL then
        -- 如果当前主宠是未进化过的精怪、御灵宠物，则副宠携带等级必须大于等于80级
        gf:ShowSmallTips(CHS[6000515])
        return
    elseif not PetMgr:isEvolved(self.mainPet) and PetMgr:isJinianPet(self.mainPet) and self.selectPet:queryInt("req_level") < Const.JINIAN_PET_COST_REQ_LEVEL then
        -- 如果当前主宠是未进化过的纪念宠物，则副宠携带等级必须大于等于60级
        gf:ShowSmallTips(CHS[7002149])
        return
    elseif not PetMgr:isEvolved(self.mainPet) and self.mainPet:queryBasic("raw_name") == CHS[7190018] and self.selectPet:queryInt("req_level") < Const.BAIGUOER_PET_COST_REQ_LEVEL then
        -- 如果当前主宠是白果儿，则第一次进化时副宠携带等级必须大于等于70级
        gf:ShowSmallTips(CHS[7190020])
        return
    end
        
    -- 状态
    local pet_status = self.selectPet:queryInt("pet_status")
    if pet_status == 1 then
        -- 参战
        gf:confirm(string.format(CHS[4100172], CHS[2000026], CHS[2000026]), function ()
            PetMgr:setPetStatus(self.selectPet:getId(), 0)
        end)
        return
    elseif pet_status == 2 then
        -- 掠阵
        gf:confirm(string.format(CHS[4100172], CHS[2000027], CHS[2000027]), function ()
            PetMgr:setPetStatus(self.selectPet:getId(), 0)
        end)
        return
    end
    
    -- 天书
    if PetMgr:haveGoodbookSkill(self.selectPet:getId()) then
        gf:ShowSmallTips(CHS[4100173])
        return 
    end
    
    -- 贵重（强化、点化、天技）
    if PetMgr:getPetDevelopLevel(self.selectPet) > 0 or self.selectPet:queryBasicInt("enchant") ~= 0 or #SkillMgr:getPetRawSkillNoAndLadder(self.selectPet:getId()) > 0 then
        gf:confirm(CHS[4100174], function ()        
            DlgMgr:sendMsg("PetEvolveDlg", "setOtherPet", self.selectPet)
            self:onCloseButton()
        end)
        return
    end
    
    DlgMgr:sendMsg("PetEvolveDlg", "setOtherPet", self.selectPet)
    self:onCloseButton()
end

function PetEvolveSubmitPetDlg:MSG_SET_CURRENT_PET(data)
    local list = self:getControl("PetListView")
    local items = list:getItems()
    for _, item in pairs(items) do
        if item.pet and item.pet:getId() == data.id then
            item.pet:setBasic('pet_status', data.pet_status)
            self:setPetUnitPanel(item.pet, item)
        end
    end
    
    if self.selectPet and self.selectPet:getId() == data.id then
        self.selectPet:setBasic('pet_status', data.pet_status)
    end
end

function PetEvolveSubmitPetDlg:MSG_SET_CURRENT_MOUNT(data)
    local list = self:getControl("PetListView")
    local items = list:getItems()
    if self.needRefreshRidePet then
        for _, item in pairs(items) do
            if item.pet and item.pet == self.needRefreshRidePet then
                self:setPetUnitPanel(item.pet, item)
                self.needRefreshRidePet = nil
            end
        end
    end
end

return PetEvolveSubmitPetDlg
