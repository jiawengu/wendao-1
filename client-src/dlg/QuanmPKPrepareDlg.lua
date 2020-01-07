-- QuanmPKPrepareDlg.lua
-- Created by songcw Mar/15/2017
-- 全名PK物质

local QuanmPKPrepareDlg = Singleton("QuanmPKPrepareDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local EQUIP_CFG = require (ResMgr:getCfgPath("QuanmmPKCfg.lua"))

-- 变异宠物列表信息
local elitePetList = require(ResMgr:getCfgPath('VariationPetList.lua'))
local EpicPetList = require (ResMgr:getCfgPath("EpicPetList.lua"))

-- 所有天书
local godBooks = require(ResMgr:getCfgPath("GodBooks.lua"))

-- 左侧菜单列表
local LEFT_MENU = {
    CHS[4100499], --  角     色
    CHS[4100500], --  宠     物
    CHS[4100501], --  妖     石
    CHS[4100502], --  天     书
    CHS[4100503], --  药     品
    CHS[4100504], --  变     身
    CHS[4100505], --  回     收
    CHS[4100506], --  一键检查
}

-- 菜单对应显示的panel
local MENU_DISPLAY_PANEL = {
    [CHS[4100499]] = "PrepareEquipPanel",   -- 角     色
    [CHS[4100500]] = "PreparePetPanel",     -- 宠     物
    [CHS[4100501]] = "PrepareItemPanel",    -- 妖     石
    [CHS[4100502]] = "PrepareItemPanel",    --  天     书
    [CHS[4100503]] = "PrepareItemPanel",    --  药     品
    [CHS[4100505]] = "ReclaimPanel",        --  变     身
    [CHS[4100504]] = "PrepareItemPanel",    --  回     收
    [CHS[4100506]] = "CheckPanel",          --  一键检查
}

-- 角色菜单下，装备格子对应的panel
local EQUIP_DISPLAY_PANEL = {
    ["HelmetPanel"] = "EquipAttribPanel",
    ["WeaponPanel"] = "EquipAttribPanel",
    ["BaldricPanel"] = "JewelryAttribPanel",
    ["WristPanel_1"] = "JewelryAttribPanel",
    ["ArtifactPanel"] = "ArtifactAttribPanel",
    ["FlyArtifactPanel"] = "",
    ["WristPanel_2"] = "JewelryAttribPanel",
    ["NecklacePanel"] = "JewelryAttribPanel",
    ["BootPanel"] = "EquipAttribPanel",
    ["ArmorPanel"] = "EquipAttribPanel",
}

-- 装备格子对应的装备类型
local EQUIP_PANEL_EQUIPTYPE = {
    ["HelmetPanel"] = EQUIP_TYPE.HELMET,
    ["WeaponPanel"] = EQUIP_TYPE.WEAPON,
    ["BaldricPanel"] = EQUIP_TYPE.BALDRIC,
    ["WristPanel_1"] = EQUIP_TYPE.WRIST,
    ["ArtifactPanel"] = EQUIP_TYPE.ARTIFACT,
    ["FlyArtifactPanel"] = "",
    ["WristPanel_2"] = EQUIP_TYPE.WRIST,
    ["NecklacePanel"] = EQUIP_TYPE.NECKLACE,
    ["BootPanel"] = EQUIP_TYPE.BOOT,
    ["ArmorPanel"] = EQUIP_TYPE.ARMOR,
}

local EQUIP_INFO = EQUIP_CFG[CHS[5000285]]

local RECOMMENDED_INFO = EQUIP_CFG[CHS[4100508]]

local RECLAIM_CHECK = {
    "EquipCheckBox", "PetCheckBox", "ItemCheckBox", "ChangeCardCheckBox"
}

local RECOMMEND_CHECK = {
    "PhyTypeCheckBox", "MagTypeCheckBox", "SpeedTypeCheckBox", "DefTypeCheckBox", "ObstacleTypeCheckBox"
}

local CHECK_PANEL_NAME = {
    [1] = "EquipPanel",
    [2] = "PetPanel",
    [3] = "StonePanel",
    [4] = "GodBookPanel",
    [5] = "DrugPanel",
    [6] = "ChangeCardPanel",
}

QuanmPKPrepareDlg.makeEquip = {}

local DEFAULT_EQUIP_REBUILD_LEVEL = 6
local DEFAULT_EQUIP_PROP_RATE = 0.8
local DEFAULT_JEWELRY_PROP_RATE = 0.4

function QuanmPKPrepareDlg:init()
    if DistMgr:isInQcldServer() then
        DEFAULT_EQUIP_REBUILD_LEVEL = 8
        DEFAULT_EQUIP_PROP_RATE = 1.0
        DEFAULT_JEWELRY_PROP_RATE = 0.8
    end

    -- 装备panel中，推荐类型按钮的绑定
    self:bindEquipButton()

    self:initCloneAndBind()

    self.curMenu = nil
    self.selectEquipType = nil
    self.itemCount = 1
    self.addElite = nil
    self.selectReadyPet = nil
    self.selectItem = nil
    self.makeEquip = {}
    self.reclaimItem = self:getReclaimItem()


    self:addMagicAndSee("MagicPanel", ResMgr:getMagicDownIcon())
    self:bindListener("MagicPanel", self.onDownTipsPanel)

    -- 初始化菜单对应隐藏相关panel
    self:initCtrlVisible()

    -- 初始化左侧菜单
    self:leftMenuInit()

    -- 初始化变异宠物列表
    self:setElitePetList()

    -- 初始化一键检测
    self:initCheckPanel()

    self:initSelect()

    self:hookMsg('MSG_PKM_GEN_PET')
    self:hookMsg('MSG_PKM_RECYCLE_DONE')
    self:hookMsg('MSG_PREVIEW_RESONANCE_ATTRIB')

    self:bindListViewByPageLoad("AttribListView", "TouchPanel", function(dlg, percent)
        if percent < 90 then
            self:addMagicAndSee("MagicPanel", ResMgr:getMagicDownIcon())
        else
            self:removeMagicAndNoSee("MagicPanel", ResMgr:getMagicDownIcon())
        end
    end, "EquipAttribPanel")
end

-- 获取当前区组的等级段
function QuanmPKPrepareDlg:getEquipLevel()
    if DistMgr:isInXMZBServer() then
        return 120
    else
        return 125
    end
end

-- 获取宠物等级
function QuanmPKPrepareDlg:getPetLevel()
    if DistMgr:isInXMZBServer() then
        return 120
    else
        return 125
    end
end

-- 获取首饰等级
function QuanmPKPrepareDlg:getShoushiLevel()
    return 120
end

-- 获取首饰属性数量上限
function QuanmPKPrepareDlg:getShoushiAtribMax()
    return 5
end

-- 获取法宝等级
function QuanmPKPrepareDlg:getArtifactLevel()
    if DistMgr:isInQcldServer() then
        return 20
    elseif DistMgr:isInXMZBServer() then
        return 13
    else
        return 14
    end
end

-- 获取妖石等级
function QuanmPKPrepareDlg:getStoneLevel()
    return 12
end

function QuanmPKPrepareDlg:addMagicAndSee(panelName, icon)
    local ctrl = self:getControl(panelName)
    self:addMagic(ctrl, icon)
    ctrl:setVisible(true)
end

function QuanmPKPrepareDlg:removeMagicAndNoSee(panelName, icon)
    local ctrl = self:getControl(panelName)
    self:removeMagic(ctrl, icon)
    ctrl:setVisible(false)
end

function QuanmPKPrepareDlg:onDownTipsPanel(sender, eventType)
    local listCtrl = self:getControl("AttribListView", nil, "EquipAttribPanel")
    listCtrl:scrollToPercentVertical(100, 0.1, true)
    self:removeMagicAndNoSee("MagicPanel", ResMgr:getMagicDownIcon())
end


-- 初始化选中
function QuanmPKPrepareDlg:initSelect()
    self:onSelectEquipBtn(self:getControl("HelmetPanel"))

    self.radioGroup:setSetlctByName("EquipCheckBox")
end

function QuanmPKPrepareDlg:initCheckPanel()
    local checkPanel = self:getControl("CheckPanel")
    for _, panelName in pairs(CHECK_PANEL_NAME) do
        local panel = self:getControl(panelName, nil, checkPanel)
        self:setImagePlist("Statusimage", ResMgr.ui.touming, panel)
    end
end

-- 初始化时，克隆、绑定点击
function QuanmPKPrepareDlg:initCloneAndBind()
    -- 弹出悬浮panel
    self:bindFloatPanelListener("TipPanel")
    self:bindFloatPanelListener("ChoseMenuPanel")

    -- 菜单相关
    self.menuPanel = self:toCloneCtrl("MenuPanel")
    self.seleceMenuImage = self:toCloneCtrl("BChosenEffectImage", self.menuPanel)
    self.seleceArrowImage = self:toCloneCtrl("UpArrowImage", self.menuPanel)
    self:bindTouchEndEventListener(self.menuPanel, self.onMenuButton)

    -- 装备相关
    self.selectEquipImage = self:toCloneCtrl("ChosenPanelImage", "HelmetPanel")
    for ctrlName, _ in pairs(EQUIP_DISPLAY_PANEL) do
       self:bindListener(ctrlName, self.onSelectEquipBtn)
    end

    -- 弹出选择
    self.tipPanel = self:toCloneCtrl("RowUnitPanel")
    self:bindListener("UnitPanel1", self.onSelectTipBtn, self.tipPanel)
    self:bindListener("UnitPanel2", self.onSelectTipBtn, self.tipPanel)
    self:bindListener("UnitPanel3", self.onSelectTipBtn, self.tipPanel)

    -- 宠物
    self.pickedPetPanel = self:toCloneCtrl("PickedPetPanel")
    self.pickedPetEffectImage = self:toCloneCtrl("ChosenEffectImage", self.pickedPetPanel)
    self:bindTouchEndEventListener(self.pickedPetPanel, self.onPickedElitePetBtn)
    self.addPetPanel = self:toCloneCtrl("PetEmptyPanel")
    self:bindTouchEndEventListener(self.addPetPanel, self.onAddElitePetBtn)
    self.chosePetPanel = self:toCloneCtrl("ElitePetPanel")
    self:bindTouchEndEventListener(self.chosePetPanel, self.onChosePetBtn)
    self.chosePetEffectImage = self:toCloneCtrl("ChosenEffectImage", self.chosePetPanel)

    -- 物资相关的
    self.itemOneRowPanel = self:toCloneCtrl("OneRowPanel")
    self.itemSelectImage = self:toCloneCtrl("ChosenEffectImage", self.itemOneRowPanel)

    self:bindListener("ItemPetPanel_1", self.onSelectItemPanel, self.itemOneRowPanel)
    self:bindListener("ItemPetPanel_2", self.onSelectItemPanel, self.itemOneRowPanel)

    local leftPanel = self:getControl("ItemPetPanel_1", nil, self.itemOneRowPanel)
    self:bindListener("ShapePanel", self.onShowCard, leftPanel)
    local rightPanel = self:getControl("ItemPetPanel_2", nil, self.itemOneRowPanel)
    self:bindListener("ShapePanel", self.onShowCard, rightPanel)

    -- 回收的checkbox
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, RECLAIM_CHECK, self.onReclaimCheckBox)

    -- 角色重置点
    self:bindListener("ResetUserButton", self.onResetUserPoint, "PrepareEquipPanel")
    self:bindListener("ResetAttribButton", self.onResetAttribPoint, "ChoseMenuPanel")
    self:bindListener("UpgradeChangeButton", self.onChangeUpgradeButton, "ChoseMenuPanel")

    -- 一键检测
    local checkPanel = self:getControl("CheckPanel")
    self:bindListener("CheckButton", self.onCheckButton, checkPanel)
