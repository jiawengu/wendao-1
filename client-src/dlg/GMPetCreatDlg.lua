-- GMPetCreatDlg.lua
-- Created by songcw Mar/04/2017
-- GM宠物生成

local GMPetCreatDlg = Singleton("GMPetCreatDlg", Dialog)

-- 普遍宠物列表信息
local normalPetList = require(ResMgr:getCfgPath('NormalPetList.lua'))

-- 变异宠物列表信息
local elitePetList = require(ResMgr:getCfgPath('VariationPetList.lua'))

-- 神兽宠物列表信息
local epicPetList = require(ResMgr:getCfgPath('EpicPetList.lua'))

-- 其他宠物列表信息
local otherPetList = require(ResMgr:getCfgPath('OtherPetList.lua'))

-- 纪念宠物
local jinianPetList = require(ResMgr:getCfgPath("JinianPetList.lua"))

-- 精怪宠物列表
local jingguaiPetList = require(ResMgr:getCfgPath('JingGuai.lua'))

-- 所有天书
local godBooks = require(ResMgr:getCfgPath("GodBooks.lua"))

local EQUIP_CFG = require (ResMgr:getCfgPath("QuanmmPKCfg.lua"))

local DUNWU_JINJIE = {
    [CHS[3001987]] = 1,   -- 缓兵之计
    [CHS[3001988]] = 1,   -- 束手就擒
    [CHS[3001989]] = 1,   -- 闻风丧胆
    [CHS[3001990]] = 1,   -- 哀痛欲绝
    [CHS[3001991]] = 1,   -- 养精蓄锐
}

-- 宠物类型
local PET_TYPE = 
{
        {title = CHS[3001219], color = COLOR3.WHITE, flag = "pet_type", content = "normal"},    -- "普通"
        {title = CHS[3001220], color = COLOR3.WHITE, flag = "pet_type", content = "elite"},
        {title = CHS[3003814], color = COLOR3.WHITE, flag = "pet_type", content = "epic"},
        {title = CHS[4200237], color = COLOR3.WHITE, flag = "pet_type", content = "jingg"},
        {title = CHS[6000520], color = COLOR3.WHITE, flag = "pet_type", content = "yuling"},
        {title = CHS[4100464], color = COLOR3.WHITE, flag = "pet_type", content = "other"},
        {title = CHS[7002139], color = COLOR3.WHITE, flag = "pet_type", content = "jinian"},
        {title = CHS[4100465], color = COLOR3.YELLOW, flag = "pet_type", content = "haved"},
}

local PET_TYPE_TO_CHS = {
    normal = CHS[3001219],
    elite = CHS[3001220],
    epic = CHS[3003814],
    jingg = CHS[4200237],
    yuling = CHS[6000520],
    other = CHS[4100464],
    jinian = CHS[7002139],
    haved = CHS[4100465],
} 


-- 宠物表，在init中赋值
local NORMAL_PET_NAME

-- 宠物表，在init中赋值
local ELITE_PET_NAME

-- 宠物表，在init中赋值
local EPIC_PET_NAME

-- 宠物表，在init中赋值
local OTHER_PET_NAME

-- 精怪、御灵
local ZUOJI_PET_NAME

-- 纪念
local JINIAN_PET_NAME

-- 已经有的
local HAVED_PET_NAME

-- 属性面板
local ATTRIB_PANEL = {
    {title = CHS[4100466], flag = "attrib_type", content = "PetPropertiesPanel"},
    {title = CHS[4100467], flag = "attrib_type", content = "SpecialSkillPanel"},
    {title = CHS[4100468], flag = "attrib_type", content = "EclosionPanel"},
    {title = CHS[4100469], flag = "attrib_type", content = "OtherScrollView"},
}

GMPetCreatDlg.VALUE_RANGE = {
    ["LevelNumPanel"] = {MIN = 1, MAX = Const.PLAYER_MAX_LEVEL, DEF = math.min(Me:queryInt("level") + 10, Const.PLAYER_MAX_LEVEL), notNeedChanegColor = true},
    ["SkillNumPanel"] = {MIN = 0, MAX = 160, DEF = "", notNeedChanegColor = true},
    ["MartialNumPanel"] = {MIN = 0, MAX = 3.65 * math.pow(10, 8), DEF = Me:queryInt("tao") * 2, notNeedChanegColor = true},
    ["LifeNumPanel"] = {MIN = 0, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("max_life") - Me:queryInt("gm_attribs/max_life")},
    ["ManaNumPanel"] = {MIN = 0, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("max_mana") - Me:queryInt("gm_attribs/max_mana")},
    ["Phy_powerNumPanel"] = {MIN = 0, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("phy_power") - Me:queryInt("gm_attribs/phy_power")},
    ["Mag_powerNumPanel"] = {MIN = 0, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("mag_power") - Me:queryInt("gm_attribs/mag_power")},
    ["DefenceNumPanel"] = {MIN = 0, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("def") - Me:queryInt("gm_attribs/def")},
    ["SpeedNumPanel"] = {MIN = 0, MAX = 3 * math.pow(10, 4), DEF = Me:queryInt("speed") - Me:queryInt("gm_attribs/speed")},
    
    ["LifeEclosionNumPanel"] = {MIN = 0, MAX = 5, DEF = Me:queryInt("max_life") - Me:queryInt("gm_attribs/max_life"), notNeedChanegColor = true},
    ["ManaEclosionNumPanel"] = {MIN = 0, MAX = 5, DEF = Me:queryInt("max_mana") - Me:queryInt("gm_attribs/max_mana"), notNeedChanegColor = true},
    ["Phy_powerEclosionNumPanel"] = {MIN = 0, MAX = 5, DEF = Me:queryInt("phy_power") - Me:queryInt("gm_attribs/phy_power"), notNeedChanegColor = true},
    ["Mag_powerEclosionNumPanel"] = {MIN = 0, MAX = 5, DEF = Me:queryInt("mag_power") - Me:queryInt("gm_attribs/mag_power"), notNeedChanegColor = true},
    ["DefenceEclosionNumPanel"] = {MIN = 0, MAX = 5, DEF = Me:queryInt("def") - Me:queryInt("gm_attribs/def"), notNeedChanegColor = true},
    ["SpeedEclosionNumPanel"] = {MIN = 0, MAX = 5, DEF = Me:queryInt("speed") - Me:queryInt("gm_attribs/speed"), notNeedChanegColor = true},
    ["IntimateNumPanel"] = {MIN = 0, MAX = 9 * math.pow(10, 6), DEF = 0, notNeedChanegColor = true},
    ["StrengthenNumPanel"] = {MIN = 0, MAX = 12, DEF = 0, notNeedChanegColor = true},
    
}

