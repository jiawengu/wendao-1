-- GroceryStoreDlg.lua
-- Created by songcw May/19/2015
-- 杂货店

local RadioGroup = require("ctrl/RadioGroup")
local GroceryStoreDlg = Singleton("GroceryStoreDlg", Dialog)

local TOUCH_BEGAN  = 1
local TOUCH_END    = 2

local FONTSIZE = 20

local shopLimit = 100

local GOOD_TYPE = {
    COM = 1,   -- 常用
    STONE = 2  -- 妖石
}

function GroceryStoreDlg:init()
    self:blindPress("AddButton")
    self:blindPress("ReduceButton")
    self:bindListener("AddCashButton", self.onAddCashButton)
    self:bindListener("BuyButton", self.onBuyButton)

    -- 绑定数字键盘
    self:bindNumInput("NumberValuePanel")

    -- 金钱、代金券
    self:bindListener("CheckBox", function(dlg, sender, eventType)
        if not self:getControl("CheckBox"):getSelectedState() then
            self:onCashCheckBox()
        else
            self:onVoucherCheckBox()
        end
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
    self.sellListView = self:getControl("GroceryStoreListView", nil, "GroceryStorePanel1")
    self.sellListView:removeAllChildren()

    self.goodsInfo = nil
    self.pick = nil
    self.initItemName = nil
    self.initItemLevel = nil
    self.pk_add = 100
    self.shopLimit = shopLimit
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_INVENTORY")
    self.allCards = InventoryMgr:getAllCardInfo()

    self.curGoodType = 0
    self:setCtrlVisible("GroceryStorePanel1", true)
    self:setCtrlVisible("GroceryStorePanel2", false)

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"CheckBox_1", "CheckBox_2"}, self.onCheckbox, "TabPanel")
    self.radioGroup:selectRadio(1, true)

    -- 跨服试道中显示战场物资，不显示杂货店
    if DistMgr:isInKFSDServer()
          or DistMgr:isInKFZCServer()
          or DistMgr:isInKFJJServer()
          or DistMgr:isInKFZC2019Server()
          or DistMgr:isInMRZBServer() then
        self:setLabelText("TitleLabel1", CHS[5400039])
        self:setLabelText("TitleLabel2", CHS[5400039])
    end



    -- 若当前角色PK值大于0，则给出提示
    if Me:queryBasicInt("total_pk") > 0 then
        gf:ShowSmallTips(CHS[7000062])
    end
end

function GroceryStoreDlg:setClassify(classify)
    if not classify then
        -- 不分类
        self.curGoodType = 0
        self.sellListView = self:getControl("GroceryStoreListView", nil, "GroceryStorePanel1")
        self.sellListView:removeAllChildren()

        self:setCtrlVisible("GroceryStorePanel1", true)
        self:setCtrlVisible("GroceryStorePanel2", false)
    else
        -- 分类，默认选中常用道具
        if self.curGoodType == 0 then self.curGoodType = GOOD_TYPE.COM end

        self.sellListView = self:getControl("GroceryStoreListView2", nil, "GroceryStorePanel2")
        self.sellListView:removeAllChildren()

        self:setCtrlVisible("GroceryStorePanel1", false)
        self:setCtrlVisible("GroceryStorePanel2", true)
    end
end

function GroceryStoreDlg:onCheckbox(sender)
    local name = sender:getName()
    if name == "CheckBox_1" then
        self.curGoodType = GOOD_TYPE.COM
    else
        self.curGoodType = GOOD_TYPE.STONE
    end

    if self.goodsInfo then
        self:updateSell(self.goodsInfo)
    end
end

function GroceryStoreDlg:cleanup()
    if self.goodsPanel then
        self.goodsPanel:release()
        self.goodsPanel = nil
    end

    self.allCards = {}
end

function GroceryStoreDlg:blindPress(name)
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

