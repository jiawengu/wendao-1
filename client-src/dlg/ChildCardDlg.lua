-- ChildCardDlg.lua
-- Created by lixh May/13/2019
-- 娃娃悬浮框

local ChildCardDlg = Singleton("ChildCardDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local DISPLAY_CHECKBOX = {
    "BasicCheckBox",
    "EffectCheckBox",
}

local CHECKBOX_PANEL = {
    ["BasicCheckBox"] = "PetBasicInfoPanel",
    ["EffectCheckBox"] = "PetAttribInfoPanel",
}

function ChildCardDlg:init()
    -- 初始化单选框
    self.radioCheckBox = RadioGroup.new()
    self.radioCheckBox:setItems(self, DISPLAY_CHECKBOX, self.onCheckBox)
    self.radioCheckBox:setSetlctByName(DISPLAY_CHECKBOX[1])
end

-- 设置界面数据
function ChildCardDlg:setData(data)
    self.dlgData = data
    self:setUpAreaInfo(data)
    self:setDownAreaInfo(data)
end

-- 设置上半部分信息
function ChildCardDlg:setUpAreaInfo(data)
    -- 头像
    HomeChildMgr:setPortrait(nil, self:getControl("ChildShapePanel"), self, cc.p(2, -20), data)

    -- 飞升Logo
    HomeChildMgr:setChildLogo(self, data.is_upgrade > 0, self.root)

    -- 名称
    if data.stage == HomeChildMgr.CHILD_TYPE.FETUS then
        self:setLabelText("PetNameLabel", CHS[7120227])
    elseif data.stage == HomeChildMgr.CHILD_TYPE.STONE then
        self:setLabelText("PetNameLabel", CHS[7120228])
    else
        self:setLabelText("PetNameLabel", string.format(CHS[7120215], data.name))
    end

    -- 阶段
    self:setLabelText("PetLevelLabel", HomeChildMgr:getStageChild(data))

    -- 家长与亲密度
    self:setCtrlVisible("PetMartialLabel", false, "BasicInfoPanel")
    self:setCtrlVisible("OwnerLabel", false, "BasicInfoPanel")
    self:setCtrlVisible("ExChangeLabel", false, "BasicInfoPanel")
    self:setCtrlVisible("ExChangeLabel_2", false, "BasicInfoPanel")
    if data.owner_count == 1 then
        self:setCtrlVisible("PetMartialLabel", true, "BasicInfoPanel")
        self:setCtrlVisible("OwnerLabel", true, "BasicInfoPanel")
        self:setLabelText("PetMartialLabel", string.format(CHS[7120217], data.owner_list[1].name), "BasicInfoPanel")
        self:setLabelText("OwnerLabel", string.format(CHS[7120216], data.owner_list[1].intimacy), "BasicInfoPanel")
    elseif data.owner_count == 2 then
        self:setCtrlVisible("PetMartialLabel", true, "BasicInfoPanel")
        self:setCtrlVisible("OwnerLabel", true, "BasicInfoPanel")
        self:setCtrlVisible("ExChangeLabel", true, "BasicInfoPanel")
        self:setCtrlVisible("ExChangeLabel_2", true, "BasicInfoPanel")
        self:setLabelText("PetMartialLabel", string.format(CHS[7120217], data.owner_list[1].name), "BasicInfoPanel")
        self:setLabelText("OwnerLabel", string.format(CHS[7120216], data.owner_list[1].intimacy), "BasicInfoPanel")
        self:setLabelText("ExChangeLabel", string.format(CHS[7120217], data.owner_list[2].name), "BasicInfoPanel")
        self:setLabelText("ExChangeLabel_2", string.format(CHS[7120216], data.owner_list[2].intimacy), "BasicInfoPanel")
    end
end

-- 设置下半部分信息
function ChildCardDlg:setDownAreaInfo(data)
    self:initScrollViewSize(data)

    -- 基本信息
    self:setBasicInfo(data)

    -- 属性资质
    self:setPropInfo(data)
end

