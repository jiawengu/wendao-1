-- OnlineMallDlg.lua
-- Created by zhengjh Mar/2/2015
-- 在线商城

local Group = require('ctrl/RadioGroup')
local PageTag = require('ctrl/PageTag')

local FASHION_OFF_Y = -70

local CONST_DATA =
{
    columnSpace = 6 ,
    lineSapce = 5 ,
    columnNumber = 2 ,
    decriptionSapce = 10, -- 描述面板间距
    shopLimit = 100,
    goldCoin  = 1,    -- 金元宝
    silverCoin = 2,   -- 银元宝
    marginTop = 0,    -- 容器上边距
    marginLeft = 0,   -- 容器左边距
}

local FOLLOW_SPRITE_OFFPOS = {
    [1] = cc.p(-30, -80),
    [3] = cc.p(40, -80),
    [5] = cc.p(-40, -80),
    [7] = cc.p(40, -80),
}

local NumImg = require('ctrl/NumImg')

local COIN_IMAGE =
{
    [1] = ResMgr.ui["big_gold"],
    [2] = ResMgr.ui["big_silver"],
}

-- 道具标签
local RECOMMEND =
{
    [1] = CHS[6000038],  -- 新品
    [2] = CHS[6000037],  -- 热销
    [3] = CHS[6000039],  -- 推荐
    [4] = CHS[6000040],  -- 折扣
}

local FASHION_OFFECT = {
    [21018] = {x = 0, y = -10},  -- 引天长歌
}

local TOUCH_BEGAN  = 1
local TOUCH_END     = 2

local TAG_TEAM = 10    -- 放item的曾
local OnlineMallDlg = Singleton("OnlineMallDlg", Dialog)

local lastClick -- 代表表示上一次点击的按钮，用于判断按不同按钮
local lastSelectTab
local lastCloseTime
local TAB_INIT_TIME = 150

function OnlineMallDlg:init()
    self:bindListener("GoodsPanel", self.onGoodsButton)
    self:bindListener("NumberButton", self.onNumberButton)
    self:bindListener("TotalValueButton", self.onTotalValueButton)
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListViewListener("PharmacyListView", self.onSelectPharmacyListView)

    self:bindListener("GoldBackImage", self.onAddGoldButton)
    self:bindListener("SilverBackImage", self.onAddSliverButton)
    self:bindListener("SupplyPanel", self.onSupplyPanel, "CoinTypePanel")

    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("LeftButton", self.onLeftButton)

    -- 打开数字键盘
    self:bindNumInput("NumberValueImage", nil, function()
        if not self.selectTag then
            gf:ShowSmallTips(CHS[3003169])
            return true
        end
    end)

    -- 是否含有幸运折扣券
    self.hasDiscountCoupon = InventoryMgr:hasDiscountCoupon()

    self.lastSelectTag = nil
    local goodsCellPanel = self:getControl("GoodsPanel", Const.UIPanel)
    goodsCellPanel:retain()
    goodsCellPanel:removeFromParent()
    self.goodsCellPanel = goodsCellPanel

    self.selectImagePattern = self:getControl("ChosenEffectImage", Const.UIImage, goodsCellPanel)
    self.selectImagePattern:retain()
    self.selectImagePattern:removeFromParent()

    self.namePanel = self:getControl("NamePanel")
    self.namePanel:retain()
    self.namePanel:removeFromParent()

    self.descPanel = self:getControl("DescriptionPanel")
    self.descPanel:retain()
    self.descPanel:removeFromParent()

    self.isLimitPurchaseOpen = ActivityMgr:isInLimitPurchase()

    --self:hookMsg("MSG_ONLINE_MALL_LIST")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_ACTIVITY_LIST")

    self:blindPress("ReduceButton")
    self:blindPress("AddButton")

   -- local infoLabel = self:getControl("InfoLabel")
    self.radio = self:getControl("CheckBox", Const.UICheckBox)
    self.radio:setSelectedState(OnlineMallMgr.isUseGold)

    local function checkBoxClick(self, sender, eventType)
        lastClick = "checkBox"
        if eventType == ccui.CheckBoxEventType.selected then
            gf:ShowSmallTips(CHS[3003170])
            OnlineMallMgr.isUseGold = true
            self:setShopPanel(true)
        elseif eventType == ccui.CheckBoxEventType.unselected then
            gf:ShowSmallTips(CHS[3003171])
            OnlineMallMgr.isUseGold = false
            self:setShopPanel(true)
        end
    end

    self:bindCheckBoxWidgetListener(self.radio, checkBoxClick)

    self.group = Group.new()
    self.group:setItems(self, {"CheckBox_1", "CheckBox_2", "CheckBox_3", "CheckBox_4"}, self.onSelected)

    if not lastCloseTime or (lastCloseTime and gf:getServerTime() - lastCloseTime > TAB_INIT_TIME) then
        self.group:selectRadio(1)
    else
        self.group:selectRadio(lastSelectTab or 1)
    end

    self:setShopPanel()

    -- 对同一个按钮连续点击的计数位
    self.clickButtonTime = 0

    if not ActivityMgr:getStartTimeList() then
        ActivityMgr:CMD_ACTIVITY_LIST()
    else
        self:MSG_ACTIVITY_LIST()
    end

    -- 时装page
    self.curPageIndex = 1
    local pageTagPanel = self:getControl("PageTagPanel")
    pageTagPanel:removeAllChildren()
    local pageView = self:getControl('PageView', Const.UIPageView)
    local contentSize = pageView:getContentSize()


    -- 绑定分页控件和分页标签
    local pageTag = PageTag.new(2, 2)
    local tagPanelSz = pageTagPanel:getContentSize()
    pageTag:ignoreAnchorPointForPosition(false)
    pageTag:setAnchorPoint(0.5, 0)
    pageTag:setPositionX(tagPanelSz.width / 2)
    pageTagPanel:addChild(pageTag)
    self:bindPageViewAndPageTag(pageView, pageTag, self.onPageChanged)
    pageTag:setPage(1)

    EventDispatcher:addEventListener("doOpenDlgRequestData", self.onOpenDlgRequestData, self)
