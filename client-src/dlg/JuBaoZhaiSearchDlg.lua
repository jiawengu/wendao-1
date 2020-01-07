-- JuBaoZhaiSearchDlg.lua
-- Created by songcw Feb/6/2018
-- 聚宝斋鹰眼搜索界面
-- 复用 MarketSearchDlg.json

local MarketSearchDlg = require('dlg/MarketSearchDlg')
local JuBaoZhaiSearchDlg = Singleton("JuBaoZhaiSearchDlg", MarketSearchDlg)
local RadioGroup = require("ctrl/RadioGroup")

local CEHCKBOX_TO_PANEL =
{
    ["PlayerSearchCheckBox"] = "PlayerSearchPanel",
    ["EquipmentSearchCheckBox"] = "NewEquipmentSearchPanel",
    ["JewelrySearchCheckBox"] = "JewelrySearchPanel",
    ["PetSearchCheckBox"] = "PetSearchPanel",
}

--                  全部          云霄洞         玉柱洞         斗阙宫         金光洞         白骨洞
local FAMILY_MAP = {CHS[4100075], CHS[3000880], CHS[3000910], CHS[3000917], CHS[3001677], CHS[3001705]}

local GOODS_TYPE = {
    [CHS[7190083]] = TradingMgr.GOODS_TYPE.SALE_TYPE_CASH_GOODS,   -- 金钱

    [CHS[3000880]] = TradingMgr.GOODS_TYPE.SALE_TYPE_USER_METAL,
    [CHS[3000910]] = TradingMgr.GOODS_TYPE.SALE_TYPE_USER_WOOD,
    [CHS[3000917]] = TradingMgr.GOODS_TYPE.SALE_TYPE_USER_WATER,
    [CHS[3001677]] = TradingMgr.GOODS_TYPE.SALE_TYPE_USER_FIRE,
    [CHS[3001705]] = TradingMgr.GOODS_TYPE.SALE_TYPE_USER_EARTH,

    [CHS[3001219]] = TradingMgr.GOODS_TYPE.SALE_TYPE_PET_NORMAL,        -- 普通
    [CHS[3001220]] = TradingMgr.GOODS_TYPE.SALE_TYPE_PET_ELITE,        -- 变异
    [CHS[3003814]] = TradingMgr.GOODS_TYPE.SALE_TYPE_PET_EPIC,        -- 神兽
    [CHS[4100360]] = TradingMgr.GOODS_TYPE.SALE_TYPE_PET_OTHER,        -- 其他
    [CHS[4200237]] = TradingMgr.GOODS_TYPE.SALE_TYPE_PET_JINGGUAI,        -- 精怪
    [CHS[4200238]] = TradingMgr.GOODS_TYPE.SALE_TYPE_PET_YULING,        -- 御灵
    [CHS[7002139]] = TradingMgr.GOODS_TYPE.SALE_TYPE_PET_JINIAN,        -- 纪念
    [CHS[4010002]] = "304|305",

    [CHS[3003023]] = TradingMgr.GOODS_TYPE.SALE_TYPE_WEAPON_GUN,
    [CHS[3003024]] = TradingMgr.GOODS_TYPE.SALE_TYPE_WEAPON_CLAW,
    [CHS[3003025]] = TradingMgr.GOODS_TYPE.SALE_TYPE_WEAPON_SWORD,
    [CHS[3003026]] = TradingMgr.GOODS_TYPE.SALE_TYPE_WEAPON_FAN,
    [CHS[3003027]] = TradingMgr.GOODS_TYPE.SALE_TYPE_WEAPON_HAMMER,
    [CHS[4300170]] = "401|402|403|404|405",

    [CHS[3003028]] = TradingMgr.GOODS_TYPE.SALE_TYPE_HELMET_MALE,
    [CHS[3003029]] = TradingMgr.GOODS_TYPE.SALE_TYPE_HELMET_FEMALE,
    [CHS[3003030]] = TradingMgr.GOODS_TYPE.SALE_TYPE_ARMOR_MALE,
    [CHS[3003031]] = TradingMgr.GOODS_TYPE.SALE_TYPE_ARMOR_FEMALE,
    [CHS[3003036]] = TradingMgr.GOODS_TYPE.SALE_TYPE_BOOT,
    [CHS[3003153]] = TradingMgr.GOODS_TYPE.SALE_TYPE_BOOT,
    [CHS[4100075]] = "101|102|103|104|105",

    [CHS[7000138]] = TradingMgr.GOODS_TYPE.SALE_TYPE_ARTIFACT_HUNYJD,
    [CHS[7000143]] = TradingMgr.GOODS_TYPE.SALE_TYPE_ARTIFACT_FANTY,
    [CHS[7000137]] = TradingMgr.GOODS_TYPE.SALE_TYPE_ARTIFACT_DINGHZ,
    [CHS[7000139]] = TradingMgr.GOODS_TYPE.SALE_TYPE_ARTIFACT_JINJJ,
    [CHS[7000140]] = TradingMgr.GOODS_TYPE.SALE_TYPE_ARTIFACT_YINYJ,
    [CHS[7000141]] = TradingMgr.GOODS_TYPE.SALE_TYPE_ARTIFACT_XIEJJH,
    [CHS[7000142]] = TradingMgr.GOODS_TYPE.SALE_TYPE_ARTIFACT_JIULSHZ,

    [CHS[4200259]] = TradingMgr.GOODS_TYPE.SALE_TYPE_JEWELRY_BALDRIC,
    [CHS[4200260]] = TradingMgr.GOODS_TYPE.SALE_TYPE_JEWELRY_NECKLACE,
    [CHS[4200261]] = TradingMgr.GOODS_TYPE.SALE_TYPE_JEWELRY_WRIST,
    [CHS[3004161]] = "601|602|603",
}

