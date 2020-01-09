-- WangZWStoreDlg.lua
-- Created by songcw May/19/2015
-- 王中王商店

local RadioGroup = require("ctrl/RadioGroup")
local WangZWStoreDlg = Singleton("WangZWStoreDlg", Dialog)

local TOUCH_BEGAN  = 1
local TOUCH_END    = 2

local FONTSIZE = 20

local shopLimit = 10

function WangZWStoreDlg:getCfgFileName()
    return ResMgr:getDlgCfg("GroceryStoreDlg")
end

function WangZWStoreDlg:init()
    self:blindPress("AddButton")
    self:blindPress("ReduceButton")
    self:bindListener("AddCashButton", self.onAddCashButton)
    self:bindListener("BuyButton", self.onBuyButton)
    
    -- 绑定数字键盘
    self:bindNumInput("NumberValuePanel")

    -- 金钱、代金券
    self:bindListener("CheckBox", function(dlg, sender, eventType) 
        self:onCashCheckBox()  
    end)

    -- 克隆
    local goodsPanel = self:getControl("GoodsPanel", Const.UIPanel)
    local leftPanel = self:getControl("GoodsPanel1", Const.UIPanel, goodsPanel)
    self:setCtrlVisible("ChosenImage", false, leftPanel)
    local rightPanel = self:getControl("GoodsPanel2", Const.UIPanel, goodsPanel)
    self:setCtrlVisible("ChosenImage", false, rightPanel)
    self.goodsPanel = goodsPanel:clone()
    self.goodsPanel:retain()
    goodsPanel:removeFromParent()
    local sellListView = self:getControl("GroceryStoreListView")
    sellListView:removeAllChildren()

    self.goodsInfo = nil
    self.pick = nil
    self.initItemName = nil
    self.shopLimit = shopLimit
    self:hookMsg("MSG_UPDATE")
    
    -- 若当前角色PK值大于0，则给出提示
    if Me:queryBasicInt("total_pk") > 0 then
        gf:ShowSmallTips(CHS[7000062])
    end
    
    -- json复用 GroceryStoreDlg，隐藏部分
    self:setCtrlVisible("Label", false, "BuyPanel")
    self:setCtrlVisible("CheckBox", false, "BuyPanel")
end

function WangZWStoreDlg:cleanup()
    if self.goodsPanel then
        self.goodsPanel:release()
        self.goodsPanel = nil
    end
    
    if not DistMgr:curIsTestDist() then
        gf:ShowSmallTips(CHS[4200212]) 
    end
end

function WangZWStoreDlg:blindPress(name)
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

function WangZWStoreDlg:updateSell(goodsInfo, selectName)

    selectName = selectName or self.initItemName
    self.goodsInfo = goodsInfo
    local sellListView = self:resetListView("GroceryStoreListView")
    local initSel = true

    local count = math.floor(goodsInfo.count / 2) + goodsInfo.count % 2
    for i = 1, count do
        local goodsPanel = self.goodsPanel:clone()
        local leftGoods = self:getControl("GoodsPanel1", Const.UIPanel, goodsPanel)
        leftGoods:setTag(i * 2 - 1)
        self:setSingelGoodsPanel(goodsInfo.items[i * 2 - 1], leftGoods)
        if selectName and goodsInfo.items[i * 2 - 1].name == selectName then
            self:chooseGoods(leftGoods)
            initSel = false
        end

        local rightGoods = self:getControl("GoodsPanel2", Const.UIPanel, goodsPanel)
        if i * 2 > goodsInfo.count then
            rightGoods:setVisible(false)
        else
            rightGoods:setTag(i * 2)
            self:setSingelGoodsPanel(goodsInfo.items[i * 2], rightGoods)
            if selectName and goodsInfo.items[i * 2].name == selectName then
                self:chooseGoods(rightGoods)
                initSel = false
            end
        end

        sellListView:pushBackCustomItem(goodsPanel)
    end

    if initSel then self:chooseGoods() end