end

function OnlineMallDlg:onAddGoldButton(sender, eventType)
    local onlineTabDlg = DlgMgr.dlgs["OnlineMallTabDlg"]

    -- 需要延迟一帧，释放按钮
    performWithDelay(sender, function()
        if onlineTabDlg then
            onlineTabDlg.group:setSetlctByName("RechargeCheckBox")
        else
            DlgMgr:openDlg("OnlineRechargeDlg")
            DlgMgr.dlgs["OnlineMallTabDlg"].group:setSetlctByName("RechargeCheckBox")
        end
    end, 0)
end

function OnlineMallDlg:onAddSliverButton(sender, eventType)
    InventoryMgr:openItemRescourse(CHS[3003172])
end

function OnlineMallDlg:onGoodsButton(sender, eventType)
    if gf:isNullOrEmpty(self.goodsTable) then return end

    self.selectTag = sender:getTag()
    local goodsData = self.goodsTable[self.selectTag]

    -- 如果是时装，右侧显示的控件不同
    self:setCtrlVisible("EmptyPanel", false)
    self:setCtrlVisible("GoodsAttribInfoPanel", false)
    self:setCtrlVisible("FashionPanel", false)
    if self:isFashion(goodsData["name"]) then
        self:setCtrlVisible("FashionPanel", true)
    else
        self:setCtrlVisible("GoodsAttribInfoPanel", true)
    end

    local tempName = InventoryMgr:getParentName(goodsData["name"]) or goodsData["name"]
    self.shopLimit = InventoryMgr:isCanAddToBag(tempName, CONST_DATA.shopLimit, OnlineMallMgr.isUseGold and 0 or goodsData["coin"])

    if self.lastSelectTag  ~= self.selectTag or self.selectTag == nil then
        self.ShopGoodsNumber = 1
        self.clickButtonTime = 0
        self:addSelectImage(sender)
    else
        self:onAddButton()
    end

    self:setGoodsDescription()

    -- 是否需要显示:位列仙班才可购买提示
    self:setCtrlVisible("EligibilityNotePanel", goodsData["must_vip"] == 1)

    self:setShopPanel()
    self.lastSelectTag = self.selectTag
end

-- 商城点击减号按钮，参数longClick为判断是否长按的标志位
function OnlineMallDlg:onReduceButton(longClick)
    if lastClick ~= "reduceButton" then self.clickButtonTime = 0 end
    if not self.selectTag then return gf:ShowSmallTips(CHS[3003169]) end
    if self.selectTag then
        if self.ShopGoodsNumber <= 1 then
            gf:ShowSmallTips(CHS[6000034])
        else
            self.ShopGoodsNumber = self.ShopGoodsNumber - 1
            if longClick then
                self.clickButtonTime = -1
            else
                self.clickButtonTime = self.clickButtonTime + 1
                if self.clickButtonTime == 3 then
                    gf:ShowSmallTips(CHS[3003173])
                end
            end
        end
        self:setShopPanel()
        lastClick = "reduceButton"
    end
end

-- 商城点击加号按钮，参数longClick为判断是否长按的标志位
function OnlineMallDlg:onAddButton(longClick)
    if lastClick ~= "addButton" then self.clickButtonTime = 0 end
    if not self.selectTag then return gf:ShowSmallTips(CHS[3003169]) end

    if self:isQuotaItem(self.selectTag) and not self:isCanBuyQuotaItemByNum(self.ShopGoodsNumber + 1, self.selectTag) then -- 超过配额
        return
    elseif self.ShopGoodsNumber >= self.shopLimit then
        if self.shopLimit == CONST_DATA.shopLimit then
            gf:ShowSmallTips(CHS[6000035])
        else
            gf:ShowSmallTips(CHS[6000150])
        end
    else
        self.ShopGoodsNumber = self.ShopGoodsNumber + 1
        if longClick then
            self.clickButtonTime = -1
        else
            self.clickButtonTime = self.clickButtonTime + 1
            if self.clickButtonTime == 3 then
                gf:ShowSmallTips(CHS[3003173])
            end
        end
    end
    self:setShopPanel()
    lastClick = "addButton"
end

function OnlineMallDlg:onTotalValueButton(sender, eventType)
end

function OnlineMallDlg:onSupplyPanel(sender, eventType)
    DlgMgr:openDlg("OnlineMallRuleDlg")
    local panel = self:getControl("SupplyPanel", Const.UILabel, "CoinTypePanel")
    if panel then
        self:removeMagic(panel, Const.ARMATURE_MAGIC_TAG)
    end
end

