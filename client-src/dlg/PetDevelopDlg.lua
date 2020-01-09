-- PetDevelopDlg.lua
-- Created by songcw Sep/24/2015
-- 宠物强化界面

local PetDevelopDlg = Singleton("PetDevelopDlg", Dialog)

function PetDevelopDlg:init()
    self:bindListener("DevelopButton", self.onDevelopButton)
    self:bindListener("DevelopOneClickButton", self.onDevelopOneClickButton)
    self:bindListener("DevelopCloseButton", self.onCloseButton)
    self:bindListener("CheckBox_34", self.onCheckBox)
    self:bindListener("CostImage", self.onCostImagePanel)

    -- 图片
    local icon = InventoryMgr:getIconByName(CHS[3003371])
    self:setImage("CostImage", ResMgr:getItemIconPath(icon))
    self:setItemImageSize("CostImage")

    -- checkBox状态
    if InventoryMgr.UseLimitItemDlgs[self.name] == 1 then
        self:setCheck("CheckBox_34", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 0 then
        self:setCheck("CheckBox_34", false)
    end
    self:onCheckBox(self:getControl("CheckBox_34"))

    self:MSG_INVENTORY()
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_UPDATE_PETS")

    self:initPet()
end

function PetDevelopDlg:initPet()
    local pet = PetMgr:getLastSelectPet()
    if pet then
        self:setPetInfo(pet)
    end
end

function PetDevelopDlg:dataClean()

end

-- 设置宠物信息
function PetDevelopDlg:setPetInfo(pet, fromServer)
    self.pet = pet

    -- 设置基本信息
    self:setPetBasicInfo(pet)

    -- 设置强化信息
    self:setPetDevelopInfo(pet, fromServer)

    -- 珍贵、点化标志
    self:setPetLogoPanel(pet)

    self:updateBtn()
end

function PetDevelopDlg:setPetLogoPanel(pet)
    PetMgr:setPetLogo(self, pet)
end


-- 基本信息设置
function PetDevelopDlg:setPetBasicInfo(pet)
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
    self:setLabelText("LevelLabel", pet:queryBasicInt("level") .. CHS[3003372])
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

-- 强化信息设置
function PetDevelopDlg:setPetDevelopInfo(pet, fromServer)
    if not pet then
        self:setLabelText("OldPowerValueLabel", "")
        self:setLabelText("OldDefValueLabel", "")
        self:setLabelText("OldLevelLabel", "")

        self:setLabelText("NewLevelLabel", "", nil, COLOR3.RED)
        self:setLabelText("NewPowerValueLabel", "", nil, COLOR3.RED)
        self:setLabelText("NewDefValueLabel", "", nil, COLOR3.RED)

        self:setLabelText("ComLabel", "", nil, COLOR3.RED)
        self:setLabelText("ComLabel_1", "", nil, COLOR3.RED)

        self:setProgressBar("ProgressBar", 100, 100)
        return
    end
    local function setRebuildInfo(key)
        local delta = 0
        local raw_name = pet:queryBasic("raw_name")
        local rebuildAdd = pet:queryInt(key.."_rebuild_add")
    	if key == "mag" then
            self:setLabelText("PowerLabel", CHS[3003373])
            self:setLabelText("DefLabel", CHS[3003374])
            local mag_std = PetMgr:getPetStdValue(raw_name, "mag_attack") - 40
            delta = Formula:getMagRebuildDelta(mag_std, rebuildAdd)
    	else
            self:setLabelText("PowerLabel", CHS[3003375])
            self:setLabelText("DefLabel", CHS[3003376])
            local phy_std = PetMgr:getPetStdValue(raw_name, "phy_attack") - 40
            delta = Formula:getPhyRebuildDelta(phy_std, rebuildAdd)
    	end

        local level = pet:queryInt(key .. "_rebuild_level")
        self:setLabelText("OldLevelLabel", level .. CHS[3003372])

        local rebuildAdd = pet:queryInt(key.."_rebuild_add")
        local addPower = self:getAddPower(key, rebuildAdd, pet)
        if rebuildAdd == 0 then
            self:setLabelText("OldPowerValueLabel", 0)
            self:setLabelText("OldDefValueLabel", 0)
        else
            self:setLabelText("OldPowerValueLabel", "+" .. rebuildAdd)
            self:setLabelText("OldDefValueLabel", "+" .. addPower)
        end

        local lastNewLevelText = self:getLabelText("NewLevelLabel")
        if level >= PetMgr:getPetMaxDevelopLevel() or delta <= 0 then
            -- 已达上限，隐藏花费
            self:setCtrlVisible("CostPanel", false)

            self:setLabelText("NewLevelLabel", CHS[4000102], nil, COLOR3.RED)
            self:setLabelText("NewPowerValueLabel", CHS[4000102], nil, COLOR3.RED)
            self:setLabelText("NewDefValueLabel", CHS[4000102], nil, COLOR3.RED)

            self:setCtrlVisible("ProgressBar", false)
            self:setCtrlVisible("TypeLabel", false)
            self:setCtrlVisible("Label_18", false)
            self:setCtrlVisible("CheckBox_34", false)
            self:setCtrlVisible("BKImage", false, "ProcessPanel")
            self:setCtrlVisible("FullImage", true)

            self:setLabelText("ComLabel", CHS[4000102], nil, COLOR3.RED)
            self:setLabelText("ComLabel_1", CHS[4000102], nil, COLOR3.RED)
            self:setProgressBar("ProgressBar", 100, 100)
        else
            -- 恢复花费显示
            self:setCtrlVisible("CostPanel", true)

            self:setLabelText("NewLevelLabel", (level + 1) .. CHS[3003372], nil, COLOR3.GREEN)
            self:setLabelText("NewPowerValueLabel", "+" .. rebuildAdd + delta, nil, COLOR3.GREEN)

            self:setCtrlVisible("ProgressBar", true)
            self:setCtrlVisible("TypeLabel", true)
            self:setCtrlVisible("Label_18", true)
            self:setCtrlVisible("CheckBox_34", true)
            self:setCtrlVisible("BKImage", true, "ProcessPanel")
            self:setCtrlVisible("FullImage", false)
            local addPower = self:getAddPower(key, rebuildAdd + delta, pet)
            self:setLabelText("NewDefValueLabel", "+" .. addPower, nil, COLOR3.GREEN)
            local rate = pet:queryInt(key .. "_rebuild_rate")
            self:setLabelText("ComLabel", string.format("%.02f%%", rate / 100), nil, COLOR3.WHITE)
            self:setLabelText("ComLabel_1", string.format("%.02f%%", rate / 100), nil, COLOR3.WHITE)
            self:setProgressBar("ProgressBar", rate, 10000)
        end

        if fromServer and lastNewLevelText ~= self:getLabelText("NewLevelLabel") then
            -- 服务器通知强化成功，播放一次强化成功特效
            gf:displaySuccessOrFaildMagic(true)
        end
    end

    -- 判断当前宠物是否为相性宠物
    local petPolar = pet:queryBasicInt("polar")
    if petPolar > 0 then
        setRebuildInfo('mag')
    else
        setRebuildInfo('phy')
    end
end

-- 计算物理/法术伤害增长
function PetDevelopDlg:getAddPower(key, shapeValue, pet)

    local strOrMag = 0
    local petLevel = pet:queryBasicInt("level")
    local oldShape = 0
    local oldPower = 0
    local newPower = 0
    if key == "phy" then
        strOrMag = pet:queryInt("str")
        oldShape = PetMgr:getPetBasicShape(pet, "phy_effect")
        oldPower = Formula:getPetPhyPower(strOrMag, oldShape, petLevel)
        newPower = Formula:getPetPhyPower(strOrMag, oldShape + shapeValue, petLevel)
    else
        strOrMag = pet:queryInt("wiz")
        oldShape = PetMgr:getPetBasicShape(pet, "mag_effect")
        oldPower = Formula:getPetMagPower(strOrMag, oldShape, petLevel)
        newPower = Formula:getPetMagPower(strOrMag, oldShape + shapeValue, petLevel)
    end

    return newPower - oldPower
end

function PetDevelopDlg:MSG_INVENTORY(data)
    local amount = InventoryMgr:getAmountByNameIsForeverBind(CHS[3003371], self:isCheck("CheckBox_34"))
    if amount > 999 then amount = "*" end
    if amount == 0 then
        self:setLabelText("DevelopLabel_0", amount, nil, COLOR3.RED)
    else
        self:setLabelText("DevelopLabel_0", amount, nil, COLOR3.TEXT_DEFAULT)
    end
    self:updateLayout("CostPanel")
end

function PetDevelopDlg:MSG_UPDATE_PETS(data)
    if data[1].no == self.pet:queryBasicInt("no") then
        self.pet = PetMgr:getPetByNo(data[1].no)
        self:setPetInfo(self.pet, true)
    end

    self:updateBtn()
end

function PetDevelopDlg:onCheckBox(sender, eventType)
    self:MSG_INVENTORY()

    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
    end
end

-- 更新按钮状态
function PetDevelopDlg:updateBtn()
    if not self.pet then return end
    local petPolar = self.pet:queryBasicInt("polar")
    local rebuildLevel = 0
    if petPolar > 0 then
        rebuildLevel = self.pet:queryInt("mag_rebuild_level")
    else
        rebuildLevel = self.pet:queryInt("phy_rebuild_level")
    end

    local maxLevel = PetMgr:getMaxDevelopLevel(self.pet)
    if rebuildLevel >= maxLevel then
        self:setCtrlVisible("DevelopButton", false)
        self:setCtrlVisible("DevelopOneClickButton", false)
        self:setCtrlVisible("DevelopCloseButton", true)
    else
        self:setCtrlVisible("DevelopButton", true)
        self:setCtrlVisible("DevelopOneClickButton", true)
        self:setCtrlVisible("DevelopCloseButton", false)
    end
end

function PetDevelopDlg:onDevelopButton(sender, eventType)

    if PetMgr:isTimeLimitedPet(self.pet) then
        gf:ShowSmallTips(CHS[7000086])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[4300325])
        return
    end
    self:useItem(CHS[6000213])
