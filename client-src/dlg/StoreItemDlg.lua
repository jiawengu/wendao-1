-- StoreItemDlg.lua
-- Created by songcw Aug/25/2015
-- 仓库对话框界面

local StoreItemDlg = Singleton("StoreItemDlg", Dialog)
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
local STORE_INDEX_START = 201

local TAOTAL_PAGE = 5
local TOTAL_BAG_PAGE = 5
local TOTAL_STROE_PAGE = 4

local DEF_TIME = (60 * 2 +30) * 1000

local BAG_POS = {
    [1] = 0,
    [2] = -397.69,
    [3] = -795.94,
    [4]= -1194,
    [5] = -1591.3,
}


function StoreItemDlg:init()
    self:bindListener("BagArrangementButton", self.onBagArrangementButton)
    self:bindListener("StoreArrangementButton", self.onStoreArrangementButton)

    self:bindListener("PetStoreButton", self.onPetStoreButton)
    self:bindListener("MoneyStoreButton", self.onMoneyStoreButton)

    self:setValidClickTime("MoneyStoreButton", 3000, CHS[4200491])
    self:setValidClickTime("PetStoreButton", 3000, CHS[4200492])


    StoreMgr:setStoreType(STORE_TYPE.NORMAL_STORE)

    -- 获取背包的PageView控件
    self.bagListView = self:getControl("BagGridListView", Const.UIListView)
    self.bagListView:setTouchEnabled(true)
    self.bagLayout = self:getControl("BagPanel", Const.UIPanel, self:getControl("BagPanel", Const.UIPanel))
    self.bagListView:setItemsMargin(LISTVIEW_MARGIN)

    -- 获取仓库的PageView控件
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

    self:initCheck(Me:getVipType())

    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_STORE")
    self:hookMsg("MSG_INSIDER_INFO")
    self.bagGridPanel = {}
    self.gridstorePanel = {}
    for i = 1,5 do
        self.bagGridPanel[i] = {}
    end

    for i = 1,4 do
        self.gridstorePanel[i] = {}
    end


    self:showBagItems()
    self:showStoreItems()
    self:showPanelInCheckBox(self.storeCheckTable[1], true, self.storeCheckTable)


    -- 向服务器请求仓库物品数据
    StoreMgr:cmdStoreItemsInfo()
    --    if StoreMgr:isExistData() then self:showStoreItems() end

    self.lastPercent = {[0] = 0, [1] = 0, [2] = 0}
    self.lastSelect = {[0] = 0, [1] = 0, [2] = 0}

    -- 1背包  2仓库
    self:bindPageScrollEvent(1)
    self:bindPageScrollEvent(2)

    EventDispatcher:addEventListener("doOpenDlgRequestData", self.onOpenDlgRequestData, self)

    self:setStoreLastPage()
end