end

function WangZWStoreDlg:onDlgOpened(param)
    local sellListView = self:getControl("GroceryStoreListView")
    local itemsPanel = sellListView:getItems()
    if #itemsPanel == 0 then
        self.initItemName = param[1]
        return
    end

    local initSel = true
    for _,goodsPanel in pairs(itemsPanel) do
        local goodsPanel1 = self:getControl("GoodsPanel1", nil, goodsPanel)
        local goodsPanel2 = self:getControl("GoodsPanel2", nil, goodsPanel)

        self:setCtrlVisible("ChosenImage", false, goodsPanel1)
        self:setCtrlVisible("ChosenImage", false, goodsPanel2)

        if self:getLabelText("GoodsNameLabel", goodsPanel1) == param[1] then
            self.pick = goodsPanel1:getTag()
            self:setCtrlVisible("ChosenImage", true, goodsPanel1)
            self:setItemInfo(self.pick)
            self:setCostInfo(self.pick)
            initSel = false
        end

        if self:getLabelText("GoodsNameLabel", goodsPanel2) == param[1] then
            self.pick = goodsPanel2:getTag()
            self:setCtrlVisible("ChosenImage", true, goodsPanel2)
            self:setItemInfo(self.pick)
            self:setCostInfo(self.pick)
            initSel = false
        end
    end

    if initSel then self:chooseGoods() end
end

function WangZWStoreDlg:setSingelGoodsPanel(goods, panel)
    local icon = InventoryMgr:getIconByName(goods.name)
    self:setImage("GoodsImage", ResMgr:getItemIconPath(icon), panel)
    self:setItemImageSize("GoodsImage", panel)

    if nil ~= goods.level and 0 ~= goods.level then
        self:setNumImgForPanel("GoodsImagePanel", ART_FONT_COLOR.DEFAULT, goods.level, false, LOCATE_POSITION.LEFT_TOP, 19, panel) 
    end

    self:setLabelText("GoodsNameLabel", goods.name, panel)
    local num, numColor = gf:getArtFontMoneyDesc(goods.price)
    self:setNumImgForPanel("GoodsPricePanel", numColor, num, false, LOCATE_POSITION.CENTER, 21, panel) 
    self:bindTouchEndEventListener(panel, self.chooseGoods)
end

function WangZWStoreDlg:chooseGoods(sender, eventType)
    if sender then
        if self:getControl("ChosenImage", nil, sender):isVisible() then
            self:onAddButton()
            return
        end
    end

    local sellListView = self:getControl("GroceryStoreListView")
    local itemsPanel = sellListView:getItems()
    for _,goodsPanel in pairs(itemsPanel) do
        local goodsPanel1 = self:getControl("GoodsPanel1", nil, goodsPanel)
        local goodsPanel2 = self:getControl("GoodsPanel2", nil, goodsPanel)

        self:setCtrlVisible("ChosenImage", false, goodsPanel1)
        self:setCtrlVisible("ChosenImage", false, goodsPanel2)

        sender = sender or goodsPanel1
    end

    self.pick = sender:getTag()
    self:setCtrlVisible("ChosenImage", true, sender)
    --
    self:setItemInfo(self.pick)
    self:setCostInfo(self.pick)
    --]]
    
    self.shopLimit = InventoryMgr:isCanAddToBag(self.goodsInfo.items[self.pick].name, shopLimit)
end

function WangZWStoreDlg:getItemByName(name, level)
    if nil == level or 0 == level then
        -- 等级为空的就不是宠物妖石
        return { }
    end

    return Formula:getPetStoneAttri(name, level)
end

