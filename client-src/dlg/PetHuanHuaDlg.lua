-- PetHuanHuaDlg.lua
-- Created by songcw Sep/18/2016
-- 宠物幻化界面

local PetHuanHuaDlg = Singleton("PetHuanHuaDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local ATTRIB_PANEL = {"LifePanel", "ManaPanel", "SpeedPanel", "PhyPanel", "MagPanel"}
local ATTRIB_FIELD = {
    ["LifePanel"]   = "life_effect",
    ["ManaPanel"]   = "mana_effect",
    ["SpeedPanel"]  = "speed_effect",
    ["PhyPanel"]    = "phy_effect",
    ["MagPanel"]    = "mag_effect",
}

local MORPH_NO = {
    [1] = {field = "life",  panel = "LifePanel", chs = CHS[4000010]},
    [2] = {field = "mana",  panel = "ManaPanel", chs = CHS[4000011]},
    [3] = {field = "speed", panel = "SpeedPanel", chs = CHS[4000012]},
    [4] = {field = "phy",  panel = "PhyPanel", chs = CHS[4000013]},
    [5] = {field = "mag",  panel = "MagPanel", chs = CHS[4000014]},
}

function PetHuanHuaDlg:init()
    self:bindListener("GoOnButton", self.onGoOnButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("HeadPanel2", self.onHeadPanel2)
    self:bindListener("ConfirmButton", self.onConfirmButton)

    self.mainPet = nil
    self.otherPet = nil
    self.attNo = 0

    self:setCtrlInit()
    self:setDisplayType(1)

    -- 创建互斥按钮
    self.radioGroup = RadioGroup.new()
    local CHECKBOXS = {}
    for _, name in pairs(ATTRIB_PANEL) do
        local checkBox = self:getControl("ChoseCheckBox", nil, name)
        checkBox:setTag(_)
        checkBox.field = ATTRIB_FIELD[name]
        table.insert(CHECKBOXS, checkBox)
    end
    self.radioGroup:setItems(self, CHECKBOXS, self.onCheckBoxClick)

    for i = 1, #MORPH_NO do
        local panel = self:getControl(MORPH_NO[i].panel)
        self:setProgressBar("ProgressBar", 0, 0, panel)
        self:setProgressBar("ProgressBar_1", 0, 0, panel)

    end

    self:hookMsg("MSG_MORPH_SUCCESS")

    self:initPet()
end

function PetHuanHuaDlg:initPet()
    local pet = PetMgr:getLastSelectPet()
    if pet then
        self:setMainPet(pet)
    end
end

-- 界面初始化（隐藏一些、将一些label设置为空）
function PetHuanHuaDlg:setCtrlInit()
    for _, name in pairs(ATTRIB_PANEL) do
        self:setLabelText("TimeLabel_1", "", name)
    end
end

-- 1为显示形象信息，否则为幻化成长信息
function PetHuanHuaDlg:setDisplayType(display)
    self:setCtrlVisible("PetShapePanel", display == 1)
    self:setCtrlVisible("PetInfoPanel", display ~= 1)

    self:setCtrlVisible("ConfirmButton", display ~= 1)
    self:setCtrlVisible("GoOnButton", display == 1)
    for _, name in pairs(ATTRIB_PANEL) do
        local checkBox = self:getControl("ChoseCheckBox", nil, name)
        checkBox:setVisible(display ~= 1 and not checkBox.isComplete)
    end
end

-- 设置主宠信息
function PetHuanHuaDlg:setMainPet(pet)
    self.mainPet = pet

    self:setMainPetHead(pet)

    self:setMainPetShape(pet)

    self:setMainPetGrowUp(pet)

    self:setMainPetMorph(pet)

    self:setSubsectionInit(pet)
end

-- 设置副宠
function PetHuanHuaDlg:setOtherPet(pet)
    self.otherPet = pet

    local panel = self:getControl("HeadPanel2")
    self:setImage("PetImage", ResMgr:getSmallPortrait(pet:queryBasicInt("portrait")), panel)
    self:setItemImageSize("PetImage", panel)

    self:setCtrlVisible("NoneImage", false, panel)
    self:setCtrlVisible("SelectLabel", false, "HeadPanel2")

    PetMgr:setPetLogo(self, pet, panel)


end

-- 设置主宠的形象等信息
function PetHuanHuaDlg:setMainPetShape(pet)
    local nameLevel = string.format(CHS[4000391], pet:getShowName(), pet:queryBasicInt("level"))
    self:setLabelText("NameLabel", nameLevel, "RenamePanel")
    self:setPortrait("PetIconPanel", pet:getDlgIcon(nil, nil, true), 0, self.root, true, nil, nil, cc.p(0, -36))

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
    self:setImage("SuffixImage", ResMgr:getPetRankImagePath(pet))

    PetMgr:setPetLogo(self, pet, "PetShapePanel")
end

-- 设置主宠原有的幻化信息，次数等
function PetHuanHuaDlg:setMainPetMorph(pet)
    local hMax = PetMgr:getHuanProgressMax(pet)
    for i = 1, #MORPH_NO do
        local panel = self:getControl(MORPH_NO[i].panel)
        local fieldPro = string.format("morph_%s_stat", MORPH_NO[i].field)
        self:setProgressBar("ProgressBar", pet:queryBasicInt(fieldPro), hMax, panel)
        self:setProgressBar("ProgressBar", 0, hMax, panel)
        self:setProgressBar("ProgressBar_1", pet:queryBasicInt(fieldPro), hMax, panel)

        local fieldTimes = string.format("morph_%s_times", MORPH_NO[i].field)
        self:setLabelText("TimeLabel_1", pet:queryBasicInt(fieldTimes) .. CHS[3002314], panel, COLOR3.TEXT_DEFAULT)

        -- 幻化是否完成
        self:setCtrlVisible("BarPanel", (pet:queryBasicInt(fieldTimes) ~= PetMgr:getMorphMaxTimes()), panel)
        self:setCtrlVisible("CompleteLabel", (pet:queryBasicInt(fieldTimes) == PetMgr:getMorphMaxTimes()), panel)


        -- 勾选框标记幻化完成
        local checkBox = self:getControl("ChoseCheckBox", nil, panel)
        checkBox.isComplete = (pet:queryBasicInt(fieldTimes) == PetMgr:getMorphMaxTimes())

    end
end

-- 设置主宠的幻化信息中，头像
function PetHuanHuaDlg:setMainPetHead(pet)
    local panel = self:getControl("HeadPanel1")
    self:setImage("PetImage", ResMgr:getSmallPortrait(pet:queryBasicInt("portrait")), panel)
    self:setItemImageSize("PetImage", panel)
    PetMgr:setPetLogo(self, pet, panel)
end

-- 设置主宠的成长
function PetHuanHuaDlg:setMainPetGrowUp(pet)
    local lifeShape = pet:queryInt("pet_life_shape")
    local manaShape = pet:queryInt("pet_mana_shape")
    local speedShape = pet:queryInt("pet_speed_shape")
    local phyShape = pet:queryInt("pet_phy_shape")
    local magShape = pet:queryInt("pet_mag_shape")
    local totalShape = lifeShape + manaShape + speedShape + phyShape + magShape

    -- 资质相关
    -- 气血成长
    self:setLabelText("LifeEffectLabel", lifeShape, "LifeEffectPanel")
    self:setLabelText("LifeEffectLabel_2", lifeShape, "LifeEffectPanel", COLOR3.TEXT_DEFAULT)

    -- 法力成长
    self:setLabelText("ManaEffectLabel", manaShape, "ManaEffectPanel")
    self:setLabelText("ManaEffectLabel_2", manaShape, "ManaEffectPanel", COLOR3.TEXT_DEFAULT)

    -- 速度成长
    self:setLabelText("SpeedEffectLabel", speedShape, "SpeedEffectPanel")
    self:setLabelText("SpeedEffectLabel_2", speedShape, "SpeedEffectPanel", COLOR3.TEXT_DEFAULT)

    -- 物攻成长
    self:setLabelText("PhyEffectLabel", phyShape, "PhyEffectPanel")
    self:setLabelText("PhyEffectLabel_2", phyShape, "PhyEffectPanel", COLOR3.TEXT_DEFAULT)

    -- 法攻成长
    self:setLabelText("MagEffectLabel", magShape, "MagEffectPanel")
    self:setLabelText("MagEffectLabel_2", magShape, "MagEffectPanel", COLOR3.TEXT_DEFAULT)

    -- 总成长
    local totalAll = lifeShape + manaShape + speedShape + phyShape + magShape
    self:setLabelText("TotalEffectLabel", totalAll, "TotalEffectPanel")
    self:setLabelText("TotalEffectLabel_2", totalAll, "TotalEffectPanel", COLOR3.TEXT_DEFAULT)
end

-- 进度条分段
function PetHuanHuaDlg:setSubsectionInit(pet)
    if not pet then return end

    local function subsection(panel, count)
        self:setCtrlVisible("SeparateImage_1", (count == 3), panel)
        self:setCtrlVisible("SeparateImage_2", (count == 3), panel)
        self:setCtrlVisible("SeparateImage_3", (count ~= 3), panel)
        self:setCtrlVisible("SeparateImage_4", (count ~= 3), panel)
        self:setCtrlVisible("SeparateImage_5", (count ~= 3), panel)
        self:setCtrlVisible("SeparateImage_6", (count ~= 3), panel)
    end

    local subCount = 3
    local rank = pet:queryInt('rank')
    if rank == Const.PET_RANK_ELITE or rank == Const.PET_RANK_EPIC then
        subCount = 5
    end

    for _, name in pairs(ATTRIB_PANEL) do
        subsection(self:getControl(name), subCount)
    end
end

function PetHuanHuaDlg:onCheckBoxClick(sender, eventType)
    local ATTRIB_VALUE_PANEL = {
        ["life_effect"]   = {attCtrl = "LifeEffectLabel_2", attField = "life", barPanel = "LifePanel"},--"LifeEffectLabel_2",
        ["mana_effect"]   = {attCtrl = "ManaEffectLabel_2", attField = "mana", barPanel = "ManaPanel"},--"ManaEffectLabel_2",
        ["speed_effect"]  = {attCtrl = "SpeedEffectLabel_2", attField = "speed", barPanel = "SpeedPanel"},--"SpeedEffectLabel_2",
        ["phy_effect"]    = {attCtrl = "PhyEffectLabel_2", attField = "phy", barPanel = "PhyPanel"},--"PhyEffectLabel_2",
        ["mag_effect"]    = {attCtrl = "MagEffectLabel_2", attField = "mag", barPanel = "MagPanel"},--"MagEffectLabel_2",
    }

    self.attNo = sender:getTag()
    self:setMainPetGrowUp(self.mainPet)
    self:setMainPetMorph(self.mainPet)
    if sender:getSelectedState() then
        -- 设置相应的属性值
        local panelInfo = ATTRIB_VALUE_PANEL[sender.field]
        local value = tonumber(self:getLabelText(panelInfo["attCtrl"]))
        if value then
            local add = Formula:petHuanhuaAdd(self.mainPet, sender.field)
            local ret = value + add
            self:setLabelText(ATTRIB_VALUE_PANEL[sender.field]["attCtrl"], ret, nil, COLOR3.YELLOW)
            local totalValue = self:getLabelText("TotalEffectLabel_2")
            self:setLabelText("TotalEffectLabel_2", tonumber(totalValue) + add, nil, COLOR3.YELLOW)
        end

        -- 设置相应的进度、次数
        local cur = self.mainPet:queryBasicInt(string.format("morph_%s_stat", panelInfo["attField"]))
        local hMax = PetMgr:getHuanProgressMax(self.mainPet)

        local times = self.mainPet:queryBasicInt(string.format("morph_%s_times", panelInfo["attField"]))
        if cur + 1 == hMax then
            self:setLabelText("TimeLabel_1", (times + 1) .. CHS[3002314], panelInfo["barPanel"], COLOR3.YELLOW)
        end

        self:setProgressBar("ProgressBar", cur + 1, hMax, panelInfo["barPanel"])
    end


end

function PetHuanHuaDlg:onGoOnButton(sender, eventType)
    self:setDisplayType(2)
end

function PetHuanHuaDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("PetHuanHuaRuleDlg")
end

-- 点击副宠要弹出选择副宠界面
function PetHuanHuaDlg:onHeadPanel2(sender, eventType)
    -- 主宠是否是限时宠物
    if PetMgr:isTimeLimitedPet(self.mainPet) then
        gf:ShowSmallTips(CHS[7000095])
        return
    end

    -- 类型判断
    if self.mainPet:queryInt('rank') == Const.PET_RANK_WILD then
        gf:ShowSmallTips(CHS[4100340])
        return
    end

    if PetMgr:getPetCount() == 1 then
        gf:ShowSmallTips(CHS[4100153])
        return
    end

    local dlg = DlgMgr:openDlg("PetEvolveSubmitPetDlg")
    dlg:setSubType("huanhua")
    dlg:setPetList(self.mainPet)

end

function PetHuanHuaDlg:onConfirmButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[5000228])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[5000229])
        return
    end

    if not self.otherPet then
        gf:ShowSmallTips(CHS[4100341])
        return
    end

    if self.attNo == 0 then
        gf:ShowSmallTips(CHS[4100342])
        return
    end

    -- 主宠类型判断
    if self.mainPet:queryInt('rank') == Const.PET_RANK_WILD then
        gf:ShowSmallTips(CHS[4100343])
        return
    end

    -- 副宠是否是百年黑熊 或 血幻豪猪 或 赤血幼猿 或 魅影毒蝎
    if self.otherPet:queryBasic("raw_name") ~= CHS[4100344]
          and self.otherPet:queryBasic("raw_name") ~= CHS[7000136]
          and self.otherPet:queryBasic("raw_name") ~= CHS[7002095]
          and self.otherPet:queryBasic("raw_name") ~= CHS[7002303] then
        gf:ShowSmallTips(CHS[4100345])
        return
    end

    -- 是否进化过
    if PetMgr:isEvolved(self.otherPet) then
        gf:ShowSmallTips(CHS[4100346])
        return
    end

    -- 贵重宠物不能作为副宠
    if gf:isExpensive(self.otherPet, true) then
        gf:ShowSmallTips(CHS[7100059])
        return
    end

    -- 是不是满成长宠物判断
    if not PetMgr:isGrowUpPerfect(self.otherPet) then
        gf:ShowSmallTips(CHS[4100348])
        return
    end

    -- 状态
    local pet_status = self.otherPet:queryInt("pet_status")
    if pet_status == 1 then
        -- 参战
        gf:ShowSmallTips(CHS[4100349])
        return
    elseif pet_status == 2 then
        -- 掠阵
        gf:ShowSmallTips(CHS[4100350])
        return
    end

    -- 天书
    if PetMgr:haveGoodbookSkill(self.otherPet:getId()) then
        gf:ShowSmallTips(CHS[4100351])
        return
    end

    -- 判断当前幻化次数是否3次
    local field = MORPH_NO[self.attNo].field
    local fieldTimes = string.format("morph_%s_times", field)
    if self.mainPet:queryBasicInt(fieldTimes) == PetMgr:getMorphMaxTimes() then
        gf:ShowSmallTips(string.format(CHS[4100352], self.mainPet:getName(), MORPH_NO[self.attNo].chs))
        return true
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onConfirmButton", sender, eventType) then
        return
    end

    self:confirmByStep(1)
