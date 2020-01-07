-- MarketBuyDlg.lua
-- Created by liuhb Apr/22/2015
-- 集市界面

local MarketBuyDlg = Singleton("MarketBuyDlg", Dialog)

local LEVEL_LIMIT = 25

local STATIC = {
    row = MarketMgr.buyRow,
    col = MarketMgr.buyCow,
    margin = 1,
}

local VIEW_TYPE = {
    LIST = 1,
    NONE = 2,
    LOAD = 3,
}

local VIEW = {
    "ItemListPanel",
    "NoticePanel",
    "WaitingPanel"
}

local ONE_KEY = {
    CHS[5000141],
    CHS[5000142],
    CHS[5000143],
}

local leftSelectCtrls = {}

local SEARCH_COST = 10000

local PAGE_CONTAIN_NUM = 8
local SCROLL_MARGIN = 20

MarketBuyDlg.itemsListCtrls = {}
MarketBuyDlg.leftListData = {}

local CONST_DATA =
{
    Colunm = 2
}

local ITEM_CLASS =
    {
        CHS[7000306],   -- 搜索结果
        CHS[3002964],   -- 装备
        CHS[3002965],     -- 宠物
        CHS[3002966],   -- 高级首饰
        CHS[7000144],   -- 法宝
        CHS[3002967],   -- 超级黑水晶
        CHS[3002968],
        CHS[3002969],
        CHS[3002970], -- 装备道具
        CHS[3002971],     -- 宠物道具
        CHS[3002972],
        CHS[3002973],   -- 妖石
        CHS[4200733],
        CHS[3002974],
        CHS[3002975],
        CHS[4100000],
        CHS[2000369],
    }

local PUBLIC_ITEM_CLASS =
    {
        [CHS[3002964]] = CHS[3002964],
        [CHS[3002965]] = CHS[3002965],
        [CHS[3002966]] = CHS[3002966],
        [CHS[3002967]] = CHS[3002967],
        [CHS[3002968]] = CHS[3002968],
        [CHS[7000144]] = CHS[7000144],
    }


local NEED_CONFORM_COST = 3000000

function MarketBuyDlg:getCallBackFunc(func)
    return function(self, sender, eventType)
        self:resetContinueClick()
        func(self, sender, eventType)
    end
end

function MarketBuyDlg:init()
    self:bindListener("SearchButton", self:getCallBackFunc(self.onSearchButton))
    self:bindListener("LeftButton", self:getCallBackFunc(self.onLeftButton))
    self:bindListener("RightButton", self:getCallBackFunc(self.onRightButton))
    self:bindListener("AddButton", self:getCallBackFunc(self.onAddButton))
    self:bindListener("ResetButton", self:getCallBackFunc(self.onResetButton))
    self:bindListener("MarketSellButton", self:getCallBackFunc(self.onMarketSellButton))
    self:bindListener("MoneyPanel", self.onMoneyPanel)
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("CollectionButton", self.onCollectionButton)
    self:bindListener("CancelCollectionButton", self.onCancelCollectionButton)
    self:bindListener("PriceSortButton", self.onPriceSortButton)
    self:bindListener("UnlockButton", self.onUnlockButton)
    self:bindListener("LianxiButton", self.onLianxiButton)
    self:bindListener("RefreshButton", self.onRefreshButton)
    self:setCtrlVisible("ViewButton", false)

    -- 打开数字键盘
    self:bindNumInput("PageInfoPanel", nil, self.inputLimit)

    -- 排序按钮
    self:bindListener("UnitPanel1", self.onUnitPanel1)
    self:bindListener("UnitPanel2", self.onUnitPanel2)
    self:bindListener("UnitPanel3", self.onUnitPanel3)
    self:bindListener("UnitPanel4", self.onUnitPanel4)

    self:setCtrlVisible("ThirdButton", false)

    self:hookMsg("MSG_STALL_SERACH_ITEM_LIST")
    self:hookMsg("MSG_REFRESH_STALL_ITEM")
    self:hookMsg("MSG_SAFE_LOCK_INFO")

    self.allSellItems = require("cfg/MarketSellItems")
    self.curPage = 0
    self.totalPage = 0
    self.posxTable = {}
    local thirdBtn = self:getControl("ThirdButton")
    if thirdBtn then
        self.posxTable[1] = thirdBtn:getPositionX()
    end

    local priceSortBtn = self:getControl("PriceSortButton")
    if priceSortBtn then
        self.posxTable[2] = priceSortBtn:getPositionX()
    end

    -- 当没有排序时，设置为默认升序，为false时是降序
    if self.upSort == nil then
        self.upSort  = true
        self.sortType = "price"
    end

    self.isOnBuyButton = false
    -- 根据交易类型设置ui
    self:setTradeTypeUI()

    -- 根据交易类型设置ui
    self:initClassList()

    -- 绑定二级菜单外关闭二级菜单
    self:bindSecondClassTouchEvent()

    -- 绑定集市秒拍挂panel
    self:bindMarketCheater()

    -- 设置金钱
    self:setCashView()


    -- 设置所有hook消息
    self:setAllHookMsgs()

    -- 设置安全锁信息
    self:setSafeLockInfo()

    -- 页面刷新
    self:refreshPageInfo()

    self.needTipForCashList = false
end

function MarketBuyDlg:setSafeLockInfo()
    if SafeLockMgr:isNeedUnLock() then -- 需要解锁
        self:setCtrlVisible("UnlockButton", true)
        self:setCtrlVisible("BuyButton", false)
    else
        self:setCtrlVisible("UnlockButton", false)
        self:setCtrlVisible("BuyButton", true)
    end
end

function MarketBuyDlg:onUnlockButton()
    SafeLockMgr:cmdOpenSafeLockDlg("SafeLockReleaseDlg")
end

function MarketBuyDlg:onLianxiButton()
    if not self.selectItemData then
        gf:ShowSmallTips(CHS[4100832])
        return
    end

    if not self:isPublicityItem(self.selectItemData) then
        gf:ShowSmallTips(CHS[4100833])  -- 只有需要公示的商品才支持联系卖家。
        return
    end

    if self.selectItemData.unidentified == 1  then -- and self.selectItemData.item_type == ITEM_TYPE.EQUIPMENT    无  item_type
        gf:ShowSmallTips(CHS[4100833])  -- 只有需要公示的商品才支持联系卖家。
        return
    end

    local exchangeType = self.firstClass == CHS[7000306] and MarketMgr.CARD_EXCHANGE.CARD_EXCHANGE_SEARCH or MarketMgr.CARD_EXCHANGE.CARD_EXCHANGE_LIST
    local type = (string.match(self.name, "Glod") or string.match(self.name, "Gold")) and CHS[7002312] or CHS[7002311]
    if exchangeType == MarketMgr.CARD_EXCHANGE.CARD_EXCHANGE_SEARCH then
        MarketMgr:connectSeller(type, self.selectItemData.id, exchangeType, self.name, self.selectItemData.name)
    else
        MarketMgr:connectSeller(type, self.selectItemData.id, string.format("%d|%s|%s", exchangeType, self:getRequestKey(), self:getPageStr()), self.name, self.selectItemData.name)
    end
end


function MarketBuyDlg:MSG_SAFE_LOCK_INFO()
    self:setSafeLockInfo()
end

function MarketBuyDlg:onMoneyPanel()
    gf:showBuyCash()
end

function MarketBuyDlg:bindSecondClassTouchEvent()
    local secondPanel = self:getControl("SecondPanel")
    local bkPanel = self:getControl("BKPanel")
    local listPanel = self:getControl("CategoryPanel")
    local layout = ccui.Layout:create()
    layout:setContentSize(bkPanel:getContentSize())
    layout:setPosition(bkPanel:getPosition())
    layout:setAnchorPoint(bkPanel:getAnchorPoint())

    local closeBtn = self:getControl("CloseButton")
    local  function touch(touch, event)
        local rect = self:getBoundingBoxInWorldSpace(secondPanel)
        local toPos = touch:getLocation()
        local classRect = self:getBoundingBoxInWorldSpace(listPanel)
        local closeRect = self:getBoundingBoxInWorldSpace(closeBtn)
        local bkRect = self:getBoundingBoxInWorldSpace(bkPanel)

        -- 如果点击位置在界面外，返回false，使得点击事件可以传递到blank层
        if not cc.rectContainsPoint(bkRect, toPos) then
            return false
        end

        if  not cc.rectContainsPoint(closeRect, toPos) and not cc.rectContainsPoint(rect, toPos) and not cc.rectContainsPoint(classRect, toPos) and  secondPanel:isVisible() then
            secondPanel:setVisible(false)

            local item = self.leftListCtrl:getChildByName(self.lastFirstClass or CHS[3002964])
            self:addClassSelcelImage(item)
            self.firstClass = self.lastFirstClass or CHS[3002964]

            if not self.secondClass then
                local searchData = MarketMgr:getSearchItemList(self:tradeType())
                if self.firstClass == CHS[7000306] and next(searchData) then
                    -- 如果是鹰眼搜索并且有结果
                    self:setCtrlVisible("NoticePanel2", false)
                else
                    self:setCtrlVisible("NoticePanel2", true)
                end
            else
                self:setCtrlVisible("NoticePanel2", false)
            end


            return false
        end
    end
    self.root:addChild(layout, 10, 1)

    gf:bindTouchListener(layout, touch)
end

function MarketBuyDlg:bindMarketCheater()
    local marketCheaterPanel = self:getControl("MarketCheaterPanel")
    marketCheaterPanel:setTouchEnabled(false)
    local secondPanel = self:getControl("SecondPanel")
    local layout = ccui.Layout:create()
    layout:setContentSize(marketCheaterPanel:getContentSize())
    layout:setPosition(marketCheaterPanel:getPosition())
    layout:setAnchorPoint(marketCheaterPanel:getAnchorPoint())

    local  function touch(touch, event)
        local rect = self:getBoundingBoxInWorldSpace(marketCheaterPanel)
        local toPos = touch:getLocation()

        if cc.rectContainsPoint(rect, toPos) and not secondPanel:isVisible() then
            RecordLogMgr:setMarketCheaterClickTimesData("zone", self.name)
            return false
        end
    end
    self.root:addChild(layout, 10, 1)

    gf:bindTouchListener(layout, touch)