function ChildCardDlg:setBasicInfo(data)
    local stagePanel0 = self:getControl("Stage0Panel")
    local stagePanel1 = self:getControl("Stage1Panel")
    local stagePanel2 = self:getControl("Stage2Panel")
    local stagePanel3 = self:getControl("Stage3Panel")

    if data.stage == HomeChildMgr.CHILD_TYPE.BABY then
        -- 成长度
        local chengzhangPanel = self:getControl("ChengzhangPanel", nil, stagePanel2)
        self:setLabelText("ValueLabel", string.format("%d/%d", data.mature, 1000), chengzhangPanel)

        -- 饱食度
        local baoshiPanel = self:getControl("BaoshiPanel", nil, stagePanel2)
        self:setLabelText("ValueLabel", string.format("%d/%d", data.feed, 100), baoshiPanel)

        -- 清洁度
        local qingjiePanel = self:getControl("QingjiePanel", nil, stagePanel2)
        self:setLabelText("ValueLabel", string.format("%d/%d", data.clean, 100), qingjiePanel)

        -- 心情度
        local xinqingPanel = self:getControl("XinqingPanel", nil, stagePanel2)
        self:setLabelText("ValueLabel", string.format("%d/%d", data.happy, 100), xinqingPanel)

        -- 健康度
        local jiankangPanel = self:getControl("JiankangPanel", nil, stagePanel2)
        self:setLabelText("ValueLabel", string.format("%d/%d", data.health, 100), jiankangPanel)

        -- 疲劳度
        local pilaoPanel = self:getControl("PilaoPanel", nil, stagePanel2)
        self:setLabelText("ValueLabel", string.format("%d/%d", data.fatigue, 100), pilaoPanel)

        -- 悟性
        local wuxingPanel = self:getControl("WuxingPanel", nil, stagePanel2)
        self:setLabelText("ValueLabel", HomeChildMgr:getWuXinChs(data.wuxing), wuxingPanel)

        -- 性格
        local xinggePanel = self:getControl("XinggePanel", nil, stagePanel2)
        self:setLabelText("ValueLabel", HomeChildMgr:getXinggeChs(data.xingge), xinggePanel)
    elseif data.stage == HomeChildMgr.CHILD_TYPE.KID then
        -- 体力
        local tiliPanel = self:getControl("TiliPanel", nil, stagePanel3)
        self:setLabelText("ValueLabel", string.format("%d/%d", data.vitality, 100), tiliPanel)

        -- 门派
        local menpaiPanel = self:getControl("MenpaiPanel", nil, stagePanel3)
        self:setLabelText("ValueLabel", gf:getPolar(data.polar), menpaiPanel)

        -- 飞升
        local feishengPanel = self:getControl("FeishengPanel", nil, stagePanel3)
        self:setLabelText("ValueLabel", data.is_upgrade == 1 and CHS[7120218] or CHS[7120219], feishengPanel)

        -- 悟性
        local wuxingPanel = self:getControl("WuxingPanel", nil, stagePanel3)
        self:setLabelText("ValueLabel", HomeChildMgr:getWuXinChs(data.wuxing), wuxingPanel)

        -- 性格
        local xinggePanel = self:getControl("XinggePanel", nil, stagePanel3)
        self:setLabelText("ValueLabel", HomeChildMgr:getXinggeChs(data.xingge), xinggePanel)
    elseif data.stage == HomeChildMgr.CHILD_TYPE.STONE then
        -- 成熟度
        local chengshuPanel = self:getControl("ChengshuPanel", nil, stagePanel0)
        self:setLabelText("ValueLabel", string.format("%d/%d", data.maturity, 200), chengshuPanel)
    else
        -- 成熟度
        local chengshuPanel = self:getControl("ChengshuPanel", nil, stagePanel1)
        self:setLabelText("ValueLabel", string.format("%d/%d", data.maturity, 100), chengshuPanel)

        -- 健康度
        local jiankangPanel = self:getControl("JiankangPanel", nil, stagePanel1)
        self:setLabelText("ValueLabel", string.format("%d/%d", data.health, 100), jiankangPanel)
    end

    -- 成长金库
    local moneyPanel = self:getControl("MoneyPanel")
    local moneyDesc, _ = gf:getMoneyDesc(data.money, true)
    self:setLabelText("ValueLabel", moneyDesc, moneyPanel)

    -- 小书包
    local bagPanel = self:getControl("BagPanel")
    self:setLabelText("TypeLabel_0", string.format(CHS[7120220], data.daofa), bagPanel)
    self:setLabelText("TypeLabel_1",string.format(CHS[7120221],  data.xinfa), bagPanel)

    -- 玩具
    local toysPanel = self:getControl("ToyPanel")
    if data.toy_count <= 0 then
        self:setLabelText("TypeLabel_0", CHS[7120223], toysPanel)
        self:setCtrlVisible("TypeLabel_1", false, toysPanel)
        self:setCtrlVisible("TypeLabel_2", false, toysPanel)
    else
        for i = 1, 3 do
            if data.toy_list[i] then
                self:setCtrlVisible("TypeLabel_" .. (i - 1), true, toysPanel)
                self:setLabelText("TypeLabel_" .. (i - 1), string.format(CHS[7120222],
                    data.toy_list[i].name, data.toy_list[i].naijiu, data.toy_list[i].naijiu_max), toysPanel)
            else
                -- 玩具不够3个的隐藏
                self:setCtrlVisible("TypeLabel_" .. (i - 1), false, toysPanel)
            end
        end
    end