-- 派生对象中可通过重新该函数来实现共用对话框配置
function JuBaoZhaiSearchDlg:getCfgFileName()
    return ResMgr:getDlgCfg("MarketSearchDlg")
end

function JuBaoZhaiSearchDlg:init()
    self.playerInfo = {}
    self.userPetType = nil
    self.userPetName = nil
    self.userArfType = nil

    self.radioPOrAGroup = RadioGroup.new()
    self.radioPOrAGroup:setItemsCanReClick(self, {"PlayerPetCheckBox", "PlayerArtifactCheckBox"}, self.onPOrACheckBox)

    self:initPlayerSearchPanel()
--[[
    local listView = self:getControl("SearchAttributeListView", nil, "PlayerSearchPanel")
    -- 聚宝角色搜索中，宠物相关panel,不用 retainCtrl，是因为 retainCtrl 方法后，当帧不会 listView:getItems()还在里面
       self.userPetPanel = self:retainCtrl("SearchCarryPetPanel")
     self.userArtifactPanel = self:retainCtrl("SearchCarryFaBaoPanel")
    listView:refreshView()
--]]    

    self.userPetPanel = self:getControl("SearchCarryPetPanel")
    self:bindListener("PetSearchTypeButton", self.onUserPetSearchTypeButton, self.userPetPanel)
    self:bindListener("PetSearchNameButton", self.onUserPetSearchNameButton, self.userPetPanel)

    self.userArtifactPanel = self:getControl("SearchCarryFaBaoPanel")
    self:bindListener("ArtifactSearchTypeButton", self.onUserAtfSearchNameButton, self.userArtifactPanel)

    local listView = self:getControl("SearchAttributeListView", nil, "PlayerSearchPanel")
    listView:removeChild(self.userPetPanel)
    listView:removeChild(self.userArtifactPanel)
    self.userPetPanel:retain()
    self.userArtifactPanel:retain()

    self:bindNumInputForRemoved()
    self:updateListView()

    MarketSearchDlg.init(self)

    for _, panelName in pairs(CEHCKBOX_TO_PANEL) do
        local panel = self:getControl("SeletePanel", nil, panelName)
        self:setLabelText("Label1", CHS[4010003], panel)
        self:setLabelText("Label2", CHS[4010004], panel)
    end