end

function MarketBuyDlg:initClassList()

    -- 一级菜单单元格
    self.classCtrl = self:getControl("BigPanel")
    self.classCtrl:retain()
    self.classCtrl:removeFromParent()

    self.classSelectImg = self:getControl("BChosenEffectImage", Const.UIImage, self.classCtrl)
    self.classSelectImg:setVisible(true)
    self.classSelectImg:retain()
    self.classSelectImg:removeFromParent()

    self.upArrowImage = self:getControl("UpArrowImage", Const.UIImage, self.classCtrl)
    self.upArrowImage:retain()
    self.upArrowImage:removeFromParent()

    -- 二级菜单单元格
    self.secondClassCtrl = self:getControl("ClassItemPanel")
    if self.secondClassCtrl then
        self.secondClassCtrl:retain()
        self.secondClassCtrl:removeFromParent()
    end

    -- 三级菜单单元格
    self.thirdClassCtrl = self:getControl("UnitPanel")
    if self.thirdClassCtrl then
        self.thirdClassCtrl:retain()
        self.thirdClassCtrl:removeFromParent()
    end

    -- 商品列表单元格
    self.itemCellCtrl = self:getControl("ItemPanel")
    self.itemCellCtrl:retain()
    self.itemCellCtrl:removeFromParent()

    self.itemSelectImg = self:getControl("ChosenEffectImage", Const.UIImage, self.itemCellCtrl)
    self.itemSelectImg:retain()
    self.itemSelectImg:removeFromParent()

    self.moneyCellCtrl = self:retainCtrl("MoneyPanel", "SellMoneyPanel")
    self.moneySelectImg = self:retainCtrl("ChosenEffectImage", self.moneyCellCtrl)

    -- 初始化列表控件
    self.leftListCtrl, self.leftListSize = self:resetListView("CategoryListView",0)
    self:bindListViewListener("CategoryListView", self.onClickClassList)

    local firstItemList = self:getFirstItemList()

    for i = 1, #firstItemList do
        local classCell =  self:createClassCell(firstItemList[i])
        classCell:setName(firstItemList[i])
        self.leftListCtrl:pushBackCustomItem(classCell)
    end

    -- 初值选中信息
    self:setInitSelectInfo()
end

function MarketBuyDlg:cleanClassData()
    MarketMgr:MSG_STALL_ITEM_LIST({})
end

function MarketBuyDlg:getDefaultMenu()
    return CHS[3002964]
end

function MarketBuyDlg:setInitSelectInfo()
    local selectData =  MarketMgr:getMarketLastSelectStateData(self.name)

    if selectData and selectData.dlgName == self.name and next(MarketMgr:getStallItemList(self.name)) and selectData.firstClass then

        -- 对应菜单设置
        self:clickClassList(selectData.firstClass)
        if selectData.isFromSearch then
            self:selectItemByClass(selectData.firstClass, selectData.secondClass, selectData.thirdClass, selectData.curPage, selectData.upSort, selectData.sortType)
        else
            self:initSelectOneClassInfo(selectData.firstClass, selectData.secondClass, selectData.thirdClass, selectData.curPage, selectData.upSort, selectData.sortType)
            self:refreshItemList()
        end
        -- 搜索结果，需要隐藏二级panel
        self:setCtrlVisible("SecondPanel", false)
    elseif selectData and selectData.dlgName == self.name and selectData.firstClass == CHS[7000306] then
        self:clickClassList(selectData.firstClass)
        self:selectItemByClass(selectData.firstClass, selectData.secondClass, selectData.thirdClass, selectData.curPage, selectData.upSort, selectData.sortType)
    else
        self:cleanClassData()

        -- 默认选中装备
        local item = self.leftListCtrl:getChildByName(self:getDefaultMenu())
        self:addClassSelcelImage(item)

        self.firstClass = self:getDefaultMenu()
     --   self:initCollectList()

        -- 初值化二级菜单内容
        local name = item:getName()
        self:clickClassList(name)
   end
end

function MarketBuyDlg:getFirstItemList()
    return ITEM_CLASS
end

function MarketBuyDlg:setTradeTypeUI()
    -- 设置商品单元格为货币为金元宝
    self:setCtrlVisible("GoldImage", false, self.itemCellCtrl)
    self:setCtrlVisible("CoinImage", true, self.itemCellCtrl)

    -- 设置玩家身上的金元宝
    local moneyPanel = self:getControl("MoneyPanel")
    self:setCtrlVisible("GoldImage", false, moneyPanel)
    self:setCtrlVisible("MoneyImage", true, moneyPanel)
end

-- 设置所有hook消息
function MarketBuyDlg:setAllHookMsgs()
    self:hookMsg("MSG_STALL_ITEM_LIST")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_STALL_UPDATE_GOODS_INFO")
    self:hookMsg("MSG_MARKET_CHECK_RESULT")
end