end

-- 属性部分
function ChildCardDlg:setPropInfo(data)
    self:setCtrlVisible("KidValuePanel", false)
    self:setCtrlVisible("BabyValuePanel", false)
    self:setCtrlVisible("OtherLabel", false)
    if data.stage == HomeChildMgr.CHILD_TYPE.BABY then
        self:setCtrlVisible("BabyValuePanel", true)
    elseif data.stage == HomeChildMgr.CHILD_TYPE.KID then
        self:setCtrlVisible("KidValuePanel", true)

        local root = self:getControl("KidValuePanel")
        if data.status == HomeChildMgr.KID_STAGE.XIULIAN then
            self:setLabelText("Label_351", CHS[7120224], root)
        else
            self:setLabelText("Label_351", CHS[7120225], root)
        end
    else
        self:setCtrlVisible("OtherLabel", true)
    end

    if data.stage == HomeChildMgr.CHILD_TYPE.KID  or data.stage == HomeChildMgr.CHILD_TYPE.BABY then
        local root = self:getControl("BabyValuePanel")
        if data.stage == HomeChildMgr.CHILD_TYPE.KID then
            root = self:getControl("KidValuePanel")
        end

        local lifePanel = self:getControl("LifeEffectPanel", nil, root)
        local manaPanel = self:getControl("ManaEffectPanel", nil, root)
        local speedPanel = self:getControl("SpeedEffectPanel", nil, root)
        local phyPanel = self:getControl("PhyEffectPanel", nil, root)
        local magPanel = self:getControl("MagEffectPanel", nil, root)
        local totalPanel = self:getControl("TotalEffectPanel", nil, root)
        local totalValue = data.life_shape + data.mana_shape
            + data.speed_shape + data.phy_shape + data.mag_shape
        self:setLabelText("ValueLabel", totalValue, totalPanel)
        self:setCtrlVisible("StageLabel", false, totalPanel)

        if data.stage == HomeChildMgr.CHILD_TYPE.KID then
            self:setLabelText("ValueLabel", data.life_shape, lifePanel)
            self:setLabelText("ValueLabel", data.mana_shape, manaPanel)
            self:setLabelText("ValueLabel", data.speed_shape, speedPanel)
            self:setLabelText("ValueLabel", data.phy_shape, phyPanel)
            self:setLabelText("ValueLabel", data.mag_shape, magPanel)
            self:setLabelText("StageLabel", string.format(CHS[7120226], data.life_shape_percent), lifePanel)
            self:setLabelText("StageLabel", string.format(CHS[7120226], data.mana_shape_percent), manaPanel)
            self:setLabelText("StageLabel", string.format(CHS[7120226], data.speed_shape_percent), speedPanel)
            self:setLabelText("StageLabel", string.format(CHS[7120226], data.phy_shape_percent), phyPanel)
            self:setLabelText("StageLabel", string.format(CHS[7120226], data.mag_shape_percent), magPanel)
        else
            self:setLabelText("ValueLabel", data.life_shape, lifePanel)
            self:setLabelText("ValueLabel", data.mana_shape, manaPanel)
            self:setLabelText("ValueLabel", data.speed_shape, speedPanel)
            self:setLabelText("ValueLabel", data.phy_shape, phyPanel)
            self:setLabelText("ValueLabel", data.mag_shape, magPanel)
        end
    end