GMPetCreatDlg.godBooks = {}

GMPetCreatDlg.skillInfo = {}

GMPetCreatDlg.dunwu = {}

function GMPetCreatDlg:init()
    -- 部分条件会变化，所以每次初始化更新下    
    NORMAL_PET_NAME = NORMAL_PET_NAME or self:getPetCfg("normal")
    ELITE_PET_NAME = ELITE_PET_NAME or self:getPetCfg("elite")
    EPIC_PET_NAME = EPIC_PET_NAME or self:getPetCfg("epic")
    OTHER_PET_NAME = OTHER_PET_NAME or self:getPetCfg("other")
    ZUOJI_PET_NAME = ZUOJI_PET_NAME or self:getPetCfg("jingguai")
    JINIAN_PET_NAME = JINIAN_PET_NAME or self:getPetCfg("jinian")
    HAVED_PET_NAME = self:getPetCfg("haved")

    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("RefineButton", self.onRefineButton)
    
    -- 下拉框绑定
    self:bindListener("TypeBKImage", self.onSelectPetTypeBtn)
    self:bindListener("NameBKImage", self.onSelectPetNameBtn)
    self:bindListener("ChooseBKImage", self.onSelectAttBtn)
    
    self:bindListener("UpgradeCheckBox", self.onUpgradeCheck)
    
    for i = 1, 3 do
        local image = self:getControl("GodbookBKImage_" .. i)
        image:setTag(i)
        self:bindTouchEndEventListener(image, self.onSelectGodBookBtn)         
    end        
    --
    for i = 1, 2 do
        local image = self:getControl("DunSkillBKImage_" .. i)
        image:setTag(i)
        self:bindTouchEndEventListener(image, self.onSelectDunBtn)         
    end 
    --]]   
    
    self.skillPanel = self:toCloneCtrl("SkillPanel")  
    
    self.oneRowPanel = self:toCloneCtrl("OneRowPanel")
    -- 弹出菜单点击事件绑定
    for i = 1, 3 do
        self:bindListener("UnitPanel" .. i, self.onSelectUnitBtn, self.oneRowPanel)    
    end    
    
    self:bindFloatPanelListener("TipPanel")
    
    -- 绑定各种输入框
    GMMgr:bindEditBoxForGM(self, "LevelNumPanel", self.levelDownCallBack)
    GMMgr:bindEditBoxForGM(self, "MartialNumPanel", self.martialDownCallBack)
    GMMgr:bindEditBoxForGM(self, "IntimateNumPanel")        
    GMMgr:bindEditBoxForGM(self, "LifeNumPanel", nil, nil, "PetPropertiesPanel")
    GMMgr:bindEditBoxForGM(self, "ManaNumPanel", nil, nil, "PetPropertiesPanel")
    GMMgr:bindEditBoxForGM(self, "Phy_powerNumPanel", nil, nil, "PetPropertiesPanel")
    GMMgr:bindEditBoxForGM(self, "Mag_powerNumPanel", nil, nil, "PetPropertiesPanel")
    GMMgr:bindEditBoxForGM(self, "DefenceNumPanel", nil, nil, "PetPropertiesPanel")
    GMMgr:bindEditBoxForGM(self, "SpeedNumPanel", nil, nil, "PetPropertiesPanel")    
    GMMgr:bindEditBoxForGM(self, "LifeEclosionNumPanel")
    GMMgr:bindEditBoxForGM(self, "ManaEclosionNumPanel")
    GMMgr:bindEditBoxForGM(self, "Phy_powerEclosionNumPanel")
    GMMgr:bindEditBoxForGM(self, "Mag_powerEclosionNumPanel")
    GMMgr:bindEditBoxForGM(self, "SpeedEclosionNumPanel")    
    GMMgr:bindEditBoxForGM(self, "StrengthenNumPanel")
    
    self:initDlg()
    
    self:hookMsg("MSG_AMDIN_NEW_PET")
    self:hookMsg("MSG_UPDATE_PETS")
end

function GMPetCreatDlg:onUpgradeCheck(sender, eventType)  
    if not self.selectPet then
        return
    end
    if sender:getSelectedState() == true then
        if self.selectPet:queryBasicInt("level") < 110 then
            gf:ShowSmallTips(CHS[4200480])
            sender:setSelectedState(false)
        end
    else
        if self.selectPet:queryBasicInt("level") > 115 then
            gf:ShowSmallTips(CHS[4200481])
            sender:setSelectedState(true)
        end
    end
     
end

-- 初始化界面
function GMPetCreatDlg:initDlg()
    -- 显示相关的panel
    self:setDisplayPanel("NonePetPanel")
    
    -- 初始化技能
    self:setSkillListViewByPetName()
    
    -- 设置默认值
    self:setDefalueValue()   
    
    for i = 1, 3 do
        self:setLabelText("GodbookTextField_" .. i, CHS[5000059])
    end    
   
    -- 初始化scrollView 
    local scroll = self:getControl("OtherScrollView")
    local inner = self:getControl("OtherPanel", nil, scroll)
    scroll:setInnerContainerSize(inner:getContentSize())
    --]]
end

-- 技能等级未成功输入，返回默认
function GMPetCreatDlg:skillDefCallBack(sender, value)
    value = tonumber(value)    
    local tag = sender:getParent():getTag()
    self.skillInfo[tag].level = value
end

-- 技能等级输入完成后回调
function GMPetCreatDlg:skillDownCallBack(sender, value)
    value = tonumber(value)    
    local tag = sender:getParent():getTag()
    self.skillInfo[tag].level = value
end