-- 初值化收藏列表
function MarketBuyDlg:initCollectList()
    MarketMgr:checkCollectItemStatus(self:tradeType())
    local itemList = self:getCollectItemList()
    local itemsPanel = self:getControl("ItemsPanel")
    if #itemList == 0 then
        self:setCtrlVisible("NoticePanel", true, itemsPanel)
        local scrollview = self:getControl("ItemScrollView")
        scrollview:removeAllChildren()
    else
        self:setCtrlVisible("NoticePanel", false, itemsPanel)
        self.totalPage = math.ceil(#itemList / PAGE_CONTAIN_NUM)
        self.curPage = 1
        self.isFromSearch = true
        self:refreshFormSeachItemList()

    end

    self:refreshPageInfo()
    self:setCtrlVisible("PriceSortButton", false)
    self:setCtrlVisible("ThirdButton", false)
    self:setCtrlVisible("CollectionInfoPanel", true)
end

-- 初始化搜索结果列表
function MarketBuyDlg:initSearchList()
    local itemList = MarketMgr:getSearchItemList(self:tradeType())
    local itemsPanel = self:getControl("ItemsPanel")
    if not itemList or #itemList == 0 then
        self:setCtrlVisible("NoticePanel", true, itemsPanel)
        self.totalPage = 0
        self.curPage = 0
        self.isFromSearch = true
        local scrollview = self:getControl("ItemScrollView")
        scrollview:removeAllChildren()
    else
        self:setCtrlVisible("NoticePanel", false, itemsPanel)
        self.totalPage = math.ceil(#itemList / PAGE_CONTAIN_NUM)
        self.curPage = 1
        self.isFromSearch = true
        self:refreshFormSeachItemList()
    end

    self:refreshPageInfo()
    self:showAndHideButton(false)
    self:setCtrlVisible("PriceSortButton", true)
    self:setCtrlVisible("SearchInfoPanel", true)
end

function MarketBuyDlg:createClassCell(className)
    local cell = self.classCtrl:clone()
    local label = self:getControl("Label", Const.UILabel, cell)
    label:setString(className)
    return cell
end

function MarketBuyDlg:addClassSelcelImage(item)
    self.upArrowImage:removeFromParent()
    item:addChild(self.upArrowImage)
    self.classSelectImg:removeFromParent()
    item:addChild(self.classSelectImg)
end

function MarketBuyDlg:onClickClassList(sender,eventType)
    local item = self:getListViewSelectedItem(sender)
    self:addClassSelcelImage(item)

    -- 隐藏三级列表内容
    --self:setCtrlVisible("ItemsPanel", false)

    -- 初值化二级菜单内容
    local name = item:getName()
    self:clickClassList(name)
end

function MarketBuyDlg:clickClassList(name)
    -- 现在会记忆二级菜单滑动位置，连续点击一级菜单的某一项过程中，每次都会刷新二级菜单，导致画面闪烁
    -- 故如果连续点击一级菜单的某一项，不再重新生成二级菜单界面
    if self.firstClass and self.firstClass == name then
        if self:getCtrlVisible("SecondPanel") == true then
            return
        end
    end

    self:setCtrlVisible("SellMoneyPanel", false)
    self:setCtrlVisible("MoneyPanel2", false)
    self:setCtrlVisible("ItemsPanel", true)
    self:setCtrlVisible("LianxiButton", true)
    self:setCtrlVisible("RefreshButton", false)
    self:setCtrlVisible("SearchInfoPanel", name == CHS[7000306])

        -- 珍宝非金钱，要显示查看按钮
    if MarketMgr:isGoldtype(self:tradeType()) then
        self:setCtrlVisible("ViewButton", name ~= CHS[3002143])
        if name == CHS[3002143] then
            -- 如果是金钱，珍宝要显示解锁、或者购买
            if SafeLockMgr:isNeedUnLock() then -- 需要解锁
                self:setCtrlVisible("UnlockButton", true)
                self:setCtrlVisible("BuyButton", false)
            else
                self:setCtrlVisible("UnlockButton", false)
                self:setCtrlVisible("BuyButton", true)
            end
        end
    end

    self.firstClass = name
    if self.allSellItems[name] and #self.allSellItems[name] >  0 then
        self:setCtrlVisible("SecondPanel", true)
    else
        self:setCtrlVisible("SecondPanel", false)
        if name == CHS[3002963] then
            self:initCollectList()
            self:cancleSelectItem()
            self:swichCancelAndCollectBtn(true)
            return
        elseif name == CHS[7000306] then
            self:initSearchList()
            self:cancleSelectItem()
            self.secondClass = nil
            self.thirdClass = nil
            self.lastFirstClass = self.firstClass
            self:swichCancelAndCollectBtn(true)
            return
        elseif name == CHS[3002143] then
            -- 金钱
            self:setCtrlVisible("SellMoneyPanel", true)
            self:setCtrlVisible("MoneyPanel2", true)
            self:setCtrlVisible("ItemsPanel", false)

            self:setCtrlVisible("LianxiButton", false)
            self:setCtrlVisible("RefreshButton", true)

            self:setCtrlVisible("ThirdButton", false)
            self:setCtrlVisible("PriceSortButton", false)
            self:setCtrlVisible("SortPanel", false)
            self:setCtrlVisible("ThirdPanel", false)

            self:cancleSelectItem()
            if not MarketMgr:getIsCanSellCash() or not MarketMgr:tryGetCurSellCashList() then
                -- 请求失败，直接使用客户端缓存的旧数据显示
                self:MSG_GOLD_STALL_CASH_GOODS_LIST()
            end
            return
        end
    end

    local classListPanel = self:getControl("ClassListPanel")
    if classListPanel then
        classListPanel:removeAllChildren()

        -- 由于当前集市配置和珍宝同一份，后来黄伟相惊天要求，有些东西珍宝显示，集市不显示！so... 数据要转化下，排除不需要显示的
        local data = MarketMgr:eliminateData(self.allSellItems[name], self:tradeType())
        self:initListPanel(data, self.secondClassCtrl, self.initSecondClassCell, classListPanel)
    end

    -- 初值化三级菜单的默认标签
    self:setCtrlVisible("ThirdPanel", false)
    self:setCtrlVisible("SortPanel", false)
end

-- 初值列表数据
function MarketBuyDlg:initListPanel(data, cellColne, func, panel, needScrollCallFuc)
    panel:removeAllChildren()
    local colunm = CONST_DATA.Colunm
    if func == self.setMoneyItemData then
        -- 金钱商品只有一列
        colunm = 1
    end

    local contentLayer = ccui.Layout:create()
    local line = math.floor(#data / colunm)
    local left = #data % colunm

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0
    local totalHeight = line * cellColne:getContentSize().height

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

    scroview:setName("ScoreView")

    if totalHeight < scroview:getContentSize().height then
        contentLayer:setPositionY(scroview:getContentSize().height  - totalHeight)
    end

    -- 需要记录一下二级列表的scrollview，同时将scrollView滑动到之前上一次滑动的位置（仅在连续的两次同一二级列表操作有效）
    if panel == self:getControl("ClassListPanel") then
        self.secondClassScrollView = scroview
        performWithDelay(scroview, function()
            local container = scroview:getInnerContainer()
            local posY = MarketMgr:getSecondClassScrollPosition(self.firstClass)
            local height = container:getContentSize().height - scroview:getContentSize().height
            if posY and height > 0 then
                local percent = (height + posY) / height * 100
                if percent == 0 then
                    scroview:scrollToTop(0)
                else
                    scroview:scrollToPercentVertical(percent, 0, false)
                end
            end
        end, 0)
    end


    -- 滚动监听
    local isChangePage = false
    local isCanScroll = true
    if needScrollCallFuc then
        local  function scrollListener(sender , eventType)
            if eventType == ccui.ScrollviewEventType.scrolling then
                local offset = - 8
                local  y = scroview:getInnerContainer():getPositionY()
                if not isChangePage  then
                    if y + SCROLL_MARGIN < offset  then
                        isChangePage= self:onLeftButton()


                    elseif y > SCROLL_MARGIN and isCanScroll then
                        isChangePage= self:onRightButton()
                        isCanScroll = false
                    end
                end

                if y < SCROLL_MARGIN / 2 then
                    isCanScroll = true
                end

            end
        end

        scroview:addEventListener(scrollListener)

    end

    panel:addChild(scroview)
end

function MarketBuyDlg:initSecondClassCell(cell, data)
    local nameLabel = self:getControl("OneNameLabel", Const.UILabel, cell)
    nameLabel:setString(data.name)
    local tag = cell:getTag()

    local sellItemList = MarketMgr:eliminateData(self.allSellItems[self.firstClass], self:tradeType())
    local itemList = MarketMgr:getThirdClassList(sellItemList[tag]["list"], self:tradeType())

    local thirdButton = self:getControl("ThirdButton")
    local thirdPanel = self:getControl("ThirdPanel")
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if itemList then
                --thirdButton:setVisible(true)
                self:showAndHideButton(true)
                self:bindTouchEndEventListener(thirdButton, self.onThirdButton, itemList)

                -- 设置三级菜单默认值
                local label = self:getControl("Label1", nil, thirdButton)
                if type(itemList[1]) == "number" then
                    -- 数字表示等级
                    self.thirdClass = self:getThirdClassLevel(itemList[1])

                    local str = MarketMgr:getThirdClassStr(self.thirdClass, self.firstClass)
                    label:setString(str)

                elseif data.name == CHS[7000044] or data.name == CHS[7000045] then
                    -- 经验心得/道武心得特殊处理
                    local str = MarketMgr:getLastSelectLevel(self.firstClass, data.name)
                    if not str then
                        str = MarketMgr:getXindeLVByLevel(nil, data.name)
                    end

                    self.thirdClass = str
                    label:setString(str)

                else
                    local thirdClass = MarketMgr:getLastSelectThirdClass(self.firstClass, data.name, itemList[1])
                    label:setString(thirdClass)

                    self.thirdClass = thirdClass
                end
            else
                self.thirdClass = nil
                self:showAndHideButton(false)
                --thirdButton:setVisible(false)
            end

            -- 记录一下当前二级列表滑动位置
            if self.secondClassScrollView then
                local y = self.secondClassScrollView:getInnerContainer():getPositionY()
                MarketMgr:setSecondClassScrollPosition(self.firstClass, y)
            end

            thirdPanel:setVisible(false)
            self:setCtrlVisible("SecondPanel", false)
            self:setCtrlVisible("CollectionInfoPanel", false)
            self:setCtrlVisible("SearchInfoPanel", false)
            self:setCtrlVisible("NoticePanel2", false)
            self.secondClass = data.name

            if self:selectItemIsPubilc() then -- 公示
                self.upSort, self.sortType = MarketMgr:getLastSort()
            else
                -- 重置为升序状态
                self.upSort  = true
                self.sortType = "price"
            end

            self.curPage = 1
            self:refreshUpDownImage()

            -- 发送物品请求
            self.isFromSearch = false
            self:requireItemList()

            -- 设置选中一级列表
            self.lastFirstClass = self.firstClass
            MarketMgr:setLastSelectClass(self.firstClass, self.secondClass, self.thirdClass)

            -- 清除之前的数据
            local scrollview = self:getControl("ItemScrollView")
            scrollview:removeAllChildren()
            self.totalPage = 0
            self.curPage = 0
            self:refreshPageInfo()
        end
    end

    -- 头像
    if data.isPlist then
        self:setImagePlist("IconImage", data.icon, cell)
    else
        if not data.isPortraits then
            if DistMgr:curIsTestDist() and data.testIcon then
                self:setImage("IconImage", ResMgr:getItemIconPath(data.testIcon), cell)
            else
                self:setImage("IconImage", ResMgr:getItemIconPath(data.icon), cell)
            end
                self:setItemImageSize("IconImage", cell)
        else
                self:setImage("IconImage", ResMgr:getSmallPortrait(data.icon), cell)
                self:setItemImageSize("IconImage", cell)
        end
    end
    cell:addTouchEventListener(listener)
end


-- 显示和隐藏价格按钮和三级列表按钮
function MarketBuyDlg:showAndHideButton(haveThirdClass)
    local thirdButton = self:getControl("ThirdButton")
    local priceSortBtn = self:getControl("PriceSortButton")
    local sortPanel = self:getControl("SortPanel")
    sortPanel:setAnchorPoint(0.5, 0)
    if haveThirdClass then
        thirdButton:setVisible(true)
        priceSortBtn:setPositionX(self.posxTable[2])
        sortPanel:setPositionX(self.posxTable[2])
    else
        thirdButton:setVisible(false)
        priceSortBtn:setPositionX(self.posxTable[1])
        sortPanel:setPositionX(self.posxTable[1])
    end

    if self:selectItemIsPubilc() or self.firstClass == CHS[7000306] then
        priceSortBtn:setVisible(true)
    else
        priceSortBtn:setVisible(false)
    end
end

-- 获取玩家适合等级
function MarketBuyDlg:getThirdClassLevel(minLevel)
    -- 上次有选中
    local lastLevel = MarketMgr:getLastSelectLevel(self.firstClass)
    if lastLevel then
        return lastLevel
    end

    local level = 0
    local meLevel = Me:queryBasicInt("level")
	if self.firstClass == CHS[3002973] then
        level = math.floor(meLevel / 10)
    elseif self.firstClass == CHS[3002975] then
        if meLevel <= 34 then
            level = 20
        elseif meLevel >= 35 and meLevel <= 49 then
            level = 35
        elseif meLevel >= 70 then
             level = 70
        else
            level = math.floor(meLevel / 10) * 10
        end
	else
        level = math.floor(meLevel / 10) * 10
	end

	if level < minLevel then
	   level = minLevel
	end

    return level
end

function MarketBuyDlg:onThirdButton(sender, eventType, data)
    local thirdListView = self:getControl("ThirdCategoryListView")
    local thirdPanel = self:getControl("ThirdPanel")
    if not thirdPanel:isVisible() then
        self:initListPanel(data, self.thirdClassCtrl, self.initTirdClassCell, thirdListView)
        thirdPanel:setVisible(true)
    else
        thirdPanel:setVisible(false)
    end

    self:setCtrlVisible("SortPanel", false)
end

function MarketBuyDlg:initTirdClassCell(cell, data)
    local nameLabel = self:getControl("Label", Const.UILabel, cell)
    local thirdPanel = self:getControl("ThirdPanel")
    local thirdButton = self:getControl("ThirdButton")
   --[[ local str = ""
    if type(data) == "number" then
        str = data .. CHS[3002976]
    else
        str = data
    end]]

    local str = MarketMgr:getThirdClassStr(data, self.firstClass)       -- CHS[3002964] 装备
    nameLabel:setString(str)


    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            thirdPanel:setVisible(false)
            local label = self:getControl("Label1", nil, thirdButton)
            label:setString(str)

            if self:selectItemIsPubilc() then -- 公示
                self.upSort, self.sortType = MarketMgr:getLastSort()
            else
                -- 重置为升序状态
                self.upSort  = true
                self.sortType = "price"
            end

            self.curPage = 1
            self:refreshUpDownImage()

            -- 发送物品请求
            self.thirdClass = data
            self:requireItemList()

            -- 设置上次的等级
            MarketMgr:setLastSelectLevel(self.firstClass, data, self.secondClass)

            -- 记录上一次选择的一级、二级、三级分类
            MarketMgr:setLastSelectClass(self.firstClass, self.secondClass, data)

            -- 清除数据
            self.totalPage = 0
            self.curPage = 0
            self:refreshPageInfo()
            self:showAndHideButton(true)
        end
    end

    cell:addTouchEventListener(listener)

end

-- 刷新商品列表
function MarketBuyDlg:refreshItemList()
    self:cancleSelectItem()
    self:swichCancelAndCollectBtn(true)
    self.isFromSearch = false
    local itemList = {}
    local requireInfo = MarketMgr:getStallItemList(self.name)

    local itemList = requireInfo["itemList"] or {}
    self.curPage = requireInfo["cur_page"] or 0
    self.totalPage = requireInfo["totalPage"] or 0

    local scrollview = self:getControl("ItemScrollView")
    scrollview:removeAllChildren()
    local itemsPanel = self:getControl("ItemsPanel")
    if #itemList == 0 then
        self:setCtrlVisible("NoticePanel", true, itemsPanel)
        self:refreshPageInfo()
        return
    else
        self:setCtrlVisible("NoticePanel", false, itemsPanel)
        self:setCtrlVisible("NoticePanel2", false, itemsPanel)
    end

    self:initListPanel(itemList, self.itemCellCtrl, self.setItemData, scrollview, true)

    self:refreshPageInfo()
end


-- 刷新从搜索返回的物品
function MarketBuyDlg:refreshFormSeachItemList()
    self:cancleSelectItem()
    self:swichCancelAndCollectBtn(true)
    self.isFromSearch = true
    local itemList = {}

    local allitemList= {}
    if self.firstClass == CHS[3002963] then
        allitemList =  self:getCollectItemList()
    elseif self.firstClass == CHS[7000306] then
        -- 如果是搜索结果，由客户端进行排序（根据价格/上架时间）
        if self.sortType == "start_time" then
            allitemList = MarketMgr:getSearchItemListByTime(self.upSort, self:tradeType())
        elseif self.sortType == "price" then
            if self.upSort then
                allitemList = MarketMgr:getSearchItemList(self:tradeType())
            else
                allitemList = MarketMgr:getDownSearchList(self:tradeType())
            end
        end
    else
        if self.upSort then
            allitemList = MarketMgr:getSearchItemList(self:tradeType())
        else
            allitemList =  MarketMgr:getDownSearchList(self:tradeType())
        end
    end

    if not allitemList then return end
    self.totalPage = math.ceil(#allitemList / PAGE_CONTAIN_NUM)

    if self.curPage > self.totalPage then
        self.curPage = self.totalPage
    end


    local left = 8
    if self.curPage == self.totalPage then
        left = #allitemList  % 8
        if left == 0 then
            left = 8
        end
    end

    local startIndex = (self.curPage - 1) * 8

    for i = startIndex + 1,startIndex + left do
        table.insert(itemList, allitemList[i])
    end

    local scrollview = self:getControl("ItemScrollView")
    scrollview:removeAllChildren()

    local itemsPanel = self:getControl("ItemsPanel")
    if #itemList == 0 then
        self:setCtrlVisible("NoticePanel", true, itemsPanel)
        self:refreshPageInfo()
        return
    else
        self:setCtrlVisible("NoticePanel", false, itemsPanel)
        self:setCtrlVisible("NoticePanel2", false, itemsPanel)
    end

    self:initListPanel(itemList, self.itemCellCtrl, self.setItemData, scrollview, true)

    self:refreshPageInfo()
end

function MarketBuyDlg:addItemSelcelImage(item, selectImg)

    selectImg:removeFromParent()
    item:addChild(selectImg)

    if MarketMgr:isCollectedInAll(self.selectItemData.id, self:tradeType()) then
        self:swichCancelAndCollectBtn(false)
    else
        self:swichCancelAndCollectBtn(true)
    end
end

function MarketBuyDlg:swichCancelAndCollectBtn(isShowCollect)
    if isShowCollect then
        self:setCtrlVisible("CollectionButton", true)
        self:setCtrlVisible("CancelCollectionButton", false)
    else
        self:setCtrlVisible("CollectionButton", false)
        self:setCtrlVisible("CancelCollectionButton", true)
    end
end

-- 发送请求物品的指令
function MarketBuyDlg:requireItemList()
    if not self.firstClass or not self.secondClass or not self.curPage then return end

    local key = self:getRequestKey()

    local page_str = self:getPageStr()

    if key and page_str then
        MarketMgr:requestBuyItem(key, page_str, self:tradeType())
    end
end

function MarketBuyDlg:getRequestKey()
    if not self.firstClass or not self.secondClass then return end

    local key = self.firstClass.."_".. self.secondClass

    -- 3级
    if self.thirdClass then
        key = key.."_"..self.thirdClass
    else
        -- 时装的 thirdClass特殊
        if InventoryMgr:getRecourseItem() and InventoryMgr:getRecourseItem().fasion_type == FASION_TYPE.FASION then
            local days = string.match(InventoryMgr:getRecourseItem().alias, CHS[5410270]) or CHS[4300359]
            local suffix = days .. CHS[4100655]
            key = key.."_"..suffix
        end
    end


    return key
end

function MarketBuyDlg:getPageStr()
    if not self.curPage then  return end

    local page_str = ""

    if self.curPage < 1 then
        self.curPage = 1
    end

    if self.upSort then
        page_str = string.format("%d;%d;%d;%s", self.curPage, MARKET_STATUS.STALL_GS_SELLING, 1, self.sortType or "price")
    else
        page_str = string.format("%d;%d;%d;%s", self.curPage, MARKET_STATUS.STALL_GS_SELLING, 2, self.sortType or "price")
    end

    return page_str
end

-- 刷新页面信息
function MarketBuyDlg:refreshPageInfo()
    local pageText
    if self.totalPage == 0 then
         pageText = string.format("%d/%d", 0, self.totalPage)
    else
         pageText = string.format("%d/%d", self.curPage, self.totalPage)
    end

    self:setNumImgForPanel("PageInfoPanel", ART_FONT_COLOR.DEFAULT, pageText, false, LOCATE_POSITION.MID, 23)
end

-- 数字键盘插入数字
function MarketBuyDlg:insertNumber(num)
    local inputPage = num
    if num > self.totalPage then
        inputPage = self.totalPage
        gf:ShowSmallTips(CHS[6200045])
    elseif num < 1 then
        inputPage = 1
        gf:ShowSmallTips(CHS[6200046])
    end

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(inputPage)
    end

    if self.curPage == inputPage then return end

    self.curPage = inputPage
    self:refreshPageInfo()

    if self.isFromSearch then
        self:refreshFormSeachItemList()
    else
        self:requireItemList()
    end
end

function MarketBuyDlg:inputLimit()
    if not self.totalPage or  self.totalPage <= 3 then
        gf:ShowSmallTips(CHS[6200047])
        return true
    end
end

function MarketBuyDlg:setItemData(cell, data)

    cell:setName(data.id)

    local imgPath
    local isPet = false
    if PetMgr:getPetIcon(data.name) then
        imgPath =   ResMgr:getSmallPortrait(PetMgr:getPetIcon(data.name))
        data.name = PetMgr:getShowNameByRawName(data.name)
        local petShowName = MarketMgr:getPetShowName(data)
        data.petShowName = petShowName
        isPet = true
    else
        local icon = InventoryMgr:getIconByName(data.name)
        imgPath = ResMgr:getItemIconPath(icon)
    end

    local goodsImage = self:getControl("IconImage", Const.UIImage, cell)
    goodsImage:loadTexture(imgPath)
    self:setItemImageSize("IconImage", cell)
    goodsImage:setVisible(true)

    local iconPanel = self:getControl("IconPanel", nil, cell)
    if  data.level ~= 0 then
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21)
    end

    -- 设置数量
    if data.amount and data.amount > 1 then
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, data.amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 19)
    end

    if data.req_level and data.req_level > 0 then
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, data.req_level, false, LOCATE_POSITION.LEFT_TOP, 19)
    end

    -- 法宝相性
    if data.item_polar then
        InventoryMgr:addArtifactPolarImage(goodsImage, data.item_polar)
    end

    -- 带属性超级黑水晶
    if string.match(data.name, CHS[3002980]) then
        local name = string.gsub(data.name,CHS[3002981],"")
        local list = gf:split(name, "|")
        self:setLabelText("NameLabel", list[1], cell)
        local field = EquipmentMgr:getAttribChsOrEng(list[1])
        local str = field .. "_" .. Const.FIELDS_EXTRA1
        local value = 0
        local maxValue = 0
        local bai = ""
        if list[2] then
            value =  tonumber(list[2])
            local equip = {req_level = data.level, equip_type = list[3]}
            maxValue = EquipmentMgr:getAttribMaxValueByField(equip, field) or ""
            if EquipmentMgr:getAttribsTabByName(CHS[3002982])[field] then bai = "%" end
        end

        self:setLabelText("NameLabel2", value .. bai .. "/" .. maxValue .. bai, cell)

        self:setCtrlVisible("NameLabel", true, cell)
        self:setCtrlVisible("NameLabel2", true, cell)
        self:setCtrlVisible("OneNameLabel", false, cell)
    else

        -- 名字
        self:setLabelText("OneNameLabel", data.petShowName or data.name, cell)
        self:setCtrlVisible("NameLabel", false, cell)
        self:setCtrlVisible("NameLabel2", false, cell)
    end


        -- 金钱
    local price = data.price
    local sell_buy_type = data.sell_type
    if (sell_buy_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_SELL or sell_buy_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_BUY) and data.appointee_name ~= Me:queryBasic("name") then
        -- 指定交易，指定对象不是我，显示一口价
         price = data.buyout_price
    elseif (sell_buy_type == ZHENBAO_TRADE_TYPE.STALL_SBT_AUCTION or sell_buy_type == ZHENBAO_TRADE_TYPE.STALL_SBT_AUCTION_BUY) then
        -- 拍卖显示当前价格
        price = data.buyout_price
    end



    local str, color = gf:getMoneyDesc(price, true)
    local coinLabel = self:getControl("CoinLabel", nil, cell)
    coinLabel:setColor(color)
    coinLabel:setString(str)
    self:setLabelText("CoinLabel2", str, cell)

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self.selectItemData = data
            self.selectItemCell = cell
            self:addItemSelcelImage(cell, self.itemSelectImg)
        end
    end

    local function onClick()
        self.selectItemData = data
        self.selectItemCell = cell
        self:addItemSelcelImage(cell, self.itemSelectImg)
    end

    local function onLongClick()
        self.selectItemData = data
        self.selectItemCell = cell
        self:addItemSelcelImage(cell, self.itemSelectImg)

        if not MarketMgr:isGoldtype(self:tradeType()) then
            BlogMgr:showButtonList(self, cell, "TipOffMarket", self.name)
        end
    end

    self:blindLongPressWithCtrl(cell, onLongClick, onClick)
    --cell:addTouchEventListener(listener)


    local iconPanel = self:getControl("IconPanel", nil, cell)
    local function showFloatPanel(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self.selectItemData = data
            self.selectItemCell = cell
            self:addItemSelcelImage(cell, self.itemSelectImg)

            if MarketMgr:isGoldtype(self:tradeType()) then
                if self.onViewButton then
                    self:onViewButton()
                end
            else
                local rect = self:getBoundingBoxInWorldSpace(iconPanel)
                MarketMgr:requireMarketGoodCard(data.id.."|"..data.endTime, MARKET_CARD_TYPE.FLOAT_DLG,
                    rect, isPet, true, self:tradeType())
            end


        end
    end

    iconPanel:addTouchEventListener(showFloatPanel)

    if data.status == 4 then
        self:setCtrlVisible("TipImage", true, cell)
    end

    -- 收藏标签
    if MarketMgr:isCollectedInAll(data.id, self:tradeType()) then
        self:setCtrlVisible("CollectionImage", true, cell)
    else
        self:setCtrlVisible("CollectionImage", false, cell)
    end


   -- cell:setTag(data.id)
   MarketMgr:setSellBuyTypeFlag(data.sell_type, self, cell)

    -- 未鉴定
    if  data.unidentified == 1 then
        InventoryMgr:addLogoUnidentified(goodsImage)
    end

    -- 默认选中
    if self.defaultSelectGid == data.id then
        listener(nil, ccui.TouchEventType.ended)
        if self.defaultCol then
            self:defaultCol()
        end
        self.defaultSelectGid = nil

        self:defaultSelectCallBack()
    end
end

function MarketBuyDlg:defaultSelectCallBack()
    if self.isOpenPay then
        self:onViewButton()
        self.isOpenPay = false
    end
end

function MarketBuyDlg:selectItemByClass(firstClass, sendcondClass, thirdClass, page, upSort, sortType)
    self:initSelectOneClassInfo(firstClass, sendcondClass, thirdClass, page, upSort, sortType)
    self.isFromSearch = true
    self:refreshFormSeachItemList()
end

function MarketBuyDlg:initSelectOneClassInfo(firstClass, sendcondClass, thirdClass, page, upSort, sortType)
    local thirdButton = self:getControl("ThirdButton")
    local thirdPanel = self:getControl("ThirdPanel")
    self.firstClass = firstClass

    if thirdClass then
        -- 设置三级菜单默认值
        local label = self:getControl("Label1", nil, thirdButton)
       --[[ if type(thirdClass) == "number" then
            -- 数字表示等级
            label:setString(thirdClass..CHS[3002976])
        else
            label:setString(thirdClass)
        end]]

        local str = MarketMgr:getThirdClassStr(thirdClass, firstClass)
        label:setString(str)

        self:showAndHideButton(true)
        --thirdButton:setVisible(true)

        local tag = 1
        for i = 1, #self.allSellItems[firstClass] do
            if self.allSellItems[firstClass][i]["name"] == sendcondClass then
                tag = i
            end
        end

        local itemList = MarketMgr:getThirdClassList(self.allSellItems[firstClass][tag]["list"], self:tradeType())
        if itemList then
            self:bindTouchEndEventListener(thirdButton, self.onThirdButton, itemList)
        end

    else
        self:showAndHideButton(false)
    end

    thirdPanel:setVisible(false)
    self:setCtrlVisible("CollectionInfoPanel", false)
    self:setCtrlVisible("SearchInfoPanel", firstClass == CHS[7000306])

    self.lastFirstClass = firstClass
    self.secondClass = sendcondClass
    self.thirdClass = thirdClass
    self.curPage = page or 1
    if upSort == nil then
    -- 为nil值时，用当前的排序
    else
        -- 非nil值，设置排序
        self.upSort = upSort
    end

    if sortType == nil then
    -- 为nil值时，用当前的排序
    else
        -- 非nil值，设置排序
        self.sortType = sortType
    end

    self:refreshUpDownImage()
    MarketMgr:setLastSort(self.upSort, self.sortType)

    local item = self.leftListCtrl:getChildByName(firstClass)
    self:addClassSelcelImage(item)
end

function MarketBuyDlg:ShowPageByClass(firstClass, sendcondClass, thirdClass, notRequest)
    self:initSelectOneClassInfo(firstClass, sendcondClass, thirdClass)
    -- 默认为升序
   -- self.upSort  = true
    self:refreshUpDownImage()

    self.isFromSearch = false

    if self.firstClass ~= CHS[3002963] and self.firstClass ~= CHS[7000306] and not notRequest then
        self:requireItemList()
    end
end

-- 设置金钱
function MarketBuyDlg:setCashView()
    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23)
end


function MarketBuyDlg:onLeftButton(sender, eventType)

    if self.curPage >= 0 then
        performWithDelay(self.root, function()
    if self.curPage > 1 then
        self.curPage = self.curPage - 1
            end

            if self.isFromSearch then
                self:refreshFormSeachItemList()
            else
                self:requireItemList()
            end
         end, 0)

        return true
    end

    return false
end

function MarketBuyDlg:onRightButton(sender, eventType)

    if self:selectItemIsPubilc() or self.firstClass == CHS[7000306] then
       -- if self.curPage <= self.totalPage then
            performWithDelay(self.root, function()
            self.curPage = self.curPage + 1
                if self.isFromSearch then
                    self:refreshFormSeachItemList()
                else
                    self:requireItemList()
                end
                end, 0)

            return true
        --end
    else
       --[[ if self.curPage > self:getUnPublicCanFreshPage() then
            gf:ShowSmallTips(CHS[3002983])

        else]]
        self.curPage = self.curPage + 1
        performWithDelay(self.root, function()
            if self.isFromSearch then
                self:refreshFormSeachItemList()
            else
                self:requireItemList()
            end
        end, 0)

        return true
        --end

    end

    return false
end

function MarketBuyDlg:getUnPublicCanFreshPage()
    return  math.min(math.max(math.floor(self.totalPage / 2), 3), self.totalPage) - 1
end

function MarketBuyDlg:selectItemIsPubilc()

    if PUBLIC_ITEM_CLASS[self.firstClass] then
        return true
    end
   --[[ if self.thirdClass then
        if  MarketMgr:isPublicityItem(self.thirdClass) then
            return true
        end
    elseif self.secondClass then
        if  MarketMgr:isPublicityItem(self.secondClass) then
            return true
        end
    end]]

    return false
end


function MarketBuyDlg:onSearchButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if Me:getVipType() == 0 and not GMMgr:isGM() then
        gf:ShowSmallTips(CHS[3002984])
        return
    end

    self:openSearchDlg()
end

function MarketBuyDlg:openSearchDlg()
    DlgMgr:openDlg("MarketSearchDlg")
end


function MarketBuyDlg:onDlgOpened(param)
    if nil == param[1] then
        return
    end
    
    if param[2] and not MarketMgr:isPublicityItem(param[2]) then
        self.upSort = 1
        self.sortType = "price"
    end

    if string.match(param[1], "ItemName=(.+)") then
        local itemName = string.match(param[1], "ItemName=(.+)")
        param = {}
        local info = MarketMgr:getSellItemInfo(itemName)
        param[1] = info.subClass
        param[2] = itemName
    end


    if not param[2] then -- 只是选中一级列表
        local item = self.leftListCtrl:getChildByName(param[1])
        self:addClassSelcelImage(item)
        self:clickClassList(param[1])
    else
    	self:setCtrlVisible("SecondPanel", false)

        if param[2] == CHS[4100655] and not param[3] then
            -- 时装的 thirdClass特殊
            if InventoryMgr:getRecourseItem() and InventoryMgr:getRecourseItem().fasion_type == FASION_TYPE.FASION then
                local days = tonumber(string.match(InventoryMgr:getRecourseItem().alias, CHS[4100656]))
                if days then
                    if days <= 30 then
                        days = 30
                    else
                        days = 90
                    end

                    param[3] = days .. CHS[4100658]
                else
                    -- 永久
                    param[3] = CHS[5410269]
                end
            end
    	end

        if param[3] == "" then
            -- 三级标签可能不存在
            param[3] = nil

        end

        -- param[4] 为选中指定的道具 gid，目前该逻辑为先刷数据后打开界面，所以打开界面后不用再请求数据
        local notRequest
        if param[4] then
            self.defaultSelectGid = param[4]
            notRequest = true
        end

        if param[2] == CHS[4100075] then
            -- WDSY-29466
            self:clickClassList(param[1])
        end

        MarketMgr:setLastSelectLevel(param[1], tonumber(param[3]))
        self:ShowPageByClass(param[1], param[2], param[3], notRequest)
    end


    -- 清除数据
    self.totalPage = 0
    self.curPage = 0
    self:refreshPageInfo()

    InventoryMgr:setRecourseItem()

    local firstClassItem = self.leftListCtrl:getChildByName(param[1])
    if firstClassItem then
        performWithDelay(self.root, function ()
            local index = self.leftListCtrl:getIndex(firstClassItem)
            local container = self.leftListCtrl:getInnerContainer()
            local innerSize = container:getContentSize()
            local listViewSize = self.leftListCtrl:getContentSize()

            -- 计算滚动的百分比
            local totalHeight = listViewSize.height - innerSize.height
            local distance =  self.classCtrl:getContentSize().height * index
            local posy = distance + totalHeight
            if posy > 0 then posy = 0 end
            container:setPositionY(posy)
        end, 0)
    end
end

function MarketBuyDlg:close(now)
    Dialog.close(self, now)

    if nil ~= self.bigCtrl then
        self.bigCtrl:release()
        self.bigCtrl = nil
    end

    if nil ~= self.smallCtrl then
        self.smallCtrl:release()
        self.smallCtrl = nil
    end

    if nil ~= self.selectImg then
        self.selectImg:release()
        self.selectImg = nil
    end

    MarketBuyDlg.itemsListCtrls = {}
    MarketBuyDlg.leftListData = {}
    MarketMgr:setBuyStateNormal()
end

function MarketBuyDlg:getSelectImg()
    if nil == self.selectImg then
        -- 创建选择框
        local img = self:getControl("ChosenEffectImage", Const.UIImage)
        img:retain()
        img:setVisible(true)
        img:setPosition(0, 0)
        img:setAnchorPoint(0, 0)
        self.selectImg = img
    end

    self.selectImg:removeFromParent()

    return self.selectImg
end

function MarketBuyDlg:getBSelectImg()
    if nil == self.selectBImg then
        -- 创建选择框
        local img = self:getControl("BChosenEffectImage", Const.UIImage)
        img:retain()
        img:setVisible(true)
        img:setPosition(0, 0)
        img:setAnchorPoint(0, 0)
        self.selectBImg = img
    end

    self.selectBImg:removeFromParent()

    return self.selectBImg
end

function MarketBuyDlg:getSSelectImg()
    if nil == self.selectSImg then
        -- 创建选择框
        local img = self:getControl("SChosenEffectImage", Const.UIImage)
        img:retain()
        img:setVisible(true)
        img:setPosition(0, 0)
        img:setAnchorPoint(0, 0)
        self.selectSImg = img
    end

    self.selectSImg:removeFromParent()

    return self.selectSImg
end

-- 初始化界面控件
function MarketBuyDlg:initView()
    -- 初始化左侧列表
    self:initLeftView()

    -- 初始化右侧显示列表
    self:initRightView()

    -- 初始化整个界面数据
    self:initWholeView()
end

-- 初始化左侧列表
function MarketBuyDlg:initLeftView()
    -- 获取
    MarketBuyDlg.leftListData = require("cfg/MarketClasses")

    -- 获取一级控件
    self.bigCtrl = self:getControl("BigPanel")
    self.bigCtrl:retain()

    -- 获取二级控件
    self.smallCtrl = self:getControl("SPanel")
    self.smallCtrl:retain()

    -- 获取列表控件
    self.searchCtrl = self:getControl("SearchMatchUnitPanel")
    self.searchCtrl:retain()


    -- 初始化列表控件
    self.leftListCtrl, self.leftListSize = self:resetListView("CategoryListView", STATIC.margin)
    self.searchListCtrl, self.searchListSize = self:resetListView("SearchMatchListView", STATIC.margin)

    --[[
    zhengjh 测试要求
    self.searchEdit = self:createEditBox("NameInputPanel", nil, nil, function(sender, type)
        if type = "began" then
            self:resetContinueClick()
        elseif type == "end" then
            local str = self.searchEdit:getText()
            if "" ~= str then
                self:displaySearchList()
            else
                local delCtrl = self:getControl("SearchTextField")
                local restCtrl = self:getControl("ResetButton")
                self:setCtrlVisible("SearchMatchPanel", false)
                restCtrl:setVisible(false)
            end
        elseif type == "changed" then
        end
    end)

    self.newNameEdit:setPlaceholderFont(CHS[3002985], 23)
    self.newNameEdit:setFont(CHS[3002985], 23)
    self.newNameEdit:setPlaceHolder(CHS[3002986])
    self.newNameEdit:setPlaceholderFontColor(cc.c3b(102, 102, 102))

    --]]

end



-- 初始化右侧显示列表
function MarketBuyDlg:initRightView()
    -- 直接创建整个界面的控件，后面只需替换数据即可

    -- 获取第一个itemPanel进行复制
    local itemCtrl = self:getControl("ItemPanel")
    itemCtrl:retain()
    itemCtrl:removeFromParentAndCleanup(false)
    local itemListCtrl = self:getControl("ItemListPanel")
    itemListCtrl:removeAllChildren()
    local contentSize = itemCtrl:getContentSize()
    local width = contentSize.width
    local height = contentSize.height
    for i = 1, STATIC.row do
        for j = 1, STATIC.col do
            local newItem = itemCtrl:clone()
            newItem:setPosition(width * (j - 1) + STATIC.margin, height * (STATIC.row - i) + STATIC.margin)
            newItem.index = (i - 1) * STATIC.col + j
            newItem:setVisible(false)

            self:bindTouchEndEventListener(newItem, self:getCallBackFunc(function(self, sender, eventType)
                Log:D(">>>>>>Click item : " .. newItem.index)
                self.curSelectItem = sender.item
                self.curSelectIndex = newItem.index
                sender:addChild(self:getSelectImg())
            end))
            itemListCtrl:addChild(newItem)
            table.insert(self.itemsListCtrls, newItem)

            if self.curSelectIndex == i * j then

            end
        end
    end

    itemCtrl:release()

    -- 显示正在获取数据
    self:exchangePanel(VIEW_TYPE.LOAD)
end

-- 切换加载界面和列表
function MarketBuyDlg:exchangePanel(type)
    -- 将所有控件设为不可见
    for i = 1, #VIEW do
        self:setCtrlVisible(VIEW[i], false)
    end

    if VIEW_TYPE.LIST == type then
        self:setCtrlVisible("ItemListPanel", true)
    elseif VIEW_TYPE.NONE == type then
        self:setCtrlVisible("NoticePanel", true)
    elseif VIEW_TYPE.LOAD == type then
        self:setCtrlVisible("WaitingPanel", true)
    end
end

-- 初始化整体界面
function MarketBuyDlg:initWholeView()
    self:setLabelText("PageLabel", "0/0")
    self:setLabelText("CoinLabel", "0")
end

-- 更新界面数据
function MarketBuyDlg:updateViewData()
    -- 更新左侧列表数据
    self:updateLeftViewData()

    -- 更新右侧具体物品数据
    self:updateRightViewData()

    -- 更新整体界面数据
    self:updateWholeViewData()
end

-- 更新左侧列表数据
function MarketBuyDlg:updateLeftViewData()
    if nil == MarketBuyDlg.leftListData then
        return
    end

    local isFirst = true
    for i = 1, #ONE_KEY do
        local value = MarketBuyDlg.leftListData[ONE_KEY[i]]
        local k = ONE_KEY[i]

        -- key 为一级菜单
        local newOne = self.bigCtrl:clone()
        self:setLabelText("Label", k, newOne)
        newOne.isExpand = false
        newOne.value = value
        newOne.key = k

        if isFirst then
            self.firstOneCtrl = newOne
            isFirst = false
        end

        self:bindTouchEndEventListener(newOne, self:getCallBackFunc(MarketBuyDlg.oneClick))
        self.leftListCtrl:pushBackCustomItem(newOne)
        table.insert(leftSelectCtrls, newOne)
    end

end


-- 更新右侧具体物品数据
function MarketBuyDlg:updateRightViewData()
    if nil == self.curSelectName then return end

    local items = MarketMgr:getPageDataByType(self.curSelectName)

    self:setRightViewData(items)
end

-- 根据数据设置右边面板
function MarketBuyDlg:setRightViewData(items)
    self:exchangePanel(VIEW_TYPE.LIST)
    for i = 1, #MarketBuyDlg.itemsListCtrls do
        local itemCtrl = MarketBuyDlg.itemsListCtrls[i]
        gf:resetImageView(itemCtrl)

        if i > #items then
            itemCtrl:setVisible(false)
        else
            itemCtrl.item = items[i]

            local iconPanel = self:getControl("IconPanel", nil, itemCtrl)

            -- 设置名字
            self:setLabelText("NameLabel", items[i].name, itemCtrl)

            -- 设置价格
            local label = self:getControl("CoinLabel", Const.UILabel, itemCtrl)
            local cashText, cashColor = gf:getMoneyDesc(items[i].price, true)
            label:setString(cashText)
            label:setColor(cashColor)

            local iconPath = ResMgr:getItemIconPath(items[i].icon)
            self:setImage("IconImage", iconPath, itemCtrl)
            self:setItemImageSize("IconImage", itemCtrl)

            -- 设置等级、图标、数量
            if nil == items[i].level or 0 == items[i].level then
                self:removeNumImgForPanel(iconPanel, LOCATE_POSITION.LEFT_TOP)
            else
                self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, items[i].level, false, LOCATE_POSITION.LEFT_TOP, 21)
            end

            if nil == items[i].amount or 1 >= items[i].amount then
                self:removeNumImgForPanel(iconPanel, LOCATE_POSITION.RIGHT_BOTTOM)
            else
                self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, items[i].amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
            end

            if items[i].item_type == ITEM_TYPE.EQUIPMENT and items[i].unidentified == 1 then
                InventoryMgr:addLogoUnidentified(self:getControl("IconImage", nil, itemCtrl))
            end

            -- 设置售罄标志
            local flagImg = self:getControl("SellOutImage", Const.UIImage, itemCtrl)
            if items[i].amount <= 0 then
                flagImg:setVisible(true)
                gf:grayImageView(itemCtrl)
            else
                flagImg:setVisible(false)
            end

            -- 显示item
            itemCtrl:setVisible(true)
            self:bindListener("IconPanel", self:getCallBackFunc(function(self, sender, eventType)
                local dlg = DlgMgr:openDlg("ItemInfoDlg")
                items[i].attrib = nil
                items[i].value = nil
                dlg:setInfoFormCard(items[i])
                local rect = self:getBoundingBoxInWorldSpace(sender)
                dlg:setFloatingFramePos(rect)
            end), itemCtrl)
        end

        itemCtrl:requestDoLayout()
    end

    if 0 == #items then
        self:exchangePanel(VIEW_TYPE.NONE)
    end
