-- ValueShopDlg.lua
-- Created by yangym May/23/2017
-- 稀有物品商店

local ValueShopDlg = Singleton("ValueShopDlg", Dialog)
local shopLimit = 100

function ValueShopDlg:init()
    self:bindListener("GoodsButton", self.onGoodsButton)
    self:bindListener("GoodsButton1", self.onGoodsButton1)
    self:bindListener("NumberButton", self.onNumberButton)
    self:bindListener("TotalValueButton", self.onTotalValueButton)
    self:bindListener("HaveButton", self.onHaveButton)
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListViewListener("PharmacyListView", self.onSelectPharmacyListView)
    self:bindPressForIntervalCallback('ReduceButton', 0.1, self.onSubOrAddNum, 'times')
    self:bindPressForIntervalCallback('AddButton', 0.1, self.onSubOrAddNum, 'times')

    -- 绑定数字键盘
    self:bindNumInput("NumberValuePanel")

    self.pickGoods = nil
    self.goods = nil

    -- 克隆
    local goodsPanel = self:getControl("GoodsPanel", Const.UIPanel)
    local goodsPanel1 = self:getControl("GoodsPanel1", Const.UIPanel, goodsPanel)
    local goodsPanel2 = self:getControl("GoodsPanel2", Const.UIPanel, goodsPanel)
    self:setCtrlVisible("ChosenImage", false, goodsPanel1)
    self:setCtrlVisible("ChosenImage", false, goodsPanel2)
    self:setCtrlVisible("SoldoutImage", false, goodsPanel1)
    self:setCtrlVisible("SoldoutImage", false, goodsPanel2)
    self.goodsPanel = goodsPanel:clone()
    self.goodsPanel:retain()
    self:getControl("GoodsPanel"):removeFromParent()

    self:setCtrlVisible('EmptyPanel', true)
    self:setCtrlVisible('ItemInfoPanel', false)

    self:setHavePanel()
    self:setCost()

    self:hookMsg("MSG_RARE_SHOP_ONE_ITEM_INFO", ValueShopDlg)
    self:hookMsg("MSG_RARE_SHOP_ITEMS_INFO", ValueShopDlg)
    self:hookMsg("MSG_UPDATE", ValueShopDlg)

    self.shopLimit = shopLimit
end

function ValueShopDlg:cleanup()
    self:releaseCloneCtrl("goodsPanel")
end

function ValueShopDlg:onGoodsButton(sender, eventType)
end

function ValueShopDlg:onGoodsButton1(sender, eventType)
end

function ValueShopDlg:onNumberButton(sender, eventType)
end

function ValueShopDlg:onReduceButton(sender, eventType)
    if not self.pickGoods then
        if self.needShowSubOrAddTips then
            gf:ShowSmallTips(CHS[3003269])
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

    self:setLabelText("NumberValueLabel", num - 1, countPanel)

    self:refreshTotalValuePanel(self.goods[self.pickGoods].cost * (num - 1))
end

function ValueShopDlg:onAddButton(sender, eventType)
    if not self.pickGoods then
        gf:ShowSmallTips(CHS[3003269])
        return
    end

    local countPanel = self:getControl("BuyNumberPanel")
    local num = tonumber(self:getLabelText("NumberValueLabel", countPanel))

    if num + 1 > self.shopLimit then
        -- 单次购买已达上限。
        if self.shopLimit == shopLimit then
            gf:ShowSmallTips(CHS[6000035])
        else
            gf:ShowSmallTips(CHS[6000150])
        end

        return
    end

    if num + 1 > self.goods[self.pickGoods].num then
        -- 配额不足，无法增加！
        gf:ShowSmallTips(CHS[3003270])
        return
    end

    if (num + 1) * self.goods[self.pickGoods].cost > Const.MAX_MONEY_IN_BAG then
        -- 总价超过背包可以有的最大金钱
        gf:ShowSmallTips(CHS[6000035])
        return
    end

    self:setLabelText("NumberValueLabel", num + 1, countPanel)
    self:refreshTotalValuePanel(self.goods[self.pickGoods].cost * (num + 1))