-- 等级输入完成后回调
function GMPetCreatDlg:levelDownCallBack(sender, value)
    local martial = tonumber(GMMgr:getEditBoxValue(self, "MartialNumPanel"))
    if not martial then return end   
    local level = value
    if not level then return end
    
    if self.selectPet then
        -- 如果是已有宠物
        GMMgr:setAdminPetLevel(self.selectPet:queryBasicInt("no"), level)
    end    
    
    if martial == 0 then
        self:setLabelText("MartialLabel_2", string.format(CHS[4100470], martial))
        return
    end

    local level = value
    self:setLabelText("MartialLabel_2", string.format(CHS[4100470], martial / math.floor(Formula:getStdMartial(level))))
end

-- 武学设置完后回调
function GMPetCreatDlg:martialDownCallBack(sender, value)
    local martial = value
    if not martial then return end
    if martial == 0 then
        self:setLabelText("MartialLabel_2", string.format(CHS[4100470], martial))
        return
    end

    local level = tonumber(GMMgr:getEditBoxValue(self, "LevelNumPanel"))
    self:setLabelText("MartialLabel_2", string.format(CHS[4100470], martial / math.floor(Formula:getStdMartial(level))))
end

function GMPetCreatDlg:getPetCfg(petType)
    local ret = {}
    local srcTab
    if petType == "normal" then
        srcTab = normalPetList
    elseif petType == "elite" then
        srcTab = elitePetList
    elseif petType == "epic" then
        srcTab = epicPetList
    elseif petType == "other" then        
        srcTab = otherPetList
    elseif petType == "jinian" then
        srcTab = jinianPetList
    elseif petType == "haved" then
        srcTab = PetMgr.pets
        for name, pet in pairs(PetMgr.pets) do
            local data = {title = pet:queryBasic("name"), flag = "pet_name", raw_name = pet:queryBasic("raw_name"), havePet = pet}
            table.insert(ret, data)            
        end
        return ret
    else
        srcTab = jingguaiPetList
    end
    
    for name, info in pairs(srcTab) do
        local data = {title = name, flag = "pet_name", raw_name = name, level_req = info.level_req, index = info.index, order = info.order}
        table.insert(ret, data)
    end
    
    if petType == "normal" then
        table.sort(ret, function(l, r)
            if l.level_req < r.level_req then return true end
            if l.level_req > r.level_req then return false end
            if l.index < r.index then return true end
            if l.index > r.index then return false end
        end)
    else
        table.sort(ret, function(l, r) return l.order < r.order end)
    end
    
    return ret
end

function GMPetCreatDlg:cleanup()
    self.selectPetName = nil
    self.petType = nil
    self.selectPet = nil
    self.godBooks = {}
    self.skillInfo = {}

    self:releaseCloneCtrl("oneRowPanel")
    self:releaseCloneCtrl("skillPanel")
end

function GMPetCreatDlg:setDisplayPanel(panelName)
    self:setCtrlVisible("PetPropertiesPanel", panelName == "PetPropertiesPanel")
    self:setCtrlVisible("SpecialSkillPanel", panelName == "SpecialSkillPanel")
    self:setCtrlVisible("EclosionPanel", panelName == "EclosionPanel")
    self:setCtrlVisible("OtherScrollView", panelName == "OtherScrollView")    
    self:setCtrlVisible("NonePetPanel", panelName == "NonePetPanel")    
    self:setCtrlVisible("ChoosePanel", panelName ~= "NonePetPanel")
    
    if panelName == "PetPropertiesPanel" then
        self:setLabelText("ChooseTextField", CHS[4200248])    -- 基础属性
    else
        if panelName == "NonePetPanel" or panelName == nil then
            self:setLabelText("ChooseTextField", CHS[4200249])
        end
    end 
end

-- 点击弹出项
function GMPetCreatDlg:onSelectUnitBtn(sender, eventType)
    local data = sender.data       
    
    if data.flag == "pet_type" then
        -- 选择宠物类型
        self:setLabelText("TypeTextField", data.title)        
        self.petType = data.content    
        self:setLabelText("NameTextField", CHS[4100471]) 
        self.selectPetName = nil
        self.selectPet = nil
        self:setDisplayPanel("NonePetPanel")
        
        self:updataValueConst()
        
        self:initGodBooks()
    elseif data.flag == "attrib_type" then
        -- 选择调整类型
        self:setDisplayPanel(data.content)
        self:setLabelText("ChooseTextField", data.title) 
    elseif data.flag == "pet_name" then
        -- 选择宠物名字
        self:setLabelText("NameTextField", data.title) 
        self.selectPetName = data.raw_name
        self.selectPet = data.havePet
        
        self:setSkillListViewByPetName(data.raw_name)        
        if data.havePet then
            self:setDisplayPanel("PetPropertiesPanel")
            self:updataValueConst(data.havePet)
            self:setDataByPet(data.havePet)                 
        end
    elseif data.flag == "god_book" then
        -- 点击选择天书         
        self.godBooks[data.content] = nil
        self:setLabelText("GodbookTextField_" .. data.content, data.title)
        self.godBooks[data.content] = data.title
    elseif data.flag == "dunwu" then
        self.dunwu[data.content] = nil
        self:setLabelText("DunSkillTextField_" .. data.content, data.title)
        self.dunwu[data.content] = data.title
    end
    
    self:setCtrlVisible("TipPanel", false)
end

-- 设置默认数值
function GMPetCreatDlg:setDefalueValue()
    local level = math.min(Me:queryInt("level") + 10, Const.PLAYER_MAX_LEVEL)
    local martial = math.floor(Me:queryBasicInt("tao") * 2)    

    -- 等级、武学
    self:setLevelAndMartial(level, martial, 0)
    
    self:martialDownCallBack(nil, martial)
end

-- 设置等级、武学
function GMPetCreatDlg:setLevelAndMartial(level, martial, intimaty)
    -- 等级    
    GMMgr:setEditBoxValue(self, "LevelNumPanel", level)

    -- 武学
    GMMgr:setEditBoxValue(self, "MartialNumPanel", martial)
    
    -- 亲密
    GMMgr:setEditBoxValue(self, "IntimateNumPanel", intimaty)
    
    self:martialDownCallBack(nil, martial)
end

