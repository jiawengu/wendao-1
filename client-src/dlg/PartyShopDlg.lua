-- PartyShopDlg.lua
-- Created by songcw Mar/10/2015
-- 帮贡商店界面

local PartyShopDlg = Singleton("PartyShopDlg", Dialog)
local shopLimit = 100

function PartyShopDlg:init()
    self:bindListener("GoodsButton", self.onGoodsButton)
    self:bindListener("GoodsButton1", self.onGoodsButton1)
    self:bindListener("NumberButton", self.onNumberButton)
    self:bindListener("TotalValueButton", self.onTotalValueButton)
    self:bindListener("HaveButton", self.onHaveButton)
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("RefreshButton", self.onRefreshButton)
    self:bindListViewListener("PharmacyListView", self.onSelectPharmacyListView)
    self:bindPressForIntervalCallback('ReduceButton', 0.1, self.onSubOrAddNum, 'times')
    self:bindPressForIntervalCallback('AddButton', 0.1, self.onSubOrAddNum, 'times')

    -- 绑定数字键盘
    self:bindNumInput("NumberValuePanel", nil, self.onlimitNumInput)

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

    -- 设置拥有的帮贡
    self:setHavePanel()
    self:setCost()

    self:hookMsg("MSG_REFRESH_PARTY_SHOP", PartyShopDlg)
    self:hookMsg("MSG_UPDATE", PartyShopDlg)

    self.shopLimit = shopLimit
end

function PartyShopDlg:cleanup()
    self:releaseCloneCtrl("goodsPanel")
end

function PartyShopDlg:onGoodsButton(sender, eventType)
end

function PartyShopDlg:onGoodsButton1(sender, eventType)
end

function PartyShopDlg:onNumberButton(sender, eventType)
end

function PartyShopDlg:onReduceButton(sender, eventType)
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

    --[[local pricePanel = self:getControl("TotalValuePanel")
    local costStr = gf:getMoneyDesc(self.goods[self.pickGoods].cost * (num - 1), true)
    self:setLabelText("TotalValueLabel_1", costStr, pricePanel)
    self:setLabelText("TotalValueLabel_2", costStr, pricePanel)]]

    self:refreshTotalValuePanel(self.goods[self.pickGoods].cost * (num - 1))
end

function PartyShopDlg:onAddButton(sender, eventType)
    if not self.pickGoods then
        if self.needShowSubOrAddTips then
            gf:ShowSmallTips(CHS[3003269])
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

    if num + 1 > self.goods[self.pickGoods].num then
        -- 配额不足，无法增加！
        if self.needShowSubOrAddTips then
            gf:ShowSmallTips(CHS[3003270])
            self.needShowSubOrAddTips = nil
        end

        return
    end

    if (num + 1) * self.goods[self.pickGoods].cost > Me:queryInt("party/contrib") then
        gf:ShowSmallTips(CHS[4200407])

        return
    end

    self:setLabelText("NumberValueLabel", num + 1, countPanel)

   --[[ local pricePanel = self:getControl("TotalValuePanel")
    local costStr = gf:getMoneyDesc(self.goods[self.pickGoods].cost * (num + 1), true)
    self:setLabelText("TotalValueLabel_1", costStr, pricePanel)
    self:setLabelText("TotalValueLabel_2", costStr, pricePanel)]]

    self:refreshTotalValuePanel(self.goods[self.pickGoods].cost * (num + 1))
end

function PartyShopDlg:refreshTotalValuePanel(totalValue)
    local pricePanel = self:getControl("TotalValuePanel")
    local costStr = gf:getMoneyDesc(totalValue, true)

    if totalValue > Me:queryInt("party/contrib") then
        self:setLabelText("TotalValueLabel_1", costStr, pricePanel, COLOR3.RED)
        self:setLabelText("TotalValueLabel_2", costStr, pricePanel)
    else
        self:setLabelText("TotalValueLabel_1", costStr, pricePanel, COLOR3.WHITE)
        self:setLabelText("TotalValueLabel_2", costStr, pricePanel)
    end
end

function PartyShopDlg:onSubOrAddNum(ctrlName, times)
    if times == 1 then
        self.needShowSubOrAddTips = true
    end

    if ctrlName == "AddButton" then
        self:onAddButton()
    elseif ctrlName == "ReduceButton" then
        self:onReduceButton()
    end
end


function PartyShopDlg:onTotalValueButton(sender, eventType)
end

function PartyShopDlg:onHaveButton(sender, eventType)
end

function PartyShopDlg:onBuyButton(sender, eventType)
    if not self.pickGoods then
        gf:ShowSmallTips(CHS[3003269])
        return
    end

    if Me:queryBasic("party/name") == "" then
        gf:ShowSmallTips(CHS[3003272])
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

    if Me:queryInt("party/contrib") < self.goods[self.pickGoods].cost then
        -- 帮贡不足，快去参加帮派活动为帮派做些贡献吧！
        gf:ShowSmallTips(CHS[4000211])
        return
    end

    PartyMgr:buyPartyShop(self.goods[self.pickGoods].name, num)
