-- BagDlg.lua
-- Created by chenyq Jan/06/2015
-- 装备、包裹界面

local RadioGroup = require("ctrl/RadioGroup")
local GridPanel = require('ctrl/GridPanel')
local BagDlg = Singleton("BagDlg", Dialog)

local BAG_ROW_NUM = 5
local BAG_COL_NUM = 5
local BAG_GRID_MARGIN = 2
local GRID_W = 74
local GRID_H = 74
local BAG_WIDTH = 350
local BAG_INDEX_START = 40
local AUTO_MOVE_DIST = 0
local NORMARL_OUTLINE_COLOR = cc.c4b(139, 143, 123, 255)
local COIN_FONT_SIZE = 25
local COIN_FONT_NAME = CHS[3002295]
local SCROLL_TIME = 0.7
local DELTA_TIME = 0.01
local LISTVIEW_MARGIN = 20
local TAOTAL_PAGE = 5
local ROW_SPACE = 6
local BAG_COUNT = 5         -- 背包数量，目前一共5个，会员、座骑
local FollowPet = DressMgr:getFollowPet()

local FOLLOW_SPRITE_OFFPOS = {
    [1] = cc.p(-40, -60),
    [3] = cc.p(40, -60),
    [5] = cc.p(-40, -60),
    [7] = cc.p(40, -60),
}

-- 装备栏相关
local EQUIP_ROW_SPACE = 15
local EQUIP_GRID_TOP = -25

local EQUIPMENT =
    {
        [1] = EQUIP.HELMET,  -- 头盔
        [2] = EQUIP.ARMOR,   -- 衣服
        [3] = EQUIP.WEAPON,  -- 武器
        [4] = EQUIP.BOOT,    -- 鞋子
        [5] = EQUIP.BALDRIC, -- 玉佩
        [6] = EQUIP.NECKLACE,-- 项链
        [7] = EQUIP.LEFT_WRIST,-- 左手镯
        [8] = EQUIP.RIGHT_WRIST,-- 右手镯
        [9] = EQUIP.ARTIFACT, -- 法宝
        [10] = EQUIP.TALISMAN, -- 符具
    }

function BagDlg:init()
    self:bindListener("ArrangementButton", self.onArrangementButton)
    self:bindListener("GoldCoinImage", self.onGoldCoin)
    self:bindListener("GoldCoinValueLabel", self.onGoldCoin)
    self:bindListener("SilverCoinImage", self.onSilverCoin)
    self:bindListener("SilverCoinValueLabel", self.onSilverCoin)
    self:bindListener("SliverCoinPanel", self.onSilverAddButton)
    self:bindListener("AlchemyButton", self.onAlchemyButton)
    self:bindListener("CashSwitchPanel", self.onCashSwitchPanel)

    self:bindListener("SuitButton_1", self.onSwitchButton)
    self:bindListener("SuitButton_2", self.onSwitchButton)
    self:bindListener("FashionButton", self.onFashionButton)
    self:bindListener("SuitButton", self.onSuitButton)
    self:bindListener("TurnRightButton", self.onTurnRightButton)
    self:bindListener("TurnLeftButton", self.onTurnLeftButton)
    -- 金钱、代金券
    self:bindListener("HaveCashCheckBox", self.onCashCheckBox)
    self:bindListener("HaveVoucherCheckBox", self.onVoucherCheckBox)

    self.moneyRGroup = RadioGroup.new()
   -- self.moneyRGroup:setItems(self, { "HaveCashCheckBox", "HaveVoucherCheckBox" }, function() end)

    local moneyType = Me:queryBasicInt("use_money_type")
    self.moneyRGroup:selectRadio(moneyType + 1, true)
    self:updateMoneyInfo()

    -- 金钱 代金券 位置
    local voucherPanel = self:getControl("VoucherPanel")
    local cashPanel = self:getControl("CashPanel")
    self.cashPostionX = cashPanel:getPosition()
    self.voucherPositionX = voucherPanel:getPosition()
    self:initCashSwitchPanel()


    local equipPanel =  self:getControl("EquipPanel", Const.UIPanel)
    local jewelryPanel =  self:getControl("JewelryPanel", Const.UIPanel)
    equipPanel:removeAllChildren()
    jewelryPanel:removeAllChildren()

    local checkCtrl1 = self:getControl("BagTagCheckBox", Const.UICheckBox)
    checkCtrl1:setTag(1)
    local checkCtrl2 = self:getControl("LuggageOneTagCheckBox", Const.UICheckBox)
    checkCtrl2:setTag(2)
    local checkCtrl3 = self:getControl("LuggageTwoTagCheckBox", Const.UICheckBox)
    checkCtrl3:setTag(3)
    local checkCtrl4 = self:getControl("LuggageThreeTagCheckBox", Const.UICheckBox)
    checkCtrl4:setTag(4)
    local checkCtrl5 = self:getControl("LuggageFourTagCheckBox", Const.UICheckBox)
    checkCtrl5:setTag(5)


    self.checkTable = {checkCtrl1, checkCtrl2, checkCtrl3, checkCtrl4, checkCtrl5}

    self.curOpenPages = self:initCheck(Me:getVipType())

    -- 获取背包的PageView控件
    self.bagListView = self:getControl("BagGridListView", Const.UIListView)
    self.bagListView:setTouchEnabled(true)
    self.bagListView:setEnabled(false)

    self.bagLayout = self:getControl("BagPanel", Const.UIPanel)
    self.bagListView:setItemsMargin(LISTVIEW_MARGIN)
    --绑定turnning事件
    -- pageView滚动事件
    local function onTouchBegan(touch, event)
        self.bagListView:setEnabled(true)

        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        Log:D("location : x = %d, y = %d", touchPos.x, touchPos.y)
        touchPos = self.bagLayout:getParent():convertToNodeSpace(touchPos)

        if not self.bagLayout:isVisible() then
            return false
        end

        local box = self.bagLayout:getBoundingBox()
        if nil == box then
            return false
        end

        if cc.rectContainsPoint(box, touchPos) then
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
        Log:D("location : x = %d, y = %d", touchPos.x, touchPos.y)

        local box = self.bagLayout:getBoundingBox()
        if nil == box then
            return false
        end

        local percent = self:getCurScrollPercent()
        local isLeft = (percent - self.lastPercent) > 0
        self:checkCurPercent(percent, isLeft)
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
    local dispatcher = self.bagLayout:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self.bagLayout)


    if self.bagListView == nil then return end
    self.bagListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    -- 创建互斥按钮 --liuhb Jan/31/2015
    -- 创建单选框组
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"BagTagCheckBox", "LuggageOneTagCheckBox", "LuggageTwoTagCheckBox",
        "LuggageThreeTagCheckBox", "LuggageFourTagCheckBox"}, self.onBagCheckBox)
    self.radioGroup:selectRadio(1, true)

    -- 设置形象
    local equipPanel = self:getControl("EquipmentPanel")
    self:setPortrait("UserPanel", Me:getDlgIcon(true), Me:getDlgWeaponIcon(true), equipPanel, nil, nil, nil, nil, Me:queryBasicInt("icon"), nil, nil, nil, nil, Me:getDlgPartIndex(true), Me:getDlgPartColorIndex(true))

    -- 设置跟宠
    self:setFollowPet(equipPanel)

    -- 仙魔光效
    self:addUpgradeMagicToCtrl("UserPanel", Me:queryBasicInt("upgrade/type"), nil, not gf:isBabyShow(Me:getDlgIcon(true)))

    -- 显示所有的物品信息，包括装备、首饰
    self:showAllItems()

    -- 显示金钱相关信息
    -- self:showCoinInfo()

    -- 显示名字
    self:setLabelText("FightingTypeLabel_1", Me:getShowName(), nil, COLOR3.TEXT_DEFAULT)
    self:setLabelText("FightingTypeLabel_2", Me:getShowName(), nil, COLOR3.TEXT_DEFAULT)

    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_FINISH_SORT_PACK")
    self:hookMsg("MSG_INSIDER_INFO")
    self:hookMsg("MSG_UPDATE_APPEARANCE")
    self:hookMsg("MSG_UPDATE_PETS")
    self:hookMsg("MSG_WB_CREATE_BOOK_EFFECT")
    self:hookMsg("MSG_SET_SETTING")

    self.lastTime = 0
    self.Sorted = false

    -- 用来判断滚动方向
    self.lastPercent = 0

    self:MSG_UPDATE()

    self:swichFastionAndEquip()

    -- 背包的标签页
    --local  tabGroup = RadioGroup.new()
    --tabGroup:setItems(self, {"BagDlgCheckBox", "StoreItemDlgCheckBox", "AlchemyDlgCheckBox"}, self.onTabCheckBox)
    --self:setUseType(MONEY_TYPE.VOUCHER, true)
