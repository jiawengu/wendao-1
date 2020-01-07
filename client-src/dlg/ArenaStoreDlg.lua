-- ArenaStoreDlg.lua
-- Created by zhengjh Mar/13/2015
-- 声望商店

local ArenaStoreDlg = Singleton("ArenaStoreDlg", Dialog)

local CONST_DATA =
{
    GoodListNunber = 21,
    ColumnNumber = 2,
    ColumnSpace = 5,
    LineSapce = 10,
    RefreshPrice = 100,
    DecriptionSapce = 20,
    shopLimit = 100,
}

local TOUCH_BEGAN  = 1
local TOUCH_END     = 2


function ArenaStoreDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("RefreshButton", self.onRefreshButton)

    -- 绑定数字键盘
    self:bindNumInput("NumberValuePanel")

    self.goodsCellPanel = self:getControl("GoodsPanel1", Const.UIPanel)
    self.goodsCellPanel:retain()

    self.selectImagePattern = self:getControl("ChosenEffectImage", Const.UIImage)
    self.selectImagePattern:retain()
    self.selectImagePattern:removeFromParent()

    self:hookMsg("MSG_ARENA_SHOP_ITEM_LIST")
    self:hookMsg("MSG_UPDATE")

    self:blindPress("ReduceButton")
    self:blindPress("AddButton")
    --ArenaMgr:openArenaStore()
    self.selectTag = 1        -- 默认选中第一个
    self.lastSelectTag = 1
    self.ShopGoodsNumber = 1
    self:setCtrlVisible("EmptyPanel", false)

    self:MSG_UPDATE()
    self:MSG_ARENA_SHOP_ITEM_LIST()
end

function ArenaStoreDlg:onGoodsButton(sender, eventType)
    self.selectTag = sender:getTag()
    local  item = self.itemList[self.selectTag]
    self.shopLimit = InventoryMgr:isCanAddToBag(item["name"], CONST_DATA.shopLimit)

    if self.lastSelectTag  ~= self.selectTag then
        self.ShopGoodsNumber = 1
        self:setGoodsDescription()
    else
        self:onAddButton()
    end

    self.lastSelectTag = self.selectTag
    self:setCtrlVisible("EmptyPanel", false)
    self:addSelectImage(sender)
end

function ArenaStoreDlg:addSelectImage(sender)
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

function ArenaStoreDlg:onBuyButton(sender, eventType)
    if self.ShopGoodsNumber < 1 then
        gf:ShowSmallTips(CHS[3002274])
        return
    end
    
   if tonumber(Me:queryBasic("reputation")) < self.itemList[self.selectTag]["price"] * self.ShopGoodsNumber then
        gf:ShowSmallTips(CHS[6000128])
    else
        ArenaMgr:buyItems(self.itemList[self.selectTag]["key"].."_"..(self.ShopGoodsNumber or 1))
    end
end

function ArenaStoreDlg:onRefreshButton(sender, eventType)
    gf:confirm(string.format(CHS[6000129], CONST_DATA.RefreshPrice), function()
        local coin = Me:queryBasicInt('gold_coin') + Me:queryBasicInt('silver_coin')
        if coin < CONST_DATA.RefreshPrice then
            gf:askUserWhetherBuyCoin()
        else
            ArenaMgr:refreshShopInfo()
        end
    end)
end

function ArenaStoreDlg:MSG_ARENA_SHOP_ITEM_LIST()
    -- 道具列表
    self:initScroviewData()

    -- 初值化当前道具
    self:setGoodsDescription()

    local  item = self.itemList[self.selectTag]
    self.shopLimit = InventoryMgr:isCanAddToBag(item["name"], CONST_DATA.shopLimit)


    -- 声望
   -- self:MSG_UPDATE()
end

