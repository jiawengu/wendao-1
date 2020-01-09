-- HomeStoreDlg.lua
-- Created by yangym Jun/20/2017
-- 储物室

local HomeStoreDlg = Singleton("HomeStoreDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local GridPanel = require('ctrl/GridPanel')

local LISTVIEW_MARGIN = 20
local BAG_GRID_MARGIN = 2
local BAG_ROW_NUM = 5
local BAG_COL_NUM = 5
local GRID_W = 74
local GRID_H = 74
local SCROLL_TIME = 0.7
local DELTA_TIME = 0.01
local AUTO_MOVE_DIST = 0
local ROW_SPACE = 6

local BAG_INDEX_START = 41
local STORE_INDEX_START = 501
local COUPLE_STORE_INDEX_START = 601

local TAOTAL_PAGE = 5
local TOTAL_BAG_PAGE = 5
local TOTAL_STORE_PAGE = 2
local TOTAL_STORE_PAGE_COUPLE = 4

local DEF_TIME = (60 * 2 +30) * 1000

local BAG_POS = {
    [1] = 0,
    [2] = -397.69,
    [3] = -795.94,
    [4]= -1194,
    [5] = -1591.3,
}

local STORE_CHECKBOX = {
    "StoreOneCheckBox",
    "StoreTwoCheckBox",
    "StoreThreeCheckBox",
    "StoreFourCheckBox",
}

local COUPLE_INFO = {
    ["StoreOneCheckBox"] = CHS[7002369],
    ["StoreTwoCheckBox"] = CHS[7002370],
    ["StoreThreeCheckBox"] = CHS[7002371],
    ["StoreFourCheckBox"] = CHS[7002372],
}

function HomeStoreDlg:init()
    self:bindListener("BagArrangementButton", self.onBagArrangementButton)
    self:bindListener("StoreArrangementButton", self.onStoreArrangementButton)

    StoreMgr:setStoreType(STORE_TYPE.HOME_STORE)
    self.isCouple = HomeMgr:isCoupleStore()
    self.isHusband = HomeMgr:isHusband()

    -- 获取背包的PageView控件
    self.bagListView = self:getControl("BagGridListView", Const.UIListView)
    self.bagListView:setTouchEnabled(true)
    self.bagLayout = self:getControl("BagPanel", Const.UIPanel, self:getControl("BagPanel", Const.UIPanel))
    self.bagListView:setItemsMargin(LISTVIEW_MARGIN)

    -- 获取储物室的PageView控件
    self.storeListView = self:getControl("StoreGridListView", Const.UIListView)
    self.storeListView:setTouchEnabled(true)
    self.storeLayout = self:getControl("StorePanel", Const.UIPanel, self:getControl("StorePanel", Const.UIPanel))
    self.storeListView:setItemsMargin(LISTVIEW_MARGIN)

    -- 单选框
    self.bagCheckTable = {
        self:getControl("BagTagCheckBox", Const.UICheckBox),
        self:getControl("LuggageOneTagCheckBox", Const.UICheckBox),
        self:getControl("LuggageTwoTagCheckBox", Const.UICheckBox),
        self:getControl("LuggageThreeTagCheckBox", Const.UICheckBox),
        self:getControl("LuggageFourTagCheckBox", Const.UICheckBox)
    }

    self.bagRadioGroup = RadioGroup.new()
    self.bagRadioGroup:setItems(self, {"BagTagCheckBox", "LuggageOneTagCheckBox", "LuggageTwoTagCheckBox",
        "LuggageThreeTagCheckBox", "LuggageFourTagCheckBox"}, self.onBagCheckBox)
    self.bagCheckTable[1]:setSelectedState(true)
    self:showPanelInCheckBox(self.bagCheckTable[1], true, self.bagCheckTable)

    if self.isCouple then
        -- 夫妻储物室
        self.storeCheckTable = {
            self:getControl("StoreOneCheckBox", Const.UICheckBox),
            self:getControl("StoreTwoCheckBox", Const.UICheckBox),
            self:getControl("StoreThreeCheckBox", Const.UICheckBox),
            self:getControl("StoreFourCheckBox", Const.UICheckBox)
        }
        self.storeRadioGroup = RadioGroup.new()
        self.storeRadioGroup:setItems(self, {"StoreOneCheckBox", "StoreTwoCheckBox",
            "StoreThreeCheckBox", "StoreFourCheckBox"}, self.onStoreCheckBox)
        self.storeCheckTable[1]:setSelectedState(true)
        self:showPanelInCheckBox(self.storeCheckTable[1], true, self.storeCheckTable)

    else
        self.storeCheckTable = {
            self:getControl("StoreOneCheckBox", Const.UICheckBox),
            self:getControl("StoreTwoCheckBox", Const.UICheckBox),
        }

        self.storeRadioGroup = RadioGroup.new()
        self.storeRadioGroup:setItems(self, {"StoreOneCheckBox", "StoreTwoCheckBox"}, self.onStoreCheckBox)
        self.storeCheckTable[1]:setSelectedState(true)
        self:showPanelInCheckBox(self.storeCheckTable[1], true, self.storeCheckTable)
    end

    self:initCheck(Me:getVipType())
    self:showCoupleUI()

    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_STORE")
    self:hookMsg("MSG_INSIDER_INFO")
    self.bagGridPanel = {}
    self.gridstorePanel = {}
    for i = 1, TOTAL_BAG_PAGE do
        self.bagGridPanel[i] = {}
    end

    for i = 1, self:getTotalStorePage() do
        self.gridstorePanel[i] = {}
    end


    self:showBagItems()
    self:showStoreItems()

    -- 向服务器请求储物室物品数据
    StoreMgr:cmdHomeStoreItemsInfo(self.isCouple)

    self.lastPercent = {[0] = 0, [1] = 0, [2] = 0}
    self.lastSelect = {[0] = 0, [1] = 0, [2] = 0}

    -- 1背包  2仓库
    self:bindPageScrollEvent(1)
    self:bindPageScrollEvent(2)

    EventDispatcher:addEventListener("doOpenDlgRequestData", self.onOpenDlgRequestData, self)
	if not self.lastBagIndex then
        -- 第一次打开
        self:setStoreLastPage()
        self:setPage(self:getMyFirstPageInStore(), 2, self.storeCheckTable[self:getMyFirstPageInStore()])
    else
        self:setStoreLastPage()
    end
    self:setTitle()
end

function HomeStoreDlg:bindPageScrollEvent(listType)
    self.mainLayout = self:getControl("TouchPanel", Const.UIPanel)

        -- pageView滚动事件
    local function onTouchBegan(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        local boxBag = self:getBoundingBoxInWorldSpace(self.bagListView)
        local boxStore = self:getBoundingBoxInWorldSpace(self.storeListView)
        if listType == 1 and cc.rectContainsPoint(boxBag, touchPos) then
            return true
        end
        if listType == 2 and cc.rectContainsPoint(boxStore, touchPos) then
            return true
        end

        return false
    end

    local function onTouchMove(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()

    end

    local function onTouchEnd(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()

        local percent = self:getCurScrollPercent(listType)

        if not percent then return end
        local isLeft = (percent - self.lastPercent[listType]) > 0

        self:checkCurPercent(percent, isLeft, listType)
        return true
    end


    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

        -- 添加监听
    local storeDispatcher = self.mainLayout:getEventDispatcher()
    storeDispatcher:addEventListenerWithSceneGraphPriority(listener, self.mainLayout)
end


function HomeStoreDlg:showCoupleUI()
    if not self.isCouple then
        return
    end

    -- 显示夫妻储物室的UI，有4页储物页
    self:setCtrlVisible("StoreThreeCheckBox", true)
    self:setCtrlVisible("StoreFourCheckBox", true)

    for k, v in pairs(COUPLE_INFO) do
        local panel = self:getControl(k)
        local chosenPanel = self:getControl("ChosenPanel", nil, panel)
        local unChosenPanel = self:getControl("UnChosenPanel", nil, panel)
        self:setLabelText("NameLabel_1", v, chosenPanel)
        self:setLabelText("NameLabel_2", v, chosenPanel)
        self:setLabelText("NameLabel_1", v, unChosenPanel)
        self:setLabelText("NameLabel_2", v, unChosenPanel)
    end

end

function HomeStoreDlg:getTotalStorePage()
    if self.isCouple then
        return TOTAL_STORE_PAGE_COUPLE
    else
        return TOTAL_STORE_PAGE
    end
end

function HomeStoreDlg:getMyFirstPageInStore()
    -- 根据当前是夫还是妻，获取属于他的第一页储物页；个人储物室直接返回第一页
    if self.isCouple and (not self.isHusband) then
        return 3
    else
        return 1
    end
end

-- 获取夫妻储物室中对方的第一页储物页位置
function HomeStoreDlg:getCoupleFirstPageInStore()
    if not self.isCouple then
        return 0
    end

    if self.isHusband then
        return 3
    else
        return 1
    end
end

function HomeStoreDlg:cleanup()
    EventDispatcher:removeEventListener("doOpenDlgRequestData", self.onOpenDlgRequestData, self)
    self:setLastOperTime("lastTime", gfGetTickCount())
    self.lastStIndex = self.storeRadioGroup:getSelectedRadioIndex()
    self.isCouple = nil
    self.isHusband = nil

    self.lastBagIndex = self.bagRadioGroup:getSelectedRadioIndex()
end

-- 设置标题
function HomeStoreDlg:setTitle()
    self:setLabelText("TitleLabel_1", self:getTitle())
    self:setLabelText("TitleLabel_2", self:getTitle())
end

-- 获取储物室标题
function HomeStoreDlg:getTitle()
    local type = HomeMgr:getHomeStoreType()
    if type == HOME_STORE_TYPE.SMALL then
        return CHS[7002323]
    elseif type == HOME_STORE_TYPE.MIDDLE then
        return CHS[7002324]
    elseif type == HOME_STORE_TYPE.BIG then
        return CHS[7002325]
    end
end

-- 置灰标签页
function HomeStoreDlg:initCheck(vip)
    for i = 1, self:getTotalStorePage() do
        if self:getHaveOpenStorePage()[i] then
            gf:resetImageView(self.storeCheckTable[i])
            gf:resetCheckSelectImageView(self.storeCheckTable[i])
        else
            gf:grayImageView(self.storeCheckTable[i])
            gf:grayCheckSelectImageView(self.storeCheckTable[i])
        end
    end

    for i = 1, TOTAL_BAG_PAGE do
        if i > self:getHaveOpenBagPage() then
            gf:grayImageView(self.bagCheckTable[i])
            gf:grayCheckSelectImageView(self.bagCheckTable[i])
        else
            gf:resetImageView(self.bagCheckTable[i])
            gf:resetCheckSelectImageView(self.bagCheckTable[i])
        end
    end
end

-- 背包已开启的页数
function HomeStoreDlg:getHaveOpenBagPage()
    local page = 2 -- 初值2页
    if Me:getVipType() > 0 and Me:getVipType() < 3 then
        page = page + 1 -- 月卡季卡加一页
    elseif Me:getVipType() == 3 then
        page = page + 2 -- 年卡加2页
    end

    local rideId = PetMgr:getRideId()
    if rideId and rideId > 0 then
        local pet = PetMgr:getPetById(rideId)

        if pet and PetMgr:isHaveFenghuaTime(pet) then
            page = page + 1 -- 骑乘状态的宠物还有风灵丸时间加一页
        end
    end

    return page
end

-- 储物室已开启的页数
function HomeStoreDlg:getHaveOpenStorePage()
    local pageInfo = {}
    local storeType = HomeMgr:getHomeStoreType()
    local maxPage = math.ceil(storeType / 2)
    if self.isCouple then
        -- 夫妻储物室
        -- 夫妻的储物室空间由当前储物室类型决定，且两者必然相同
        -- 夫妻双方看对方的储物室也算未开启
        for i = 1, TOTAL_STORE_PAGE do
            -- 夫
            pageInfo[i] = (i <= maxPage) and self.isHusband
        end

        for i = TOTAL_STORE_PAGE + 1, TOTAL_STORE_PAGE_COUPLE do
            -- 妻
            pageInfo[i] = (i <= (maxPage + 2)) and (not self.isHusband)
        end
    else
        -- 个人储物室
        for i = 1, TOTAL_STORE_PAGE do
            pageInfo[i] = (i <= maxPage)
        end
    end

    return pageInfo
end

-- 获取当前ListView滚动百分比
function HomeStoreDlg:getCurScrollPercent(listType)
    if listType == 0 then
        return
    elseif listType == 1 then
        local width = self.bagListView:getInnerContainer():getContentSize().width - self.bagListView:getContentSize().width
        local curPosX = self.bagListView:getInnerContainer():getPositionX()
        return curPosX / width * (-100)
    elseif listType == 2 then
        local width = self.storeListView:getInnerContainer():getContentSize().width - self.storeListView:getContentSize().width
        local curPosX = self.storeListView:getInnerContainer():getPositionX()
        return curPosX / width * (-100)
    end
end

-- 显示对应checkbox下的panel
function HomeStoreDlg:showPanelInCheckBox(checkBox, isShow, checkBoxList)
    local page
    for k, v in ipairs(checkBoxList) do
        if v ~= checkBox then
            local choosePanel = v:getChildByName("ChosenPanel")
            local unChoosePanel = v:getChildByName("UnChosenPanel")
            choosePanel:setVisible(false)
            unChoosePanel:setVisible(true)
            v:setSelectedState(false)
        else
            if k == 1 or k == 2 then
                if checkBoxList == self.bagListView then
                    local checkBox2 = self:getControl("LuggageTwoTagCheckBox", Const.UICheckBox)
                    local checkBox3 = self:getControl("LuggageThreeTagCheckBox", Const.UICheckBox)
                    self:setCtrlVisible("CoverImage", false, checkBox2)
                    self:setCtrlVisible("CoverImage", false, checkBox3)
                end
            end

            if checkBoxList == self.storeListView then
                for i = 1, #STORE_CHECKBOX do
                    if checkBox:getName() ~= STORE_CHECKBOX[i] then
                        local checkBox = self:getControl(m)
                        self:setCtrlVisible("CoverImage", false, checkBox)
                    end
                end
            end
        end
    end
    local choosePanel = checkBox:getChildByName("ChosenPanel")
    local unChoosePanel = checkBox:getChildByName("UnChosenPanel")
    choosePanel:setVisible(isShow)
    unChoosePanel:setVisible(not isShow)
    checkBox:setSelectedState(true)
end

-- 显示所有的物品信息
function HomeStoreDlg:showBagItems(isNotJumLeft)
    self.bag1 = InventoryMgr:getBag1Items() -- 包裹数据
    self.bag2 = InventoryMgr:getBag2Items() -- 行囊1数据
    self.bag3 = InventoryMgr:getBag3Items() -- 行囊2数据
    self.bag4 = InventoryMgr:getBag4Items() -- 行囊3数据
    self.bag5 = InventoryMgr:getBag5Items() -- 行囊4数据

    local totalBag = {self.bag1, self.bag2, self.bag3, self.bag4, self.bag5}
    self:initBagItemInfo(totalBag)
    if not isNotJumLeft then
        self.bagListView:jumpToLeft()
    end
end

function HomeStoreDlg:initBagItemInfo(bagData)
    self.bagListView:removeAllItems()
    for _, v in ipairs(bagData) do
        self:showItems(_, v, self.bagListView, false)
    end
end

-- 显示所有的物品信息
function HomeStoreDlg:showStoreItems(isNotJumLeft)
    local totalBag

    -- self.store1、self.store2一定是自己可操作的储物室
    self.store1 = StoreMgr:getHomeStore1Items()
    self.store2 = StoreMgr:getHomeStore2Items()

    -- 夫妻储物室中对方的储物室一
    self.store3 = StoreMgr:getCoupleHomeStore1Items()

    -- 夫妻储物室中对方的储物室二
    self.store4 = StoreMgr:getCoupleHomeStore2Items()
    if self.isCouple then
        -- 夫妻储物室
        if self.isHusband then
            totalBag = {self.store1, self.store2, self.store3, self.store4}
        else
            totalBag = {self.store3, self.store4, self.store1, self.store2}
        end
    else
        -- 个人储物室
        totalBag = {self.store1, self.store2}
    end

    self:initStoreItemInfo(totalBag)
    if not isNotJumLeft then
        self.storeListView:jumpToLeft()
    end
end

function HomeStoreDlg:initStoreItemInfo(bagData)
    self.storeListView:removeAllItems()
    for _, v in ipairs(bagData) do
        self:showItems(_, v, self.storeListView, true)
    end
end

function HomeStoreDlg:isBagGray(page)
    if page > self:getHaveOpenBagPage() then
        return true
    end

    return false
end

function HomeStoreDlg:isStoreGray(page)
    -- 此页是否所有格子都未开启（夫妻双方看对方的储物室算作“未开启”）
    if self:getHaveOpenStorePage()[page] then
        return false
    end

    return true
end

function HomeStoreDlg:getGrayGridByPage(page)
    -- 获取当前页未开启的格子(三种储物空间的格子数目分别为10, 25, 50)
    -- (与isStoreGray不同，此函数并不考虑夫妻双方看对方储物室的情况，即此情况并不是全部置灰)
    if page > TOTAL_STORE_PAGE then
        -- 夫妻居所有可以有3、4页，且第3、4页的格子数与第1、2页的相同
        page = page - TOTAL_STORE_PAGE
    end

    local gridsEveryPage = BAG_ROW_NUM * BAG_COL_NUM
    local maxGrid = HomeMgr:getMaxGridByHomeStoreType(HomeMgr:getHomeStoreType())
    local res = {}
    for i = 1, gridsEveryPage do
        local isGray =  (i + (page - 1) * gridsEveryPage) > maxGrid
        table.insert(res, isGray)
    end

    return res
end

function HomeStoreDlg:removeLastSelect()
    self.lastSelect = {[1] = 0, [2] = 0}
end

-- 显示物品信息
function HomeStoreDlg:showItems(index, data, listViewCtrl, isStore)
    local size = listViewCtrl:getContentSize()
    local layout = ccui.Layout:create()
    layout:setContentSize(size)

    local h = BAG_ROW_NUM * (GRID_H + BAG_GRID_MARGIN) + BAG_GRID_MARGIN
    local grids = GridPanel.new(
        size.width, size.height,
        BAG_ROW_NUM, BAG_COL_NUM,
        GRID_W, GRID_H, ROW_SPACE,
        BAG_GRID_MARGIN)
    grids:setTextMargin(8, 8)
    grids:setLevelMargin(-8, -8)

    local isGray
    if isStore then
        if self:isStoreGray(index) then
            -- 整页所有格子未开启（包括夫妻双方看对方的储物室）
            isGray = true
        else
            -- 可能此页只有部分格子未开启（有格子已经开启了）
            isGray = self:getGrayGridByPage(index)
        end
    else
        isGray = self:isBagGray(index)
    end

    grids:setData(data, 1, function(idx, sender)
        -- 刷新标志位
        sender:updateBagGrid()
        local isOperateOthers
        local pos =  data[idx].pos
        local item = StoreMgr:getItemByPos(pos)
        if self.isCouple and item and not (index >= self:getMyFirstPageInStore() and
              index <=  self:getMyFirstPageInStore() + 1) then
           isOperateOthers = true
        end

        local listType  = isStore and 2 or 1
        if self.lastSelect[listType] == data[idx].pos then
            if listType == 1 then
                StoreMgr:cmdBagToStore(data[idx].pos)
            else
                if isOperateOthers then
                    gf:ShowSmallTips(CHS[7003109])
                    return
                end

                StoreMgr:cmdStoreToBag(data[idx].pos)
            end
            self.lastSelect = {[1] = 0, [2] = 0}
        else
            if ((type(isGray) ~= "table" and isGray)
                    or (type(isGray) == "table" and isGray[idx]))
                    and listType ~= 1
                    and (not item)
                    and MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
                -- 储物室中不可使用且不包含物品的格子
                if self.isCouple then
                    -- 夫妻储物室
                    if index >= self:getMyFirstPageInStore() and index <=  self:getMyFirstPageInStore() + 1 then
                        gf:ShowSmallTips(CHS[7002342])
                    end
                else
                    gf:ShowSmallTips(CHS[7002342])
                end
            end

            local rect = self:getBoundingBoxInWorldSpace(sender)
            if isOperateOthers then
                StoreMgr:showItemDlg(data[idx].pos, rect)
            else
                StoreMgr:showHasStoreDlg(data[idx].pos, rect, true)
            end
        end

        self.lastSelect[listType] = data[idx].pos
        self.root:requestDoLayout()
    end, isGray)

    layout:addChild(grids)
    listViewCtrl:pushBackCustomItem(layout)
    self.showBag = data


    if listViewCtrl:getName() == "BagGridListView" then
        self.bagGridPanel[index] = grids
    else
        self.gridstorePanel[index] = grids
    end

end

function HomeStoreDlg:clearSelceted(exceptIndex, listType)
    for i = 1, TAOTAL_PAGE do
        if i ~= exceptIndex then
            if listType == 1 then
                self.bagGridPanel[i]:clearSelected()
            else
                if self.gridstorePanel[i] and self.gridstorePanel[i].clearSelected then
                    self.gridstorePanel[i]:clearSelected()
                end
            end
        end
    end
end

function HomeStoreDlg:getPrecentByIndex(index, isLfet, listType)
    local listCtrl
    if listType == 1 then
        listCtrl = self.bagListView
    else
        listCtrl = self.storeListView
    end

    local prencent = 0
    local width = listCtrl:getInnerContainer():getContentSize().width - listCtrl:getContentSize().width

    if isLfet then
        local moveDiatance = GRID_W
        prencent = ((listCtrl:getContentSize().width  + LISTVIEW_MARGIN )* (index - 1) + moveDiatance) / width * 100

    else
        local moveDiatance = GRID_W + LISTVIEW_MARGIN
        prencent =((listCtrl:getContentSize().width + LISTVIEW_MARGIN) * (index -1 )- moveDiatance) / width  * 100
    end

    return prencent
end

-- 检测下当前移动的百分比,然后进行强制移动
function HomeStoreDlg:checkCurPercent(percent, isLeft, listType)
    local listCtrl, radioGroup, checkList, totalPage
    if listType == 1 then
        totalPage = TOTAL_BAG_PAGE

        listCtrl = self.bagListView
        radioGroup = self.bagRadioGroup
        checkList = self.bagCheckTable
    else
        totalPage = self:getTotalStorePage()

        listCtrl = self.storeListView
        radioGroup = self.storeRadioGroup
        checkList = self.storeCheckTable
    end

    if isLeft then
        -- 第一页
        if percent < self:getPrecentByIndex(1, true, listType) and percent >= 0 and percent <= 100 then
            self:clearSelceted(1, listType)
            performWithDelay(self.root, function()
                radioGroup:selectRadio(1, true)
                listCtrl:scrollToPercentHorizontal(0, SCROLL_TIME, true)
                self:showPanelInCheckBox(checkList[1], true, checkList)
                self.lastPercent[listType] = 0
            end, DELTA_TIME)
            -- 第二页如果是向左
        elseif percent >= self:getPrecentByIndex(1, true, listType) and percent < self:getPrecentByIndex(2, true, listType)  and percent <= 100 then
            self:clearSelceted(2, listType)
            performWithDelay(self.root, function()
                radioGroup:selectRadio(2, true)
                local autoRange = 0

                if self.Sorted then
                    autoRange = AUTO_MOVE_DIST
                end

                self.lastPercent[listType] = 100 / (totalPage - 1)
                listCtrl:scrollToPercentHorizontal(self.lastPercent[listType], SCROLL_TIME, true)
                self:showPanelInCheckBox(checkList[2], true, checkList)
            end, DELTA_TIME)

        elseif  percent >= self:getPrecentByIndex(2, true, listType) and percent <= self:getPrecentByIndex(3, true, listType)  and percent <= 100 then
            self:clearSelceted(3, listType)
            performWithDelay(self.root, function()
                radioGroup:selectRadio(3, true)
                local autoRange = 0

                if self.Sorted then
                    autoRange = AUTO_MOVE_DIST
                end

                if math.abs(self.lastPercent[listType] - 100 * 2 / (totalPage - 1)) > 1 then self:isBuyVipByPage(3, listType) end
                self.lastPercent[listType] = 100 * 2 / (totalPage - 1)

                listCtrl:scrollToPercentHorizontal(self.lastPercent[listType], SCROLL_TIME, true)
                self:showPanelInCheckBox(checkList[3], true, checkList)

            end, DELTA_TIME)
        elseif  percent >= self:getPrecentByIndex(3, true, listType) and percent <= self:getPrecentByIndex(4, true, listType) and percent <= 100 then
            self:clearSelceted(4, listType)
            performWithDelay(self.root, function()
                radioGroup:selectRadio(4, true)

                if math.abs(self.lastPercent[listType] - 100 * 3 / (totalPage - 1)) > 1 then self:isBuyVipByPage(4, listType) end
                self.lastPercent[listType] = 100 * 3 / (totalPage - 1)

                listCtrl:scrollToPercentHorizontal(self.lastPercent[listType], SCROLL_TIME, true)
                self:showPanelInCheckBox(checkList[4], true, checkList)

            end, DELTA_TIME)
        elseif  percent > self:getPrecentByIndex(4, true, listType) and percent <= 100 then
            self:clearSelceted(5, listType)
            performWithDelay(self.root, function()
                radioGroup:selectRadio(5, true)

                listCtrl:scrollToPercentHorizontal(100, SCROLL_TIME, true)
                self:showPanelInCheckBox(checkList[5], true, checkList)
                if self.lastPercent[listType] ~= 100 then self:isBuyVipByPage(5, listType) end
                self.lastPercent[listType] = 100
            end, DELTA_TIME)
        elseif percent > 100 then
            self:clearSelceted(totalPage, listType)
            performWithDelay(self.root, function()
                radioGroup:selectRadio(totalPage, true)
                local autoRange = 0

                if self.Sorted then
                    autoRange = AUTO_MOVE_DIST
                end

                self:showPanelInCheckBox(checkList[totalPage], true, checkList)
                if self.lastPercent[listType] ~= 100 then self:isBuyVipByPage(totalPage, listType) end
                self.lastPercent[listType] = 100
            end, DELTA_TIME)
        elseif percent < 0 then
            radioGroup:selectRadio(1, true)
            self:clearSelceted(1, listType)
            performWithDelay(self.root, function()
                self:showPanelInCheckBox(checkList[1], true, checkList)
                self.lastPercent[listType] = 0
            end, DELTA_TIME)
        end
    else
        if percent >= 0 and percent  < self:getPrecentByIndex(2, false, listType) then
            self:clearSelceted(1, listType)
            performWithDelay(self.root, function()
                radioGroup:selectRadio(1, true)
                listCtrl:scrollToPercentHorizontal(0, SCROLL_TIME, true)
                self:showPanelInCheckBox(checkList[1], true, checkList)
                self.lastPercent[listType] = 0
            end, DELTA_TIME)
            -- 第二页如果是向左
        elseif percent >= self:getPrecentByIndex(2, false, listType) and percent < self:getPrecentByIndex(3, false, listType) then
            self:clearSelceted(2, listType)
            performWithDelay(self.root, function()
                radioGroup:selectRadio(2, true)
                local autoRange = 0

                if self.Sorted then
                    autoRange = AUTO_MOVE_DIST
                end
                self.lastPercent[listType] = 100 / (totalPage - 1)
                listCtrl:scrollToPercentHorizontal(self.lastPercent[listType], SCROLL_TIME, true)
                self:showPanelInCheckBox(checkList[2], true, checkList)

            end, DELTA_TIME)
        elseif percent >= self:getPrecentByIndex(3, false, listType)  and percent <= self:getPrecentByIndex(4, false, listType)  then
            self:clearSelceted(3, listType)
            performWithDelay(self.root, function()
                radioGroup:selectRadio(3, true)
                local autoRange = 0

                if self.Sorted then
                    autoRange = AUTO_MOVE_DIST
                end
                if math.abs(self.lastPercent[listType] - 100 * 2 / (totalPage - 1)) > 1 then self:isBuyVipByPage(3, listType) end
                self.lastPercent[listType] = 100 * 2 / (totalPage - 1)
                listCtrl:scrollToPercentHorizontal(self.lastPercent[listType], SCROLL_TIME, false)
                self:showPanelInCheckBox(checkList[3], true, checkList)

            end, DELTA_TIME)
        elseif percent >= self:getPrecentByIndex(4, false, listType)  and percent <= self:getPrecentByIndex(5, false, listType)  then
            self:clearSelceted(4, listType)
            performWithDelay(self.root, function()
                radioGroup:selectRadio(4, true)
                local autoRange = 0

                if math.abs(self.lastPercent[listType] - 100 * 3 / (totalPage - 1)) > 1 then self:isBuyVipByPage(4, listType) end
                self.lastPercent[listType] = 100 * 3 / (totalPage - 1)
                listCtrl:scrollToPercentHorizontal(self.lastPercent[listType], SCROLL_TIME, false)
                self:showPanelInCheckBox(checkList[4], true, checkList)

            end, DELTA_TIME)
        elseif percent >= self:getPrecentByIndex(5, false, listType) and percent <= 100 then
            self:clearSelceted(5, listType)
            performWithDelay(self.root, function()
                radioGroup:selectRadio(5, true)
                local autoRange = 0

                if self.Sorted then
                    autoRange = AUTO_MOVE_DIST
                end
                listCtrl:scrollToPercentHorizontal(100 + AUTO_MOVE_DIST, SCROLL_TIME, false)
                self:showPanelInCheckBox(checkList[5], true, checkList)
                if self.lastPercent[listType] ~= 100 then self:isBuyVipByPage(5, listType) end
                self.lastPercent[listType] = 100
            end, DELTA_TIME)


        elseif percent < 0 then
            radioGroup:selectRadio(1, true)
            self:clearSelceted(1, listType)
            performWithDelay(self.root, function()
                --self.bagListView:scrollToPercentHorizontal(0, SCROLL_TIME, true)
                self:showPanelInCheckBox(checkList[1], true, checkList)
                self.lastPercent[listType] = 0
            end, DELTA_TIME)
        elseif percent > 100 then
            self:clearSelceted(totalPage, listType)
            performWithDelay(self.root, function()
                radioGroup:selectRadio(totalPage, true)
                local autoRange = 0

                if self.Sorted then
                    autoRange = AUTO_MOVE_DIST
                end
                --self.bagListView:scrollToPercentHorizontal(100 + AUTO_MOVE_DIST, SCROLL_TIME, true)
                self:showPanelInCheckBox(checkList[totalPage], true, checkList)
                if self.lastPercent[listType] ~= 100 then self:isBuyVipByPage(totalPage, listType) end
                self.lastPercent[listType] = 100
            end, DELTA_TIME)
        end
    end
end

function HomeStoreDlg:getBagCurIndex()
    return self.bagRadioGroup:getSelectedRadioIndex()
end

function HomeStoreDlg:setStoreLastPage()
    self.lastStIndex = self.lastStIndex or 1
    self.lastBagIndex = self.lastBagIndex or 1
    if self:isOutLimitTime("lastTime", DEF_TIME) then
        self.lastStIndex = self:getMyFirstPageInStore()
        self.lastBagIndex = 1
    end
    self.storeListView:refreshView()
    self.storeListView:doLayout()

    self.lastPercent[2] = 100 * (self.lastStIndex - 1) / (self:getTotalStorePage() - 1)

    self.storeListView:getInnerContainer():setPositionX(BAG_POS[self.lastStIndex])
    self.storeListView:doLayout()

    local checkCtrl = self.storeRadioGroup:getRadioNameIndex(self.lastStIndex)
    self:showPanelInCheckBox(checkCtrl, true, self.storeCheckTable)

    self.bagListView:refreshView()
    self.bagListView:doLayout()

    self.lastPercent[1] = 100 * (self.lastBagIndex - 1) / (TOTAL_BAG_PAGE - 1)

    self.bagListView:getInnerContainer():setPositionX(BAG_POS[self.lastBagIndex])
    self.bagListView:doLayout()

    local checkCtrl = self.bagRadioGroup:getRadioNameIndex(self.lastBagIndex)
    self:showPanelInCheckBox(checkCtrl, true, self.bagCheckTable)

end

function HomeStoreDlg:setBagIndex(x, index)
    --self.bagListView
    self.bagListView:refreshView()
    self.bagListView:doLayout()

    self.bagListView:getInnerContainer():setPositionX(x)
    self.bagListView:doLayout()

    local checkCtrl = self.bagRadioGroup:getRadioNameIndex(index)
    self:showPanelInCheckBox(checkCtrl, true, self.bagCheckTable)
end

function HomeStoreDlg:onBagArrangementButton(sender, eventType)
    -- 整理包裹和行囊中的道具
    self.lastServerTime = self.lastServerTime or 0
    if gf:getServerTime() - self.lastServerTime > 5 then
        InventoryMgr:arrangeBag()
        self.lastServerTime = gf:getServerTime()
        self.Sorted = true
    else
        gf:ShowSmallTips(CHS[6000208])
    end
end

-- 重载
function HomeStoreDlg:close()
    Dialog.close(self)
end

function HomeStoreDlg:playExtraSound(sender)
    if sender:getName() == "BagArrangementButton" or sender:getName() == "StoreArrangementButton" then
        SoundMgr:playEffect("item")
        return true
    end

    return false
end

function HomeStoreDlg:onStoreArrangementButton(sender, eventType)
    self.lastStoreArrangeTime = self.lastStoreArrangeTime or 0
    if gf:getServerTime() - self.lastStoreArrangeTime > 5 then
        StoreMgr:arrangeBag()
        self.lastStoreArrangeTime = gf:getServerTime()
        self.Sorted = true
    else
        gf:ShowSmallTips(CHS[6000208])
    end
end

function HomeStoreDlg:onSelectBagGridListView(sender, eventType)
end

function HomeStoreDlg:onSelectStoreGridListView(sender, eventType)
end

function HomeStoreDlg:onSelectStoreGridListView(sender, eventType)
end

function HomeStoreDlg:MSG_INVENTORY(data)
    local autoPage = false -- 整理后不需要自动翻
    for i = 1, data.count do
        local pos = data[i].pos - BAG_INDEX_START + 1
        if pos >= 1 and pos <= BAG_ROW_NUM * BAG_COL_NUM then
            self.bag1 = InventoryMgr:getBag1Items()
            self.bagGridPanel[1]:setGridData(self.bag1[pos], pos, GRID_W, GRID_H)
            if autoPage then
                self:setPage(1, 1, self.bagCheckTable[1])
                self:showPanelInCheckBox(self.bagCheckTable[1], true, self.bagCheckTable)
            end
        end

        if pos > BAG_ROW_NUM * BAG_COL_NUM and pos <= BAG_ROW_NUM * BAG_COL_NUM * 2 then
            self.bag2 = InventoryMgr:getBag2Items()
            self.bagGridPanel[2]:setGridData(self.bag2[pos - BAG_ROW_NUM * BAG_COL_NUM], pos - BAG_ROW_NUM * BAG_COL_NUM, GRID_W, GRID_H)
            if autoPage then
                self:setPage(2, 1, self.bagCheckTable[2])
                self:showPanelInCheckBox(self.bagCheckTable[2], true, self.bagCheckTable)
            end
        end

        if pos > BAG_ROW_NUM * BAG_COL_NUM * 2 and pos <= BAG_ROW_NUM * BAG_COL_NUM * 3 then
            self.bag3 = InventoryMgr:getBag3Items()
            self.bagGridPanel[3]:setGridData(self.bag3[pos - BAG_ROW_NUM * BAG_COL_NUM * 2], pos - BAG_ROW_NUM * BAG_COL_NUM * 2, GRID_W, GRID_H, self:isBagGray(3))
            if autoPage then
                self:setPage(3, 1, self.bagCheckTable[3])
                self:showPanelInCheckBox(self.bagCheckTable[3], true, self.bagCheckTable)
            end
        end

        if pos > BAG_ROW_NUM * BAG_COL_NUM * 3 and pos <= BAG_ROW_NUM * BAG_COL_NUM * 4 then
            self.bag4 = InventoryMgr:getBag4Items()
            self.bagGridPanel[4]:setGridData(self.bag4[pos - BAG_ROW_NUM * BAG_COL_NUM * 3], pos - BAG_ROW_NUM * BAG_COL_NUM * 3, GRID_W, GRID_H, self:isBagGray(4))
            if autoPage then
                self:setPage(4, 1, self.bagCheckTable[4])
                self:showPanelInCheckBox(self.bagCheckTable[4], true, self.bagCheckTable)
            end
        end

        if pos > BAG_ROW_NUM * BAG_COL_NUM * 4 and pos <= BAG_ROW_NUM * BAG_COL_NUM * 5 then
            self.bag5 = InventoryMgr:getBag5Items()
            self.bagGridPanel[5]:setGridData(self.bag5[pos - BAG_ROW_NUM * BAG_COL_NUM * 4], pos - BAG_ROW_NUM * BAG_COL_NUM * 4, GRID_W, GRID_H, self:isBagGray(5))
            if autoPage then
                self:setPage(5, 1, self.bagCheckTable[5])
                self:showPanelInCheckBox(self.bagCheckTable[5], true, self.bagCheckTable)
            end
        end
    end
end

-- 储物室
function HomeStoreDlg:MSG_STORE(data)
    local autoPage = false -- 整理后不需要自动翻
    if data.store_type ~= "home_store" and data.store_type ~= "couple_store" then
        return
    end

    local autoPage = false -- 整理后不需要自动翻
    for i = 1, data.count do
        if data[i].pos >= COUPLE_STORE_INDEX_START then
            local pos = data[i].pos - COUPLE_STORE_INDEX_START + 1
            if pos >= 1 and pos <= BAG_ROW_NUM * BAG_COL_NUM then
                -- 夫妻储物室中对方储物室第一页
                local page = self:getCoupleFirstPageInStore()
                self.store3 = StoreMgr:getCoupleHomeStore1Items()
                self.gridstorePanel[page]:setGridData(self.store3[pos], pos, GRID_W, GRID_H, true)
                if autoPage then
                    self:setPage(page, 2, self.storeCheckTable[page])
                    self:showPanelInCheckBox(self.storeCheckTable[page], true, self.storeCheckTable)
                end
            end

            if pos > BAG_ROW_NUM * BAG_COL_NUM and pos <= BAG_ROW_NUM * BAG_COL_NUM * 2 then
                -- 夫妻储物室中对方储物室第二页
                local page = self:getCoupleFirstPageInStore() + 1
                self.store4 = StoreMgr:getCoupleHomeStore2Items()
                self.gridstorePanel[page]:setGridData(self.store4[pos - BAG_ROW_NUM * BAG_COL_NUM], pos - BAG_ROW_NUM * BAG_COL_NUM, GRID_W, GRID_H, true)
                if autoPage then
                    self:setPage(page, 2, self.storeCheckTable[page])
                    self:showPanelInCheckBox(self.storeCheckTable[page], true, self.storeCheckTable)
                end
            end
        else
            local pos = data[i].pos - STORE_INDEX_START + 1
            if pos >= 1 and pos <= BAG_ROW_NUM * BAG_COL_NUM then
                local page = self:getMyFirstPageInStore()
                self.store1 = StoreMgr:getHomeStore1Items()
                local isGray = pos > HomeMgr:getMaxGridByHomeStoreType(HomeMgr:getHomeStoreType())
                self.gridstorePanel[page]:setGridData(self.store1[pos], pos, GRID_W, GRID_H, isGray)
                if autoPage then
                    self:setPage(page, 2, self.storeCheckTable[page])
                    self:showPanelInCheckBox(self.storeCheckTable[page], true, self.storeCheckTable)
                end
            end

            if pos > BAG_ROW_NUM * BAG_COL_NUM and pos <= BAG_ROW_NUM * BAG_COL_NUM * 2 then
                local page = self:getMyFirstPageInStore() + 1
                self.store2 = StoreMgr:getHomeStore2Items()
                local isGray = pos > HomeMgr:getMaxGridByHomeStoreType(HomeMgr:getHomeStoreType())
                self.gridstorePanel[page]:setGridData(self.store2[pos - BAG_ROW_NUM * BAG_COL_NUM], pos - BAG_ROW_NUM * BAG_COL_NUM, GRID_W, GRID_H, isGray)
                if autoPage then
                    self:setPage(page, 2, self.storeCheckTable[page])
                    self:showPanelInCheckBox(self.storeCheckTable[page], true, self.storeCheckTable)
                end
            end
        end
    end
end

function HomeStoreDlg:toPrentcent(index, totalPage)
    return (index - 1) / (totalPage -1) * 100
end

function HomeStoreDlg:setPage(page, listType, checkCtrl)
    if listType == 1 then
        self.lastPercent[listType] = self:toPrentcent(page, TOTAL_BAG_PAGE)
        self.bagListView:scrollToPercentHorizontal(self.lastPercent[listType], SCROLL_TIME, true)
        self:showPanelInCheckBox(checkCtrl, true, self.bagCheckTable)
    else
        self.lastPercent[listType] = self:toPrentcent(page, self:getTotalStorePage())
        self.storeListView:scrollToPercentHorizontal(self.lastPercent[listType], SCROLL_TIME, true)
        self:showPanelInCheckBox(checkCtrl, true, self.storeCheckTable)
    end
    checkCtrl:setSelectedState(true)
    self:clearSelceted(page, listType)
    self:isBuyVipByPage(page, listType)
end

-- 是否提示购买vip
function HomeStoreDlg:isBuyVipByPage(page, listType)

    local strTypeFlag = "bag"

    if listType == 1 then
        strTypeFlag = "bag"
    else
        strTypeFlag = "store"
    end

    if 1 == listType then
        if page > self:getHaveOpenBagPage() then
            if not InventoryMgr.isShowNeedVip.bag[page] then
                InventoryMgr.isShowNeedVip.bag[page] = true

                InventoryMgr:checkBagMorePageTips()
                        end
                end
    --[[  -- 点击标签页不再给出提示
    else
        if self:isStoreGray(page) and page <= self:getMyFirstPageInStore() and page <= self:getMyFirstPageInStore() + 1 then
            if not InventoryMgr.isShowNeedVipInHomeStore.store[page] then
                InventoryMgr.isShowNeedVipInHomeStore.store[page] = true
                gf:ShowSmallTips(CHS[7002342])
            end
        end
        --]]
    end

    if listType then
        if listType == 1 then
            local checkBox2 = self:getControl("LuggageTwoTagCheckBox", Const.UICheckBox)
            local checkBox3 = self:getControl("LuggageThreeTagCheckBox", Const.UICheckBox)

            if page == 3 then
                if Me:getVipType() == 0 then
                    self:setCtrlVisible("CoverImage", true, checkBox2)
                    self:setCtrlVisible("CoverImage", false, checkBox3)
                end
            elseif page == 4 then
                if Me:getVipType() ~= 3 then
                    self:setCtrlVisible("CoverImage", false, checkBox2)
                    self:setCtrlVisible("CoverImage", true, checkBox3)
                end
            end
        else
            for i =  1, #STORE_CHECKBOX do
                local checkBox = self:getControl(STORE_CHECKBOX[i])
                self:setCtrlVisible("CoverImage", (i == page and self:isStoreGray(page)))
            end
        end
    end
end

-- 包裹页签翻页
function HomeStoreDlg:onBagCheckBox(sender, eventType)
    local name = sender:getName()
    if name == "BagTagCheckBox" then
        self:setPage(1, 1, sender)
    elseif name == "LuggageOneTagCheckBox" then
        self:setPage(2, 1, sender)
    elseif name == "LuggageTwoTagCheckBox" then
        self:setPage(3, 1, sender)
    elseif name == "LuggageThreeTagCheckBox" then
        self:setPage(4, 1, sender)
    elseif name == "LuggageFourTagCheckBox" then
        self:setPage(5, 1, sender)
    end
end

function HomeStoreDlg:onStoreCheckBox(sender, eventType)
    local name = sender:getName()
    if name == "StoreOneCheckBox" then
        self:setPage(1, 2, sender)
    elseif name == "StoreTwoCheckBox" then
        self:setPage(2, 2, sender)
    elseif name == "StoreThreeCheckBox" then
        self:setPage(3, 2, sender)
    elseif name == "StoreFourCheckBox" then
        self:setPage(4, 2, sender)
    end
end

function HomeStoreDlg:onOpenDlgRequestData(sender, eventType)
    -- 向服务器请求储物室物品数据
    StoreMgr:cmdHomeStoreItemsInfo()
end

function HomeStoreDlg:MSG_INSIDER_INFO(data)
    self:showBagItems(true)
    self:showStoreItems(true)
    self:initCheck(data.vipType)
end

return HomeStoreDlg
