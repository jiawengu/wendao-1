-- LingchenShopDlg.lua
-- Created by huangzz Feb/02/2019
-- 灵尘点数商品界面

local LingchenShopDlg = Singleton("LingchenShopDlg", Dialog)
local shopLimit = 100

local ITEM_ORDER = {
    [CHS[3001147]] = 1, -- 超级仙风散
    [CHS[3001251]] = 2, -- 超级晶石
    [CHS[6200026]] = 3, -- 宠风散
    [CHS[3001500]] = 4, -- 宠物强化丹
    [CHS[3003329]] = 5, -- 超级神兽丹
    [CHS[7000277]] = 6, -- 紫气鸿蒙
    [CHS[4100994]] = 7, -- 羽化丹
    [CHS[3001103]] = 8, -- 超级绿水晶
    [CHS[3001102]] = 9, -- 黄水晶
    [CHS[3001104]] = 10, -- 超级圣水晶
    [CHS[3001101]] = 11, -- 超级粉水晶
    [CHS[4000383]] = 12, -- 点化丹
    [CHS[3001099]] = 13, -- 超级灵石
    [CHS[3001106]] = 14, -- 超级归元露
    [CHS[3001146]] = 15, -- 急急如律令
    [CHS[7190126]] = 16, -- 装备共鸣石
    [CHS[3001148]] = 17, -- 天神护佑
    [CHS[3001225]] = 18, -- 超级黑水晶
    [CHS[3001249]] = 19, -- 混沌玉
    [CHS[6000522]] = 20, -- 风灵丸
    [CHS[2000128]] = 21, -- 聚灵石
    [CHS[7000210]] = 22, -- 宠物顿悟丹
    [CHS[3001144]] = 23, -- 火眼金睛
    [CHS[5400662]] = 100, -- 灵尘宝盒
}

function LingchenShopDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindPressForIntervalCallback('ReduceButton', 0.1, self.onSubOrAddNum, 'times')
    self:bindPressForIntervalCallback('AddButton', 0.1, self.onSubOrAddNum, 'times')

    -- 绑定数字键盘
    self:bindNumInput("NumberValuePanel", nil, self.onlimitNumInput)

    self.pickGoods = nil
    self.goods = nil

    self:setLabelText("Label_1", CHS[5400800], "HaveValueLabel")

    -- 克隆
    local goodsPanel = self:getControl("GoodsPanel", Const.UIPanel)
    local goodsPanel1 = self:getControl("GoodsPanel1", Const.UIPanel, goodsPanel)
    local goodsPanel2 = self:getControl("GoodsPanel2", Const.UIPanel, goodsPanel)
    self:setCtrlVisible("ChosenImage", false, goodsPanel1)
    self:setCtrlVisible("ChosenImage", false, goodsPanel2)
    self:setCtrlVisible("SoldoutImage", false, goodsPanel1)
    self:setCtrlVisible("SoldoutImage", false, goodsPanel2)

    self.goodsPanel = self:retainCtrl("GoodsPanel")

    self:setCtrlVisible('EmptyPanel', true)
    self:setCtrlVisible('ItemInfoPanel', false)

    -- 设置拥有的灵尘
    self:setHavePanel()
    self:setCost()

    self:hookMsg("MSG_LINGCHEN_DATA")
    self:hookMsg("MSG_UPDATE")

    self.shopLimit = shopLimit
end

function LingchenShopDlg:cleanup()
end

function LingchenShopDlg:onReduceButton(sender, eventType)
    if not self.pickGoods then
        if self.needShowSubOrAddTips then
            gf:ShowSmallTips(CHS[3003269])
            self.needShowSubOrAddTips = nil
        end

        return
    end

    local countPanel = self:getControl("BuyNumberPanel")
    local num = tonumber(self:getLabelText("NumberValueLabel", countPanel)) - 1

    if num < 1 then
        -- 购买数量不能小于1
        if self.needShowSubOrAddTips then
            gf:ShowSmallTips(CHS[4000206])
            self.needShowSubOrAddTips = nil
        end

        return
    end

    self:setLabelText("NumberValueLabel", num, countPanel)

    self:refreshTotalValuePanel(self.goods[self.pickGoods].cost * num)
end

