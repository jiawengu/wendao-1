-- MarketSearchDlg.lua
-- Created by zhengjh Aug/21/2015
-- 搜索

---- 因为策划把属性面板和装备搜素分成两个不一样的东西(之前是一样，所以后面有加new命名都是装备搜索的)

local MarketSearchDlg = Singleton("MarketSearchDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local MARGIN_ITEM = 10

local WORD_LIMIT = 10

-- 普遍宠物列表信息
local normalPetList = require(ResMgr:getCfgPath('NormalPetList.lua'))

-- 变异宠物列表信息
local elitePetList = require(ResMgr:getCfgPath('VariationPetList.lua'))

-- 神兽宠物列表信息
local epicPetList = require (ResMgr:getCfgPath("EpicPetList.lua"))

-- 其他宠物列表信息
local otherPetList = require(ResMgr:getCfgPath('OtherPetList.lua'))

-- 精怪宠物列表
local jingguaiPetList = require(ResMgr:getCfgPath('JingGuai.lua'))

-- 纪念宠物列表
local jinianPetList = require(ResMgr:getCfgPath("JinianPetList.lua"))

local MAX_INPUT_NUM = 2000000000
local INPUT_PANEL_NUM = 48
-- 48为装备强化

local EQUIP_REBUILD_LEVEL = 48

local CEHCKBOX_TO_PANEL =
{
    ["NormalSearchCheckBox"] = "NormalSearchPanel",
    ["EquipmentSearchCheckBox"] = "NewEquipmentSearchPanel",
    ["JewelrySearchCheckBox"] = "JewelrySearchPanel",
    ["PetSearchCheckBox"] = "PetSearchPanel",
    ["AttributeSearchCheckBox"] = "EquipmentSearchPanel",
}

local equip_config =
{
    [CHS[3003023]] = EQUIP_TYPE.WEAPON,
    [CHS[3003024]] = EQUIP_TYPE.WEAPON,
    [CHS[3003025]] = EQUIP_TYPE.WEAPON,
    [CHS[3003026]] = EQUIP_TYPE.WEAPON,
    [CHS[3003027]] = EQUIP_TYPE.WEAPON,
    [CHS[3003028]] = EQUIP_TYPE.HELMET,
    [CHS[3003029]] = EQUIP_TYPE.HELMET,
    [CHS[3003030]] = EQUIP_TYPE.ARMOR,
    [CHS[3003031]] = EQUIP_TYPE.ARMOR,
    [CHS[3003032]] = EQUIP_TYPE.BOOT,
    [CHS[3003033]] = EQUIP_TYPE.WEAPON,
    [CHS[3003034]] = EQUIP_TYPE.ARMOR,
    [CHS[3003035]] = EQUIP_TYPE.HELMET,
    [CHS[3003036]] = EQUIP_TYPE.BOOT,
    [CHS[6400000]] = EQUIP_TYPE.WEAPON,
}

--  首饰属性的条数
local JEWELRY_ATTRIB_MAX_NUM = 5

-- 最后一个装备搜索属性在attributeTag中的下标
local LAST_EQUIP_ATTR_INDEX = 8

-- 属性输入框：装备属性名(7-20)，首饰控件名(21-30)，修改json或代码时需要注意
-- 装备搜索属性配置、首饰搜索属性配置放在一起
local attributeTag =
{
        [1] = {pro = "prop", name = CHS[6400010]}, -- 属性一
        [2] = {pro = "prop", name = CHS[6400011]}, -- 属性二
        [3] = {pro = "prop", name = CHS[6400012]}, -- 属性三
        [4] = {pro = "prop", name = CHS[6400013]}, -- 属性四
        [5] = {pro = "prop", name = CHS[6400014]},      -- 属性五
        [6] = {pro = "prop4", name = CHS[3003040]}, -- 绿属性
        [7] = {pro = "prop4", name = CHS[3003040]}, -- 绿属性
        [8] = {pro = "prop_resonance", name = CHS[7100200]},   -- 共鸣属性
        [9] = {pro = "prop", name = CHS[6400010]}, -- 属性一
        [10] = {pro = "prop", name = CHS[6400011]}, -- 属性二
        [11] = {pro = "prop", name = CHS[6400012]}, -- 属性三
        [12] = {pro = "prop", name = CHS[6400013]}, -- 属性四
        [13] = {pro = "prop", name = CHS[6400014]}, -- 属性五
}

local ChangeType = {
    [CHS[4200260]] = EQUIP_TYPE.NECKLACE,
    [CHS[4200259]] = EQUIP_TYPE.BALDRIC,
    [CHS[4200261]] = EQUIP_TYPE.WRIST,
}

-- 装备，首饰，黑水晶搜索等级配置
local EQUIP_SEARCH_LEVELS = {CHS[3003050], CHS[3003051], CHS[6000397], CHS[6000398], CHS[6000399], CHS[6000400], CHS[4200348], CHS[7100056]}
local JEWELRY_LEVELS = {CHS[4200403], CHS[3003053], CHS[4200350], CHS[4200351], CHS[4200349], CHS[7100057]}
local ATTRIB_SEARCH_LEVELS = {CHS[3003050], CHS[3003051], CHS[3003052], CHS[3003053], CHS[6000395], CHS[6000396], CHS[4200349], CHS[7100057]}

local search_cost = 100000


local INPUT_MAX = {
    [42] = 12,                      -- 强化
    [45] = 12,
    [46] = 24,
    [47] = 24,
    [48] = 12,                  -- 装备强化
}

function MarketSearchDlg:init()
    self:bindListener("ClearButton", self.onClearButton)
    self:bindListener("EquipSearchNameButton", self.onEquipSearchNameButton)
    self:bindListener("JewelrySearchNameButton", self.onJewelrySearchNameButton)
    self:bindListener("JewelrySearchLevelButton", self.onJewelrySearchLevelButton)
    --self:bindListener("JewelryAttributeButton", self.onJewelryAttributeButton)
    self:bindListener("EquipSearchLevelButton", self.onNewEquipSearchLevelButton)
    self:bindListener("AttributeButton", self.onAttributeButton)
    self:bindListener("AttributeMaxButton", self.onAttributeMaxButton)
    self:bindListener("PetSearchTypeButton", self.onPetSearchTypeButton)
    self:bindListener("PetSearchNameButton", self.onPetSearchNameButton)
    self:bindListener("PetSearchSkillButton", self.onPetSearchSkillButton)
    self:bindListener("AttributeSearchNameButton", self.onEquipSearchNameButton)
    self:bindListener("AttributeSearchLevelButton", self.onEquipSearchLevelButton)
    self:bindListener("InfoButton", self.onInfoButton)

    self:bindCheckBoxListener("FlyCheckBox", self.onFlyCheckBox)
    self:bindCheckBoxListener("DianhuaCheckBox", self.onFlyCheckBox)
    self:bindCheckBoxListener("YuhuaCheckBox", self.onFlyCheckBox)


    self:bindListener("ResetButton", self.onHuanhuaTypeResetButton, "SearchHuanhuaPanel")
    self:bindListener("HuanhuaTypeButton", self.onHuanhuaTypeButton)
    self:bindListener("HuanhuaTimeButton", self.onHuanhuaTimeButton)

    self:bindListViewListener("MatchPopUpListView", self.onSelectMatchPopUpListView)
    self:bindListViewListener("MatchPopUpListView", self.onSelectMatchPopUpListView)

    self:setCtrlVisible("NormalSearchPanel", false)      --  普通搜索
    self:setCtrlVisible("NewEquipmentSearchPanel", false)      --  装备搜索
    self:setCtrlVisible("JewelrySearchPanel", false)      --  首饰搜索
    self:setCtrlVisible("PetSearchPanel", false)      --  宠物搜索
    self:setCtrlVisible("EquipmentSearchPanel", false)      --  黑水晶搜索
    self:setCtrlVisible("PlayerSearchPanel", false)      --  角色搜索

    self:setCtrlVisible("SearchDevelopPanel", false)      -- 宠物搜索-强化，默认隐藏

    self.equipSearchTable = {}
    self.petSearchTable = {}
    self.checkBoxTable = {}

    --self:selectCheckBoxByName("NormalSearchCheckBox")

    -- 普通搜索单元格
    self.normalSearchCell = self:getControl("NormalUnitPanel")
    self.normalSearchCell:retain()
    self.normalSearchCell:removeFromParent()
    self.normalSearchCell:setVisible(true)

    -- 搜索单元格
    self.searchCell = self:getControl("UnitPanel")
    self.searchCell:retain()
    self.searchCell:removeFromParent()

    local searchCtrl = self:getControl("SearchTextField")
    searchCtrl:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    searchCtrl:setColor(COLOR3.GRAY)

    local searchCtrl = self:getControl("SearchTextField")
    searchCtrl:addEventListener(function(sender, eventType)
        if ccui.TextFiledEventType.attach_with_ime == eventType then

        elseif ccui.TextFiledEventType.insert_text == eventType then
            self:displaySearchList()
            local restCtrl = self:getControl("ClearButton")
            restCtrl:setVisible(true)
            sender:setColor(COLOR3.TEXT_DEFAULT)

            local str = sender:getStringValue()
            if gf:getTextLength(str) > WORD_LIMIT * 2 then
                str = gf:subString(str, WORD_LIMIT * 2)
                sender:setText(str)
                gf:ShowSmallTips(CHS[5400041])
            end
        elseif ccui.TextFiledEventType.delete_backward == eventType then
            local str = sender:getStringValue()
            if "" ~= str then
                self:displaySearchList()
                sender:setColor(COLOR3.TEXT_DEFAULT)
            else
                local delCtrl = self:getControl("SearchTextField")
                local restCtrl = self:getControl("ClearButton")
                self:setCtrlVisible("MatchPopUpPanel", false)
                restCtrl:setVisible(false)
                delCtrl:setColor(COLOR3.GRAY)
            end
        end
    end)


    self:initCheckBox()

    -- 初值历史列表
    self:initHistoryList()

    -- 初值化搜索金钱
    self:initSearchCash()

    -- 绑定共有的控件
    self:bindPublicCtrl()

    -- 绑定数字键盘
    self:initNumKeyBord()

    -- 绑定搜索悬浮时间
    self:bindTipPanelTouchEvent()

    -- 初值化装备具体属性列表
    self:initEquipSearchList()

    -- 初值交易类型ui差异性
    self:setTradeTypeUI()
    self:setAllHookMsgs()

    self.firstEquip = true
    self.firstJewelry = true
    self.firstPlayer = true
    self:bindEquipListView()

    self:setLastSearchData()

    -- 暂时屏蔽共鸣属性
    if DistMgr:needIgnoreGongming() then
        local listView = self:getControl("SearchAttributeListView", nil, "NewEquipmentSearchPanel")
        listView:removeChildByName("SearchAttributeUintPanel8")
    end
end

function MarketSearchDlg:getCheckToPanelMap()
    return CEHCKBOX_TO_PANEL
end

-- 隐藏部分CheckBox，和修改名字
function MarketSearchDlg:initCheckBox()
    -- 隐藏不用的，显示可用的
    self:setCtrlVisible("NormalSearchCheckBox", true)      --  普通搜索
    self:setCtrlVisible("EquipmentSearchCheckBox", true)      --  装备搜索
    self:setCtrlVisible("JewelrySearchCheckBox", true)      --  首饰搜索
    self:setCtrlVisible("PetSearchCheckBox", true)      --  宠物搜索
    self:setCtrlVisible("AttributeSearchCheckBox", true)      --  黑水晶搜索
    self:setCtrlVisible("PlayerSearchCheckBox", false)      --  角色搜索

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"NormalSearchCheckBox", "EquipmentSearchCheckBox", "JewelrySearchCheckBox", "PetSearchCheckBox", "AttributeSearchCheckBox"}, self.onCheckBox)
end