end

-- 根据控件id更新数据
function MarketBuyDlg:updateItemById(itemInfo, index)
    local itemCtrl = self.itemsListCtrls[index]
    self:setLabelText("", itemInfo)
end

-- 更新整体界面数据
function MarketBuyDlg:updateWholeViewData()
    -- 设置角色身上的金钱
    local cash = Me:queryBasicInt("cash")

    -- 设置页数
    -- 获取总数
    local curPage, totlePage = MarketMgr:getPageViewInfo(self.curSelectName)
    self:setWholeViewData(cash, curPage, totlePage)
end

function MarketBuyDlg:setWholeViewData(cash, curPage, totlePage)
    self:setCashView(cash)

    -- 设置页数
    -- 获取总数
    local leftButtonCtrl = self:getControl("LeftButton")
    local rightButtonCtrl = self:getControl("RightButton")
    if nil ~= self.curSelectName then
        local pageViewStr = string.format("%d/%d", curPage, totlePage)
        self:setLabelText("PageLabel", pageViewStr)
        if 1 >= curPage then
            gf:grayImageView(leftButtonCtrl)
            leftButtonCtrl:setTouchEnabled(false)
        else
            gf:resetImageView(leftButtonCtrl)
            leftButtonCtrl:setTouchEnabled(true)
        end

        if curPage < totlePage then
            gf:resetImageView(rightButtonCtrl)
            rightButtonCtrl:setTouchEnabled(true)
        else
            gf:grayImageView(rightButtonCtrl)
            rightButtonCtrl:setTouchEnabled(false)
        end
    else
        gf:grayImageView(leftButtonCtrl)
        gf:grayImageView(rightButtonCtrl)
        rightButtonCtrl:setTouchEnabled(false)
        leftButtonCtrl:setTouchEnabled(false)
    end