end

function BagDlg:cleanup()
    self.selectBagBoundingBox = nil

    self.gridPanel = {}
    self.root:stopAllActions()

    DlgMgr:sendMsg("BagTabDlg", "setLastDlgInfo", "BagDlg", self:getBagCurIndex())
    EventDispatcher:dispatchEvent(EVENT.BAGDLG_CLEANUP, data)
end

function BagDlg:getBagCurIndex()
    return self.radioGroup:getSelectedRadioIndex()
end

function BagDlg:setBagIndex(x, index)
    --self.bagListView
    self.bagListView:refreshView()
    self.bagListView:doLayout()

    self.lastPercent = 100 * (index - 1) / (TAOTAL_PAGE - 1)

    self.bagListView:getInnerContainer():setPositionX(x)
    self.bagListView:doLayout()

    local checkCtrl = self.radioGroup:getRadioNameIndex(index)
    self:showPanelInCheckBox(checkCtrl, true)
end

function BagDlg:onTabCheckBox(sender, type)
    local name = sender:getName()
    local chosenLable1 = self:getControl("ChosenLabel_1")
    local chosenLable2 = self:getControl("ChosenLabel_2")
    local UnChosenLable1 = self:getControl("UnChosenLabel_1")
    local UnChosenLable2 = self:getControl("UnChosenLabel_2")
end

-- 打开界面需要某些参数需要重载这个函数
function BagDlg:onDlgOpened(param)
    if nil == param[1] then
        -- param[1]为需要选中的物品名称
        return
    end

    if param[1] == CHS[4100634] then
        gf:ShowSmallTips(CHS[4100635])
        gf:ShowSmallTips(CHS[4100636])

        ChatMgr:sendMiscMsg(CHS[4100635])
        ChatMgr:sendMiscMsg(CHS[4100636])
        return
    end

    local pos = InventoryMgr:getBagItemPosByName(param[1])
    if nil == pos then return end

    -- 选中页数
    local page = math.floor((pos - 1) / 25) + 1

    -- 选中物品
    local index = (pos - 1) % 25 + 1
    self.gridPanel[page]:setSelectedGridByIndex(index)
    performWithDelay(self.root, function()
        self:onBagCheckBox(self.checkTable[page])
        self.radioGroup:selectRadio(page, true)

        local sender = self.gridPanel[page]:getGridByIndex(index)
        local rect = self:getBoundingBoxInWorldSpace(sender)
        local items = InventoryMgr:getItemByName(param[1])
        if next(items) then
            InventoryMgr:showItemDlg(items[1].pos, rect)
        end
    end, 0.1)
end

-- 获取当前ListView滚动百分比
function BagDlg:getCurScrollPercent()
    local width = self.bagListView:getInnerContainer():getContentSize().width - self.bagListView:getContentSize().width
    local curPosX = self.bagListView:getInnerContainer():getPositionX()
    return curPosX / width * (-100)
end

function BagDlg:getPrecentByIndex(index, isLfet)
    local prencent = 0
    local width = self.bagListView:getInnerContainer():getContentSize().width - self.bagListView:getContentSize().width

    if isLfet then
        local moveDiatance = GRID_W
        prencent = ((self.bagListView:getContentSize().width  + LISTVIEW_MARGIN )* (index - 1) + moveDiatance) / width * 100

    else
        local moveDiatance = GRID_W + LISTVIEW_MARGIN
        prencent =((self.bagListView:getContentSize().width + LISTVIEW_MARGIN) * (index -1 )- moveDiatance) / width  * 100
    end

    return prencent
end

function BagDlg:toPrentcent(index)
    return (index - 1) / (TAOTAL_PAGE -1) * 100
end