function StoreItemDlg:bindPageScrollEvent(listType)
    self.mainLayout = self:getControl("TouchPanel", Const.UIPanel)

    -- pageView滚动事件
    local function onTouchBegan(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        local boxBag = self:getBoundingBoxInWorldSpace(self.bagListView)

        if listType == 1 and cc.rectContainsPoint(boxBag, touchPos) then
            return true
        end

        local boxStore = self:getBoundingBoxInWorldSpace(self.storeListView)
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

function StoreItemDlg:cleanup()
    EventDispatcher:removeEventListener("doOpenDlgRequestData", self.onOpenDlgRequestData, self)

    DlgMgr:sendMsg("BagTabDlg", "setLastDlgInfo", "StoreItemDlg", self:getBagCurIndex())

    self:setLastOperTime("lastTime", gfGetTickCount())
    self.lastStIndex = self.storeRadioGroup:getSelectedRadioIndex()
end

--[[
function StoreItemDlg:isGrayByPos(pos)
    local page = 1

    if pos > 0 and pos <= 25 then
        page = 1
    elseif pos > 25 and pos <= 50 then
        page = 2
    elseif pos > 50 and pos <= 75 then
        page = 3
    elseif pos > 75 and pos <= 100 then
        page = 4
    end

    if page == 4 and Me:getVipType() ~= 3 then
        return true
    end

    if page == 3 and Me:getVipType() == 0 then
        return true
    end

    return false
end]]

function StoreItemDlg:initCheck(vip)
    -- 根据位列仙班等级置灰部分标签页

    for i = 1, 4 do
        if i > self:getHaveOpenStorePage() then
            gf:grayImageView(self.storeCheckTable[i])
            gf:grayCheckSelectImageView(self.storeCheckTable[i])
        else
            gf:resetImageView(self.storeCheckTable[i])
            gf:resetCheckSelectImageView(self.storeCheckTable[i])
        end
    end

    for i = 1, 5 do
        if i > self:getHaveOpenBagPage() then
            gf:grayImageView(self.bagCheckTable[i])
            gf:grayCheckSelectImageView(self.bagCheckTable[i])
        else
            gf:resetImageView(self.bagCheckTable[i])
            gf:resetCheckSelectImageView(self.bagCheckTable[i])
        end
    end
end

-- 已开启的页数
function StoreItemDlg:getHaveOpenBagPage()
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

-- 已开启的页数
function StoreItemDlg:getHaveOpenStorePage()
    local page = 2 -- 初值2页
    if Me:getVipType() > 0 and Me:getVipType() < 3 then
        page = page + 1 -- 月卡季卡加一页
    elseif Me:getVipType() == 3 then
        page = page + 2 -- 年卡加2页
    end

    return page
end

-- 获取当前ListView滚动百分比
function StoreItemDlg:getCurScrollPercent(listType)
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

-- 显示checkbox下的panel
function StoreItemDlg:showPanelInCheckBox(checkBox, isShow, checkBoxList)
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
                if checkBoxList[k] == self.bagListView then
                    local checkBox2 = self:getControl("LuggageTwoTagCheckBox", Const.UICheckBox)
                    local checkBox3 = self:getControl("LuggageThreeTagCheckBox", Const.UICheckBox)
                    self:setCtrlVisible("CoverImage", false, checkBox2)
                    self:setCtrlVisible("CoverImage", false, checkBox3)
                else
                    local checkBox3 = self:getControl("StoreThreeCheckBox", Const.UICheckBox)
                    local checkBox4 = self:getControl("StoreFourCheckBox", Const.UICheckBox)
                    self:setCtrlVisible("CoverImage", false, checkBox3)
                    self:setCtrlVisible("CoverImage", false, checkBox4)
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
function StoreItemDlg:showBagItems(isNotJumLeft)
    self.bag1 = InventoryMgr:getBag1Items() -- 包裹数据
    self.bag2 = InventoryMgr:getBag2Items() -- 行囊1数据
    self.bag3 = InventoryMgr:getBag3Items() -- 行囊2数据
    self.bag4 = InventoryMgr:getBag4Items() -- 行囊3数据
    self.bag5 = InventoryMgr:getBag5Items() -- 行囊4数据

    local totalBag = {self.bag1, self.bag2, self.bag3, self.bag4, self.bag5}
    self:initBagItemInfo(totalBag)
    --    self.radioGroup:selectRadio(1, true)
    if not isNotJumLeft then
        self.bagListView:jumpToLeft()
    end
end

function StoreItemDlg:initBagItemInfo(bagData)
    self.bagListView:removeAllItems()
    for _, v in ipairs(bagData) do
        self:showItems(_, v, self.bagListView, false)
    end
end

-- 显示所有的物品信息
function StoreItemDlg:showStoreItems(isNotJumLeft)
    self.store1 = StoreMgr:getStor1Items() -- 包裹数据
    self.store2 = StoreMgr:getStor2Items() -- 行囊1数据
    self.store3 = StoreMgr:getStor3Items() -- 行囊2数据
    self.store4 = StoreMgr:getStor4Items() -- 行囊3数据

    local totalBag = {self.store1, self.store2, self.store3, self.store4}
    self:initStoreItemInfo(totalBag)
    --    self.radioGroup:selectRadio(1, true)

    if not isNotJumLeft then
        self.storeListView:jumpToLeft()
    end
end

function StoreItemDlg:initStoreItemInfo(bagData)
    self.storeListView:removeAllItems()
    for _, v in ipairs(bagData) do
        self:showItems(_, v, self.storeListView, true)
    end
end

function StoreItemDlg:isBagGray(page)
    if page > self:getHaveOpenBagPage() then
        return true
    end

    return false
end

function StoreItemDlg:isStoreGray(page)
    if page > self:getHaveOpenStorePage() then
        return true
    end

    return false
end

function StoreItemDlg:removeLastSelect()
    self.lastSelect = {[1] = 0, [2] = 0}
end

-- 显示物品信息
function StoreItemDlg:showItems(index, data, listViewCtrl, isStore)
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

    grids:setData(data, 1, function(idx, sender)
        -- 刷新标志位
        sender:updateBagGrid()

        local listType = isStore and 2 or 1
        if self.lastSelect[listType] == data[idx].pos then
            if listType == 1 then
                StoreMgr:cmdBagToStore(data[idx].pos)
            else
                StoreMgr:cmdStoreToBag(data[idx].pos)
            end
            self.lastSelect = {[1] = 0, [2] = 0}
        else
            local rect = self:getBoundingBoxInWorldSpace(sender)
            StoreMgr:showHasStoreDlg(data[idx].pos, rect)
        end

        self.lastSelect[listType] = data[idx].pos
        self.root:requestDoLayout()
    end, isStore and self:isStoreGray(index) or self:isBagGray(index))

    layout:addChild(grids)
    listViewCtrl:pushBackCustomItem(layout)
    self.showBag = data


    if listViewCtrl:getName() == "BagGridListView" then
        self.bagGridPanel[index] = grids
    else
        self.gridstorePanel[index] = grids
    end

end

function StoreItemDlg:clearSelceted(exceptIndex, listType)
    for i = 1, TAOTAL_PAGE do
        if i ~= exceptIndex then
            if listType == 1 then
                -- 背包
                self.bagGridPanel[i]:clearSelected()
            else
                -- 仓库
                if self.gridstorePanel[i] then
                    self.gridstorePanel[i]:clearSelected()
                end
            end
        end
    end
end

function StoreItemDlg:getPrecentByIndex(index, isLfet, listType)
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
function StoreItemDlg:checkCurPercent(percent, isLeft, listType)
    local listCtrl, radioGroup, checkList, totalPage
    if listType == 1 then
        totalPage = TOTAL_BAG_PAGE
        listCtrl = self.bagListView
        radioGroup = self.bagRadioGroup
        checkList = self.bagCheckTable
    else
        totalPage = TOTAL_STROE_PAGE

        listCtrl = self.storeListView
        radioGroup = self.storeRadioGroup
        checkList = self.storeCheckTable
    end

    if isLeft then
        -- 第一页
        if percent < self:getPrecentByIndex(1, true, listType) and percent >= 0 then
            self:clearSelceted(1, listType)
            performWithDelay(self.root, function()
                radioGroup:selectRadio(1, true)
                listCtrl:scrollToPercentHorizontal(0, SCROLL_TIME, true)
                self:showPanelInCheckBox(checkList[1], true, checkList)
                self.lastPercent[listType] = 0
            end, DELTA_TIME)
            -- 第二页如果是向左
        elseif percent >= self:getPrecentByIndex(1, true, listType) and percent < self:getPrecentByIndex(2, true, listType) then
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

        elseif  percent >= self:getPrecentByIndex(2, true, listType) and percent <= self:getPrecentByIndex(3, true, listType) then
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
        elseif  percent >= self:getPrecentByIndex(3, true, listType) and percent <= self:getPrecentByIndex(4, true, listType) then
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
                --self.bagListView:scrollToPercentHorizontal(100 + AUTO_MOVE_DIST, SCROLL_TIME, true)
                self:showPanelInCheckBox(checkList[totalPage], true, checkList)
                if self.lastPercent[listType] ~= 100 then self:isBuyVipByPage(totalPage, listType) end
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

function StoreItemDlg:getBagCurIndex()
    return self.bagRadioGroup:getSelectedRadioIndex()
end

function StoreItemDlg:setStoreLastPage()
    self.lastStIndex = self.lastStIndex or 1
    if self:isOutLimitTime("lastTime", DEF_TIME) then
        self.lastStIndex = 1
    end
    self.storeListView:refreshView()
    self.storeListView:doLayout()

    self.lastPercent[2] = 100 * (self.lastStIndex - 1) / (TOTAL_STROE_PAGE - 1)

    self.storeListView:getInnerContainer():setPositionX(BAG_POS[self.lastStIndex])
    self.storeListView:doLayout()

    local checkCtrl = self.storeRadioGroup:getRadioNameIndex(self.lastStIndex)
    self:showPanelInCheckBox(checkCtrl, true, self.storeCheckTable)
end

function StoreItemDlg:setBagIndex(x, index)
--self.bagListView
    self.bagListView:refreshView()
    self.bagListView:doLayout()

    self.lastPercent[1] = 100 * (index - 1) / (TOTAL_BAG_PAGE - 1)

    self.bagListView:getInnerContainer():setPositionX(x)
    self.bagListView:doLayout()

    local checkCtrl = self.bagRadioGroup:getRadioNameIndex(index)
    self:showPanelInCheckBox(checkCtrl, true, self.bagCheckTable)
end

function StoreItemDlg:onBagArrangementButton(sender, eventType)
    -- 整理包裹和行囊中的道具
    self.lastServerTime = self.lastServerTime or 0
    if gf:getServerTime() - self.lastServerTime > 5 then
        InventoryMgr:arrangeBag()
        StoreMgr:arrangeBag()
        self.lastServerTime = gf:getServerTime()
        self.Sorted = true
    else
        gf:ShowSmallTips(CHS[6000208])
    end
end

-- 重载
function StoreItemDlg:close()
    --StoreMgr:cmdCloseStoreItems()
    Dialog.close(self)
end

function StoreItemDlg:playExtraSound(sender)
    if sender:getName() == "BagArrangementButton" or sender:getName() == "StoreArrangementButton" then
        SoundMgr:playEffect("item")
        return true
    end

    return false
end

function StoreItemDlg:onStoreArrangementButton(sender, eventType)

end

function StoreItemDlg:onPetStoreButton(sender, eventType)
    if GameMgr:IsCrossDist() and not DistMgr:isInZBYLServer() and not DistMgr:isInQcldServer() then
        gf:ShowSmallTips(CHS[5000267])
        return
    end

    StoreMgr:cmdStorePetsInfo()
    DlgMgr:openDlg("StorePetDlg")
end

function StoreItemDlg:onMoneyStoreButton(sender, eventType)
    if GameMgr:IsCrossDist() and not DistMgr:isInZBYLServer() and not DistMgr:isInQcldServer() then
        gf:ShowSmallTips(CHS[5000267])
        return
    end

        -- 安全锁判断
    if self:checkSafeLockRelease("onMoneyStoreButton", sender) then
        return
    end

    sender.lastTime = gfGetTickCount()
    DlgMgr:openDlg("StoreMoneyDlg")
end

function StoreItemDlg:MSG_INVENTORY(data)
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
    --]]