end

-- 初始化scrollView大小
function ChildCardDlg:initScrollViewSize(data)
    local scollCtrl = self:getControl("ScrollView", nil, "PetBasicInfoPanel")
    local container = self:getControl("InfoPanel", nil, scollCtrl)

    local innerSize = container:getContentSize()
    innerSize.width = self:getControl("MoneyPanel", nil, container):getContentSize().height
        + self:getControl("BagPanel", nil, container):getContentSize().height
        + self:getControl("ToyPanel", nil, container):getContentSize().height
        + self:getControl("StageAttriPanel", nil, container):getContentSize().height

    self:setCtrlVisible("Stage0Panel", false, container)
    self:setCtrlVisible("Stage1Panel", false, container)
    self:setCtrlVisible("Stage2Panel", false, container)
    self:setCtrlVisible("Stage3Panel", false, container)
    if data.stage == HomeChildMgr.CHILD_TYPE.BABY then
        self:setCtrlVisible("Stage2Panel", true, container)
        self:getControl("StageAttriPanel"):setContentSize(self:getControl("Stage2Panel"):getContentSize())
        innerSize.width = innerSize.width + 55
    elseif data.stage == HomeChildMgr.CHILD_TYPE.KID then
        self:setCtrlVisible("Stage3Panel", true, container)
        self:getControl("StageAttriPanel"):setContentSize(self:getControl("Stage3Panel"):getContentSize())
        innerSize.width = innerSize.width + 30
    elseif data.stage == HomeChildMgr.CHILD_TYPE.STONE then
        self:setCtrlVisible("Stage0Panel", true, container)
        self:getControl("StageAttriPanel"):setContentSize(self:getControl("Stage0Panel"):getContentSize())
    else
        self:setCtrlVisible("Stage1Panel", true, container)
        self:getControl("StageAttriPanel"):setContentSize(self:getControl("Stage1Panel"):getContentSize())
        innerSize.width = innerSize.width - 15
    end

    container:requestDoLayout()
    scollCtrl:setInnerContainerSize(innerSize)
    self:addMagicAndSee("MagicPanel", ResMgr:getMagicDownIcon(), scollCtrl:getParent())
    scollCtrl:addEventListener(function(sender, eventType) self:updateDownArrow(sender, eventType) end)
    container:setPositionY(0)
    self:bindListener("MagicPanel", self.onDownTipsPanel, scollCtrl:getParent())
end

-- 点击向下按钮
function ChildCardDlg:onDownTipsPanel(sender, eventType)
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
function ChildCardDlg:updateDownArrow(sender, eventType)
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

function ChildCardDlg:addMagicAndSee(panelName, icon, root)
    if self.dlgData and self.dlgData.stage == HomeChildMgr.CHILD_TYPE.KID 
        and self.dlgData.toy_count >= 3
        and root:getName() == "PetBasicInfoPanel" then
        local ctrl = self:getControl(panelName, nil, root)
        self:addMagic(ctrl, icon)
        ctrl:setVisible(true)
    end
end

function ChildCardDlg:removeMagicAndNoSee(panelName, icon, root)
    local ctrl = self:getControl(panelName, nil, root)
    self:removeMagic(ctrl, icon)
    ctrl:setVisible(false)
end

function ChildCardDlg:onCheckBox(sender, eventType)
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

function ChildCardDlg:cleanup()
    self.dlgData = nil
end

return ChildCardDlg