end



-- 选择左边菜单,不响应菜单回调
function MarketBuyDlg:selectItem(oneItem, twoItem)
    self:operItem(oneItem, twoItem, true, true)
end

-- 选择左边菜单，响应回调
function MarketBuyDlg:selectItemEx(oneItem, twoItem)
    self:operItem(oneItem, twoItem)
end

function MarketBuyDlg:operItem(oneItem, twoItem, one, two)
    local children = self.leftListCtrl:getChildren()

    -- 需要分开响应
    for k, child in pairs(children) do
        local str = child.key
        if oneItem == str then
            self:oneClick(child, nil, one)
        end
    end

    children = self.leftListCtrl:getChildren()

    -- 需要分开响应
    for k, child in pairs(children) do
        local str = child.key
        if twoItem == str then
            self:twoClick(child, nil, two)
        end
    end
end

-- 根据二级菜单获取一级菜单
function MarketBuyDlg:getOneName(twoName)
    for k, v in pairs(self.leftListData) do
        for i = 1, #v do
            if v[i] == twoName then
                return k
            end
        end
    end
end

function MarketBuyDlg:onLongPressBuyButton(sender, eventType)
    local level = Me:getLevel()
    if level < LEVEL_LIMIT then
        gf:ShowSmallTips(string.format(CHS[3002987], LEVEL_LIMIT))
        return
    end

    if nil == self.curSelectItem then
        gf:ShowSmallTips(CHS[3002988])
        return
    end

    if self.curSelectItem.amount > 0 then
        local dlg = DlgMgr:openDlg("MarketBuyItemDlg")
        dlg:setViewData(self.curSelectItem)
    else
        gf:ShowSmallTips(CHS[5000137])
    end
