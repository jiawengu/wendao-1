-- MarketPublicityDlg.lua
-- Created by zhengjh Aug/23/2015
-- 告示

local MarketPublicityDlg = Singleton("MarketPublicityDlg", Dialog)

local CONST_DATA =
{
    Colunm = 2
}

local ITEM_CLASS =
{
    CHS[7000306],
    CHS[3002999],
    CHS[3003000],
    CHS[3003001],
    CHS[7000144],
    CHS[3003002],
    CHS[3003003],
}

local SEARCH_COST = 10000

local PAGE_CONTAIN_NUM = 8
local SCROLL_MARGIN = 20

function MarketPublicityDlg:init()
    self:bindListener("SearchButton", self.onSearchButton)
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("ResetButton", self.onResetButton)
    self:bindListener("MarketSellButton", self.onMarketSellButton)
    self:bindListener("PanicBuyButton", self.onPanicBuyButton)
    self:bindListener("CollectionButton", self.onCollectionButton)
    self:bindListener("CancelCollectionButton", self.onCancelCollectionButton)
    self:bindListener("PriceSortButton", self.onPriceSortButton)
    self:bindListener("MoneyPanel", self.onMoneyPanel)
    self:bindListener("UnlockButton", self.onUnlockButton)
    self:bindListener("LianxiButton", self.onLianxiButton)
    self.allSellItems = require("cfg/MarketSellItems")

    -- 排序按钮
    self:bindListener("UnitPanel1", self.onUnitPanel1)
    self:bindListener("UnitPanel2", self.onUnitPanel2)
    self:bindListener("UnitPanel3", self.onUnitPanel3)
    self:bindListener("UnitPanel4", self.onUnitPanel4)

    self:setCtrlVisible("ThirdButton", false)

    -- 显示抢购按钮
    self:swichTipOrBuy(false)

    self.curPage = 0
    self.totalPage = 0

    -- 当没有排序时，设置为默认升序，为false时是降序
    if self.upSort == nil then
        self.upSort  = true
        self.sortType = "price" 
    end   

    self.isOnPriceButton = false

    self.posxTable = {}
    self.posxTable[1] = self:getControl("ThirdButton"):getPositionX()
    self.posxTable[2] = self:getControl("PriceSortButton"):getPositionX()


    -- 根据交易类型设置ui
    self:setTradeTypeUI()

    -- 初值一级列表
    self:initClassList()

    -- 绑定二级菜单外关闭二级菜单
    self:bindSecondClassTouchEvent()

    -- 设置金钱
    self:setCashView()

    -- 设置所有hook消息
    self:setAllHookMsgs()
    self:hookMsg("MSG_SAFE_LOCK_INFO")

    -- 打开数字键盘
    self:bindNumInput("PageInfoPanel", nil, self.inputLimit)

    -- 页面刷新
    self:refreshPageInfo()

    -- 设置安全锁信息
    self:setSafeLockInfo()
end

function MarketPublicityDlg:onUnlockButton()
    SafeLockMgr:cmdOpenSafeLockDlg("SafeLockReleaseDlg")
end

function MarketPublicityDlg:getRequestKey()
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

function MarketPublicityDlg:getPageStr()
    if not self.curPage then  return end

    local page_str = ""

    if self.curPage < 1 then
        self.curPage = 1
    end

    if self.upSort then
        page_str = string.format("%d;%d;%d;%s", self.curPage, MarketMgr.TRADE_GOLD_STATE.SHOW, 1, self.sortType or "price")
    else
        page_str = string.format("%d;%d;%d;%s", self.curPage, MarketMgr.TRADE_GOLD_STATE.SHOW, 2, self.sortType or "price")
    end

    return page_str
end

function MarketPublicityDlg:onLianxiButton()
    if not self.selectItemData then
        gf:ShowSmallTips(CHS[4100832])
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

function MarketPublicityDlg:onMoneyPanel()
    gf:showBuyCash()
end

-- 设置金钱
function MarketPublicityDlg:setCashView()
    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23)
end

function MarketPublicityDlg:bindSecondClassTouchEvent()
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

        if not cc.rectContainsPoint(closeRect, toPos) and not cc.rectContainsPoint(rect, toPos) and not cc.rectContainsPoint(classRect, toPos) and  secondPanel:isVisible() then
            secondPanel:setVisible(false)

            local item = self.leftListCtrl:getChildByName(self.lastFirstClass or CHS[3002964])
            self:addClassSelcelImage(item)
            self.firstClass = self.lastFirstClass or CHS[3002964]

            if not self.secondClass then
                local searchData = MarketMgr:getSearchPublicityItemList(self:tradeType())
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