-- 设置基本属性信息
function GMPetCreatDlg:setBasicAttrib(pet)

    local max_life, max_mana, phy_power, mag_power, def, speed = pet:queryInt("max_life") ,pet:queryInt("max_mana"), pet:queryInt("phy_power"), pet:queryInt("mag_power"), pet:queryInt("def"), pet:queryInt("speed")

    -- == 基础信息
    local basicPanel = self:getControl("PetPropertiesPanel")
    -- 气血
    local color = COLOR3.WHITE
    if pet:queryInt("gm_attribs/max_life") < 0 then color = COLOR3.RED end
    if pet:queryInt("gm_attribs/max_life") > 0 then color = COLOR3.GREEN end
    GMMgr:setEditBoxValue(self, "LifeNumPanel", max_life, color)
    
    -- 法力
    color = COLOR3.WHITE
    if pet:queryInt("gm_attribs/max_mana") < 0 then color = COLOR3.RED end
    if pet:queryInt("gm_attribs/max_mana") > 0 then color = COLOR3.GREEN end
    GMMgr:setEditBoxValue(self, "ManaNumPanel", max_mana, color)
    
    -- 物伤
    color = COLOR3.WHITE
    if pet:queryInt("gm_attribs/phy_power") < 0 then color = COLOR3.RED end
    if pet:queryInt("gm_attribs/phy_power") > 0 then color = COLOR3.GREEN end
    GMMgr:setEditBoxValue(self, "Phy_powerNumPanel", phy_power, color)
    
    -- 法伤
    color = COLOR3.WHITE
    if pet:queryInt("gm_attribs/mag_power") < 0 then color = COLOR3.RED end
    if pet:queryInt("gm_attribs/mag_power") > 0 then color = COLOR3.GREEN end
    GMMgr:setEditBoxValue(self, "Mag_powerNumPanel", mag_power, color)
    
    -- 防御
    color = COLOR3.WHITE
    if pet:queryInt("gm_attribs/def") < 0 then color = COLOR3.RED end
    if pet:queryInt("gm_attribs/def") > 0 then color = COLOR3.GREEN end
    GMMgr:setEditBoxValue(self, "DefenceNumPanel", def, color)
    
    -- 速度
    color = COLOR3.WHITE
    if pet:queryInt("gm_attribs/speed") < 0 then color = COLOR3.RED end
    if pet:queryInt("gm_attribs/speed") > 0 then color = COLOR3.GREEN end
    GMMgr:setEditBoxValue(self, "SpeedNumPanel", speed, color)
end

function GMPetCreatDlg:setDunSkillVisible(isVisible, index)
    if isVisible then
        self:setLabelText("DunSkillLabel_" .. index, CHS[4200482] .. index)    
        self:setLabelText("DunSkillTextField_" .. index, "")        
    else
        self:setLabelText("DunSkillLabel_" .. index, "")    
        self:setLabelText("DunSkillTextField_" .. index, "")        
    end
    self:setCtrlVisible("DunSkillTextField_" .. index, isVisible)
    self:setCtrlVisible("DunSkillImage_" .. index, isVisible)
    self:setCtrlVisible("DunSkillBKImage_" .. index, isVisible)
end

function GMPetCreatDlg:getCanChosenDunwSkill(tag)
    if not self.selectPet then return {} end    
    local total = {}
    
    if not self.dunwu or not next(self.dunwu) then
        self.dunwu = {}
    end
    
    local skill1, skill2 = self.dunwu[1], self.dunwu[2]

    local hasInnateSkill = SkillMgr:getPetRawSkillNoAndLadder(self.selectPet:getId()) or {}

    local function isExsit(descSkill, skills)        
        for i = 1, #skills do
            if descSkill == skills[i].name then return true end
        end
        return false
    end

    --local skillAll = {"缓兵之计", "束手就擒", "闻风丧胆", "哀痛欲绝", "养精蓄锐"}
    local skillAll = EQUIP_CFG[CHS[4100538]]
    for _, skillName in pairs(skillAll) do
    
        local isExsitInSkill = false -- 是否在技能面板中
        local listCtrl = self:getControl("SkillListView")
        local itemPanels = listCtrl:getItems()
        for p, unitPanel in pairs(itemPanels) do
            if unitPanel.data.skillName == skillName then
                isExsitInSkill = true
            end
        end
    
        if not isExsitInSkill then
            if tag == 1 then
                if type(skillName) == "table" then
                    local skillTemp = skillName[self.selectPet:queryInt("polar")]
                    if skillTemp and not isExsit(skillTemp, hasInnateSkill) and skillTemp ~= skill2 then
                        table.insert(total, skillTemp)
                    end
                else
                    if skillName ~= skill2 and not isExsit(skillName, hasInnateSkill) then
                        table.insert(total, skillName)
                    end
                end
            else
                if type(skillName) == "table" then
                    local skillTemp = skillName[self.selectPet:queryInt("polar")]
                    if skillTemp and not isExsit(skillTemp, hasInnateSkill) and skillTemp ~= skill1 then
                        table.insert(total, skillTemp)
                    end
                else
                    if skillName ~= skill1 and not isExsit(skillName, hasInnateSkill) then
                        table.insert(total, skillName)
                    end
                end
            
            end
        end
    end

    return total
end