end

function MarketBuyDlg:resetContinueClick(item_unique)
    self.countItem = item_unique
    self.countItemTime = 1

    Log:D(">>>>resetContinueClick")
end

function MarketBuyDlg:onRefreshButton(sender, eventType)
    if self.firstClass == CHS[3002143] then
        if MarketMgr:tryGetCurSellCashList() then
            self.needTipForCashList = true
        else
            self.needTipForCashList = false
        end
    end
end

function MarketBuyDlg:onBuyMoneyGoods()
    self.checkBindItemData = nil

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 实名认证（防沉迷）
    if Me:getAdultStatus() == 2 then
        -- 未完成实名认证
        if LeitingSdkMgr:isOverseas() then
            -- 海外版本
            gf:confirmEx(CHS[4300453], CHS[4300455], function ()
                gf:copyTextToClipboard("gmservice@leiting.com")
                gf:ShowSmallTips(CHS[4300456])
            end, nil, nil, nil, nil, nil, nil, true)
        else
            -- 非海外版本
            gf:confirm(CHS[4300454], function ()
                -- body
            end, nil, nil, nil, nil, nil, true)
        end

        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onBuyMoneyGoods") then
        return
    end

    gf:CmdToServer("CMD_GOLD_STALL_BUY_CASH", {name = self.selectItemData.name, expect_price = self.selectItemData.price})