function MarketPublicityDlg:initClassList()

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
    self.secondClassCtrl:retain()
    self.secondClassCtrl:removeFromParent()


    -- 三级菜单单元格
    self.thirdClassCtrl = self:getControl("UnitPanel")
    self.thirdClassCtrl:retain()
    self.thirdClassCtrl:removeFromParent()

    -- 商品列表单元格
    self.itemCellCtrl = self:getControl("ItemPanel")
    self.itemCellCtrl:retain()
    self.itemCellCtrl:removeFromParent()

    self.itemSelectImg = self:getControl("ChosenEffectImage", Const.UIImage, self.itemCellCtrl)
    self.itemSelectImg:retain()
    self.itemSelectImg:removeFromParent()

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

function MarketPublicityDlg:cleanClassData()
    MarketMgr:MSG_STALL_ITEM_LIST({sell_stage = 1})
end


function MarketPublicityDlg:setInitSelectInfo()
    local selectData =  MarketMgr:getMarketLastSelectStateData(self.name)
    --if selectData and selectData.dlgName == self.name and selectData.firstClass ~= CHS[3002964] then
    if selectData and selectData.dlgName == self.name and next(MarketMgr:getStallItemList(self.name)) and selectData.firstClass then
        if selectData.isFromSearch then
            self:selectItemByClass(selectData.firstClass, selectData.secondClass, selectData.thirdClass, selectData.curPage, selectData.upSort, selectData.sortType)
        else
            self:initSelectOneClassInfo(selectData.firstClass, selectData.secondClass, selectData.thirdClass, selectData.curPage, selectData.upSort, selectData.sortType)
            self:refreshItemList()
        end
    elseif selectData and selectData.dlgName == self.name and selectData.firstClass == CHS[7000306] then
        self:selectItemByClass(selectData.firstClass, selectData.secondClass, selectData.thirdClass, selectData.curPage, selectData.upSort, selectData.sortType)
    else
        self:cleanClassData()

        -- 默认选中准备
        local item = self.leftListCtrl:getChildByName(CHS[3002999])
        self:addClassSelcelImage(item)

        self.firstClass = CHS[3002999]
  --      self:initCollectList()

        -- 初值化二级菜单内容
        local name = item:getName()
        self:initSecondMenu(name)
    end

end

function MarketPublicityDlg:getFirstItemList()
    return ITEM_CLASS
end

function MarketPublicityDlg:setTradeTypeUI()
    -- 设置商品单元格为货币为金元宝
    self:setCtrlVisible("GoldImage", false, self.itemCellCtrl)
    self:setCtrlVisible("CoinImage", true, self.itemCellCtrl)

    -- 设置玩家身上的金元宝
    local moneyPanel = self:getControl("MoneyPanel")
    self:setCtrlVisible("GoldImage", false, moneyPanel)
    self:setCtrlVisible("MoneyImage", true, moneyPanel)
end

-- 设置所有hook消息
function MarketPublicityDlg:setAllHookMsgs()
    self:hookMsg("MSG_STALL_ITEM_LIST")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_MARKET_CHECK_RESULT")

    self:hookMsg("MSG_STALL_RUSH_BUY_OPEN")
end

function MarketPublicityDlg:createClassCell(className)
    local cell = self.classCtrl:clone()
    local label = self:getControl("Label", Const.UILabel, cell)
    label:setString(className)
    return cell
end

function MarketPublicityDlg:addClassSelcelImage(item)
    self.upArrowImage:removeFromParent()
    item:addChild(self.upArrowImage)
    self.classSelectImg:removeFromParent()
    item:addChild(self.classSelectImg)
end

function MarketPublicityDlg:onClickClassList(sender,eventType)
    local item = self:getListViewSelectedItem(sender)
    self:addClassSelcelImage(item)

    -- 隐藏抢购按钮
  --  self:setCtrlVisible("PanicBuyButton", false)

    -- 隐藏三级列表内容
    --self:setCtrlVisible("ItemsPanel", false)

    self:setCtrlVisible("PanicBuyInfoPanel", false)

    -- 显示二级菜单内

    -- 初值化二级菜单内容
    local name = item:getName()
    self:initSecondMenu(name)
end

