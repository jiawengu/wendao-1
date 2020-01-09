-- PetCardDlg.lua
-- Created by songcw Jan/13/2015
-- 宠物悬浮框

local PetCardDlg = Singleton("PetCardDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local DISPLAY_CHECKBOX = {
    "BasicCheckBox",
    "EffectCheckBox",
    "SkillCheckBox",
}

local CHECKBOX_PANEL = {
    ["BasicCheckBox"] = "PetBasicInfoPanel",
    ["EffectCheckBox"] = "PetAttribInfoPanel",
    ["SkillCheckBox"] = "PetSkillInfoPanel",
}

function PetCardDlg:init()
    self:bindListener("PetCardDlg", self.onCloseButton)
    --
    -- 初始化单选框
    self.radioCheckBox = RadioGroup.new()
    self.radioCheckBox:setItems(self, DISPLAY_CHECKBOX, self.onCheckBox)
    self.radioCheckBox:setSetlctByName(DISPLAY_CHECKBOX[1])

    -- 初始化3个ScrollView
    for _, panelName in pairs(CHECKBOX_PANEL) do
        local scollCtrl = self:getControl("ScrollView", nil, panelName)
        local container = self:getControl("InfoPanel", nil, scollCtrl)

        scollCtrl:setInnerContainerSize(container:getContentSize())
        self:addMagicAndSee("MagicPanel", ResMgr:getMagicDownIcon(), scollCtrl:getParent())
        scollCtrl:addEventListener(function(sender, eventType) self:updateDownArrow(sender, eventType) end)

        self:bindListener("MagicPanel", self.onDownTipsPanel, scollCtrl:getParent())
    end
end

-- 点击向下按钮
function PetCardDlg:onDownTipsPanel(sender, eventType)
    local scroll = self:getControl("ScrollView", nil, sender:getParent())
    local listInnerContent = scroll:getInnerContainer()
    local innerSize = listInnerContent:getContentSize()
    local listViewSize = scroll:getContentSize()

    -- 计算滚动的百分比
    local totalHeight = innerSize.height - listViewSize.height
    local innerPosY = listInnerContent:getPositionY()
    if innerPosY < -230 then
        listInnerContent:setPositionY(innerPosY + 230)
    else
        self:removeMagic(sender, ResMgr:getMagicDownIcon())
        sender:setVisible(false)
        listInnerContent:setPositionY(0)
    end
end

-- 更新向下提示
function PetCardDlg:updateDownArrow(sender, eventType)
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

        if persent < 90 then
            self:addMagicAndSee("MagicPanel", ResMgr:getMagicDownIcon(), listViewCtrl:getParent())
        else
            self:removeMagicAndNoSee("MagicPanel", ResMgr:getMagicDownIcon(), listViewCtrl:getParent())
        end
    end
end

function PetCardDlg:addMagicAndSee(panelName, icon, root)
    local ctrl = self:getControl(panelName, nil, root)
    self:addMagic(ctrl, icon)
    ctrl:setVisible(true)
end

function PetCardDlg:removeMagicAndNoSee(panelName, icon, root)
    local ctrl = self:getControl(panelName, nil, root)
    self:removeMagic(ctrl, icon)
    ctrl:setVisible(false)
end

function PetCardDlg:onCheckBox(sender, eventType)
    for _, panelName in pairs(CHECKBOX_PANEL) do
        self:setCtrlVisible(panelName, false)
        self:setCtrlVisible("ChosenPanel", false, _)
        self:setCtrlVisible("UnChosenPanel", true, _)

        local scollCtrl = self:getControl("ScrollView", nil, panelName)
        local y = scollCtrl:getContentSize().height - scollCtrl:getInnerContainer():getContentSize().height
        scollCtrl:getInnerContainer():setPositionY(y)

        self:addMagicAndSee("MagicPanel", ResMgr:getMagicDownIcon(), scollCtrl:getParent())
    end

    self:setCtrlVisible("ChosenPanel", true, sender)
    self:setCtrlVisible("UnChosenPanel", false, sender)
    self:setCtrlVisible(CHECKBOX_PANEL[sender:getName()], true)
end