function LingchenShopDlg:onAddButton(sender, eventType)
    if not self.pickGoods then
        if self.needShowSubOrAddTips then
            gf:ShowSmallTips(CHS[3003269])
            self.needShowSubOrAddTips = nil
        end

        return
    end

    local countPanel = self:getControl("BuyNumberPanel")
    local num = tonumber(self:getLabelText("NumberValueLabel", countPanel)) + 1

    -- 若因配额不足，弹出不可选提示：
    if num > self.goods[self.pickGoods].num then
        -- 配额不足，无法购买！
        if self.needShowSubOrAddTips then
            gf:ShowSmallTips(CHS[3003270])
            self.needShowSubOrAddTips = nil
        end
        return
    end

    -- 若超过100个，弹出不可选提示：
    if num > self.shopLimit then
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

    -- 若购买数量超过Max(Min(玩家当前灵尘可购买该商品最大数量,Min(剩余配额, 100), 1)，则弹出不可选提示：
    if num * self.goods[self.pickGoods].cost > Me:queryInt("lingchen_point") then
        if self.needShowSubOrAddTips then
            gf:ShowSmallTips(CHS[5400798])
            self.needShowSubOrAddTips = nil
        end
        return
    end

    self:setLabelText("NumberValueLabel", num, countPanel)

    self:refreshTotalValuePanel(self.goods[self.pickGoods].cost * num)
end

function LingchenShopDlg:refreshTotalValuePanel(totalValue)
    local pricePanel = self:getControl("TotalValuePanel")
    local costStr = gf:getMoneyDesc(totalValue, true)

    if totalValue > Me:queryInt("lingchen_point") then
        self:setLabelText("TotalValueLabel_1", costStr, pricePanel, COLOR3.RED)
        self:setLabelText("TotalValueLabel_2", costStr, pricePanel)
    else
        self:setLabelText("TotalValueLabel_1", costStr, pricePanel, COLOR3.WHITE)
        self:setLabelText("TotalValueLabel_2", costStr, pricePanel)
    end
end

function LingchenShopDlg:onSubOrAddNum(ctrlName, times)
    if times == 1 then
        self.needShowSubOrAddTips = true
    end

    if ctrlName == "AddButton" then
        self:onAddButton()
    elseif ctrlName == "ReduceButton" then
        self:onReduceButton()
    end
end

function LingchenShopDlg:onBuyButton(sender, eventType)
    if not self.pickGoods then
        gf:ShowSmallTips(CHS[3003269])
        return
    end

    local countPanel = self:getControl("BuyNumberPanel")
    local num = tonumber(self:getLabelText("NumberValueLabel", countPanel))

    -- 若角色处于禁闭状态，则给予弹出提示
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 若该商品当前可购买数量为0，则弹出如下不可选提示
    if self.goods[self.pickGoods].num == 0 then
        gf:ShowSmallTips(CHS[5420131])
        return
    end

    -- 若购买数量<1，则弹出如下不可选提示
    if num < 1 then
        gf:ShowSmallTips(CHS[3003273])
        return
    end

    -- 若购买数量大于剩余配额数量，弹出提示
    if num > self.goods[self.pickGoods].num or self.goods[self.pickGoods].num == 0 then
        -- 配额不足，无法购买！
        gf:ShowSmallTips(CHS[3003270])
        return
    end

    -- 若灵尘不足，弹出提示
    if Me:queryInt("lingchen_point") < self.goods[self.pickGoods].cost * num then
        gf:ShowSmallTips(CHS[5400797])
        return
    end

    gf:CmdToServer("CMD_BUY_LINGCHEN_ITEM", {name = self.goods[self.pickGoods].name, num = num})
end

-- 商品重新刷新
function LingchenShopDlg:setStore()
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
        goodsPanel1:setTag(i)
        self:setGoods(i, goodsPanel1)
        self:bindTouchEndEventListener(goodsPanel1, self.chooseGoods)
        i = i + 1

        local goodsPanel2 = self:getControl("GoodsPanel2", nil, goodsPanel)

        if i <= self.goods.count then
            goodsPanel2:setTag(i)
            self:setGoods(i, goodsPanel2)
            self:bindTouchEndEventListener(goodsPanel2, self.chooseGoods)
            i = i + 1
        else
            goodsPanel2:setVisible(false)
        end

        storeGoodsPanel:pushBackCustomItem(goodsPanel)
    end
    
    -- 默认选择第一项
    if not self.pickGoods then
        local defaultItems = storeGoodsPanel:getItems(0)
        local defaultGoodsPanel = self:getControl("GoodsPanel1", nil, defaultItems)
        self:chooseGoods(defaultGoodsPanel)
    end
end

-- 只刷新商品数量
function LingchenShopDlg:setStoreItemsNum()
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

function LingchenShopDlg:chooseGoods(sender, eventType)
    self:setCtrlVisible('EmptyPanel', false)
    self:setCtrlVisible('ItemInfoPanel', true)

    -- 点击已选中的物品，数量加一
    local chosen = self:getControl("ChosenImage", nil, sender)
    local isChosen = chosen:isVisible()
    if isChosen then
        self.needShowSubOrAddTips = true
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

function LingchenShopDlg:setGoods(index, panel)
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

        if not self.pickGoods then
            self:chooseGoods(panel)
        end
    end
end

function LingchenShopDlg:setGoodsInfo()
    if not self.pickGoods then return end

    local introPanel = self:getControl("GoodsAttribInfoPanel")
    self:setLabelText("GoodsNameLabel", self.goods[self.pickGoods].name, introPanel)

    local desc = InventoryMgr:getDescript(self.goods[self.pickGoods].name)
    local funDesc = InventoryMgr:getFuncStr(self.goods[self.pickGoods])

    self:setColorText(desc, 'ItemDescPanel')
    self:updateLayout('ItemInfoPanel')
end

function LingchenShopDlg:onDlgOpened(itemName)
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

function LingchenShopDlg:setCost(isChosingDifferentGood)
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
end

-- 设置拥有的灵尘点数
function LingchenShopDlg:setHavePanel()
    local ownPanel = self:getControl("HavePanel")
    local haveText = gf:getArtFontMoneyDesc(Me:queryInt("lingchen_point"))
    self:setNumImgForPanel("HaveTextPanel", ART_FONT_COLOR.DEFAULT, haveText, haveText, LOCATE_POSITION.MID, 23, ownPanel)
end

function LingchenShopDlg:MSG_LINGCHEN_DATA(data)
    table.sort(data, function(l, r)
        if not ITEM_ORDER[l.name] or not ITEM_ORDER[r.name] then return l.name < r.name end

        if ITEM_ORDER[l.name] < ITEM_ORDER[r.name] then return true end
    
        return false
    end)

    if self.goods == nil then
        self.goods = data
        self:setStore()
    else
        self.goods = data
        self:setStoreItemsNum()
    end
end

function LingchenShopDlg:MSG_UPDATE(data)
    -- 设置拥有的帮贡
    self:setHavePanel()
end

--  限制弹出数字键盘
function LingchenShopDlg:onlimitNumInput()
    if not self.pickGoods then
        gf:ShowSmallTips(CHS[3003275])
        return true
    end
end

-- 数字键盘插入数字
function LingchenShopDlg:insertNumber(num)
    local countPanel = self:getControl("BuyNumberPanel")
    local shopNum = tonumber(self:getLabelText("NumberValueLabel", countPanel))
    shopNum = num

    if shopNum < 0 then
        shopNum = 0
    end

    -- 超过包裹上限
    local limit = math.min(self.shopLimit, self.goods[self.pickGoods].num)

    local tips = {
        {num = self.goods[self.pickGoods].num, tip = CHS[3003270]},
        {num = self.shopLimit, tip = self.shopLimit == shopLimit and CHS[6000035] or CHS[6000150]},
        {num = math.floor(Me:queryInt("lingchen_point") / self.goods[self.pickGoods].cost), tip = CHS[5400798]},
    }

    table.sort(tips, function(l, r)
        if l.num < r.num then
            return true
        end

        return false
    end)

    -- 防止键盘输入时，限制条件第一次与第二次的提示不一致
    if num > tips[1].num then
        gf:ShowSmallTips(tips[1].tip)
        shopNum = tips[1].num
    end

    --[[if num > limit then
        if num > self.goods[self.pickGoods].num then
            -- 配额不足，无法增加！
            gf:ShowSmallTips(CHS[3003270])
        else
            if self.shopLimit == shopLimit then
                gf:ShowSmallTips(CHS[6000035]) -- 超过上限
            else
                gf:ShowSmallTips(CHS[6000150]) -- 包裹不足
            end
        end
        
        shopNum =  math.max(math.min(limit, math.floor(Me:queryInt("lingchen_point") / self.goods[self.pickGoods].cost)), 0 )
    else
        if num * self.goods[self.pickGoods].cost > Me:queryInt("lingchen_point") then
            gf:ShowSmallTips(CHS[5400798])
            shopNum = math.floor(Me:queryInt("lingchen_point") / self.goods[self.pickGoods].cost)
        end
    end]]

    self:setLabelText("NumberValueLabel", shopNum, countPanel)
    self:refreshTotalValuePanel(self.goods[self.pickGoods].cost * (shopNum))

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(shopNum)
    end
end

return LingchenShopDlg