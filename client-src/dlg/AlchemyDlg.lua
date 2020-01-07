-- AlchemyDlg.lua
-- Created by zhengjh Apr/21/2015
-- 炼丹

local AlchemyDlg = Singleton("AlchemyDlg", Dialog)
local MainType1 = 10000     -- 材料充足
local MainType2 = 20000     -- 配方
local SecondType = 100      -- 二级菜单起始
local LINE_SPACE = 10

local ALL_ITEM_LIST = AlchemyMgr:getAllItemType() -- 获取合成类别

local TOTAL_INFO = {
    [CHS[3002249]] = {  [1] = {nimbus = 4000, chs = CHS[3004110], value = 100},
        [2] = {nimbus = 5000, chs = CHS[3004110], value = 400},
        [3] = {nimbus = 6000, chs = CHS[3004110], value = 900},
        [4] = {nimbus = 7000, chs = CHS[3004110], value = 1600},
        [5] = {nimbus = 8000, chs = CHS[3004110], value = 2500},
        [6] = {nimbus = 9000, chs = CHS[3004110], value = 3600},
        [7] = {nimbus = 10000, chs = CHS[3004110], value = 4900},
        [8] = {nimbus = 11000, chs = CHS[3004110], value = 6400},
        [9] = {nimbus = 12000, chs = CHS[3004110], value = 8100},
        [10] = {nimbus = 13000, chs = CHS[3004110], value = 10000},
        [11] = {nimbus = 14000, chs = CHS[3004110], value = 12100},
        [12] = {nimbus = 15000, chs = CHS[3004110], value = 14400},
    },

    [CHS[3004454]] = {  [1] = {nimbus = 4000, chs = CHS[3004456], value = 66},
        [2] = {nimbus = 5000, chs = CHS[3004456], value = 264},
        [3] = {nimbus = 6000, chs = CHS[3004456], value = 594},
        [4] = {nimbus = 7000, chs = CHS[3004456], value = 1056},
        [5] = {nimbus = 8000, chs = CHS[3004456], value = 1650},
        [6] = {nimbus = 9000, chs = CHS[3004456], value = 2376},
        [7] = {nimbus = 10000, chs = CHS[3004456], value = 3234},
        [8] = {nimbus = 11000, chs = CHS[3004456], value = 4224},
        [9] = {nimbus = 12000, chs = CHS[3004456], value = 5346},
        [10] = {nimbus = 13000, chs = CHS[3004456], value = 6600},
        [11] = {nimbus = 14000, chs = CHS[3004456], value = 7986},
        [12] = {nimbus = 15000, chs = CHS[3004456], value = 9504},
    },

    [CHS[3002250]] = {  [1] = {nimbus = 4000, chs = CHS[3004111], value = 32},
        [2] = {nimbus = 5000, chs = CHS[3004111], value = 64},
        [3] = {nimbus = 6000, chs = CHS[3004111], value = 96},
        [4] = {nimbus = 7000, chs = CHS[3004111], value = 128},
        [5] = {nimbus = 8000, chs = CHS[3004111], value = 160},
        [6] = {nimbus = 9000, chs = CHS[3004111], value = 192},
        [7] = {nimbus = 10000, chs = CHS[3004111], value = 224},
        [8] = {nimbus = 11000, chs = CHS[3004111], value = 256},
        [9] = {nimbus = 12000, chs = CHS[3004111], value = 288},
        [10] = {nimbus = 13000, chs = CHS[3004111], value = 320},
        [11] = {nimbus = 14000, chs = CHS[3004111], value = 352},
        [12] = {nimbus = 15000, chs = CHS[3004111], value = 384},
    },

    [CHS[3002251]] = {  [1] = {nimbus = 4000, chs = CHS[3004107], value = 30},
        [2] = {nimbus = 5000, chs = CHS[3004107], value = 120},
        [3] = {nimbus = 6000, chs = CHS[3004107], value = 270},
        [4] = {nimbus = 7000, chs = CHS[3004107], value = 480},
        [5] = {nimbus = 8000, chs = CHS[3004107], value = 750},
        [6] = {nimbus = 9000, chs = CHS[3004107], value = 1080},
        [7] = {nimbus = 10000, chs = CHS[3004107], value = 1470},
        [8] = {nimbus = 11000, chs = CHS[3004107], value = 1920},
        [9] = {nimbus = 12000, chs = CHS[3004107], value = 2430},
        [10] = {nimbus = 13000, chs = CHS[3004107], value = 3000},
        [11] = {nimbus = 14000, chs = CHS[3004107], value = 3630},
        [12] = {nimbus = 15000, chs = CHS[3004107], value = 4320},
    },

    [CHS[3002252]] = {  [1] = {nimbus = 4000, chs = CHS[3004109], value = 66},
        [2] = {nimbus = 5000, chs = CHS[3004109], value = 264},
        [3] = {nimbus = 6000, chs = CHS[3004109], value = 594},
        [4] = {nimbus = 7000, chs = CHS[3004109], value = 1056},
        [5] = {nimbus = 8000, chs = CHS[3004109], value = 1650},
        [6] = {nimbus = 9000, chs = CHS[3004109], value = 2376},
        [7] = {nimbus = 10000, chs = CHS[3004109], value = 3234},
        [8] = {nimbus = 11000, chs = CHS[3004109], value = 4224},
        [9] = {nimbus = 12000, chs = CHS[3004109], value = 5346},
        [10] = {nimbus = 13000, chs = CHS[3004109], value = 6600},
        [11] = {nimbus = 14000, chs = CHS[3004109], value = 7986},
        [12] = {nimbus = 15000, chs = CHS[3004109], value = 9504},
    },

    [CHS[3002253]] = {  [1] = {nimbus = 4000, chs = CHS[3004108], value = 43},
        [2] = {nimbus = 5000, chs = CHS[3004108], value = 174},
        [3] = {nimbus = 6000, chs = CHS[3004108], value = 392},
        [4] = {nimbus = 7000, chs = CHS[3004108], value = 696},
        [5] = {nimbus = 8000, chs = CHS[3004108], value = 1089},
        [6] = {nimbus = 9000, chs = CHS[3004108], value = 1568},
        [7] = {nimbus = 10000, chs = CHS[3004108], value = 2134},
        [8] = {nimbus = 11000, chs = CHS[3004108], value = 2787},
        [9] = {nimbus = 12000, chs = CHS[3004108], value = 3528},
        [10] = {nimbus = 13000, chs = CHS[3004108], value = 4356},
        [11] = {nimbus = 14000, chs = CHS[3004108], value = 5270},
        [12] = {nimbus = 15000, chs = CHS[3004108], value = 6272},
    },
}