function WangZWStoreDlg:setItemInfo(pick)
    local itemPanel = self:getControl("GoodsAttribInfoPanel")
    -- 名称
    self:setLabelText("GoodsNameLabel", self.goodsInfo.items[pick].name, itemPanel)

    -- 描述
    local desStr = InventoryMgr:getDescript(self.goodsInfo.items[pick].name)
    --local color = self:getControl("GoodsNameLabel", nil, itemPanel):getColor()
    local color = COLOR3.TEXT_DEFAULT
    local item = self:getItemByName(self.goodsInfo.items[pick].name, self.goodsInfo.items[pick].level)
    local funStr = InventoryMgr:getFuncStr(item)

    local str = desStr .. "\n" .. funStr
    local funPanel = self:getControl("FunPanel")
    funPanel:removeAllChildren()
    local size = funPanel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(FONTSIZE)
    textCtrl:setString(str)
    textCtrl:setDefaultColor(color.r, color.g, color.b)
    textCtrl:setContentSize(size.width, 0)
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition(0, size.height)
    funPanel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
end

function WangZWStoreDlg:setCostInfo(pick)
    -- 数量
    local countPanel = self:getControl("BuyNumberPanel")
    self:setLabelText("NumberValueLabel", 1, countPanel)

    -- 价格
    local pricePanel = self:getControl("TotalValuePanel")
    local totalPrice, priceColor = gf:getArtFontMoneyDesc(self.goodsInfo.items[pick].price)
    --local totalPrice, priceColor = gf:getMoneyDesc(self.goodsInfo.items[pick].value, true)
    self:setNumImgForPanel("TotalPricePanel", priceColor, totalPrice, false, LOCATE_POSITION.MID, 21) 
    --self:setLabelText("PriceLabel_1", totalPrice, "BuyButton", priceColor)
    --self:setLabelText("PriceLabel_2", totalPrice, "BuyButton", priceColor)

    -- 拥有
    self:updateMoney()
end

function WangZWStoreDlg:onReduceButton(sender, eventType)
    local countPanel = self:getControl("BuyNumberPanel")
    local count = self:getLabelText("NumberValueLabel", countPanel)
    count = tonumber(count)
    if count and count > 1 then
        self:setLabelText("NumberValueLabel", count - 1, countPanel)
        self:updatePrice()
    else
        gf:ShowSmallTips(CHS[3002743])
    end
end

function WangZWStoreDlg:onAddButton(sender, eventType)
    local countPanel = self:getControl("BuyNumberPanel")
    local count = self:getLabelText("NumberValueLabel", countPanel)
    count = tonumber(count)
    
    if count and count >= self.shopLimit then
        if self.shopLimit == shopLimit then
            gf:ShowSmallTips(CHS[4400011])
        else
            gf:ShowSmallTips(CHS[6000150])
        end
        return
    else
        self:setLabelText("NumberValueLabel", count + 1, countPanel)
        self:updatePrice()
    end
    
   --[[ if count and count < 100 then
        self:setLabelText("NumberValueLabel", count + 1, countPanel)
        self:updatePrice()
    else
        gf:ShowSmallTips(CHS[3002744])
    end]]
end

function WangZWStoreDlg:onAddCashButton(sender, eventType)
    gf:showBuyCash()
end

function WangZWStoreDlg:onBuyButton(sender, eventType)
    local countPanel = self:getControl("BuyNumberPanel")
    local count = self:getLabelText("NumberValueLabel", countPanel)
    
    if tonumber(count) < 1 then
        gf:ShowSmallTips(CHS[3002743])
        return
    end

    local price = self.goodsInfo.items[self.pick].price * tonumber(count) 
    
    local compCostStr = CHS[3002770] -- 确认框提示花费类型

    local itemName = self.goodsInfo.items[self.pick].name
    local costNumStr = gf:getMoneyDesc(price, false)
    
    local function buy()
    if price > Me:queryInt("cash") then
        gf:askUserWhetherBuyCash(price - Me:queryInt("cash"))
        return
    end

    gf:CmdToServer("CMD_EXCHANGE_GOODS", {        
        type = 4,
            name = itemName,
        amount = tonumber(count),
    })
    end
    
    if price >= 10000000 then
        gf:confirm(string.format(CHS[4300203], costNumStr, compCostStr, count, InventoryMgr:getUnit(itemName), itemName), function()
            buy()
        end)
    else
        buy()
    end