function GMPetCreatDlg:setDataByPet(pet)
    -- 等级、武学
    self:setLevelAndMartial(pet:queryBasicInt("level"), pet:queryBasicInt("martial"), pet:queryBasicInt("origin_intimacy"))
    
    -- 设置基本属性信息
    self:setBasicAttrib(pet)
    
    -- 点化
    self:setCheck("EnchantCheckBox", PetMgr:isDianhuaOK(pet))
    
    self:setCheck("UpgradeCheckBox", PetMgr:isFlyPet(pet))    
    
    self:setCheck("YuhuaCheckBox", PetMgr:isYuhuaCompleted(pet))
    
    -- 强化
    local field = "mag" 
    self:setLabelText("StrengthenLabel", CHS[4200250])    -- "强化法攻"
    if pet:queryBasicInt("polar") == 0 then 
        field = "phy"
        self:setLabelText("StrengthenLabel", CHS[4200251])  -- 强化物攻
    end
    local level = pet:queryInt(field .. "_rebuild_level")
    GMMgr:setEditBoxValue(self, "StrengthenNumPanel", level)
    if pet:queryInt('rank') == Const.PET_RANK_ELITE then
        self:setLabelText("StrengthenMaxLabel", "/0")
        self:setLabelText("StrengthenLabel", CHS[3003811]) 
    else
        self:setLabelText("StrengthenMaxLabel", "/12")
    end
    
    -- 天书
    local nGodBookCount = pet:queryBasicInt('god_book_skill_count')
    self.godBooks = {}
    for i = 1, 3 do
        if i <= nGodBookCount then
            -- 名字
            local key = 'god_book_skill_name_' .. i
            self:setLabelText("GodbookTextField_" .. i, pet:queryBasic(key))
            
            self.godBooks[i] = pet:queryBasic(key)
        else
            self:setLabelText("GodbookTextField_" .. i, CHS[5000059])
        end
    end
    
    local hasInnateSkill = SkillMgr:getPetRawSkillNoAndLadder(pet:getId()) or {}
    local petSkills = SkillMgr:getSkillNoAndLadder(pet:getId(), SKILL.SUBCLASS_E, SKILL.CLASS_PET)
    -- 技能
    local listCtrl = self:getControl("SkillListView")
    local items = listCtrl:getItems()
    for _, panel in pairs(items) do    
        GMMgr:setEditBoxValue(self, "SkillNumPanel", 0, nil, panel)
        for i = 1, #hasInnateSkill do
            if panel.data.skillName == hasInnateSkill[i].name then
         
                GMMgr:setEditBoxValue(self, "SkillNumPanel", hasInnateSkill[i].level, nil, panel)

                self.skillInfo[_].level = hasInnateSkill[i].level       
                self:setLabelText("MaxSkillLabel", "/" .. math.floor(pet:getLevel() * 1.6), panel)         
                panel.data.level = hasInnateSkill[i].level
            end
        end
        
        for i = 1, #petSkills do
            if panel.data.skillName == petSkills[i].name then
                GMMgr:setEditBoxValue(self, "SkillNumPanel", petSkills[i].level, nil, panel)
                self.skillInfo[_].level = petSkills[i].level
                self:setLabelText("MaxSkillLabel", "/" .. math.floor(pet:getLevel() * 1.6), panel)
                panel.data.level = petSkills[i].level
            end
        end
    end
    
    -- 顿悟技能
    local dunWuSkills = SkillMgr:getPetDunWuSkills(pet:getId()) or {}
    
    local petRank = pet:queryInt('rank')
    self:setDunSkillVisible(petRank == Const.PET_RANK_ELITE or petRank == Const.PET_RANK_EPIC, 2)
    
    for i = 1, 2 do
        if dunWuSkills[i] then
            self:setDunSkillVisible(true, i)
            self:setLabelText("DunSkillTextField_" .. i, dunWuSkills[i])
            self.dunwu[i] = dunWuSkills[i]
        else
            self:setLabelText("DunSkillTextField_" .. i, CHS[2100078])
            self.dunwu[i] = ""
        end
    end 
    --]]  
    
    -- 气血
    GMMgr:setEditBoxValue(self, "LifeEclosionNumPanel", pet:queryBasicInt("morph_life_times"))    

    -- 法力
    GMMgr:setEditBoxValue(self, "ManaEclosionNumPanel", pet:queryBasicInt("morph_mana_times"))

    -- 物伤
    GMMgr:setEditBoxValue(self, "Phy_powerEclosionNumPanel", pet:queryBasicInt("morph_phy_times"))

    -- 法伤
    GMMgr:setEditBoxValue(self, "Mag_powerEclosionNumPanel", pet:queryBasicInt("morph_mag_times"))

    -- 速度
    GMMgr:setEditBoxValue(self, "SpeedEclosionNumPanel", pet:queryBasicInt("morph_speed_times"))
end

function GMPetCreatDlg:getSkillsInfoByName(name)
    local retInate = {}
    local inateSkill = PetMgr:petHaveRawSkill(name) or {}
    local developSkill = PetMgr:getDevelopSkillList()
    
    for i, info in pairs(inateSkill) do
        table.insert(retInate, {skillName = info, displayContent = CHS[4100472]})
    end
    
    local devSkill = {}
    for i, info in pairs(developSkill) do
        table.insert(devSkill, {skillName = info, displayContent = CHS[4100473]})
    end
    return retInate, devSkill
end


function GMPetCreatDlg:setSkillListViewByPetName(name)
    local listCtrl = self:resetListView("SkillListView")
    if not name then return end
    
    local inaSkill, devSkill  = self:getSkillsInfoByName(name)
    self.skillInfo = {}
    
    local add = 0
    for i, info in pairs(inaSkill) do
        add = add + 1
        local panel = self.skillPanel:clone()
        self:setLabelText("SkillLabel", string.format(info.displayContent, i, info.skillName), panel)     
        if self.selectPet then
            self:setLabelText("MaxSkillLabel", "/" .. math.floor(self.selectPet:getLevel() * 1.6), panel)
        else
            self:setLabelText("MaxSkillLabel", "", panel)
        end 
        
        GMMgr:bindEditBoxForGM(self, "SkillNumPanel", self.skillDownCallBack, nil, panel, self.skillDefCallBack)
        
        listCtrl:pushBackCustomItem(panel)
        
        local level = math.floor(GMMgr:getEditBoxValue(self, "LevelNumPanel") * 1.6)
        
        local data = {skillName = info.skillName, level = level}
        panel.data = data
        local editBoxPanel = self:getControl("SkillNumPanel", nil, panel)
        panel:setTag(add)
        editBoxPanel:setTag(add)
        table.insert(self.skillInfo, data)        
    end
    
    for i, info in pairs(devSkill) do
        add = add + 1
        local panel = self.skillPanel:clone()
        self:setLabelText("SkillLabel", string.format(info.displayContent, i, info.skillName), panel)     
        if self.selectPet then
            self:setLabelText("MaxSkillLabel", "/" .. math.floor(self.selectPet:getLevel() * 1.6), panel)
        else
            self:setLabelText("MaxSkillLabel", "", panel)
        end 

        GMMgr:bindEditBoxForGM(self, "SkillNumPanel", self.skillDownCallBack, nil, panel, self.skillDefCallBack)

        listCtrl:pushBackCustomItem(panel)

        local level = math.floor(GMMgr:getEditBoxValue(self, "LevelNumPanel") * 1.6)

        local data = {skillName = info.skillName, level = level}
        panel.data = data
        local editBoxPanel = self:getControl("SkillNumPanel", nil, panel)
        panel:setTag(add)
        editBoxPanel:setTag(add)
        table.insert(self.skillInfo, data)        
    end   
    
    listCtrl:doLayout()
    listCtrl:refreshView()    