end

function ValueShopDlg:refreshTotalValuePanel(totalValue)
    -- 当前需要花费多少文钱
    local pricePanel = self:getControl("TotalValuePanel")
    local totalPrice, priceColor = gf:getArtFontMoneyDesc(totalValue)
    self:setNumImgForPanel("TotalValuePanelChild", priceColor, totalPrice, false, LOCATE_POSITION.MID, 21, pricePanel)
end

function ValueShopDlg:onSubOrAddNum(ctrlName, times)
    if times == 1 then
        self.needShowSubOrAddTips = true
    end

    if ctrlName == "AddButton" then
        self:onAddButton()
    elseif ctrlName == "ReduceButton" then
        self:onReduceButton()
    end
end


function ValueShopDlg:onTotalValueButton(sender, eventType)
end

function ValueShopDlg:onHaveButton(sender, eventType)
end

function ValueShopDlg:onBuyButton(sender, eventType)
    if not self.pickGoods then
        gf:ShowSmallTips(CHS[3003269])
        return
    end

    local countPanel = self:getControl("BuyNumberPanel")
    local num = tonumber(self:getLabelText("NumberValueLabel", countPanel))
    
    if self.goods[self.pickGoods].num == 0 then
        gf:ShowSmallTips(CHS[5420131])
        return
    end
    
    if num < 1 then
        gf:ShowSmallTips(CHS[3003273])
        return
    end

    if num > self.goods[self.pickGoods].num or self.goods[self.pickGoods].num == 0 then
        -- 配额不足，无法购买！
        gf:ShowSmallTips(CHS[3003270])
        return
    end
    
    local price = self.goods[self.pickGoods].cost * num
    local hasEnough = gf:checkCurMoneyEnough(price, function()
        gf:CmdToServer("CMD_REQUEST_BUY_RARE_ITEM", {barcode = self.goods[self.pickGoods].barcode, num = num})
    end)
    
    if not hasEnough then
        if nil == hasEnough then
            gf:askUserWhetherBuyCash(price - Me:queryInt("cash"))
        end

        return
    end
    
    gf:CmdToServer("CMD_REQUEST_BUY_RARE_ITEM", {barcode = self.goods[self.pickGoods].barcode, num = num})
end

function ValueShopDlg:onSelectPharmacyListView(sender, eventType)
end

-- 商品重新刷新
function ValueShopDlg:setStore()
    local storeGoodsPanel = self:resetListView("PharmacyListView")
    storeGoodsPanel:setItemsMargin(8)
    
    local count = 1

    if self.goods.count % 2 == 0 then
        count = self.goods.count / 2
    else
        count = math.floor(self.goods.count / 2) + 1
    end

    local i = 1
    while i <= self.goods.count do
        local goodsPanel = self.goodsPanel:clone()
        local goodsPanel1 = self:getControl("GoodsPanel1", nil, goodsPanel)
        self:setGoods(i, goodsPanel1)
        goodsPanel1:setTag(i)
        self:bindTouchEndEventListener(goodsPanel1, self.chooseGoods)
        i = i + 1

        local goodsPanel2 = self:getControl("GoodsPanel2", nil, goodsPanel)

        if i <= self.goods.count then
            self:setGoods(i, goodsPanel2)
            goodsPanel2:setTag(i)
            self:bindTouchEndEventListener(goodsPanel2, self.chooseGoods)
            i = i + 1
        else
            goodsPanel2:setVisible(false)
        end

        storeGoodsPanel:pushBackCustomItem(goodsPanel)
    end
    
    -- 默认选择第一项
    local defaultItems = storeGoodsPanel:getItems(0)
    local defaultGoodsPanel = self:getControl("GoodsPanel1", nil, defaultItems)
    self:chooseGoods(defaultGoodsPanel)
end