-- 检测下当前移动的百分比,然后进行强制移动
function BagDlg:checkCurPercent(percent, isLeft)

    if isLeft then
        -- 第一页
        if percent < self:getPrecentByIndex(1, true) and percent >= 0 then
            self:clearSelceted(1)
            performWithDelay(self.root, function()
                self.radioGroup:selectRadio(1, true)
                self.bagListView:scrollToPercentHorizontal(0, SCROLL_TIME, true)
                self:showPanelInCheckBox(self.checkTable[1], true)
                self.lastPercent = 0
            end, DELTA_TIME)
            -- 第二页如果是向左
        elseif percent >= self:getPrecentByIndex(1, true) and percent < self:getPrecentByIndex(2, true) then
            self:clearSelceted(2)
            performWithDelay(self.root, function()
                self.radioGroup:selectRadio(2, true)
                local autoRange = 0

                if self.Sorted then
                    autoRange = AUTO_MOVE_DIST
                end

                self.lastPercent = 100 / (TAOTAL_PAGE - 1)
                self.bagListView:scrollToPercentHorizontal(self.lastPercent, SCROLL_TIME, true)
                self:showPanelInCheckBox(self.checkTable[2], true)
            end, DELTA_TIME)

        elseif  percent >= self:getPrecentByIndex(2, true) and percent <= self:getPrecentByIndex(3, true) then
            self:clearSelceted(3)
            performWithDelay(self.root, function()
                self.radioGroup:selectRadio(3, true)
                local autoRange = 0

                if self.Sorted then
                    autoRange = AUTO_MOVE_DIST
                end
                if math.abs(self.lastPercent - 100 * 2 / (TAOTAL_PAGE - 1)) > 1 then self:isBuyVipByPage(3) end
                self.lastPercent = 100 * 2 / (TAOTAL_PAGE - 1)
                self.bagListView:scrollToPercentHorizontal(self.lastPercent, SCROLL_TIME, true)
                self:showPanelInCheckBox(self.checkTable[3], true)

            end, DELTA_TIME)
        elseif  percent >= self:getPrecentByIndex(3, true) and percent <= self:getPrecentByIndex(4, true) then
            self:clearSelceted(4)
            performWithDelay(self.root, function()
                self.radioGroup:selectRadio(4, true)

                if math.abs(self.lastPercent - 100 * 3 / (TAOTAL_PAGE - 1)) > 1 then self:isBuyVipByPage(4) end
                self.lastPercent = 100 * 3 / (TAOTAL_PAGE - 1)
                self.bagListView:scrollToPercentHorizontal(self.lastPercent, SCROLL_TIME, true)
                self:showPanelInCheckBox(self.checkTable[4], true)

            end, DELTA_TIME)
        elseif  percent > self:getPrecentByIndex(4, true) and percent <= 100 then
            self:clearSelceted(5)
            performWithDelay(self.root, function()
                self.radioGroup:selectRadio(5, true)
                self.bagListView:scrollToPercentHorizontal(100, SCROLL_TIME, true)
                self:showPanelInCheckBox(self.checkTable[5], true)
                if self.lastPercent ~= 100 then self:isBuyVipByPage(5) end
                self.lastPercent = 100
            end, DELTA_TIME)
        elseif percent > 100 then
            self:clearSelceted(TAOTAL_PAGE)
            performWithDelay(self.root, function()
                self.radioGroup:selectRadio(TAOTAL_PAGE, true)
                local autoRange = 0

                if self.Sorted then
                    autoRange = AUTO_MOVE_DIST
                end
                --self.bagListView:scrollToPercentHorizontal(100 + AUTO_MOVE_DIST, SCROLL_TIME, true)
                self:showPanelInCheckBox(self.checkTable[TAOTAL_PAGE], true)
                if self.lastPercent ~= 100 then self:isBuyVipByPage(TAOTAL_PAGE) end
                self.lastPercent = 100
            end, DELTA_TIME)
        elseif percent < 0 then
            self.radioGroup:selectRadio(1, true)
            self:clearSelceted(1)
            performWithDelay(self.root, function()
                --self.bagListView:scrollToPercentHorizontal(0, SCROLL_TIME, true)
                self:showPanelInCheckBox(self.checkTable[1], true)
                self.lastPercent = 0
            end, DELTA_TIME)
        end
    else
        if percent >= 0 and percent  < self:getPrecentByIndex(2, false) then
            self:clearSelceted(1)
            performWithDelay(self.root, function()
                self.radioGroup:selectRadio(1, true)
                self.bagListView:scrollToPercentHorizontal(0, SCROLL_TIME, true)
                self:showPanelInCheckBox(self.checkTable[1], true)
                self.lastPercent = 0
            end, DELTA_TIME)
            -- 第二页如果是向左
        elseif percent >= self:getPrecentByIndex(2, false) and percent < self:getPrecentByIndex(3, false) then
            self:clearSelceted(2)
            performWithDelay(self.root, function()
                self.radioGroup:selectRadio(2, true)
                local autoRange = 0

                if self.Sorted then
                    autoRange = AUTO_MOVE_DIST
                end
                self.lastPercent = 100 / (TAOTAL_PAGE - 1)
                self.bagListView:scrollToPercentHorizontal(self.lastPercent, SCROLL_TIME, true)
                self:showPanelInCheckBox(self.checkTable[2], true)

            end, DELTA_TIME)
        elseif percent >= self:getPrecentByIndex(3, false)  and percent <= self:getPrecentByIndex(4, false)  then
            self:clearSelceted(3)
            performWithDelay(self.root, function()
                self.radioGroup:selectRadio(3, true)
                local autoRange = 0

                if self.Sorted then
                    autoRange = AUTO_MOVE_DIST
                end
                if math.abs(self.lastPercent - 100 * 2 / (TAOTAL_PAGE - 1)) > 1 then self:isBuyVipByPage(3) end
                self.lastPercent = 100 * 2 / (TAOTAL_PAGE - 1)
                self.bagListView:scrollToPercentHorizontal(self.lastPercent, SCROLL_TIME, false)
                self:showPanelInCheckBox(self.checkTable[3], true)

            end, DELTA_TIME)

        elseif percent >= self:getPrecentByIndex(4, false)  and percent <= self:getPrecentByIndex(5, false)  then
            self:clearSelceted(4)
            performWithDelay(self.root, function()
                self.radioGroup:selectRadio(4, true)
                local autoRange = 0

                if math.abs(self.lastPercent - 100 * 3 / (TAOTAL_PAGE - 1)) > 1 then self:isBuyVipByPage(4) end
                self.lastPercent = 100 * 3 / (TAOTAL_PAGE - 1)
                self.bagListView:scrollToPercentHorizontal(self.lastPercent, SCROLL_TIME, false)
                self:showPanelInCheckBox(self.checkTable[4], true)

            end, DELTA_TIME)
        elseif percent >= self:getPrecentByIndex(5, false) and percent <= 100 then
            self:clearSelceted(5)
            performWithDelay(self.root, function()
                self.radioGroup:selectRadio(5, true)
                local autoRange = 0

                if self.Sorted then
                    autoRange = AUTO_MOVE_DIST
                end
                self.bagListView:scrollToPercentHorizontal(100 + AUTO_MOVE_DIST, SCROLL_TIME, false)
                self:showPanelInCheckBox(self.checkTable[5], true)
                if self.lastPercent ~= 100 then self:isBuyVipByPage(5) end
                self.lastPercent = 100
            end, DELTA_TIME)


        elseif percent < 0 then
            self.radioGroup:selectRadio(1, true)

            self:clearSelceted(1)
            performWithDelay(self.root, function()
                --self.bagListView:scrollToPercentHorizontal(0, SCROLL_TIME, true)
                self:showPanelInCheckBox(self.checkTable[1], true)
                self.lastPercent = 0
            end, DELTA_TIME)
        elseif percent > 100 then
            self:clearSelceted((TAOTAL_PAGE))
            performWithDelay(self.root, function()
                self.radioGroup:selectRadio((TAOTAL_PAGE), true)
                local autoRange = 0

                if self.Sorted then
                    autoRange = AUTO_MOVE_DIST
                end
                --self.bagListView:scrollToPercentHorizontal(100 + AUTO_MOVE_DIST, SCROLL_TIME, true)
                self:showPanelInCheckBox(self.checkTable[(TAOTAL_PAGE)], true)
                if self.lastPercent ~= 100 then self:isBuyVipByPage(TAOTAL_PAGE) end
                self.lastPercent = 100
            end, DELTA_TIME)
        end
    end