end


function GMPetCreatDlg:onSelectDunBtn(sender, eventType)

    local skill = self:getCanChosenDunwSkill(sender:getTag())
    local ret = {}
    for _, skillName in pairs(skill) do
        table.insert(ret, {title = skillName, flag = "dunwu", content = sender:getTag()})
    end
    self:setCtrlVisible("TipPanel", true)
    self:setListViewData(ret)
end

-- 点击天书
function GMPetCreatDlg:onSelectGodBookBtn(sender, eventType)
    local ret = {}
    for name, info in pairs(godBooks) do
    
        local isExist = false
        for _, skillName in pairs(self.godBooks) do
            if name == skillName then
                isExist = true
            end
        end
    
    
        if not isExist then
            table.insert(ret, {title = name, flag = "god_book", content = sender:getTag()})
        end
    end
    
    self:setCtrlVisible("TipPanel", true)
    self:setListViewData(ret)
end

-- 点击调整类型
function GMPetCreatDlg:onSelectAttBtn(sender, eventType)
    if not self.petType then
        gf:ShowSmallTips(CHS[3003058])
        return 
    end
    
    if not self.selectPet then return end

    self:setCtrlVisible("TipPanel", true)
    self:setListViewData(ATTRIB_PANEL)
end

-- 点击弹出选择宠物名称
function GMPetCreatDlg:onSelectPetNameBtn(sender, eventType)
    if not self.petType then
        gf:ShowSmallTips(CHS[3003058])
        return 
    end
    
    self:setCtrlVisible("TipPanel", true)
    if self.petType == "normal" then 
        self:setListViewData(NORMAL_PET_NAME)
    elseif self.petType == "elite" then
        self:setListViewData(ELITE_PET_NAME)
    elseif self.petType == "epic" then
        self:setListViewData(EPIC_PET_NAME)
    elseif self.petType == "other" then
        self:setListViewData(OTHER_PET_NAME)
    elseif self.petType == "yuling" or self.petType == "jingg" then
        self:setListViewData(ZUOJI_PET_NAME)
    elseif self.petType == "jinian" then
        self:setListViewData(JINIAN_PET_NAME)
    elseif self.petType == "haved" then
        self:setListViewData(HAVED_PET_NAME)
    end    
end

-- 点击弹出选择宠物类型
function GMPetCreatDlg:onSelectPetTypeBtn(sender, eventType)


    self:setCtrlVisible("TipPanel", true)
    self:setListViewData(PET_TYPE)    
end