-- isMePet 是否为 me 的宠物，如果是则从 SkillMgr 中获取对应的技能信息
function PetCardDlg:setPetInfo(pet, isMePet)

    self.isMePet = isMePet

    local icon = 0              -- 形象
    local polar = 0             -- 相性
    local life = 0              -- 气血
    local maxLife = 0          -- 最大气血
    local mana = 0              -- 法力
    local maxMana = 0          -- 最大法力
    local phyPower = 0         -- 物伤
    local magPower = 0         -- 法伤
    local speed = 0             -- 速度
    local def = 0               -- 防御
    local loyalty = 0           -- 忠诚
    local longevity = 0         -- 寿命
    local intimacy = 0          -- 亲密
    local martial = 0           -- 武学
    local con = 0               -- 体质
    local wiz = 0               -- 灵力
    local str = 0               -- 力量
    local dex = 0               -- 敏捷
    local attributePoint = 0    -- 剩余属性点
    local level = 0             -- 等级
    local lifeShape = 0        -- 气血成长
    local manaShape = 0        -- 法力成长
    local speedShape = 0       -- 速度成长
    local phyShape = 0         -- 物攻成长
    local magShape = 0         -- 法功成长
    local phyShapeAdd = 0     -- 物攻强化增加成长
    local magShapeAdd = 0     -- 法功强化增加成长
    local totalAdd = 0         -- 增加成长和
    local totalShape = 0       -- 全部成长
    local lifeMax = 0          -- 气血成长max
    local manaMax = 0          -- 法力成长max
    local speedMax = 0         -- 速度成长max
    local phyMax = 0           -- 物攻成长max.
    local magMax = 0           -- 法功成长max
    local rawName = ""

    -- 抗性
    local resist_poison = 0
    local resist_frozen = 0
    local resist_sleep = 0
    local resist_forgotten = 0
    local resist_confusion = 0
    local resist_metal = 0
    local resist_wood = 0
    local resist_water = 0
    local resist_fire = 0
    local resist_earth = 0
    local resist_point = 0


    local phyStrongTime = 0   -- 物攻强化次数
    local magStrongTime = 0   -- 法功强化次数

    local phyStrongRate = 0   -- 物攻强化完成度
    local magStrongRate = 0   -- 法功强化完成度

    if nil ~= pet then
        icon = self:getDlgIcon(pet)
        polar = pet:queryBasicInt("polar")
        life = pet:queryInt("life")
        mana = pet:queryInt("mana")
        loyalty = pet:queryInt("loyalty")
        longevity = pet:queryInt("longevity")
        level = pet:queryBasic("level")
        -- 成长相关
        magShape = pet:queryInt("pet_mag_shape")
        magShapeAdd = pet:queryInt("mag_rebuild_add")
        phyShapeAdd = pet:queryInt("phy_rebuild_add")
        totalAdd = magShapeAdd + phyShapeAdd
        rawName = pet:queryBasic("raw_name")
        lifeMax = PetMgr:getPetStdValue(rawName, "life") + 10
        manaMax = PetMgr:getPetStdValue(rawName, "mana") + 10
        speedMax = PetMgr:getPetStdValue(rawName, "speed") + 5
        phyMax = PetMgr:getPetStdValue(rawName, "phy_attack") + 10
        magMax = PetMgr:getPetStdValue(rawName, "mag_attack") + 10
    end

    -- 设置宠物形象
    self:setPortrait("PetShapePanel", icon, 0, self.root, true)

    -- 设置宠物相性
    self:setLabelText("PolarLabel", gf:getPolar(polar))

    -- 设置宠物名称
    self:setLabelText("PetNameLabel", CHS[4200226] .. pet:queryBasic("name"))

    -- 等级
    self:setLabelText("PetLevelLabel", string.format(CHS[4200227], pet:queryInt("level")))

    local strLimitedTime = gf:converToLimitedTimeDay(pet:query("gift"))

    if not strLimitedTime or strLimitedTime == "" then
        -- 隐藏
        self:setLabelText("ExChangeLabel_1", CHS[4200228], nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("ExChangeLabel_2", "")
    elseif PetMgr:isTimeLimitedPet(pet) then
        -- 限时宠物不显示限制交易内容，而显示剩余时间
        local timeLimitStr = PetMgr:convertLimitTimeToStr(pet:queryBasicInt("deadline"))
        self:setLabelText("ExChangeLabel_2", timeLimitStr, nil, COLOR3.RED)
        self:setLabelText("ExChangeLabel_1", CHS[7000083], nil, COLOR3.RED)
    else
        self:setLabelText("ExChangeLabel_1", strLimitedTime, nil, COLOR3.RED)
        self:setLabelText("ExChangeLabel_2", "")
    end


    -- 设置携带等级
    local level = pet:queryInt("req_level")
    if level == 0 then
        level = PetMgr:getPetLevelReq(pet:queryBasic("raw_name"))
    end

    -- 宠物主人
    local ownerName = gf:getRealName(pet:queryBasic("owner_name"))
    if ownerName == "" then
         ownerName = CHS[34048]
    end

    self:setLabelText("OwnerLabel", CHS[4200229] .. ownerName)

    self:setCtrlValue("CatchLevelPanel", "ValueLabel", level)

    -- 基本信息
    PetMgr:setBasicInfoForCard(pet, self)

    -- 宠物资质
    PetMgr:setAttribInfoForCard(pet, self)

    -- 宠物技能
    PetMgr:setSkillInfoForCard(pet, self)

    -- 相性、贵重、点化
    self:setPetLogoPanel(pet)

    -- 设置类型：野生、宝宝
    self:setImage("SuffixImage", ResMgr:getPetRankImagePath(pet))
end

function PetCardDlg:getDlgIcon(pet)




    if DlgMgr:getDlgByName("GiveDlg") then
    elseif DlgMgr:getDlgByName("RankingListDlg") then
        local myPet = PetMgr:getPetById(id)
    else
        if pet:queryBasicInt("fasion_id") ~= 0 and pet:queryBasicInt("fasion_visible") ~= 0 then
            return pet:queryBasicInt("fasion_id")
        end
    end

    if pet:queryBasicInt("dye_icon") ~= 0 then

        return pet:queryBasicInt("dye_icon")
    end

    return pet:queryBasicInt("icon")
end

-- 坐骑属性
function PetCardDlg:setHorsePet(pet)
    local mount_type = pet:queryBasicInt("mount_type")

    if MOUNT_TYPE.MOUNT_TYPE_YULING == mount_type then -- -- 御灵
        local ride_attrib = pet:queryBasic("group_" .. GROUP_NO.FIELDS_MOUNT_ATTRIB)
        if not ride_attrib or  type(ride_attrib) ~= 'table' then return end
        -- 主人攻击
        local phy_power = ride_attrib.phy_power
        self:setLabelText("ValueLabel", "+" .. phy_power, "AddPhyPowerPanel")

        -- 主人法攻
        local mag_power = ride_attrib.mag_power
        self:setLabelText("ValueLabel", "+" .. mag_power, "AddMagPowerPanel")

        -- 主人防御
        local def = ride_attrib.def
        self:setLabelText("ValueLabel", "+" .. def, "AddDefencePowerPanel")

        -- 主任所有属性
        local all_attribute = ride_attrib.all_attrib
        self:setLabelText("ValueLabel", "+" .. all_attribute, "AddAllPowerPanel")

        -- 移动速度
        -- 速度的级数和速度百分比是5倍关系
        local speed = math.floor(pet:queryInt("mount_attrib/move_speed") / 5)
        self:setLabelText("ValueLabel", string.format(CHS[3003355], speed), "SpeefPanel")
    else
        self:setLabelText("ValueLabel", "+" .. 0, "AddPhyPowerPanel")
        self:setLabelText("ValueLabel", "+" .. 0, "AddMagPowerPanel")
        self:setLabelText("ValueLabel", "+" .. 0, "AddDefencePowerPanel")
        self:setLabelText("ValueLabel", "+" .. 0, "AddAllPowerPanel")
        self:setLabelText("ValueLabel", string.format(CHS[3003355], 0), "SpeefPanel")
    end
end

-- 设置相性，贵重，点化标记
function PetCardDlg:setPetLogoPanel(pet)
    PetMgr:setPetLogo(self, pet)
end

function PetCardDlg:setCtrlValue(panelName, LabelName, value)
    local panel = self:getControl(panelName, Const.UIPanel)
    self:setLabelText(LabelName, value, panel)
end


-- 设置技能名片
function PetCardDlg:setSkillCard(pet, skillName, sender, dlgType)
    local skillCard = DlgMgr:openDlg("SkillFloatingFrameDlg")

    if skillCard then
        local rect = sender:getBoundingBox()
        local pt = sender:convertToWorldSpace(cc.p(0, 0))
        rect.x = pt.x
        rect.y = pt.y
        rect.width = rect.width * Const.UI_SCALE
        rect.height = rect.height * Const.UI_SCALE
        skillCard:setInfo(skillName, pet:queryBasicInt("id"), false, rect, dlgType, pet)
        skillCard:setGodbookPower(skillName, pet)
    end
end

return PetCardDlg