end

function JuBaoZhaiSearchDlg:cleanupForChild()
    if self.userPetPanel then
        self.userPetPanel:release()
        self.userPetPanel = nil
    end

    if self.userArtifactPanel then
        self.userArtifactPanel:release()
        self.userArtifactPanel = nil
    end    
end

-- 宠物和法宝，初始化时候会remove掉，所以单独处理
function JuBaoZhaiSearchDlg:bindNumInputForRemoved()
    for i = 43, 45 do
        self:bindNumInput("InputBKImage"..i, i, self.userPetPanel)
    end

    for i = 46, 47 do
        self:bindNumInput("InputBKImage"..i, i, self.userArtifactPanel)
    end
end

function JuBaoZhaiSearchDlg:updateListView()
    local listView = self:getControl("SearchAttributeListView", nil, "PlayerSearchPanel")

    local items = listView:getItems()
    local height = 0
    for _, panel in pairs(items) do
        height = height + panel:getContentSize().height
    end

    local size = {width = listView:getContentSize().width, height = height}
    listView:setInnerContainerSize(size)
    listView:refreshView()
end

-- 角色搜索中，点击法宝、宠物的单选框
function JuBaoZhaiSearchDlg:onPOrACheckBox(sender, idx, eventType, rState)
    -- 重复点击时，需要取消选择
    if rState == 1 then
    else
        sender:setSelectedState(false)
    end

    -- 删除已加载的
    local listView = self:getControl("SearchAttributeListView", nil, "PlayerSearchPanel")
    local index = listView:getIndex(self.userPetPanel)
    if index < 0 then
        index = listView:getIndex(self.userArtifactPanel)
    end
    if index >= 0 then
        listView:removeItem(index)
    end

    -- push对应单选框增加的选项
    if sender:getSelectedState() then
        if idx == 1 then
            listView:pushBackCustomItem(self.userPetPanel)
        else
            listView:pushBackCustomItem(self.userArtifactPanel)
        end
    end

    listView:refreshView()
end

function JuBaoZhaiSearchDlg:setForVendue()
    for _, panelName in pairs(CEHCKBOX_TO_PANEL) do
        local panel = self:getControl("SeletePanel", nil, panelName)
        self:setLabelText("Label1", CHS[4200523], panel)
    end
end

function JuBaoZhaiSearchDlg:getPlayerInfo()
    return self.playerInfo
end

function JuBaoZhaiSearchDlg:closeNumInputDlg(key)
    MarketSearchDlg.closeNumInputDlg(self, key)
end

function JuBaoZhaiSearchDlg:getLastSearchData()
    return TradingMgr:getEagleEyeSearchData()
end

function JuBaoZhaiSearchDlg:savePlayerInfo()
    self.playerInfo = {}
    local playerPanel = self:getControl("PlayerSearchPanel")
    local textCtrl = self:getControl("TextField", nil, playerPanel)
    self.playerInfo.name = textCtrl:getStringValue()

    local searchNamePanel = self:getControl("SearchMenpaiPanel", nil, playerPanel)
    self.playerInfo.menpai = self:getLabelText("InputLabel", searchNamePanel)

    local searchTypePanel = self:getControl("SearchTypePanel", nil, playerPanel)
    self.playerInfo.petType = self:getLabelText("InputLabel", searchTypePanel)

    local searchNamePanel = self:getControl("SearchNamePanel", nil, playerPanel)
    self.playerInfo.petName = self:getLabelText("InputLabel", searchNamePanel)

    local searchArfPanel = self:getControl("SearchCarryFaBaoPanel", nil, playerPanel)
    self.playerInfo.arfType = self:getLabelText("InputLabel", searchArfPanel)

    self.playerInfo.checkValue = self.radioPOrAGroup:getSelectedRadioIndex() or 0

    return self.playerInfo
end