function GroceryStoreDlg:updateSell(goodsInfo, selectName)
    if not goodsInfo then return end

    self.goodsInfo = goodsInfo

    selectName = selectName or self.initItemName or (self.pick and goodsInfo.goods[self.pick] and goodsInfo.goods[self.pick].name)
    if self.initItemName and self.curGoodType > 0 then
        -- 根据要选中商品重新选择分类
        for _, v in pairs(self.goodsInfo.goods) do
            if v.name == selectName then
                self.curGoodType = v.type
                self.radioGroup:selectRadio(self.curGoodType, true)
                break
            end
        end
    end

    local selectLevel = self.initItemLevel
    self.pk_add = goodsInfo.pk_add
    local sellListView = self.sellListView
    sellListView:removeAllItems()
    local listSize = sellListView:getContentSize()
    local initSel = true

    local count = math.floor(goodsInfo.count / 2) + goodsInfo.count % 2
    local index = 1
    local count = 0
    while goodsInfo.goods[index] do
        while goodsInfo.goods[index] and self.curGoodType ~= goodsInfo.goods[index].type do
            index = index + 1
        end

        if not goodsInfo.goods[index] then break end

        count = count + 1
        local goodsPanel = self.goodsPanel:clone()
        sellListView:pushBackCustomItem(goodsPanel)

        local leftGoods = self:getControl("GoodsPanel1", Const.UIPanel, goodsPanel)
        leftGoods:setTag(index)
        self:setSingelGoodsPanel(goodsInfo.goods[index], leftGoods)
        if selectName and goodsInfo.goods[index].name == selectName
               and (not selectLevel or selectLevel == goodsInfo.goods[index].level) then
            self:chooseGoods(leftGoods)
            local singelHeight = goodsPanel:getContentSize().height
            if singelHeight * count > listSize.height then
                sellListView:scrollToBottom(1,false)
            end

            initSel = false
        end

        index = index + 1
        while goodsInfo.goods[index] and self.curGoodType ~= goodsInfo.goods[index].type do
            index = index + 1
        end

        local rightGoods = self:getControl("GoodsPanel2", Const.UIPanel, goodsPanel)
        if not goodsInfo.goods[index] then
            rightGoods:setVisible(false)
        else
            rightGoods:setTag(index)
            self:setSingelGoodsPanel(goodsInfo.goods[index], rightGoods)
            if selectName and goodsInfo.goods[index].name == selectName
                  and (not selectLevel or selectLevel == goodsInfo.goods[index].level)then
                self:chooseGoods(rightGoods)
                local singelHeight = goodsPanel:getContentSize().height
                if singelHeight * count > listSize.height then
                    sellListView:scrollToBottom(1,false)
                end

                initSel = false
            end
        end

        index = index + 1
    end

    self.initItemName = nil
    self.initItemLevel = nil

    if initSel then self:chooseGoods() end
end

function GroceryStoreDlg:onDlgOpened(param)
    local sellListView = self.sellListView
    local itemsPanel = sellListView:getItems()
    if #itemsPanel == 0 or not self.goodsInfo then
        self.initItemName = param[1]
        self.initItemLevel = tonumber(param[2])
        return
    end

    if param[1] then
        for _, v in pairs(self.goodsInfo.goods) do
            if v.name == param[1] then
                if self.curGoodType ~= v.type then
                    -- 需要根据要选中商品重新选择分类
                    self.initItemName = param[1]
                    self.initItemLevel = tonumber(param[2])
                    self:updateSell(self.goodsInfo)
                    return
                end

                break
            end
        end
    end

    local initSel = true
    for _,goodsPanel in pairs(itemsPanel) do
        local goodsPanel1 = self:getControl("GoodsPanel1", nil, goodsPanel)
        local goodsPanel2 = self:getControl("GoodsPanel2", nil, goodsPanel)

        self:setCtrlVisible("ChosenImage", false, goodsPanel1)
        self:setCtrlVisible("ChosenImage", false, goodsPanel2)

        if initSel and self:getLabelText("GoodsNameLabel", goodsPanel1) == param[1] then
            self.pick = goodsPanel1:getTag()
            self:setCtrlVisible("ChosenImage", true, goodsPanel1)
            self:setItemInfo(self.pick)
            self:setCostInfo(self.pick)
            initSel = false
        end

        if initSel and self:getLabelText("GoodsNameLabel", goodsPanel2) == param[1] then
            self.pick = goodsPanel2:getTag()
            self:setCtrlVisible("ChosenImage", true, goodsPanel2)
            self:setItemInfo(self.pick)
            self:setCostInfo(self.pick)
            initSel = false
        end
    end

    if initSel then self:chooseGoods() end
end

function GroceryStoreDlg:setSingelGoodsPanel(goods, panel)
    local icon = InventoryMgr:getIconByName(goods.name)
    self:setImage("GoodsImage", ResMgr:getItemIconPath(icon), panel)
    self:setItemImageSize("GoodsImage", panel)

    if nil ~= goods.level and 0 ~= goods.level then
        self:setNumImgForPanel("GoodsImagePanel", ART_FONT_COLOR.DEFAULT, goods.level, false, LOCATE_POSITION.LEFT_TOP, 19, panel)
    end

    self:setLabelText("GoodsNameLabel", goods.name, panel)
    local num, numColor = gf:getArtFontMoneyDesc(goods.value * self.pk_add / 100)
    self:setNumImgForPanel("GoodsPricePanel", numColor, num, false, LOCATE_POSITION.CENTER, 21, panel)
    self:bindTouchEndEventListener(panel, self.chooseGoods)