function MarketSearchDlg:bindEquipListView()
    local listView = self:getControl("SearchAttributeListView", nil, "NewEquipmentSearchPanel")
    local contentLayer = listView:getInnerContainer()

    local function listener(sender , eventType)
        if eventType == ccui.ScrollviewEventType.scrolling then
            local offset = listView:getContentSize().height - contentLayer:getContentSize().height
            local  y = listView:getInnerContainer():getPositionY()
            if  y > 0 - MARGIN_ITEM then
                if not self.firstEquip then
                    self:setCtrlVisible("DownImage", false, "NewEquipmentSearchPanel")
                end

                self.firstEquip = false
            else
                self:setCtrlVisible("DownImage", true, "NewEquipmentSearchPanel")
            end
        end
    end

    listView:addScrollViewEventListener(listener)

    local listView = self:getControl("SearchAttributeListView", nil, "JewelrySearchPanel")
    local contentLayer = listView:getInnerContainer()

    local function listener(sender , eventType)
        if eventType == ccui.ScrollviewEventType.scrolling then
            local offset = listView:getContentSize().height - contentLayer:getContentSize().height
            local  y = listView:getInnerContainer():getPositionY()
            if  y > 0 - MARGIN_ITEM then
                if not self.firstJewelry then
                    self:setCtrlVisible("DownImage", false, "JewelrySearchPanel")
                end

                self.firstJewelry = false
            else
                self:setCtrlVisible("DownImage", true, "JewelrySearchPanel")
            end
        end
    end

    listView:addScrollViewEventListener(listener)

    local listView = self:getControl("SearchAttributeListView", nil, "PlayerSearchPanel")
    local contentLayer = listView:getInnerContainer()

    local function listener(sender , eventType)
        if eventType == ccui.ScrollviewEventType.scrolling then
            local offset = listView:getContentSize().height - contentLayer:getContentSize().height
            local  y = listView:getInnerContainer():getPositionY()
            if  y > 0 - MARGIN_ITEM then
                if not self.firstPlayer then
                    self:setCtrlVisible("DownImage", false, "PlayerSearchPanel")
                end

                self.firstPlayer = false
            else
                self:setCtrlVisible("DownImage", true, "PlayerSearchPanel")
            end
        end
    end

    listView:addScrollViewEventListener(listener)

    local listView = self:getControl("SearchAttributeListView", nil, "PetSearchPanel")
    local contentLayer = listView:getInnerContainer()

    local function listener(sender , eventType)
        if eventType == ccui.ScrollviewEventType.scrolling then
            local offset = listView:getContentSize().height - contentLayer:getContentSize().height
            local  y = listView:getInnerContainer():getPositionY()
            if  y > 0 - MARGIN_ITEM then
                if not self.firstPlayer then
                    self:setCtrlVisible("DownImage", false, "PetSearchPanel")
                end

                self.firstPlayer = false
            else
                self:setCtrlVisible("DownImage", true, "PetSearchPanel")
            end
        end
    end

    listView:addScrollViewEventListener(listener)
end

function MarketSearchDlg:setTradeTypeUI()
    -- 隐藏属性搜索标签页
    self:setCtrlVisible("AttributeSearchCheckBox", true)
end

-- 设置所有hook消息
function MarketSearchDlg:setAllHookMsgs()
    self:hookMsg("MSG_MARKET_SEARCH_RESULT")
end

function MarketSearchDlg:cleanup()
    self:releaseCloneCtrl("normalSearchCell")
    self:releaseCloneCtrl("searchCell")
    self:saveLastSearchData()
    self.checkBoxTable = {}
    self:clearClassInfo()
    self:clearInputVuale()
    self:cleanupForChild()
end

function MarketSearchDlg:cleanupForChild()
end

-- 绑定共有的控件
function MarketSearchDlg:bindPublicCtrl()
    local map = self:getCheckToPanelMap()
    for k, v in pairs(map) do
        local panel = self:getControl(v)
        self:bindListener("SearchButton", self.onSearchButton, panel)
        self:bindListener("ResetAllButton", self.onResetButton, panel)
        self.checkBoxTable[k] = RadioGroup.new()
        self.checkBoxTable[k]:setItems(self, {"CheckBox1", "CheckBox2"}, nil, panel)
        self.checkBoxTable[k]:selectRadio(1)
    end
end

-- 绑定搜索框关闭时间
function MarketSearchDlg:bindTipPanelTouchEvent()
    local tipPanel = self:getControl("TipPanel")
    local layout = ccui.Layout:create()
    layout:setContentSize(tipPanel:getContentSize())
    layout:setPosition(tipPanel:getPosition())
    layout:setAnchorPoint(tipPanel:getAnchorPoint())

    local  function touch(touch, event)
        local rect = self:getBoundingBoxInWorldSpace(tipPanel)
        local toPos = touch:getLocation()

        if not cc.rectContainsPoint(rect, toPos) and  tipPanel:isVisible() then
            tipPanel:setVisible(false)
            return true
        end
    end
    self.root:addChild(layout, 10, 1)

    gf:bindTouchListener(layout, touch)
end


-- 初值化装备具体属性列表
function MarketSearchDlg:initEquipSearchList()
    local equipPanel = self:getControl("NewEquipmentSearchPanel")

    for i = 1, LAST_EQUIP_ATTR_INDEX do
        local panel = self:getControl("SearchAttributeUintPanel" .. i, nil, equipPanel)
        panel:setTag(i)
        self:bindListener("SearchAttributeButton", self.onSearchAttributeButton, panel)
        self:bindListener("EquipMaxButton", self.onEquipMaxButton, panel)
        self:bindListener("ResetButton", self.onAttribResetButton, panel)
        local attributeBtn = self:getControl("SearchAttributeButton", nil, panel)
        attributeBtn:setTag(i)
        local maxBtn = self:getControl("EquipMaxButton", nil, panel)
        if maxBtn then maxBtn:setTag(i) end
        local attribResetBtn = self:getControl("ResetButton", nil, panel)
        attribResetBtn:setTag(i)
    end

    -- 初始化宠物搜索天技重设按钮
    local petSearchPanel = self:getControl("PetSearchPanel")
    local searchSkillPanel = self:getControl("SearchSkillPanel", nil, petSearchPanel)
    self:bindListener("ResetButton", self.onPetSkillResetButton, searchSkillPanel)

    -- 初始化属性搜索的属性重设按钮
    local equipmentSearchPanel = self:getControl("EquipmentSearchPanel")
    local searchAttributePanel = self:getControl("SearchAttributePanel", nil, equipmentSearchPanel)
    self:bindListener("ResetButton", self.onEquipmentSearchAttribResetButton, searchAttributePanel)

    -- 初始化首饰技能
    local equipPanel = self:getControl("JewelrySearchPanel")
    for i = 1, JEWELRY_ATTRIB_MAX_NUM do
        local panel = self:getControl("SearchAttributeUintPanel" .. i, nil, equipPanel)
        panel:setTag(i)
        self:bindListener("SearchAttributeButton", self.onJewelryAttributeButton, panel)
        self:bindListener("EquipMaxButton", self.onJewelryMaxButton, panel)
        self:bindListener("ResetButton", self.onJewelryResetButton, panel)
        local attributeBtn = self:getControl("SearchAttributeButton", nil, panel)
        attributeBtn:setTag(i)
        local maxBtn = self:getControl("EquipMaxButton", nil, panel)
        maxBtn:setTag(i)
        local attribResetBtn = self:getControl("ResetButton", nil, panel)
        attribResetBtn:setTag(i)
    end
end

-- 重置某个属性的输入数值
function MarketSearchDlg:resetAttibuteValue(panel, tag)
    local smaller, bigger
    if "EquipmentSearchCheckBox" == self.selectName then
        tag = tag or self.selectAttributeTag
        smaller = 7 + (tag - 1) * 2
    elseif "JewelrySearchCheckBox" == self.selectName then
        tag = tag or self.selectJewelryTag
        smaller = 21 + (tag - 1) * 2
    elseif "AttributeSearchCheckBox" == self.selectName then
        smaller = tag or 5
    else
        return
    end
    bigger = smaller + 1
    local imageSmaller = self:getControl("InputBKImage" .. smaller)
    local imageBigger = self:getControl("InputBKImage" .. bigger)
    self:setLabelText("Label", "", imageSmaller)
    self:setLabelText("Label", "", imageBigger)
    self.inputValueList[smaller] = nil
    self.inputValueList[bigger] = nil
    self:setCtrlVisible("Label2", true, imageSmaller)
    self:setCtrlVisible("Label2", true, imageBigger)
    if panel then
        self:updateLayout("SearchValuePanel", panel)
    end
end

-- 重置某个属性
function MarketSearchDlg:resetAttibuteName(panel)
    if not panel then return end
    local searchNamePanel = self:getControl("SearchAttributePanel", nil, panel)
    self:setLabelText("InputLabel", "", searchNamePanel)
    local valueInfoLabel = self:getControl("ValueInfoPanel", nil, panel)
    local infoLabel = self:getControl("InfoLabel", nil, valueInfoLabel)
    infoLabel:setString(CHS[3003046])
    self:updateLayout("ValueInfoPanel", panel)
end

function MarketSearchDlg:onJewelryResetButton(sender, eventType)
    local tag = sender:getTag()
    local listView = self:getControl("SearchAttributeListView", nil, "JewelrySearchPanel")
    local panel = listView:getChildByTag(tag)
    attributeTag[tag + LAST_EQUIP_ATTR_INDEX].attrib = nil
    attributeTag[tag + LAST_EQUIP_ATTR_INDEX].maxValue = nil
    attributeTag[tag + LAST_EQUIP_ATTR_INDEX].minValue = nil

    self:resetAttibuteName(panel)
    self:resetAttibuteValue(panel, tag)
end

function MarketSearchDlg:onAttribResetButton(sender, eventType)
    local tag = sender:getTag()
    local listView = self:getControl("SearchAttributeListView", nil, "NewEquipmentSearchPanel")
    local panel = listView:getChildByTag(tag)
    attributeTag[tag].attrib = nil
    attributeTag[tag].maxValue = nil
    attributeTag[tag].minValue = nil

    self:resetAttibuteName(panel)
    self:resetAttibuteValue(panel, tag)
end

function MarketSearchDlg:onPetSkillResetButton(sender, eventType)
    local petSearchPanel = self:getControl("PetSearchPanel")
    local searchSkillPanel = self:getControl("SearchSkillPanel", nil, petSearchPanel)
    self.petSearchTable.petSkill = nil
    self:setLabelText("InputLabel", "", searchSkillPanel)
    self:updateLayout("SearchSkillPanel",petSearchPanel)
end

function MarketSearchDlg:onEquipmentSearchAttribResetButton(sender, eventType)
    self.equipSearchTable.attrib = nil
    self.equipSearchTable.minValue = nil
    self.equipSearchTable.maxValue = nil

    local equipmentSearchPanel = self:getControl("EquipmentSearchPanel")
    self:resetAttibuteName(equipmentSearchPanel)
    self:resetAttibuteValue(equipmentSearchPanel)
end

function MarketSearchDlg:onSearchAttributeButton(sender, envetType)
    if not self.equipSearchTable.euipmentName  then
        gf:ShowSmallTips(CHS[3003041])
        return
    end

    if not self.equipSearchTable.level then
        gf:ShowSmallTips(CHS[3003042])
        return
    end

    local equipmentPanel = self:getControl("NewEquipmentSearchPanel")
    local searchNamePanel = self:getControl("SearchNamePanel", nil, equipmentPanel)
    local inputLabel = self:getControl("InputLabel", Const.UILabel, searchNamePanel)

    local equipName = inputLabel:getString()
    local equipType =  equip_config[equipName]
    self.equipSearchTable.equipType = equipType


	local tag = sender:getTag()
	self.selectAttributeTag = tag
	local list = nil
	if attributeTag[tag].pro == "prop4" then -- 绿属性
        if self.equipSearchTable.level and self.equipSearchTable.level < 70 then
	       gf:ShowSmallTips(CHS[3003043])
	       return
	    end

	    if tag == 6 then
	        if equipName == CHS[6400000] then
                list = EquipmentMgr:getAllWeaponSuitAttrib() -- 全部武器明属性
	        else
            list = EquipmentMgr:getAllSuitAttribByEquipType(equipName) -- 明属性
            end
        else
            list = EquipmentMgr:getSuitAttribute() -- 暗属性
        end
    elseif tag == LAST_EQUIP_ATTR_INDEX then -- 共鸣属性策划单独配置了一张表
        list = EquipmentMgr:getGongmingAttribList()
    else
        local excpetAttribute = {}
        for i = 1, 5 do
            for j = 1, 5 do
                if i ~= j and attributeTag[i].attrib and  attributeTag[j].attrib and attributeTag[i].attrib == attributeTag[j].attrib then
                    table.insert(excpetAttribute, attributeTag[i].attrib)
                end
            end
        end

        list = EquipmentMgr:getAllAddAttribByEquipType(equipType, excpetAttribute)
    end

    if list then
        self:initTipInfoPanle(list, self.searchCell, self.createNewEquipmentAttribCell)
    end
end

-- 装备搜索界面的属性单元格
function MarketSearchDlg:createNewEquipmentAttribCell(cell, data)
    self:setLabelText("Label", data, cell)

    local function lisnter()
        local listView = self:getControl("SearchAttributeListView", nil, "NewEquipmentSearchPanel")
        local panel = listView:getChildByTag(self.selectAttributeTag)
        local searchNamePanel = self:getControl("SearchAttributePanel", nil, panel)
        -- 如果当前选择的属性与之前的不一致，就重置属性值
        if self:getLabelText("InputLabel", searchNamePanel) ~= data then
            self:resetAttibuteValue()
        end
        self:setLabelText("InputLabel", data, searchNamePanel)
        self:setCtrlVisible("TipPanel", false)
        attributeTag[self.selectAttributeTag].attrib =  EquipmentMgr:getAttribChsOrEng(data)
        self:setEquipCellMaxMinValue(self.selectAttributeTag)
        self:updateLayout("SearchAttributePanel", panel)
        panel:requestDoLayout()
    end

    self:bindTouchEndEventListener(cell, lisnter, data)