-- 初值滚动框数据
function ArenaStoreDlg:initScroviewData()
    self.itemList = ArenaMgr:getShopList()
    local scrollViewPanel = self:getControl("GoodsPanel", Const.UIPanel)
    scrollViewPanel:removeAllChildren()
    self.selcetImage = nil
    self.container = ccui.Layout:create()
    self.container:setPosition(0,0)
    self.scrollview = ccui.ScrollView:create()
    self.scrollview:setContentSize(scrollViewPanel:getContentSize())
    self.scrollview:setDirection(ccui.ScrollViewDir.vertical)
    self.scrollview:addChild(self.container)
    scrollViewPanel:addChild(self.scrollview)

    local number = #self.itemList
    local line = math.floor(number / CONST_DATA.ColumnNumber) + 1
    local left = number % CONST_DATA.ColumnNumber
    local innerSizeheight  = 0

    if left == 0 then
        innerSizeheight = (line - 1) * (self.goodsCellPanel:getContentSize().height + CONST_DATA.LineSapce)
    else
        innerSizeheight = line * (self.goodsCellPanel:getContentSize().height + CONST_DATA.LineSapce)
    end

    if innerSizeheight < self.scrollview:getContentSize().height then
        innerSizeheight = self.scrollview:getContentSize().height
    end

    for i = 1 , line do
        local cloumnNumber = 0
        if i == line then
            cloumnNumber = left
        else
            cloumnNumber = CONST_DATA.ColumnNumber
        end
        for j = 1 , cloumnNumber do
            local tag = (i - 1)*CONST_DATA.ColumnNumber + j
            local goodsCell = self.goodsCellPanel:clone()
            goodsCell:setTag(tag)
            goodsCell:setAnchorPoint(0,1)
            local pox = (self.goodsCellPanel:getContentSize().width + CONST_DATA.ColumnSpace) * (j - 1)
            local poy = innerSizeheight - (self.goodsCellPanel:getContentSize().height + CONST_DATA.LineSapce) * (i - 1)
            goodsCell:setPosition(pox, poy)
            self.container:addChild(goodsCell)
            self:setGoodsData(goodsCell, tag)
           -- local goodsBtn = self:getControl("GoodsButton", Const.UIButton, goodsCell)
          --  goodsBtn:setTag(tag)

            if tag == self.selectTag then
                self:addSelectImage(goodsCell)
            end
        end
    end

    self.container:setContentSize(self.goodsCellPanel:getContentSize().width, innerSizeheight)
    self.scrollview:setInnerContainerSize(self.container:getContentSize())

    self.scrollview:scrollToBottom(0.04,false)
end