end

function GroceryStoreDlg:chooseGoods(sender, eventType)
    if sender then
        if self:getControl("ChosenImage", nil, sender):isVisible() then
            self:onAddButton()
            return
        end
    end

    local sellListView = self.sellListView
    local itemsPanel = sellListView:getItems()
    for _,goodsPanel in pairs(itemsPanel) do
        local goodsPanel1 = self:getControl("GoodsPanel1", nil, goodsPanel)
        local goodsPanel2 = self:getControl("GoodsPanel2", nil, goodsPanel)

        self:setCtrlVisible("ChosenImage", false, goodsPanel1)
        self:setCtrlVisible("ChosenImage", false, goodsPanel2)

        sender = sender or goodsPanel1
    end

    if not sender then return end

    self.pick = sender:getTag()
    self:setCtrlVisible("ChosenImage", true, sender)
    --
    self:setItemInfo(self.pick)
    self:setCostInfo(self.pick)
    --]]

    self.shopLimit = InventoryMgr:getCountCanAddToBag(self.goodsInfo.goods[self.pick], shopLimit, Me:queryBasicInt("use_money_type") == MONEY_TYPE.VOUCHER)
end

function GroceryStoreDlg:getItemByName(name, level)
    if nil == level or 0 == level then
        -- 等级为空的就不是宠物妖石
        return { }
    end

    return Formula:getPetStoneAttri(name, level)
end

function GroceryStoreDlg:setItemInfo(pick)
    local itemPanel = self:getControl("GoodsAttribInfoPanel")
    -- 名称
    self:setLabelText("GoodsNameLabel", self.goodsInfo.goods[pick].name, itemPanel)

    -- 描述
    local desStr = InventoryMgr:getDescript(self.goodsInfo.goods[pick].name)
    --local color = self:getControl("GoodsNameLabel", nil, itemPanel):getColor()
    local color = COLOR3.TEXT_DEFAULT
    local item = self:getItemByName(self.goodsInfo.goods[pick].name, self.goodsInfo.goods[pick].level)
    local funStr = InventoryMgr:getFuncStr(item)
    local funPanel = self:getControl("FunPanel")
    funPanel:removeAllChildren()
    local size = funPanel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(FONTSIZE)

    if not self.allCards[self.goodsInfo.goods[pick].name] then
        local str = desStr .. "\n" .. funStr
        textCtrl:setString(str)
    else
        -- 跨服试道中需要显示变身卡商品
        local cardInfo = self.allCards[self.goodsInfo.goods[pick].name]
        local cardInfoStr = ""
        -- 基本属性
        for i = 1, #cardInfo.attrib do
            local perce = InventoryMgr:isPercentChangeAtt(cardInfo.attrib[i].field)
            cardInfoStr = cardInfoStr .. "#B" .. cardInfo.attrib[i].chs
            local valueStr = ""
            if cardInfo.attrib[i].value > 0 then
                if cardInfo.grayImg then
                    -- 置灰代表没有获得过，显示？号
                    valueStr = "+?" .. perce
                else
                    valueStr = string.format("+%d", cardInfo.attrib[i].value) .. perce
                end
            else
                if cardInfo.grayImg then
                    -- 置灰代表没有获得过，显示？号
                    valueStr = "-?" .. perce
                else
                    valueStr = string.format("%d", cardInfo.attrib[i].value) .. perce
                end
            end

            cardInfoStr = cardInfoStr .. valueStr .. "#n\n"
        end
        -- 阵法属性
        local battleArrayAttribTab = cardInfo.battle_arr

        local start = #cardInfo.attrib
        for i = 1, #battleArrayAttribTab do
            local perce = InventoryMgr:isPercentChangeAtt(cardInfo.attrib[i].field)
            local att = battleArrayAttribTab[i]
            cardInfoStr = cardInfoStr .. "#D" .. att.chs
            local valueStr = ""
            if att.value > 0 then
                if cardInfo.grayImg then
                    -- 置灰代表没有获得过，显示？号
                    valueStr = "+?" .. perce
                else
                    valueStr = string.format("+%d", att.value) .. perce
                end
            else
                if cardInfo.grayImg then
                    -- 置灰代表没有获得过，显示？号
                    valueStr = "-?" .. perce
                else
                    valueStr = string.format("%d", att.value) .. perce
                end
            end

            cardInfoStr = cardInfoStr .. valueStr .. "#n\n"
        end


        local str = desStr .. "\n" .. funStr .. "\n" .. cardInfoStr
        textCtrl:setString(str)
    end

    textCtrl:setDefaultColor(color.r, color.g, color.b)
    textCtrl:setContentSize(size.width, 0)
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition(0, textH)

    funPanel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
    size = funPanel:getContentSize()
    local scrollView = self:getControl("ScrollView")
    local svSize = scrollView:getContentSize()
    -- 内容小于显示区域往上移
    if textH < scrollView:getContentSize().height then
        textCtrl:setPosition(0, scrollView:getContentSize().height)
    end

    scrollView:setInnerContainerSize({width = size.width, height = textH})
    scrollView:getInnerContainer():setPositionY(math.min(0, size.height - textH))
