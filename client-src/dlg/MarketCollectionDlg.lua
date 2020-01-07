-- MarketCollectionDlg.lua
-- Created by songcw
-- 集市收藏界面

local MarketCollectionDlg = Singleton("MarketCollectionDlg", Dialog)

local MENU_CONTENT = {
    CHS[4100075],
    CHS[4200200],
    CHS[4200201],
}

local TIME_SORT_STR = {
    [CHS[4100075]] = CHS[4300184],      -- "时  间",
    [CHS[4200200]] = CHS[4300185],      -- 上架时间
    [CHS[4200201]] = CHS[4300186],      -- 公示时间
}

local CONST_DATA =
    {
        Colunm = 2
    }

local SCROLL_MARGIN = 20
local PAGE_MAX_COUNT = 8

-- ScrollView中空调行间距
local ITEM_ROL_MARGIN = 8

MarketCollectionDlg.sortType = 1

function MarketCollectionDlg:init()
    self:bindListener("SearchButton", self.onSearchButton)
    self:bindListener("LianxiButton", self.onLianxiButton)
    self:bindListener("ThirdButton", self.onThirdButton)
    self:bindListener("PriceSortButton", self.onPriceSortButton)
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("PanicBuyButton", self.onPanicBuyButton)
    self:bindListener("UnlockButton", self.onUnlockButton)
    self:bindListener("CollectionButton", self.onCollectionButton)
    self:bindListener("CancelCollectionButton", self.onCancelCollectionButton)
    self:bindListener("RefreshButton", self.onRefreshButton)
    self:bindListViewListener("ThirdCategoryListView", self.onSelectThirdCategoryListView)
    self:bindListViewListener("CategoryListView", self.onSelectCategoryListView)
    self:bindListener("MoneyPanel", self.onMoneyPanel)

    self:setCtrlVisible("ViewButton", false)
    self:bindMarketCheater()

    for i = 1, 4 do
        local btn = self:getControl("UnitPanel" .. i)
        btn:setTag(i)
        self:bindTouchEndEventListener(btn, self.onSortButton)
    end


    -- 打开数字键盘
    self:bindNumInput("PageInfoPanel", nil, self.inputLimit)

    -- 获取一级控件
    self.bigCtrl = self:getControl("BigPanel")
    self.bigCtrl:retain()
    self.bigCtrl:removeFromParent()

    -- 事件监听
    self:bindTouchEndEventListener(self.bigCtrl, self.onClickMenu)

    -- 菜单按钮的选中效果
    self.bigCtrlSelectImage = self:getControl("BChosenEffectImage", nil, self.bigCtrl)
    self.bigCtrlSelectImage:setVisible(true)
    self.bigCtrlSelectImage:retain()
    self.bigCtrlSelectImage:removeFromParent()

    self.bigCtrlSelectArrowImage = self:getControl("UpArrowImage", nil, self.bigCtrl)
    self.bigCtrlSelectArrowImage:retain()
    self.bigCtrlSelectArrowImage:removeFromParent()


    -- 商品列表单元格
    self.itemCellCtrl = self:getControl("ItemPanel")
    self.itemCellCtrl:retain()
    self.itemCellCtrl:removeFromParent()

    self.itemSelectImg = self:getControl("ChosenEffectImage", Const.UIImage, self.itemCellCtrl)
    self.itemSelectImg:retain()
    self.itemSelectImg:removeFromParent()



    self:bindFloatPanelListener("SortPanel")

    self.selectMenuBtn = false
    self.curPage = 1
    self.totalPage = 1
    self.selectItemData = false
    self.selectItemCell = false
    self.listInfo = {}

    self:setTradeTypeUI()

    -- 锁状态
    self:setLockBtn()

    -- 左边的菜单
    self:initLeftMenu()

    -- 金钱
    self:setCashView()

    self:swichCancelAndCollectBtn(false)

    self:onRefreshButton()

    self:setAllHookMsgs()
end

-- 设置所有hook消息
function MarketCollectionDlg:setAllHookMsgs()
    self:hookMsg("MSG_MARKET_CHECK_RESULT")
    self:hookMsg("MSG_SAFE_LOCK_INFO")
    self:hookMsg("MSG_UPDATE")

    self:hookMsg("MSG_STALL_RUSH_BUY_OPEN")
end