end

function MarketBuyDlg:onBuyButton(sender, eventType)

    if not DistMgr:checkCrossDist() then return end

    local level = Me:getLevel()
    local minLevel

    -- 珍宝不需要判断基本开放等级
    if MarketMgr:isGoldtype(self:tradeType()) then
    else
        minLevel = 50
        if level < minLevel then
            gf:ShowSmallTips(string.format(CHS[3002990], minLevel))
            return
        end
    end

    if nil == self.selectItemData then
        gf:ShowSmallTips(CHS[3002988])
        return
    end

    if self.selectItemData.isSellMoney then
        self:onBuyMoneyGoods(self.selectItemData)
        return
    end

    if self.selectItemData.is_my_goods == 1 then
        gf:ShowSmallTips(CHS[3002991])
        return;
    end

    local key = self:getRequestKey()
    local page_str = self:getPageStr()
    if (not key or not page_str)
            and self.firstClass ~= CHS[3002963]
            and self.firstClass ~= CHS[7000306] then
        return
    end

    local item =  self.selectItemData
    local function buyItem(amount)

        local price = item.appointee_name and item.appointee_name ~= "" and item.appointee_name ~= Me:queryBasic("name") and item.buyout_price or item.price
        if item.appointee_name and item.appointee_name == Me:queryBasic("name") and item.deposit_state and item.deposit_state == 1 then
            -- 指定交易的对象是自己，并且已经支付了订金，价格需要再减去订金
            price = item.price - MarketMgr:getDepositDingJin(item.price)
        end

        if self.firstClass == CHS[3002963]then
            self:BuyItem(item.id, key, page_str, price, 2, amount or 1)
        elseif self.isFromSearch then
            self:BuyItem(item.id, key, page_str, price, 1, amount or 1)
        else
            self:BuyItem(item.id, key, page_str, price, 0, amount or 1)
        end

        self.isOnBuyButton = true
    end

    local name = item.name
    if string.match(item.name, CHS[3002980]) then
        local list = gf:split(item.name, "|")
        name = list[1]
    end

    if MarketMgr:isGoldtype(self:tradeType()) then
            local price = item.appointee_name and item.appointee_name ~= "" and item.appointee_name ~= Me:queryBasic("name") and item.buyout_price or item.price
            if item.appointee_name and item.appointee_name == Me:queryBasic("name") and item.deposit_state and item.deposit_state == 1 then
                -- 指定交易的对象是自己，并且已经支付了订金，价格需要再减去订金
                price = item.price - MarketMgr:getDepositDingJin(item.price)
            end

        if price > Me:queryBasicInt("gold_coin") then
            gf:askUserWhetherBuyCoin("gold_coin")
            return
        else
            local showMessage = string.format(CHS[4200203], price, name)
            -- 如果购买的是宠物且宠物无法参战时的提示，其他情况为空串
            local tip = MarketMgr:petCannotFightTip(item)
            gf:confirm(showMessage..tip, function()
                buyItem()
            end, nil, nil, nil, nil, true)
        end
    else
        if item.price > Me:queryBasicInt("cash") then
            gf:askUserWhetherBuyCash()
            return
        end

            if MarketMgr:isCanDoubleSellAndBuy(name) then -- 可批量购买
                local dlg = DlgMgr:openDlg("MarketBatchSellItemDlg")
                dlg:setTradeType(MarketMgr.TradeType.marketType)
                item.icon = InventoryMgr:getIconByName(item.name)
                dlg:setItemInfo(item, 5, item.id)
                dlg:setBuyInfo(item.amount, buyItem)
            return
        end

        if self:isPublicityItem(item) or item.price >= NEED_CONFORM_COST then -- 公示物品
            local price = item.appointee_name and item.appointee_name ~= "" and item.appointee_name ~= Me:queryBasic("name") and item.buyout_price or item.price
            local showMessage = string.format(CHS[6400086], gf:getMoneyDesc(price) , name)
            -- 如果购买的是宠物且宠物无法参战时的提示，其他情况为空串
            local tip = MarketMgr:petCannotFightTip(item)
            gf:confirm(showMessage..tip, function()
                buyItem()
            end, nil, nil, nil, nil, true)
            else
            buyItem()
        end
    end
end