function OnlineMallDlg:doBuyGoods(goodsData)
    if not goodsData then return end

    local totalMoney = 0
    local isGold = ""
    local coinType = ""
    if  goodsData["for_sale"] == CONST_DATA.goldCoin then
        totalMoney = Me:queryBasicInt("gold_coin")
        isGold = "gold_coin"
        coinType = CHS[3003176]
    elseif goodsData["for_sale"] == CONST_DATA.silverCoin then
        totalMoney = Me:getTotalCoin()
        coinType = CHS[3003177]
    end

    if self.radio:getSelectedState() and Me:queryBasicInt("gold_coin") < goodsData["coin"] then
        gf:askUserWhetherBuyCoin("gold_coin")
        return
    end

    if totalMoney < goodsData["coin"] * self.ShopGoodsNumber then
        gf:askUserWhetherBuyCoin(isGold)
    else
        -- (其中#RNum2#n个以金元宝替代)
        local showMessage = CHS[3003178]
        local showExtra = CHS[3003179]

        if not self.radio:getSelectedState() then
            if goodsData["for_sale"] ~= CONST_DATA.goldCoin then
                if Me:queryInt("silver_coin") >= goodsData["coin"] * self.ShopGoodsNumber then
                    showExtra = ""
                else
                    -- 银元宝如果未负，则计算消耗的金元时，银元宝用0计算
                    local realUseSilver = Me:queryInt("silver_coin")
                    if realUseSilver < 0 then realUseSilver = 0 end
                    showExtra = string.format(showExtra, (goodsData["coin"] * self.ShopGoodsNumber - realUseSilver))
                    coinType = CHS[3003177]
                end
            else
                showExtra = ""
                coinType = CHS[3003176]
            end
        else
                showExtra = ""
                coinType = CHS[3003176]
        end

        showMessage = string.format(showMessage,
            goodsData["coin"] * self.ShopGoodsNumber,
            coinType,
            showExtra,
            self.ShopGoodsNumber,
            InventoryMgr:getUnit(goodsData["name"]),
            goodsData["name"])

        --[[
        local showMessage = string.format(CHS[6000036], self.ShopGoodsNumber, InventoryMgr:getUnit(goodsData["name"]), goodsData["name"],
            goodsData["coin"] * self.ShopGoodsNumber)
            --]]

        local data = {}
        data["barcode"] = goodsData["barcode"]
        data["amount"] = self.ShopGoodsNumber
        data["coin_pwd"] = ""
        if self.radio:getSelectedState() then
            data["coin_type"] = "gold_coin"
        else
            data["coin_type"] = ""
        end

        -- 安全锁判断
        if self:checkSafeLockRelease("doBuyGoods", goodsData) then
            return
        end

        local meLevel = Me:queryBasicInt("level")
        local itemUseLevel = InventoryMgr:getItemInfoByNameAndField(goodsData.name, "use_level")
        if itemUseLevel and itemUseLevel > meLevel then
            -- 使用等级确认
            gf:confirm(string.format(CHS[5420010], string.format(CHS[5420011], itemUseLevel)), function()
                -- 购买确认
                gf:confirm(showMessage, function()
                    OnlineMallMgr:buyGoods(data)
                end)
            end)

            return
        end


        -- 时装需要根据性别，是否需要再次确认框
        if self:isFashion(goodsData.name) and Me:queryInt("gender") ~= InventoryMgr:getItemInfoByName(goodsData.name).gender then
            -- 购买确认
            gf:confirm(CHS[4100667], function()
                -- 购买确认
                gf:confirm(showMessage, function()
                    OnlineMallMgr:buyGoods(data)
                end)
                return
            end)

            return
        else
            -- 购买确认
            gf:confirm(showMessage, function()
                OnlineMallMgr:buyGoods(data)
            end)
        end
    end
end

-- 购买道具
function OnlineMallDlg:onBuyButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if gf:isNullOrEmpty(self.goodsTable) then return end

    lastClick = "buyButton"
    if self.ShopGoodsNumber < 1 then
        gf:ShowSmallTips(CHS[3003175])
        return
    end

    if not self.selectTag then return gf:ShowSmallTips(CHS[3003169]) end

    local goodsData = self.goodsTable[self.selectTag]

    if self:isQuotaItem(self.selectTag) and goodsData["discountTime"] < gf:getServerTime() then
            gf:ShowSmallTips(CHS[6000231])
            OnlineMallMgr:openOnlineMall()
            return
    end

    if not Me:isVip() and goodsData["must_vip"] == 1 then
            gf:ShowSmallTips(CHS[6000230])
            return
        end

    if self.ShopGoodsNumber > self.shopLimit then
        gf:ShowSmallTips(CHS[5420009])
        return
    end

    if self:isQuotaItem(self.selectTag) and not self:isCanBuyQuotaItemByNum(self.ShopGoodsNumber, self.selectTag) then
        return
    end

    -- 如果有幸运折扣券，进入折扣券界面
    if self.hasDiscountCoupon and self:canUseDiscount(goodsData) then
        local dlg = DlgMgr:openDlg("DiscountDlg")
        dlg:setData(goodsData, self.ShopGoodsNumber)
        return
    end

    self:doBuyGoods(goodsData)
end

function OnlineMallDlg:onSelectPharmacyListView(sender, eventType)
end

-- 商城数据回来刷新
function OnlineMallDlg:initData()
    self.ShopGoodsNumber = 0  -- 道具默认购买数量是1

    if 1 == self.curSelectType then
        self.goodsTable = OnlineMallMgr:getRecommandMallList()
    elseif 2 == self.curSelectType then
        self.goodsTable = OnlineMallMgr:getPromoteMallList()
    elseif 3 == self.curSelectType then
        self.goodsTable = OnlineMallMgr:getPracticeMallList()
    elseif 4 == self.curSelectType then
        self.goodsTable = OnlineMallMgr:getOtherMallList()
    end

    if not gf:isNullOrEmpty(self.goodsTable) then
        local goodsData = self.goodsTable[1]
        local tempName = InventoryMgr:getParentName(goodsData["name"]) or goodsData["name"]-- 时装为  xxx·n天
        self.shopLimit = InventoryMgr:isCanAddToBag(tempName, CONST_DATA.shopLimit, OnlineMallMgr.isUseGold and 0 or goodsData["coin"])
    else
        self.shopLimit = 0
    end

    -- 设置金钱信息
    self:MSG_UPDATE()

    -- 到道具列表
    self:initScroviewData()

    -- 初值化当前道具
   -- self:setGoodsDescription()
   -- self:setShopPanel()
end

-- 初值滚动框数据
function OnlineMallDlg:initScroviewData()
    local scrollViewPanel = self:getControl("PharmacyPanel", Const.UIPanel)
    scrollViewPanel:removeAllChildren()
    scrollViewPanel:setTouchEnabled(false)

    -- scrollViewPanel:removeAllChildren() 会析构 selcetImage 对象，故需要清空
    self.selcetImage = nil

    local container = ccui.Layout:create()
    container:setPosition(0,0)
    self.scrollview = ccui.ScrollView:create()
    self.scrollview:setContentSize(scrollViewPanel:getContentSize())
    self.scrollview:setDirection(ccui.ScrollViewDir.vertical)
    self.scrollview:setTouchEnabled(true)
    self.scrollview:setBounceEnabled(true)
    self.scrollview:addChild(container, 0, TAG_TEAM)
    scrollViewPanel:addChild(self.scrollview)

    local number = self.goodsTable and #self.goodsTable or 0
    local line = math.floor(number / CONST_DATA.columnNumber) + 1
    local left = number % CONST_DATA.columnNumber
    local innerSizeheight = 0

    if left == 0 then
        innerSizeheight = (line - 1) * (self.goodsCellPanel:getContentSize().height + CONST_DATA.lineSapce)
    else
        innerSizeheight = line * (self.goodsCellPanel:getContentSize().height + CONST_DATA.lineSapce)
    end

    if innerSizeheight < self.scrollview:getContentSize().height then
        innerSizeheight = self.scrollview:getContentSize().height
    end

    for i = 1 , line do
        local cloumnNumber = 0
        if i == line then
            cloumnNumber = left
        else
            cloumnNumber = CONST_DATA.columnNumber
        end
        for j = 1 , cloumnNumber do
            local tag = (i - 1)*CONST_DATA.columnNumber + j
            local goodsCell = self.goodsCellPanel:clone()
            goodsCell:setTag(tag)
            goodsCell:setAnchorPoint(0,1)
            local pox = (self.goodsCellPanel:getContentSize().width + CONST_DATA.columnSpace) * (j - 1)
            local poy = innerSizeheight - (self.goodsCellPanel:getContentSize().height + CONST_DATA.lineSapce) * (i - 1)

            --将其向右移动规定像素
            pox = CONST_DATA.marginLeft + pox
            goodsCell:setPosition(pox, poy)
            container:addChild(goodsCell)
            self:setGoodsData(goodsCell, tag)
            goodsCell:setTag(tag)

            -- 选中上一次选中的物品
            if self.lastSelectTag and tag == self.lastSelectTag then
                self.ShopGoodsNumber = 1
                self.selectTag = self.lastSelectTag
                self:addSelectImage(goodsCell)
                self:setGoodsDescription()
                self:setShopPanel()
            end
        end
    end

    container:setContentSize(self.goodsCellPanel:getContentSize().width, innerSizeheight)
    local innerContent = container:getContentSize()
    local contentSize = self.scrollview:getContentSize()
    contentSize.height = contentSize.height - CONST_DATA.marginTop
    contentSize.width = contentSize.width + CONST_DATA.marginLeft * 2
    self.scrollview:setContentSize(contentSize)
    self.scrollview:setInnerContainerSize(container:getContentSize())
end

-- 设置每个物品信息
function OnlineMallDlg:setGoodsData(goodsCell, tag)
    if gf:isNullOrEmpty(self.goodsTable) then return end
    local goodsData = self.goodsTable[tag]

    -- 道具图片
    local goodsImage = self:getControl("GoodsImage", Const.UIImage, goodsCell)
    local imgPath = InventoryMgr:getIconFileByName(goodsData.name)
    goodsImage:loadTexture(imgPath)
    self:setItemImageSize("GoodsImage", goodsCell)

    -- 道具名字
    local nameLabel = self:getControl("GoodsNameLabel", Const.UILabel, goodsCell)
    nameLabel:setString(goodsData["name"])

    -- 道具元宝
    local moneyImage = self:getControl("MoneyImage", Const.UIImage, goodsCell)
    moneyImage:loadTexture(COIN_IMAGE[goodsData["for_sale"]], ccui.TextureResType.plistType)

    -- 道具价格
    local goodPrice = gf:getArtFontMoneyDesc(goodsData["coin"])
    self:setNumImgForPanel("MoneyNumberPanel", ART_FONT_COLOR.DEFAULT, goodPrice, false, LOCATE_POSITION.LEFT_BOTTOM, 21, goodsCell)
    self:updateLayout("MoneyNumberPanel", goodsCell)

    -- 限购标签
    if goodsData["sale_quota"] ~= -1 then
        self:setQuotaItemInfo(goodsData, goodsCell)
    end

    -- 限制交易logo
    if goodsData["is_gift"] == 1 then
        InventoryMgr:addLogoBinding(goodsImage)
    else
        InventoryMgr:removeLogoBinding(goodsImage)
    end

    -- 移除不再使用的控件
    -- 道具标签
    --local tipLabel = self:getControl("TabLabel11", Const.UILabel, goodsCell)
    --tipLabel:setString(RECOMMEND[goodsData["recommend"]])
    -- 应策划要求暂不显示推荐信息
    --self:setCtrlVisible('TipImage', false, goodsCell)
end

function OnlineMallDlg:setQuotaItemInfo(data, cell)
    -- 显示标签
    self:setCtrlVisible("TipImage", true, cell)

    -- 时间
    local leftTime = data["discountTime"] - gf:getServerTime()

    self:setCtrlVisible("RefreshTimePanel", true, cell)
    self:setLabelText("RefreshTimeLabel", self:getTimeStr(leftTime), cell)

    -- 折扣
    if data["discount"] < 100 and data["discount"] > 0 then
        self:setCtrlVisible("DiscountPanel", true, cell)
        self:setLabelText("DiscountLabel", data["discount"] / 10, cell)
    end

    -- 数量
    local goodsImage = self:getControl("GoodsImage", Const.UIImage, cell)
    if data["sale_quota"] == 0 then
        self:setNumImgForPanel("LimitNumPanel", ART_FONT_COLOR.RED, data["sale_quota"], false, LOCATE_POSITION.RIGHT_BOTTOM, 21, cell)
        gf:grayImageView(goodsImage)
    else
        self:setNumImgForPanel("LimitNumPanel", ART_FONT_COLOR.NORMAL_TEXT, data["sale_quota"], false, LOCATE_POSITION.RIGHT_BOTTOM, 21, cell)
        gf:resetImageView(goodsImage)
    end

    --self:updateLayout("GoodsBackImage", cell)
end


function OnlineMallDlg:getTimeStr(leftTime)
    if leftTime < 0 then leftTime = 60 end

    local str = ""
    local days = math.floor(leftTime / (3600 * 24))
    local ours = math.floor((leftTime - days * 3600 * 24) / 3600)
    local min = ""

    if days >= 1 then
        str = days .. CHS[6000229]
    elseif ours >= 1 then
        str = str .. ours..CHS[3002942]
    else
        local min = math.floor((leftTime - days * 3600 * 24) / 60)
        if min < 1 then
            min = 1
        end

        str = str .. min..CHS[3002943]
    end

    return str
end

-- 是否可以使用折扣券
function OnlineMallDlg:canUseDiscount(goodsData)
    if not goodsData or 1 == goodsData.type then return false end
    local isTestDist = DistMgr:curIsTestDist()
    return isTestDist or OnlineMallMgr.isUseGold
end

function OnlineMallDlg:isFashion(name)
    local itemInfo = InventoryMgr:getItemInfoByName(name)
    if itemInfo and itemInfo.item_class == ITEM_CLASS.FASHION then
        return true
    end
end

function OnlineMallDlg:getFashionOffect(icon)
    local y = FASHION_OFF_Y
    if FASHION_OFFECT[icon] then
        y = y + FASHION_OFFECT[icon].y
    end

    return cc.p(0, y)
end

-- 设置选中道具描述信息
function OnlineMallDlg:setGoodsDescription()
    if gf:isNullOrEmpty(self.goodsTable) then return end
    local item = self.goodsTable[self.selectTag]
    local descriptStr = ""

    local listCtrl = self:getControl("GoodsAttribInfoListView")
    if listCtrl.selectTag and listCtrl.selectTag == self.selectTag then return end
    listCtrl.selectTag = self.selectTag

    -- 时装的listView不一样
    if self:isFashion(item.name) then
        listCtrl = self:getControl("GoodsAttribInfoListView", nil, "FashionPanel")
        self.dir = 5

        -- 时装还要显示形象
        local shapePanel = self:getControl("UserPanel")
        shapePanel:removeAllChildren()
        shapePanel:stopAllActions()

        local icon = InventoryMgr:getFashionShapeIcon(item.name)
        local pos = self:getFashionOffect(icon)
        self:setPortrait("UserPanel", icon, nil, nil, nil, nil, nil, pos, nil, nil, nil)
        self:setPortrait("UserPanel", ResMgr:getFollowSprite(icon, item.follow_pet_type), 0, nil, nil, nil, nil, FOLLOW_SPRITE_OFFPOS[5], 0, nil, nil, Dialog.TAG_PORTRAIT1, true)
        self:displayPlayActions()

        self:setLabelText("TitleLabel", item.name, "FashionShapePanel")
    end

    -- 名字
    local NamePanel = self.namePanel:clone()
    local nameLable = self:getControl("GoodsNameLabel", nil, NamePanel)
    nameLable:setString(item["name"])

    --  描述、使用等级
    local itemUseLevel = InventoryMgr:getItemInfoByNameAndField(item.name, "use_level")
    local useLevelStr = CHS[5420013] .. CHS[5420012]
    if itemUseLevel then
        useLevelStr = CHS[5420013] .. string.format(CHS[5420011], itemUseLevel)
    end

    local desPanel = self.descPanel:clone()
    desPanel:removeAllChildren()
    local desText = CGAColorTextList:create()
    desText:setFontSize(19)
    desText:setString(InventoryMgr:getDescript(item["name"]) .. "\n" .. useLevelStr)
    desText:setContentSize(desPanel:getContentSize().width, 0)
    desText:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    desText:updateNow()
    local labelW, labelH = desText:getRealSize()
    desText:setPosition(0, labelH)
    desPanel:addChild(tolua.cast(desText, "cc.LayerColor"))
    desPanel:setContentSize(desPanel:getContentSize().width, labelH)

    listCtrl:removeAllItems()
    listCtrl:setInnerContainerSize(0,0)
    listCtrl:pushBackCustomItem(NamePanel)
    listCtrl:pushBackCustomItem(desPanel)
    listCtrl:getInnerContainer():setContentSize(listCtrl:getContentSize().width, NamePanel:getContentSize().height + desPanel:getContentSize().height)

    if listCtrl:getInnerContainer():getContentSize().height < listCtrl:getContentSize().height then
        listCtrl:setEnabled(false)
    else
        listCtrl:getInnerContainer():setPositionY(listCtrl:getContentSize().height - listCtrl:getInnerContainer():getContentSize().height)
        listCtrl:setEnabled(true)
    end

    self:updateLayout("GoodsAttribInfoListView")
end

-- 定时做相关动作，时装需要循环做动作
function OnlineMallDlg:displayPlayActions()
    local shapePanel = self:getControl("UserPanel")
    local charNow = shapePanel:getChildByTag(Dialog.TAG_PORTRAIT)
    local pos = self:getFashionOffect(charNow.icon or 0)

    Dialog.displayPlayActions(self, "UserPanel", nil, pos.y)
end

-- 刷新金钱
function OnlineMallDlg:MSG_UPDATE()
    local meSiliverStr = gf:getArtFontMoneyDesc(Me:queryBasicInt("silver_coin"))
    self:setNumImgForPanel("SilverValuePanel", ART_FONT_COLOR.DEFAULT, meSiliverStr, false, LOCATE_POSITION.CENTER, 21)
    local meGoldStr = gf:getArtFontMoneyDesc(Me:queryBasicInt("gold_coin"))
    self:setNumImgForPanel("GoldValuePanel", ART_FONT_COLOR.DEFAULT, meGoldStr, false, LOCATE_POSITION.CENTER, 21)
    self:updateLayout("SilverValuePanel")
    self:updateLayout("GoldValuePanel")
end

-- 购买物品信息
function OnlineMallDlg:setShopPanel(refreshShopLimit)
    if not self.selectTag then self:refreshGoldIcon() return end
    if gf:isNullOrEmpty(self.goodsTable) then return end
    local goodsData = self.goodsTable[self.selectTag]

    if refreshShopLimit then
        local tempName = InventoryMgr:getParentName(goodsData["name"]) or goodsData["name"]
        self.shopLimit = InventoryMgr:isCanAddToBag(tempName, CONST_DATA.shopLimit, OnlineMallMgr.isUseGold and 0 or goodsData["coin"])
        self.ShopGoodsNumber = math.min(self.ShopGoodsNumber, self.shopLimit)
    end

    -- 购买道具数量
    local numberImage = self:getControl("NumberValueImage")
    local numberLabel = self:getControl("NumberLabel", Const.UILabel, numberImage)
    numberLabel:setString(self.ShopGoodsNumber)
    local numberLabel1 = self:getControl("NumberLabel_1", Const.UILabel, numberImage)
    numberLabel1:setString(self.ShopGoodsNumber)

    -- 购买道具总价

    local buyButton = self:getControl("BuyButton")
    local totalPrice = self.ShopGoodsNumber * goodsData["coin"]
    local totalNumberLabel = self:getControl("NumLabel", Const.UILabel, buyButton)
    totalNumberLabel:setString(totalPrice)
    local totalNumberLabel1 = self:getControl("NumLabel_1", Const.UILabel, buyButton)
    totalNumberLabel1:setString(totalPrice)

   --[[ local layout = self:getControl("TotalPriceValuePanel", Const.UIPanel)
    layout:requestDoLayout()  ]]

    -- 替换元宝图片
    local buyButton = self:getControl("BuyButton")
    local cashImage = self:getControl("SilverImage", Const.UIImage, buyButton)
    if OnlineMallMgr.isUseGold then
        cashImage:loadTexture(COIN_IMAGE[1], ccui.TextureResType.plistType)
    else
        cashImage:loadTexture(COIN_IMAGE[goodsData["for_sale"]], ccui.TextureResType.plistType)
    end

    -- 非折扣、非礼包
    if self.hasDiscountCoupon then
        self:setCtrlVisible("DiscountImage", self:canUseDiscount(goodsData), buyButton)
    else
        self:setCtrlVisible("DiscountImage", false, buyButton)
    end
end

function OnlineMallDlg:refreshGoldIcon()
    local buyButton = self:getControl("BuyButton")
    local cashImage = self:getControl("SilverImage", Const.UIImage, buyButton)
    if OnlineMallMgr.isUseGold then
        cashImage:loadTexture(COIN_IMAGE[1], ccui.TextureResType.plistType)
    else
        cashImage:loadTexture(COIN_IMAGE[2], ccui.TextureResType.plistType)
    end
end

function OnlineMallDlg:requireOnlineMallInfo()
    OnlineMallMgr:openOnlineMall()
end


function OnlineMallDlg:blindPress(name)
    local widget = self:getControl(name,nil,self.root)

    if not widget then
        Log:W("Dialog:bindListViewListener no control " .. name)
        return
    end
    -- longClick为长按的标志位
    local function updataCount(longClick)
        if self.touchStatus == TOUCH_BEGAN  then
            if self.clickBtn == "AddButton" then
                self:onAddButton(longClick)
            elseif self.clickBtn == "ReduceButton" then
                self:onReduceButton(longClick)
            end
        elseif self.touchStatus == TOUCH_END then

        end
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.clickBtn = sender:getName()
            self.touchStatus = TOUCH_BEGAN
            schedule(widget , function() updataCount(true) end, 0.1)
        elseif eventType == ccui.TouchEventType.moved then
        else
            updataCount()
            self.touchStatus = TOUCH_END
            widget:stopAllActions()
        end
    end

    widget:addTouchEventListener(listener)
end

function OnlineMallDlg:addSelectImage(sender)
    if self.selcetImage  then
        self.selcetImage:removeFromParent()
        self.selcetImage = nil
    end

    self.selcetImage = self.selectImagePattern:clone()
    self.selcetImage:setPosition(sender:getContentSize().width / 2, sender:getContentSize().height / 2)
    self.selcetImage:setAnchorPoint(0.5, 0.5)
    self.selcetImage:setVisible(true)
    sender:addChild(self.selcetImage)
end

function OnlineMallDlg:refreshItemData(barcode)
    -- 更新一下数据
    if 1 == self.curSelectType then
        self.goodsTable = OnlineMallMgr:getRecommandMallList()
    elseif 2 == self.curSelectType then
        self.goodsTable = OnlineMallMgr:getPromoteMallList()
    elseif 3 == self.curSelectType then
        self.goodsTable = OnlineMallMgr:getPracticeMallList()
    elseif 4 == self.curSelectType then
        self.goodsTable = OnlineMallMgr:getOtherMallList()
    end

    -- 获取当前要更新项的位置
    local tag
    for i = 1, #self.goodsTable do
        local goodsData = self.goodsTable[i]
        if barcode == goodsData["barcode"] then
            tag = i
        end
    end

    if not tag then return end  -- 可能切换分页了，当前分页没有改道具了

    local itemLayer = self.scrollview:getChildByTag(TAG_TEAM)
    local item = itemLayer:getChildByTag(tag)

    -- 更新该项
    self:setGoodsData(item, tag)
end

function OnlineMallDlg:cleanup()
    self:releaseCloneCtrl("goodsCellPanel")
    self:releaseCloneCtrl("selectImagePattern")
    self:releaseCloneCtrl("namePanel")
    self:releaseCloneCtrl("descPanel")

    self.selectTag = nil
    self.selcetImage = nil
    self.radio = nil

    lastCloseTime = gf:getServerTime()

    EventDispatcher:removeEventListener("doOpenDlgRequestData", self.onOpenDlgRequestData, self)
end

function OnlineMallDlg:onOpenDlgRequestData(sender, eventType)
    -- 请求商城数据
    OnlineMallMgr:openOnlineMall()
end

function OnlineMallDlg:onDlgOpened(items)
    if not items then return end
    local isSelect = false
    local itemName, index = next(items)
    if not itemName or itemName == "" then
        if index then
            -- 选中某标签页
            self.group:selectRadio(index)
        end

        return
    end

    if InventoryMgr:getItemInfoByName(itemName).item_class == ITEM_CLASS.FASHION then
        -- 时装的 thirdClass特殊
        if InventoryMgr:getRecourseItem() and InventoryMgr:getRecourseItem().fasion_type == FASION_TYPE.FASION then
            local days = tonumber(string.match(InventoryMgr:getRecourseItem().alias, CHS[4100656]))
            if days then
                if days <= 30 then
                    days = 30
                else
                    days = 90
                end

                itemName = itemName .. "·" .. days .. CHS[6000229]
            else
                -- 永久
                itemName = InventoryMgr:getRecourseItem().alias
            end

            items[itemName] = index
        end
    end

    local selectItem = OnlineMallMgr:getMallItemForRes(itemName)
    if not selectItem then return end
    local itemType = selectItem.type
    if 1 == itemType or (3 == selectItem.recommend and not ActivityMgr:isInLimitPurchase()) then
        self.group:selectRadio(1)
    elseif 2 == itemType then
        self.group:selectRadio(2)
    elseif 3 == itemType then
        self.group:selectRadio(3)
    elseif 4 == itemType then
        self.group:selectRadio(4)
    end

    local num = self.goodsTable and #self.goodsTable or 0
    for i = 1, num do
        local goods = self.goodsTable[i]
        if items[goods.name] and not isSelect then
            isSelect = true
            local height = math.floor((i - 1)/ 2) * self.goodsCellPanel:getContentSize().height
            local off = self.scrollview:getContentSize().height - self.scrollview:getInnerContainer():getContentSize().height + height
            if off > 0 then off = 0 end
            self.scrollview:getInnerContainer():setPositionY(off)

            local itemLayer = self.scrollview:getChildByTag(TAG_TEAM)
            local panel = itemLayer:getChildByTag(i)
            --local btn = self:getControl("GoodsButton", nil, panel)
            self:onGoodsButton(panel)
        end
    end

    InventoryMgr:setRecourseItem()
end

function OnlineMallDlg:MSG_INVENTORY()
    local tag = self.selectTag or 1
    local goodsData
    if not gf:isNullOrEmpty(self.goodsTable) then
        local goodsData = self.goodsTable[tag]
        local tempName = InventoryMgr:getParentName(goodsData["name"]) or goodsData["name"] -- 时装为  xxx·n天
        self.shopLimit = InventoryMgr:isCanAddToBag(tempName, CONST_DATA.shopLimit, OnlineMallMgr.isUseGold and 0 or goodsData["coin"])
    else
        self.shopLimit = 0
    end

    self.hasDiscountCoupon = InventoryMgr:hasDiscountCoupon()

    -- 非折扣、非礼包
    if self.hasDiscountCoupon then
        self:setCtrlVisible("DiscountImage", self:canUseDiscount(goodsData), "BuyButton")
    else
        self:setCtrlVisible("DiscountImage", false, "BuyButton")
    end
end
--[[
--  绑定数字键盘
function OnlineMallDlg:bindNumInput(ctrlName)
    local panel = self:getControl(ctrlName)
    local function openNumIuputDlg()

        local rect = self:getBoundingBoxInWorldSpace(panel)
        local dlg = DlgMgr:openDlg("SmallNumInputDlg")
        dlg:setObj(self)
        dlg.root:setPosition(rect.x + rect.width /2 , rect.y  + rect.height +  dlg.root:getContentSize().height /2 - 10)
    end
    self:bindListener(ctrlName, openNumIuputDlg)
end
]]

-- 数字键盘插入数字
function OnlineMallDlg:insertNumber(num)
    if gf:isNullOrEmpty(self.goodsTable) then return end

    self.ShopGoodsNumber = num

    if self.ShopGoodsNumber < 0 then
        --gf:ShowSmallTips(CHS[6000034])
        self.ShopGoodsNumber = 0
    end


    -- 限购道具
    local goodsData = self.goodsTable[self.selectTag]
    if self:isQuotaItem(self.selectTag) and not self:isCanBuyQuotaItemByNum(num, self.selectTag) then
        self.ShopGoodsNumber = math.max(goodsData.sale_quota, 0)
    else
        if num > self.shopLimit then
            if self.shopLimit == CONST_DATA.shopLimit then
                gf:ShowSmallTips(CHS[6000035])
            else
                gf:ShowSmallTips(CHS[6000150])
            end

            self.ShopGoodsNumber = math.max(self.shopLimit, 0)
        end
    end


    self:setShopPanel()

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(self.ShopGoodsNumber)
    end
end

function OnlineMallDlg:isQuotaItem(tag)
    if gf:isNullOrEmpty(self.goodsTable) then return end

    local goodsData = self.goodsTable[tag]

    if goodsData.sale_quota ~= -1 then
        return true
    end
end

function OnlineMallDlg:isCanBuyQuotaItemByNum(num, tag)
    if gf:isNullOrEmpty(self.goodsTable) then return false end
    local goodsData = self.goodsTable[tag]

    local discountTime = goodsData["discountTime"]
    local soldOutTip = CHS[7000209]
    local hasQuotaTip = CHS[7000208]

    if goodsData.sale_quota == 0 then
        gf:ShowSmallTips(string.format(soldOutTip, goodsData.quota_limit or 0))
        return false
    else
        if num > goodsData.sale_quota then
            gf:ShowSmallTips(string.format(hasQuotaTip, goodsData.quota_limit or 0,goodsData.sale_quota))
            return false
        else
            return true
        end
    end
end

function OnlineMallDlg:onSelected(sender, eventType)
    local senderName = sender:getName()
    if "CheckBox_1" == senderName then
        self.curSelectType = 1
    elseif "CheckBox_2" == senderName then
        self.curSelectType = 2
    elseif "CheckBox_3" == senderName then
        self.curSelectType = 3
    elseif "CheckBox_4" == senderName then
        self.curSelectType = 4
    end

    -- 记录当前选择的页面
    lastSelectTab = self.group:getSelectedRadioIndex()

    self.ShopGoodsNumber = 0
    self:setShopPanel()
    self.lastSelectTag = nil
    self.selectTag = nil
    self:getControl("EmptyPanel"):setVisible(true)
    self:getControl("GoodsAttribInfoPanel"):setVisible(false)
    self:setCtrlVisible("FashionPanel", false)

    local listCtrl = self:getControl("GoodsAttribInfoListView")
    listCtrl.selectTag = nil

        -- 请求商城信息
    if #OnlineMallMgr:getOnlineMallList() == 0 then
        OnlineMallMgr:openOnlineMall()
    else
        self:initData()
    end
end

function OnlineMallDlg:MSG_ACTIVITY_LIST(data)
    local isInLimitOpen = ActivityMgr:isInLimitPurchase()

    -- 限时特惠活动期间，“推荐商品”需要替换为“限时特惠”
    if isInLimitOpen then
            self:setLabelText("TextLabel", CHS[7003073], "CheckBox_1")
        else
            self:setLabelText("TextLabel", CHS[7003074], "CheckBox_1")
        end

    local activityTime = ActivityMgr:getActivityStartTimeByMainType("discount_coupon")
    if activityTime then
        local curTime = gf:getServerTime()
        local startTime = activityTime["startTime"]

        if curTime < startTime then return end
        local endTime = activityTime["endTime"]
        local key = string.format("discount_coupon_%s", Me:queryBasic("gid"))
        local curStoreTime = cc.UserDefault:getInstance():getIntegerForKey(key)
        if endTime > curStoreTime then
            local panel = self:getControl("SupplyPanel", Const.UILabel, "CoinTypePanel")
            if panel then
                self:removeMagic(panel, Const.ARMATURE_MAGIC_TAG)
                gf:createArmatureMagic(ResMgr.ArmatureMagic.mall_discount, panel, Const.ARMATURE_MAGIC_TAG, 20, -1)
            end

            cc.UserDefault:getInstance():setIntegerForKey(key, endTime)
            cc.UserDefault:getInstance():flush()
        end
    end

    -- 如果当前显示特惠活动状态变化了，需要刷新商城列表
    if isInLimitOpen ~= self.isLimitPurchaseOpen then
        self.isLimitPurchaseOpen = isInLimitOpen
        gf:CmdToServer("CMD_OPEN_ONLINE_MALL", {name = Me:queryBasic("name")})
        return
    end

    self:initData()
end

function OnlineMallDlg:onRightButton()
    if not self.selectTag or not self.goodsTable then
        return
    end

    local goodsData = self.goodsTable[self.selectTag]
    self.dir = self.dir + 2
    if self.dir > 7 then
        self.dir = 1
    end

    local shapePanel = self:getControl("UserPanel")
    shapePanel:removeAllChildren()
    shapePanel:stopAllActions()

    local icon = InventoryMgr:getFashionShapeIcon(goodsData["name"])
    local pos = self:getFashionOffect(icon)
    self:setPortrait("UserPanel", icon, nil, nil, nil, nil, nil, pos, nil, nil, self.dir)
    self:setPortrait("UserPanel", ResMgr:getFollowSprite(icon, goodsData.follow_pet_type), 0, nil, nil, nil, nil, FOLLOW_SPRITE_OFFPOS[self.dir], 0, nil, self.dir, Dialog.TAG_PORTRAIT1, true)
    self:displayPlayActions()
end


function OnlineMallDlg:onLeftButton()
    if not self.selectTag or not self.goodsTable then
        return
    end

    local goodsData = self.goodsTable[self.selectTag]
    self.dir = self.dir - 2
    if self.dir < 0 then
        self.dir = 7
    end

    local shapePanel = self:getControl("UserPanel")
    shapePanel:removeAllChildren()
    shapePanel:stopAllActions()

    local icon = InventoryMgr:getFashionShapeIcon(goodsData["name"])
    local pos = self:getFashionOffect(icon)
    self:setPortrait("UserPanel", icon, nil, nil, nil, nil, nil, pos, nil, nil, self.dir)
    self:setPortrait("UserPanel", ResMgr:getFollowSprite(icon, goodsData.follow_pet_type), 0, nil, nil, nil, nil, FOLLOW_SPRITE_OFFPOS[self.dir], 0, nil, self.dir, Dialog.TAG_PORTRAIT1, true)
    self:displayPlayActions()
end

return OnlineMallDlg