-- 保存上次选中的数据
function JuBaoZhaiSearchDlg:saveLastSearchData()
    local searchData = {}
    local attributeTag = self:getAttribTab()
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

    --
    searchData.playerInfo = self:savePlayerInfo()

    TradingMgr:setEagleEyeSearchData(searchData)
end

function JuBaoZhaiSearchDlg:bindNumInpputPlayersInfo()
    local playerList = self:getControl("PlayerSearchPanel")

    local function openNumIuputDlg(key, parentPanel)
        self:setCtrlVisible("Label2", false, parentPanel)
        self:setCtrlVisible("Label", true, parentPanel)
        local rect = self:getBoundingBoxInWorldSpace(parentPanel)
        local dlg = DlgMgr:openDlg("NumInputDlg")--SmallNumInputDlg
        dlg:setObj(self)
        dlg:setKey(key)
        if rect.y  + rect.height +  dlg.root:getContentSize().height /2 + dlg.root:getContentSize().height >= self:getWinSize().height then
            dlg.root:setPosition(rect.x + rect.width /2 , rect.y - dlg.root:getContentSize().height / 2 - 10)
            dlg:setCtrlVisible("UpImage", false)
            dlg:setCtrlVisible("DownImage", true)
        else
            dlg.root:setPosition(rect.x + rect.width /2 , rect.y  + rect.height +  dlg.root:getContentSize().height /2 )
            dlg:setCtrlVisible("UpImage", true)
            dlg:setCtrlVisible("DownImage", false)
        end
    end

    -- 等级最低
    local levelPanel = self:getControl("SearchLevelPanel", nil, playerList)
    local minLevelPanel = self:getControl("InputBKImage3", nil, levelPanel)
    local maxLevelPanel = self:getControl("InputBKImage4", nil, levelPanel)


    self:bindTouchEndEventListener(minLevelPanel, function ()
        openNumIuputDlg("minLevel", minLevelPanel)
    end)

    self:bindTouchEndEventListener(maxLevelPanel, function ()
        openNumIuputDlg("maxLevel", maxLevelPanel)
    end)
end

function JuBaoZhaiSearchDlg:setTradeTypeUI()
    -- 隐藏属性搜索标签页
    self:setCtrlVisible("AttributeSearchCheckBox", false)
end

-- 隐藏部分CheckBox，和修改名字
function JuBaoZhaiSearchDlg:initCheckBox()
    -- 隐藏不用的，显示可用的
    self:setCtrlVisible("NormalSearchCheckBox", false)      --  普通搜索
    self:setCtrlVisible("EquipmentSearchCheckBox", true)      --  装备搜索
    self:setCtrlVisible("JewelrySearchCheckBox", true)      --  首饰搜索
    self:setCtrlVisible("PetSearchCheckBox", true)      --  宠物搜索
    self:setCtrlVisible("AttributeSearchCheckBox", false)      --  黑水晶搜索
    self:setCtrlVisible("PlayerSearchCheckBox", true)      --  黑水晶搜索

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"PlayerSearchCheckBox", "EquipmentSearchCheckBox", "JewelrySearchCheckBox", "PetSearchCheckBox"}, self.onCheckBox)
end

function JuBaoZhaiSearchDlg:initPlayerSearchPanel()
    self:bindListener("PlayerNameResetButton", self.onResetPlayerNameButton)
    self:bindListener("SearchMenpaiButton", self.onSearchMenpaiButton)
    self:bindListener("SearchButton", self.onSearchButton, "PlayerSearchPanel")
    self:bindListener("ResetAllButton", self.onResetButton, "PlayerSearchPanel")

    -- 名字的TextField
    self:bindEditFieldForSafe("PlayerSearchPanel", 6, "PlayerNameResetButton")
end

function JuBaoZhaiSearchDlg:getFirstCheckBox()
    return self:getControl("PlayerSearchCheckBox")
end