end

-- 嵌套确认框判断
function PetHuanHuaDlg:confirmByStep(step)
    if step == 1 then
        local str, day = gf:converToLimitedTimeDay(self.mainPet:queryInt("gift"))
        if PetMgr:isLimitedForeverPet(self.otherPet) and day <= Const.LIMIT_TIPS_DAY then
            gf:confirm(string.format(CHS[4100353], self.mainPet:getName(), MORPH_NO[self.attNo].chs),function ()
                PetMgr:morphPet(self.mainPet, self.otherPet, self.attNo)
            end)
            return
        end
        return self:confirmByStep(2)
    elseif step == 2 then
        gf:confirm(string.format(CHS[4100354], self.mainPet:getName(), MORPH_NO[self.attNo].chs),function ()
            PetMgr:morphPet(self.mainPet, self.otherPet, self.attNo)
        end)
        return
    end
end

-- 成功刷新界面
function PetHuanHuaDlg:MSG_MORPH_SUCCESS(step)
    self.otherPet = nil
    self:setCtrlVisible("NoneImage", true, "HeadPanel2")
    self:setCtrlVisible("SelectLabel", true, "HeadPanel2")
    self:setCtrlVisible("PetLogoPanel", false, "HeadPanel2")
    self.attNo = 0
    self.mainPet = PetMgr:getPetByNo(self.mainPet:queryInt("no"))
    if not self.mainPet then
        -- 幻化界面主宠没有取到
        return
    end

    self:setMainPet(self.mainPet)

    for _, name in pairs(ATTRIB_PANEL) do
        local checkBox = self:getControl("ChoseCheckBox", nil, name)
        checkBox:setSelectedState(false)
        if checkBox.isComplete then checkBox:setVisible(false) end
    end
end

return PetHuanHuaDlg