end

function PetDevelopDlg:onDevelopOneClickButton(sender, eventType)
    if not self.pet then return end

    if PetMgr:isTimeLimitedPet(self.pet) then
        gf:ShowSmallTips(CHS[7000086])
        return
    end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[4300325])
        return
    end

    local petPolar = self.pet:queryBasicInt("polar")
    local rebuildLevel = 0
    if petPolar > 0 then
        rebuildLevel = self.pet:queryInt("mag_rebuild_level")
    else
        rebuildLevel = self.pet:queryInt("phy_rebuild_level")
    end

    if rebuildLevel < 3 then
        gf:ShowSmallTips(CHS[5300005])
        return
    end

    -- 宠物一键强化
    DlgMgr:openDlg("PetOneClickDevelopDlg")
    DlgMgr:sendMsg("PetOneClickDevelopDlg", "setPetData", self.pet)
end

function PetDevelopDlg:onCostImagePanel(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[3003371], rect)
end

function PetDevelopDlg:useItem(name)
    if self.pet == nil then return end
    local para = nil
    local petPolar = self.pet:queryBasicInt("polar")

    if petPolar > 0 then
        para = "mag"
    else
        para = "phy"
    end

    InventoryMgr:feedPetByIsLimitItem(name, self.pet, para, self:isCheck("CheckBox_34"))
end

return PetDevelopDlg
