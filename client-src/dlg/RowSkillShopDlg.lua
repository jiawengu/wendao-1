-- RowSkillShopDlg.lua
-- Created by songcw May/26/2015
-- 天技秘笈兑换界面

local RowSkillShopDlg = Singleton("RowSkillShopDlg", Dialog)

local TOUCH_BEGAN  = 1
local TOUCH_END    = 2

function RowSkillShopDlg:init()
    self:blindPress("AddButton")
    self:blindPress("ReduceButton")
    self:bindListener("AddCashButton", self.onAddCashButton)
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListViewListener("ItemListView", self.onSelectItemListView)

    -- 绑定数字键盘
    self:bindNumInput("NumberValuePanel")

    -- 克隆
    local goodsPanel = self:getControl("OneRowPanel", Const.UIPanel)
    self.goodsPanel = goodsPanel:clone()
    self.goodsPanel:retain()
    goodsPanel:removeFromParent()

    self.goodsInfo = nil
    self.count = 1
    self.shopLimit = 100

    local listViewCtrl = self:getControl("ItemListView")
    self:hookMsg("MSG_INVENTORY")   
end

function RowSkillShopDlg:onDlgOpened(param)
    -- param为nil代表第一次走进来的时候，数据未收到
    if not param then param = self.param end
    
    -- 如果第二次走进来，没有记录需要选择，则不处理
    if not param then return end
    local sellListView = self:getControl("ItemListView")
    local items = sellListView:getItems()
    for i = 1, #items do
        local leftPanel = self:getControl("ItemPanel_1", Const.UIPanel, items[i])
        local rightPanel = self:getControl("ItemPanel_2", Const.UIPanel, items[i])
        
        if self.goodsInfo and self.goodsInfo.items and self.goodsInfo.items[leftPanel:getTag()] and self.goodsInfo.items[leftPanel:getTag()].name == param[1] then
            self:chooseGoods(leftPanel)
            self.param = nil
            return
        end

        if self.goodsInfo and self.goodsInfo.items and self.goodsInfo.items[rightPanel:getTag()] and self.goodsInfo.items[rightPanel:getTag()].name == param[1] then
            self:chooseGoods(rightPanel)
            self.param = nil
            return
        end
    end
    
    -- 会走到这说明数据未收到 self.goodsInfo == nil，记录需要打开的参数
    self.param = param
end

function RowSkillShopDlg:blindPress(name)
    local widget = self:getControl(name)

    if not widget then
        Log:W("Dialog:bindListViewListener no control " .. name)
        return
    end

    local function updataCount()
        if self.touchStatus == TOUCH_BEGAN  then
            if self.clickBtn == "AddButton" then
                self:onAddButton()
            elseif self.clickBtn == "ReduceButton" then
                self:onReduceButton()
            end
        elseif self.touchStatus == TOUCH_END then

        end
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
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

function RowSkillShopDlg:onReduceButton(sender, eventType)
    if self.count <= 1 then
        gf:ShowSmallTips(CHS[3003601])
        return
    end

    self.count = math.max(self.count - 1, 1)
    self:setCostInfo(self.pick)
end

function RowSkillShopDlg:onAddButton(sender, eventType)
    if self.count >= self.shopLimit then
        if self.shopLimit == 100 then
            gf:ShowSmallTips(CHS[6000035])
        else
            gf:ShowSmallTips(CHS[6000150])
        end
        return
    end

    self.count = math.min(self.count + 1, self.shopLimit)
    self:setCostInfo(self.pick)
end

function RowSkillShopDlg:cleanup()
    self:releaseCloneCtrl("goodsPanel")
end

function RowSkillShopDlg:updateSell(goodsInfo)
    self.goodsInfo = goodsInfo
    local sellListView = self:resetListView("ItemListView")
    local count = math.floor(goodsInfo.count / 2) + goodsInfo.count % 2

    for i = 1, count do
        local goodsPanel = self.goodsPanel:clone()
        -- 左边
        local leftPanel = self:getControl("ItemPanel_1", Const.UIPanel, goodsPanel)
        leftPanel:setTag(i * 2 - 1)
        self:setSingelGoodsPanel(goodsInfo.items[i * 2 - 1], leftPanel)

        -- 右边
        local rightPanel = self:getControl("ItemPanel_2", Const.UIPanel, goodsPanel)
        if i * 2 > goodsInfo.count then
            rightPanel:setVisible(false)
        else
            rightPanel:setTag(i * 2)
            self:setSingelGoodsPanel(goodsInfo.items[i * 2], rightPanel)
        end

        sellListView:pushBackCustomItem(goodsPanel)
    end

    self:chooseGoods()
end

function RowSkillShopDlg:setSingelGoodsPanel(goods, panel)

    self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(goods.name)), panel)
    self:setItemImageSize("ItemImage", panel)
    self:setLabelText("ItemLabel", goods.name, panel)

    local cash, color = gf:getArtFontMoneyDesc(goods.price)
    self:setNumImgForPanel("PricePanel", color, cash, false, LOCATE_POSITION.CENTER, 21, panel)
    self:bindTouchEndEventListener(panel, self.chooseGoods)