end

function WangZWStoreDlg:updatePrice()
    local countPanel = self:getControl("BuyNumberPanel")
    local count = self:getLabelText("NumberValueLabel", countPanel)
    count = tonumber(count)
    if not count then return end

    -- 价格
    local pricePanel = self:getControl("TotalValuePanel")
    local totalPrice, priceColor = gf:getArtFontMoneyDesc(self.goodsInfo.items[self.pick].price * count)
    self:setNumImgForPanel("TotalPricePanel", priceColor, totalPrice, false, LOCATE_POSITION.MID, 21)
    --self:setLabelText("PriceLabel_1", totalPrice, "BuyButton", priceColor)
    --self:setLabelText("PriceLabel_2", totalPrice, "BuyButton", priceColor)
end

-- 金钱响应
function WangZWStoreDlg:onCashCheckBox(sender, eventType)
    if Me:queryBasicInt("use_money_type") == MONEY_TYPE.CASH then return end

    gf:ShowSmallTips(CHS[3002745])
    self:CashCheckBox()
    CharMgr:setUseMoneyType(MONEY_TYPE.CASH)
end

function WangZWStoreDlg:CashCheckBox()
    local cash = Me:query("cash")
    self:updateMoneyByAmount(cash)
    self:setCtrlVisible("AddCashButton", true)
    self:setCtrlVisible("TicketImage", false)
    self:setCtrlVisible("TicketImage", false, "BuyButton")
    self:setCtrlVisible("TotalValueCashImage", true, "BuyButton")
end

-- 代金券响应
function WangZWStoreDlg:onVoucherCheckBox(sender, eventType)
    if Me:queryBasicInt("use_money_type") == MONEY_TYPE.VOUCHER then return end

    gf:ShowSmallTips(CHS[3002746])
    self:VoucherCheckBox()
    CharMgr:setUseMoneyType(MONEY_TYPE.VOUCHER)
end

function WangZWStoreDlg:VoucherCheckBox()
    local voucher = Me:query("voucher")
    self:updateMoneyByAmount(voucher)
    self:setCtrlVisible("AddCashButton", false, "HavePanel")
    self:setCtrlVisible("TicketImage", true)
    self:setCtrlVisible("TicketImage", true, "BuyButton")
    self:setCtrlVisible("TotalValueCashImage", false, "BuyButton")
end

-- 刷新金钱
function WangZWStoreDlg:updateMoneyByAmount(money)
    money = tonumber(money)
    Log:D(">>>> money :" .. money)

    -- 拥有
    local cashPanel = self:getControl("HavePanel")
    local cash, color = gf:getArtFontMoneyDesc(money)
    self:setNumImgForPanel("HaveCashPanel", color, cash, false, LOCATE_POSITION.MID, 21, cashPanel) 
end

function WangZWStoreDlg:updateMoney()
    self:CashCheckBox()
end

-- 刷新金钱
function WangZWStoreDlg:MSG_UPDATE()
    -- 拥有
    self:updateMoney()
end

-- 数字键盘插入数字
function WangZWStoreDlg:insertNumber(num)
    local count = num

    if count < 0 then
        count = 0
    end

    if num > self.shopLimit then
        if self.shopLimit == shopLimit then
            gf:ShowSmallTips(CHS[4400011])
        else
            gf:ShowSmallTips(CHS[6000150])
        end

        count = math.max(self.shopLimit, 0)
    end
    
    -- 数量
    local countPanel = self:getControl("BuyNumberPanel")
    self:setLabelText("NumberValueLabel", count, countPanel)
    
    self:updatePrice()
    
    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(count)
    end
end

return WangZWStoreDlg