end

-- 显示所有的物品信息，包括装备、首饰
function BagDlg:showAllItems(isNotJumpLeft)
    self.equip = InventoryMgr:getEquipments() -- 武器数据
 --   self.Jewelry = InventoryMgr:getJewelrys() -- 首饰数据
    self.Jewelry = EquipmentMgr:getEffJewelry()
    self.artifact = EquipmentMgr:getEffArtifact() -- 法宝数据

    for i = 1, #self.Jewelry do
        table.insert(self.equip, self.Jewelry[i])
    end

    for i = 1, #self.artifact do
        table.insert(self.equip, self.artifact[i])
    end

    self.equip["count"] = # self.equip

    self.bag1 = InventoryMgr:getBag1Items() -- 包裹数据
    self.bag2 = InventoryMgr:getBag2Items() -- 行囊1数据
    self.bag3 = InventoryMgr:getBag3Items() -- 行囊2数据
    self.bag4 = InventoryMgr:getBag4Items() -- 行囊3数据
    self.bag5 = InventoryMgr:getBag5Items() -- 行囊4数据

    local totalBag = {self.bag1, self.bag2, self.bag3, self.bag4, self.bag5}

    -- 显示装备
    self:showEquip()

    -- 显示 未开放的
    -- self:showUnOpenFunction()
    self:getControl("UnOpenPanel"):setVisible(false)

    -- 显示首饰
    --self:showJewelry()

    -- 默认显示包裹数据
    --self:showItems(self.bag1)
    self.gridPanel = {}
    self:initBagItemInfo(totalBag)
    --self.radioGroup:selectRadio(1, true)

    if not isNotJumpLeft then
        self.radioGroup:selectRadio(1, true)
        self.bagListView:jumpToLeft()
    end
end

-- 初始化背包信息
-- bagData[1]
-- bagData[2]
-- bagData[3]
function BagDlg:initBagItemInfo(bagData)
    self.bagListView:removeAllItems()
    for i, v in ipairs(bagData) do
        self:showItems(i, v)
    end
end


-- 更新背包内容
function BagDlg:updateBagInfo(bagData)
    local count = bagData.count

    for i = 1, count do
        local data = bagData[i]

        if data.pos <= EQUIP.BACK_ARTIFACT then
            self.equip = InventoryMgr:getEquipments() -- 武器数据
    --        self.Jewelry = InventoryMgr:getJewelrys() -- 首饰数据
            self.Jewelry = EquipmentMgr:getEffJewelry()
            self.artifact = EquipmentMgr:getEffArtifact() -- 法宝数据

            for i = 1, #self.Jewelry do
                table.insert(self.equip, self.Jewelry[i])
            end

            for i = 1, #self.artifact do
                table.insert(self.equip, self.artifact[i])
            end

            self.equip["count"] = # self.equip

            -- 显示装备
            self:showEquip()
        else
            local pos = data.pos - BAG_INDEX_START
            if pos >= 1 and pos <= BAG_ROW_NUM * BAG_COL_NUM then
                self.bag1 = InventoryMgr:getBag1Items()
                self.gridPanel[1]:setGridData(self.bag1[pos], pos, GRID_W, GRID_H)
            end

            if pos > BAG_ROW_NUM * BAG_COL_NUM and pos <= BAG_ROW_NUM * BAG_COL_NUM * 2 then
                self.bag2 = InventoryMgr:getBag2Items()
                self.gridPanel[2]:setGridData(self.bag2[pos - BAG_ROW_NUM * BAG_COL_NUM], pos - BAG_ROW_NUM * BAG_COL_NUM, GRID_W, GRID_H)
            end

            if pos > BAG_ROW_NUM * BAG_COL_NUM * 2 and pos <= BAG_ROW_NUM * BAG_COL_NUM * 3 then
                self.bag3 = InventoryMgr:getBag3Items()
                self.gridPanel[3]:setGridData(self.bag3[pos - BAG_ROW_NUM * BAG_COL_NUM * 2], pos - BAG_ROW_NUM * BAG_COL_NUM * 2, GRID_W, GRID_H, self:isGray(3))
            end

            if pos > BAG_ROW_NUM * BAG_COL_NUM * 3 and pos <= BAG_ROW_NUM * BAG_COL_NUM * 4 then
                self.bag4 = InventoryMgr:getBag4Items()
                self.gridPanel[4]:setGridData(self.bag4[pos - BAG_ROW_NUM * BAG_COL_NUM * 3], pos - BAG_ROW_NUM * BAG_COL_NUM * 3, GRID_W, GRID_H, self:isGray(4))
            end

            if pos > BAG_ROW_NUM * BAG_COL_NUM * 4 and pos <= BAG_ROW_NUM * BAG_COL_NUM * 5 then
                self.bag5 = InventoryMgr:getBag5Items()
                self.gridPanel[5]:setGridData(self.bag5[pos - BAG_ROW_NUM * BAG_COL_NUM * 4], pos - BAG_ROW_NUM * BAG_COL_NUM * 4, GRID_W, GRID_H, self:isGray(5))
            end
        end
    end

    self:initFashionPanel()
end

function BagDlg:isGray(page)
  --[[  if page == 3 then
        if Me:getVipType() == 0 then
            return true
        end
    elseif page == 4 then
        if Me:getVipType() ~= 3 then
            return true
        end
    end]]

    if page > self:getHaveOpenPage() then
        return true
    end

    return false
end

-- 整理背包
function BagDlg:sortBagItem()
    self:showAllItems(true)
end

-- 显示装备相关信息
function BagDlg:showEquipInfo(panelName, data, callback)
    local panel = self:getControl(panelName, Const.UIPanel)
    local size = panel:getContentSize()
    panel:removeAllChildren()
    local colunm = 2

    local rowNum = data.count / colunm
    local rowSpace = EQUIP_ROW_SPACE
    local colunmSpace = size.width - colunm * GRID_H

    local grids = GridPanel.new(
        size.width, size.height,
        rowNum, colunm,
        GRID_W, GRID_H,
        rowSpace, colunmSpace)

   -- grids:setGridTop(EQUIP_GRID_TOP)

    grids:setData(data, 1, function(idx, sender)
        callback(idx, sender)
        self:clearAllSelected()
    end)

    self.equipmentGrids = grids
    panel:addChild(grids)