function ArenaStoreDlg:setGoodsData(goodsCell, tag)
    local item = self.itemList[tag]
    -- 商品图片
    local icon = InventoryMgr:getIconByName(item.name)
    self:setImage("GoodsImage", ResMgr:getItemIconPath(icon), goodsCell)
    self:setItemImageSize("GoodsImage", goodsCell)

 --[[   if item["isCanShop"] == 0 then      -- 不能购买
    local soldoutImage = self:getControl("SoldoutImage", Const.UIImage, goodsCell)
        soldoutImage:setVisible(true)
        gf:grayImageView(goodsImage)
    end]]

    -- 商品名字
    local goodsNameLabel = self:getControl("GoodsNameLabel", Const.UILabel, goodsCell)
    goodsNameLabel:setString(item.name)

    -- 价格
    --[[
    local goodsPriceLabel = self:getControl("GoodsValueLabel", Const.UILabel, goodsCell)
    goodsPriceLabel:setString(item["price"])
    --]]
    local cash, color = gf:getArtFontMoneyDesc(item["price"])
    self:setNumImgForPanel("PricePanel", ART_FONT_COLOR.NORMAL_TEXT, cash, false, LOCATE_POSITION.CENTER, 21, goodsCell)
    local function touchOnGoods(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onGoodsButton(sender, eventType)
        end
    end

    goodsCell:addTouchEventListener(touchOnGoods)
end

-- 设置选中道具描述信息
function ArenaStoreDlg:setGoodsDescription()
    local  item = self.itemList[self.selectTag]
    local infoPanel = self:getControl("GoodsAttribInfoPanel", Const.UIPanel)

    -- 名字
    local nameLabel = self:getControl("GoodsNameLabel", Const.UILabel, infoPanel)
    nameLabel:setString(item["name"])

    local descriptStr = ""

    --  描述
    descriptStr = descriptStr..InventoryMgr:getDescript(item["name"])

    local descPanel = self:getControl("ItemDescPanel", Const.UIPanel)
    descPanel:removeAllChildren()
    local lableText = CGAColorTextList:create()
    lableText:setFontSize(20)
    lableText:setString(descriptStr)
    lableText:setContentSize(descPanel:getContentSize().width, 0)
    lableText:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    lableText:updateNow()
    local labelW, labelH = lableText:getRealSize()
    lableText:setPosition(0, descPanel:getContentSize().height)
    descPanel:addChild(tolua.cast(lableText, "cc.LayerColor"))
    infoPanel:requestDoLayout()
    self:setShopPanel()
end

function ArenaStoreDlg:onDlgOpened(param)
    if self.container and self.container:getChildByTag(self.selectTag) then
        local panels = self.container:getChildren()
        for i = 1, #panels do
            if self:getLabelText("GoodsNameLabel", panels[i]) == param[1] then
                self:onGoodsButton(panels[i])
            end
        end
        
    end
end

function ArenaStoreDlg:MSG_UPDATE()
    -- 拥有的声望
    local haveLabel = self:getControl("HaveValueLabel", Const.UILabel)
    haveLabel:setString(Me:queryBasic("reputation"))
    
    if self.itemList then
        -- 购买物品后，重新刷新要消耗的声望数值的颜色
        self:setShopPanel()
    end
end

function ArenaStoreDlg:setShopPanel()
    local  item = self.itemList[self.selectTag]
    -- 购买道具数量
    local numberLabel = self:getControl("NumberValueLabel", Const.UILabel)
    numberLabel:setString(self.ShopGoodsNumber)

    -- 购买道具总价
    local totalCostStr = gf:getArtFontMoneyDesc(self.ShopGoodsNumber * item["price"])
    local priceLabel = self:getControl("TotalValueLabel", Const.UILabel)

    local fontColor = COLOR3.WHITE

    if Me:queryBasicInt("reputation") < self.ShopGoodsNumber * item["price"] then
        fontColor = COLOR3.RED
    end

    self:setLabelText("TotalValueLabel_1", self.ShopGoodsNumber * item["price"], nil, fontColor)
    self:setLabelText("TotalValueLabel_2", self.ShopGoodsNumber * item["price"], nil)

    self:updateLayout("TotalValuePanel")
end

function ArenaStoreDlg:onReduceButton()
    if self.selectTag then
        if self.ShopGoodsNumber <= 1 then
            gf:ShowSmallTips(CHS[6000034])
        else
            self.ShopGoodsNumber = self.ShopGoodsNumber - 1
        end

        self:setShopPanel()
    end
end

function ArenaStoreDlg:onAddButton()
    if not self.selectTag then return end
    local item = self.itemList[self.selectTag]
    if self.ShopGoodsNumber >= self.shopLimit then
        if self.shopLimit == CONST_DATA.shopLimit then
            gf:ShowSmallTips(CHS[6000035])
        else
            gf:ShowSmallTips(CHS[6000150])
        end
    else
        if Me:queryBasicInt("reputation") < item.price * (self.ShopGoodsNumber + 1) then
            gf:ShowSmallTips(CHS[4200406])
        else
            self.ShopGoodsNumber = self.ShopGoodsNumber + 1
        end        
    end

    self:setShopPanel()
end

function ArenaStoreDlg:blindPress(name)
    local widget = self:getControl(name, nil, self.root)

    if not widget then
        Log:W("Dialog:bindListViewListener no control " .. name)
        return
    end

    local function updataCount()
        if self.touchStatus == TOUCH_BEGAN  then
            if self.clickBtn == "AddButton" then

                if self.ShopGoodsNumber >= CONST_DATA.shopLimit then
                    widget:stopAllActions()
                end
                self:onAddButton()
            elseif self.clickBtn == "ReduceButton" then

                if self.ShopGoodsNumber <= 1 then
                    widget:stopAllActions()
                end
                self:onReduceButton()
            end
        elseif self.touchStatus == TOUCH_END then

        end
    end

    local begnTime = 0
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            begnTime = gfGetTickCount()
            self.clickBtn = sender:getName()
            self.touchStatus = TOUCH_BEGAN
            schedule(widget , updataCount, 0.1)
        elseif eventType == ccui.TouchEventType.moved then
        else
            updataCount()
            self.touchStatus = TOUCH_END
            widget:stopAllActions()
        end
    end

    widget:addTouchEventListener(listener)
end

function ArenaStoreDlg:cleanup()
    self:releaseCloneCtrl("goodsCellPanel")
    self:releaseCloneCtrl("selectImagePattern")
end

-- 数字键盘插入数字
function ArenaStoreDlg:insertNumber(num)
    self.ShopGoodsNumber = num

    if self.ShopGoodsNumber < 0 then
        self.ShopGoodsNumber = 0
    end

    if num > self.shopLimit then
        if self.shopLimit == CONST_DATA.shopLimit then
            gf:ShowSmallTips(CHS[6000035])
        else
            gf:ShowSmallTips(CHS[6000150])
        end
        
        self.ShopGoodsNumber = math.max(math.min(self.shopLimit, math.floor(Me:queryInt("reputation") / self.itemList[self.selectTag].price)), 0)
    else
        if Me:queryBasicInt("reputation") < self.itemList[self.selectTag].price * self.ShopGoodsNumber then
            gf:ShowSmallTips(CHS[4200406])
            self.ShopGoodsNumber =  math.floor(Me:queryInt("reputation") / self.itemList[self.selectTag].price)
        end

    end

    self:setShopPanel()

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(self.ShopGoodsNumber)
    end
end


return ArenaStoreDlg