function JuBaoZhaiSearchDlg:onUserAtfSearchNameButton()
    local list = {CHS[7000137], CHS[7000138], CHS[7000139], CHS[7000140], CHS[7000141], CHS[7000142], CHS[7000143]}
    self:initTipInfoPanle(list, self.searchCell, self.createUserArfTypeCell)
end

function JuBaoZhaiSearchDlg:createUserArfTypeCell(cell, data)
    self:setLabelText("Label", data, cell)

    local function lisnter()
        self:setLabelText("InputLabel", data, self.userArtifactPanel)
        self:setCtrlVisible("TipPanel", false)

        self.userArfType = data
    end

    self:bindTouchEndEventListener(cell, lisnter, data)
end

function JuBaoZhaiSearchDlg:iscanInputNumForUserPet(inputPanelName)
    local num = tonumber(string.match(inputPanelName, "InputBKImage(.+)"))
    local isPet = (num >= 43 and num <= 45)

    if not self.userPetType and isPet then
        gf:ShowSmallTips(CHS[3003058])
        return
    end

    if (self.userPetType == CHS[4100077] or self.userPetType == CHS[5450057]) and isPet and num == 45 then
        gf:ShowSmallTips(CHS[4101145])
        return
    end

    local isArf = (num == 46 or num == 47)
    if isArf and not self.userArfType then
        gf:ShowSmallTips(CHS[4101146])
        return
    end

    return true
end

function JuBaoZhaiSearchDlg:onUserPetSearchNameButton()
    if not self.userPetType then
        gf:ShowSmallTips(CHS[3003058])
        return
    end

    local showList = self:getPetsByClass(self.userPetType)
    local petList = {}

    for name, info in pairs(showList) do
        local data = {}
        data.name = name
        data.cfg = info
        table.insert(petList, data)
    end

    local nameList = {}
    if self.userPetType == CHS[3003056] then
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

    self:initTipInfoPanle(nameList, self.searchCell, self.createUserPetNameCell)
end

-- 清除附加信息
function JuBaoZhaiSearchDlg:cleanCatchData()
    self:setLabelText("InputLabel", "", self.userPetPanel)
    self.userPetType = nil

    local panel = self:getControl("SearchNamePanel", nil, self.userPetPanel)
    self:setLabelText("InputLabel", "", panel)
    self.userPetName = nil

    self:setLabelText("InputLabel", "", self.userArtifactPanel)
    self.userArfType = nil

    self:bindNumInputForRemoved()
end


function JuBaoZhaiSearchDlg:onUserPetSearchTypeButton()
    local list = {CHS[3003056], CHS[3003057], CHS[3003814], CHS[4100360], CHS[6000504], CHS[7002139]}
    self:initTipInfoPanle(list, self.searchCell, self.createUserPetTypeCell)
end

function JuBaoZhaiSearchDlg:createUserPetTypeCell(cell, data)
    self:setLabelText("Label", data, cell)

    local function lisnter()

        self:setLabelText("InputLabel", data, self.userPetPanel)
        self:setCtrlVisible("TipPanel", false)

        self.userPetType = data
        self.userPetName = nil
        self.inputValueList[45] = nil
        self:closeNumInputDlg(45)

        -- 清除宠物名
        local searchTypePanel = self:getControl("SearchNamePanel", nil, self.userPetPanel)
        self:setLabelText("InputLabel", "", searchTypePanel)
    end

    self:bindTouchEndEventListener(cell, lisnter, data)
end

function JuBaoZhaiSearchDlg:createUserPetNameCell(cell, data)
    self:setLabelText("Label", data, cell)

    local function lisnter()
        local panel = self:getControl("SearchNamePanel", nil, self.userPetPanel)
        self:setLabelText("InputLabel", data, panel)
        self:setCtrlVisible("TipPanel", false)

        self.userPetName = data
    end

    self:bindTouchEndEventListener(cell, lisnter, data)
end