end

function PartyShopDlg:onRefreshButton(sender, eventType)
    local function refresh()
        -- 0获取当前配合，1花元宝刷新配额
        PartyMgr:refreshPartyShop(1)
    end

    -- 你确认要花费#R%d#n个元宝刷新商品配额吗？
    local tips = string.format(CHS[4000213], self.goods.costWing)
    gf:confirm(tips, refresh)
end

function PartyShopDlg:onSelectPharmacyListView(sender, eventType)
end

-- 商品重新刷新
function PartyShopDlg:setStore()
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
function PartyShopDlg:setStoreItemsNum()
    local storeGoodsPanel = self:getControl("PharmacyListView")
    local itemsPanel = storeGoodsPanel:getItems()
    for i,goodsPanel in pairs(itemsPanel) do
        local goodsPanel1 = self:getControl("GoodsPanel1", nil, goodsPanel)
        local goodsPanel2 = self:getControl("GoodsPanel2", nil, goodsPanel)

        self:setGoods(i * 2 - 1, goodsPanel1)
        self:setGoods(i * 2, goodsPanel2)
    end

    self:setCost()
end

function PartyShopDlg:chooseGoods(sender, eventType)
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


    self.shopLimit = InventoryMgr:isCanAddToBag(self.goods[self.pickGoods].name, shopLimit)
end

function PartyShopDlg:setGoods(index, panel)
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

    self:setLabelText("NumLabel", self.goods[index].num, panel)
    self:setLabelText("GoodsNameLabel", self.goods[index].name, panel)
    self:setLabelText("GoodsValueLabel", self.goods[index].cost, panel)

    if self.goods[index].num == 0 then
        self:setLabelText("LimitNumLabel", CHS[3003274] .. self.goods[index].num, panel, COLOR3.RED)
        self:setCtrlVisible("SoldoutImage", true, panel)
        gf:grayImageView(goodImage)

    else
        self:setLabelText("LimitNumLabel", CHS[3003274] .. self.goods[index].num, panel)
        self:setCtrlVisible("SoldoutImage", false, panel)
        gf:resetImageView(goodImage)
    end
end

function PartyShopDlg:setGoodsInfo()
    if not self.pickGoods then return end

    local introPanel = self:getControl("GoodsAttribInfoPanel")
    self:setLabelText("GoodsNameLabel", self.goods[self.pickGoods].name, introPanel)

    local desc = InventoryMgr:getDescript(self.goods[self.pickGoods].name)
    local funDesc = InventoryMgr:getFuncStr(self.goods[self.pickGoods])

    self:setColorText(desc, 'ItemDescPanel')
    self:updateLayout('ItemInfoPanel')
end

function PartyShopDlg:onDlgOpened(itemName)
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

function PartyShopDlg:setCost(isChosingDifferentGood)
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

-- 设置拥有的帮贡
function PartyShopDlg:setHavePanel()
    local ownPanel = self:getControl("HavePanel")
    --local contribStr = gf:getMoneyDesc(Me:queryInt("party/contrib"), true)
  --  self:setLabelText("HaveValueLabel", contribStr, ownPanel)]]

    local haveText = gf:getArtFontMoneyDesc(Me:queryInt("party/contrib"))
    self:setNumImgForPanel("HaveTextPanel", ART_FONT_COLOR.DEFAULT, haveText, haveText, LOCATE_POSITION.MID, 23, ownPanel)
end

function PartyShopDlg:MSG_REFRESH_PARTY_SHOP(data)
    if self.goods == nil then
        self.goods = data
        self:setStore()
        
        if PartyMgr.partyShopItem then
            self:onDlgOpened(PartyMgr.partyShopItem)
            PartyMgr:setPartyShopSelectItem()
        end
    else
        self.goods = data
        self:setStoreItemsNum()
    end
end

function PartyShopDlg:MSG_UPDATE(data)
    -- 设置拥有的帮贡
    self:setHavePanel()
end

--  限制弹出数字键盘
function PartyShopDlg:onlimitNumInput(ctrlName)
    if not self.pickGoods then
        gf:ShowSmallTips(CHS[3003275])
        return true
    end
end

-- 数字键盘插入数字
function PartyShopDlg:insertNumber(num)
    local countPanel = self:getControl("BuyNumberPanel")
    local shopNum = tonumber(self:getLabelText("NumberValueLabel", countPanel))
    shopNum = num

    if shopNum < 0 then
        shopNum = 0
    end

    -- 超过包裹上限
    local limit = math.min(self.shopLimit, self.goods[self.pickGoods].num)

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
        
        shopNum =  math.max(math.min(limit, math.floor(Me:queryInt("party/contrib") / self.goods[self.pickGoods].cost)), 0 )
    else
        if num * self.goods[self.pickGoods].cost > Me:queryInt("party/contrib") then
            gf:ShowSmallTips(CHS[4200407])
            shopNum = math.floor(Me:queryInt("party/contrib") / self.goods[self.pickGoods].cost)
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

return PartyShopDlg