-- 将表数据设置进listView
function GMPetCreatDlg:setListViewData(tabData)
    local listCtrl = self:resetListView("ListView")
    local count = math.ceil(#tabData / 3)
    for i = 1, count do
        local panel = self.oneRowPanel:clone()        
        for j = 1, 3 do
            local key = (i - 1) * 3 + j
            local unitPanel = self:getControl("UnitPanel" .. j, nil, panel)
            if tabData[key] then
                unitPanel.data = tabData[key]
                self:setLabelText("Label", tabData[key].title, unitPanel, tabData[key].color or COLOR3.WHITE)
            else
                unitPanel:setVisible(false)
            end
        end
        listCtrl:pushBackCustomItem(panel)
    end
    listCtrl:doLayout()
    listCtrl:refreshView()
end

function GMPetCreatDlg:getAttribStr()

--string，武学、气血、法力、物伤、法伤、防御、速度属性，以“|”分隔。
    if not self.selectPet then return end
    
    local pet = self.selectPet

    local martial = GMMgr:getEditBoxValue(self, "MartialNumPanel")

    -- == 基础信息
    local basicPanel = self:getControl("PetPropertiesPanel")    
    -- 气血       
    local life = tonumber(GMMgr:getEditBoxValue(self, "LifeNumPanel")) - (pet:queryInt("max_life") - pet:queryInt("gm_attribs/max_life"))

    -- 法力   
    local mana = tonumber(GMMgr:getEditBoxValue(self, "ManaNumPanel")) - (pet:queryInt("max_mana") - pet:queryInt("gm_attribs/max_mana"))
    
    -- 物伤  
    local phy = tonumber(GMMgr:getEditBoxValue(self, "Phy_powerNumPanel")) - (pet:queryInt("phy_power") - pet:queryInt("gm_attribs/phy_power"))

    -- 法伤 
    local mag = tonumber(GMMgr:getEditBoxValue(self, "Mag_powerNumPanel")) - (pet:queryInt("mag_power") - pet:queryInt("gm_attribs/mag_power"))

    -- 防御   
    local def = tonumber(GMMgr:getEditBoxValue(self, "DefenceNumPanel")) - (pet:queryInt("def") - pet:queryInt("gm_attribs/def"))

    -- 速度       
    local speed = tonumber(GMMgr:getEditBoxValue(self, "SpeedNumPanel")) - (pet:queryInt("speed") - pet:queryInt("gm_attribs/speed"))
    
    -- 亲密
    local intimate = GMMgr:getEditBoxValue(self, "IntimateNumPanel")
    
    local str = martial .. "|" .. life .. "|" .. mana .. "|" .. phy .. "|" .. mag .. "|" .. def .. "|" .. speed .. "|" .. intimate
    return str 
end

-- 获取幻化字符串
function GMPetCreatDlg:getMorphStr()
    local basicPanel = self:getControl("EclosionPanel")
        
    -- 气血   
    local life = tonumber(GMMgr:getEditBoxValue(self, "LifeEclosionNumPanel")) or 0

    -- 法力  
    local mana = tonumber(GMMgr:getEditBoxValue(self, "ManaEclosionNumPanel")) or 0

    -- 物伤   
    local phy = tonumber(GMMgr:getEditBoxValue(self, "Phy_powerEclosionNumPanel")) or 0

    -- 法伤   
    local mag = tonumber(GMMgr:getEditBoxValue(self, "Mag_powerEclosionNumPanel")) or 0

    -- 速度  
    local speed = tonumber( GMMgr:getEditBoxValue(self, "SpeedEclosionNumPanel")) or 0

    local str = life .. "|" .. mana .. "|" .. phy .. "|" .. mag .. "|" .. speed
    return str 
end

function GMPetCreatDlg:initGodBooks()    
    self.godBooks = {}
    for i = 1, 3 do
        self:setLabelText("GodbookTextField_" .. i, CHS[5000059])
    end
end


function GMPetCreatDlg:getLevel()    
    return tonumber(GMMgr:getEditBoxValue(self, "LevelNumPanel"))    
end

function GMPetCreatDlg:getMartial()
    return tonumber(GMMgr:getEditBoxValue(self, "MartialNumPanel"))
end

function GMPetCreatDlg:getIntimate()
    return tonumber(GMMgr:getEditBoxValue(self, "IntimateNumPanel"))
end

function GMPetCreatDlg:onConfirmButton(sender, eventType)
    if not self.selectPetName or not self.petType then
        gf:ShowSmallTips(CHS[4200253])        
        return
    end

    local godbookStr = ""
    for name, info in pairs(self.godBooks) do
        if godbookStr ~= "" then godbookStr = godbookStr .. "|" end
        godbookStr = godbookStr .. info
    end
    
    local skillStr = ""
    for _, info in pairs(self.skillInfo) do
        if skillStr ~= "" then skillStr = skillStr .. "|" end
        skillStr = skillStr .. info.skillName .. ":" .. info.level
    end   

    
    if not self.selectPet then
        -- 要生成新宠物
        local info = self.selectPetName .. ":" .. self:getLevel()
        local attribStr = self:getMartial() .. "|0|0|0|0|0|0"
        local morphStr = "3|3|3|3|3"
        
        local isFly = (tonumber(self:getLevel()) > 115) and 1 or 0 
        GMMgr:setAdminPetAttrib(PET_TYPE_TO_CHS[self.petType], info, attribStr, skillStr, morphStr, 0, 0, godbookStr, 0, 0, isFly)
    else
        local attribStr = self:getAttribStr()
        local morphStr = self:getMorphStr()
        
        if self.dunwu[1] ~= "" then
            if skillStr ~= "" then skillStr = skillStr .. "|" end
            local level = self.selectPet:queryInt("level") * 1.6
            if DUNWU_JINJIE[self.dunwu[1]] then
                level = math.min(160, level)
            end            
            
            skillStr = skillStr .. self.dunwu[1] .. ":" .. level
        end
        
        if self.dunwu[2] ~= "" then
            local rank = self.selectPet:queryInt('rank')
            if  rank == Const.PET_RANK_ELITE or rank == Const.PET_RANK_EPIC then
                local level = self.selectPet:queryInt("level") * 1.6
                if DUNWU_JINJIE[self.dunwu[2]] then
                    level = math.min(160, level)
                end     
                if skillStr ~= "" then skillStr = skillStr .. "|" end
                skillStr = skillStr .. self.dunwu[2] .. ":" .. level
            end
        end

        
        local rebuild = tonumber(GMMgr:getEditBoxValue(self, "StrengthenNumPanel")) or 0
        local isDianhua = 0
        if self:isCheck("EnchantCheckBox") then isDianhua = 1 end
        local isYuhua = self:isCheck("YuhuaCheckBox") and 1 or 0
        
        local intimaty = self:getIntimate()
        
        local isFly = self:isCheck("UpgradeCheckBox") and 1 or 0
        GMMgr:setAdminPetAttrib(PET_TYPE_TO_CHS["haved"], self.selectPet:queryBasic('no'), attribStr, skillStr, morphStr, rebuild, isDianhua, godbookStr, isYuhua, intimaty, isFly)
    end
end

function GMPetCreatDlg:setOriginalPet(pet)
    self:setDataByPet(pet)
    local max_life, max_mana, phy_power, mag_power, def, speed = pet:queryInt("max_life") ,pet:queryInt("max_mana"), pet:queryInt("phy_power"), pet:queryInt("mag_power"), pet:queryInt("def"), pet:queryInt("speed")

    -- == 基础信息
    local basicPanel = self:getControl("PetPropertiesPanel")
    -- 气血       GMMgr:getEditBoxValue(dlg, ctlName)
    local color = COLOR3.WHITE
    GMMgr:setEditBoxValue(self, "LifeNumPanel", max_life - pet:queryInt("gm_attribs/max_life"), color) 
    
    -- 法力
    GMMgr:setEditBoxValue(self, "ManaNumPanel", max_mana - pet:queryInt("gm_attribs/max_mana"), color)    
    
    -- 物伤
    GMMgr:setEditBoxValue(self, "Phy_powerNumPanel", phy_power - pet:queryInt("gm_attribs/phy_power"), color)
    
    -- 法伤
    GMMgr:setEditBoxValue(self, "Mag_powerNumPanel", mag_power - pet:queryInt("gm_attribs/mag_power"), color)
    
    -- 防御
    GMMgr:setEditBoxValue(self, "DefenceNumPanel", def - pet:queryInt("gm_attribs/def"), color)
    
    -- 速度
    GMMgr:setEditBoxValue(self, "SpeedNumPanel", speed - pet:queryInt("gm_attribs/speed"), color)
end

function GMPetCreatDlg:onRefineButton(sender, eventType)
    if not self.selectPet then
        gf:ShowSmallTips(CHS[4200252])
        return
    end

    self:updataValueConst(self.selectPet)
    self:setOriginalPet(self.selectPet)
end

function GMPetCreatDlg:updataValueConst(pet)
    if pet then
        local eclosionDef = 3           
        -- 强化
        local field = "mag" 
        if pet:queryBasicInt("polar") == 0 then 
            field = "phy" 
        end
        local strLevel = pet:queryInt(field .. "_rebuild_level")
        local strMax = 12
        local rank = pet:queryInt('rank')
        if rank == Const.PET_RANK_ELITE or rank == Const.PET_RANK_EPIC then
            strMax = 0
        end
        
        self.VALUE_RANGE = {        
            ["LevelNumPanel"] = {MIN = 1, MAX = Const.PLAYER_MAX_LEVEL, DEF = math.min(Me:queryInt("level") + 10, Const.PLAYER_MAX_LEVEL), notNeedChanegColor = true},
            ["SkillNumPanel"] = {MIN = 0, MAX = math.floor(pet:queryInt("level") * 1.6), DEF = math.floor(pet:queryInt("level") * 1.6), notNeedChanegColor = true},
            ["MartialNumPanel"] = {MIN = 0, MAX = 3.65 * math.pow(10, 8), DEF = pet:queryInt("martial"), notNeedChanegColor = true},
            ["LifeNumPanel"] = {MIN = 1, MAX = 1 * math.pow(10, 6), DEF = pet:queryInt("max_life") - pet:queryInt("gm_attribs/max_life")},
            ["ManaNumPanel"] = {MIN = 1, MAX = 1 * math.pow(10, 6), DEF = pet:queryInt("max_mana") - pet:queryInt("gm_attribs/max_mana")},
            ["Phy_powerNumPanel"] = {MIN = 1, MAX = 1 * math.pow(10, 6), DEF = pet:queryInt("phy_power") - pet:queryInt("gm_attribs/phy_power")},
            ["Mag_powerNumPanel"] = {MIN = 1, MAX = 1 * math.pow(10, 6), DEF = pet:queryInt("mag_power") - pet:queryInt("gm_attribs/mag_power")},
            ["DefenceNumPanel"] = {MIN = 1, MAX = 1 * math.pow(10, 6), DEF = pet:queryInt("def") - pet:queryInt("gm_attribs/def")},
            ["SpeedNumPanel"] = {MIN = 1, MAX = 3 * math.pow(10, 4), DEF = pet:queryInt("speed") - pet:queryInt("gm_attribs/speed")},
            
            ["LifeEclosionNumPanel"] = {MIN = 0, MAX = eclosionDef, DEF = eclosionDef, notNeedChanegColor = true},
            ["ManaEclosionNumPanel"] = {MIN = 0, MAX = eclosionDef, DEF = eclosionDef, notNeedChanegColor = true},
            ["Phy_powerEclosionNumPanel"] = {MIN = 0, MAX = eclosionDef, DEF = eclosionDef, notNeedChanegColor = true},
            ["Mag_powerEclosionNumPanel"] = {MIN = 0, MAX = eclosionDef, DEF = eclosionDef, notNeedChanegColor = true},
            ["DefenceEclosionNumPanel"] = {MIN = 0, MAX = eclosionDef, DEF = eclosionDef, notNeedChanegColor = true},
            ["SpeedEclosionNumPanel"] = {MIN = 0, MAX = eclosionDef, DEF = eclosionDef, notNeedChanegColor = true},       
            ["StrengthenNumPanel"] = {MIN = 0, MAX = strMax, DEF = strLevel, notNeedChanegColor = true},  
            ["IntimateNumPanel"] = {MIN = 0, MAX = 9 * math.pow(10, 6), DEF = pet:queryInt("origin_intimacy"), notNeedChanegColor = true},          
        }
    else
        self.VALUE_RANGE = {        
            ["LevelNumPanel"] = {MIN = 1, MAX = Const.PLAYER_MAX_LEVEL, DEF = math.min(Me:queryInt("level") + 10, Const.PLAYER_MAX_LEVEL), notNeedChanegColor = true},
            ["SkillNumPanel"] = {MIN = 0, MAX = 160, DEF = "", notNeedChanegColor = true},
            ["MartialNumPanel"] = {MIN = 0, MAX = 3.65 * math.pow(10, 8), DEF = Me:queryInt("tao") * 2, notNeedChanegColor = true},
            ["LifeNumPanel"] = {MIN = 0, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("max_life") - Me:queryInt("gm_attribs/max_life")},
            ["ManaNumPanel"] = {MIN = 0, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("max_mana") - Me:queryInt("gm_attribs/max_mana")},
            ["Phy_powerNumPanel"] = {MIN = 0, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("phy_power") - Me:queryInt("gm_attribs/phy_power")},
            ["Mag_powerNumPanel"] = {MIN = 0, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("mag_power") - Me:queryInt("gm_attribs/mag_power")},
            ["DefenceNumPanel"] = {MIN = 0, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("def") - Me:queryInt("gm_attribs/def")},
            ["SpeedNumPanel"] = {MIN = 0, MAX = 3 * math.pow(10, 4), DEF = Me:queryInt("speed") - Me:queryInt("gm_attribs/speed")},

            ["LifeEclosionNumPanel"] = {MIN = 0, MAX = 5, DEF = Me:queryInt("max_life") - Me:queryInt("gm_attribs/max_life"), notNeedChanegColor = true},
            ["ManaEclosionNumPanel"] = {MIN = 0, MAX = 5, DEF = Me:queryInt("max_mana") - Me:queryInt("gm_attribs/max_mana"), notNeedChanegColor = true},
            ["Phy_powerEclosionNumPanel"] = {MIN = 0, MAX = 5, DEF = Me:queryInt("phy_power") - Me:queryInt("gm_attribs/phy_power"), notNeedChanegColor = true},
            ["Mag_powerEclosionNumPanel"] = {MIN = 0, MAX = 5, DEF = Me:queryInt("mag_power") - Me:queryInt("gm_attribs/mag_power"), notNeedChanegColor = true},
            ["DefenceEclosionNumPanel"] = {MIN = 0, MAX = 5, DEF = Me:queryInt("def") - Me:queryInt("gm_attribs/def"), notNeedChanegColor = true},
            ["SpeedEclosionNumPanel"] = {MIN = 0, MAX = 5, DEF = Me:queryInt("speed") - Me:queryInt("gm_attribs/speed"), notNeedChanegColor = true},
            ["IntimateNumPanel"] = {MIN = 0, MAX = 9 * math.pow(10, 6), DEF = 0, notNeedChanegColor = true},
            ["StrengthenNumPanel"] = {MIN = 0, MAX = 12, DEF = 0, notNeedChanegColor = true},
        }
    end
end

function GMPetCreatDlg:MSG_UPDATE_PETS(data)
    if self.selectPet and self.selectPet:getId() == data[1].id then
        local pet = PetMgr:getPetById(data[1].id)
        self.selectPet = pet
        self:updataValueConst(pet)
        self:setDataByPet(pet)
    end
end

function GMPetCreatDlg:MSG_AMDIN_NEW_PET(data)
    HAVED_PET_NAME = self:getPetCfg("haved")
    local pet = PetMgr:getPetById(data.petId)
    self.selectPet = pet
    self:updataValueConst(pet)
    self:setDataByPet(pet)
    self:setDisplayPanel("PetPropertiesPanel")
end

return GMPetCreatDlg