function JuBaoZhaiSearchDlg:onInfoButton(sender, eventType)
    local dlg = DlgMgr:openDlg("MarketRuleDlg")
    if self.selectName == "PlayerSearchCheckBox" then
        dlg:setRuleType("JuBaoPlayer")
    elseif self.selectName == "EquipmentSearchCheckBox" then
        dlg:setRuleType("JuBaoEquip")
    elseif self.selectName == "JewelrySearchCheckBox" then
        dlg:setRuleType("JuBaoEquipJewelry")
    elseif self.selectName == "PetSearchCheckBox" then
        dlg:setRuleType("JuBaoEquipPet")
    end
end

function JuBaoZhaiSearchDlg:createMenpaicell(cell, data)
    self:setLabelText("Label", data, cell)

    local function lisnter()
        local playerPanel = self:getControl("PlayerSearchPanel")
        local searchNamePanel = self:getControl("SearchMenpaiPanel", nil, playerPanel)
        self:setLabelText("InputLabel", data, searchNamePanel)
        self:setCtrlVisible("TipPanel", false)
    end

    self:bindTouchEndEventListener(cell, lisnter, data)
end

function JuBaoZhaiSearchDlg:onSearchMenpaiButton(sender, eventType)
    self:initTipInfoPanle(FAMILY_MAP, self.searchCell, self.createMenpaicell)
end

function JuBaoZhaiSearchDlg:getCheckToPanelMap()
    return CEHCKBOX_TO_PANEL
end

function JuBaoZhaiSearchDlg:setPlayerInfo(searchData)
    local playerPanel = self:getControl("PlayerSearchPanel")
    local textCtrl = self:getControl("TextField", nil, playerPanel)
    textCtrl:setText(searchData.playerInfo.name or "")

    self:setCtrlVisible("PlayerNameResetButton", searchData.playerInfo.name ~= "", playerPanel)

    local searchNamePanel = self:getControl("SearchMenpaiPanel", nil, playerPanel)
    self:setLabelText("InputLabel", searchData.playerInfo.menpai or CHS[4100075], searchNamePanel)

    for i = 31, 41 do
        local value = searchData.inputValueList[i]
        if value then
            self:setInputLabelValue(i, value)
            self.inputValueList[i] = value
        end
    end

    local listView = self:getControl("SearchAttributeListView", nil, "PlayerSearchPanel")
    if searchData.playerInfo.checkValue ~= 0 then
        self.radioPOrAGroup:selectRadio(searchData.playerInfo.checkValue, true)

        if searchData.playerInfo.checkValue == 1 then
            listView:pushBackCustomItem(self.userPetPanel)

            for i = 43, 45 do
                local value = searchData.inputValueList[i]
                if value then
                    self:setInputLabelValue(i, value)
                    self.inputValueList[i] = value
                end
            end

            if searchData.playerInfo.petType then
                self:setLabelText("InputLabel",  searchData.playerInfo.petType, self.userPetPanel)
                self.userPetType = searchData.playerInfo.petType
            end

            if searchData.playerInfo.petName then
                local panel = self:getControl("SearchNamePanel", nil, self.userPetPanel)
                self:setLabelText("InputLabel", searchData.playerInfo.petName, panel)
                self.userPetName = searchData.playerInfo.petName
            end

        else
            listView:pushBackCustomItem(self.userArtifactPanel)
            for i = 46, 47 do
                local value = searchData.inputValueList[i]
                if value then
                    self:setInputLabelValue(i, value)
                    self.inputValueList[i] = value
                end
            end

            if searchData.playerInfo.arfType then
                self:setLabelText("InputLabel", searchData.playerInfo.arfType, self.userArtifactPanel)
                self.userArfType = searchData.playerInfo.arfType
            end
        end
    end
    listView:refreshView()
end

function JuBaoZhaiSearchDlg:onSearchButton(sender, eventType)
    if not DlgMgr:isDlgOpened("JuBaoZhaiTabDlg") then return end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if self.selectName == "PlayerSearchCheckBox" then
        self:playerSearch()
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