end

-- 仓库
function StoreItemDlg:MSG_STORE(data)
    if data.store_type ~= "normal_store" then return end
    local autoPage = false -- 整理后不需要自动翻
    for i = 1, data.count do
        local pos = data[i].pos - STORE_INDEX_START + 1
        if pos >= 1 and pos <= BAG_ROW_NUM * BAG_COL_NUM then
            self.store1 = StoreMgr:getStor1Items()
            self.gridstorePanel[1]:setGridData(self.store1[pos], pos, GRID_W, GRID_H)
            if autoPage then
                self:setPage(1, 2, self.storeCheckTable[1])
                self:showPanelInCheckBox(self.storeCheckTable[1], true, self.storeCheckTable)
            end

        end

        if pos > BAG_ROW_NUM * BAG_COL_NUM and pos <= BAG_ROW_NUM * BAG_COL_NUM * 2 then
            self.store2 = StoreMgr:getStor2Items()
            self.gridstorePanel[2]:setGridData(self.store2[pos - BAG_ROW_NUM * BAG_COL_NUM], pos - BAG_ROW_NUM * BAG_COL_NUM, GRID_W, GRID_H)
            if autoPage then
                self:setPage(2, 2, self.storeCheckTable[2])
                self:showPanelInCheckBox(self.storeCheckTable[2], true, self.storeCheckTable)
            end

        end

        if pos > BAG_ROW_NUM * BAG_COL_NUM * 2 and pos <= BAG_ROW_NUM * BAG_COL_NUM * 3 then
            self.store3 = StoreMgr:getStor3Items()
            self.gridstorePanel[3]:setGridData(self.store3[pos - BAG_ROW_NUM * BAG_COL_NUM * 2], pos - BAG_ROW_NUM * BAG_COL_NUM * 2, GRID_W, GRID_H, self:isStoreGray(3))
            if autoPage then
                self:showPanelInCheckBox(self.storeCheckTable[3], true, self.storeCheckTable)
                self:setPage(3, 2, self.storeCheckTable[3])
            end

        end

        if pos > BAG_ROW_NUM * BAG_COL_NUM * 3 and pos <= BAG_ROW_NUM * BAG_COL_NUM * 4 then
            self.store4 = StoreMgr:getStor4Items()
            self.gridstorePanel[4]:setGridData(self.store4[pos - BAG_ROW_NUM * BAG_COL_NUM * 3], pos - BAG_ROW_NUM * BAG_COL_NUM * 3, GRID_W, GRID_H, self:isStoreGray(4))
            if autoPage then
                self:showPanelInCheckBox(self.storeCheckTable[4], true, self.storeCheckTable)
                self:setPage(4, 2, self.storeCheckTable[4])
            end

        end
    end