-- 只刷新商品数量
function ValueShopDlg:setStoreItemsNum()
    local storeGoodsPanel = self:getControl("PharmacyListView")
    local itemsPanel = storeGoodsPanel:getItems()
    for i,goodsPanel in pairs(itemsPanel) do
        local goodsPanel1 = self:getControl("GoodsPanel1", nil, goodsPanel)
        local goodsPanel2 = self:getControl("GoodsPanel2", nil, goodsPanel)

        self:setGoods(i * 2 - 1, goodsPanel1)
        self:setGoods(i * 2, goodsPanel2)
    end

    self:setCost()
    self:setLimitNum()
end

function ValueShopDlg:chooseGoods(sender, eventType)
    self:setCtrlVisible('EmptyPanel', false)
    self:setCtrlVisible('ItemInfoPanel', true)

    -- 点击已选中的物品，数量加一
    local chosen = self:getControl("ChosenImage", nil, sender)
    local isChosen = chosen:isVisible()
    if isChosen then
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
    self:setCost(true)
    self:setLimitNum()

    self.shopLimit = InventoryMgr:isCanAddToBag(self.goods[self.pickGoods].name, shopLimit)
end

function ValueShopDlg:setLimitNum()
    self:setLabelText("Label_72", string.format(CHS[7001052], self.goods[self.pickGoods].num), "BuyPanel")
end

function ValueShopDlg:setGoods(index, panel)
    if not self.goods[index] then
        return
    end

    local goodImagePanel = self:getControl("GoodsImagePanel", Const.UIPanel, panel)
    local goodImage = ccui.ImageView:create(ResMgr:getItemIconPath(InventoryMgr:getIconByName(self.goods[index].name)))
    goodImage:setPosition(goodImagePanel:getContentSize().width / 2, goodImagePanel:getContentSize().height / 2)
    goodImage:setAnchorPoint(0.5, 0.5)
    gf:setItemImageSize(goodImage)
    goodImagePanel:removeAllChildren()
    goodImagePanel:addChild(goodImage)

    self:setLabelText("NumLabel", self.goods[index].num, panel)
    self:setLabelText("GoodsNameLabel", self.goods[index].name, panel)
    local moneyText, moneyColor = gf:getArtFontMoneyDesc(self.goods[index].cost)
    self:setNumImgForPanel("GoodsValuePanel", moneyColor, moneyText, false, LOCATE_POSITION.LEFT_TOP, 23, panel)

    if self.goods[index].num == 0 then
        self:setCtrlVisible("SoldoutImage", true, panel)
        gf:grayImageView(goodImage)

    else
        self:setCtrlVisible("SoldoutImage", false, panel)
        gf:resetImageView(goodImage)
    end
end

function ValueShopDlg:setGoodsInfo()
    if not self.pickGoods then return end

    local introPanel = self:getControl("GoodsAttribInfoPanel")
    self:setLabelText("GoodsNameLabel", self.goods[self.pickGoods].name, introPanel)

    local desc = InventoryMgr:getDescript(self.goods[self.pickGoods].name)
    local funDesc = InventoryMgr:getFuncStr(self.goods[self.pickGoods])

    self:setColorText(desc, 'ItemDescPanel')
    self:updateLayout('ItemInfoPanel')
end

function ValueShopDlg:onDlgOpened(itemName)
    local listView = self:getControl("PharmacyListView")
    local items = listView:getItems()
    for i = 1, #items do
        local goodsPanel1 = self:getControl("GoodsPanel1", nil, items[i])
        local goodsPanel2 = self:getControl("GoodsPanel2", nil, items[i])
        
        if self.goods[goodsPanel1:getTag()] and self.goods[goodsPanel1:getTag()].name == itemName then
            self:chooseGoods(goodsPanel1)
            return
        end
        
        if self.goods[goodsPanel2:getTag()] and self.goods[goodsPanel2:getTag()].name == itemName then
            self:chooseGoods(goodsPanel2)
            return
        end
    end
end