function JuBaoZhaiSearchDlg:getPlayerExtra()
    local data = {}
    local info = self:savePlayerInfo()

    if info.name ~= "" then
        data.name = info.name
    end
    local minLevel = self.inputValueList[31] or 0
    local maxLevel = self.inputValueList[32] or 999
    data.level = string.format("%d-%d", minLevel, maxLevel)

    if self.inputValueList[33] then
        data.tao = tonumber(self.inputValueList[33] or 0) * 360 + 1
    end

    if self.inputValueList[34] then
        data.max_life = (self.inputValueList[34] or 0) + 1
    end

    if self.inputValueList[35] then
        data.max_mana = (self.inputValueList[35] or 0) + 1
    end

    if self.inputValueList[36] then
        data.phy_power = (self.inputValueList[36] or 0) + 1
    end

    if self.inputValueList[37] then
        data.mag_power = (self.inputValueList[37] or 0) + 1
    end

    if self.inputValueList[38] then
        data.def = (self.inputValueList[38] or 0) + 1
    end

    if self.inputValueList[39] then
        data.speed = (self.inputValueList[39] or 0) + 1
    end

    if self.inputValueList[41] then
        data.all_skill = (self.inputValueList[41] or 0) + 1
    end

    if self.inputValueList[40] then
        data.ignore_resist_forgotten = (self.inputValueList[40] or 0) + 1
        data.ignore_resist_poison = (self.inputValueList[40] or 0) + 1
        data.ignore_resist_frozen = (self.inputValueList[40] or 0) + 1
        data.ignore_resist_sleep = (self.inputValueList[40] or 0) + 1
        data.ignore_resist_confusion = (self.inputValueList[40] or 0) + 1
    end

    local retStr = ""
    for field, value in pairs(data) do

        if tonumber(value) then
            retStr = retStr .. string.format("%s:%d;", field, value)
        else
            retStr = retStr .. string.format("%s:%s;", field, value)
        end
    end


    local sub_extra = ""
    local sub_type = self.radioPOrAGroup:getSelectedRadioIndex() or 0
    if sub_type == 1 then
        -- 勾选了携带宠物
        if self.userPetType then
            sub_extra = sub_extra .. GOODS_TYPE[self.userPetType] .. "||"

            local condition = ""

            if self.userPetName and self.userPetName ~= "" then
                condition = condition .. "name:" .. self.userPetName .. ";"
            end

            if self.inputValueList[43] or self.inputValueList[44] then
                local min = self.inputValueList[43] or 1
                local max = self.inputValueList[44] or 999999999
                condition = condition .. "martial:" .. min .. "-" .. max .. ";"
            end

            if self.inputValueList[45] then
                condition = condition .. "rebuild_level:" .. self.inputValueList[45] .. ";"
            end

            if condition ~= "" then sub_extra = sub_extra .. condition end
        end

    elseif sub_type == 2 then
        -- 勾选了携带法宝
        if self.userArfType and self.userArfType ~= "" then
            sub_extra = sub_extra .. GOODS_TYPE[self.userArfType] .. "||"
        end

        local condition = ""
        if self.inputValueList[46] or self.inputValueList[47] then
            local min = self.inputValueList[46] or 1
            local max = self.inputValueList[47] or 999999999
            condition = condition .. "level:" .. min .. "-" .. max .. ";"
        end

        if condition ~= "" then sub_extra = sub_extra .. condition end
    end

    return retStr, sub_extra
end