end

function QuanmPKPrepareDlg:cleanup()
    self:releaseCloneCtrl("menuPanel")
    self:releaseCloneCtrl("seleceMenuImage")
    self:releaseCloneCtrl("seleceArrowImage")
    self:releaseCloneCtrl("selectEquipImage")
    self:releaseCloneCtrl("tipPanel")
    self:releaseCloneCtrl("pickedPetPanel")
    self:releaseCloneCtrl("pickedPetEffectImage")
    self:releaseCloneCtrl("addPetPanel")
    self:releaseCloneCtrl("chosePetPanel")
    self:releaseCloneCtrl("chosePetEffectImage")
    self:releaseCloneCtrl("itemOneRowPanel")
    self:releaseCloneCtrl("itemSelectImage")
end

-- 绑定装备推荐按钮
function QuanmPKPrepareDlg:bindEquipButton()
                            -- 物攻型                      法攻型                                 速度型                                 防御型                             障碍型
    local recommendedBtn = {"PhyTypeButton", "MagTypeButton", "SpeedTypeButton", "DefTypeButton", "ObstacleTypeButton"}

    -- 推荐按钮
    local equipPanel = self:getControl("EquipAttribPanel")
    for _, ctlName in pairs(RECOMMEND_CHECK) do
        local btn = self:getControl(ctlName, nil, equipPanel)
        btn.equipType = "EquipAttribPanel"
    end
    self.equipRadioGroup = RadioGroup.new()
    self.equipRadioGroup:setItems(self, RECOMMEND_CHECK, self.onRecommendedButton, equipPanel)


    local jewelryPanel = self:getControl("JewelryAttribPanel")
    for _, ctlName in pairs(RECOMMEND_CHECK) do
        local btn = self:getControl(ctlName, nil, jewelryPanel)
        btn.equipType = "JewelryAttribPanel"
    end
    self.jewelryRadioGroup = RadioGroup.new()
    self.jewelryRadioGroup:setItems(self, RECOMMEND_CHECK, self.onRecommendedButton, jewelryPanel)
    --]]

    -- 装备，点击弹出框
    -- 蓝属性
    for i = 1, 3 do
        local panel = self:getControl("BlueAttribPanel_" .. i, nil, equipPanel)
        local btn = self:getControl("ExpandButton", nil, panel)
        btn.color = "blue"
        btn.order = i
        btn.curPanel = panel
        self:bindTouchEndEventListener(btn, self.onExpandButton)

        local bkImage = self:getControl("BKImage", nil, panel)
        bkImage.color = "blue"
        bkImage.order = i
        bkImage.curPanel = panel
        self:bindTouchEndEventListener(bkImage, self.onExpandButton)
    end

    -- 粉属性
    local pinkPanel = self:getControl("PinkAttribPanel", nil, equipPanel)
    local btn = self:getControl("ExpandButton", nil, pinkPanel)
    btn.color = "pink"
    btn.curPanel = pinkPanel
    self:bindTouchEndEventListener(btn, self.onExpandButton)
    local bkImage = self:getControl("BKImage", nil, pinkPanel)
    bkImage.color = "pink"
    bkImage.curPanel = pinkPanel
    self:bindTouchEndEventListener(bkImage, self.onExpandButton)

    -- 黄属性
    local yellowPanel = self:getControl("GoldAttribPanel", nil, equipPanel)
    local btn = self:getControl("ExpandButton", nil, yellowPanel)
    btn.color = "yellow"
    btn.curPanel = yellowPanel
    self:bindTouchEndEventListener(btn, self.onExpandButton)
    local bkImage = self:getControl("BKImage", nil, yellowPanel)
    bkImage.color = "yellow"
    bkImage.curPanel = yellowPanel
    self:bindTouchEndEventListener(bkImage, self.onExpandButton)

    -- 绿属性的暗属性
    local polarPanel = self:getControl("PolarPanel", nil, equipPanel)
    local btn = self:getControl("ExpandButton", nil, polarPanel)
    btn.color = "black"
    btn.curPanel = polarPanel
    self:bindTouchEndEventListener(btn, self.onExpandButton)
    local bkImage = self:getControl("BKImage", nil, polarPanel)
    bkImage.color = "black"
    bkImage.curPanel = polarPanel
    self:bindTouchEndEventListener(bkImage, self.onExpandButton)

    -- 绿属性
    local greenPanel = self:getControl("GreenAttribPanel", nil, equipPanel)
    local btn = self:getControl("ExpandButton", nil, greenPanel)
    btn.color = "green"
    btn.curPanel = greenPanel
    self:bindTouchEndEventListener(btn, self.onExpandButton)
    local bkImage = self:getControl("BKImage", nil, greenPanel)
    bkImage.color = "green"
    bkImage.curPanel = greenPanel
    self:bindTouchEndEventListener(bkImage, self.onExpandButton)

    -- 共鸣属性
    local gongmingPanel = self:getControl("GongmingPanel", nil, equipPanel)
    local btn = self:getControl("ExpandButton", nil, gongmingPanel)
    btn.color = "gongming"
    btn.curPanel = gongmingPanel
    self:bindTouchEndEventListener(btn, self.onExpandButton)
    local bkImage = self:getControl("BKImage", nil, gongmingPanel)
    bkImage.color = "gongming"
    bkImage.curPanel = gongmingPanel
    self:bindTouchEndEventListener(bkImage, self.onExpandButton)

    -- 首饰，点击弹出
    -- 蓝属性
    for i = 1, self:getShoushiAtribMax() do
        local panel = self:getControl("BlueAttribPanel_" .. i, nil, jewelryPanel)
        local btn = self:getControl("ExpandButton", nil, panel)
        btn.color = "blue"
        btn.order = i
        btn.curPanel = panel
        self:bindTouchEndEventListener(btn, self.onExpandButton)
        local bkImage = self:getControl("BKImage", nil, panel)
        bkImage.color = "blue"
        bkImage.order = i
        bkImage.curPanel = panel
        self:bindTouchEndEventListener(bkImage, self.onExpandButton)
    end

    --      法宝
    local artifactPanel = self:getControl("ArtifactAttribPanel")
    -- 种类
    local panel = self:getControl("TypePanel", nil, artifactPanel)
    local btn = self:getControl("ExpandButton", nil, panel)
    btn.content = CHS[4100509]
    btn.curPanel = panel
    self:bindTouchEndEventListener(btn, self.onExpandButton)
    local bkImage = self:getControl("BKImage", nil, panel)
    bkImage.content = CHS[4100509]
    bkImage.curPanel = panel
    self:bindTouchEndEventListener(bkImage, self.onExpandButton)

    -- 相性
    local panel = self:getControl("PolarPanel", nil, artifactPanel)
    local btn = self:getControl("ExpandButton", nil, panel)
    btn.content = CHS[4100510]
    btn.curPanel = panel
    self:bindTouchEndEventListener(btn, self.onExpandButton)
    local bkImage = self:getControl("BKImage", nil, panel)
    bkImage.content = CHS[4100510]
    bkImage.curPanel = panel
    self:bindTouchEndEventListener(bkImage, self.onExpandButton)

    -- 特殊技能
    local panel = self:getControl("SpecilSkillPanel", nil, artifactPanel)
    local btn = self:getControl("ExpandButton", nil, panel)
    btn.content = CHS[4100511]
    btn.curPanel = panel
    self:bindTouchEndEventListener(btn, self.onExpandButton)
    local bkImage = self:getControl("BKImage", nil, panel)
    bkImage.content = CHS[4100511]
    bkImage.curPanel = panel
    self:bindTouchEndEventListener(bkImage, self.onExpandButton)

    -- 生成装备
    self:bindListener("MakeEquipButton", self.onMakeEquipButton)

    -- 顿悟技能弹出按钮绑定
    local panel = self:getControl("DunwSkillPane")
    for i = 1, 2 do
        local innatePanel = self:getControl("InnateSkillPanel_" .. i, nil, panel)
        local btn = self:getControl("ExpandButton", nil, innatePanel)
        btn.content = CHS[4100538] -- 顿悟技能
        btn.curPanel = innatePanel
        btn:setTag(i)
        self:bindTouchEndEventListener(btn, self.onExpandButton)

        local bkImage = self:getControl("BKImage", nil, innatePanel)
        bkImage.content = CHS[4100538]
        bkImage.curPanel = innatePanel
        bkImage:setTag(i)
        self:bindTouchEndEventListener(bkImage, self.onExpandButton)
    end

    -- 增加、减少按钮
    self:blindPress("LeftButton")
    self:blindPress("RightButton")

    -- 生成宠物
    self:bindListener("MakePetButton", self.onMakePetButton)

    -- 修改顿悟
    self:bindListener("ModifyDunwButton", self.onModifyDunwButton)

    -- 修改宠物属性点
    self:bindListener("ResetButton", self.onResetPetPointButton)

    -- 领取物资
    self:bindListener("GetButton", self.onGetButton)

    -- 回收物品
    self:bindListener("ReclaimButton", self.onReclaimButton)

    -- 天生技能 图标点击
    for i = 1, 3 do
        local unitSkillPanel = self:getControl("InnateSkillPanel_" .. i)
        self:bindListener("InnateSkillBKImage", self.onSkillImageButton, unitSkillPanel)
    end

    -- 顿悟技能 图标点击
    local panel = self:getControl("DunwSkillPane")
    for i = 1, 2 do
        local innatePanel = self:getControl("InnateSkillPanel_" .. i, nil, panel)
        self:bindListener("InnateSkillBKImage", self.onSkillImageButton, innatePanel)
    end