end

function GroceryStoreDlg:setCostInfo(pick)
    -- 数量
    local countPanel = self:getControl("BuyNumberPanel")
    self:setLabelText("NumberValueLabel", 1, countPanel)

    -- 价格
    local pricePanel = self:getControl("TotalValuePanel")
    local totalPrice, priceColor = gf:getArtFontMoneyDesc(self.goodsInfo.goods[pick].value * self.pk_add / 100)
    --local totalPrice, priceColor = gf:getMoneyDesc(self.goodsInfo.goods[pick].value, true)
    self:setNumImgForPanel("TotalPricePanel", priceColor, totalPrice, false, LOCATE_POSITION.MID, 21)
    --self:setLabelText("PriceLabel_1", totalPrice, "BuyButton", priceColor)
    --self:setLabelText("PriceLabel_2", totalPrice, "BuyButton", priceColor)

    -- 拥有
    self:updateMoney()
end

function GroceryStoreDlg:onReduceButton(sender, eventType)
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

function GroceryStoreDlg:onAddButton(sender, eventType)
    local countPanel = self:getControl("BuyNumberPanel")
    local count = self:getLabelText("NumberValueLabel", countPanel)
    count = tonumber(count)

    if count and count >= self.shopLimit then
        if self.shopLimit == shopLimit then
            gf:ShowSmallTips(CHS[6000035])
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

function GroceryStoreDlg:onAddCashButton(sender, eventType)
    gf:showBuyCash()
end

function GroceryStoreDlg:onBuyButton(sender, eventType)
    local countPanel = self:getControl("BuyNumberPanel")
    local count = self:getLabelText("NumberValueLabel", countPanel)

    if tonumber(count) < 1 then
        gf:ShowSmallTips(CHS[3002743])
        return
    end

    if tonumber(count) > self.shopLimit then
        gf:ShowSmallTips(CHS[4200309])
        return
    end

    local price = self.goodsInfo.goods[self.pick].value * self.pk_add * tonumber(count) / 100

    local canOnlyBuyByCash = false
    if self.goodsInfo.goods[self.pick].pay_type == 8 then  -- 代表只能用金钱购买
        canOnlyBuyByCash = true
    end

    local compCostStr = CHS[3002770] -- 确认框提示花费类型
    if Me:queryBasicInt("use_money_type") == MONEY_TYPE.CASH then
        -- 当前金钱模式
        compCostStr = CHS[3002770]
    else
        -- 当前代金券模式
        compCostStr = CHS[3003718]
    end
    if canOnlyBuyByCash then
        -- 如果只能使用金钱
        compCostStr = CHS[3002770]
    end

    local itemName = self.goodsInfo.goods[self.pick].name
    local costNumStr = gf:getMoneyDesc(price, false)

    local function buy()
        -- 判断金钱、代金券是否足够
        local hasEnough = gf:checkCurMoneyEnough(price, function()
            gf:CmdToServer("CMD_GOODS_BUY", {
                shipper = self.goodsInfo.shipper,
                pos = self.pick,
                amount = count,
                to_pos = 0,
            })
        end, canOnlyBuyByCash)

        if not hasEnough then
            if nil == hasEnough then
                gf:askUserWhetherBuyCash(price - Me:queryInt("cash"))
            end

            return
        end

        gf:CmdToServer("CMD_GOODS_BUY", {
            shipper = self.goodsInfo.shipper,
            pos = self.pick,
            amount = count,
            to_pos = 0,
        })
        self:frozeButton("BuyButton")   -- 防止误触
    end

    if price >= 10000000 then
        gf:confirm(string.format(CHS[4300203], costNumStr, compCostStr, count, InventoryMgr:getUnit(itemName), itemName), function()
            buy()
        end)
    else
        buy()
    end