end

-- 设置装备搜索界面的属性单元格的每个属性最大和最小值
function MarketSearchDlg:setEquipCellMaxMinValue(tag)
    local equip = {}
    equip.equip_type = self.equipSearchTable.equipType
    equip.req_level = self.equipSearchTable.level

    if tag > LAST_EQUIP_ATTR_INDEX then
        equip.equip_type = ChangeType[self.equipSearchTable.euipmentName]
        equip.req_level = self.equipSearchTable.level
    end

    local min, max = self:getMaxAndMinLevel(equip.req_level)

    if tag == 7 then -- 套装属性
        attributeTag[tag].minValue, attributeTag[tag].minLevelMaxValue = EquipmentMgr:getSuitMinAndMax(equip, attributeTag[tag].attrib)

        equip.req_level = max
        attributeTag[tag].maxLevelMinValue, attributeTag[tag].maxValue = EquipmentMgr:getSuitMinAndMax(equip, attributeTag[tag].attrib)
    elseif tag > LAST_EQUIP_ATTR_INDEX then
        -- 首饰属性搜索
        local tempEquip = gf:deepCopy(equip)
        tempEquip.req_level = 80
        attributeTag[tag].minValue = EquipmentMgr:getAttribMinValueByField(tempEquip, attributeTag[tag].attrib)
        attributeTag[tag].minLevelMaxValue = EquipmentMgr:getAttribMaxValueByField(tempEquip, attributeTag[tag].attrib)

        if equip.req_level == CHS[4200403] then
            local str = JEWELRY_LEVELS[#JEWELRY_LEVELS]
            equip.req_level = tonumber(string.match(str, CHS[6000401])) or tonumber(string.match(str, CHS[3003054]))
        end
        attributeTag[tag].maxLevelMinValue = EquipmentMgr:getAttribMinValueByField(equip, attributeTag[tag].attrib)
        attributeTag[tag].maxValue = EquipmentMgr:getAttribMaxValueByField(equip, attributeTag[tag].attrib)
    else
        attributeTag[tag].minValue = EquipmentMgr:getAttribMinValueByField(equip, attributeTag[tag].attrib)
        attributeTag[tag].minLevelMaxValue = EquipmentMgr:getAttribMaxValueByField(equip, attributeTag[tag].attrib)

        equip.req_level = max
        attributeTag[tag].maxLevelMinValue = EquipmentMgr:getAttribMinValueByField(equip, attributeTag[tag].attrib)
        attributeTag[tag].maxValue = EquipmentMgr:getAttribMaxValueByField(equip, attributeTag[tag].attrib)
    end

    local listView = self:getControl("SearchAttributeListView", nil, "NewEquipmentSearchPanel")
    local panel = listView:getChildByTag(tag)
    if tag > LAST_EQUIP_ATTR_INDEX then
        listView = self:getControl("SearchAttributeListView", nil, "JewelrySearchPanel")
        panel = listView:getChildByTag(tag - LAST_EQUIP_ATTR_INDEX)
    end

    local valueInfoLabel = self:getControl("ValueInfoPanel", nil, panel)
    local infoLabel = self:getControl("InfoLabel", nil, valueInfoLabel)

    if EquipmentMgr:isJewelry(equip) then
        infoLabel:setString(string.format(CHS[3003044], (attributeTag[tag].minValue or ""), (attributeTag[tag].maxValue or "")))
    else
        if min == max then
            infoLabel:setString(string.format(CHS[3003044], (attributeTag[tag].minValue or ""), (attributeTag[tag].maxValue or "")))
        else
            infoLabel:setString(string.format(CHS[6600001], (attributeTag[tag].minValue or ""), (attributeTag[tag].maxLevelMinValue or ""),
            (attributeTag[tag].minLevelMaxValue or ""), (attributeTag[tag].maxValue or "")))
        end
    end

    self:updateLayout("ValueInfoPanel", panel)
end

function MarketSearchDlg:getMaxAndMinLevel(level)
    local levelStr =  MarketMgr:getEquipLevelStr(level)
    local min, max = 0

    if string.match(levelStr, CHS[6600000]) then -- 等级段
        min, max = string.match(levelStr, CHS[6600000])
    else
        min = level
        max = level
    end

    return tonumber(min), tonumber(max)
end

function MarketSearchDlg:onJewelryMaxButton(sender, envetType)
    local tag = sender:getTag()

    if not attributeTag[tag + LAST_EQUIP_ATTR_INDEX].attrib then
        gf:ShowSmallTips(CHS[3003045])
        return
    end

    local listView = self:getControl("SearchAttributeListView", nil, "JewelrySearchPanel")
    local panel = listView:getChildByTag(tag)
    local searchValuePanel = self:getControl("SearchValuePanel", nil, panel)

    local inputTag = (tag + 7) * 2 + 6
    self.inputValueList[inputTag] = attributeTag[tag + LAST_EQUIP_ATTR_INDEX].maxValue
    self:setInputLabelValue(inputTag, attributeTag[tag + LAST_EQUIP_ATTR_INDEX].maxValue)
    self.inputValueList[inputTag -1] = attributeTag[tag + LAST_EQUIP_ATTR_INDEX].maxValue
    self:setInputLabelValue(inputTag - 1 , attributeTag[tag + LAST_EQUIP_ATTR_INDEX].maxValue)

    local input5Panel = self:getControl("InputBKImage"..(inputTag -1))
    self:setCtrlVisible("Label2", false, input5Panel)
    local input6Panel = self:getControl("InputBKImage"..inputTag)
    self:setCtrlVisible("Label2", false, input6Panel)
end

function MarketSearchDlg:onEquipMaxButton(sender, envetType)
    local tag = sender:getTag()

    if not attributeTag[tag].attrib then
        gf:ShowSmallTips(CHS[3003045])
        return
    end

    local listView = self:getControl("SearchAttributeListView", nil, "NewEquipmentSearchPanel")
    local panel = listView:getChildByTag(tag)
    local searchValuePanel = self:getControl("SearchValuePanel", nil, panel)

    local inputTag = tag * 2 + 6
    self.inputValueList[inputTag] = attributeTag[tag].maxValue
    self:setInputLabelValue(inputTag, attributeTag[tag].maxValue)
    self.inputValueList[inputTag -1] = attributeTag[tag].minLevelMaxValue
    self:setInputLabelValue(inputTag - 1 , attributeTag[tag].minLevelMaxValue)

    local input5Panel = self:getControl("InputBKImage"..(inputTag -1))
    self:setCtrlVisible("Label2", false, input5Panel)
    local input6Panel = self:getControl("InputBKImage"..inputTag)
    self:setCtrlVisible("Label2", false, input6Panel)
end

function MarketSearchDlg:clearJewelryAttibuteSearchInfo()
    local listView = self:getControl("SearchAttributeListView", nil, "JewelrySearchPanel")

    self:clearInputVuale()

    for i = 1, JEWELRY_ATTRIB_MAX_NUM do
        local panel = listView:getChildByTag(i)
        attributeTag[i + LAST_EQUIP_ATTR_INDEX].attrib = nil
        attributeTag[i + LAST_EQUIP_ATTR_INDEX].maxValue = nil
        attributeTag[i + LAST_EQUIP_ATTR_INDEX].minValue = nil
        local searchNamePanel = self:getControl("SearchAttributePanel", nil, panel)
        self:setLabelText("InputLabel", "", searchNamePanel)
        local valueInfoLabel = self:getControl("ValueInfoPanel", nil, panel)
        local infoLabel = self:getControl("InfoLabel", nil, valueInfoLabel)
        infoLabel:setString(CHS[3003046])
        self:updateLayout("ValueInfoPanel", panel)
    end

    self.selectAttributeTag = nil
end

function MarketSearchDlg:clearNewEquipAttibuteSearchInfo()
    local listView = self:getControl("SearchAttributeListView", nil, "NewEquipmentSearchPanel")

    self:clearInputVuale()

    for i = 1, LAST_EQUIP_ATTR_INDEX do
        local panel = listView:getChildByTag(i)
        if attributeTag[i] then
            attributeTag[i].attrib = nil
            attributeTag[i].maxValue = nil
            attributeTag[i].minValue = nil
        end

        local searchNamePanel = self:getControl("SearchAttributePanel", nil, panel)
        self:setLabelText("InputLabel", "", searchNamePanel)
        local valueInfoLabel = self:getControl("ValueInfoPanel", nil, panel)
        local infoLabel = self:getControl("InfoLabel", nil, valueInfoLabel)
        if infoLabel then
            infoLabel:setString(CHS[3003046])
        end

        self:updateLayout("ValueInfoPanel", panel)
    end

    self.selectAttributeTag = nil
end


function MarketSearchDlg:clearJewelrySearchInfo()
    self:clearJewelryAttibuteSearchInfo()

    local equipmentPanel = self:getControl("JewelrySearchPanel")
    local searchNamePanel = self:getControl("JewelrySearchLevelPanel", nil, equipmentPanel)
    self:setLabelText("InputLabel", "", searchNamePanel)

    local searchNamePanel = self:getControl("JewelrySearchNamePanel", nil, equipmentPanel)
    self:setLabelText("InputLabel", "", searchNamePanel)

    self.equipSearchTable = {}
    self:clearInputVuale()
    self:onClearButton()
end

function MarketSearchDlg:clearNewEquipSearchInfo()
    self:clearNewEquipAttibuteSearchInfo()

    local equipmentPanel = self:getControl("NewEquipmentSearchPanel")
    local searchNamePanel = self:getControl("SearchLevelPanel", nil, equipmentPanel)
    self:setLabelText("InputLabel", "", searchNamePanel)

    local searchNamePanel = self:getControl("SearchNamePanel", nil, equipmentPanel)
    self:setLabelText("InputLabel", "", searchNamePanel)

    self.equipSearchTable = {}
    self:clearInputVuale()
    self:onClearButton()
end

function MarketSearchDlg:initSearchCash()
    local map = self:getCheckToPanelMap()
    for k, v in pairs(map) do
        local panel = self:getControl(v)
        local cashText, fontColor = gf:getArtFontMoneyDesc(search_cost)
        self:setNumImgForPanel("MoneyPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 21, panel)
    end
end

function MarketSearchDlg:getFirstCheckBox()
    return self:getControl("NormalSearchCheckBox")
end

function MarketSearchDlg:onCheckBox(sender, eventType)
    if not sender then
        sender = self:getFirstCheckBox()
        sender:setSelectedState(true)
    end

    local name = sender:getName()
    self:selectCheckBoxByName(name)
    self.selectName = name
end

function MarketSearchDlg:selectCheckBoxByName(name)
    local map = self:getCheckToPanelMap()
    for k, v in pairs(map) do
        self:setCtrlVisible(map[k], false)
    end

    self:setCtrlVisible(map[name], true)
    self:setCtrlVisible("TipPanel", false)

    -- 切换界面清楚数据
    self:clearPetSearchInfo()
    self:clearEquipSearchInfo()
    self:clearNewEquipSearchInfo()
    self:clearJewelrySearchInfo()
    self:clearPlayerSearchInfo()
    self:clearClassInfo()

    -- 初值一级列别
    self:setSearchFirstClass(name)
 end

function MarketSearchDlg:clearPlayerSearchInfo()

    self:onResetPlayerNameButton(self:getControl("PlayerNameResetButton"))

    local playerPanel = self:getControl("PlayerSearchPanel")
    local searchNamePanel = self:getControl("SearchMenpaiPanel", nil, playerPanel)
    self:setLabelText("InputLabel", "", searchNamePanel)
    self:setCtrlVisible("TipPanel", false)

    self:cleanCatchData()

    self:clearInputVuale()
    self:onClearButton()

    self:setCheck("PlayerPetCheckBox", false)
    self:setCheck("PlayerArtifactCheckBox", false)

    self:onPOrACheckBox(self:getControl("PlayerPetCheckBox"), 1, nil, 2)
    self:onPOrACheckBox(self:getControl("PlayerArtifactCheckBox"), 2, nil, 2)


end

function MarketSearchDlg:onPOrACheckBox()
end

function MarketSearchDlg:cleanCatchData()
end

function MarketSearchDlg:clearClassInfo()
    self.searchFirstClass = nil
    self.searchSecondClass = nil
    self.searchThirdClass = nil
end

function MarketSearchDlg:setSearchFirstClass(name)

    if  name == "NormalSearchCheckBox" then
        self.searchFirstClass = nil
    elseif name == "EquipmentSearchCheckBox" then
        self.searchFirstClass = CHS[3003047]
    elseif name == "JewelrySearchCheckBox" then
        self.searchFirstClass = CHS[3004161]
    elseif name == "PetSearchCheckBox" then
        self.searchFirstClass = CHS[3003048]
    elseif name == "AttributeSearchCheckBox" then
        self.searchFirstClass = CHS[3003049]
    end
 end

function MarketSearchDlg:onClearButton(sender, eventType)
    local searchCtrl = self:getControl("SearchTextField")
    searchCtrl:didNotSelectSelf()
    searchCtrl:setText("")
    searchCtrl:setDeleteBackward(true)
end

-- 显示下拉框物品
function MarketSearchDlg:displaySearchList()
    -- 获取搜索框数据
    local str = self:getInputText("SearchTextField")
    local items = MarketMgr:matchTheChar(str, self:tradeType())
    if 0 >= #items then
        self:setCtrlVisible("MatchPopUpPanel", false)
        return
    end

    local normalSearchListPanel = self:getControl("NormalSearchListPanel")
    self:initListPanel(items, self.normalSearchCell, self.createSearCell, normalSearchListPanel, 2)
    self:setCtrlVisible("MatchPopUpPanel", true)
end

-- 初值历史列表
function MarketSearchDlg:initHistoryList()
    local items = MarketMgr:getHistorySearchList(self:tradeType()) or {}
    if #items > 0 then
        local normalSearchListPanel = self:getControl("HistorySearchListPanel")
        self:initListPanel(items, self.normalSearchCell, self.createSearCell, normalSearchListPanel, 2)
    end

end

-- 初值列表数据
function MarketSearchDlg:initListPanel(data, cellColne, func, panel, colunm)
    panel:removeAllChildren()
    local contentLayer = ccui.Layout:create()
    local line = math.floor(#data /colunm)
    local left = #data %colunm

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0
    local totalHeight = line * cellColne:getContentSize().height

    for i = 1, line do
        if i == line and left ~= 0 then
            curColunm = left
        else
            curColunm =colunm
        end

        for j = 1, curColunm do
            local tag = j + (i - 1) *colunm
            local cell = cellColne:clone()
            cell:setAnchorPoint(0,1)
            local x = (j - 1) * cellColne:getContentSize().width
            local y = totalHeight - (i - 1) * cellColne:getContentSize().height
            cell:setPosition(x, y)
            cell:setTag(tag)
            func(self, cell , data[tag])
            contentLayer:addChild(cell)
        end
    end

    contentLayer:setContentSize(panel:getContentSize().width, totalHeight)
    local scroview = ccui.ScrollView:create()
    scroview:setContentSize(panel:getContentSize())
    scroview:setDirection(ccui.ScrollViewDir.vertical)
    scroview:addChild(contentLayer)
    scroview:setInnerContainerSize(contentLayer:getContentSize())
    scroview:setTouchEnabled(true)
    scroview:setClippingEnabled(true)
    scroview:setBounceEnabled(true)

    if totalHeight < scroview:getContentSize().height then
        contentLayer:setPositionY(scroview:getContentSize().height  - totalHeight)
    end

    panel:addChild(scroview)
end

function MarketSearchDlg:createSearCell(cell, data)
    self:setLabelText("Label", data, cell)
    self:bindTouchEndEventListener(cell, self.selectListItem, data)
end

function MarketSearchDlg:selectListItem(sender,eventType, data)
    local searchCtrl = self:getControl("SearchTextField")
    searchCtrl:setText(data)
    self:setCtrlVisible("MatchPopUpPanel", false)
end

function MarketSearchDlg:onJewelrySearchNameButton(sender, eventType)
    local equipments = {CHS[4200259], CHS[4200260], CHS[4200261]}
    self:initTipInfoPanle(equipments, self.searchCell, self.createJewelryPosCell)
end

function MarketSearchDlg:onJewelrySearchLevelButton(sender, eventType)
    self:initTipInfoPanle(JEWELRY_LEVELS, self.searchCell, self.createJewelryLevelCell)
end

function MarketSearchDlg:onJewelryAttributeButton(sender, eventType)
    if not self.equipSearchTable.euipmentName then
        gf:ShowSmallTips(CHS[3003041])
        return
    end

    if not self.equipSearchTable.level then
        gf:ShowSmallTips(CHS[3003042])
        return
    end

    local tag = sender:getTag()
    if not tonumber(self.equipSearchTable.level) then

    else
        local amout = math.floor((self.equipSearchTable.level - 80) / 10 + 1)
        if amout < tag then
            gf:ShowSmallTips(string.format(CHS[4200352], self.equipSearchTable.level, amout))
            return
        end
    end

    self.selectJewelryTag = tag

    local allAttrib = EquipmentMgr:getEquipAttribCfgInfo()
    local attTab = allAttrib[ChangeType[self.equipSearchTable.euipmentName]]
    local attrib = {}
    for _, field in pairs(attTab) do
        if self:isCanExsitFieldJewelry(field, tag) then
            table.insert(attrib, EquipmentMgr:getAttribChsOrEng(field))
        end
    end
    --[[
    local allAttrib = EquipmentMgr:getEquipAttribCfgInfo()
    attTab = allAttrib[self.self.equipSearchTable.euipmentName]
    --]]
    self:initTipInfoPanle(attrib, self.searchCell, self.createJewelryAttribCell)
end

function MarketSearchDlg:isCanExsitFieldJewelry(field, tag)
    local count = 0
    for i = LAST_EQUIP_ATTR_INDEX + 1, LAST_EQUIP_ATTR_INDEX + JEWELRY_ATTRIB_MAX_NUM do
        if attributeTag[i].attrib == field and tag ~= i - LAST_EQUIP_ATTR_INDEX then
            count = count + 1
        end
    end

    if field == "all_skill" or field == "all_polar" or field == "all_resist_except" then
        return count < 1
    end
    return count < 2
end

-- 装备部位
function MarketSearchDlg:onEquipSearchNameButton(sender, eventType)
    local equipments
    if "EquipmentSearchCheckBox" ==  self.selectName then
        equipments = MarketMgr:getEquipmentSecondClassList()
    else
        equipments = {CHS[3003033], CHS[3003035], CHS[3003034], CHS[3003036]}
    end

    self:initTipInfoPanle(equipments, self.searchCell, self.createEquipmentNameCell)
end

-- 装备搜索界面的属性单元格
function MarketSearchDlg:createJewelryAttribCell(cell, data)
    self:setLabelText("Label", data, cell)

    local function lisnter()
        local listView = self:getControl("SearchAttributeListView", nil, "JewelrySearchPanel")
        local panel = listView:getChildByTag(self.selectJewelryTag)
        local searchNamePanel = self:getControl("SearchAttributePanel", nil, panel)
        -- 如果当前选择的属性与之前的不一致，就重置属性值
        if self:getLabelText("InputLabel", searchNamePanel) ~= data then
            self:resetAttibuteValue()
        end
        self:setLabelText("InputLabel", data, searchNamePanel)
        self:setCtrlVisible("TipPanel", false)
        -- >LAST_EQUIP_ATTR_INDEX 是首饰
        attributeTag[self.selectJewelryTag + LAST_EQUIP_ATTR_INDEX].attrib =  EquipmentMgr:getAttribChsOrEng(data)
        self:setEquipCellMaxMinValue(self.selectJewelryTag + LAST_EQUIP_ATTR_INDEX)
        self:updateLayout("SearchAttributePanel", panel)
        panel:requestDoLayout()
    end

    self:bindTouchEndEventListener(cell, lisnter, data)
end

function MarketSearchDlg:createJewelryLevelCell(cell, data)
    self:setLabelText("Label", data, cell)

    local function lisnter()
        local jewelryPanel = self:getControl("JewelrySearchPanel")
        local searchNamePanel = self:getControl("JewelrySearchLevelPanel", nil, jewelryPanel)
        self:clearJewelryAttibuteSearchInfo()

        self:setLabelText("InputLabel", data, searchNamePanel)
        self:setCtrlVisible("TipPanel", false)

        self.equipSearchTable.level = tonumber(string.match(data, CHS[6000401])) or tonumber(string.match(data, CHS[3003054])) or data
        self.searchThirdClass = self.equipSearchTable.level
    end

    self:bindTouchEndEventListener(cell, lisnter, data)
end

function MarketSearchDlg:createJewelryPosCell(cell, data)
    self:setLabelText("Label", data, cell)

    local function lisnter()
        local jewelryPanel = self:getControl("JewelrySearchPanel")
        local searchNamePanel = self:getControl("JewelrySearchNamePanel", nil, jewelryPanel)
        self:clearJewelryAttibuteSearchInfo()
        self:setLabelText("InputLabel", data, searchNamePanel)
        self:setCtrlVisible("TipPanel", false)

        self.equipSearchTable.euipmentName = data
        self.searchSecondClass = data
    end

    self:bindTouchEndEventListener(cell, lisnter, data)
end

function MarketSearchDlg:createEquipmentNameCell(cell, data)
    self:setLabelText("Label", data, cell)

    local function lisnter()
    	local equipmentPanel

    	if "EquipmentSearchCheckBox" ==  self.selectName then
            equipmentPanel = self:getControl("NewEquipmentSearchPanel")
            self:clearNewEquipAttibuteSearchInfo()
    	else
            equipmentPanel = self:getControl("EquipmentSearchPanel")
            self:clearEquipAttibuteSearchInfo()
    	end

    	local searchNamePanel = self:getControl("SearchNamePanel", nil, equipmentPanel)
        self:setLabelText("InputLabel", data, searchNamePanel)
        self:setCtrlVisible("TipPanel", false)

        self.equipSearchTable.euipmentName = data
        self.searchSecondClass = data
    end

    self:bindTouchEndEventListener(cell, lisnter, data)
end

-- 装备等级
function MarketSearchDlg:onNewEquipSearchLevelButton(sender, eventType)
    self:initTipInfoPanle(EQUIP_SEARCH_LEVELS, self.searchCell, self.createEquipmentLevelcell)
end


-- 属性搜索等级
function MarketSearchDlg:onEquipSearchLevelButton(sender, eventType)
    self:initTipInfoPanle(ATTRIB_SEARCH_LEVELS, self.searchCell, self.createEquipmentLevelcell)
end

function MarketSearchDlg:createEquipmentLevelcell(cell, data)
    self:setLabelText("Label", data, cell)

    local function lisnter()
        local equipmentPanel

        if "EquipmentSearchCheckBox" ==  self.selectName then
            equipmentPanel = self:getControl("NewEquipmentSearchPanel")
            self:clearNewEquipAttibuteSearchInfo()
            self.equipSearchTable.level = tonumber(string.match(data, CHS[6000401])) or tonumber(string.match(data, CHS[3003054]))
        else
            equipmentPanel = self:getControl("EquipmentSearchPanel")
            self:clearEquipAttibuteSearchInfo()
            self.equipSearchTable.level = tonumber(string.match(data, CHS[3003054]))
        end

        local searchNamePanel = self:getControl("SearchLevelPanel", nil, equipmentPanel)
        self:setLabelText("InputLabel", data, searchNamePanel)
        self:setCtrlVisible("TipPanel", false)
        self.searchThirdClass = self.equipSearchTable.level
    end

    self:bindTouchEndEventListener(cell, lisnter, data)
end

-- 属性选择
function MarketSearchDlg:onAttributeButton(sender, eventType)
    if not self.equipSearchTable.euipmentName  then
        gf:ShowSmallTips(CHS[3003041])
        return
    end

    if not self.equipSearchTable.level then
        gf:ShowSmallTips(CHS[3003042])
        return
    end

    local equipmentPanel = self:getControl("EquipmentSearchPanel")
    local searchNamePanel = self:getControl("SearchNamePanel", nil, equipmentPanel)
    local inputLabel = self:getControl("InputLabel", Const.UILabel, searchNamePanel)

    local equipName = inputLabel:getString()
    local equipType =  equip_config[equipName]
    self.equipSearchTable.equipType = equipType

    if equipType then
        local list = EquipmentMgr:getAllAddAttribByEquipType(equipType)
        self:initTipInfoPanle(list, self.searchCell, self.createEquipmentAttribCell)
    end
end

function MarketSearchDlg:createEquipmentAttribCell(cell, data)
    self:setLabelText("Label", data, cell)

    local function lisnter()
        local equipmentPanel = self:getControl("EquipmentSearchPanel")
        local searchNamePanel = self:getControl("SearchAttributePanel", nil, equipmentPanel)
        -- 如果当前选择的属性与之前的不一致，就重置属性值
        if self:getLabelText("InputLabel", searchNamePanel) ~= data then
            self:resetAttibuteValue()
        end
        self:setLabelText("InputLabel", data, searchNamePanel)
        self:setCtrlVisible("TipPanel", false)
        self.equipSearchTable.attrib = data
        self:setMaxMinValue()
    end

    self:bindTouchEndEventListener(cell, lisnter, data)
end

function MarketSearchDlg:setMaxMinValue()
    local equip = {}
    equip.equip_type = self.equipSearchTable.equipType
    equip.req_level = self.equipSearchTable.level
    self.equipSearchTable.minValue = EquipmentMgr:getAttribMinValueByField(equip, EquipmentMgr:getAttribChsOrEng(self.equipSearchTable.attrib))
    self.equipSearchTable.maxValue = EquipmentMgr:getAttribMaxValueByField(equip, EquipmentMgr:getAttribChsOrEng(self.equipSearchTable.attrib))

    local valueInfoLabel = self:getControl("ValueInfoPanel")
    local infoLabel = self:getControl("InfoLabel", nil, valueInfoLabel)
    infoLabel:setString(string.format(CHS[3003044], self.equipSearchTable.minValue, self.equipSearchTable.maxValue))
    self:updateLayout("ValueInfoPanel")
end

function MarketSearchDlg:clearEquipAttibuteSearchInfo()
    local valueInfoLabel = self:getControl("ValueInfoPanel")
    local infoLabel = self:getControl("InfoLabel", nil, valueInfoLabel)
    infoLabel:setString(CHS[3003046])

    self:clearInputVuale()
    self.equipSearchTable.attrib = nil

    local equipmentPanel = self:getControl("EquipmentSearchPanel")
    local searchNamePanel = self:getControl("SearchAttributePanel")
    self:setLabelText("InputLabel", "", searchNamePanel)

    if self.equipSearchTable.maxValue then
        self.equipSearchTable.maxValue = nil
    end

    if self.equipSearchTable.minValue then
        self.equipSearchTable.minValue = nil
    end
end

function MarketSearchDlg:onResetPlayerNameButton(sender, eventType)
    local textCtrl = self:getControl("TextField", nil, "PlayerSearchPanel")
    textCtrl:setText("")

    sender:setVisible(false)
end

function MarketSearchDlg:clearEquipSearchInfo()
    self:clearEquipAttibuteSearchInfo()

    local equipmentPanel = self:getControl("EquipmentSearchPanel")
    local searchNamePanel = self:getControl("SearchLevelPanel", nil, equipmentPanel)
    self:setLabelText("InputLabel", "", searchNamePanel)

    local searchNamePanel = self:getControl("SearchNamePanel", nil, equipmentPanel)
    self:setLabelText("InputLabel", "", searchNamePanel)

    self.equipSearchTable = {}
    self:clearInputVuale()
    self:onClearButton()
end


function MarketSearchDlg:onAttributeMaxButton(sender, eventType)
    if not self.equipSearchTable.attrib then
        gf:ShowSmallTips(CHS[3003055])
        return
    end
    local searchValuePanel = self:getControl("SearchValuePanel")
    self.inputValueList[6] = self.equipSearchTable.maxValue
    self:setInputLabelValue(6, self.equipSearchTable.maxValue)
    self.inputValueList[5] = self.equipSearchTable.maxValue
    self:setInputLabelValue(5 , self.equipSearchTable.maxValue)

    local input5Panel = self:getControl("InputBKImage5")
    self:setCtrlVisible("Label2", false, input5Panel)
    local input6Panel = self:getControl("InputBKImage6")
    self:setCtrlVisible("Label2", false, input6Panel)
end

-- 点击幻化类型
function MarketSearchDlg:createPetHuanhuaType(cell, data)
    self:setLabelText("Label", data, cell)
    local function lisnter()
        self:setLabelText("InputLabel", data, "SearchHuanhuaPanel")
        self:setCtrlVisible("TipPanel", false)
        self.petSearchTable.huanhua = data
    end

    self:bindTouchEndEventListener(cell, lisnter, data)
end


function MarketSearchDlg:onHuanhuaTimeButton(sender, eventType)
    if not self.petSearchTable.huanhua then
        gf:ShowSmallTips(CHS[4101147])
        return
    end

    local list = {string.format(CHS[4200522], 1), string.format(CHS[4200522], 2), string.format(CHS[4200522], 3)}
    self:initTipInfoPanle(list, self.searchCell, self.createPetHuanhuaTime)
end

-- 点击幻化次数
function MarketSearchDlg:createPetHuanhuaTime(cell, data)
    self:setLabelText("Label", data, cell)
    local function lisnter()
        local image = self:getControl("InputBKImage", nil, "SearchHuanhuaPanel")
        self:setLabelText("InputLabel", data, image)
        self:setCtrlVisible("TipPanel", false)
        self.petSearchTable.huanhuaTime = data
    end

    self:bindTouchEndEventListener(cell, lisnter, data)
end

function MarketSearchDlg:onHuanhuaTypeResetButton(sender, eventType)
    self:setLabelText("InputLabel", "", "SearchHuanhuaPanel")
    self:setCtrlVisible("TipPanel", false)

    self.petSearchTable.huanhua = nil

    local image = self:getControl("InputBKImage", nil, "SearchHuanhuaPanel")
    self:setLabelText("InputLabel", "", image)
    self.petSearchTable.huanhuaTime = nil
end

function MarketSearchDlg:onHuanhuaTypeButton(sender, eventType)
    if not self.petSearchTable.class then
        gf:ShowSmallTips(CHS[3003058])
        return
    end

    --              气血              法力          速度      物攻              法攻
    local list = {CHS[4000050], CHS[4000110], CHS[4000092], CHS[3003641], CHS[4101148]}
    self:initTipInfoPanle(list, self.searchCell, self.createPetHuanhuaType)
end

function MarketSearchDlg:onPetSearchTypeButton(sender, eventType)
    local list = {CHS[3003056], CHS[3003057], CHS[3003814], CHS[4100360], CHS[6000504], CHS[7002139]}
    self:initTipInfoPanle(list, self.searchCell, self.createPetTypeCell)
end

function MarketSearchDlg:createPetTypeCell(cell, data)
    self:setLabelText("Label", data, cell)

    local function lisnter()
        local petSearchPanel = self:getControl("PetSearchPanel")
        local searchTypePanel = self:getControl("SearchTypePanel", nil, petSearchPanel)
        self:setLabelText("InputLabel", data, searchTypePanel)
        self:setCtrlVisible("TipPanel", false)

        if self.petSearchTable.class ~= data then
            -- 清除宠物名
            local petSearchPanel = self:getControl("PetSearchPanel")
            local searchTypePanel = self:getControl("SearchNamePanel", nil, petSearchPanel)
            self:setLabelText("InputLabel", "", searchTypePanel)

            -- 清除上次选中的名字
            if self.petSearchTable then
                self.petSearchTable.petName = nil
            end
        end

        self.petSearchTable.class = data
        self.searchSecondClass  = data

        if self.petSearchTable.class == CHS[3003813] or self.petSearchTable.class == CHS[3003814] then
            self:setCtrlVisible("SearchDevelopPanel", false)      -- 宠物搜索-强化，默认隐藏
        else
            self:setCtrlVisible("SearchDevelopPanel", true)      -- 宠物搜索-强化，默认隐藏
        end
    end

    self:bindTouchEndEventListener(cell, lisnter, data)
end

function MarketSearchDlg:getPetsByClass(class)
    local showList = {}

    if class == CHS[3003056] then
        showList = normalPetList
    elseif class == CHS[3003057] then
        showList = elitePetList
    elseif class == CHS[3003814] then
        showList = epicPetList
    elseif class == CHS[6000504] then -- 精怪/御灵
        showList = jingguaiPetList
    elseif class == CHS[7002139] then -- 纪念
        showList = jinianPetList
    else
        showList = otherPetList
    end

    return showList
end

function MarketSearchDlg:onPetSearchNameButton(sender, eventType)
    if not self.petSearchTable.class then
        gf:ShowSmallTips(CHS[3003058])
        return
    end

    local showList = self:getPetsByClass(self.petSearchTable.class)
    local petList = {}
    for name, info in pairs(showList) do
        -- 公测需要限制某些宠物的显示
        if not DistMgr:curIsTestDist() and info.needHideInPublic then
        else
            local data = {}
            data.name = name
            data.cfg = info
            table.insert(petList, data)
        end
    end

    local nameList = {}
    if self.petSearchTable.class == CHS[3003056] then
        table.sort(petList, function(l, r) return l.cfg.level_req < r.cfg.level_req end)
        for i = 1, #petList do
            table.insert(nameList, petList[i].name)
        end
    else
        table.sort(petList, function(l, r) return l.cfg.order < r.cfg.order end)
        for i = 1, #petList do
            table.insert(nameList, petList[i].name)
        end
    end

    self:initTipInfoPanle(nameList, self.searchCell, self.createPetNameCell)
end

function MarketSearchDlg:createPetNameCell(cell, data)
    self:setLabelText("Label", data, cell)

    local function lisnter()
        local petSearchPanel = self:getControl("PetSearchPanel")
        local searchTypePanel = self:getControl("SearchNamePanel", nil, petSearchPanel)
        self:setLabelText("InputLabel", data, searchTypePanel)
        self:setCtrlVisible("TipPanel", false)
        self.petSearchTable.petName = data
    end

    self:bindTouchEndEventListener(cell, lisnter)
end

function MarketSearchDlg:onPetSearchSkillButton(sender, eventType)

    if not self.petSearchTable or not self.petSearchTable.class then
        gf:ShowSmallTips(CHS[3003058])
        return
    end

    local skillList = SkillMgr:getNatureSkillOrder()
    local orderList = {}

    for k, v in pairs(skillList) do
        table.insert(orderList, k)
    end

    local jinjieSkillList = SkillMgr:getJinjieSkillOrder()
    local natureSkillNum = #orderList
    for k, v in pairs(jinjieSkillList) do
        orderList[natureSkillNum + v] = k
    end

    self:initTipInfoPanle(orderList, self.searchCell, self.createPetSkillCell)
end

function MarketSearchDlg:createPetSkillCell(cell, data)
    self:setLabelText("Label", data, cell)

    local function lisnter()
        local petSearchPanel = self:getControl("PetSearchPanel")
        local searchTypePanel = self:getControl("SearchSkillPanel", nil, petSearchPanel)
        self:setLabelText("InputLabel", data, searchTypePanel)
        self:setCtrlVisible("TipPanel", false)
        self.petSearchTable.petSkill = data
    end

    self:bindTouchEndEventListener(cell, lisnter, data)
end

function MarketSearchDlg:initTipInfoPanle(list, cell, func)
    local normalSearchListPanel = self:getControl("TipPanel")
    local listPanel = self:getControl("SearchListPanel", nil, normalSearchListPanel)
    normalSearchListPanel:setVisible(true)
    self:initListPanel(list, cell, func, listPanel, 3)
end

function MarketSearchDlg:clearPetSearchInfo()
    local petSearchPanel = self:getControl("PetSearchPanel")
    local searchTypePanel = self:getControl("SearchTypePanel", nil, petSearchPanel)
    self:setLabelText("InputLabel", "", searchTypePanel)

    local searchTypePanel = self:getControl("SearchNamePanel", nil, petSearchPanel)
    self:setLabelText("InputLabel", "", searchTypePanel)

    local searchTypePanel = self:getControl("SearchSkillPanel", nil, petSearchPanel)
    self:setLabelText("InputLabel", "", searchTypePanel)


    self:setCtrlVisible("SearchDevelopPanel", false)      -- 宠物搜索-强化，默认隐藏
    self:setCheck("FlyCheckBox", false)
    self:setCheck("DianhuaCheckBox", false)
    self:setCheck("YuhuaCheckBox", false)

    if not self.petSearchTable.checkBoxs then self.petSearchTable.checkBoxs = {} end
    self.petSearchTable.checkBoxs["FlyCheckBox"] = false
    self.petSearchTable.checkBoxs["DianhuaCheckBox"] = false
    self.petSearchTable.checkBoxs["YuhuaCheckBox"] = false
    self:onHuanhuaTypeResetButton()

    self.petSearchTable = {}
    self:clearInputVuale()
end

function MarketSearchDlg:onSearchButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if self.selectName == "NormalSearchCheckBox" then
        self:NormalSearch()
    elseif self.selectName == "EquipmentSearchCheckBox" then
        self:newEquipSearch()
    elseif self.selectName == "JewelrySearchCheckBox" then
        self:newJewelrySearch()
    elseif self.selectName == "PetSearchCheckBox" then
        self:petSearch()
    elseif self.selectName == "AttributeSearchCheckBox" then
        self:equipSearch()
    end

end

-- 获取普通搜索的key
function MarketSearchDlg:getNormalSearchKey(item)
    local itemInfo = MarketMgr:getSellItemInfo(item)
    local key = ""
    if itemInfo.subClass == CHS[4100000] then -- 变身卡
        self.searchSecondClass = itemInfo.secondClass
        local polar = InventoryMgr:getCardInfoByName(item).polar
        self.searchThirdClass = MarketMgr:getChangeCardThirdClass(polar)
        key = itemInfo.subClass .. "_" .. itemInfo.secondClass .. "_" .. self.searchThirdClass
    elseif itemInfo.subClass == CHS[3003059] then
        self.searchSecondClass = item
        self.searchThirdClass = self:getStoneClassLevel()
        key = itemInfo.subClass .. "_" .. item .. "_" ..self:getStoneClassLevel()
    elseif itemInfo.subClass == CHS[7000144] and self:tradeType() == MarketMgr.TradeType.marketType then
        -- 法宝鹰眼搜索为全部相性(仅集市)
        key = itemInfo.subClass.."_"..item .. "_" .. CHS[7000324]
        self.searchThirdClass = nil
        self.searchSecondClass = item
    elseif itemInfo.subClass == CHS[3001107] and itemInfo.secondClass == CHS[5400066] then
        -- 纪念宠元神碎片特殊处理
        key = itemInfo.subClass.."_"..itemInfo.secondClass .. "_" .. item
        self.searchThirdClass = nil
        self.searchSecondClass = itemInfo.secondClass
    elseif itemInfo.subClass == CHS[2000369] then
        -- 菜肴
        local str = string.match(item, ".*%((.+)%)")
        key = itemInfo.subClass.."_"..itemInfo.secondClass .. "_" .. str
        self.searchThirdClass = nil
        self.searchSecondClass = itemInfo.secondClass
    elseif CHS[5000270] == itemInfo.subClass and CHS[5000271] == itemInfo.secondClass then
        -- 时装
        if type(item) == "string" and string.match(item, CHS[5000272]) then
            key = itemInfo.subClass .. "_" .. itemInfo.secondClass .. "_" .. CHS[5000274]
        elseif type(item) == "string" and string.match(item, CHS[5000273]) then
            key = itemInfo.subClass .. "_" .. itemInfo.secondClass .. "_" .. CHS[5000275]
        elseif type(item) == "string" and string.match(item, CHS[5410268]) then  -- 永久时装
            key = itemInfo.subClass .. "_" .. itemInfo.secondClass .. "_" .. CHS[5410269]
        else
            key = itemInfo.subClass .. "_" .. itemInfo.secondClass .. "_" .. CHS[5000276]
        end
    elseif itemInfo.secondClass == CHS[5420176] then
        -- 家具
        local furnitureInfo = HomeMgr:getFurnitureInfo(item)
        local levelStr = HomeMgr:furnitureLevelToChs()[furnitureInfo.level]
        key = itemInfo.subClass.."_" ..itemInfo.secondClass.."_" ..levelStr.."_" ..item
    elseif itemInfo.secondClass then
        if itemInfo.level ~= 0 then
            key = itemInfo.subClass.."_"..itemInfo.secondClass.."_"..itemInfo.level
            self.searchSecondClass = itemInfo.secondClass
            self.searchThirdClass = itemInfo.level
        else
            key = itemInfo.subClass.."_" ..itemInfo.secondClass.."_" ..item
            self.searchSecondClass = itemInfo.secondClass
            self.searchThirdClass = item
        end
    elseif type(item) == "string" and string.match(item, CHS[4200213]) then
        -- 经验心得，道武心得需要匹配当前等级
        local range = MarketMgr:getXindeLVByLevel(nil, item)
        key = itemInfo.subClass.."_"..item .. "_" .. range
        self.searchThirdClass = nil
        self.searchSecondClass = item
    elseif type(item) == "string" and string.match(item, CHS[2100031]) then
        -- ？阶骑宠灵魄，需要转换为“骑宠灵魄_？阶”的格式
        local level = string.match(item, "(.+)" .. CHS[2100031])
        key = itemInfo.subClass .. "_" .. CHS[2100031] .. "_" .. level
        self.searchThirdClass = level
        self.searchSecondClass = CHS[2100031]
    else

        key = itemInfo.subClass.."_"..item
         self.searchThirdClass = nil
        self.searchSecondClass = item
    end

    self.searchFirstClass = itemInfo.subClass
    return key
end

-- 获取搜索的key
function MarketSearchDlg:getSearchJewelryKey()
    if self.searchThirdClass then
        return self.searchFirstClass.."_"..self.searchSecondClass .."_".. self.searchThirdClass
    else
        return self.searchFirstClass.."_"..self.searchSecondClass
    end
end

-- 获取搜索的key
function MarketSearchDlg:getSearchKey()
    if self.searchThirdClass then
        return self.searchFirstClass.."_"..self.searchSecondClass .."_".. self.searchThirdClass
    else
        return self.searchFirstClass.."_"..self.searchSecondClass
    end
end

function MarketSearchDlg:getPublicType()

    if DlgMgr:getDlgByName("JuBaoZhaiVendueDlg") then
        local type = TradingMgr.LIST_TYPE.AUCTION_LIST
        if self.checkBoxTable[self.selectName] and self.checkBoxTable[self.selectName]:getSelectedRadioName() == "CheckBox2" then
            type = TradingMgr.LIST_TYPE.AUCTION_SHOW_LIST
        end

        return type

    end

    local type = TradingMgr.LIST_TYPE.SALE_LIST
    if self.checkBoxTable[self.selectName] and self.checkBoxTable[self.selectName]:getSelectedRadioName() == "CheckBox2" then
        type = TradingMgr.LIST_TYPE.SHOW_LIST
    end

    return type
end


-- 获取玩家妖石适合等级
function MarketSearchDlg:getStoneClassLevel()
    local meLevel = Me:queryBasicInt("level")
    local level = math.floor(meLevel / 10)

    if level < 5 then
        level = 5
    end

    return level
end


function MarketSearchDlg:NormalSearch()
    if not self:checkVip() then return end

    local item  = self:getInputText("SearchTextField")
    if not MarketMgr:exsistItem(item) then
        gf:ShowSmallTips(CHS[3003061])
        return
    end

    -- 公示中
    if self.checkBoxTable[self.selectName]:getSelectedRadioName() == "CheckBox2" then
        if not MarketMgr:isPublicityItem(item) then
            gf:ShowSmallTips(CHS[3003062])
            return
        end
    end

    local key = self:getNormalSearchKey(item)
    local type = self:getPublicType()

    -- 如果是GM
    if GMMgr:isGM() then
        local itemInfo = MarketMgr:getSellItemInfo(item)

        if itemInfo.subClass == CHS[4100000]then -- 变身卡
            self:startSearch(key, string.format("name:%s;", item), type) -- 时装
        elseif CHS[5000270] == itemInfo.subClass and CHS[5000271] == itemInfo.secondClass then
            -- 时装道具，取 “·” 前面的名字即可
            self:startSearch(key, string.format("name:%s;", itemInfo.keyName), type)
        elseif itemInfo.subClass == CHS[3001137] and itemInfo.secondClass == CHS[5420176] then
            self:startSearch(key, string.format("name:%s;", item), type)
        else
            self:startSearch(key, "", type)
        end

        return
    end

    gf:confirm(string.format(CHS[3003063], gf:getMoneyDesc(search_cost)), function()
        if search_cost > Me:queryBasicInt('cash') then
            performWithDelay(self.root, function () gf:askUserWhetherBuyCash(search_cost  - Me:queryBasicInt('cash')) end , 0)
            return
        end

        local itemInfo = MarketMgr:getSellItemInfo(item)

        if itemInfo.subClass == CHS[4100000]then -- 变身卡
            self:startSearch(key, string.format("name:%s;", item), type) -- 时装
        elseif CHS[5000270] == itemInfo.subClass and CHS[5000271] == itemInfo.secondClass then
            -- 时装道具，取 “·” 前面的名字即可
            self:startSearch(key, string.format("name:%s;", itemInfo.keyName), type)
        elseif itemInfo.subClass == CHS[3001137] and itemInfo.secondClass == CHS[5420176] then
            self:startSearch(key, string.format("name:%s;", item), type)
        else
            self:startSearch(key, "", type)
        end
    end, nil, nil, nil, nil, true)

end

function MarketSearchDlg:equipSearch()
    if not self:checkVip() then return end

    if not self.equipSearchTable.euipmentName  then
        gf:ShowSmallTips(CHS[3003041])
        return
    end

    if not self.equipSearchTable.level then
        gf:ShowSmallTips(CHS[3003042])
        return
    end

    local min = self.equipSearchTable.minValue
    local max = self.equipSearchTable.maxValue
    -- 有输入最小值
    if self.inputValueList[5]  then
        if self.inputValueList[5] < min or self.inputValueList[5] > max then
            gf:ShowSmallTips(CHS[3003064])
            return
        end
    end

    -- 有输入最大值
    if self.inputValueList[6] then
        if self.inputValueList[6] < min or self.inputValueList[6] > max then
            gf:ShowSmallTips(CHS[3003064])
            return
        end
    end

    if self.inputValueList[5] and self.inputValueList[6] then
        if self.inputValueList[5] > self.inputValueList[6] then
            gf:ShowSmallTips(CHS[3003065])
            return
        end
    end

    local extra = ""
    if self.equipSearchTable.attrib then
        local equipSearchTable = self.equipSearchTable
        local inputValueList = self.inputValueList
        extra = string.format("%s:%d-%d", EquipmentMgr:getAttribChsOrEng(equipSearchTable.attrib), (inputValueList[5] or min), (inputValueList[6] or max))
    end
    if extra == "" then
        gf:confirm(CHS[4100943], function ()
            self:heishuijingSearch(search_cost, extra, min, max)
        end)
    else
        self:heishuijingSearch(search_cost, extra, min, max)
    end
end

function MarketSearchDlg:heishuijingSearch(search_cost, extra, min, max)
    local key = self:getSearchKey()
    local type = self:getPublicType()
    local equipSearchTable = self.equipSearchTable
    local inputValueList = self.inputValueList

    -- 如果是GM
    if GMMgr:isGM() then
            local extra = ""
        if self.equipSearchTable.attrib then
            extra = string.format("%s:%d-%d", EquipmentMgr:getAttribChsOrEng(equipSearchTable.attrib), (inputValueList[5] or min), (inputValueList[6] or max))
        end
        self:startSearch(key, extra, type)
        return
    end

    gf:confirm(string.format(CHS[3003063], gf:getMoneyDesc(search_cost)), function()
        if search_cost > Me:queryBasicInt('cash') then
            performWithDelay(self.root, function () gf:askUserWhetherBuyCash(search_cost  - Me:queryBasicInt('cash')) end , 0)
            return
        end
        local extra = ""
        if self.equipSearchTable.attrib then
            extra = string.format("%s:%d-%d", EquipmentMgr:getAttribChsOrEng(equipSearchTable.attrib), (inputValueList[5] or min), (inputValueList[6] or max))
        end
        self:startSearch(key, extra, type)
    end, nil, nil, nil, nil, true)
end

function MarketSearchDlg:newJewelrySearch()
    if not self:checkVip() then return end

    if not self.equipSearchTable.euipmentName  then
        gf:ShowSmallTips(CHS[3003041])
        return
    end

    if not self.equipSearchTable.level then
        gf:ShowSmallTips(CHS[3003042])
        return
    end

    local extra = ""
    for i = LAST_EQUIP_ATTR_INDEX + 1, LAST_EQUIP_ATTR_INDEX + JEWELRY_ATTRIB_MAX_NUM do
        local min = attributeTag[i].minValue
        local max = attributeTag[i].maxValue
        local inputTag = (i - 1) * 2 + 6
        -- 有输入最小值
        if self.inputValueList[inputTag - 1]  then
            if self.inputValueList[inputTag - 1] < min or self.inputValueList[inputTag - 1] > max then
                gf:ShowSmallTips(attributeTag[i].name ..CHS[3003064])
                return
            end
        end

        -- 有输入最大值
        if self.inputValueList[inputTag] then
            if self.inputValueList[inputTag] < min or self.inputValueList[inputTag] > max then
                gf:ShowSmallTips(attributeTag[i].name ..CHS[3003064])
                return
            end
        end


        if self.inputValueList[inputTag - 1] and self.inputValueList[inputTag] then
            if self.inputValueList[inputTag - 1] > self.inputValueList[inputTag] then
                gf:ShowSmallTips(attributeTag[i].name ..CHS[3003065])
                return
            end
        end

        if attributeTag[i].attrib then
            local str = string.format("%s:%s:%d-%d;", attributeTag[i].pro,  attributeTag[i].attrib,(self.inputValueList[inputTag - 1] or min), (self.inputValueList[inputTag] or max))
            extra = extra .. str
        end
    end

    local key = self:getSearchJewelryKey()
    if extra == "" then
        gf:confirm(CHS[4100943], function ()
            self:equipConfirmSearch(key, search_cost, extra)
        end)
    else
        self:equipConfirmSearch(key, search_cost, extra)
    end
end

-- 子类有一个不需要位列仙班
function MarketSearchDlg:checkVip()
    if Me:getVipType() == 0 and not GMMgr:isGM() then
        gf:ShowSmallTips(CHS[3003060])
        return false
    end

    return true
end

function MarketSearchDlg:newEquipSearch()
    if not self:checkVip() then return end

    if not self.equipSearchTable.euipmentName  then
        gf:ShowSmallTips(CHS[3003041])
        return
    end

    if not self.equipSearchTable.level then
        gf:ShowSmallTips(CHS[3003042])
        return
    end

    local extra = ""
    for i = 1, LAST_EQUIP_ATTR_INDEX - 1 do
        local min = attributeTag[i].minValue
        local max = attributeTag[i].maxValue
        local inputTag = i * 2 + 6
        -- 有输入最小值
        if self.inputValueList[inputTag - 1]  then
            if self.inputValueList[inputTag - 1] < min or self.inputValueList[inputTag - 1] > max then
                gf:ShowSmallTips(attributeTag[i].name ..CHS[3003064])
                return
            end
        end

        -- 有输入最大值
        if self.inputValueList[inputTag] then
            if self.inputValueList[inputTag] < min or self.inputValueList[inputTag] > max then
                gf:ShowSmallTips(attributeTag[i].name ..CHS[3003064])
                return
            end
        end


        if self.inputValueList[inputTag - 1] and self.inputValueList[inputTag] then
            if self.inputValueList[inputTag - 1] > self.inputValueList[inputTag] then
                gf:ShowSmallTips(attributeTag[i].name ..CHS[3003065])
                return
            end
        end

        if attributeTag[i].attrib then
            local str = string.format("%s:%s:%d-%d;", attributeTag[i].pro,  attributeTag[i].attrib,(self.inputValueList[inputTag - 1] or min), (self.inputValueList[inputTag] or max))
            extra = extra .. str
        end
    end

    -- 共鸣属性单独提取
    local listView = self:getControl("SearchAttributeListView", nil, "NewEquipmentSearchPanel")
    local gongmingPanel = listView:getChildByTag(LAST_EQUIP_ATTR_INDEX)
    local searchNamePanel = self:getControl("SearchAttributePanel", nil, gongmingPanel)
    local gongmingAtt = self:getLabelText("InputLabel", searchNamePanel)
    gongmingAtt = EquipmentMgr:getAttribChsOrEng(gongmingAtt)
    if gongmingAtt and gongmingAtt ~= "" then
        extra = extra .. "prop_resonance:" .. gongmingAtt .. ";"
    end

    -- 改造等级
    if self.inputValueList[EQUIP_REBUILD_LEVEL] and self.inputValueList[EQUIP_REBUILD_LEVEL] > 0 then
        extra = extra .. "rebuild_level:" .. self.inputValueList[EQUIP_REBUILD_LEVEL] .. ";"
    end

    local key = self:getSearchKey()
    if extra == "" then
        gf:confirm(CHS[4100943], function ()
            self:equipConfirmSearch(key, search_cost, extra)
        end)
    else
        self:equipConfirmSearch(key, search_cost, extra)
    end
end

function MarketSearchDlg:equipConfirmSearch(key, search_cost, extra)
    local type = self:getPublicType()

    -- 如果是GM
    if GMMgr:isGM() then
        self:startSearch(key, extra, type)
        return
    end

    gf:confirm(string.format(CHS[3003063], gf:getMoneyDesc(search_cost)), function()
        if search_cost > Me:queryBasicInt('cash') then
            performWithDelay(self.root, function () gf:askUserWhetherBuyCash(search_cost  - Me:queryBasicInt('cash')) end , 0)
            return
        end
        self:startSearch(key, extra, type)
    end, nil, nil, nil, nil, true)
end

function MarketSearchDlg:doPetSearch(petSearchTable, key, type, inputValueList)
    local extra = ""

    if petSearchTable.petName then
        extra = extra.."name:".. petSearchTable.petName .. ";"
    end

    -- 根据搜索的宠物名称，在普通宠物后加上具体相性信息，精怪御灵类宠物后加上“全部等阶”
    -- 此规则仅作用于集市
    local petType = string.match(key, ".*_(.*)")
    if self:tradeType() == MarketMgr.TradeType.marketType then
        if petType == CHS[3001219] then
            if petSearchTable.petName then
                local polarStr
                local polar = PetMgr:getNormalPetPolar(petSearchTable.petName)
                if polar then
                    polarStr = polar .. CHS[7000326]
                else
                    polarStr = CHS[7000324]
                end

                key = key .. "_" .. polarStr
            else
                key = key .. "_" .. CHS[7000324]
            end
        elseif petType == CHS[6000504] then
            key = key .. "_" .. CHS[7000325]
        end
    end

    if petSearchTable.petSkill then
        extra = extra.."skill:".. petSearchTable.petSkill .. ";"
    end

    if not inputValueList[1]and not inputValueList[2] then
    else
        extra = extra .. string.format("%s:%d-%d;", "martial", (inputValueList[1] or 0), (inputValueList[2] or 999999999))
    end

    if not inputValueList[3] and not inputValueList[4] then
    else
        extra = extra .. string.format("%s:%d-%d;", "level", (inputValueList[3] or 0), (inputValueList[4] or 999999999))
    end

    -- 飞升
    if self:isCheck("FlyCheckBox") then
        extra = extra .. "has_upgraded:1;"
    end

    -- 点化
    if self:isCheck("DianhuaCheckBox") then
        extra = extra .. "enchant:2;"
    end

    -- 羽化
    if self:isCheck("YuhuaCheckBox") then
        extra = extra .. "eclosion:2;"
    end

    -- 幻化次数
    local panel = self:getControl("SearchHuanhuaPanel")
    local str = self:getLabelText("InputLabel", panel)
    local hhTimeCtrl = self:getControl("InputBKImage", nil, panel)
    local huanhuaTimeStr = self:getLabelText("InputLabel", hhTimeCtrl)
    local times = string.match( huanhuaTimeStr, "(.+)次")
    if times == "" or not times then times = 1 end
    times = tonumber(times)

    if times > 0 then
        if str == CHS[4000050] then
            extra = extra .. string.format( "morph_life_times:%d;", times)
        elseif str == CHS[4000110] then
            extra = extra .. string.format( "morph_mana_times:%d;", times)
        elseif str == CHS[4000092] then
            extra = extra .. string.format( "morph_speed_times:%d;", times)
        elseif str == CHS[3003641] then
            extra = extra .. string.format( "morph_phy_times:%d;", times)
        elseif str == CHS[4101148] then
            extra = extra .. string.format( "morph_mag_times:%d;", times)
        end
    end

    -- 强化
    if inputValueList[42] and self:getCtrlVisible("SearchDevelopPanel") then
        extra = extra .. string.format( "rebuild_level:%d;", inputValueList[42])
    end

    self:startSearch(key, extra, type)
end

function MarketSearchDlg:petSearch()
    if not self:checkVip() then return end

    if not self.petSearchTable.class then
        gf:ShowSmallTips(CHS[3003066])
        return
    end

    if self.inputValueList[1] and self.inputValueList[2] then
        if self.inputValueList[1] > self.inputValueList[2] then
            gf:ShowSmallTips(CHS[3003065])
            return
        end
    end

    if self.inputValueList[3]  and self.inputValueList[4] then
        if self.inputValueList[3] > self.inputValueList[4] then
            gf:ShowSmallTips(CHS[3003065])
            return
        end
    end

    local petSearchTable = self.petSearchTable
    local key = self:getSearchKey()
    local type = self:getPublicType()
    local inputValueList = self.inputValueList

    -- 如果是GM
    if GMMgr:isGM() then
        self:doPetSearch(petSearchTable, key, type, inputValueList)
        return
    end

    local dlg = gf:confirm(string.format(CHS[3003063], gf:getMoneyDesc(search_cost)), function()
        if search_cost > Me:queryBasicInt('cash') then
            performWithDelay(self.root, function () gf:askUserWhetherBuyCash(search_cost  - Me:queryBasicInt('cash')) end , 0)
            return
        end

        -- 执行搜索
        self:doPetSearch(petSearchTable, key, type, inputValueList)
    end, nil, nil, nil, nil, true)
end

function MarketSearchDlg:startSearch(key, eatra, type)
    MarketMgr:startSearch(key, eatra, type, self:tradeType())
end

function MarketSearchDlg:selectItemClass(firstClass, secondClass, thirdCladss)
    local marketTabDlg = DlgMgr.dlgs["MarketTabDlg"]
    local dlg

    if self.checkBoxTable[self.selectName]:getSelectedRadioName() == "CheckBox2" then

        if marketTabDlg then
            marketTabDlg.group:setSetlctByName("MarketPublicityDlgCheckBox")
        else
            DlgMgr:openDlg("MarketPublicityDlg")
            DlgMgr.dlgs["MarketTabDlg"].group:setSetlctByName("MarketPublicityDlgCheckBox")
        end

        dlg = DlgMgr.dlgs["MarketPublicityDlg"]
    else
        if marketTabDlg then
            marketTabDlg.group:setSetlctByName("MarketBuyDlgCheckBox")
        else
            DlgMgr:openDlg("MarketBuyDlg")
            DlgMgr.dlgs["MarketTabDlg"].group:setSetlctByName("MarketBuyDlgCheckBox")
        end

        dlg = DlgMgr.dlgs["MarketBuyDlg"]
    end

    if secondClass == CHS[6400000] then
        secondClass = CHS[3003965]  -- 搜索的是全部武器跳转带集市为枪类别
    end

    -- dlg:selectItemByClass(firstClass, secondClass, thirdCladss)
    dlg:selectItemByClass(CHS[7000306])
    dlg:setCtrlVisible("SecondPanel", false)

    DlgMgr:closeDlg(self.name)
end

function MarketSearchDlg:onResetButton(sender, eventType)
    if self.selectName == "EquipmentSearchCheckBox" then
        self:clearNewEquipSearchInfo()
    elseif self.selectName == "JewelrySearchCheckBox" then
        self:clearJewelrySearchInfo()
    elseif self.selectName == "PetSearchCheckBox" then
        self:clearPetSearchInfo()
    elseif self.selectName == "AttributeSearchCheckBox" then
        self:clearEquipSearchInfo()
    elseif self.selectName == "PlayerSearchCheckBox" then
        self:clearPlayerSearchInfo()
    end
end

function MarketSearchDlg:onFlyCheckBox(sender, eventType)
    if not self.petSearchTable then self.petSearchTable = {} end
    if not self.petSearchTable.checkBoxs then self.petSearchTable.checkBoxs = {} end

    if self.selectName == "PetSearchCheckBox" then
        if not self.petSearchTable or not self.petSearchTable.class then
            gf:ShowSmallTips(CHS[3003058])
            sender:setSelectedState(false)
            self.petSearchTable.checkBoxs[sender:getName()] = false
            return false
        end
    end

    self.petSearchTable.checkBoxs[sender:getName()] = sender:getSelectedState()
end

function MarketSearchDlg:onInfoButton(sender, eventType)
    local dlg = DlgMgr:openDlg("MarketRuleDlg")
    if self.selectName == "EquipmentSearchCheckBox" then
        dlg:setRuleType("equipmentSearchRule")
    elseif self.selectName == "JewelrySearchCheckBox" then
        dlg:setRuleType("JewelrySearchCheckBox")
    elseif self.selectName == "PetSearchCheckBox" then
        dlg:setRuleType("petSearchRule")
    elseif self.selectName == "AttributeSearchCheckBox" then
        dlg:setRuleType("attributeSearchRule")
    elseif self.selectName == "NormalSearchCheckBox" then
        dlg:setRuleType("normalSearchRule")
    end
end

function MarketSearchDlg:initNumKeyBord()
    self.inputValueList = {}
    for i = 1, INPUT_PANEL_NUM do
        self:bindNumInput("InputBKImage"..i, i)
        self.inputValueList[i] = nil
    end
end

function MarketSearchDlg:clearInputVuale()
    if not self.inputValueList then return end
    for i = 1, INPUT_PANEL_NUM do
        local image = self:getControl("InputBKImage"..i)
        if image then
            self:setLabelText("Label", "", image)
            self.inputValueList[i] = nil
            self:setCtrlVisible("Label2", true, image)
        end
	end
end

function MarketSearchDlg:iscanInputNum(inputPanelName, key)
    if self.selectName == "PetSearchCheckBox" then
        if not self.petSearchTable or not self.petSearchTable.class then
            gf:ShowSmallTips(CHS[3003058])
            return false
        end
    end

    -- 聚宝斋角色搜索-携带宠物
    if self.selectName == "PlayerSearchCheckBox" then
        if not self:iscanInputNumForUserPet(inputPanelName) then
            return
        end
    end

    if (inputPanelName == "InputBKImage5" or inputPanelName == "InputBKImage6") and not self.equipSearchTable.attrib then -- 属性搜索
        gf:ShowSmallTips(CHS[3003055])
        return false
    elseif key >= 31 then
        -- 角色
        return true
    elseif key > 6 then -- 装备搜索的输入框
        local tag = math.ceil((key - 6 ) / 2  )
        if key > 20 then
            -- 因为装备搜索增加了一个没有属性输入框的共鸣属性，所以首饰搜索的tag整体后移1
            tag = tag + 1
        end

        if not attributeTag[tag].attrib  then
            gf:ShowSmallTips(CHS[3003055])
            return false
        end
        return true
    else
        return true
    end
end

-- 设置数字键盘输入
function MarketSearchDlg:bindNumInput(inputPanelName, key, root)
    local inputPanel = self:getControl(inputPanelName, nil, root)

    local function openNumIuputDlg()
        if not self:iscanInputNum(inputPanelName, key) then -- 属性搜索
            return
        end

        self:setCtrlVisible("Label2", false, inputPanel)
        self:setCtrlVisible("Label", true, inputPanel)
        local rect = self:getBoundingBoxInWorldSpace(inputPanel)

        local dlg
        if useBig then
            dlg = DlgMgr:openDlg("NumInputExDlg")
        else
            dlg = DlgMgr:openDlg("SmallNumInputDlg")
            end

            dlg:setObj(self)
            dlg:setKey(key)
        dlg:setIsString(true == isString and true or false)
        dlg:updatePosition(rect)

        if self.doWhenOpenNumInput then
            self:doWhenOpenNumInput(ctrlName, root)
        end
    end

    self:bindListener(inputPanelName, openNumIuputDlg, root)
end

-- 数字键盘删除数字
function MarketSearchDlg:deleteNumber(key)
    local image = self:getControl("InputBKImage"..key)
    if self.inputValueList[key] then
        if self.inputValueList[key]  < 10 then
            self.inputValueList[key] = nil
            self:setLabelText("Label", "", image)
        else
            self.inputValueList[key] = math.floor(self.inputValueList[key] / 10)
            self:setLabelText("Label", self.inputValueList[key], image)
        end

    end
end

-- 数字键盘清空
function MarketSearchDlg:deleteAllNumber(key)
    local image = self:getControl("InputBKImage"..key)
    self.inputValueList[key] = nil
    self:setLabelText("Label", "", image)
end

-- 数字键盘插入数字
function MarketSearchDlg:insertNumber(num, key)
    local image = self:getControl("InputBKImage"..key)

        local curNumber = num
        if self.inputValueList[key] then

            local max = INPUT_MAX[key] or MAX_INPUT_NUM
            if curNumber >= max then
                self.inputValueList[key] = max
                gf:ShowSmallTips(CHS[3003067])
            else
                self.inputValueList[key] = curNumber
            end
        else
            self.inputValueList[key] = curNumber
        end

        DlgMgr:sendMsg("SmallNumInputDlg", "setInputValue", self.inputValueList[key])
        self:setLabelText("Label", self.inputValueList[key], image)
end

-- 设置某个 输入区域的值
function MarketSearchDlg:setInputLabelValue(key, value)
    local image = self:getControl("InputBKImage"..key)
    self:setLabelText("Label", value, image)
    self:setCtrlVisible("Label2", false, image)
end

function MarketSearchDlg:closeNumInputDlg(key)
    local inputPanel = self:getControl("InputBKImage"..key)
    if self.inputValueList[key] == nil then
            self:setLabelText("Label", "", inputPanel)
        self:setCtrlVisible("Label2", true, inputPanel)
    end
end

-- 搜索结果
function MarketSearchDlg:MSG_MARKET_SEARCH_RESULT()
    local item  = self:getInputText("SearchTextField")
    if item and item ~= "" then
        MarketMgr:insertHistroySearch(item, self:tradeType())
    end
    self:selectItemClass(self.searchFirstClass, self.searchSecondClass, self.searchThirdClass )
end

function MarketSearchDlg:tradeType()
    return MarketMgr.TradeType.marketType
end

function MarketSearchDlg:getLastSearchData()
    return MarketMgr:getMarketSearchData(self:tradeType())
end

-- 设置上次缓存的数据
function MarketSearchDlg:setLastSearchData()
    local searchData = self:getLastSearchData()
    if searchData then
        local selecltName = searchData.selectName
        self.radioGroup:setSetlctByName(selecltName)
        self.searchFirstClass = searchData.searchFirstClass
        self.searchSecondClass = searchData.searchSecondClass
        self.searchThirdClass = searchData.searchThirdClass

        if selecltName == "PetSearchCheckBox" and searchData.petSearchTable then -- 宠物搜索
            self.petSearchTable = searchData.petSearchTable
            self.inputValueList = searchData.inputValueList

            local petSearchPanel = self:getControl("PetSearchPanel")
            local searchNamePanel = self:getControl("SearchNamePanel", nil, petSearchPanel) -- 名字
            self:setLabelText("InputLabel", searchData.petSearchTable.petName or "", searchNamePanel)

            local searchTypePanel = self:getControl("SearchTypePanel", nil, petSearchPanel) -- 类型
            self:setLabelText("InputLabel", searchData.petSearchTable.class or "", searchTypePanel)

            local searchSkillPanel = self:getControl("SearchSkillPanel", nil, petSearchPanel) -- 天技
            self:setLabelText("InputLabel", self.petSearchTable.petSkill, searchSkillPanel)


            if not self.petSearchTable.class or self.petSearchTable.class == "" or (self.petSearchTable.class == CHS[4100077] or self.petSearchTable.class == CHS[5450057]) then
                self:setCtrlVisible("SearchDevelopPanel", false)      -- 宠物搜索-强化，默认隐藏
            else
                self:setCtrlVisible("SearchDevelopPanel", true)      -- 宠物搜索-强化，默认隐藏
            end

--[[
            if self.petSearchTable.class and self.petSearchTable.class ~= "" and (self.petSearchTable.class == CHS[4100077] or self.petSearchTable.class == CHS[5450057]) then
                self:setCtrlVisible("SearchDevelopPanel", false)      -- 宠物搜索-强化，默认隐藏
            else
                self:setCtrlVisible("SearchDevelopPanel", true)      -- 宠物搜索-强化，默认隐藏
            end
--]]
            for i = 1, 4 do
                local value = self.inputValueList[i]
                if value then
                    self:setInputLabelValue(i, value)
                end
            end

            local value = self.inputValueList[42]
            if value then
                self:setInputLabelValue(42, value)
            end

            -- 幻化
            if self.petSearchTable.huanhua then
                self:setLabelText("InputLabel", self.petSearchTable.huanhua, "SearchHuanhuaPanel")
            end

            if self.petSearchTable.huanhuaTime then
                local image = self:getControl("InputBKImage", nil, "SearchHuanhuaPanel")

                self:setLabelText("InputLabel", self.petSearchTable.huanhuaTime, image)
            end

            -- 飞升、点化、羽化
            if self.petSearchTable.checkBoxs then
                for checkName, bValue in pairs(self.petSearchTable.checkBoxs) do
                    self:setCheck(checkName, bValue)
                end
            end

        elseif selecltName == "AttributeSearchCheckBox" and searchData.equipSearchTable then
            self.equipSearchTable = searchData.equipSearchTable
            self.inputValueList = searchData.inputValueList
            local equipmentPanel = self:getControl("EquipmentSearchPanel")
            local searchNamePanel = self:getControl("SearchNamePanel", nil, equipmentPanel)
            self:setLabelText("InputLabel", self.equipSearchTable.euipmentName, searchNamePanel)

            local searchNamePanel = self:getControl("SearchLevelPanel", nil, equipmentPanel)
            self:setLabelText("InputLabel", MarketMgr:getThirdClassStr(self.equipSearchTable.level, ""), searchNamePanel)

            if self.equipSearchTable.attrib then
                local searchNamePanel = self:getControl("SearchAttributePanel", nil, equipmentPanel)
                self:setLabelText("InputLabel", self.equipSearchTable.attrib, searchNamePanel)
                self:setCtrlVisible("TipPanel", false)
                self:setMaxMinValue()
            end

            for i = 5, 6 do
                local value = self.inputValueList[i]
                if value then
                    self:setInputLabelValue(i, value)
                end
            end
        elseif selecltName == "EquipmentSearchCheckBox" and searchData.equipSearchTable then
            self.equipSearchTable = searchData.equipSearchTable
            self.inputValueList = searchData.inputValueList
            attributeTag = searchData.attributeTag

            local equipmentPanel = self:getControl("NewEquipmentSearchPanel")
            local searchNamePanel = self:getControl("SearchNamePanel", nil, equipmentPanel)
            self:setLabelText("InputLabel", self.equipSearchTable.euipmentName, searchNamePanel)

            local searchNamePanel = self:getControl("SearchLevelPanel", nil, equipmentPanel)
            self:setLabelText("InputLabel", MarketMgr:getThirdClassStr(self.equipSearchTable.level, CHS[3002964]), searchNamePanel)


            for i = 1, LAST_EQUIP_ATTR_INDEX do
                if attributeTag[i].attrib then
                    local listView = self:getControl("SearchAttributeListView", nil, "NewEquipmentSearchPanel")
                    local panel = listView:getChildByTag(i)
                    local searchNamePanel = self:getControl("SearchAttributePanel", nil, panel)
                    self:setLabelText("InputLabel", EquipmentMgr:getAttribChsOrEng(attributeTag[i].attrib), searchNamePanel)
                    self:setEquipCellMaxMinValue(i)
                end

                local inputTag = i * 2 + 6
                local maxValue = self.inputValueList[inputTag]
                if maxValue then
                    self:setInputLabelValue(inputTag, maxValue)
                end

                local minValue = self.inputValueList[inputTag - 1]
                if minValue then
                    self:setInputLabelValue(inputTag - 1, minValue)
                end
            end

            -- 强化
            if self.inputValueList[EQUIP_REBUILD_LEVEL] and self.inputValueList[EQUIP_REBUILD_LEVEL] > 0 then
                self:setInputLabelValue(EQUIP_REBUILD_LEVEL, self.inputValueList[EQUIP_REBUILD_LEVEL])
            end
        elseif selecltName == "JewelrySearchCheckBox" and searchData.equipSearchTable then
            self.equipSearchTable = searchData.equipSearchTable
            self.inputValueList = searchData.inputValueList
            attributeTag = searchData.attributeTag

            local equipmentPanel = self:getControl("JewelrySearchPanel")
            local searchNamePanel = self:getControl("JewelrySearchNamePanel", nil, equipmentPanel)
            self:setLabelText("InputLabel", self.equipSearchTable.euipmentName, searchNamePanel)

            local searchNamePanel = self:getControl("JewelrySearchLevelPanel", nil, equipmentPanel)
            if self.equipSearchTable and self.equipSearchTable.level then
                if tonumber(self.equipSearchTable.level) then
                    self:setLabelText("InputLabel", self.equipSearchTable.level .. CHS[3003094], searchNamePanel)
                else
                    self:setLabelText("InputLabel", self.equipSearchTable.level, searchNamePanel)
                end
            else
                self:setLabelText("InputLabel", "", searchNamePanel)
            end

            for i = LAST_EQUIP_ATTR_INDEX + 1, LAST_EQUIP_ATTR_INDEX + JEWELRY_ATTRIB_MAX_NUM do
                if attributeTag[i].attrib then
                    local listView = self:getControl("SearchAttributeListView", nil, equipmentPanel)
                    local panel = listView:getChildByTag(i - LAST_EQUIP_ATTR_INDEX)
                    local searchNamePanel = self:getControl("SearchAttributePanel", nil, panel)
                    self:setLabelText("InputLabel", EquipmentMgr:getAttribChsOrEng(attributeTag[i].attrib), searchNamePanel)
                    self:setEquipCellMaxMinValue(i)
                end

                local inputTag = (i - 1) * 2 + 6
                local maxValue = self.inputValueList[inputTag]
                if maxValue then
                    self:setInputLabelValue(inputTag, maxValue)
                end

                local minValue = self.inputValueList[inputTag - 1]
                if minValue then
                    self:setInputLabelValue(inputTag - 1, minValue)
                end
            end
        elseif selecltName == "PlayerSearchCheckBox" and searchData.playerInfo then

            self:setPlayerInfo(searchData)

        end

        local group = self.checkBoxTable[searchData.selectName]

        if group and searchData.statusCheckBoxName then
            group:setSetlctByName(searchData.statusCheckBoxName)
        end
    else
        self.radioGroup:selectRadio(1)
    end
end

function MarketSearchDlg:getAttribTab()
    return attributeTag
end

-- 保存上次选中的数据
function MarketSearchDlg:saveLastSearchData()
    local searchData = {}
    searchData.inputValueList = gf:deepCopy(self.inputValueList) -- 数字键盘数据
    searchData.equipSearchTable = self.equipSearchTable -- 装备等级和类型信息
    searchData.petSearchTable = self.petSearchTable -- 宠物属性搜索
    searchData.attributeTag = gf:deepCopy(attributeTag) -- 装备搜索属性值
    searchData.selectName = self.selectName -- 上次选中的标签
    searchData.searchFirstClass = self.searchFirstClass
    searchData.searchSecondClass = self.searchSecondClass
    searchData.searchThirdClass = self.searchThirdClass

    local group = self.checkBoxTable[searchData.selectName]
    if group then
        searchData.statusCheckBoxName = group:getSelectedRadioName()
    end

    MarketMgr:setMarketSearchData(searchData, self:tradeType())
end

return MarketSearchDlg