function MarketCollectionDlg:bindMarketCheater()
    local marketCheaterPanel = self:getControl("MarketCheaterPanel")
    marketCheaterPanel:setTouchEnabled(false)
    local layout = ccui.Layout:create()
    layout:setContentSize(marketCheaterPanel:getContentSize())
    layout:setPosition(marketCheaterPanel:getPosition())
    layout:setAnchorPoint(marketCheaterPanel:getAnchorPoint())

    local  function touch(touch, event)
        local rect = self:getBoundingBoxInWorldSpace(marketCheaterPanel)
        local toPos = touch:getLocation()

        if cc.rectContainsPoint(rect, toPos) then
            RecordLogMgr:setMarketCheaterClickTimesData("zone", self.name)
            return false
        end
    end
    self.root:addChild(layout, 10, 1)
    gf:bindTouchListener(layout, touch)
end

function MarketCollectionDlg:MSG_UPDATE()
    self:setCashView()
end

-- 设置金钱
function MarketCollectionDlg:setCashView()
    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23)
end

function MarketCollectionDlg:cleanup()
    self:releaseCloneCtrl("bigCtrl")
    self:releaseCloneCtrl("bigCtrlSelectImage")
    self:releaseCloneCtrl("bigCtrlSelectArrowImage")
    self:releaseCloneCtrl("itemCellCtrl")
    self:releaseCloneCtrl("itemSelectImg")
end

-- 设置左边的菜单
function MarketCollectionDlg:initLeftMenu()
    self.leftListCtrl, self.leftListSize = self:resetListView("CategoryListView")
    for i = 1, #MENU_CONTENT do
        local classCell = self.bigCtrl:clone()
        classCell.classType = MENU_CONTENT[i]
        classCell:setName(MENU_CONTENT[i])
        self:setLabelText("Label", MENU_CONTENT[i], classCell)
        self.leftListCtrl:pushBackCustomItem(classCell)
    end

    self:onClickMenu(self.leftListCtrl:getChildByName(MENU_CONTENT[1]))
end

-- 增加点击光效,菜单
function MarketCollectionDlg:addSelectImage(sender)
    self.bigCtrlSelectImage:removeFromParent()
    sender:addChild(self.bigCtrlSelectImage)

    self.bigCtrlSelectArrowImage:removeFromParent()
    sender:addChild(self.bigCtrlSelectArrowImage)
end

-- 增加点击光效,商品
function MarketCollectionDlg:addItemSelcelImage(sender)
    self.itemSelectImg:removeFromParent()
    sender:addChild(self.itemSelectImg)
end

function MarketCollectionDlg:getSortFun(sortType)
    -- 价格升序
    local function sortPriceUp(list)
        table.sort(list, function(l, r)
            if l.price < r.price then return true end
            if l.price > r.price then return false end

            if l.order < r.order then return true end
            if l.order > r.order then return false end

            if l.endTime < r.endTime then return true end
            if l.endTime > r.endTime then return false end

            return false
        end)
    end

    -- 价格降序
    local function sortPriceDown(list)
        table.sort(list, function(l, r)
            if l.price > r.price then return true end
            if l.price < r.price then return false end

            if l.order < r.order then return true end
            if l.order > r.order then return false end

            if l.endTime < r.endTime then return true end
            if l.endTime > r.endTime then return false end

            return false
        end)
    end

    -- 时间降序
    local function sortEndTimeDown(list)
        table.sort(list, function(l, r)
            if l.order > r.order then return true end
            if l.order < r.order then return false end

            if l.endTime > r.endTime then return true end
            if l.endTime < r.endTime then return false end

            return false
        end)
    end

    -- 时间升序
    local function sortEndTimeUp(list)
        table.sort(list, function(l, r)
            if l.order < r.order then return true end
            if l.order > r.order then return false end

            if l.endTime < r.endTime then return true end
            if l.endTime > r.endTime then return false end

            return false
        end)
    end

    if sortType == 1 then
        return sortPriceUp
    elseif sortType == 2 then
        return sortPriceDown
    elseif sortType == 3 then
        return sortEndTimeUp
    elseif sortType == 4 then
        return sortEndTimeDown
    end
end