end

function GroceryStoreDlg:updatePrice()
    local countPanel = self:getControl("BuyNumberPanel")
    local count = self:getLabelText("NumberValueLabel", countPanel)
    count = tonumber(count)
    if not count then return end

    -- 价格
    local pricePanel = self:getControl("TotalValuePanel")
    local totalPrice, priceColor = gf:getArtFontMoneyDesc(self.goodsInfo.goods[self.pick].value * self.pk_add * count / 100)
    self:setNumImgForPanel("TotalPricePanel", priceColor, totalPrice, false, LOCATE_POSITION.MID, 21)
    --self:setLabelText("PriceLabel_1", totalPrice, "BuyButton", priceColor)
    --self:setLabelText("PriceLabel_2", totalPrice, "BuyButton", priceColor)
end

-- 金钱响应
function GroceryStoreDlg:onCashCheckBox(sender, eventType)
    if Me:queryBasicInt("use_money_type") == MONEY_TYPE.CASH then return end

    gf:ShowSmallTips(CHS[3002745])
    self:CashCheckBox()
    CharMgr:setUseMoneyType(MONEY_TYPE.CASH)
end

function GroceryStoreDlg:CashCheckBox()
    local cash = Me:query("cash")
    self:updateMoneyByAmount(cash)
    self:setCtrlVisible("AddCashButton", true)
    self:setCtrlVisible("TicketImage", false)
    self:setCtrlVisible("TicketImage", false, "BuyButton")
    self:setCtrlVisible("TotalValueCashImage", true, "BuyButton")
end

-- 代金券响应
function GroceryStoreDlg:onVoucherCheckBox(sender, eventType)
    if Me:queryBasicInt("use_money_type") == MONEY_TYPE.VOUCHER then return end

    gf:ShowSmallTips(CHS[3002746])
    self:VoucherCheckBox()
    CharMgr:setUseMoneyType(MONEY_TYPE.VOUCHER)
end

function GroceryStoreDlg:VoucherCheckBox()
    local voucher = Me:query("voucher")
    self:updateMoneyByAmount(voucher)
    self:setCtrlVisible("AddCashButton", false, "HavePanel")
    self:setCtrlVisible("TicketImage", true)
    self:setCtrlVisible("TicketImage", true, "BuyButton")
    self:setCtrlVisible("TotalValueCashImage", false, "BuyButton")
end

-- 刷新金钱
function GroceryStoreDlg:updateMoneyByAmount(money)
    money = tonumber(money)
    Log:D(">>>> money :" .. money)

    -- 拥有
    local cashPanel = self:getControl("HavePanel")
    local cash, color = gf:getArtFontMoneyDesc(money)
    self:setNumImgForPanel("HaveCashPanel", color, cash, false, LOCATE_POSITION.MID, 21, cashPanel)
end

function GroceryStoreDlg:updateMoney()
    local useMoneyType = Me:queryBasicInt("use_money_type")
    local checkbox = self:getControl("CheckBox", Const.UICheckBox)
    if useMoneyType == MONEY_TYPE.CASH then
        checkbox:setSelectedState(false)
        self:CashCheckBox()
    elseif useMoneyType == MONEY_TYPE.VOUCHER then
        checkbox:setSelectedState(true)
        self:VoucherCheckBox()
    end
end

-- 刷新可购买的商品数量
function GroceryStoreDlg:MSG_INVENTORY(data)
    if self.goodsInfo and self.pick and self.goodsInfo.goods[self.pick] then
        self.shopLimit = InventoryMgr:getCountCanAddToBag(self.goodsInfo.goods[self.pick], shopLimit, Me:queryBasicInt("use_money_type") == MONEY_TYPE.VOUCHER)
    end
end

-- 刷新金钱
function GroceryStoreDlg:MSG_UPDATE(data)
    -- 拥有
    self:updateMoney()

    if data["use_money_type"] and self.goodsInfo and self.pick and self.goodsInfo.goods[self.pick] then
        self.shopLimit = InventoryMgr:getCountCanAddToBag(self.goodsInfo.goods[self.pick], shopLimit, Me:queryBasicInt("use_money_type") == MONEY_TYPE.VOUCHER)
    end
end

-- 数字键盘插入数字
function GroceryStoreDlg:insertNumber(num)
    local count = num

    if count < 0 then
        count = 0
    end

    if num > self.shopLimit then
        if self.shopLimit == shopLimit then
            gf:ShowSmallTips(CHS[6000035])
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

return GroceryStoreDlg