function JuBaoZhaiSearchDlg:playerSearch()
    local info = self:savePlayerInfo()
    if not info.menpai or info.menpai == "" then
        gf:ShowSmallTips(CHS[4010005])
        return
    end

    if self.inputValueList[31] and self.inputValueList[32] then
        if self.inputValueList[31] > self.inputValueList[32] then
            gf:ShowSmallTips(CHS[4101140])
            return
        end
    end

    local conditionCheck = self.radioPOrAGroup:getSelectedRadioIndex() or 0
    if conditionCheck == 1 then
        if not self.userPetType then
            gf:ShowSmallTips(CHS[4101143])
            return
        end

        if self.inputValueList[43] and self.inputValueList[44] then
            if self.inputValueList[43] > self.inputValueList[44] then
                gf:ShowSmallTips(CHS[4101141])
                return
            end
        end
    elseif conditionCheck == 2 then
        if not self.userArfType then
            gf:ShowSmallTips(CHS[4101144])
            return
        end

        if self.inputValueList[46] and self.inputValueList[47] then
            if self.inputValueList[46] > self.inputValueList[47] then
                gf:ShowSmallTips(CHS[4101142])
                return
            end
        end
    end

    -- 如果是GM
    if GMMgr:isGM() then
        local extra, sub_extra = self:getPlayerExtra()
        self:startSearch(CHS[4010006] .. info.menpai, extra, "", sub_extra)
        return
    end

    local search_cost = 100000
    gf:confirm(string.format(CHS[3003063], gf:getMoneyDesc(search_cost)), function()
        if search_cost > Me:queryBasicInt('cash') then
            performWithDelay(self.root, function () gf:askUserWhetherBuyCash(search_cost  - Me:queryBasicInt('cash')) end , 0)
            return
        end

        local info = self:savePlayerInfo()
        if not info.menpai or info.menpai == "" then
            gf:ShowSmallTips(CHS[4010005])
            return
        end

        local extra, sub_extra = self:getPlayerExtra()
        self:startSearch(CHS[4010006] .. info.menpai, extra, "", sub_extra)
    end, nil, nil, nil, nil, true)
end

function JuBaoZhaiSearchDlg:checkVip()
    return true
end

function JuBaoZhaiSearchDlg:getTradingTimeState()
    local saleType = TradingMgr.LIST_TYPE.SALE_LIST
    local showType = TradingMgr.LIST_TYPE.SHOW_LIST

    if DlgMgr:getDlgByName("JuBaoZhaiVendueDlg") then
        saleType = TradingMgr.LIST_TYPE.AUCTION_LIST
        showType = TradingMgr.LIST_TYPE.AUCTION_SHOW_LIST
    end

    local panel
    if self.selectName == "PlayerSearchCheckBox" then
        panel = self:getControl("PlayerSearchPanel")
    elseif self.selectName == "EquipmentSearchCheckBox" then
        panel = self:getControl("NewEquipmentSearchPanel")
    elseif self.selectName == "JewelrySearchCheckBox" then
        panel = self:getControl("JewelrySearchPanel")
    elseif self.selectName == "PetSearchCheckBox" then
        panel = self:getControl("PetSearchPanel")
    end

    return self:isCheck("CheckBox1", panel) and saleType or showType
end

function JuBaoZhaiSearchDlg:startSearch(key, eatra, type, sub_extra)
    sub_extra = sub_extra or ""
    if not DlgMgr:isDlgOpened("JuBaoZhaiTabDlg") then return end
    local bigMenu, class, level = string.match(key, "(.+)_(.+)_(.+)")
    if not bigMenu and not class and not level then
        bigMenu, class = string.match(key, "(.+)_(.+)")
    end

    local path_str = ""
    local newCmdExtra = ""
    path_str = GOODS_TYPE[class]
    if bigMenu == CHS[7002314] or bigMenu == CHS[3001073] then -- 装备 高级首饰
        if level == CHS[4100650] then
            newCmdExtra = eatra
        else
            if eatra ~= "" then
                newCmdExtra = eatra .. ";level:" .. level .. "-" .. (level + 9) .. ";"
            else
                newCmdExtra = eatra .. "level:" .. level .. "-" .. (level + 9) .. ";"
            end
        end
    elseif bigMenu == CHS[3001218] then -- "宠物"
        newCmdExtra = eatra
    else
        newCmdExtra = eatra
    end

    local listType = self:getTradingTimeState()
    gf:CmdToServer("CMD_TRADING_SEARCH_GOODS", {list_type = listType, path_str = path_str, extra = newCmdExtra, sub_extra = sub_extra})
end

return JuBaoZhaiSearchDlg