function MarketCollectionDlg:getDataByType(classType)
    local listInfo = {}
    if classType == CHS[4100075] then
        local temp = MarketMgr:getCollectItemList(self:tradeType())
        local publicTemp = MarketMgr:getPublicCollectItem(self:tradeType())
        listInfo = {}
        for i = 1, #temp do
            temp[i].isPublic = false
            temp[i].order = 0
            table.insert(listInfo, temp[i])
        end
        for i = 1, #publicTemp do
            publicTemp[i].isPublic = true
            publicTemp[i].order = 1
            table.insert(listInfo, publicTemp[i])
        end
    elseif classType == CHS[4200200] then
        local temp = MarketMgr:getCollectItemList(self:tradeType())
        for i = 1, #temp do
            temp[i].isPublic = false
            temp[i].order = 0
            table.insert(listInfo, temp[i])
        end
    elseif classType == CHS[4200201] then
        local publicTemp = MarketMgr:getPublicCollectItem(self:tradeType())
        for i = 1, #publicTemp do
            publicTemp[i].isPublic = true
            publicTemp[i].order = 1
            table.insert(listInfo, publicTemp[i])
        end
    end

    local sortFun = self:getSortFun(self.sortType)
    sortFun(listInfo)
    return listInfo
end

function MarketCollectionDlg:getItemsByPage(page, maxCount, itemsList)

    local starNum = (page - 1) * maxCount + 1
    local endNum = math.min(page * maxCount, #itemsList)

    local ret = {}
    for i = starNum, endNum do
        table.insert(ret, itemsList[i])
    end
    return ret

end

-- 点击菜单
function MarketCollectionDlg:onClickMenu(sender, eventType)
    self:setCtrlVisible("PanicBuyButton", false)
    if self.selectMenuBtn and self.selectMenuBtn.classType ~= sender.classType then
        self.curPage = 1

        self.selectItemData = false
        self.selectItemCell = false
        self:swichCancelAndCollectBtn(false)

        self:setCtrlVisible("UnlockButton", false)

        self:setCtrlVisible("BuyButton", false)
        self:setCtrlVisible("PublicInfoPanel", false)
    end
    -- 设置选中菜单
    self.selectMenuBtn = sender

    -- 排序标志
    self:setSortFlag(self.sortType)

    -- 增加选择菜单选中效果
    self:addSelectImage(sender)

    -- 获取相关商品
    self.listInfo = self:getDataByType(sender.classType)

    self.totalPage = math.floor((#self.listInfo - 1) / PAGE_MAX_COUNT + 1)

    -- 显示右上角，商品个数
    self:setCtrlVisible("CollectionInfoPanel", false)
    self:setCtrlVisible("PanicBuyInfoPanel", false)

    if sender.classType == CHS[4100075] then
        self:setCtrlVisible("CollectionInfoPanel", true)

    elseif sender.classType == CHS[4200201] then
        self:setCtrlVisible("PanicBuyInfoPanel", true)

    end
    self:updateLayout("CollectionInfoPanel")

    -- 设置页码
    self:setPageInfo(self.listInfo)

    -- 设置数据
    local itemsInfo = self:getItemsByPage(self.curPage, PAGE_MAX_COUNT, self.listInfo)

    -- 初始化 ScrollView
    local scrollview = self:getControl("ItemScrollView")
    scrollview:removeAllChildren()
    if not next(self.listInfo) then
        self:setCtrlVisible("NoticePanel", true)
        return
    end
    self:setCtrlVisible("NoticePanel", false)

    -- 设置数据
    self:initListPanel(itemsInfo, self.itemCellCtrl, self.setItemData, scrollview, true)
end

function MarketCollectionDlg:setBtnDisplayByItem(cell, item)
    self:setCtrlVisible("UnlockButton", false)

    self:setCtrlVisible("BuyButton", false)
    self:setCtrlVisible("PanicBuyButton", false)
    self:setCtrlVisible("PublicInfoPanel", false)

    -- 收藏标签
    if item.isPublic then
        self:swichCancelAndCollectBtn(not MarketMgr:isPublicCollectItem(item.id, self:tradeType()))

        self:setCtrlVisible("PanicBuyButton", true)
    else
        self:swichCancelAndCollectBtn(not MarketMgr:isCollectItem(item.id, self:tradeType()))
        self:setCtrlVisible("BuyButton", true)

        self:setCtrlVisible("UnlockButton", SafeLockMgr:isNeedUnLock())
    end
end

function MarketCollectionDlg:setPageInfo(list)
    local pageText
    if not list or not next(list) then
        pageText = "0/0"
    else
        pageText = string.format("%d/%d", self.curPage, self.totalPage)
    end

    self:setNumImgForPanel("PageInfoPanel", ART_FONT_COLOR.DEFAULT, pageText, false, LOCATE_POSITION.MID, 23)
end

-- 初值列表数据
function MarketCollectionDlg:initListPanel(data, cellColne, func, panel, needScrollCallFuc)
    panel:removeAllChildren()
    local contentLayer = ccui.Layout:create()
    contentLayer:setName("DataLayer")
    local line = math.floor(#data / CONST_DATA.Colunm)
    local left = #data % CONST_DATA.Colunm

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0
    local totalHeight = line * (cellColne:getContentSize().height)

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
            local y = totalHeight - (i - 1) * (cellColne:getContentSize().height)
            cell:setPosition(x, y)
            cell:setTag(tag)
            contentLayer.maxCount = tag
            contentLayer.func = func
            cell.data = data[tag]
            if func then func(self, cell , data[tag]) end
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

                        performWithDelay(self.root, function()
                            self:onLeftButton()
                        end)

                    elseif y > SCROLL_MARGIN and isCanScroll then
                        isCanScroll = false
                        performWithDelay(self.root, function()
                            self:onRightButton()
                        end)
                    end
                end
                --[[
                if y < SCROLL_MARGIN / 2 then
                    isCanScroll = true
                end
                --]]
            end
        end

        scroview:addEventListener(scrollListener)

    end

    panel:addChild(scroview)
end

function MarketCollectionDlg:setItemData(cell, data)
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

       MarketMgr:setSellBuyTypeFlag(data.sell_type, self, cell)

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

            -- 下方按钮状态
            self:setBtnDisplayByItem(cell, self.selectItemData)
        end
    end

    local function onClick()
        self.selectItemData = data
        self.selectItemCell = cell
        self:addItemSelcelImage(cell)

        -- 下方按钮状态
        self:setBtnDisplayByItem(cell, self.selectItemData)
    end

    local function onLongClick()
        self.selectItemData = data
        self.selectItemCell = cell
        self:addItemSelcelImage(cell)

        -- 下方按钮状态
        self:setBtnDisplayByItem(cell, self.selectItemData)


        if not MarketMgr:isGoldtype(self:tradeType()) then
            BlogMgr:showButtonList(self, cell, "TipOffMarket", self.name)
        end
    end

    self:blindLongPressWithCtrl(cell, onLongClick, onClick)
  --  cell:addTouchEventListener(listener)

    -- 刷新时，如果有选中，再次选中
    if self.selectItemData and self.selectItemData.id == data.id then
        listener(cell, ccui.TouchEventType.ended)
        self.isExitItem = true
    end


    local iconPanel = self:getControl("IconPanel", nil, cell)
    local function showFloatPanel(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self.selectItemData = data
            self.selectItemCell = cell
            self:addItemSelcelImage(cell)

            -- 下方按钮状态
            self:setBtnDisplayByItem(cell, self.selectItemData)

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

    self:setCtrlVisible("BehindImage", false, cell)
    self:setCtrlVisible("LeadImage", false, cell)
    self:setCtrlVisible("PayImage", false, cell)
    self:setCtrlVisible("VendueImage", false, cell)

    if data.status == MARKET_STATUS.STALL_GS_AUCTION_SHOW or data.status == MARKET_STATUS.STALL_GS_AUCTION or data.status == MARKET_STATUS.STALL_GS_AUCTION_PAYMENT then
        -- 拍卖标记
        self:setCtrlVisible("VendueImage", true, cell)
        if data.status == MARKET_STATUS.STALL_GS_AUCTION_SHOW then
            self:setCtrlVisible("TimeLabel", true, cell)
            self:setCtrlVisible("BackImage", true, cell)
            local leftTime = data.endTime - gf:getServerTime()
            local timeStr = MarketMgr:getTimeStr(leftTime)
            self:setLabelText("TimeLabel", timeStr, cell)
        else
            if MarketMgr:isVenduedByGoodsGid(data.id) then
                self:setCtrlVisible("BehindImage", data.appointee_name ~= Me:queryBasic("name"), cell)
                self:setCtrlVisible("LeadImage", data.appointee_name == Me:queryBasic("name"), cell)
            end

            if data.appointee_name == Me:queryBasic("name") and data.status == MARKET_STATUS.STALL_GS_AUCTION_PAYMENT then
                self:setCtrlVisible("PayImage", true, cell)
            end
        end


    elseif data.status == 3 then
        -- 超时
        self:setCtrlVisible("TimeoutImage", true, cell)
        -- 公示中
    elseif data.status == 1 then
        self:setCtrlVisible("TimeLabel", true, cell)
        self:setCtrlVisible("BackImage", true, cell)
        local leftTime = data.endTime - gf:getServerTime()
        local timeStr = MarketMgr:getTimeStr(leftTime)
        self:setLabelText("TimeLabel", timeStr, cell)
    elseif data.status == 4 then
        self:setCtrlVisible("TipImage", true, cell)
    end

    iconPanel:addTouchEventListener(showFloatPanel)

    -- 收藏标签
    if data.isPublic then
        if MarketMgr:isPublicCollectItem(data.id, self:tradeType()) then
            self:setCtrlVisible("CollectionImage", true, cell)
        else
            self:setCtrlVisible("CollectionImage", false, cell)
        end
    else
        if MarketMgr:isCollectItem(data.id, self:tradeType()) then
            self:setCtrlVisible("CollectionImage", true, cell)
        else
            self:setCtrlVisible("CollectionImage", false, cell)
        end
    end

        -- 落后、领先标记\支付
    self:setCtrlVisible("BehindImage", false, cell)
    self:setCtrlVisible("LeadImage", false, cell)
    self:setCtrlVisible("PayImage", false, cell)

    if MarketMgr:isVenduedByGoodsGid(data.id) then
        self:setCtrlVisible("BehindImage", data.appointee_name ~= Me:queryBasic("name"), cell)
        self:setCtrlVisible("LeadImage", data.appointee_name == Me:queryBasic("name"), cell)
    end

    if data.appointee_name == Me:queryBasic("name") and data.status == MARKET_STATUS.STALL_GS_AUCTION_PAYMENT then
        self:setCtrlVisible("PayImage", true, cell)
    end

end

-- 小键盘输入页码
function MarketCollectionDlg:inputLimit()
    if not self.totalPage or self.totalPage <= 3 then
        gf:ShowSmallTips(CHS[6200047])
        return true
    end
end

function MarketCollectionDlg:onLianxiButton(sender, eventType)
    if not self.selectItemData then
        gf:ShowSmallTips(CHS[4100832])
        return
    end

    if not MarketMgr:isPublicityItem(self.selectItemData) then
        gf:ShowSmallTips(CHS[4100833])
        return
    end


    local exchangeType = MarketMgr.CARD_EXCHANGE.CARD_EXCHANGE_COLLECTION
    local type = MarketMgr:getTradeType() == MarketMgr.TradeType.marketType and CHS[7002311] or CHS[7002312]
    MarketMgr:connectSeller(type, self.selectItemData.id, exchangeType, self.name, self.selectItemData.name)
end

function MarketCollectionDlg:onSearchButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if Me:getVipType() == 0 and not GMMgr:isGM() then
        gf:ShowSmallTips(CHS[3003017])
        return
    end

    self:openSearchDlg()
end

function MarketCollectionDlg:openSearchDlg()
    DlgMgr:openDlg("MarketSearchDlg")
end

function MarketCollectionDlg:onThirdButton(sender, eventType)
end

function MarketCollectionDlg:onPriceSortButton(sender, eventType)
    self:setCtrlVisible("SortPanel", true)
end

-- 根据当前页码设置数据
function MarketCollectionDlg:setDataByPage()
    -- 设置数据
    local itemsInfo = self:getItemsByPage(self.curPage, PAGE_MAX_COUNT, self.listInfo)

    -- 初始化 ScrollView
    local scrollview = self:getControl("ItemScrollView")
    scrollview:removeAllChildren()

    -- 设置数据
    self:initListPanel(itemsInfo, self.itemCellCtrl, self.setItemData, scrollview, true)

    -- 设置页码
    self:setPageInfo(self.listInfo)
end

function MarketCollectionDlg:onLeftButton(sender, eventType)
    if not next(self.listInfo) or self.curPage <= 1 then
        return
    end

    -- 更新当前页码
    self.curPage = self.curPage - 1

    -- 设置数据
    self:setDataByPage()
end

function MarketCollectionDlg:onRightButton(sender, eventType)
    if not next(self.listInfo) or self.curPage >= self.totalPage then
        return
    end

    -- 更新当前页码
    self.curPage = self.curPage + 1

    -- 设置数据
    self:setDataByPage()
end

function MarketCollectionDlg:onPanicBuyButton(sender, eventType)
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

function MarketCollectionDlg:onBuyButton(sender, eventType)
    local level = Me:getLevel()
    if level < 50 then
        gf:ShowSmallTips(string.format(CHS[3002990], 50))
        return
    end

    if not self.selectItemData then
        gf:ShowSmallTips(CHS[3002988])
        return
    end

    local item =  self.selectItemData
    local function buyItem(amount)
        local price = item.appointee_name and item.appointee_name ~= "" and item.appointee_name ~= Me:queryBasic("name") and item.buyout_price or item.price
        if item.appointee_name and item.appointee_name == Me:queryBasic("name") and item.deposit_state and item.deposit_state == 1 then
            -- 指定交易的对象是自己，并且已经支付了订金，价格需要再减去订金
            price = item.price - MarketMgr:getDepositDingJin(item.price)
        end
       MarketMgr:BuyItem(item.id, "", "", price, 2, self:tradeType(), amount or 1)
    end

    local name = item.name
    if string.match(item.name, CHS[3002980]) then
        local list = gf:split(item.name, "|")
        name = list[1]
    end

    if MarketMgr:isGoldtype(self:tradeType()) then
        if item.price > Me:queryBasicInt("gold_coin") then
            gf:askUserWhetherBuyCoin("gold_coin")
            return
        else
            local price = item.appointee_name and item.appointee_name ~= "" and item.appointee_name ~= Me:queryBasic("name") and item.buyout_price or item.price
            if item.appointee_name and item.appointee_name == Me:queryBasic("name") and item.deposit_state and item.deposit_state == 1 then
                -- 指定交易的对象是自己，并且已经支付了订金，价格需要再减去订金
                price = item.price - MarketMgr:getDepositDingJin(item.price)
            end

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

        if not item.isPublic then -- 公示物品
            if MarketMgr:isCanDoubleSellAndBuy(name) then -- 可批量购买
                local dlg = DlgMgr:openDlg("MarketBatchSellItemDlg")
                dlg:setTradeType(self:tradeType())
                item.icon = InventoryMgr:getIconByName(item.name)
                dlg:setItemInfo(item, 5, item.id)
                dlg:setBuyInfo(item.amount, buyItem)
            else
                local showMessage = string.format(CHS[6400086], gf:getMoneyDesc(item.price) , name)
                -- 如果购买的是宠物且宠物无法参战时的提示，其他情况为空串
                local tip = MarketMgr:petCannotFightTip(item)
                gf:confirm(showMessage..tip, function()
                    buyItem()
                end, nil, nil, nil, nil, true)
            end
        end
    end
    --]]
end

function MarketCollectionDlg:onUnlockButton(sender, eventType)
    -- 安全锁判断
    if self:checkSafeLockRelease("onUnlockButton") then
        return
    end
end

function MarketCollectionDlg:onCollectionButton(sender, eventType)
    if not self.selectItemData then
        gf:ShowSmallTips(CHS[3003011])
        return
    end

    gf:ShowSmallTips(CHS[3003015])

    if self.selectItemData.isPublic then
        MarketMgr:addPublicCollectItem(self.selectItemData, self:tradeType())
    else
        MarketMgr:addCollectItem(self.selectItemData, self:tradeType())
    end


    self:swichCancelAndCollectBtn(false)
    self:refreshCollectImage(true, self.selectItemCell)
end

function MarketCollectionDlg:onCancelCollectionButton(sender, eventType)
    if not self.selectItemData then
        gf:ShowSmallTips(CHS[4200204])
        return
    end

    gf:ShowSmallTips(CHS[3003016])
    if self.selectItemData.isPublic then
        MarketMgr:cancelPublicCollect(self.selectItemData.id, self:tradeType())
    else
        MarketMgr:cancelCollect(self.selectItemData.id, self:tradeType())
    end
    self:swichCancelAndCollectBtn(true)
    self:refreshCollectImage(false, self.selectItemCell)
end

function MarketCollectionDlg:onRefreshButton(sender, eventType)
    MarketMgr:checkCollectItemStatus(self:tradeType())
end

function MarketCollectionDlg:onSelectThirdCategoryListView(sender, eventType)
end

function MarketCollectionDlg:onSelectCategoryListView(sender, eventType)
end

function MarketCollectionDlg:onMoneyPanel()
    gf:showBuyCash()
end

-- 隐藏和显示收藏图标
function MarketCollectionDlg:refreshCollectImage(isCollect, cell)
    if not cell then return end

    -- 收藏标签
    if isCollect then
        self:setCtrlVisible("CollectionImage", true, cell)
    else
        self:setCtrlVisible("CollectionImage", false, cell)
    end
end

function MarketCollectionDlg:setSortFlag(sortType)
    local btn = self:getControl("PriceSortButton")
    self:setCtrlVisible("Image1", (sortType == 1 or sortType == 3), btn)
    self:setCtrlVisible("Image2", not (sortType == 1 or sortType == 3), btn)

    if self.selectMenuBtn then
        if sortType == 1 or sortType == 2 then
            self:setLabelText("Label1", CHS[4300187], btn)
        else
            self:setLabelText("Label1", TIME_SORT_STR[self.selectMenuBtn.classType], btn)
        end
        for i = 3, 4 do
            local btnLevel = self:getControl("UnitPanel" .. i)

            self:setLabelText("Label", TIME_SORT_STR[self.selectMenuBtn.classType], btnLevel)
        end
    end

end


function MarketCollectionDlg:onSortButton(sender, eventType)
    self.sortType = sender:getTag()
    self:setSortFlag(self.sortType)

    self:setCtrlVisible("SortPanel", false)

    if not self.selectMenuBtn then return end
    self.curPage = math.min(self.curPage, 1)
    self:onClickMenu(self.selectMenuBtn)
end

function MarketCollectionDlg:tradeType()
    return MarketMgr.TradeType.marketType
end

function MarketCollectionDlg:setTradeTypeUI()

end

function MarketCollectionDlg:setLockBtn()
 --   self:setCtrlVisible("UnlockButton", SafeLockMgr:isNeedUnLock())

    self:setCtrlVisible("BuyButton", false)
    self:setCtrlVisible("PanicBuyButton", false)
    self:setCtrlVisible("PublicInfoPanel", false)
end

function MarketCollectionDlg:MSG_MARKET_CHECK_RESULT()
    if not self.selectMenuBtn then return end

    self.isExitItem = false
    self:onClickMenu(self.selectMenuBtn)
    if not self.isExitItem then
        self.selectItemData = false
        self.selectItemCell = false

        self:swichCancelAndCollectBtn(false)
        self:setCtrlVisible("BuyButton", false)
        self:setCtrlVisible("PanicBuyButton", false)
        self:setCtrlVisible("PublicInfoPanel", false)
        self:setCtrlVisible("UnlockButton", false)
    end
end

function MarketCollectionDlg:swichCancelAndCollectBtn(isShowCollect)
    if isShowCollect then
        self:setCtrlVisible("CollectionButton", true)
        self:setCtrlVisible("CancelCollectionButton", false)
    else
        self:setCtrlVisible("CollectionButton", false)
        self:setCtrlVisible("CancelCollectionButton", true)
    end
end

function MarketCollectionDlg:MSG_SAFE_LOCK_INFO()
    -- 锁状态
    self:setLockBtn()

    if self.selectItemCell then
        -- 下方按钮状态
        self:setBtnDisplayByItem(self.selectItemCell, self.selectItemData)
    end
end

function MarketCollectionDlg:MSG_STALL_RUSH_BUY_OPEN(data)
    if not self.selectItemData then return end

    if data.isOpen == 1 and data.goods_gid == self.selectItemData.id then
        local dlg = DlgMgr:openDlg("MarketPanicBuyDlg")

        dlg:setData(self.selectItemData, self:tradeType())
    end

    if data.isOpen == 0 and data.status == 0 then
        self:requireItemList()
    end
end

-- 集市举报
function MarketCollectionDlg:onTipOffMarket()
    if not self.selectItemData then
        self:onCloseButton()
        return
    end

    if not MarketMgr:isPublicityItem(self.selectItemData) then
        gf:ShowSmallTips(CHS[4300466])  -- 该商品无需公示，无法举报。
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

function MarketCollectionDlg:getSelectItemData()
    return self.selectItemData
end

return MarketCollectionDlg