end

-- 初始化的显示状态， 不等于 ctrlName的全部隐藏
function QuanmPKPrepareDlg:initCtrlVisible(ctrlName)
    self:setCtrlVisibleForMenu(ctrlName)
    self:setCtrlVisibleForEquip(ctrlName)
end

-- 设置菜单相关界面显示
function QuanmPKPrepareDlg:setCtrlVisibleForMenu(ctrlName)
    self:setCtrlVisible("PrepareEquipPanel",  ctrlName == "PrepareEquipPanel")
    self:setCtrlVisible("PreparePetPanel",  ctrlName == "PreparePetPanel")
    self:setCtrlVisible("PrepareItemPanel",  ctrlName == "PrepareItemPanel")
    self:setCtrlVisible("ReclaimPanel",  ctrlName == "ReclaimPanel")
    self:setCtrlVisible("CheckPanel",  ctrlName == "CheckPanel")
end

-- 设置装备相关界面显示
function QuanmPKPrepareDlg:setCtrlVisibleForEquip(ctrlName)
    self:setCtrlVisible("EquipAttribPanel",  ctrlName == "EquipAttribPanel")
    self:setCtrlVisible("JewelryAttribPanel",  ctrlName == "JewelryAttribPanel")
    self:setCtrlVisible("ArtifactAttribPanel",  ctrlName == "ArtifactAttribPanel")
end

-- 左侧菜单初始化
function QuanmPKPrepareDlg:leftMenuInit()
    local menuListView = self:resetListView("CategoryListView")
    for _, title in pairs(LEFT_MENU) do
        local panel = self.menuPanel:clone()
        panel:setName(title)
        self:setLabelText("Label", title, panel)
        menuListView:pushBackCustomItem(panel)

        -- 默认选择第一个
        if not self.curMenu then
            self:onMenuButton(panel)
        end
    end

    menuListView:doLayout()
end

-- 点击菜单
function QuanmPKPrepareDlg:onMenuButton(sender, eventType)
    -- 点击的效果
    self.seleceMenuImage:removeFromParent()
    sender:addChild(self.seleceMenuImage)
    self.seleceArrowImage:removeFromParent()
    sender:addChild(self.seleceArrowImage)

    -- 显示相关panel
    local menu = sender:getName()
    self.curMenu = menu
    self.itemCount = 1
    self.selectItem = nil
    self:updateGetItemCount()
    self:setCtrlVisibleForMenu(MENU_DISPLAY_PANEL[menu])

   -- gf:ShowSmallTips("点击了菜单：" .. menu)

    if menu == CHS[4100500] then
        self:setReadyPetList()
    elseif menu == CHS[4100501] then    -- 妖     石
        local listInfo = self:getStoneList(menu)
        self:setItemListView(listInfo)
    elseif menu == CHS[4100502] then    -- 天     书
        local listInfo = self:getGodBooksList()
        self:setItemListView(listInfo)
    elseif menu == CHS[4100503] or menu == CHS[4100504] then
        local listInfo = self:getDataListByMenu(menu)
        self:setItemListView(listInfo)
    elseif menu == CHS[4100505] or menu == CHS[4100506] then
        self.reclaimItem = self:getReclaimItem()
        self:onReclaimCheckBox(self:getControl(self.radioGroup:getSelectedRadioName()))
    end
--
end

-- 根据菜单获取道具基本信息
-- showCard ：打开变身卡名片 showItem ：打开普通道具名片
function QuanmPKPrepareDlg:getDataListByMenu(menu)
    local tab = EQUIP_CFG[menu]
    if menu == CHS[4100504] and DistMgr:isInQcldServer() then
        -- 青城论道需要显示神兽卡
        tab = EQUIP_CFG[CHS[7150139]]
    end

    local ret = {}
    for _, name in pairs(tab) do
        if menu == CHS[4100504] and name ~= CHS[4200378] then
            table.insert(ret, {name = name, icon = InventoryMgr:getIconByName(name), showCard = 1})
        else
            table.insert(ret, {name = name, icon = InventoryMgr:getIconByName(name), showItem = 1})
        end
    end

    return ret
end

-- 获取天书数据
function QuanmPKPrepareDlg:getGodBooksList()
    local ret = {}
    for _, info in pairs(godBooks) do
        table.insert(ret, {name = info.name, icon = InventoryMgr:getIconByName(info.name), showItem = 1})
    end

    return ret
end

-- 获取妖石数据  石头需要加等级
function QuanmPKPrepareDlg:getStoneList(menu)
    local tab = EQUIP_CFG[menu]
    local ret = {}
    for _, name in pairs(tab) do
        local data = Formula:getPetStoneAttri(name, self:getStoneLevel())
        data.isStone = true
        data.level = self:getStoneLevel()
        data.icon = InventoryMgr:getIconByName(name)
        table.insert(ret, data)
    end

    return ret
end

-- 设置单个物资panel
function QuanmPKPrepareDlg:setUnitItemPanel(data, panel)
    if not data then
        panel:setVisible(false)
        return
    end
    self:setLabelText("NameLabel", data.name, panel)

    if data.isPet then
        self:setImage("GuardImage", ResMgr:getSmallPortrait(data.icon), panel)
    else
        self:setImage("GuardImage", ResMgr:getItemIconPath(data.icon), panel)
    end
    if data.level and data.level > 1 then
        self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)
    end

    if data.amount and data.amount > 1 then
        self:setNumImgForPanel("ShapePanel", ART_FONT_COLOR.NORMAL_TEXT, data.amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21, panel)
    end

    panel.data = data
end