local BIG_TAG = {
    CHS[5410245],   -- 妖石
    CHS[4200733],
    CHS[5410246],   -- 宝石
    CHS[5410247],   -- 耐久
}

local NAIJIU_ATT_CHS = {
    [CHS[5410239]] = CHS[5410253], -- 火眼金睛
    [CHS[5410240]] = CHS[5410253], -- 通天令牌
    [CHS[5410241]] = CHS[5410255], -- 血玲珑
    [CHS[5410242]] = CHS[5410254], -- 法玲珑
    [CHS[5410243]] = CHS[5410255], -- 中级血玲珑
    [CHS[5410244]] = CHS[5410254], -- 中级法玲珑
}

-- 宝石可合成的下一物品
local GEM_ALCHEMY_TO = {
    [CHS[4100421]] = CHS[4100422], -- 蓝松石
    [CHS[4100422]] = CHS[4100423], -- 芙蓉石
    [CHS[4100423]] = CHS[4100424], -- 红宝石
}


local ATTRIBUTE_MAP = {

    [CHS[4200735]] = CHS[4200756],
    [CHS[4200736]] = CHS[4200757],
    [CHS[4200737]] = CHS[4200755],
    [CHS[4200738]] = CHS[4200758],
    [CHS[4200739]] = CHS[4200759],
    [CHS[4200740]] = CHS[4200753],

}

-- 颜色到等级的转换
local COLOR_TO_LEVEL = {
    [CHS[7120248]] = 1,     -- 绿色
    [CHS[7120249]] = 2,     -- 紫色
}

function AlchemyDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("SynthesisButton", self.onSynthesisButton)
    self:bindListener("AllSynthesisButton", self.onAllSynthesisButton)
    self:bindCheckBoxListener("BindCheckBox", self.onCheckBox)
    self:bindListener("LevelPanel", self.onLevelPanel)
    self:bindListener("EnoughPanel", self.onEnoughPanel)
    self:bindListener("ALLButton", self.onAllButton)
    self:bindListener("EnoughButton", self.onEnoughButton)

    self:bindFloatPanelListener("LevelBKImage", "LevelPanel", nil, self.onClickOutLevelPanel)
    self:bindFloatPanelListener("LevelBKImage1", "LevelPanel", nil, self.onClickOutLevelPanel)

    -- 材料列表单元格
    self.smallCell = self:retainCtrl("SmallPanel")
    self.bigCell = self:retainCtrl("BigPanel")
    self.noneCell = self:retainCtrl("NoneLabel")

    self.smallSelectImage = self:retainCtrl("ChosenImage", self.smallCell)
    self.bigSelectImage = self:retainCtrl("BChosenEffectImage", self.bigCell)

    self.levelCell = self:retainCtrl("LevelButton")

    self.firstType = nil -- 一级标签
    self.isOpen = true
    self.secondType = nil
    self.curAlchemyCout = 0
    self.isFinishNaijiu = true
    self.needRefreshItems = {}

    self:initData()
    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_MERGE_DURABLE_ITEM")
end

function AlchemyDlg:MSG_MERGE_DURABLE_ITEM(data)
    if data.flag == 1 then
        -- 合成成功
        self:comPoundRefreshUi()
    end

    self.isFinishNaijiu = true
    self.curAlchemyCout = self.curAlchemyCout - 1
end

function AlchemyDlg:MSG_INVENTORY(data)
    for _, v in ipairs(data) do
        if v.name then
            self.needRefreshItems[v.name] = true
            if GEM_ALCHEMY_TO[v.name] then
                -- 该道具对应的合成后的道具也要刷新
                self.needRefreshItems[GEM_ALCHEMY_TO[v.name]] = true
            end
        end
    end

    -- 合成的过程中收到该消息不刷新，统一合成结束刷新
    if self.curAlchemyCout == 0 then
        self:comPoundRefreshUi()
    end
end

