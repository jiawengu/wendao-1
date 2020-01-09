-- SpecialBuyDlg.lua
-- Created by sujl, Apr/5/2017
-- 特殊购买界面基类

local SpecialBuyDlg = Singleton("SpecialBuyDlg", Dialog)

local shopLimit = 100

function SpecialBuyDlg:init(data)
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindPressForIntervalCallback('ReduceButton', 0.1, self.onSubOrAddNum, 'times')
    self:bindPressForIntervalCallback('AddButton', 0.1, self.onSubOrAddNum, 'times')

    -- 绑定数字键盘
    self:bindNumInput("NumberValuePanel")

    self.pickGoods = nil
    self.goods = nil

    -- 克隆
    self.goodsPanel = self:getControl("GoodsPanel", Const.UIPanel)
    local goodsPanel1 = self:getControl("GoodsPanel1", Const.UIPanel, goodsPanel)
    local goodsPanel2 = self:getControl("GoodsPanel2", Const.UIPanel, goodsPanel)
    self:setCtrlVisible("ChosenImage", false, goodsPanel1)
    self:setCtrlVisible("ChosenImage", false, goodsPanel2)
    self.goodsPanel:retain()
    self:getControl("GoodsPanel"):removeFromParent()

    self:setCtrlVisible('EmptyPanel', true)
    self:setCtrlVisible('ItemInfoPanel', false)

    self.shopLimit = shopLimit
    self.clickNum = 0

    self:initData()
    
    if data then
        self:setInfo(data)
    end
end

function SpecialBuyDlg:setInfo(data)
    self.goods = data.items
    self.goods.count = data.count
    self:setStore()
end

function SpecialBuyDlg:cleanup()
    self:releaseCloneCtrl("goodsPanel")
end

function SpecialBuyDlg:onReduceButton(sender, eventType)
    if not self.pickGoods then
        if self.needShowSubOrAddTips then
            gf:ShowSmallTips(CHS[3002730])
            self.needShowSubOrAddTips = nil
        end

        return
    end

    local countPanel = self:getControl("BuyNumberPanel")
    local num = tonumber(self:getLabelText("NumberValueLabel", countPanel))

    if num - 1 < 1 then
        -- 购买数量不能小于1
        if self.needShowSubOrAddTips then
            gf:ShowSmallTips(CHS[4000206])
            self.needShowSubOrAddTips = nil
        end

        return
    end

    if self.clickNum == 4 then
        gf:ShowSmallTips(CHS[3002731])
    end

    self:setLabelText("NumberValueLabel", num - 1, countPanel)
    self:refreshTotalValuePanel(self.goods[self.pickGoods].price * (num - 1))
end

function SpecialBuyDlg:onAddButton(sender, eventType)
    if not self.pickGoods then
        if self.needShowSubOrAddTips then
            gf:ShowSmallTips(CHS[3002730])
            self.needShowSubOrAddTips = nil
        end

        return
    end

    local countPanel = self:getControl("BuyNumberPanel")
    local num = tonumber(self:getLabelText("NumberValueLabel", countPanel))

    if num + 1 > self.shopLimit then
        -- 单次购买已达上限。
        if self.needShowSubOrAddTips then
            if self.shopLimit == shopLimit then
                gf:ShowSmallTips(CHS[6000035])
            else
                gf:ShowSmallTips(CHS[6000150])
            end
            self.needShowSubOrAddTips = nil
        end

        return
    end

    if self.clickNum == 3 then
        gf:ShowSmallTips(CHS[3002731])
    end

    self:setLabelText("NumberValueLabel", num + 1, countPanel)
    self:refreshTotalValuePanel(self.goods[self.pickGoods].price * (num + 1))
end

function SpecialBuyDlg:onSubOrAddNum(ctrlName, times)
    if times == 1 then
        self.needShowSubOrAddTips = true
        self.clickNum = self.clickNum  + 1  -- 点击次数，不包括长按
    elseif self.clickNum < 4 then
        self.clickNum = 0
    end

    if ctrlName == "AddButton" then
        self:onAddButton()
    elseif ctrlName == "ReduceButton" then
        self:onReduceButton()
    end

end

function SpecialBuyDlg:onBuyButton(sender, eventType)

    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3002732])
        return
    end

    if not self.pickGoods then
        gf:ShowSmallTips(CHS[3002730])
        return
    end

    local countPanel = self:getControl("BuyNumberPanel")
    local num = tonumber(self:getLabelText("NumberValueLabel", countPanel))

    if num < 1 then
        gf:ShowSmallTips(CHS[3002733])
        return
    end

    self:doBuy(num)
end

-- 商品重新刷新
function SpecialBuyDlg:setStore()
    local storeGoodsPanel = self:resetListView("PharmacyListView", 8)

    local count = 1

    if self.goods.count % 2 == 0 then
        count = self.goods.count / 2
    else
        count = math.floor(self.goods.count / 2) + 1
    end

    local i = 1
    while i <= count do
        local goodsPanel = self.goodsPanel:clone()
        local goodsPanel1 = self:getControl("GoodsPanel1", nil, goodsPanel)
        self:setGoods(i * 2 - 1, goodsPanel1)
        goodsPanel1:setTag(i * 2 - 1)
        self:bindTouchEndEventListener(goodsPanel1, self.chooseGoods)

        local goodsPanel2 = self:getControl("GoodsPanel2", nil, goodsPanel)

        if i * 2 <= self.goods.count then
            self:setGoods(i * 2, goodsPanel2)
            goodsPanel2:setTag(i * 2)
            self:bindTouchEndEventListener(goodsPanel2, self.chooseGoods)
        else
            goodsPanel2:setVisible(false)
        end

        i = i + 1

        storeGoodsPanel:pushBackCustomItem(goodsPanel)
    end