function ValueShopDlg:setCost(isChosingDifferentGood)
    local countPanel = self:getControl("BuyNumberPanel")
    local pricePanel = self:getControl("TotalValuePanel")

    if not self.pickGoods then
        self:setLabelText("NumberValueLabel", "0", countPanel)
        self:refreshTotalValuePanel(0)
        return
    end

    local num = tonumber(self:getLabelText("NumberValueLabel", countPanel))
    if not num or num < 1 or isChosingDifferentGood then
        -- 选择不同商品时，重置为1
        num = 1
    end
    
    if self.goods[self.pickGoods].num < num then
        num = self.goods[self.pickGoods].num
    end
    
    self:setLabelText("NumberValueLabel", num, countPanel)
    self:refreshTotalValuePanel(self.goods[self.pickGoods].cost * num)
    self:setLabelText("GoldLabel", self.goods.costWing)
end

function ValueShopDlg:setHavePanel()
    local ownPanel = self:getControl("HavePanel")
    local haveText, color = gf:getArtFontMoneyDesc(Me:queryInt("cash"))
    self:setNumImgForPanel("HaveTextPanel", color, haveText, false, LOCATE_POSITION.MID, 23, ownPanel)
end

function ValueShopDlg:MSG_RARE_SHOP_ITEMS_INFO(data)
    if self.goods == nil then
        self.goods = data
        self:setStore()
    else
        self.goods = data
        self:setStoreItemsNum()
    end
end

function ValueShopDlg:MSG_RARE_SHOP_ONE_ITEM_INFO(data)
    for i = 1, #self.goods do
        if self.goods[i].barcode == data.barcode then
            self.goods[i].num = data.num
            self.goods[i].cost = data.cost
        end
    end
    
    self:setStoreItemsNum()
end

function ValueShopDlg:MSG_UPDATE(data)
    self:setHavePanel()
end

--  绑定数字键盘
function ValueShopDlg:bindNumInput(ctrlName)
    local panel = self:getControl(ctrlName)
    local function openNumIuputDlg()
        if not self.pickGoods then return gf:ShowSmallTips(CHS[3003275]) end
        local rect = self:getBoundingBoxInWorldSpace(panel)
        local dlg = DlgMgr:openDlg("SmallNumInputDlg")
        dlg:setObj(self)
        dlg.root:setPosition(rect.x + rect.width /2 , rect.y  + rect.height +  dlg.root:getContentSize().height /2 - 10)
    end
    self:bindListener(ctrlName, openNumIuputDlg)
end

-- 数字键盘插入数字
function ValueShopDlg:insertNumber(num)
    local countPanel = self:getControl("BuyNumberPanel")
    local shopNum = tonumber(self:getLabelText("NumberValueLabel", countPanel))
    shopNum = num

    if shopNum < 0 then
        shopNum = 0
    end

    -- 超过包裹上限
    local limit = math.min(self.shopLimit, self.goods[self.pickGoods].num)
    
    -- 总价超过背包可以有的最大金钱20亿
    local extraLimit = math.floor(Const.MAX_MONEY_IN_BAG / self.goods[self.pickGoods].cost)
    if extraLimit >= limit then
        -- “超过限额/包裹上限”的限制更大
        if num > limit then
            if self.shopLimit > self.goods[self.pickGoods].num then
                -- 配额不足，无法增加！
                gf:ShowSmallTips(CHS[3003270])
            else

                if self.shopLimit == shopLimit then
                   gf:ShowSmallTips(CHS[6000035]) -- 超过上限
                else
                    gf:ShowSmallTips(CHS[6000150]) -- 包裹不足
                end
            end

            shopNum =  math.max(limit, 0 )
        end
    else
        -- “总价超过背包可以有的最大金钱20亿”限制更大
        if self.goods[self.pickGoods].cost and
            (num * self.goods[self.pickGoods].cost > Const.MAX_MONEY_IN_BAG) then
            -- 总价超过背包可以有的最大金钱
            gf:ShowSmallTips(CHS[6000035])
            shopNum = math.max(extraLimit, 0)
        end 
    end
    
    self:setLabelText("NumberValueLabel", shopNum, countPanel)
    self:refreshTotalValuePanel(self.goods[self.pickGoods].cost * (shopNum))

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(shopNum)
    end
end

return ValueShopDlg