function AlchemyDlg:setCheckState()
    if self.firstType == CHS[5410247] then
        -- 耐久
        if InventoryMgr:getLimitItemFlag(self.name .. "_naijiu", 1) == 1 then
            self:setCheck("BindCheckBox", true)
        elseif InventoryMgr:getLimitItemFlag(self.name .. "_naijiu", 1) == 0 then
            self:setCheck("BindCheckBox", false)
        end

        self:setLabelText("BindLabel1", CHS[5410256], "SelectPanel")
    else
        if InventoryMgr:getLimitItemFlag(self.name, 1) == 1 then
            self:setCheck("BindCheckBox", true)
        elseif InventoryMgr:getLimitItemFlag(self.name, 1) == 0 then
            self:setCheck("BindCheckBox", false)
        end

        self:setLabelText("BindLabel1", CHS[5410257], "SelectPanel")
    end
end

function AlchemyDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_FINISH_ALCHEMY == data.notify  then
        if data.para == "1" then
            self:comPoundRefreshUi()
        end

        self.curAlchemyCout = self.curAlchemyCout - 1
    end
end

-- 初值列表数据
function AlchemyDlg:initListPanel(data, cellColne, func, panel, colunm)
    panel:removeAllChildren()
    local contentLayer = ccui.Layout:create()
    local line = math.floor(#data / colunm)
    local left = #data % colunm

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0
    local totalHeight = line * (cellColne:getContentSize().height + LINE_SPACE)

    for i = 1, line do
        if i == line and left ~= 0 then
            curColunm = left
        else
            curColunm = colunm
        end

        for j = 1, curColunm do
            local tag = j + (i - 1) * colunm
            local cell = cellColne:clone()
            cell:setAnchorPoint(0,1)
            local x = (j - 1) * (cellColne:getContentSize().width + LINE_SPACE)
            local y = totalHeight - (i - 1) * (cellColne:getContentSize().height + LINE_SPACE)
            cell:setPosition(x, y)
            cell:setTag(tag)
            func(self, cell , data[tag], tag)
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

function AlchemyDlg:initData()
    self.allItemList = AlchemyMgr:getItemList(self:getCheckBoxCurState())
    self.fullItemList = AlchemyMgr:getFullItem()
    self:refreshAllItemType()
end

function AlchemyDlg:getCheckBoxCurState()
    return InventoryMgr:getLimitItemFlag(self.name, 1) == 1, InventoryMgr:getLimitItemFlag(self.name .. "_naijiu", 1) == 1
end

-- 合成后刷新ui
function AlchemyDlg:comPoundRefreshUi()
    for name, _ in pairs(self.needRefreshItems) do
        AlchemyMgr:updateOneItemList(name, self:getCheckBoxCurState())
    end

    self.needRefreshItems = {}

    if MainType2 == self.mainType then
        self.curAllItemList = self.allItemList[self.firstType]
        self:setNextCompoundItem()
    elseif MainType1 == self.mainType then
        self.curAllItemList = self.fullItemList[self.firstType]
        self:setNextCompoundItem()
    end
end

-- 更具道具名称获取一级标签
function AlchemyDlg:getFirstTypeByItemName(name)
    for i = 1, #BIG_TAG do
        local type = BIG_TAG[i]
        local itemList = ALL_ITEM_LIST[type]
        for j = 1, #itemList do
            if itemList[j] == name then
                return type, i
            end
        end
    end
end

-- 滑到某一道具标签
function AlchemyDlg:scrollToOneItem(firstType, secondType)
    if not firstType or not secondType then return end
    local listView = self:getControl("CategoryListView")
    local item = listView:getChildByName(secondType)
    local firstItem = listView:getChildByName(firstType)
    if item and firstItem then
        listView:requestRefreshView()
        listView:doLayout()

        local InnerContainerSize = listView:getInnerContainer():getContentSize()
        local listSize = listView:getContentSize()
        local tag = item:getTag()
        local margin = listView:getItemsMargin()
        local firstTag = firstItem:getTag()
        local firstHight = firstTag * firstItem:getContentSize().height + (firstTag - 1) * margin
        local heightY = tag * (item:getContentSize().height + margin) + firstHight

        if heightY > listSize.height then
            listView:getInnerContainer():setPositionY(heightY - InnerContainerSize.height)
        end
    end
end

-- 配置  AlchemyDlg=道具名:等级
function AlchemyDlg:onDlgOpened(param)
    local firstType = self:getFirstTypeByItemName(param[1])
    if not firstType then return end

    self:refreshAllItemType(firstType, param[1])

    self:scrollToOneItem(firstType, param[1])

    if COLOR_TO_LEVEL[param[2]] then
        -- 颜色转换等级
        local level = COLOR_TO_LEVEL[param[2]]
        if level then
            self.thirdType = level
            self:refreshPanelData()
        end
    else
        -- 点击具体等级妖石的“合成”来源项，需要链接到对应等级的妖石合成界面
        -- 目前合成界面中，仅有妖石存在等级
        local level = tonumber(param[2])
        if level then
            if level > #TOTAL_INFO[param[1]] then
                -- 传入等级超过最高可合成等级，取最高可合成等级
                level = #TOTAL_INFO[param[1]]
            end

            if level and level > 1 then
                -- 妖石合成中的三级菜单项与妖石本身的等级存在对应关系
                self.thirdType = level - 1
                self:refreshPanelData()
            end
        end
    end
end

function AlchemyDlg:setNextCompoundItem()
	if not self.secondType or not self.thirdType then
        self:refreshItemType(self.firstType, self.secondType)
	    return
	end

    if not self.curAllItemList[self.secondType] and MainType1 == self.mainType then -- 没有该配方
        self:refreshFullItemType()
	else
        self:initListView(self.mainType)
        self.thirdType = self:getThirdType()
        self:refreshSelectLevel(self.curAllItemList[self.secondType][self.thirdType]["targetItem"].level)
	end

    self:refreshAlchemyPanel()
end

-- 设置一级标签内容
function AlchemyDlg:setBigPanel(name, cell)



    local str = string.sub(name, 1, 3) .. "    " .. string.sub(name, 4, 6)
    self:setLabelText("Label", str, cell)

    -- 长度大于6的，不处理
    if string.len( name ) > 6 then
        self:setLabelText("Label", name, cell)
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onClickBigCell(sender, eventType)
        end
    end

    cell:addTouchEventListener(listener)
end

function AlchemyDlg:initListView(mainType)
    local listView =  self:getControl("CategoryListView", Const.UIListView)
    listView:removeAllItems()

    local secondType, firstType = self:getDefItemNameByType(mainType, self.firstType)
    if (mainType == MainType1
            and (not self.fullItemList[firstType][self.secondType] or #self.fullItemList[firstType][self.secondType] <= 0))
        or not self.secondType then
        self.secondType = secondType
    end

    for i = 1, #BIG_TAG do
        local bigCell = self.bigCell:clone()
        bigCell:setName(BIG_TAG[i])
        bigCell:setTag(i)
        self:setBigPanel(BIG_TAG[i], bigCell)
        listView:pushBackCustomItem(bigCell)

        if firstType == BIG_TAG[i] then
            self.firstType = BIG_TAG[i]
            self:addBigSelcelImage(bigCell)
        end

        local selectItem
        if self.firstType == BIG_TAG[i] and self.isOpen then
            if mainType ~= MainType1 or self:tableIsExistElement(self.fullItemList[BIG_TAG[i]]) then
                local index = 1
                for i = 1, #ALL_ITEM_LIST[self.firstType] do
                    local itemName = ALL_ITEM_LIST[self.firstType][i]
                    if mainType == MainType2
                        or (self.fullItemList[self.firstType][itemName] and #self.fullItemList[self.firstType][itemName] > 0) then
                        local cell = self.smallCell:clone()
                        cell:setTag(index)
                        cell:setName(itemName)
                        self:setSmallCell(itemName, cell)
                        listView:pushBackCustomItem(cell)

                        if self.secondType == itemName then
                            self:addSelcelImage(cell)
                        end

                        index = index + 1
                    end
                end
            else
                -- 没有充足的配方显示提示
                local cell = self.noneCell:clone()
                listView:pushBackCustomItem(cell)
            end

            self:setCtrlVisible("UpArrowImage", true, bigCell)
            self:setCtrlVisible("DownArrowImage", false, bigCell)
        else
            self:setCtrlVisible("UpArrowImage", false, bigCell)
            self:setCtrlVisible("DownArrowImage", true, bigCell)
        end
    end

    listView:jumpToTop()

    self:scrollToOneItem(self.firstType, self.secondType)
end

-- 根据类型优先返回材料充足的
function AlchemyDlg:getDefItemNameByType(mainType, defFType)
    for i = 1, #BIG_TAG do
        local type = BIG_TAG[i]
        local itemList = ALL_ITEM_LIST[type]
        if not defFType or defFType == type then
            for j = 1, #itemList do
                if self.fullItemList[type] and self.fullItemList[type][itemList[j]] and #self.fullItemList[type][itemList[j]] > 0 then
                    return itemList[j], type
                end
            end
        end
    end

    defFType = defFType or BIG_TAG[1]
    return ALL_ITEM_LIST[defFType][1], defFType
end

function AlchemyDlg:setSmallCell(name, cell)
    local showName = string.match(name, "(.+)·*.*") or name
    self:setLabelText("NameLabel", showName, cell)

    local imgPath = ResMgr:getItemIconPath(InventoryMgr:getIconByName(name))
    if self.firstType == CHS[4200733] then
        imgPath = ResMgr:getItemIconPath(InventoryMgr:getIconByName(name .. CHS[4200734]))
    end
    self:setImage("DemonStoneImage", imgPath, cell)
    self:setItemImageSize("DemonStoneImage", cell)

    local button = self:getControl("DemonStoneButton1", nil, cell)
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onClickSmallCell(sender:getParent(), eventType)
        end
    end

    button:addTouchEventListener(listener)
end

function AlchemyDlg:onAllButton()
    if self.mainType == MainType2 then return end
    self:refreshAllItemType()

    self:setCtrlVisible("Image", false, "EnoughPanel")
    self:setCtrlVisible("Image", true, "AllPanel")
end

function AlchemyDlg:onEnoughButton(sender)
    if self.mainType == MainType1 then  return end
    self:refreshFullItemType()

    self:setCtrlVisible("Image", true, "EnoughPanel")
    self:setCtrlVisible("Image", false, "AllPanel")
end

-- 传入 nil 时，会自动选中默认选项
function AlchemyDlg:refreshItemType(firstType, secondType, thirdType, isOpen)
    if self.mainType == MainType1 then
        self:refreshFullItemType(firstType, secondType, thirdType, isOpen)
    else
        self:refreshAllItemType(firstType, secondType, thirdType, isOpen)
    end
end

-- 显示所有材料列表
function AlchemyDlg:refreshAllItemType(firstType, secondType, thirdType, isOpen)
    self.mainType = MainType2
    self.secondType = secondType
    self.thirdType = thirdType
    if not firstType or self.firstType ~= firstType or self.isOpen ~= isOpen then
        -- 切换一级标签或未初始化一级标签需要重新创建列表
        self.firstType = firstType
        self.isOpen = isOpen == nil and true or isOpen
        self:initListView(self.mainType)
    end

    self.curAllItemList = self.allItemList[self.firstType]
    self.thirdType = self:getThirdType()
    self:refreshPanelData()
end

-- 显示材料充足列表
function AlchemyDlg:refreshFullItemType(firstType, secondType, thirdType, isOpen)
    self.mainType = MainType1
    self.secondType = secondType
    self.thirdType = thirdType
    if not self.firstType or self.firstType ~= firstType or self.isOpen ~= isOpen then
        -- 切换一级标签或未初始化一级标签需要重新创建列表
        self.firstType = firstType
        self.isOpen = isOpen == nil and true or isOpen
        self:initListView(self.mainType)
    end

    self.curAllItemList = self.fullItemList[self.firstType] or {}
    if self:tableIsExistElement(self.curAllItemList) and self.secondType then
        self.thirdType = self:getThirdType()
        self:refreshPanelData()
    else
        self:clearAlchemyPanel()
        self:setCtrlVisible("LevelPanel", false)
    end
end

function AlchemyDlg:tableIsExistElement(table)
    if table then
        for k, v in pairs(table) do
            if #v > 0 then
                return true
            end
        end
    end

    return false
end

function AlchemyDlg:onClickOutLevelPanel()
    self:setCtrlVisible("LevelBKImage", false)
    self:setCtrlVisible("LevelBKImage1", false)
end

function AlchemyDlg:onLevelPanel()
    if not self.secondType then return end

    local panel = nil
    local levelBKImage = self:getControl("LevelBKImage")
    local levelBKImage1 = self:getControl("LevelBKImage1")
    if levelBKImage:isVisible() or levelBKImage1:isVisible() then
        self:setCtrlVisible("LevelBKImage", false)
        self:setCtrlVisible("LevelBKImage1", false)
    else
        if self.curAllItemList[self.secondType] and #self.curAllItemList[self.secondType] <= 4 then
            panel = self:getControl("OneRowLevelListPanel")
            AlchemyDlg:initListPanel(self.curAllItemList[self.secondType], self.levelCell, self.initLevelCell, panel, 1)
            self:setCtrlVisible("LevelBKImage", false)
            self:setCtrlVisible("LevelBKImage1", true)
        else
            panel = self:getControl("TwoRowLevelListPanel")
            AlchemyDlg:initListPanel(self.curAllItemList[self.secondType], self.levelCell, self.initLevelCell, panel, 2)
            self:setCtrlVisible("LevelBKImage", true)
            self:setCtrlVisible("LevelBKImage1", false)
        end

    end
end

function AlchemyDlg:initLevelCell(cell, data, tag)
    cell:setVisible(true)
    self:setLabelText("Label", data.targetItem.level .. CHS[3002256], cell)
    if type(data.targetItem.level) == "string" then
        self:setLabelText("Label", data.targetItem.level, cell)
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onClickOutLevelPanel()
            self:refreshSelectLevel(data.targetItem.level)
            self.thirdType = tag
            self:refreshAlchemyPanel()
        end
    end

    cell:addTouchEventListener(listener)
end

-- 刷新选中按钮等级
function AlchemyDlg:refreshSelectLevel(level)

    if type(level) == "number" then
        local levelPanel = self:getControl("LevelPanel")
        levelPanel:setVisible(level ~= 0)
	    self:setLabelText("LevelLabel", level .. CHS[3002256], levelPanel)
    else
        local levelPanel = self:getControl("LevelPanel")
        levelPanel:setVisible(true)
        self:setLabelText("LevelLabel", level, levelPanel)
    end
end

-- 一二级菜单单元格
function AlchemyDlg:createCell(name, cell)
    local label = self:getControl("Label", Const.UILabel, cell)
    label:setString(name)
end

function AlchemyDlg:onClickBigCell(sender, enventType)
    local type = sender:getName()
    if self.firstType == type then
        self:refreshItemType(self.firstType, self.secondType, self.thirdType, not self.isOpen)
    else
        self:refreshItemType(type, nil, nil, true)
    end
end

function AlchemyDlg:onClickSmallCell(sender, enventType)
    local type = sender:getName()
    if self.secondType == type then return end

    self:addSelcelImage(sender)
    self:refreshItemType(self.firstType, type, self.thirdType, self.isOpen)
end

function AlchemyDlg:refreshPanelData()
    if not self.curAllItemList or not self.secondType then
        return
    end

    self:refreshSelectLevel(self.curAllItemList[self.secondType][self.thirdType]["targetItem"].level)
    self:refreshAlchemyPanel()
end

function AlchemyDlg:clearAlchemyPanel()
    -- 清除上次选中的资源
    self:setLeftItemInfo()
    self:setRightItemInfo()

    self:setCtrlVisible("InfoPanel", false)
    self:setCtrlVisible("NotePanel", false)
    self:setCtrlVisible("AttribPanel_1", false)
    self:setCtrlVisible("AttribPanel_2", false)
end

function AlchemyDlg:getThirdType()
    local  itemList = self.curAllItemList[self.secondType]
    local  thirdType = nil
    for i = 1, #itemList do
        if itemList[i]["count"] > 0 then
            thirdType = i
            break
        end
    end

    if (self.thirdType and itemList[self.thirdType] and itemList[self.thirdType]["count"] > 0) or  not thirdType then
        thirdType = self.thirdType
    end

    return  thirdType or 1
end

function AlchemyDlg:setLeftItemInfo(itemInfo)
    local panel = self:getControl("LeftPanel")

    if not itemInfo then
        self:setCtrlVisible("EmptyImage", true, panel)
        self:setLabelText("ItemNameLabel", "", panel)
        self:setLabelText("ItemNumLabel", "", panel)
        return
    end

    self:setCtrlVisible("EmptyImage", false, panel)
    self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(itemInfo["name"])), panel)
    self:setItemImageSize("ItemImage", panel)

    -- 点击目标道具显示道具名片
    self:setStoneItem(panel, itemInfo)

    if itemInfo.level == 0 then
        self:setLabelText("ItemNameLabel", itemInfo.name, panel)
    else
        self:setLabelText("ItemNameLabel", string.format(CHS[4100316], itemInfo.level, itemInfo.name), panel)
    end

    if itemInfo.oneItemNeedNum == -1 then
        self:setLabelText("ItemNumLabel", string.format(CHS[4100315], itemInfo["num"]), panel)
    elseif itemInfo.num > 999 then
        self:setLabelText("ItemNumLabel", string.format("*/%d", itemInfo["oneItemNeedNum"]), panel)
    else
        self:setLabelText("ItemNumLabel", string.format("%d/%d", itemInfo.num, itemInfo["oneItemNeedNum"]), panel)
    end
end

function AlchemyDlg:setRightItemInfo(itemInfo, targetItem)
    local panel = self:getControl("RightPanel")

    if not itemInfo then
        self:setCtrlVisible("EmptyImage", true, panel)
        self:setLabelText("ItemNameLabel", "", panel)
        self:setLabelText("ItemNumLabel", "", panel)
        return
    end

    self:setCtrlVisible("EmptyImage", false, panel)

    self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(targetItem.name)), panel)
    self:setItemImageSize("ItemImage", panel)

    -- 点击目标道具显示道具名片
    self:setStoneItem(panel, targetItem)

    if type(targetItem.level) == "string" then
        self:setLabelText("ItemNameLabel", targetItem.name, panel)
    elseif targetItem.level == 0 then
        self:setLabelText("ItemNameLabel", targetItem.name, panel)
    else
        self:setLabelText("ItemNameLabel", string.format(CHS[4100316], targetItem.level, targetItem.name), panel)
    end

    -- 永久限制交易道具
    local itemImg = self:getControl("ItemImage", nil, panel)
    if targetItem.bind then
        InventoryMgr:addLogoBinding(itemImg)
    else
        InventoryMgr:removeLogoBinding(itemImg)
    end

    -- 融合标识
    if InventoryMgr:isFuseItem(targetItem.name) then
        InventoryMgr:addLogoFuse(itemImg)
    else
        InventoryMgr:removeLogoFuse(itemImg)
    end

    if itemInfo["type"] == CHS[5410247] then
        if itemInfo["methods"] then
            self:setLabelText("ItemNumLabel", string.format(CHS[4100315], #itemInfo["methods"]), panel)
        end
    else
        local max = math.floor(itemInfo.num / 3)
        self:setLabelText("ItemNumLabel", string.format(CHS[4100315], max), panel)
    end
end

-- 设置耐久道具上限
function AlchemyDlg:setAttriPanel1(itemInfo, targetItem)
    local panel = self:getControl("AttribPanel_1")
    if itemInfo["max_value"] and targetItem then
        local tip = CHS[5410250]
        local value = itemInfo["max_value"]
        if value > 10000 then
            value = math.floor(value / 10000)
            tip = CHS[5410259]
        end

        self:setLabelText("AttribLabel_1", string.format(tip, NAIJIU_ATT_CHS[targetItem["name"]], value / 10), panel)
        self:setLabelText("AttribLabel_2", string.format(tip, NAIJIU_ATT_CHS[targetItem["name"]], value), panel)
    else
        self:setLabelText("AttribLabel_1", "", panel)
        self:setLabelText("AttribLabel_2", "", panel)
    end
end

-- 设置玩具属性{["bindAmount"] = 0,["level"] = 0,["name"] = "竹马（绿色）",["num"] = 0,["oneItemNeedNum"] = 3,["type"] = "娃娃玩具"}
function AlchemyDlg:setToyEff(itemInfo, targetItem)
    local panel = self:getControl("AttribPanel_2")

    local color = string.match(itemInfo.name, "（(.+)）")
--ATTRIBUTE_MAP
    local name = string.match(itemInfo.name, "(.+)（")

    self:setLabelText("AttribLabel_1", ATTRIBUTE_MAP[name] .. ":" .. HomeChildMgr:getEffectByToyName(itemInfo.name), panel)
    self:setLabelText("AttribLabel_2", string.format(CHS[4200765], HomeChildMgr:getNaijiuByColor(color)), panel)

    local color = string.match(targetItem.name, "（(.+)）")
    self:setLabelText("AttribLabel_3", ATTRIBUTE_MAP[name] .. ":" .. HomeChildMgr:getEffectByToyName(targetItem.name), panel)
    self:setLabelText("AttribLabel_4", string.format(CHS[4200765], HomeChildMgr:getNaijiuByColor(color)), panel)
end

-- 设置妖石属性数值
function AlchemyDlg:setAttriPanel2(itemInfo, targetItem)
    local panel = self:getControl("AttribPanel_2")
    if TOTAL_INFO[itemInfo.name] then
        self:setLabelText("AttribLabel_1", string.format(CHS[4100314], TOTAL_INFO[itemInfo.name][itemInfo.level].nimbus), panel)
        self:setLabelText("AttribLabel_2", TOTAL_INFO[itemInfo.name][itemInfo.level].chs .. TOTAL_INFO[itemInfo.name][itemInfo.level].value, panel)
    else
        self:setLabelText("AttribLabel_1", "", panel)
        self:setLabelText("AttribLabel_2", "", panel)
    end

    if TOTAL_INFO[targetItem.name] then
        self:setLabelText("AttribLabel_3", string.format(CHS[4100314], TOTAL_INFO[targetItem.name][targetItem.level].nimbus), panel)
        self:setLabelText("AttribLabel_4", TOTAL_INFO[targetItem.name][targetItem.level].chs .. TOTAL_INFO[targetItem.name][targetItem.level].value, panel)
    else
        self:setLabelText("AttribLabel_3", "", panel)
        self:setLabelText("AttribLabel_4", "", panel)
    end
end

function AlchemyDlg:refreshAlchemyPanel()
    if not self.secondType or not self.thirdType then return end
    self:clearAlchemyPanel()

    local itemList = self.curAllItemList[self.secondType][self.thirdType]["itemsList"] -- 合成的道具材料队列
    local targetItem = self.curAllItemList[self.secondType][self.thirdType]["targetItem"]


    if itemList == nil or targetItem == nil then return end

    self:setLeftItemInfo(itemList[1])
    self:setRightItemInfo(itemList[1], targetItem)

    if itemList[1] and targetItem then
        if self.firstType == CHS[5410245] then
            -- 妖石
            self:setCtrlVisible("InfoPanel", true)
            self:setCtrlVisible("AttribPanel_2", true)
            self:setAttriPanel2(itemList[1], targetItem)
        elseif self.firstType == CHS[5410247] then
            -- 耐久
            self:setCtrlVisible("NotePanel", true)
            self:setCtrlVisible("AttribPanel_1", true)
            self:setAttriPanel1(itemList[1], targetItem)
        elseif self.firstType == CHS[4200733] then
            self:setCtrlVisible("InfoPanel", false)
            self:setCtrlVisible("AttribPanel_2", true)
            self:setToyEff(itemList[1], targetItem)
        end
    end
end

-- 设置点击妖石或宝石时显示对应的名片
function AlchemyDlg:setStoneItem(panel, item)
    local itemShapePanel = self:getControl("ItemShapePanel", Const.UIPanel, panel)
    local emptyImage = self:getControl("EmptyImage", Const.UIImage, panel)
    itemShapePanel:setTouchEnabled(true)

    local function touch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            -- 没有妖石或宝石就什么都不显示
            if emptyImage:isVisible() then return end
            local rect = self:getBoundingBoxInWorldSpace(sender)
            if string.match(item.name, "（(.+)色）") then
                item.color = string.match(item.name, "（(.+)）")
            end

            InventoryMgr:showBasicMessageByItem(item, rect)
        end
    end
    itemShapePanel:addTouchEventListener(touch)
end

function AlchemyDlg:setTargetItem(panel, item)
    local function touch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            local rect = self:getBoundingBoxInWorldSpace(sender)
            InventoryMgr:showBasicMessageDlg(item["name"], rect)
        end
    end

    -- 目标道具图片
    local imgPath = ResMgr:getItemIconPath(InventoryMgr:getIconByName(item["name"]))
    local iconImg = ccui.ImageView:create(imgPath)
    iconImg:setPosition(panel:getContentSize().width / 2, panel:getContentSize().height / 2)
    gf:setItemImageSize(iconImg)
    panel:addChild(iconImg)

    -- 等级
    self:setNumImgForPanel(panel, ART_FONT_COLOR.NORMAL_TEXT, item["level"], false, LOCATE_POSITION.LEFT_TOP, 19)

    panel:addTouchEventListener(touch)
end

function AlchemyDlg:addSelcelImage(sender)
    local button = self:getControl("DemonStoneButton1", nil, sender)
    self.smallSelectImage:removeFromParent()
    button:addChild(self.smallSelectImage)
end

function AlchemyDlg:addBigSelcelImage(sender)
    self.bigSelectImage:removeFromParent()
    sender:addChild(self.bigSelectImage)

    self:setCheckState()
end

function AlchemyDlg:getTypes(tag)
    local type = math.floor(tag / MainType1) * MainType1
    local secondType = math.floor((tag - type) / SecondType)
    local tirdType = tag % SecondType

    return type, secondType, tirdType
end

function AlchemyDlg:onBuyButton(sender, eventType)
    DlgMgr:openDlg("MarketBuyDlg")
end

function AlchemyDlg:onSynthesisButton(sender, eventType)
    self:synthesis(1)
end

function AlchemyDlg:onAllSynthesisButton(sender, eventType)
    self:synthesis(2)
end

function AlchemyDlg:checkHasNaijiuTip()
    local ti = cc.UserDefault:getInstance():getIntegerForKey("AlchemyDlg_naijiu" .. gf:getShowId(Me:queryBasic("gid")), 0)
    local cruTime = gf:getServerTime()
    if not gf:isSameDay5(cruTime, ti) then
        cc.UserDefault:getInstance():setIntegerForKey("AlchemyDlg_naijiu" .. gf:getShowId(Me:queryBasic("gid")), cruTime)
        return false
    else
        return true
    end
end

function AlchemyDlg:synthesisNaijiu(achemyType, achemyItem)
    if not self.isFinishNaijiu then
        return
    end

    local itemList = achemyItem["itemsList"]
    local methods = itemList[1]["methods"]
    if methods and #methods > 0 then
        local hasNotBind = false
        local data = {}
        if achemyType == 1 then
            data = {methods[1]}
            data.index = achemyItem["index"]
        else
            data = methods
            data.index = achemyItem["index"]
        end

        for i = 1, #data do
            local count = #data[i]
            if data[i]["bindAmount"] < count then
                hasNotBind = true
                break
            end
        end

        if hasNotBind and not self:checkHasNaijiuTip() then
            gf:confirm(CHS[5410248], function()
                AlchemyMgr:alchemyNaijiu(data)
                self.curAlchemyCout = self.curAlchemyCout + 1
                self.isFinishNaijiu = false
            end)
        else
            AlchemyMgr:alchemyNaijiu(data)
            self.curAlchemyCout = self.curAlchemyCout + 1
            self.isFinishNaijiu = false
        end
    else
        gf:ShowSmallTips(CHS[3002259])
    end

end

function AlchemyDlg:synthesis(achemyType)
    if not DistMgr:checkCrossDist() then return end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if not InventoryMgr:getFirstEmptyPos() then
        gf:ShowSmallTips(CHS[3002258])
        return
    end

    if not self.secondType or  not self.thirdType or not self.firstType then
        gf:ShowSmallTips(CHS[3002259])
        return
    end

    local achemyItem = self.curAllItemList[self.secondType][self.thirdType]  -- 合成的道具材料队列

    if achemyItem == nil then return end

    if achemyItem["count"] < 1 then
        gf:ShowSmallTips(CHS[3002259])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("synthesis", achemyType) then
        return
    end

    if self.firstType == CHS[5410247] then
        -- 耐久道具
        self:synthesisNaijiu(achemyType, achemyItem)
        return
    end

    local itemList = achemyItem["itemsList"]
    local isLimted= false
    for i = 1, #itemList do
        local item = itemList[i]

        if item["bindAmount"] > 0 then      -- 该材料含有绑定物品
            isLimted = true
            break
        end
    end

    local type   -- 1表示：炼制且使用非限制道具  2表示：炼制且使用限制道具  3表示：一键炼制且使用非限制道具  4表示：一键炼制且使用限制道具
    if self:isCheck("BindCheckBox") then
        if achemyType == 1 then
            type = 2
        else
            type = 4
        end
    else
        if achemyType == 1 then
            type = 1
        else
            type = 3
        end
    end

    if self:isCheck("BindCheckBox")  and isLimted then
        gf:confirm(CHS[3002260], function()
            AlchemyMgr:alchemy(achemyItem["index"], type)
            self.curAlchemyCout = self.curAlchemyCout + 1
        end)
    else
        AlchemyMgr:alchemy(achemyItem["index"], type)
        self.curAlchemyCout = self.curAlchemyCout + 1
    end
end


function AlchemyDlg:onCheckBox(sender, type)
    if self.firstType == CHS[5410247] then
        -- 耐久
        if sender:getSelectedState() == true then
            InventoryMgr:setLimitItemDlgs(self.name .. "_naijiu", 1)
        else
            InventoryMgr:setLimitItemDlgs(self.name .. "_naijiu", 0)
        end

        local limted, naijiuLimited = self:getCheckBoxCurState()
        self.allItemList = AlchemyMgr:getItemList(limted, naijiuLimited)
    else
        if sender:getSelectedState() == true then
            InventoryMgr:setLimitItemDlgs(self.name, 1)
        else
            InventoryMgr:setLimitItemDlgs(self.name, 0)
        end

        local limted, naijiuLimited = self:getCheckBoxCurState()
        self.allItemList = AlchemyMgr:getItemList(limted)
    end

    self.fullItemList = AlchemyMgr:getFullItem()
    self.needRefreshItems = {}
    self:comPoundRefreshUi()
end

function AlchemyDlg:cleanup()
    self.mainType = nil
    self.secondType = nil
    self.thirdType = nil
    self.firstType = nil
end

return AlchemyDlg