end


function BagDlg:showUnOpenFunction()
    local panel = self:getControl("UnOpenPanel")
    local size = panel:getContentSize()
    local colunm = 2

    local rowNum = 1
    local rowSpace = EQUIP_ROW_SPACE - 2
    local colunmSpace = size.width - colunm * GRID_H

    local grids = GridPanel.new(
        size.width, size.height,
        rowNum, colunm,
        GRID_W, GRID_H,
        rowSpace, colunmSpace)

    local data = InventoryMgr:getUnOpenFunction()
    grids:setData(data, 1, function(idx, sender)
        self:clearAllSelected()
    end)

    self.unOpenFucGrids = grids

    panel:addChild(grids)
end
-- 显示装备
function BagDlg:showEquip()
    self:showEquipInfo('EquipPanel', self.equip, function(idx, sender)
        -- 显示装备信息悬浮框
        if idx >= 1 and idx <= 4 then
            local rect = self:getBoundingBoxInWorldSpace(sender)
            InventoryMgr:showEquipDescDlg(self.equip[idx].pos, rect)
        elseif idx >= 5 and idx <= 8 then

            -- 显示首饰信息悬浮框
            local rect = self:getBoundingBoxInWorldSpace(sender)
            InventoryMgr:showJewelryDescDlg(self.equip[idx].pos, rect)
        elseif idx == 9 then
            local rect = self:getBoundingBoxInWorldSpace(sender)
            local artifact = InventoryMgr:getItemByPos(self.equip[idx].pos)
            -- 显示法宝
            InventoryMgr:showArtifact(artifact, rect)
        end
    end)
end

-- 显示首饰
function BagDlg:showJewelry()
    self:showEquipInfo('JewelryPanel', self.Jewelry, function(idx, sender)

        -- 显示首饰信息悬浮框
        local rect = self:getBoundingBoxInWorldSpace(sender)
        InventoryMgr:showJewelryDescDlg(self.Jewelry[idx].pos, rect)
    end)
end