-- 设置物质列表， itemListInfo
function QuanmPKPrepareDlg:setItemListView(itemListInfo)
    local listCtrl = self:resetListView("ItemListView")
    if not itemListInfo or not next(itemListInfo) then return end

    local amountRow = math.ceil(#itemListInfo / 2)
    for i = 1, amountRow do
        local panel = self.itemOneRowPanel:clone()
        local leftPanel = self:getControl("ItemPetPanel_1", nil, panel)
        self:setUnitItemPanel(itemListInfo[(i - 1) * 2 + 1],leftPanel)
        local rightPanel = self:getControl("ItemPetPanel_2", nil, panel)
        self:setUnitItemPanel(itemListInfo[(i - 1) * 2 + 2],rightPanel)

        listCtrl:pushBackCustomItem(panel)

        -- 默认选中第一个
        if not self.selectItem then
            self:onSelectItemPanel(leftPanel)
        end
    end
    listCtrl:doLayout()
    listCtrl:refreshView()
end

-- 点击装备格子
function QuanmPKPrepareDlg:onSelectEquipBtn(sender, eventType)
    -- 选择效果
    self.selectEquipImage:removeFromParent()
    sender:addChild(self.selectEquipImage)

    local senderName = sender:getName()
    self.selectEquipType = EQUIP_PANEL_EQUIPTYPE[senderName]

    self.makeEquip = {}

    -- 显示panel
    local panelName = EQUIP_DISPLAY_PANEL[senderName]
    self:setCtrlVisibleForEquip(panelName)

    -- 设置显示相关panel的数据
    local equipBasic = self:getGridEquip(senderName)
    self:setEquipBasic(equipBasic, panelName)

    --gf:ShowSmallTips("点击了装备格子：" .. senderName)
end

-- 设置装备的基本信息，icon，等级，改造等级，名字
function QuanmPKPrepareDlg:setEquipBasic(equip, panelName)
    local panel = self:getControl(panelName)

    -- icon，名字      法宝需要后面选，所以传进来是空的
    if equip then
        self:setImage("EquipmentImage", ResMgr:getItemIconPath(equip.icon), panel)
        self:setLabelText("EquipmentNameLabel", equip.name, panel)
        self:setLabelText("upgradeLabel", "", panel)

        self.makeEquip["name"] = equip.name
    else
        self:setLabelText("EquipmentNameLabel", "", panel)
        self:setLabelText("upgradeLabel", "", panel)
        self:setImagePlist("EquipmentImage", ResMgr.ui.touming, panel)

        self.makeEquip["item_polar"] = nil
        self.makeEquip["skill"] = nil
    end

    self:removeNumImgForPanel("EquipmentLevelPanel", LOCATE_POSITION.LEFT_TOP, panel)
    if panelName == "EquipAttribPanel" then
        self:setLabelText("upgradeLabel", string.format(CHS[7100287], DEFAULT_EQUIP_REBUILD_LEVEL), panel)
        self:setNumImgForPanel("EquipmentLevelPanel", ART_FONT_COLOR.NORMAL_TEXT, self:getEquipLevel(), false, LOCATE_POSITION.LEFT_TOP, 21, panel)
        self:setAttribForEquip({})

        local selectRecommend = self.equipRadioGroup:getSelectedRadio()
        if selectRecommend then
            self:onRecommendedButton(selectRecommend)
        end
    elseif panelName == "JewelryAttribPanel" then
        self:setNumImgForPanel("EquipmentLevelPanel", ART_FONT_COLOR.NORMAL_TEXT, self:getShoushiLevel(), false, LOCATE_POSITION.LEFT_TOP, 21, panel)
        self:setAttribForJewelry({})

        local selectRecommend = self.jewelryRadioGroup:getSelectedRadio()
        if selectRecommend then
            self:onRecommendedButton(selectRecommend)
        end
    elseif panelName == "ArtifactAttribPanel" then
        if equip then
            self:setNumImgForPanel("EquipmentLevelPanel", ART_FONT_COLOR.NORMAL_TEXT, self:getArtifactLevel(), false, LOCATE_POSITION.LEFT_TOP, 21, panel)
        else
            -- 种类
            local typePanel = self:getControl("TypePanel", nil, panel)
            self:setLabelText("AttribNameLabel", "", typePanel)

            local polarPanel = self:getControl("PolarPanel", nil, panel)
            self:setLabelText("AttribNameLabel", "", polarPanel)

            local polarCtrl = self:getControl("EquipmentImage", nil, panel)
            InventoryMgr:removeArtifactPolarImage(polarCtrl)

            -- 特殊技能
            local skillPanel = self:getControl("SpecilSkillPanel", nil, panel)
            self:setLabelText("AttribNameLabel", "", skillPanel)
        end
    end
end

-- 点击装备格子时，获取该格子上的装备信息
function QuanmPKPrepareDlg:getGridEquip(gridName)
    local equipType = EQUIP_PANEL_EQUIPTYPE[gridName]
    if equipType == EQUIP_TYPE.WEAPON then
        local polar = Me:queryInt("polar")
        return EQUIP_INFO[equipType][polar]
    elseif equipType == EQUIP_TYPE.HELMET or equipType == EQUIP_TYPE.ARMOR then
        local gender = Me:queryInt("gender")
        return EQUIP_INFO[equipType][gender]
    else
        return EQUIP_INFO[equipType]
    end
end

-- 点击装备的推荐按钮   物攻、法功速度防御等
function QuanmPKPrepareDlg:onRecommendedButton(sender, eventType)
    if not self.selectEquipType then return end     -- 正常不会发生

    local remType = sender:getName()
    local attribs = RECOMMENDED_INFO[self.selectEquipType][remType]

    if not attribs then
        --gf:ShowSmallTips("暂时不可能1！！！！！！！！！！！")
        return
    end

    if sender.equipType == "EquipAttribPanel" then
        self:setAttribForEquip(attribs)
    elseif sender.equipType == "JewelryAttribPanel" then
        self:setAttribForJewelry(attribs)
    end
end

-- 获取某属性该显示的字符串
function QuanmPKPrepareDlg:getAttribChs(chs, color)
    if string.match(chs, "XX") then
        if Me:queryInt("polar") == 1 then
            chs = string.gsub(chs, "XX", CHS[3002336]) -- 遗忘
        elseif Me:queryInt("polar") == 2 then
            chs = string.gsub(chs, "XX", CHS[3002334]) -- 中毒
        elseif Me:queryInt("polar") == 3 then
            chs = string.gsub(chs, "XX", CHS[3002337]) -- 冰冻
        elseif Me:queryInt("polar") == 4 then
            chs = string.gsub(chs, "XX", CHS[3002335]) -- 昏睡
        elseif Me:queryInt("polar") == 5 then
            chs = string.gsub(chs, "XX", CHS[3002338]) -- 混乱
        end
    elseif string.match(chs, "polar") then
        chs = string.gsub(chs, "polar", gf:getPolar(Me:queryInt("polar"))) -- 遗忘
    end

    local equip = {equip_type = self.selectEquipType, req_level = self:getEquipLevel(),
        item_type = ITEM_TYPE.EQUIPMENT, rebuild_level = DEFAULT_EQUIP_REBUILD_LEVEL}
    if EquipmentMgr:isJewelry(equip) then
        equip.req_level = 120
    end

    local field = EquipmentMgr:getAttribChsOrEng(chs)
    local max, min = EquipmentMgr:getAttribMaxValueByField(equip, field)
    local curValue = 0
    if color == "black" then
        min, max = EquipmentMgr:getSuitMinAndMax(equip, field)
        curValue = math.floor(max * DEFAULT_EQUIP_PROP_RATE)
    elseif color == "blue" then
        curValue = max
    else
        curValue = math.floor(max * DEFAULT_EQUIP_PROP_RATE)
    end

    if EquipmentMgr:isJewelry(equip) then
        curValue = math.floor(curValue * DEFAULT_JEWELRY_PROP_RATE)
    end

    local bai = EquipmentMgr:getPercentSymbolByField(field)
    local str = chs .. ": " .. curValue .. bai .. "/" .. max .. bai
    return str, field, max
end

-- 设置首饰的属性
function QuanmPKPrepareDlg:setAttribForJewelry(attribs)
    local jewelryPanel = self:getControl("JewelryAttribPanel")

    -- 设置蓝属性
    for i = 1, self:getShoushiAtribMax() do
        local panel = self:getControl("BlueAttribPanel_" .. i, nil, jewelryPanel)
        local chs = attribs["blue" .. i]
        if chs then
            local str, field, max = self:getAttribChs(chs, "blue")
            self.makeEquip["blue" .. i] = {field = field, value = math.floor(max * DEFAULT_JEWELRY_PROP_RATE)}
            self:setLabelText("AttribNameLabel", str, panel)
        else
            self:setLabelText("AttribNameLabel", "", panel)
        end
    end

    for i = self:getShoushiAtribMax() + 1, 5 do
        local panel = self:getControl("BlueAttribPanel_" .. i, nil, jewelryPanel)
        if panel then
            panel:setVisible(false)
        end
    end
end

-- 设置装备的属性
function QuanmPKPrepareDlg:setAttribForEquip(attribs)
    local equipPanel = self:getControl("EquipAttribPanel")

    -- 设置蓝属性
    for i = 1, 3 do
        local panel = self:getControl("BlueAttribPanel_" .. i, nil, equipPanel)
        local chs = attribs["blue" .. i]
        if chs then
            local str, field, max = self:getAttribChs(chs, "blue")
            self.makeEquip["blue" .. i] = {field = field, value = max}
            self:setLabelText("AttribNameLabel", str, panel)
        else
            self:setLabelText("AttribNameLabel", "", panel)
        end
    end

    -- 粉属性
    local pinkPanel = self:getControl("PinkAttribPanel", nil, equipPanel)
    local pinkChs = attribs["pink"]
    if pinkChs then
        local str, field, max = self:getAttribChs(pinkChs)
        self:setLabelText("AttribNameLabel", str, pinkPanel)
        self.makeEquip["pink"] = {field = field, value = max}
    else
        self:setLabelText("AttribNameLabel", "", pinkPanel)
    end

    -- 黄属性
    local yellowPanel = self:getControl("GoldAttribPanel", nil, equipPanel)
    local yellowChs = attribs["yellow"]
    if yellowChs then
        local str, field, max = self:getAttribChs(yellowChs)
        self.makeEquip["yellow"] = {field = field, value = max}
        self:setLabelText("AttribNameLabel", str, yellowPanel)
    else
        self:setLabelText("AttribNameLabel", "", yellowPanel)
    end

    -- 绿属性的暗属性
    local polarPanel = self:getControl("PolarPanel", nil, equipPanel)
    local blackChs = attribs["black"]
    if blackChs then
        local str, field, max = self:getAttribChs(blackChs, "black")
        self.makeEquip["black"] = {field = field, value = max}
        self:setLabelText("AttribNameLabel", str, polarPanel)
    else
        self:setLabelText("AttribNameLabel", "", polarPanel)
    end

    -- 绿属性
    local greenPanel = self:getControl("GreenAttribPanel", nil, equipPanel)
    local greenChs = attribs["green"]
    if greenChs then
        local str, field, max = self:getAttribChs(greenChs, "green")
        self.makeEquip["green"] = {field = field, value = max}
        self:setLabelText("AttribNameLabel", str, greenPanel)
    else
        self:setLabelText("AttribNameLabel", "", greenPanel)
    end

    -- 共鸣属性
    local gongmingPanel = self:getControl("GongmingPanel", nil, equipPanel)
    local gongmingChs = attribs["gongming"]
    self:setLabelText("AttribNameLabel", "", gongmingPanel)
    if gongmingChs then
        local str, field, max = self:getAttribChs(gongmingChs, "blue")
        gf:CmdToServer("CMD_PREVIEW_RESONANCE_ATTRIB", {type = self.selectEquipType,
            level = QuanmPKPrepareDlg:getEquipLevel(), attrib = field,
            rebuildLevel = DEFAULT_EQUIP_REBUILD_LEVEL})
    else
        self:setLabelText("AttribNameLabel", "", gongmingPanel)
    end
end

-- 预览的共鸣属性回来了
function QuanmPKPrepareDlg:MSG_PREVIEW_RESONANCE_ATTRIB(data)
    if not self.selectEquipType then return end
    if self.selectEquipType == data.type then
        local equipPanel = self:getControl("EquipAttribPanel")
        local gongmingPanel = self:getControl("GongmingPanel", nil, equipPanel)
        local field = EquipmentMgr:getAttribChsOrEng(data.attrib)
        local bai = EquipmentMgr:getPercentSymbolByField(data.attrib)
        self.makeEquip["gongming"] = {field = data.attrib, value = data.gongmingAttrib}
        local str = field .. ": " .. data.gongmingAttrib .. bai .. "/" .. data.gongmingAttrib .. bai
        self:setLabelText("AttribNameLabel", str, gongmingPanel)
    end
end

-- 根据当前选择的属性，转化成相关格式发送服务器
function QuanmPKPrepareDlg:changeAttribInfo()
    if not self.selectEquipType then return end     -- 正常不会发生

    local blue = ""
    local pink = ""
    local yellow = ""
    local green = ""
    local black = ""
    local gongming = ""

    if self.selectEquipType == EQUIP_TYPE.ARTIFACT then
        blue = self.makeEquip.item_polar .. "|" .. self.makeEquip.skill
        return blue, pink, yellow, green, black
    end

    for i = 1, self:getShoushiAtribMax() do
        local att = self.makeEquip["blue" .. i]
        if att then
            if blue ~= "" then blue = blue .. "|" end
            blue = blue .. att.field
        end
    end

    if self.makeEquip["pink"] then pink = pink .. self.makeEquip["pink"].field end

    if self.makeEquip["yellow"] then yellow = yellow .. self.makeEquip["yellow"].field end

    if self.makeEquip["green"] then green = green .. self.makeEquip["green"].field end

    if self.makeEquip["black"] then black = black .. self.makeEquip["black"].field end

    if self.makeEquip["gongming"] then gongming = gongming .. self.makeEquip["gongming"].field end

    return blue, pink, yellow, green, black, gongming
end

function QuanmPKPrepareDlg:getElite()
    local elitePet = {}
    for _, pet in pairs(PetMgr.pets) do
        if pet:queryInt('rank') == Const.PET_RANK_ELITE or pet:queryInt('rank') == Const.PET_RANK_EPIC then
            table.insert(elitePet, pet)
        end
    end

    return elitePet
end

-- 生成宠物
function QuanmPKPrepareDlg:onMakePetButton(sender, eventType)
    if not self.addElite then
        return
    end

    local pets = self:getElite()
    gf:confirm(string.format(CHS[4100540], self.addElite), function ()
        if #pets >= 3 then
            gf:ShowSmallTips(CHS[4100539])
            return
        end
        QuanminPKMgr:cmdGenPet(self.addElite)
    end)
end

-- 修改宠物属性点
function QuanmPKPrepareDlg:onResetPetPointButton(sender, eventType)
    if not self.selectReadyPet then return end
    QuanminPKMgr:cmdResetPoint(self.selectReadyPet:getId())
end

-- 领取物品
function QuanmPKPrepareDlg:onReclaimButton(sender, eventType)
    if not self.selectItem then
        gf:ShowSmallTips(CHS[4100534])
        return
    end

    local selectItemId = self.selectItem.id
    gf:confirm(string.format(CHS[4100535], self.selectItem.name), function ()
        QuanminPKMgr:cmdRecycleItem(selectItemId)
    end)
end

-- 领取物品
function QuanmPKPrepareDlg:onGetButton(sender, eventType)
    if not self.selectItem then return end

    QuanminPKMgr:cmdFetchItem(self.selectItem.name, self.itemCount)
end

-- 点击技能图标
function QuanmPKPrepareDlg:onSkillImageButton(sender, eventType)
    local panel = sender:getParent()
    if not panel.skillName then return end

    local rect = self:getBoundingBoxInWorldSpace(sender)
    SkillMgr:showSkillDescDlg(panel.skillName, 0, true, rect)
end

-- 获取当前已显示的顿悟技能
function QuanmPKPrepareDlg:getReadyDunwSkills()
    local panel = self:getControl("DunwSkillPane")
    local innatePanel1 = self:getControl("InnateSkillPanel_1", nil, panel)
    local skill1 = self:getLabelText("TipsLabel", innatePanel1)
 --   local skillInfo1 = SkillMgr:getskillAttribByName(skill1)

    local innatePanel2 = self:getControl("InnateSkillPanel_2", nil, panel)
    local skill2 = self:getLabelText("TipsLabel", innatePanel2)
  --  local skillInfo2 = SkillMgr:getskillAttribByName(skill2)

    return skill1, skill2
end

-- 修改宠物顿悟竟能
function QuanmPKPrepareDlg:onModifyDunwButton(sender, eventType)
    if not self.selectReadyPet then return end

    local skill1, skill2 = self:getReadyDunwSkills()
    local skillInfo1 = SkillMgr:getskillAttribByName(skill1)
    local skillInfo2 = SkillMgr:getskillAttribByName(skill2)

    if not skillInfo1 or not skillInfo2 then
        gf:ShowSmallTips(CHS[4100536])
        return
    end

    local skillStr = skillInfo1.skill_no .. "|" .. skillInfo2.skill_no
    QuanminPKMgr:cmdSetDunwSkill(self.selectReadyPet:getId(), skillStr)
end

-- 生成装备
function QuanmPKPrepareDlg:onMakeEquipButton(sender, eventType)
    if not self.selectEquipType then return end     -- 正常不会发生

    if self.selectEquipType == EQUIP_TYPE.ARTIFACT and (not self.makeEquip.name or
        not self.makeEquip.item_polar or not self.makeEquip.skill)then
        gf:ShowSmallTips(CHS[4100537])
        return
    end

    if not self.makeEquip or not next(self.makeEquip) then return end

    local blue, pink, yellow, green, black, gongming = self:changeAttribInfo()

    QuanminPKMgr:cmdGenEquipment(self.makeEquip.name, blue, pink, yellow, green, black, gongming)
end

function QuanmPKPrepareDlg:getCanChosenDunwSkill(tag)
    if not self.selectReadyPet then return {} end
    local total = {}
    local skill1, skill2 = self:getReadyDunwSkills()

    local hasInnateSkill = SkillMgr:getPetRawSkillNoAndLadder(self.selectReadyPet:getId()) or {}

    local function isExsit(descSkill, skills)
    	for i = 1, #skills do
    	   if descSkill == skills[i].name then return true end
    	end
        return false
    end


    for _, skillName in pairs(EQUIP_CFG[CHS[4100538]]) do
        if tag == 1 then
            if type(skillName) == "table" then
                local skillTemp = skillName[self.selectReadyPet:queryInt("polar")]
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
                local skillTemp = skillName[self.selectReadyPet:queryInt("polar")]
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

    return total
end

-- 点击后弹出选择悬浮框
function QuanmPKPrepareDlg:onExpandButton(sender, eventType)
    self:setCtrlVisible("TipPanel", true)

    -- 在tipPanel上做一个标记，点击选项后根据标记来设置相关内容
    local tipPanel = self:getControl("TipPanel")
    tipPanel.curPanel = sender.curPanel
    local listInfo
    if self.curMenu == CHS[4100500] then    --  宠     物
        if sender.content == CHS[4100538] then  -- 顿悟技能
            --gf:ShowSmallTips("你点击了，选择顿悟技能 ")
            listInfo = self:getCanChosenDunwSkill(sender:getTag())
        end
    else
        if self.selectEquipType == EQUIP_TYPE.ARTIFACT then
            listInfo = EQUIP_CFG[sender.content]
            tipPanel.content = sender.content
        else
            tipPanel.equipType = self.selectEquipType
            tipPanel.color = sender.color
            tipPanel.order = sender.order -- 如果是蓝属性，需要知道第几个

            listInfo = self:getColorAttribInfos(sender.color)
        end
    end

    self:setTipListViewData(listInfo)
end

-- 弹出选择悬浮框的点击事件
function QuanmPKPrepareDlg:onSelectTipBtn(sender, eventType)
    self:setCtrlVisible("TipPanel", false)

    -- 根据tipPanel上做的标记处理点击事件
    local tipPanel = self:getControl("TipPanel")
    local chs = sender.data
    if self.curMenu == CHS[4100500] then
        local icon = SkillMgr:getSkillIconFilebyName(chs)
        self:setImage("InnateSkillImage_1", icon, tipPanel.curPanel)
        self:setLabelText("TipsLabel", chs, tipPanel.curPanel)
        tipPanel.curPanel.skillName = chs
    else
        if self.selectEquipType == EQUIP_TYPE.ARTIFACT then
            -- 法宝
            if tipPanel.content == CHS[4100509] then
                -- 选择法宝种类
                local item = {name = chs, icon = InventoryMgr:getIconByName(chs)}
                self:setEquipBasic(item, "ArtifactAttribPanel")
            elseif tipPanel.content == CHS[4100510] then
                -- 选择法宝相性
                local shapePanel = self:getControl("EquipShapePanel", nil, "ArtifactAttribPanel")
                local panel = self:getControl("EquipmentImage", nil, shapePanel)
                local polar = gf:getIntPolar(chs)
                InventoryMgr:removeArtifactPolarImage(panel)
                InventoryMgr:addArtifactPolarImage(panel, polar)

                self.makeEquip["item_polar"] = polar

            elseif tipPanel.content == CHS[4100511] then
                -- 选择法宝技能
                self.makeEquip["skill"] = EQUIP_CFG[CHS[4100512]][chs]
            end

            self:setLabelText("AttribNameLabel", chs, tipPanel.curPanel)
        else
            -- 首饰、武器
            if tipPanel.color == "gongming" then
                local str, field, max = self:getAttribChs(chs, "blue")
                gf:CmdToServer("CMD_PREVIEW_RESONANCE_ATTRIB", {type = self.selectEquipType,
                    level = QuanmPKPrepareDlg:getEquipLevel(), attrib = field,
                    rebuildLevel = DEFAULT_EQUIP_REBUILD_LEVEL})
                return
            end

            local str, field, max = self:getAttribChs(chs, tipPanel.color)
            self.makeEquip[tipPanel.color .. (tipPanel.order or "")] = {field = field, value = max}
            self:setLabelText("AttribNameLabel", str, tipPanel.curPanel)
        end
    end
end

function QuanmPKPrepareDlg:setTipListViewData(infoList)
    local listCtrl = self:resetListView("TipListView")
    if not infoList then return end

    local count = math.ceil(#infoList / 3)
    for i = 1, count do
        local panel = self.tipPanel:clone()
        for j = 1, 3 do
            local key = (i - 1) * 3 + j
            local unitPanel = self:getControl("UnitPanel" .. j, nil, panel)
            if infoList[key] then
                unitPanel.data = infoList[key]
                self:setLabelText("Label", infoList[key], unitPanel)
            else
                unitPanel:setVisible(false)
            end
        end
        listCtrl:pushBackCustomItem(panel)
    end
    listCtrl:doLayout()
    listCtrl:refreshView()
end

function QuanmPKPrepareDlg:isCanExsitField(field, color)
    local equip = {item_type = ITEM_TYPE.EQUIPMENT, equip_type = self.selectEquipType, req_level = 100}

    local tipPanel = self:getControl("TipPanel")
    local count = 0
    if EquipmentMgr:isJewelry(equip) then
        for i = 1, 5 do
            local att = self.makeEquip["blue" .. i]
            if att and i ~= tipPanel.order and att.field == field then
                count = count + 1
            end
        end

        if field == "all_skill" or field == "all_polar" or field == "all_resist_except" then
            return count < 1
        end

        return count < 2
    end

    if color == "blue" then
        for i = 1, 3 do
            local att = self.makeEquip["blue" .. i]
            if att and i ~= tipPanel.order and att.field == field then
                return false
            elseif att and att.field == field then
                count = count + 1
            end
        end

        local att = self.makeEquip["pink"]
        if att and att.field == field then
            count = count + 1
        end

        local att = self.makeEquip["yellow"]
        if att and att.field == field then
            count = count + 1
        end

        return count < 2
    elseif color == "pink" then
        for i = 1, 3 do
            local att = self.makeEquip["blue" .. i]
            if att and i ~= tipPanel.order and att.field == field then
                count = count + 1
            end
        end

        local att = self.makeEquip["yellow"]
        if att and att.field == field then
            count = count + 1
        end
    elseif color == "yellow" then
        for i = 1, 3 do
            local att = self.makeEquip["blue" .. i]
            if att and i ~= tipPanel.order and att.field == field then
                count = count + 1
            end
        end

        local att = self.makeEquip["pink"]
        if att and att.field == field then
            count = count + 1
        end
    end

    return count < 2
end

-- 获取某颜色全部属性
function QuanmPKPrepareDlg:getColorAttribInfos(color, ctrlName)
    local ret = {}
    local attTab = {}
    if color == "blue" or color == "pink" or color == "yellow" then
        local allAttrib = EquipmentMgr:getEquipAttribCfgInfo()
        attTab = allAttrib[self.selectEquipType]
        for _, field in pairs(attTab) do
            if self:isCanExsitField(field, color) then
                table.insert(ret, EquipmentMgr:getAttribChsOrEng(field))
            end
        end
    elseif color == "green" then
        local key = ""
        if self.selectEquipType == EQUIP_TYPE.WEAPON then
            if Me:queryInt("polar") == POLAR.METAL then
                key = CHS[3003965]
            elseif Me:queryInt("polar") == POLAR.WOOD then
                key = CHS[3003966]
            elseif Me:queryInt("polar") == POLAR.WATER then
                key = CHS[3003964]
            elseif Me:queryInt("polar") == POLAR.FIRE then
                key = CHS[3003962]
            elseif Me:queryInt("polar") == POLAR.EARTH then
                key = CHS[3003963]
            end
        else
            key = self.selectEquipType
        end
        local allAttrib = EquipmentMgr:getAllSuitAttribByEquipType(key)
        for _, name in pairs(allAttrib) do
            table.insert(ret, name)
        end
    elseif color == "black" then
        local allAttrib = EquipmentMgr:getEquipSuitCfgInfo()
        for _, field in pairs(allAttrib) do
            table.insert(ret, EquipmentMgr:getAttribChsOrEng(field))
        end
    elseif color == "gongming" then
        local allAtttrib = EquipmentMgr:getGongmingAttribList()
        for i = 1, #allAtttrib do
            table.insert(ret, allAtttrib[i])
        end
    end

    return ret
end

-- 设置单个变异宠物
function QuanmPKPrepareDlg:setUnitElitePetPanel(info, panel)
    -- 等级
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, self:getPetLevel(), false, LOCATE_POSITION.LEFT_TOP, 21, panel)
    -- 相性
    local polarPath = ResMgr:getPolarImagePath(info.polar)
    self:setImagePlist("Image", polarPath, panel)
    -- icon
    self:setImage("GuardImage", ResMgr:getSmallPortrait(info.icon), panel)
    -- 名字
    self:setLabelText("NameLabel", info.name, panel)
    -- 类型
    self:setLabelText("LevelLabel", info.pet_rank == Const.PET_RANK_ELITE and CHS[3003666] or CHS[3003667], panel)

    local statusImg = self:getControl("StatusImage", Const.UIImage, panel)
    local petNameLabel = self:getControl("NameLabel", Const.UILabel, panel)
    local petLevelValueLabel = self:getControl("LevelLabel", Const.UILabel, panel)
    statusImg:setVisible(false)

    if info.pet_status == 1 then
        -- 参战
        statusImg:setVisible(true)
        petNameLabel:setColor(COLOR3.GREEN)
        petLevelValueLabel:setColor(COLOR3.GREEN)
        statusImg:loadTexture(ResMgr.ui.canzhan_flag_new)
    elseif info.pet_status == 2 then
        -- 掠阵
        petNameLabel:setColor(COLOR3.YELLOW)
        petLevelValueLabel:setColor(COLOR3.YELLOW)
        petLevelValueLabel:setColor(COLOR3.YELLOW)
        if 1 == SystemSettingMgr:getSettingStatus("award_supply_pet", 0) then
            statusImg:loadTexture(ResMgr.ui.gongtong_flag_new)
        else
            statusImg:loadTexture(ResMgr.ui.luezhen_flag_new)
        end
        statusImg:setVisible(true)
    end

end

-- 设置供选择变异宠物列表
function QuanmPKPrepareDlg:setElitePetList()
    local ctl = self:resetListView("ChoseListView")

    local petsList = self:getOrderElitePet()
    for _, info in pairs(petsList) do
        local panel = self.chosePetPanel:clone()
        self:setUnitElitePetPanel(info, panel)
        panel.data = info
        ctl:pushBackCustomItem(panel)
    end

    ctl:doLayout()
end

-- 设置准备好的变异宠物列表
function QuanmPKPrepareDlg:setReadyPetList()
    local ctl = self:resetListView("ReadyPetListView")

    local petsList = self:getElite()
    local count = 0
    for _, pet in pairs(petsList) do
        local info = {name = pet:queryBasic("raw_name"), icon = pet:queryBasicInt("portrait"),
            polar = pet:queryBasicInt("polar"), pet_status = pet:queryInt("pet_status"), pet_rank = pet:queryInt('rank')}
        local panel = self.pickedPetPanel:clone()
        self:setUnitElitePetPanel(info, panel)
        panel.pet = pet
        ctl:pushBackCustomItem(panel)
        count = count + 1

        if not self.selectReadyPet then
            self:onPickedElitePetBtn(panel)
        end
    end

    self:setLabelText("PetNumberValueLabel", count .. "/3")

    if count < 3 then
        local panel = self.addPetPanel:clone()
        ctl:pushBackCustomItem(panel)

        if count == 0 then
            self:onAddElitePetBtn(panel)
        end
    end

    ctl:doLayout()
end

-- 获取变异宠物列表，排好序的
function QuanmPKPrepareDlg:getOrderElitePet()
    local ret = {}
    local tmp = {}

    local function insertElitePetList()
        for name, info in pairs(elitePetList) do
            info = gf:deepCopy(info)
            info.pet_rank = Const.PET_RANK_ELITE
            table.insert(ret, info)
        end

        table.sort(ret, function(l, r) return l.order < r.order end)
    end

    local function insertEpicPetList()
        for name, info in pairs(EpicPetList) do
            info = gf:deepCopy(info)
            info.pet_rank = Const.PET_RANK_EPIC
            table.insert(tmp, info)
        end

        table.sort(tmp, function(l, r) return l.order < r.order end)

        for _, info in pairs(tmp) do
            table.insert(ret, info)
        end
    end

    if DistMgr:isInQcldServer() then
        insertEpicPetList()
        return ret
    end

    insertElitePetList()

    if not DistMgr:isInXMZBServer() then
        return ret
    end

    insertEpicPetList()

    return ret
end

-- 回收-名片
function QuanmPKPrepareDlg:onShowCard(sender, eventType)
    local data = sender:getParent().data
    local rect = self:getBoundingBoxInWorldSpace(sender)

    if data.isItem then
        local item = InventoryMgr:getItemByPos(data.pos)
        InventoryMgr:showOnlyFloatCardDlg(item, rect)
    end

    if data.isPet then
        local pet = PetMgr:getPetById(data.id)
        local dlg =  DlgMgr:openDlg("PetCardDlg")
        dlg:setPetInfo(pet, true)
    end

    if data.isStone then
        InventoryMgr:showOnlyFloatCardDlg(data, rect)
    end

    if data.showItem then
        InventoryMgr:showBasicMessageDlg(data.name, rect)
    end

    if data.showCard then
        local dlg = DlgMgr:openDlg("ChangeCardInfoDlg")
        dlg:setInfoFromItem({name = data.name}, true)
        dlg:setFloatingFramePos(rect)
    end

    self:onSelectItemPanel(sender:getParent())
end

function QuanmPKPrepareDlg:onSelectItemPanel(sender, eventType)
    self.itemSelectImage:removeFromParent()
    sender:addChild(self.itemSelectImage)

    if self.curMenu ~= CHS[4100505] then
        -- 不在回收标签页下，可增加数量
        if self.selectItem and self.selectItem.name == sender.data.name then
            self:onAddButton()
        else
            self.itemCount = 1
            self:updateGetItemCount()
        end
    end
    self.selectItem = sender.data
    --gf:ShowSmallTips("你选择了物资 :" .. self.selectItem.name)
end

function QuanmPKPrepareDlg:onPickedElitePetBtn(sender, eventType)
    self:setCtrlVisible("ChosePetPanel", false)
    self:setCtrlVisible("ModifyPetPanel", true)

    self.pickedPetEffectImage:removeFromParent()
    sender:addChild(self.pickedPetEffectImage)

    self.selectReadyPet = sender.pet
    --gf:ShowSmallTips("你选择了，以拥有的变异 :" .. self.selectReadyPet:getName())

    self:setReadyPetInfo(self.selectReadyPet)
end

-- 右侧，设置以选中宠物的信息
function QuanmPKPrepareDlg:setReadyPetInfo(pet)
    local panel = self:getControl("ModifyPetPanel")

    PetMgr:setPetLogo(self, pet)

    -- 名字、等级
    self:setLabelText("NameLabel", pet:getName() .. string.format(CHS[5000286], pet:queryInt("level")), panel)

    -- 形象
    self:setPortrait("PetShapePanel", pet:getDlgIcon(nil, nil, true), 0, panel, true, nil, nil, cc.p(0, -36))

    -- 天生技能
    local hasInnateSkill = SkillMgr:getPetRawSkillNoAndLadder(pet:getId()) or {}
    for i = 1, 3 do
        local unitSkillPanel = self:getControl("InnateSkillPanel_" .. i)
        local skill = hasInnateSkill[i]

        if skill then
            local skillIconPath = SkillMgr:getSkillIconPath(skill.no)
            self:setImage("InnateSkillImage_1", skillIconPath, unitSkillPanel)
            self:setLabelText("SkillNameLabel", skill.name, unitSkillPanel)
            unitSkillPanel.skillName = skill.name
        else
            unitSkillPanel.skillName = nil
        end
    end

    local dunWuSkills = SkillMgr:getPetDunWuSkills(pet:getId()) or {}
    -- 顿悟技能弹出按钮绑定
    local panel = self:getControl("DunwSkillPane")
    for i = 1, 2 do
        local innatePanel = self:getControl("InnateSkillPanel_" .. i, nil, panel)
        innatePanel.skillName = dunWuSkills[i]

        if dunWuSkills[i] then
            self:setImage("InnateSkillImage_1", SkillMgr:getSkillIconFilebyName(dunWuSkills[i]), innatePanel)
            self:setLabelText("TipsLabel", dunWuSkills[i], innatePanel)
        else
            self:setImagePlist("InnateSkillImage_1", ResMgr.ui.ask_symbol, innatePanel)
            self:setLabelText("TipsLabel", CHS[4100514], innatePanel)
        end
    end
end

function QuanmPKPrepareDlg:onAddElitePetBtn(sender, eventType)
    self:setCtrlVisible("ChosePetPanel", true)
    self:setCtrlVisible("ModifyPetPanel", false)

    self.pickedPetEffectImage:removeFromParent()
    sender:addChild(self.pickedPetEffectImage)
end

-- 点击选择要增加的变异宠物
function QuanmPKPrepareDlg:onChosePetBtn(sender, eventType)
    local info = sender.data
    self.addElite = info.name
    --gf:ShowSmallTips("你选择了，要增加的变异 :" .. self.addElite)

    self.chosePetEffectImage:removeFromParent()
    sender:addChild(self.chosePetEffectImage)
end

-- 点击增加物资数量按钮
function QuanmPKPrepareDlg:onAddButton(sender, eventType)
    self.itemCount = self.itemCount + 1
    if self.itemCount > 10 then
        gf:ShowSmallTips(CHS[4100515])
        self.itemCount = 10
    end

    self:updateGetItemCount()
end

-- 点击减少物资按钮
function QuanmPKPrepareDlg:onReduceButton(sender, eventType)
    self.itemCount = self.itemCount - 1
    if self.itemCount < 1 then
        gf:ShowSmallTips(CHS[4100516])
        self.itemCount = 1
    end

    self:updateGetItemCount()
end

function QuanmPKPrepareDlg:updateGetItemCount()
    self:setLabelText("AmountLabel", self.itemCount, "ModifyNumPanel")
end

-- 绑定长按事件
function QuanmPKPrepareDlg:blindPress(name)
    local widget = self:getControl(name)

    local function updataCount()
        if self.clickBtn == "LeftButton" then
            self:onReduceButton()
        elseif self.clickBtn == "RightButton" then
            self:onAddButton()
        end
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.clickBtn = sender:getName()
            schedule(widget , updataCount, 0.1)
        elseif eventType == ccui.TouchEventType.moved then
        else
            updataCount()
            widget:stopAllActions()
        end
    end

    widget:addTouchEventListener(listener)
end

function QuanmPKPrepareDlg:getReclaimItem()
    local petret = {}
    for _, pet in pairs(PetMgr.pets) do
        if pet:queryInt('rank') == Const.PET_RANK_ELITE or pet:queryInt('rank') == Const.PET_RANK_EPIC then
            table.insert(petret, {isPet = true, name = pet:queryBasic("name"), icon = pet:queryBasicInt("portrait"), level = pet:queryBasicInt("level"), id = pet:getId()})
        end
    end

    local allItems = InventoryMgr:getAllBagItems()
    local equips = {}
    local items = {}
    local changeCards = {}
    for _, v in pairs(allItems) do
        if v.item_type == ITEM_TYPE.EQUIPMENT then
            table.insert(equips, {name = v.name, level = v.req_level, icon = v.icon, id = v.item_unique, isItem = true, pos = v.pos})
        elseif v.item_type == ITEM_TYPE.ARTIFACT then
            table.insert(equips, {name = v.name, level = v.level, icon = v.icon, id = v.item_unique, isItem = true, pos = v.pos})
        elseif v.item_type == ITEM_TYPE.CHANGE_LOOK_CARD or v.name == CHS[4200378] then
            -- 变身卡和九曲玲珑笔
            table.insert(changeCards, {name = v.name, level = v.level, icon = v.icon, id = v.item_unique, isItem = true, pos = v.pos})
        else
            table.insert(items, {name = v.name, level = v.level, icon = v.icon, id = v.item_unique, isItem = true, pos = v.pos, amount = v.amount})
        end
    end

    local storeCards = StoreMgr:getChangeCard()
    for _, card in pairs(storeCards) do
        table.insert(changeCards, {name = card.name, level = card.level, icon = card.icon, id = card.item_unique, isItem = true, pos = card.pos})
    end

    return {["EquipCheckBox"] = equips, ["PetCheckBox"] = petret, ["ItemCheckBox"] = items, ["ChangeCardCheckBox"] = changeCards}
end

-- 回收的checkBox
function QuanmPKPrepareDlg:onReclaimCheckBox(sender, eventType)
    local type = sender:getName()
    local listInfos = self.reclaimItem[type]

    local listCtrl = self:resetListView("ReclaimItemListView")
    self.selectItem = nil

    local amountRow = math.ceil(#listInfos / 2)
    for i = 1, amountRow do
        local panel = self.itemOneRowPanel:clone()
        local leftPanel = self:getControl("ItemPetPanel_1", nil, panel)
        self:setUnitItemPanel(listInfos[(i - 1) * 2 + 1],leftPanel)
        local rightPanel = self:getControl("ItemPetPanel_2", nil, panel)
        self:setUnitItemPanel(listInfos[(i - 1) * 2 + 2],rightPanel)

        listCtrl:pushBackCustomItem(panel)
    end
    listCtrl:doLayout()
    listCtrl:refreshView()
end

-- 重置角色
function QuanmPKPrepareDlg:onResetUserPoint(sender, eventType)
    self:setCtrlVisible("ChoseMenuPanel", true)
end

-- 玩家重置加点
function QuanmPKPrepareDlg:onResetAttribPoint(sender, eventType)
    QuanminPKMgr:cmdResetPoint(Me:getId())
end

-- 玩家仙魔转换
function QuanmPKPrepareDlg:onChangeUpgradeButton(sender, eventType)
    QuanminPKMgr:cmdChangeUpgrade()
end

function QuanmPKPrepareDlg:setCheckState(panelName, isOk)
    local panel = self:getControl(panelName, nil, "CheckPanel")
    if isOk then
        self:setImagePlist("Statusimage", ResMgr.ui.is_yes, panel)
    else
        self:setImagePlist("Statusimage", ResMgr.ui.is_no, panel)
    end
end

-- 一键检测
function QuanmPKPrepareDlg:onCheckButton(sender, eventType)
    local isGoOnEquip = true
    local checkPanel = self:getControl("CheckPanel")

    local equipPanel = self:getControl("EquipPanel", nil, checkPanel)
    -- 属性点检测
    if Me:queryInt("attrib_point") > 0 then
        self:setLabelText("InfoLabel", CHS[4100517], equipPanel)
        self:setCheckState("EquipPanel", false)
        isGoOnEquip = false
    end

    -- 相性点检测
    if isGoOnEquip and Me:queryInt("polar_point") > 0 then
        self:setLabelText("InfoLabel", CHS[4100518], equipPanel)
        self:setCheckState("EquipPanel", false)
        isGoOnEquip = false
    end

    -- 仙魔点检测
    if isGoOnEquip and Me:queryInt("upgrade/total") > 0 then
        self:setLabelText("InfoLabel", CHS[7120136], equipPanel)
        self:setCheckState("EquipPanel", false)
        isGoOnEquip = false
    end

    -- 装备检测
    if isGoOnEquip then
        local equipPoses = {1, 2, 3, 10}
        for _, pos in pairs(equipPoses) do
            local equip = InventoryMgr:getItemByPos(pos)
            if not equip then
                self:setLabelText("InfoLabel", CHS[4100519], equipPanel)
                self:setCheckState("EquipPanel", false)
                isGoOnEquip = false
            end
        end
    end

    -- 法宝
    local artifact = InventoryMgr:getItemByPos(EQUIP.ARTIFACT)
    if not artifact and isGoOnEquip then
        self:setLabelText("InfoLabel", CHS[4100520], equipPanel)
        self:setCheckState("EquipPanel", false)
        isGoOnEquip = false
    end

    -- 首饰检测
    local jewelryPoses = {4, 5, 6, 7}
    if isGoOnEquip then
        for _, pos in pairs(jewelryPoses) do
            local equip = InventoryMgr:getItemByPos(pos)
            if not equip then
                self:setLabelText("InfoLabel", CHS[4100521], equipPanel)
                self:setCheckState("EquipPanel", false)
                isGoOnEquip = false
            end
        end
    end

    -- 角色检测完成
    if isGoOnEquip then
        self:setLabelText("InfoLabel", CHS[4200326], equipPanel)
        self:setCheckState("EquipPanel", true)
    end

    local fightPet = PetMgr:getFightPet()
    local robPet = PetMgr:getRobPet()
    local isGoOnPet = true
    local petPanel = self:getControl("PetPanel", nil, checkPanel)
    -- 参战、掠阵检测
    if not fightPet or not robPet then
        self:setLabelText("InfoLabel", CHS[4100522], petPanel)
        self:setCheckState("PetPanel", false)
        isGoOnPet = false
    end

    -- 参战、掠阵检测 属性点
    if isGoOnPet and fightPet and fightPet:queryInt("attrib_point") > 0 then
        self:setLabelText("InfoLabel", CHS[4100523], petPanel)
        self:setCheckState("PetPanel", false)
        isGoOnPet = false
    end
    if isGoOnPet and robPet and robPet:queryInt("attrib_point") > 0 then
        self:setLabelText("InfoLabel", CHS[4100524], petPanel)
        self:setCheckState("PetPanel", false)
        isGoOnPet = false
    end

    -- 参战、掠阵检测 抗性点
    if isGoOnPet and fightPet and fightPet:queryInt("resist_point") > 0 then
        self:setLabelText("InfoLabel", CHS[4100525], petPanel)
        self:setCheckState("PetPanel", false)
        isGoOnPet = false
    end
    if isGoOnPet and robPet and robPet:queryInt("resist_point") > 0 then
        self:setLabelText("InfoLabel", CHS[4100526], petPanel)
        self:setCheckState("PetPanel", false)
        isGoOnPet = false
    end

    -- 顿悟技能检测
    if isGoOnPet and fightPet and fightPet then
        local fightSkill = SkillMgr:getPetDunWuSkills(fightPet:getId()) or {}
        local robSkill = SkillMgr:getPetDunWuSkills(robPet:getId()) or {}
        if #fightSkill < 2 or #robSkill < 2 then
            self:setLabelText("InfoLabel", CHS[4100527], petPanel)
            self:setCheckState("PetPanel", false)
            isGoOnPet = false
        end
    end

    -- 骑乘坐骑检测
    if isGoOnPet and PetMgr:getRideId() == 0 then
        self:setLabelText("InfoLabel", CHS[7180002], petPanel)
        self:setCheckState("PetPanel", false)
        isGoOnPet = false
    end

    -- 宠物检测完毕
    if isGoOnPet then
        self:setLabelText("InfoLabel", CHS[4200326], petPanel)
        self:setCheckState("PetPanel", true)
    end

    local isGoOnStone = true
    local stonePanel = self:getControl("StonePanel", nil, checkPanel)
    -- 妖石检测
    if not fightPet or fightPet:queryBasicInt("stone_num") < 3 or not robPet or robPet:queryBasicInt("stone_num") < 3 then
        self:setCheckState("StonePanel", false)
        self:setLabelText("InfoLabel", CHS[4100528], stonePanel)
        isGoOnStone = false
    end
    if isGoOnStone then
        self:setCheckState("StonePanel", true)
        self:setLabelText("InfoLabel", CHS[4200326], stonePanel)
    end


    local isGoOnBook = true
    local bookPanel = self:getControl("GodBookPanel", nil, checkPanel)
    -- 天书检测
    if not fightPet or fightPet:queryBasicInt("god_book_skill_count") < 3 or not robPet or robPet:queryBasicInt("god_book_skill_count") < 3 then
        self:setCheckState("GodBookPanel", false)
        self:setLabelText("InfoLabel", CHS[4100529], bookPanel)
        isGoOnBook = false
    end

    if isGoOnBook then
        self:setLabelText("InfoLabel", CHS[4200326], bookPanel)
        self:setCheckState("GodBookPanel", true)
    end


    local isGoOnDrug = true
    local drugPanel = self:getControl("DrugPanel", nil, checkPanel)
    -- 药品
    local amount = InventoryMgr:getAmountByName(CHS[5000055])
    if amount < 1 then
        self:setCheckState("DrugPanel", false)
        self:setLabelText("InfoLabel", CHS[4100530], drugPanel)
        isGoOnDrug = false
    end
    local amount = InventoryMgr:getAmountByName(CHS[5000056])
    if isGoOnDrug and amount < 1 then
        self:setCheckState("DrugPanel", false)
        self:setLabelText("InfoLabel", CHS[4100531], drugPanel)
        isGoOnDrug = false
    end

    if isGoOnDrug then
        self:setLabelText("InfoLabel", CHS[4200326], drugPanel)
        self:setCheckState("DrugPanel", true)
    end

    local isGoOnCard = true
    -- 变身卡
    local cardPanel = self:getControl("ChangeCardPanel", nil, checkPanel)
    if self.reclaimItem and not QuanmPKPrepareDlg:haveChangeItem(self.reclaimItem.ChangeCardCheckBox, true)
        and not TaskMgr:getTaskByName(CHS[4200010]) then
        self:setCheckState("ChangeCardPanel", false)
        self:setLabelText("InfoLabel", CHS[4100532], cardPanel)
        isGoOnCard = false
    end

    -- 九曲玲珑笔
    if self.reclaimItem and not QuanmPKPrepareDlg:haveChangeItem(self.reclaimItem.ChangeCardCheckBox, false)
        and not TaskMgr:getTaskByName(CHS[4200383]) then
        self:setCheckState("ChangeCardPanel", false)
        self:setLabelText("InfoLabel", CHS[7120138], cardPanel)
        isGoOnCard = false
    end

    if isGoOnCard then
        self:setLabelText("InfoLabel", CHS[4200326], cardPanel)
        self:setCheckState("ChangeCardPanel", true)
    end

    if isGoOnCard and isGoOnDrug and isGoOnBook and isGoOnStone and isGoOnPet and isGoOnEquip then
    -- 检测完成
        gf:ShowSmallTips(CHS[4100533])
    end
end

-- 检查items中是否有九曲玲珑笔和变身卡
-- isCard : true 检查变身卡 false 检查九曲玲珑笔
function QuanmPKPrepareDlg:haveChangeItem(items, isCard)
    if not items then return false end
    for i = 1, #items do
        if not isCard and items[i] and items[i].name == CHS[4200378] then
            return true
        end

        if isCard and items[i] and string.match(items[i].name, CHS[7120137]) then
            return true
        end
    end

    return false
end

function QuanmPKPrepareDlg:MSG_PKM_GEN_PET(data)
    self:setReadyPetList()
end

function QuanmPKPrepareDlg:MSG_PKM_RECYCLE_DONE(data)
    DlgMgr:closeDlg("ConfirmDlg")
    self.reclaimItem = self:getReclaimItem()
    self.selectReadyPet = nil
    self.selectItem = nil
  --  self.makeEquip = {}
    if self.curMenu ~= CHS[4100505] then return end

    self:onReclaimCheckBox(self:getControl(self.radioGroup:getSelectedRadioName()))
end

return QuanmPKPrepareDlg