end

function StoreItemDlg:toPrentcent(index, totalPage)
    return (index - 1) / (totalPage -1) * 100
end

--
function StoreItemDlg:setPage(page, listType, checkCtrl)
    if listType == 1 then
        self.lastPercent[listType] = self:toPrentcent(page, TOTAL_BAG_PAGE)
        self.bagListView:scrollToPercentHorizontal(self.lastPercent[listType], SCROLL_TIME, true)
        self:showPanelInCheckBox(checkCtrl, true, self.bagCheckTable)
    else
        self.lastPercent[listType] = self:toPrentcent(page, TOTAL_STROE_PAGE)
        self.storeListView:scrollToPercentHorizontal(self.lastPercent[listType], SCROLL_TIME, true)
        self:showPanelInCheckBox(checkCtrl, true, self.storeCheckTable)
    end
    checkCtrl:setSelectedState(true)
    self:clearSelceted(page, listType)
    self:isBuyVipByPage(page, listType)
end

-- 是否提示购买vip
function StoreItemDlg:isBuyVipByPage(page, listType)

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
    else
        if page > self:getHaveOpenStorePage() then
            if not InventoryMgr.isShowNeedVip.store[page] then
                InventoryMgr.isShowNeedVip.store[page] = true

                InventoryMgr:checkStoreMorePageTips()
                    end
                end
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
            local checkBox3 = self:getControl("StoreThreeCheckBox", Const.UICheckBox)
            local checkBox4 = self:getControl("StoreFourCheckBox", Const.UICheckBox)

            if page == 3 then
                if Me:getVipType() == 0 then
                    self:setCtrlVisible("CoverImage", true, checkBox3)
                    self:setCtrlVisible("CoverImage", false, checkBox4)
                end
            elseif page == 4 then
                if Me:getVipType() ~= 3 then
                    self:setCtrlVisible("CoverImage", false, checkBox3)
                    self:setCtrlVisible("CoverImage", true, checkBox4)
                end
            end
        end
    end
end

-- 仓库翻页页签
function StoreItemDlg:onBagCheckBox(sender, eventType)
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

function StoreItemDlg:onStoreCheckBox(sender, eventType)
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

function StoreItemDlg:onOpenDlgRequestData(sender, eventType)
    -- 向服务器请求仓库物品数据
    StoreMgr:cmdStoreItemsInfo()
end

function StoreItemDlg:MSG_INSIDER_INFO(data)
    self:showBagItems(true)
    self:showStoreItems(true)
    self:initCheck(data.vipType)
end

return StoreItemDlg