end

function RowSkillShopDlg:chooseGoods(sender, eventType)

    if sender and sender:getTag() == self.pick then
        if self.count < self.shopLimit then
            self.count = self.count + 1
            self:setCostInfo(self.pick)
        else
            gf:ShowSmallTips(CHS[3003602])
        end
        return
    end

    self.count = 1
    local sellListView = self:getControl("ItemListView")
    local itemsPanel = sellListView:getItems()
    for _,goodsPanel in pairs(itemsPanel) do
        local goodsPanel1 = self:getControl("ItemPanel_1", nil, goodsPanel)
        local goodsPanel2 = self:getControl("ItemPanel_2", nil, goodsPanel)

        self:setCtrlVisible("ChosenEffectImage", false, goodsPanel1)
        self:setCtrlVisible("ChosenEffectImage", false, goodsPanel2)

        sender = sender or goodsPanel1
    end

    self:setCtrlVisible("ChosenEffectImage", true, sender)
    if sender then
        self.pick = sender:getTag()
    else
        self.pick = 1
    end
    self:setItemInfo(self.pick)
    self:setCostInfo(self.pick)

    self.shopLimit = InventoryMgr:isCanAddToBag(self.goodsInfo.items[self.pick].name, 100)
end

function RowSkillShopDlg:setItemInfo(pick)
    local itemPanel = self:getControl("ItemInfoPanel")
    -- 名称
    self:setLabelText("NameLabel", self.goodsInfo.items[pick].name, itemPanel)

    -- 描述
    local desStr = InventoryMgr:getDescript(self.goodsInfo.items[pick].name)
    self:setLabelText("DescLabel", desStr, itemPanel)

    itemPanel:requestDoLayout()
end

function RowSkillShopDlg:setCostInfo(pick)
    self:setLabelText("NumberValueLabel", self.count)

    -- 价格
    local pricePanel = self:getControl("CostPanel")
    local totalPrice, totalPriceColor = gf:getArtFontMoneyDesc(self.goodsInfo.items[pick].price * self.count)
    --self:setNumImgForPanel("TotalPanel", totalPriceColor, totalPrice, false, LOCATE_POSITION.MID, 21, pricePanel)

    local cashPanel = self:getControl("OwnPanel")
    local meCount, meCountColor = gf:getArtFontMoneyDesc(InventoryMgr:getAmountByName(CHS[3003603]))
    self:setNumImgForPanel("HavePanel", meCountColor, meCount, false, LOCATE_POSITION.MID, 21, cashPanel)
    self:setLabelText("Label_1", totalPrice, "CostPanel")
    self:setLabelText("Label_2", totalPrice, "CostPanel")
end

-- 刷新金钱
function RowSkillShopDlg:MSG_INVENTORY()
    -- 拥有
    local cashPanel = self:getControl("OwnPanel")
    local meCount, meCountColor = gf:getArtFontMoneyDesc(InventoryMgr:getAmountByName(CHS[3003603]))
    self:setNumImgForPanel("HavePanel", meCountColor, meCount, false, LOCATE_POSITION.MID, 21, cashPanel)
end

function RowSkillShopDlg:onBuyButton(sender, eventType)
    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end    

    if self.count < 1 then
        gf:ShowSmallTips(CHS[3003601])
        return
    end
    
    if InventoryMgr:getAmountByName(CHS[3003603]) >= self.goodsInfo.items[self.pick].price then    
        gf:confirm(string.format(CHS[3003604], self.goodsInfo.items[self.pick].price * self.count, self.count, self.goodsInfo.items[self.pick].name), function()
            gf:CmdToServer("CMD_EXCHANGE_GOODS", {
                type = 0,
                name = self.goodsInfo.items[self.pick].name,
                amount = self.count,
            })
        end)
    else
    --    gf:askUserWhetherBuyItem({["天技秘笈残片"] = self.goodsInfo.items[self.pick].price})
        gf:ShowSmallTips(CHS[3003605])
    end
end

function RowSkillShopDlg:onAddCashButton(sender, eventType)
    gf:ShowSmallTips(CHS[3003606])
end

function RowSkillShopDlg:onSelectItemListView(sender, eventType)
end


-- 数字键盘插入数字
function RowSkillShopDlg:insertNumber(num)
    self.count = num

    if self.count < 0 then
        self.count = 0
    end

    if num > self.shopLimit then
        if self.shopLimit == 100 then
            gf:ShowSmallTips(CHS[6000035])
        else
            gf:ShowSmallTips(CHS[6000150])
        end

        self.count = math.max(self.shopLimit, 0)
    end

    self:setCostInfo(self.pick)

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(self.count)
    end
end

return RowSkillShopDlg