function MarketPublicityDlg:initSecondMenu(name)
    -- 现在会记忆二级菜单滑动位置，连续点击一级菜单的某一项过程中，每次都会刷新二级菜单，导致画面闪烁
    -- 故如果连续点击一级菜单的某一项，不再重新生成二级菜单界面
    if self.firstClass and self.firstClass == name then
        if self:getCtrlVisible("SecondPanel") == true then
            return
        end
    end

    self.firstClass = name

    if #self.allSellItems[name] > 0   then
        self:setCtrlVisible("SecondPanel", true)

    else
        self:setCtrlVisible("SecondPanel", false)
        if name == CHS[3002998] then
            self:initCollectList()
            self.selectItemData = nil
            self:swichCancelAndCollectBtn(true)
            return
        elseif name == CHS[7000306] then
            self:initSearchList()
            self.selectItemData = nil
            self.secondClass = nil
            self.thirdClass = nil
            self.lastFirstClass = self.firstClass
            self:swichCancelAndCollectBtn(true)
            return
        end
    end

    local classListPanel = self:getControl("ClassListPanel")
    classListPanel:removeAllChildren()

    -- 由于当前集市配置和珍宝同一份，后来黄伟相惊天要求，有些东西珍宝显示，集市不显示！so... 数据要转化下，排除不需要显示的
    local data = MarketMgr:eliminateData(self.allSellItems[name], self:tradeType())
    self:initListPanel(data, self.secondClassCtrl, self.initSecondClassCell, classListPanel)

    -- 初值化三级菜单的默认标签
    self:setCtrlVisible("ThirdPanel", false)
    self:setCtrlVisible("SortPanel", false)
end

-- 初值化收藏列表
function MarketPublicityDlg:initCollectList()
    MarketMgr:checkCollectItemStatus(self:tradeType())
    local itemList = self:getPublicCollectItem()
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
    self:setCtrlVisible("InfoPanel", true)
end


-- 初始化搜索结果列表
function MarketPublicityDlg:initSearchList()
    local itemList = MarketMgr:getSearchPublicityItemList(self:tradeType())
    local itemsPanel = self:getControl("ItemsPanel")
    if not itemList or #itemList == 0 then
        self:setCtrlVisible("NoticePanel", true, itemsPanel)
        self.curPage = 0
        self.totalPage = 0
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