-- 显示金钱相关信息
function BagDlg:showCoinInfo(cash, silver_coin, gold_coin)
    if nil == cash then
        cash = Me:queryBasicInt('cash')
    end

    if nil == silver_coin then
        silver_coin = Me:queryBasicInt('silver_coin')
    end

    if nil == gold_coin then
        gold_coin = Me:queryBasicInt('gold_coin')
    end

    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(cash))
    self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23)
    local silverText = gf:getArtFontMoneyDesc(tonumber(silver_coin))
    self:setNumImgForPanel("SilverCoinValuePanel", ART_FONT_COLOR.DEFAULT, silverText, false, LOCATE_POSITION.MID, 23)
    local goldText = gf:getArtFontMoneyDesc(tonumber(gold_coin))
    self:setNumImgForPanel("GoldCoinValuePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.MID, 23)
end

-- 清除所有GridPanel的选中效果
function BagDlg:clearAllSelected()
    if self.equipmentGrids then
        self.equipmentGrids:clearSelected()
    end

    if self.unOpenFucGrids then
        self.unOpenFucGrids:clearSelected()
    end

    for i = 1 , BAG_COUNT do
        if self.gridPanel[i] then
            self.gridPanel[i]:clearSelected()
        end
    end
end

-- 显示物品信息
function BagDlg:showItems(index, data)

    local bagView = self:getControl('BagGridListView', Const.UIListView)
    local size = bagView:getContentSize()
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
    --grids:setGridTextFontSize(15)

    grids:setData(data, 1, function(idx, sender)
        if not data[idx] or not data[idx].pos then return end

        -- 背包物品pos从41开始
        local page = math.floor((data[idx].pos - 40 - 1) / 25) + 1
        if page ~= self:getBagCurIndex() then
            -- WDSY-30110 打开界面setBagIndex后，ListView在下一帧再刷新，导致
            -- 当前页数与将要显示的页数可能不相等，此时不做后续处理
            return
        end

        EventDispatcher:dispatchEvent(EVENT.BAG_ITEM_CLICK, data[idx])

        self:clearAllSelected()
        -- 刷新标志位
        sender:updateBagGrid()

        if InventoryMgr:getItemByPos(data[idx].pos) then
            -- 显示道具信息悬浮框
            local rect = self:getBoundingBoxInWorldSpace(sender)
            InventoryMgr:showItemDlg(data[idx].pos, rect)
        else
            self:isBuyVipByPage(page, true)
        end

        self.root:requestDoLayout()
    end, self:isGray(index))

    layout:addChild(grids)
    self.bagListView:pushBackCustomItem(layout)
    self.showBag = data
    self.gridPanel[index] = grids
end

-- 显示包裹道具
function BagDlg:onBagCheckBox(sender, eventType)
    local name = sender:getName()
    local index = 1
    if name == "LuggageOneTagCheckBox" then
        index = 2
    elseif name == "LuggageTwoTagCheckBox" then
        index = 3
    elseif name == "LuggageThreeTagCheckBox" then
        index = 4
    elseif name == "LuggageFourTagCheckBox" then
        index = 5
    end

    self.lastPercent = self:toPrentcent(index)
    self.bagListView:scrollToPercentHorizontal(self:toPrentcent(index), SCROLL_TIME, true)
    self:clearSelceted(index)
    self:showPanelInCheckBox(sender, true)

    self:isBuyVipByPage(index)
end

function BagDlg:clearSelceted(exceptIndex)
    for i = 1, BAG_COUNT do
        if i ~= exceptIndex and self.gridPanel[i] then
            self.gridPanel[i]:clearSelected()
        end
    end

    --[[
    local checkBox2 = self:getControl("LuggageTwoTagCheckBox", Const.UICheckBox)
    local checkBox3 = self:getControl("LuggageThreeTagCheckBox", Const.UICheckBox)
    self:setCtrlVisible("CoverImage", false, checkBox2)
    self:setCtrlVisible("CoverImage", false, checkBox3)
    --]]
end

-- 整理道具
function BagDlg:onArrangementButton(sender, eventType)
    -- 整理包裹和行囊中的道具
    if gf:getServerTime() - self.lastTime > 5 then
        InventoryMgr:arrangeBag()
        self.lastTime = gf:getServerTime()
        self.Sorted = true
    else
        gf:ShowSmallTips(CHS[6000208])
    end
end

-- 显示checkbox下的panel
function BagDlg:showPanelInCheckBox(checkBox, isShow)
    for k, v in ipairs(self.checkTable) do
        if v ~= checkBox then
            local choosePanel = v:getChildByName("ChosenPanel")
            local unChoosePanel = v:getChildByName("UnChosenPanel")
            choosePanel:setVisible(false)
            unChoosePanel:setVisible(true)
            v:setSelectedState(false)
        else
            if k == 1 or k == 2 then
                local checkBox2 = self:getControl("LuggageTwoTagCheckBox", Const.UICheckBox)
                local checkBox3 = self:getControl("LuggageThreeTagCheckBox", Const.UICheckBox)
                self:setCtrlVisible("CoverImage", false, checkBox2)
                self:setCtrlVisible("CoverImage", false, checkBox3)
            end
        end
    end

    local choosePanel = checkBox:getChildByName("ChosenPanel")
    local unChoosePanel = checkBox:getChildByName("UnChosenPanel")
    choosePanel:setVisible(isShow)
    unChoosePanel:setVisible(not isShow)
    checkBox:setSelectedState(isShow)
end

-- 给予获取银元宝的提示
function BagDlg:onSilverCoin(sender, eventType)
    gf:showTipInfo(CHS[2000003], sender)
end

-- 给予获取银元宝的提示
function BagDlg:onSilverAddButton(sender, eventType)
    InventoryMgr:openItemRescourse(CHS[3002297])
end

-- 给予获取金元宝的提示
function BagDlg:onGoldCoin(sender, eventType)
    gf:showTipInfo(CHS[2000003], sender)
end

function BagDlg:MSG_UPDATE()
    --self:updateMoneyInfo()
    self:initCashSwitchPanel()

    self:setCtrlVisible("SuitButton_1", (Me:queryBasicInt("equip_page") + 1 == 1))
    self:setCtrlVisible("SuitButton_2", (Me:queryBasicInt("equip_page") + 1 == 2))
end

function BagDlg:updateMoneyInfo()
    -- 更新金钱相关信息
    local radioName = self.moneyRGroup:getSelectedRadioName()
    if "HaveCashCheckBox" == radioName then
        self:CashCheckBox()
    elseif "HaveVoucherCheckBox" == radioName then
        self:VoucherCheckBox()
    end
end

function BagDlg:onAlchemyButton()
    DlgMgr:openDlg("AlchemyDlg")
    DlgMgr:closeDlg(self.name)
end

-- 金钱响应
function BagDlg:onCashCheckBox(sender, eventType)
    self:setUseType(MONEY_TYPE.CASH)
end

function BagDlg:CashCheckBox()
    local cash = Me:query("cash")
    self:showCoinInfo(cash)
    self.moneyRGroup:selectRadio(1, true)
end

-- 代金券响应
function BagDlg:onVoucherCheckBox(sender, eventType)
    self:setUseType(MONEY_TYPE.VOUCHER)
end

function BagDlg:setUseType(type, notShowTip)
    if type == MONEY_TYPE.VOUCHER then
        if Me:queryBasicInt("use_money_type") == MONEY_TYPE.VOUCHER then return end
        if not notShowTip then
            gf:ShowSmallTips(CHS[3002298])
        end

        self:VoucherCheckBox()
        CharMgr:setUseMoneyType(MONEY_TYPE.VOUCHER)
    else
        if Me:queryBasicInt("use_money_type") == MONEY_TYPE.CASH then return end

        if not notShowTip then
            gf:ShowSmallTips(CHS[3002299])
        end

        self:CashCheckBox()
        CharMgr:setUseMoneyType(MONEY_TYPE.CASH)
    end
end

function BagDlg:onSwitchButton()
    EquipmentMgr:cmdBackEquip()
end

function BagDlg:onSuitButton()
    self:setCtrlVisible("EquipmentPanel", true)
    self:setCtrlVisible("FashionPanel", false)
end

function BagDlg:onFashionButton()
    -- 请求打开自定义外观界面
    gf:CmdToServer("CMD_FASION_CUSTOM_VIEW", {para = "CustomDressDlg"})
end

function BagDlg:setFollowPet(equipPanel)
    -- 设置跟宠
    local item = InventoryMgr:getItemByPos(EQUIP.EQUIP_FOLLOW_PET )
    local itemName = item and item.name
    local followPetIcon
    if itemName then
        followPetIcon = FollowPet[itemName] and FollowPet[itemName].effect_icon
    end
    self:setPortrait("UserPanel", followPetIcon, 0, equipPanel, nil, nil, nil, FOLLOW_SPRITE_OFFPOS[5], 0, nil, nil, Dialog.TAG_PORTRAIT1, true)
end

function BagDlg:initFashionPanel()

    -- 显示名字
    self:setLabelText("FightingTypeLabel_1", Me:getShowName(), nil, COLOR3.TEXT_DEFAULT)
    self:setLabelText("FightingTypeLabel_2", Me:getShowName(), nil, COLOR3.TEXT_DEFAULT)

    -- 设置时装形象
    self.dir = 5
    local fashionPanel = self:getControl("FashionPanel")
    self:setPortrait("UserPanel", Me:getDlgIcon(true), Me:getDlgWeaponIcon(true), fashionPanel, nil, nil, nil, nil, Me:queryBasicInt("icon"), nil, nil, nil, nil, Me:getDlgPartIndex(true), Me:getDlgPartColorIndex(true))

    -- 设置跟宠
    self:setFollowPet(fashionPanel)

    -- 仙魔光效
    self:addUpgradeMagicToCtrl("UserPanel", Me:queryBasicInt("upgrade/type"), fashionPanel, not gf:isBabyShow(Me:getDlgIcon(true)))

    self:setLabelText("FightingTypeLabel_1", Me:getShowName(), fashionPanel, COLOR3.TEXT_DEFAULT)
    self:setLabelText("FightingTypeLabel_2", Me:getShowName(), fashionPanel, COLOR3.TEXT_DEFAULT)

    local fashionEquip = InventoryMgr:getFashionData()
    self:showEquipInfo('FashionEquipPanel', fashionEquip, function(idx, sender)
        local rect = self:getBoundingBoxInWorldSpace(sender)
        local item = InventoryMgr:getItemByPos(fashionEquip[idx].pos)
        if not item then return end
        InventoryMgr:showFashioEquip(item, rect)
    end)

    self:updateLayout("FashionPanel")
end

-- 金币，代金券切换
function BagDlg:onCashSwitchPanel()
    local voucherPanel = self:getControl("VoucherPanel")
    local cashPanel = self:getControl("CashPanel")
    self:initCashSwitchPanel()
    local action
     if Me:queryBasicInt("use_money_type") == MONEY_TYPE.CASH then
        CharMgr:setUseMoneyType(MONEY_TYPE.VOUCHER)
        local moveto = cc.MoveTo:create(0.3,cc.p(self.voucherPositionX, voucherPanel:getPositionY()))
        local fuc = cc.CallFunc:create(function ()
            gf:ShowSmallTips(CHS[3002298])
            self:initSwithedInfo()
        end)

        action = cc.Sequence:create(moveto, fuc)

        cashPanel:runAction(action)
        voucherPanel:stopAllActions()
     else
        CharMgr:setUseMoneyType(MONEY_TYPE.CASH)
        local moveto = cc.MoveTo:create(0.3, cc.p(self.cashPostionX, voucherPanel:getPositionY()))
        local fuc = cc.CallFunc:create(function  ()
            self:initSwithedInfo()
            gf:ShowSmallTips(CHS[3002299])
            end)

        action = cc.Sequence:create(moveto, fuc)
        cashPanel:stopAllActions()
        voucherPanel:runAction(action)
     end
end

function BagDlg:initCashSwitchPanel()
    self:initSwithedInfo()
    local voucherPanel = self:getControl("VoucherPanel")
    voucherPanel:setPosition(self.voucherPositionX, voucherPanel:getPositionY())
    local cashPanel = self:getControl("CashPanel")
    cashPanel:setPosition(self.cashPostionX, voucherPanel:getPositionY())
end

function BagDlg:initSwithedInfo()
    local voucherPanel = self:getControl("VoucherPanel")
    local cashPanel = self:getControl("CashPanel")
    local voucherIamge = self:getControl("VoucherImage")
    local chasIamge = self:getControl("MoneyImage")

    if Me:queryBasicInt("use_money_type") == MONEY_TYPE.CASH  then
        voucherPanel:setVisible(false)
        voucherIamge:setVisible(false)
        cashPanel:setVisible(true)
        chasIamge:setVisible(true)
        local cash = Me:query("cash")
        self:showCoinInfo(cash)
    else
        voucherPanel:setVisible(true)
        voucherIamge:setVisible(true)
        cashPanel:setVisible(false)
        chasIamge:setVisible(false)
        local voucher = Me:query("voucher")
        self:showCoinInfo(voucher)
    end
end

function BagDlg:VoucherCheckBox()
    local voucher = Me:query("voucher")
    self:showCoinInfo(voucher)
    self.moneyRGroup:selectRadio(2, true)
end


function BagDlg:MSG_SET_SETTING(data)
    if data.count <= 0 then return end

    if data.setting["award_supply_artifact"] then
        self:showEquip()
    end
end

function BagDlg:MSG_INVENTORY(data)
    if data.count == 0 then return end
    if InventoryMgr.isArranging then
        -- 未整理完毕，不刷新
        return
    end

    -- 显示所有的物品信息，包括装备、首饰
    self:updateBagInfo(data)

    self:setFollowPet()
end

-- 服装面板和装备面板切换
function BagDlg:swichFastionAndEquip(isFashionEquip)
    if isFashionEquip then -- 时装
        self:onFashionButton()
    else
        self:onSuitButton()
    end
end

function BagDlg:MSG_FINISH_SORT_PACK()
    if InventoryMgr.isArranging then
        -- 未整理完毕，不刷新
        return
    end
    self:sortBagItem()
end

function BagDlg:playExtraSound(sender)
    if sender:getName() == "ArrangementButton" then
        SoundMgr:playEffect("item")
        return true
    end

    return false
end

-- 获取当前页数
function BagDlg:getCurPage()
    if self:isCheck("BagTagCheckBox") then
        return 1
    end

    if self:isCheck("LuggageOneTagCheckBox") then
        return 2
    end

    if self:isCheck("LuggageTwoTagCheckBox") then
        return 3
    end

    if self:isCheck("LuggageThreeTagCheckBox") then
        return 4
    end

    if self:isCheck("LuggageFourTagCheckBox") then
        return 5
    end
end

--返回点击的BoundingBox,需要转换成窗口坐标
function BagDlg:getSelectItemBox(type)
    if "selectBag" == type then
        self.itemCtrl = nil
        self.isGetUndefineEquip = nil
        local pos = InventoryMgr:getUndefineEquipLevel20()
        if nil == pos then return end
        local index = math.floor((pos - 1) / 25) + 1
        local realPos = (pos - 1) % 25 + 1
        local pageCtrl = self.checkTable[index]
        self.itemCtrl = self.gridPanel[index]:getGridByIndex(realPos)

        local radioName = self.radioGroup:getSelectedRadioName()
        if radioName == pageCtrl:getName() then
            self.selectBagBoundingBox = nil
            return self.selectBagBoundingBox
        end

        self.selectBagBoundingBox = self:getBoundingBoxInWorldSpace(pageCtrl)
        return self.selectBagBoundingBox
    elseif "undefinedEquip" == type then
        if self.itemCtrl then
            return self:getBoundingBoxInWorldSpace(self.itemCtrl)
        end
    elseif "newGift" == type then
        local equipName = EquipmentMgr:getTenLvEquipNameByPolar(Me:queryBasicInt("polar"))
        local pos = InventoryMgr:getBagItemPosByName(equipName)
        if nil == pos then return end
        pos = pos + 40
        local checkBox = self:getControl("BagTagCheckBox")
        if pos >= 41 and pos < 41 + 25 then
            checkBox = self:getControl("BagTagCheckBox")
            if self:isCheck("BagTagCheckBox") then return end
        elseif pos >= 41 + 25 and pos < 41 + 50 then
            checkBox = self:getControl("LuggageOneTagCheckBox")
            if self:isCheck("LuggageOneTagCheckBox") then return end
        elseif pos >= 41 + 50 and pos < 41 + 75 then
            checkBox = self:getControl("LuggageTwoTagCheckBox")
            if self:isCheck("LuggageTwoTagCheckBox") then return end
        elseif pos >= 41 + 75 and pos < 41 + 100 then
            checkBox = self:getControl("LuggageThreeTagCheckBox")
            if self:isCheck("LuggageThreeTagCheckBox") then return end
        else
            checkBox = self:getControl("LuggageFourTagCheckBox")
            if self:isCheck("LuggageFourTagCheckBox") then return end
        end

        self.selectBagBoundingBox = self:getBoundingBoxInWorldSpace(checkBox)
        return self.selectBagBoundingBox
    elseif "getWeapon" == type then
        local equipName = EquipmentMgr:getTenLvEquipNameByPolar(Me:queryBasicInt("polar"))
        local pos = InventoryMgr:getBagItemPosByName(equipName)
        if nil == pos then return end

        -- 选中页数
        local page = math.floor((pos - 1) / 25) + 1

        -- 选中物品
        local index = (pos - 1) % 25 + 1
        self.gridPanel[page]:getGridByIndex(index)
        return self:getBoundingBoxInWorldSpace(self.gridPanel[page]:getGridByIndex(index))
    end
end

-- 如果需要使用指引通知类型，需要重载这个函数
function BagDlg:youMustGiveMeOneNotify(param)
    if "undefinedEquip" == param then
        if self.selectBagBoundingBox then
            performWithDelay(self.root, function()
                GuideMgr:youCanDoIt(self.name, param)
            end, SCROLL_TIME)
        else
            GuideMgr:youCanDoIt(self.name, param)
        end
    elseif "getNewWeapon" == param then
        if self.selectBagBoundingBox then
            performWithDelay(self.root, function()
                GuideMgr:youCanDoIt(self.name, param)
            end, SCROLL_TIME)
        else
            GuideMgr:youCanDoIt(self.name, param)
        end
    end
end

-- 点击位置  for 新手礼包
function BagDlg:selectByPos(pos)
    local offpos = pos - 40
    -- 选中页数
    local page = math.floor((offpos - 1) / 25) + 1
    -- 选中物品
    local index = (offpos - 1) % 25 + 1
    local sender = self.gridPanel[page].grids[index]
    -- 刷新标志位
    self.gridPanel[page]:setSelectedGridByIndex(index)

    performWithDelay(self.root, function()
        local rect = self:getBoundingBoxInWorldSpace(sender)
        InventoryMgr:showItemDlg(pos, rect)
    end, 0.1)
    self.root:requestDoLayout()
end

-- 设置关闭时候是否要通知指引管理器清空新手礼包装备列表
function BagDlg:setCleanGuideEquip(isOk)
    self.isCleanGuideEquip = isOk
end

-- 重载
function BagDlg:close(now)
    if self.isCleanGuideEquip then
        GuideMgr.equipList = {}
    end
    Dialog.close(self, now)
end

-- 是否提示购买vip
function BagDlg:isBuyVipByPage(page, alwaysTip)
    if page > self:getHaveOpenPage() then
        if alwaysTip or not InventoryMgr.isShowNeedVip.bag[page] then
            InventoryMgr.isShowNeedVip.bag[page] = true

            InventoryMgr:checkBagMorePageTips()
                    end
            end
end

-- 已开启的页数
function BagDlg:getHaveOpenPage()
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

function BagDlg:initCheck(vip)
   --[[ gf:resetImageView(self.checkTable[3])
    gf:resetCheckSelectImageView(self.checkTable[3])

    gf:resetImageView(self.checkTable[4])
    gf:resetCheckSelectImageView(self.checkTable[4])
    if vip == 0 then
        gf:grayImageView(self.checkTable[3])
        gf:grayImageView(self.checkTable[4])
        gf:grayCheckSelectImageView(self.checkTable[3])
        gf:grayCheckSelectImageView(self.checkTable[4])
    elseif vip == 1 or vip == 2 then
        gf:grayImageView(self.checkTable[4])
        gf:grayCheckSelectImageView(self.checkTable[4])
    end]]

    local canOpenPage = self:getHaveOpenPage()
    for i = 1, BAG_COUNT do
        if i > canOpenPage then
            gf:grayImageView(self.checkTable[i])
            gf:grayCheckSelectImageView(self.checkTable[i])
        else
            gf:resetImageView(self.checkTable[i])
            gf:resetCheckSelectImageView(self.checkTable[i])
        end
    end

    return canOpenPage
end

function BagDlg:MSG_UPDATE_APPEARANCE(data)
    self:setPortrait("UserPanel", Me:getDlgIcon(true), Me:getDlgWeaponIcon(true), nil, nil, nil, nil, nil, Me:queryBasicInt("icon"), nil, nil, nil, nil, Me:getDlgPartIndex(true), Me:getDlgPartColorIndex(true))
    self:setFollowPet(nil)
    self:addUpgradeMagicToCtrl("UserPanel", Me:queryBasicInt("upgrade/type"), nil, not gf:isBabyShow(Me:getDlgIcon(true)))
    self:initFashionPanel()
end

function BagDlg:MSG_INSIDER_INFO(data)
    local canOpenPage = self:initCheck(data.vipType)
    if canOpenPage ~= self.curOpenPages then
        self:showAllItems(true)
        self.curOpenPages = canOpenPage
    end
end

function BagDlg:MSG_UPDATE_PETS(data)
    local canOpenPage = self:initCheck(data.vipType)
    if canOpenPage ~= self.curOpenPages then
        self:showAllItems(true)
        self.curOpenPages = canOpenPage
    end
end

function BagDlg:MSG_WB_CREATE_BOOK_EFFECT(data)
    self:setItemAround(data.pos, true)
end

function BagDlg:onTurnRightButton()
    if Me:queryBasicInt('special_icon') == 0 and Me:queryBasicInt('mount_icon') == 0 then
        self.dir = self.dir - 1
        if self.dir < 0 then
            self.dir = 7
        end
    else
        -- 有special_icon或者有mount_icon时候 只有四个方向
        self.dir = self.dir - 2
        if self.dir < 0 then
            self.dir = 7
        end
    end
    local fashionPanel = self:getControl("FashionPanel")
    self:getControl("UserPanel", nil, fashionPanel):removeAllChildren()
    self:setPortrait("UserPanel", Me:getDlgIcon(true), Me:getDlgWeaponIcon(true), fashionPanel, nil, nil, nil, nil, Me:queryBasicInt("icon"), nil, self.dir, nil,  nil, Me:getDlgPartIndex(true), Me:getDlgPartColorIndex(true))
    self:setPortrait("UserPanel", ResMgr:getFollowSprite(Me:getDlgIcon(true)), 0, fashionPanel, nil, nil, nil, FOLLOW_SPRITE_OFFPOS[self.dir], 0, nil, self.dir, Dialog.TAG_PORTRAIT1, true)
    self:setFollowPet(fashionPanel)
end


function BagDlg:onTurnLeftButton()
    if Me:queryBasicInt('special_icon') == 0 and Me:queryBasicInt('mount_icon') == 0 then
        self.dir = self.dir + 1
        if self.dir > 7 then
            self.dir = 0
        end
    else
        -- 有special_icon或者有mount_icon时候 只有四个方向
        self.dir = self.dir + 2
        if self.dir > 7 then
            self.dir = 1
        end
    end
    local fashionPanel = self:getControl("FashionPanel")
    self:getControl("UserPanel", nil, fashionPanel):removeAllChildren()
    self:setPortrait("UserPanel", Me:getDlgIcon(true), Me:getDlgWeaponIcon(true), fashionPanel, nil, nil, nil, nil, Me:queryBasicInt("icon"), nil, self.dir, nil, nil, Me:getDlgPartIndex(true), Me:getDlgPartColorIndex(true))
    self:setFollowPet(fashionPanel)
end

function BagDlg:setItemAround(pos, enable)
    local offpos = pos - 40
    -- 选中页数
    local page = math.floor((offpos - 1) / 25) + 1
    -- 选中物品
    local index = (offpos - 1) % 25 + 1
    local sender = self.gridPanel[page].grids[index]
    local data = sender.data
    data.isItemAround = enable
    sender:updateBagGrid()
    performWithDelay(self.root, function()
        self:onBagCheckBox(self.checkTable[page])
        self.radioGroup:selectRadio(page, true)
    end, 0.1)
end

-- 关闭背包界面
function BagDlg:onCloseButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
    DlgMgr:closeAllFloatDlg()
end

return BagDlg