function MarketBuyDlg:BuyItem(itemId, key, pageStr, price, type, amount)
    MarketMgr:BuyItem(itemId, key, pageStr, price, type, self:tradeType(), amount or 1)
end

function MarketBuyDlg:onCollectionButton()
    if nil == self.selectItemData then
        gf:ShowSmallTips(CHS[3002992])
        return
    end

    if not MarketMgr:isCanCollect(self:tradeType()) then
        gf:ShowSmallTips(CHS[3002993])
        return
    end

    if not self:isPublicityItem(self.selectItemData) then
        gf:ShowSmallTips(CHS[3002994])
        return
    end

    if self.selectItemData.is_my_goods == 1 then
        gf:ShowSmallTips(CHS[3002991])
        return
    end

    MarketMgr:checkCollectItemStatusByGid(self:tradeType(), self.selectItemData.id)
--[[
    gf:ShowSmallTips(CHS[3002995])
    MarketMgr:addCollectItem(self.selectItemData, self:tradeType())

    self:swichCancelAndCollectBtn(false)
    self:refreshCollectImage(true, self.selectItemCell)
    --]]
end

function MarketBuyDlg:isPublicityItem(item)
    local itemName = MarketMgr:getItemNameForJudgePublicity(item)

    return MarketMgr:isPublicityItem(itemName)
end

function MarketBuyDlg:onCancelCollectionButton()
    gf:ShowSmallTips(CHS[3002996])
    MarketMgr:cancelCollect(self.selectItemData.id, self:tradeType())
    MarketMgr:cancelPublicCollect(self.selectItemData.id, self:tradeType())
    self:swichCancelAndCollectBtn(true)
    self:refreshCollectImage(false, self.selectItemCell)
end

-- 隐藏和显示收藏图标
function MarketBuyDlg:refreshCollectImage(isCollect, cell)
    if not cell then return end

    -- 收藏标签
    if isCollect then
        self:setCtrlVisible("CollectionImage", true, cell)
    else
        self:setCtrlVisible("CollectionImage", false, cell)
    end
end

function MarketBuyDlg:onPriceSortButton()
    local sortPanel = self:getControl("SortPanel")
    if not sortPanel:isVisible() then
        sortPanel:setVisible(true)
    else
        sortPanel:setVisible(false)
    end

    self:setCtrlVisible("ThirdPanel", false)
end

function MarketBuyDlg:onUnitPanel1(sender, eventType)
    self.sortType = "price"
    self.upSort = true
    self.curPage = math.min(self.curPage, 1)
    self:refrshSortButtonInfo()
end

function MarketBuyDlg:onUnitPanel2(sender, eventType)
    self.sortType = "price"
    self.upSort = false
    self.curPage = math.min(self.curPage, 1)
    self:refrshSortButtonInfo()
end

function MarketBuyDlg:onUnitPanel3(sender, eventType)
    self.sortType = "start_time"
    self.upSort = true
    self.curPage = math.min(self.curPage, 1)
    self:refrshSortButtonInfo()
end

function MarketBuyDlg:onUnitPanel4(sender, eventType)
    self.sortType = "start_time"
    self.upSort = false
    self.curPage = math.min(self.curPage, 1)
    self:refrshSortButtonInfo()
end

function MarketBuyDlg:refrshSortButtonInfo()
    self:refreshUpDownImage()
    self.isOnBuyButton = true

    if self.isFromSearch then
        self:refreshFormSeachItemList()
    else
        self:requireItemList()
    end

    MarketMgr:setLastSort(self.upSort, self.sortType)
end

function MarketBuyDlg:refreshUpDownImage()
    local sortBtn = self:getControl("PriceSortButton")
    if self.upSort then
        self:setCtrlVisible("Image1", true, sortBtn)
        self:setCtrlVisible("Image2", false, sortBtn)
    else
        self:setCtrlVisible("Image1", false, sortBtn)
        self:setCtrlVisible("Image2", true, sortBtn)
    end

    if self.sortType == "start_time" then
        self:setCtrlVisible("Label1", false, sortBtn)
        self:setCtrlVisible("Label2", true, sortBtn)
    else
        self:setCtrlVisible("Label1", true, sortBtn)
        self:setCtrlVisible("Label2", false, sortBtn)
    end

    self:setCtrlVisible("SortPanel", false)
end

function MarketBuyDlg:onAddButton(sender, eventType)
    gf:showBuyCash()
end

function MarketBuyDlg:onResetButton(sender, eventType)
    local searchCtrl = self:getControl("SearchTextField")
    searchCtrl:didNotSelectSelf()
    searchCtrl:setText("")
    searchCtrl:setDeleteBackward(true)
end

function MarketBuyDlg:onMarketSellButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    local meLevel = Me:getLevel()
    if meLevel < LEVEL_LIMIT then
        gf:ShowSmallTips(string.format(CHS[3002987], LEVEL_LIMIT))
        return
    end

    DlgMgr:openDlg("MarketSellDlg")
    DlgMgr:closeDlg(self.name)
end


function MarketBuyDlg:MSG_STALL_ITEM_LIST(data)
    -- 3002963 收藏           7000306 搜索结果
    if self.firstClass ~= CHS[3002963] and self.firstClass ~= CHS[7000306] then
        if self.curPage and self.curPage == data["cur_page"] and self.curPage ~= 0 and not self.isOnBuyButton then
            gf:ShowSmallTips(string.format(CHS[6200039], self.curPage))
        end
        self:refreshItemList()
        self.isOnBuyButton = false
    end
end

function MarketBuyDlg:MSG_STALL_SERACH_ITEM_LIST(data)
    self.curSelectItem = nil
    local oneName = self:getOneName(data.type)
    MarketBuyDlg:selectItem(oneName, data.type)
    self:updateRightViewData()
    self:updateWholeViewData()
end


function MarketBuyDlg:MSG_UPDATE()
    self:setCashView()

    -- 刷新金钱
    local myCash = Me:queryBasicInt("cash")
    local cashText, fontColor = gf:getArtFontMoneyDesc(myCash)
    self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 21, "MoneyPanel2")
end

-- 更新搜索中购买物品的状态
function MarketBuyDlg:MSG_STALL_UPDATE_GOODS_INFO()
    self:refreshFormSeachItemList()
end

function MarketBuyDlg:tradeType()
    return MarketMgr.TradeType.marketType
end

function MarketBuyDlg:getCollectItemList()
    return MarketMgr:getCollectItemList(self:tradeType())
end

function MarketBuyDlg:cleanup()
    -- 存界面的选中信息
    local data = {}
    data.dlgName = self.name
    data.firstClass = self.lastFirstClass
    data.secondClass = self.secondClass
    data.thirdClass = self.thirdClass
    data.isFromSearch = self.isFromSearch
    data.curPage = self.curPage
    data.upSort  = self.upSort
    data.sortType = self.sortType
    MarketMgr:setMarketLastSelectStateData(data)

    self:cancleSelectItem()
    self.secondClass = nil
    self.thirdClass = nil

    self.lastFirstClass = nil
    self:releaseCloneCtrl("classCtrl")
    self:releaseCloneCtrl("classSelectImg")
    self:releaseCloneCtrl("upArrowImage")
    self:releaseCloneCtrl("secondClassCtrl")
    self:releaseCloneCtrl("thirdClassCtrl")
    self:releaseCloneCtrl("itemCellCtrl")
    self:releaseCloneCtrl("itemSelectImg")
    self:releaseCloneCtrl("selectImg")
    self:releaseCloneCtrl("selectBImg")
    self:releaseCloneCtrl("selectSImg")
    self:releaseCloneCtrl("bigCtrl")
    self:releaseCloneCtrl("smallCtrl")
    self:releaseCloneCtrl("searchCtrl")
end

-- 收藏好，服务器的通知，看看是否可以收藏等操作
function MarketBuyDlg:MSG_MARKET_CHECK_RESULT(data)
    if not self.selectItemData then return end
    local selettItem
    for i = 1, data.count do
        if self.selectItemData.id == data.itemList[i].id then
            selettItem = data.itemList[i]
        end
    end

    if not selettItem then return end

    if selettItem.status == 0 then
        gf:ShowSmallTips(CHS[4200235]) -- 当前商品已卖出或已下架，请选择其他商品。",
        self:requireItemList()
        return
    elseif selettItem.status ~= 2 then
        gf:ShowSmallTips(CHS[4200236]) -- 当前商品状态已发生变化，请重新操作。"
        self:requireItemList()
        return
    end

    -- 是否已经收藏
    if MarketMgr:isCollectedInAll(self.selectItemData.id, self:tradeType()) then return end

        -- MSG_GOLD_STALL_GOODS_STATE也会走到这，该消息如果 data.is_from_client == 0不需要加收藏
    if data.is_from_client and data.is_from_client == 0 then return end

    -- 可以收藏
    gf:ShowSmallTips(CHS[3002995])
    MarketMgr:addCollectItem(self.selectItemData, self:tradeType())

    self:swichCancelAndCollectBtn(false)
    self:refreshCollectImage(true, self.selectItemCell)
end

function MarketBuyDlg:cancleSelectItem()
    self.itemSelectImg:removeFromParent()

    if self.moneySelectImg then
        self.moneySelectImg:removeFromParent()
    end
    self.selectItemData = nil
end

function MarketBuyDlg:getSelectItemData()
    return self.selectItemData
end

-- 集市举报
function MarketBuyDlg:onTipOffMarket()
    if not self.selectItemData then
        self:onCloseButton()
        return
    end

    if not self:isPublicityItem(self.selectItemData) then
        gf:ShowSmallTips(CHS[4300466])  -- 该商品无需公示，无法举报。
        return
    end

    local data = {}
    data.user_gid = self.selectItemData.id
    data.user_name = self.selectItemData.name
    data.type = "goods_dlg"
    data.content = {}
    data.count = 1
    data.content[1] = {}
    data.content[1].reason = "market_item"
    data.user_dist = ""
    gf:CmdToServer("CMD_REPORT_USER", data)
    ChatMgr:setTipOffType("goods")
end


return MarketBuyDlg