-- 初值列表数据
function MarketPublicityDlg:initListPanel(data, cellColne, func, panel, needScrollCallFuc)
    panel:removeAllChildren()
    local contentLayer = ccui.Layout:create()
    contentLayer:setName("DataLayer")
    local line = math.floor(#data / CONST_DATA.Colunm)
    local left = #data % CONST_DATA.Colunm

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0
    local totalHeight = line * cellColne:getContentSize().height

    for i = 1, line do
        if i == line and left ~= 0 then
            curColunm = left
        else
            curColunm = CONST_DATA.Colunm
        end

        for j = 1, curColunm do
            local tag = j + (i - 1) * CONST_DATA.Colunm
            local cell = cellColne:clone()
            cell:setAnchorPoint(0,1)
            local x = (j - 1) * cellColne:getContentSize().width
            local y = totalHeight - (i - 1) * cellColne:getContentSize().height
            cell:setPosition(x, y)
            cell:setTag(tag)

            contentLayer.maxCount = tag
            contentLayer.func = func
            cell.data = data[tag]
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
    if needScrollCallFuc then
        local  function scrollListener(sender , eventType)
            if eventType == ccui.ScrollviewEventType.scrolling then
                local offset = -8
                local  y = scroview:getInnerContainer():getPositionY()
                if not isChangePage then
                    if y + SCROLL_MARGIN < offset  then
                        isChangePage= self:onLeftButton()

                    elseif y > SCROLL_MARGIN then
                        isChangePage= self:onRightButton()

                    end
                end
            end
        end

        scroview:addEventListener(scrollListener)
    end

    panel:addChild(scroview)
end

function MarketPublicityDlg:initSecondClassCell(cell, data)
    local nameLabel = self:getControl("OneNameLabel", Const.UILabel, cell)
    nameLabel:setString(data.name)
    local tag = cell:getTag()

    local itemList = MarketMgr:getThirdClassList(self.allSellItems[self.firstClass][tag]["list"], self:tradeType())
    local thirdButton = self:getControl("ThirdButton")
    local thirdPanel = self:getControl("ThirdPanel")
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if itemList then
               -- thirdButton:setVisible(true)
                self:showAndHideButton(true)
                self:bindTouchEndEventListener(thirdButton, self.onThirdButton, itemList)

                -- 设置三级菜单默认值
                local label = self:getControl("Label1", nil, thirdButton)
                if type(itemList[1]) == "number" then
                    -- 数字表示等级
                    local str = MarketMgr:getThirdClassStr(self:getThirdClassLevel(itemList[1]), self.firstClass)
                    label:setString(str)
                    self.thirdClass = self:getThirdClassLevel(itemList[1])
                else
                    local thirdClass = MarketMgr:getLastSelectThirdClass(self.firstClass, data.name, itemList[1])
                    label:setString(thirdClass)
                    self.thirdClass = thirdClass
                end
            else
                --thirdButton:setVisible(false)
                self:showAndHideButton(false)
                self.thirdClass = nil
            end

            -- 记录一下当前二级列表滑动位置
            if self.secondClassScrollView then
                local y = self.secondClassScrollView:getInnerContainer():getPositionY()
                MarketMgr:setSecondClassScrollPosition(self.firstClass, y)
            end

            thirdPanel:setVisible(false)
            self:setCtrlVisible("SecondPanel", false)
            self:setCtrlVisible("PriceSortButton", true)
            self:setCtrlVisible("CollectionInfoPanel", false)
            self:setCtrlVisible("SearchInfoPanel", false)
            self:setCtrlVisible("NoticePanel2", false)
            self:setCtrlVisible("InfoPanel", true)
            self.secondClass = data.name

            -- 获取上次排序
            self.upSort, self.sortType = MarketMgr:getLastSort()
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
            self:setImage("IconImage", ResMgr:getItemIconPath(data.icon), cell)
            self:setItemImageSize("IconImage", cell)
    else
            self:setImage("IconImage", ResMgr:getSmallPortrait(data.icon), cell)
            self:setItemImageSize("IconImage", cell)
    end
    end
    cell:addTouchEventListener(listener)
end

-- 显示和隐藏价格按钮和三级列表按钮
function MarketPublicityDlg:showAndHideButton(haveThirdClass)
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
    priceSortBtn:setVisible(true)
end

-- 获取玩家适合等级
function MarketPublicityDlg:getThirdClassLevel(minLevel)
    local lastLevel = MarketMgr:getLastSelectLevel(self.firstClass)
    if lastLevel then
        return lastLevel
    end

    local level = 0
    local meLevel = Me:queryBasicInt("level")
    if self.firstClass == CHS[3003007] then
        level = math.floor(meLevel / 10)
    else
        level = math.floor(meLevel / 10) * 10
    end

    if level < minLevel then
        level = minLevel
    end

    return level
end

function MarketPublicityDlg:onThirdButton(sender, eventType, data)
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

function MarketPublicityDlg:initTirdClassCell(cell, data)
    local nameLabel = self:getControl("Label", Const.UILabel, cell)
    local thirdPanel = self:getControl("ThirdPanel")
    local thirdButton = self:getControl("ThirdButton")
    local str = MarketMgr:getThirdClassStr(data, self.firstClass)
    nameLabel:setString(str)

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            thirdPanel:setVisible(false)
            local label = self:getControl("Label1", nil, thirdButton)
            label:setString(str)

            -- 获取上次排序
            self.upSort, self.sortType = MarketMgr:getLastSort()
            self.curPage = 1
            self:refreshUpDownImage()

            -- 发送物品请求
            self.thirdClass = data
            self:requireItemList()

            -- 设置上次的等级
            MarketMgr:setLastSelectLevel(self.firstClass, data)

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
function MarketPublicityDlg:refreshItemList()
    self.selectItemData = nil
    self:swichCancelAndCollectBtn(true)
    self.isFromSearch = false
    local itemList = {}
    local requireInfo = MarketMgr:getStallItemList(self.name)

    local itemList = requireInfo["itemList"] or {}
    self.curPage = requireInfo["cur_page"] or 0
    self.totalPage = requireInfo["totalPage"] or 0

    self:setCtrlVisible("PanicBuyInfoPanel", self.firstClass ~= CHS[7000306])
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

-- 和 function MarketMgr:BuyItem(itemId, key, pageStr, price, type, tradeType, amount)中type对应
-- 请求购买  type  0   // 普通购买        1   // 搜索购买      2   // 收藏购买            3   // 抢购     4 我的竞拍
function MarketPublicityDlg:getTradeType()
    if self.firstClass == CHS[3002963]then
        return 2

    elseif self.isFromSearch then
        return 1
    else
        return 0
    end
end


-- 刷新从搜索返回的物品
function MarketPublicityDlg:refreshFormSeachItemList()
    self.selectItemData = nil
    self:swichCancelAndCollectBtn(true)
    self.isFromSearch = true
    local itemList = {}

    local allitemList= {}
    if self.firstClass == CHS[3002998] then
        allitemList =  self:getPublicCollectItem()
    elseif self.firstClass == CHS[7000306] then
        -- 如果是搜索结果，由客户端进行排序（根据价格/公示时间）
        if self.sortType == "start_time" then
            allitemList = MarketMgr:getSearchPublicityItemListByTime(self.upSort, self:tradeType())
        elseif self.sortType == "price" then
            if self.upSort then
                allitemList = MarketMgr:getSearchPublicityItemList(self:tradeType())
            else
                allitemList = MarketMgr:getDownSearchPublicityList(self:tradeType())
            end
        end
    else
        if self.upSort then
            allitemList = MarketMgr:getSearchPublicityItemList(self:tradeType())
        else
            allitemList =  MarketMgr:getDownSearchPublicityList(self:tradeType())
        end
    end
    if not allitemList then return end

    self.totalPage = math.ceil(#allitemList / PAGE_CONTAIN_NUM)

    if self.curPage > self.totalPage then
        self.curPage = self.totalPage
    end

    for i = 1 + (self.curPage - 1) * 8, 8 * self.curPage do
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

function MarketPublicityDlg:addItemSelcelImage(item)
    self.itemSelectImg:removeFromParent()
    item:addChild(self.itemSelectImg)

    if MarketMgr:isPublicCollectItem(self.selectItemData.id, self:tradeType()) then
        self:swichCancelAndCollectBtn(false)
    else
        self:swichCancelAndCollectBtn(true)
    end

 --   local isTip = (self.selectItemData.endTime - gf:getServerTime() > 60 * 3)
 --   self:swichTipOrBuy(isTip)
end

-- 显示公示商品浏览提示或者抢购按钮
function MarketPublicityDlg:swichTipOrBuy(isTip)
    self:setCtrlVisible("PanicBuyButton", not isTip)
    self:setCtrlVisible("InfoPanel", isTip)
end

-- 转换收藏、取消收藏按钮
function MarketPublicityDlg:swichCancelAndCollectBtn(isShowCollect)
    if isShowCollect then
        self:setCtrlVisible("CollectionButton", true)
        self:setCtrlVisible("CancelCollectionButton", false)
    else
        self:setCtrlVisible("CollectionButton", false)
        self:setCtrlVisible("CancelCollectionButton", true)
    end
end

-- 发送请求物品的指令
function MarketPublicityDlg:requireItemList()
    if not self.firstClass or not self.secondClass or not self.curPage then return end

    local key = self.firstClass.."_".. self.secondClass
    if self.thirdClass then
        key = key.."_"..self.thirdClass
    end

    if self.curPage < 1 then
        self.curPage = 1
    end

    local page_str

    if self.upSort then
        page_str = string.format("%d;%d;%d;%s", self.curPage, MARKET_STATUS.STALL_GS_SHOWING, 1, self.sortType or "price")
    else
        page_str = string.format("%d;%d;%d;%s", self.curPage, MARKET_STATUS.STALL_GS_SHOWING, 2, self.sortType or "price")
    end

    MarketMgr:requestBuyItem(key, page_str, self:tradeType())

    -- 隐藏抢购按钮
 --   self:setCtrlVisible("PanicBuyButton", false)
end

-- 刷新页面信息
function MarketPublicityDlg:refreshPageInfo()
    if self.totalPage == 0 then
        self.curPage = 0
    end

    local pageText = string.format("%d/%d", self.curPage, self.totalPage)

    self:setNumImgForPanel("PageInfoPanel", ART_FONT_COLOR.DEFAULT, pageText, false, LOCATE_POSITION.MID, 23)
end


-- 数字键盘插入数字
function MarketPublicityDlg:insertNumber(num)
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

function MarketPublicityDlg:inputLimit()
    if not self.totalPage or  self.totalPage <= 3 then
        gf:ShowSmallTips(CHS[6200047])
        return true
    end
end


function MarketPublicityDlg:setItemData(cell, data)
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

    if data.item_polar then
        InventoryMgr:addArtifactPolarImage(goodsImage, data.item_polar)
    end

    -- 带属性超级黑水晶
    if string.match(data.name, CHS[3003008]) then
        local name = string.gsub(data.name,CHS[3003009],"")
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
            if EquipmentMgr:getAttribsTabByName(CHS[3003010])[field] then bai = "%" end
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
            self:addItemSelcelImage(cell)
        end
    end

    local function onClick()
        self.selectItemData = data
        self.selectItemCell = cell
        self:addItemSelcelImage(cell)
    end

    local function onLongClick()
        self.selectItemData = data
        self.selectItemCell = cell
        self:addItemSelcelImage(cell)

        if not MarketMgr:isGoldtype(self:tradeType()) then
            BlogMgr:showButtonList(self, cell, "TipOffMarket", self.name)
        end
    end

    self:blindLongPressWithCtrl(cell, onLongClick, onClick)

   -- cell:addTouchEventListener(listener)


    local iconPanel = self:getControl("IconPanel", nil, cell)
    local function showFloatPanel(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self.selectItemData = data
            self.selectItemCell = cell
            self:addItemSelcelImage(cell)

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

    -- 超时
    if data.status == 3 then
        self:setCtrlVisible("TimeoutImage", true, cell)
        -- 公示中
    elseif data.status == 1 then
        self:setCtrlVisible("TimeLabel", true, cell)
        local leftTime = data.endTime - gf:getServerTime()
        local timeStr = MarketMgr:getTimeStr(leftTime)
        self:setLabelText("TimeLabel", timeStr, cell)
    elseif data.status == 4 then
        self:setCtrlVisible("TipImage", true, cell)
    end

    iconPanel:addTouchEventListener(showFloatPanel)


    -- 收藏标签
    if MarketMgr:isPublicCollectItem(data.id, self:tradeType()) then
        self:setCtrlVisible("CollectionImage", true, cell)
    else
        self:setCtrlVisible("CollectionImage", false, cell)
    end

   -- cell:setTag(data.id)
    MarketMgr:setSellBuyTypeFlag(data.sell_type, self, cell)

    -- 默认选中
    if self.defaultSelectGid == data.id then
        listener(nil, ccui.TouchEventType.ended)
        if self.defaultCol then
            self:defaultCol()
        end
        self.defaultSelectGid = nil
    end
end

-- 从搜索界面跳转过来选中某一个类别
function MarketPublicityDlg:selectItemByClass(firstClass, sendcondClass, thirdClass, page, upSort, sortType)
    self:initSelectOneClassInfo(firstClass, sendcondClass, thirdClass, page, upSort, sortType)
    self:refreshUpDownImage()
    self.isFromSearch = true
    self:setCtrlVisible("SecondPanel", false)
    self:refreshFormSeachItemList()
end

function MarketPublicityDlg:ShowPageByClass(firstClass, sendcondClass, thirdClass, notRequest)
    self:initSelectOneClassInfo(firstClass, sendcondClass, thirdClass)
    -- 默认为升序
 --   self.upSort  = true
    self:refreshUpDownImage()

    self.isFromSearch = false

    if self.firstClass ~= CHS[3002963] and self.firstClass ~= CHS[7000306] and not notRequest then
        self:requireItemList()
    end
end

function MarketPublicityDlg:initSelectOneClassInfo(firstClass, sendcondClass, thirdClass, page, upSort, sortType)
    local thirdButton = self:getControl("ThirdButton")
    local thirdPanel = self:getControl("ThirdPanel")
    if thirdClass then
        -- 设置三级菜单默认值
        local label = self:getControl("Label1", nil, thirdButton)
        local str = MarketMgr:getThirdClassStr(thirdClass, firstClass)
        label:setString(str)

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

        self:showAndHideButton(true)
        --thirdButton:setVisible(true)
    else
        self:showAndHideButton(false)
       -- thirdButton:setVisible(false)
    end

    thirdPanel:setVisible(false)
    self:setCtrlVisible("CollectionInfoPanel", false)
    self:setCtrlVisible("SearchInfoPanel", firstClass == CHS[7000306])
    self:setCtrlVisible("PanicBuyInfoPanel", firstClass ~= CHS[7000306])
    self:setCtrlVisible("InfoPanel", true)


    self.firstClass = firstClass
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



function MarketPublicityDlg:onLeftButton(sender, eventType)
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

function MarketPublicityDlg:onRightButton(sender, eventType)
   -- if self.curPage < self.totalPage then
        performWithDelay(self.root, function()
        self.curPage = self.curPage + 1
            if self.isFromSearch then
                self:refreshFormSeachItemList()
            else
                self:requireItemList()
            end
         end, 0)

        return true
  --  end

  --  return false
end

function MarketPublicityDlg:onPanicBuyButton()
    if not DistMgr:checkCrossDist() then return end

    if not self.selectItemData then
        gf:ShowSmallTips(CHS[4300202])
        return
    end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 摆摊等级限制
    local meLevel = Me:getLevel()
    local limitLevel = MarketMgr:getOnSellLevel()
    if MarketMgr:isGoldtype(self:tradeType()) then limitLevel = MarketMgr:getGoldOnSellLevel() end
    if meLevel < limitLevel then
        gf:ShowSmallTips(string.format(CHS[3002435], limitLevel))
        return
    end

    if  self.selectItemData.is_my_goods == 1 then
        gf:ShowSmallTips(CHS[3003014])
        return
    end

    -- 刷新界面数据
    local dataLayer = self:getControl("DataLayer")
    if dataLayer then
        local count = dataLayer.maxCount
        if count then
            for i = 1, count do
                local func = dataLayer.func
                local cell = dataLayer:getChildByTag(i)
                if cell then
                    local data = cell.data
                    dataLayer.func(self, cell , data)
                end
            end
        end
    end


    local isTip = (self.selectItemData.endTime - gf:getServerTime() > 60 * 3)
    if isTip then
        gf:ShowSmallTips(CHS[4300201])
        return
    end

    MarketMgr:cmdOpenPanicBuy(self.selectItemData.id, self:tradeType())
end

function MarketPublicityDlg:onCollectionButton()
    if nil == self.selectItemData then
        gf:ShowSmallTips(CHS[3003011])
        return
    end

    if not MarketMgr:isPublicCanCollect(self:tradeType()) then
        gf:ShowSmallTips(CHS[3003012])
        return
    end

    if not MarketMgr:isPublicityItem(self.selectItemData) then
        gf:ShowSmallTips(CHS[3003013])
        return
    end

    if  self.selectItemData.is_my_goods == 1 then
        gf:ShowSmallTips(CHS[3003014])
        return
    end

    MarketMgr:checkCollectItemStatusByGid(self:tradeType(), self.selectItemData.id)
--[[
    gf:ShowSmallTips(CHS[3003015])
    MarketMgr:addPublicCollectItem(self.selectItemData, self:tradeType())
    self:swichCancelAndCollectBtn(false)
    self:refreshCollectImage(true, self.selectItemCell)
    --]]
end

function MarketPublicityDlg:onCancelCollectionButton()
    gf:ShowSmallTips(CHS[3003016])
    MarketMgr:cancelPublicCollect(self.selectItemData.id, self:tradeType())
    MarketMgr:cancelCollect(self.selectItemData.id, self:tradeType())
    self:swichCancelAndCollectBtn(true)
    self:refreshCollectImage(false, self.selectItemCell)
end

-- 隐藏和显示收藏图标
function MarketPublicityDlg:refreshCollectImage(isCollect, cell)
    if not cell then return end

    -- 收藏标签
    if isCollect then
        self:setCtrlVisible("CollectionImage", true, cell)
    else
        self:setCtrlVisible("CollectionImage", false, cell)
    end
end

function MarketPublicityDlg:onPriceSortButton()
    local sortPanel = self:getControl("SortPanel")
    if not sortPanel:isVisible() then
        sortPanel:setVisible(true)
    else
        sortPanel:setVisible(false)
    end

    self:setCtrlVisible("ThirdPanel", false)
end

function MarketPublicityDlg:onUnitPanel1(sender, eventType)
    self.sortType = "price"
    self.upSort = true
    self.curPage = math.min(self.curPage, 1)
    self:refrshSortButtonInfo()
end

function MarketPublicityDlg:onUnitPanel2(sender, eventType)
    self.sortType = "price"
    self.upSort = false
    self.curPage = math.min(self.curPage, 1)
    self:refrshSortButtonInfo()
end

function MarketPublicityDlg:onUnitPanel3(sender, eventType)
    self.sortType = "start_time"
    self.upSort = true
    self.curPage = math.min(self.curPage, 1)
    self:refrshSortButtonInfo()
end

function MarketPublicityDlg:onUnitPanel4(sender, eventType)
    self.sortType = "start_time"
    self.upSort = false
    self.curPage = math.min(self.curPage, 1)
    self:refrshSortButtonInfo()
end

function MarketPublicityDlg:refrshSortButtonInfo()
    self:refreshUpDownImage()
    self.isOnPriceButton = true
    local sortBtn = self:getControl("PriceSortButton")
    self:setCtrlVisible("SortPanel", false)

    if self.isFromSearch then
        self:refreshFormSeachItemList()
    else
        self:requireItemList()
    end

    MarketMgr:setLastSort(self.upSort, self.sortType)
end

function MarketPublicityDlg:refreshUpDownImage()
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


function MarketPublicityDlg:getPublicCanFreshPage()
    return  math.min(math.max(math.floor(self.totalPage / 2), 3), self.totalPage) - 1
end

function MarketPublicityDlg:onSearchButton(sender, eventType)
    if Me:getVipType() == 0 and not GMMgr:isGM() then
        gf:ShowSmallTips(CHS[3003017])
        return
    end

    self:openSearchDlg()
end

function MarketPublicityDlg:openSearchDlg()
    DlgMgr:openDlg("MarketSearchDlg")
end

function MarketPublicityDlg:MSG_STALL_ITEM_LIST(data)
    if self.firstClass ~= CHS[3002998] and self.firstClass ~= CHS[7000306] then
        if self.curPage and self.curPage == data["cur_page"] and self.curPage ~= 0 and not self.isOnPriceButton then
            gf:ShowSmallTips(string.format(CHS[6200039], self.curPage))
        end
        self:refreshItemList()

        self.isOnPriceButton = false
    end

end

function MarketPublicityDlg:cleanup()
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

    self.selectItemData = nil
    self.secondClass = nil
    self.thirdClass = nil
    self.lastFirstClass = nil
    self:releaseCloneCtrl("classCtrl")
    self:releaseCloneCtrl("upArrowImage")
    self:releaseCloneCtrl("secondClassCtrl")
    self:releaseCloneCtrl("classSelectImg")
    self:releaseCloneCtrl("thirdClassCtrl")
    self:releaseCloneCtrl("itemCellCtrl")
    self:releaseCloneCtrl("itemSelectImg")
end

function MarketPublicityDlg:MSG_UPDATE()
    self:setCashView()
end

function MarketPublicityDlg:tradeType()
    return MarketMgr.TradeType.marketType
end

function MarketPublicityDlg:getPublicCollectItem()
    return MarketMgr:getPublicCollectItem(self:tradeType())
end

-- 收藏好，服务器的通知，看看是否可以收藏等操作
function MarketPublicityDlg:MSG_MARKET_CHECK_RESULT(data)

    if not self.selectItemData then return end
    local selettItem
    for i = 1, data.count do
        if self.selectItemData.id == data.itemList[i].id then
            selettItem = data.itemList[i]
        end
    end

    if not selettItem then return end

    if selettItem.status == 0 then
        gf:ShowSmallTips(CHS[4200235])
        self:requireItemList()
        return
    elseif selettItem.status ~= 1 then
        gf:ShowSmallTips(CHS[4200236])
        self:requireItemList()
        return
    end

    -- 是否已经收藏
    if MarketMgr:isCollectedInAll(self.selectItemData.id, self:tradeType()) then return end

    -- MSG_GOLD_STALL_GOODS_STATE也会走到这，该消息如果 data.is_from_client == 0不需要加收藏
    if data.is_from_client and data.is_from_client == 0 then return end

    -- 可以收藏
    gf:ShowSmallTips(CHS[3003015])
    MarketMgr:addPublicCollectItem(self.selectItemData, self:tradeType())
    self:swichCancelAndCollectBtn(false)
    self:refreshCollectImage(true, self.selectItemCell)
end

function MarketPublicityDlg:onDlgOpened(param)
    if nil == param[1] then
        return
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

        -- param[4] 为选中指定的道具gid，目前该逻辑为先刷数据后打开界面，所以打开界面后不用再请求数据
        local notRequest
        if param[4] then
            self.defaultSelectGid = param[4]
            notRequest = true
        end

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

function MarketPublicityDlg:MSG_STALL_RUSH_BUY_OPEN(data)
    if not self.selectItemData then return end

    if data.isOpen == 1 and data.goods_gid == self.selectItemData.id then
        local dlg = DlgMgr:openDlg("MarketPanicBuyDlg")

        dlg:setData(self.selectItemData, self:tradeType())
    end

    if data.isOpen == 0 and data.status == 0 then
        self:requireItemList()
    end
end

-- 设置安全锁信息
function MarketPublicityDlg:setSafeLockInfo()
    self:setCtrlVisible("UnlockButton", SafeLockMgr:isNeedUnLock())
end

function MarketPublicityDlg:MSG_SAFE_LOCK_INFO()
    self:setSafeLockInfo()
end

-- 集市举报
function MarketPublicityDlg:onTipOffMarket()
    if not self.selectItemData then
        self:onCloseButton()
        return
    end

    local data = {}
    data.user_gid = self.selectItemData.id
    data.user_name = self.selectItemData.name
    data.type = "goods_dlg"
    data.content = {}
    data.count = 1
    data.user_dist = ""
    data.content[1] = {}
    data.content[1].reason = "market_item"
    gf:CmdToServer("CMD_REPORT_USER", data)

    ChatMgr:setTipOffType("goods")
end

function MarketPublicityDlg:getSelectItemData()
    return self.selectItemData
end


return MarketPublicityDlg