end

function SpecialBuyDlg:chooseGoods(sender, eventType)
    self:setCtrlVisible('EmptyPanel', false)
    self:setCtrlVisible('ItemInfoPanel', true)

    -- 点击已选中的物品，数量加一
    local chosen = self:getControl("ChosenImage", nil, sender)
    local isChosen = chosen:isVisible()
    if isChosen then
        self.clickNum = self.clickNum  + 1
        self:onAddButton()
        return
    end

    local storeGoodsPanel = self:getControl("PharmacyListView")
    local itemsPanel = storeGoodsPanel:getItems()
    for _,goodsPanel in pairs(itemsPanel) do
        local goodsPanel1 = self:getControl("GoodsPanel1", nil, goodsPanel)
        local goodsPanel2 = self:getControl("GoodsPanel2", nil, goodsPanel)

        self:setCtrlVisible("ChosenImage", false, goodsPanel1)
        self:setCtrlVisible("ChosenImage", false, goodsPanel2)
    end

    self:setCtrlVisible("ChosenImage", true, sender)

    self.pickGoods = sender:getTag()
    self:setGoodsInfo()
    self:setCost()
    self.clickNum = 0

    self.shopLimit = InventoryMgr:isCanAddToBag(self.goods[self.pickGoods].name, shopLimit)
end

function SpecialBuyDlg:setGoods(index, panel)
    if not self.goods[index] then
        return
    end

    --self:setImage("GoodsImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(self.goods[index].name)), panel)
    local goodImagePanel = self:getControl("GoodsImagePanel", Const.UIPanel, panel)
    local goodImage = ccui.ImageView:create(ResMgr:getItemIconPath(InventoryMgr:getIconByName(self.goods[index].name)))
    goodImage:setPosition(goodImagePanel:getContentSize().width / 2, goodImagePanel:getContentSize().height / 2)
    goodImage:setAnchorPoint(0.5, 0.5)
    gf:setItemImageSize(goodImage)

    goodImagePanel:removeAllChildren()
    goodImagePanel:addChild(goodImage)

    self:setLabelText("GoodsNameLabel", self.goods[index].name, panel)
    self:setLabelText("GoodsValueLabel", self.goods[index].price, panel)
end

function SpecialBuyDlg:setGoodsInfo()
    if not self.pickGoods then return end

    local introPanel = self:getControl("GoodsAttribInfoPanel")
    self:setLabelText("GoodsNameLabel", self.goods[self.pickGoods].name, introPanel)

    local desc = InventoryMgr:getDescript(self.goods[self.pickGoods].name)
    local funDesc = InventoryMgr:getFuncStr(self.goods[self.pickGoods])

    self:setColorText(desc, 'ItemDescPanel')
    self:updateLayout('ItemInfoPanel')
end

function SpecialBuyDlg:setCost()
    local countPanel = self:getControl("BuyNumberPanel")
    local pricePanel = self:getControl("TotalValuePanel")

    if not self.pickGoods then
        self:setLabelText("NumberValueLabel", "0", countPanel)
        self:refreshTotalValuePanel(0)
        return
    end

    if self.goods[self.pickGoods].num == 0 then
        self:setLabelText("NumberValueLabel", 0, countPanel)
    else
        self:setLabelText("NumberValueLabel", 1, countPanel)
    end

    self:refreshTotalValuePanel(self.goods[self.pickGoods].price * tonumber(self:getLabelText("NumberValueLabel", countPanel)))
    --self:setLabelText("GoldLabel", self.goods.priceWing)
end

--  绑定数字键盘
function SpecialBuyDlg:bindNumInput(ctrlName)
    local panel = self:getControl(ctrlName)
    local function openNumIuputDlg()
        if not self.pickGoods then return gf:ShowSmallTips(CHS[3002736]) end
        local rect = self:getBoundingBoxInWorldSpace(panel)
        local dlg = DlgMgr:openDlg("SmallNumInputDlg")
        dlg:setObj(self)
        dlg.root:setPosition(rect.x + rect.width /2 , rect.y  + rect.height +  dlg.root:getContentSize().height /2 - 10)
    end
    self:bindListener(ctrlName, openNumIuputDlg)
end

-- 数字键盘插入数字
function SpecialBuyDlg:insertNumber(num)
    local countPanel = self:getControl("BuyNumberPanel")
    local shopNum = tonumber(self:getLabelText("NumberValueLabel", countPanel))
    shopNum = num

    if shopNum < 0 then
        shopNum = 0
    end

    -- 超过包裹上限
    local limit = self.shopLimit

    if num > limit then
        if self.shopLimit == shopLimit then
            gf:ShowSmallTips(CHS[6000035]) -- 超过上限
        else
            gf:ShowSmallTips(CHS[6000150]) -- 包裹不足
        end

        shopNum =  math.max(limit, 0)
    end

    self:setLabelText("NumberValueLabel", shopNum, countPanel)
    self:refreshTotalValuePanel(self.goods[self.pickGoods].price * (shopNum))

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(shopNum)
    end
end

return SpecialBuyDlg