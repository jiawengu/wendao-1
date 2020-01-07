-- PharmacyDlg.lua
-- Created by songcw May/13/2015
-- 药店界面

local RadioGroup = require("ctrl/RadioGroup")
local PharmacyDlg = Singleton("PharmacyDlg", Dialog)

local TOUCH_BEGAN  = 1
local TOUCH_END     = 2
local shopLimit = 100

function PharmacyDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("AddCashButton", self.onAddCashButton)
    self:blindPress("AddButton")
    self:blindPress("ReduceButton")

    -- 绑定数字键盘
    self:bindNumInput("NumberValuePanel")

    local moneyType = Me:queryBasicInt("use_money_type")
    --self.moneyRGroup:selectRadio(moneyType + 1, true)
    -- self:updateMoneyInfo()

    -- 克隆
    local goodsPanel = self:getControl("GoodsPanel_1", Const.UIPanel)
    local leftPanel = self:getControl("GoodsPanel_left", Const.UIPanel, goodsPanel)
    self:setCtrlVisible("ChosenImage", false, leftPanel)
    local rightPanel = self:getControl("GoodsPanel_right", Const.UIPanel, goodsPanel)
    self:setCtrlVisible("ChosenImage", false, rightPanel)
    self.goodsPanel = goodsPanel:clone()
    self.goodsPanel:retain()
    goodsPanel:removeFromParent()
    local sellListView = self:getControl("PharmacyListView")
    sellListView:removeAllChildren()
    self:bindListener("CheckBox", function(sender, eventType)
        if not self:getControl("CheckBox"):getSelectedState() then
            self:onCashCheckBox()
        else
            self:onVoucherCheckBox()
        end
    end)


    self.goodsInfo = nil
    self.pick = nil
    self.initItemName = nil
    self.initItemNum = nil
    self.pk_add = 100
    self.shopLimit = shopLimit

    self:hookMsg("MSG_UPDATE")

    -- 若当前角色PK值大于0，则给出提示
    if Me:queryBasicInt("total_pk") > 0 then
        gf:ShowSmallTips(CHS[7000062])
    end
end

function PharmacyDlg:blindPress(name)
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

function PharmacyDlg:cleanup()
    self:releaseCloneCtrl("goodsPanel")
end

function PharmacyDlg:updateSell(goodsInfo, selectName)
    selectName = selectName or self.initItemName
    self.goodsInfo = goodsInfo
    self.pk_add = goodsInfo.pk_add
    local sellListView = self:resetListView("PharmacyListView")
    local initSel = true
    local listSize = sellListView:getContentSize()
    local count = math.floor(goodsInfo.count / 2) + goodsInfo.count % 2
    for i = 1, count do
        local goodsPanel = self.goodsPanel:clone()
        local leftGoods = self:getControl("GoodsPanel_left", Const.UIPanel, goodsPanel)
        leftGoods:setTag(goodsInfo.goods[i * 2 - 1].goods_no)
        self:setSingelGoodsPanel(goodsInfo.goods[i * 2 - 1], leftGoods)
        if selectName and goodsInfo.goods[i * 2 - 1].name == selectName then
            self:chooseGoods(leftGoods)
            local singelHeight = goodsPanel:getContentSize().height
            if singelHeight * i > listSize.height then
                sellListView:scrollToBottom(1,false)
            end
            initSel = false
        end

        local rightGoods = self:getControl("GoodsPanel_right", Const.UIPanel, goodsPanel)
        if i * 2 > goodsInfo.count then
            rightGoods:setVisible(false)
        else
            rightGoods:setTag(goodsInfo.goods[i * 2].goods_no)
            self:setSingelGoodsPanel(goodsInfo.goods[i * 2], rightGoods)
            if selectName and goodsInfo.goods[i * 2].name == selectName then
                self:chooseGoods(rightGoods)
                local singelHeight = goodsPanel:getContentSize().height
                if singelHeight * i > listSize.height then
                    sellListView:scrollToBottom(1,false)

                end
                initSel = false
            end
        end

        sellListView:pushBackCustomItem(goodsPanel)
    end

    if initSel then self:chooseGoods() end

    if self.initItemNum then
        self:setLabelText("NumberValueLabel", self.initItemNum, "BuyNumberPanel")
        self:updatePrice()
    end
end

-- 打开界面需要某些参数需要重载这个函数
function PharmacyDlg:onDlgOpened(param)
    local sellListView = self:getControl("PharmacyListView")
    local listSize = sellListView:getContentSize()
    local itemsPanel = sellListView:getItems()
    sellListView:setItemsMargin(5)

    local targetNum
    if param[2] then
        -- 第二个参数用于确定数量
        -- 任务提示中的需要物品数量 - 背包中拥有的该物品数量
        local num = tonumber(param[2])
        local itemName = param[1]
        local amount = InventoryMgr:getAmountByName(itemName, true)
        targetNum = num - amount
        if targetNum < 1 then
            targetNum = 1
        end
    end

    if #itemsPanel == 0 then
        self.initItemName = param[1]
        self.initItemNum = targetNum
        return
    end

    local initSel = true
    local num = 0
    for _,goodsPanel in pairs(itemsPanel) do
        num = num + 1
        local goodsPanel1 = self:getControl("GoodsPanel_left", nil, goodsPanel)
        local goodsPanel2 = self:getControl("GoodsPanel_right", nil, goodsPanel)

        self:setCtrlVisible("ChosenImage", false, goodsPanel1)
        self:setCtrlVisible("ChosenImage", false, goodsPanel2)

        if self:getLabelText("GoodsNameLabel", goodsPanel1) == param[1] then
            self.pick = goodsPanel1:getTag()
            self:setCtrlVisible("ChosenImage", true, goodsPanel1)
            self:setItemInfo(self.pick)
            self:setCostInfo(self.pick)
            local singelHeight = goodsPanel:getContentSize().height
            if singelHeight * num > listSize.height then
                local temp = math.floor(listSize.height / singelHeight * #itemsPanel)
                sellListView:scrollToPercentHorizontal(temp, 1,false)
            end
            initSel = false
        end

        if self:getLabelText("GoodsNameLabel", goodsPanel2) == param[1] then
            self.pick = goodsPanel2:getTag()
            self:setCtrlVisible("ChosenImage", true, goodsPanel2)
            self:setItemInfo(self.pick)
            self:setCostInfo(self.pick)
            local singelHeight = goodsPanel:getContentSize().height
            if singelHeight * num > listSize.height then
                local temp = math.floor(listSize.height / singelHeight * #itemsPanel)
                sellListView:scrollToPercentHorizontal(temp, 1,false)
            end
            initSel = false
        end
    end
    if initSel then self:chooseGoods() end

    if targetNum then
        self:setLabelText("NumberValueLabel", targetNum, "BuyNumberPanel")
        self:updatePrice()
    end
end

function PharmacyDlg:setSingelGoodsPanel(goods, panel)

    local icon = InventoryMgr:getIconByName(goods.name)
    self:setImage("GoodsImage", ResMgr:getItemIconPath(icon), panel)
    self:setItemImageSize("GoodsImage", panel)
    self:setLabelText("GoodsNameLabel", goods.name, panel)

    local num, numColor = gf:getArtFontMoneyDesc(goods.value * self.pk_add / 100)
    self:setNumImgForPanel("GoodsPricePanel", numColor, num, false, LOCATE_POSITION.CENTER, 21, panel)
    self:bindTouchEndEventListener(panel, self.chooseGoods)
end

function PharmacyDlg:chooseGoods(sender, eventType)
    if sender then
        if self:getControl("ChosenImage", nil, sender):isVisible() then
            self:onAddButton()
            return
        end
    end

    local sellListView = self:getControl("PharmacyListView")
    local itemsPanel = sellListView:getItems()
    for _,goodsPanel in pairs(itemsPanel) do
        local goodsPanel1 = self:getControl("GoodsPanel_left", nil, goodsPanel)
        local goodsPanel2 = self:getControl("GoodsPanel_right", nil, goodsPanel)

        self:setCtrlVisible("ChosenImage", false, goodsPanel1)
        self:setCtrlVisible("ChosenImage", false, goodsPanel2)

        sender = sender or goodsPanel1
    end

    self.pick = sender:getTag()
    self:setCtrlVisible("ChosenImage", true, sender)
    self:setItemInfo(self.pick)
    self:setCostInfo(self.pick)

    self.shopLimit = InventoryMgr:isCanAddToBag(self.goodsInfo.goods[self.pick].name, shopLimit)
end

function PharmacyDlg:setItemInfo(pick)
    local itemPanel = self:getControl("GoodsAttribInfoPanel")
    -- 名称
    self:setLabelText("Label_5", self.goodsInfo.goods[pick].name, itemPanel)

    -- 描述
    local desStr = InventoryMgr:getDescript(self.goodsInfo.goods[pick].name)

    -- 功效
 --   local funStr = InventoryMgr:getFuncStr(self.goodsInfo.goods[pick].item)
    local funStr = InventoryMgr:getFuncFromItemCfg(self.goodsInfo.goods[pick].name)
    if funStr ~= "" then
        funStr = CHS[3003472] .. InventoryMgr:getFuncFromItemCfg(self.goodsInfo.goods[pick].name) .. "#n"
    end
    local str = desStr .. funStr
    self:setDescript(str)

    itemPanel:requestDoLayout()
end

function PharmacyDlg:setCostInfo(pick)
    -- 数量
    local countPanel = self:getControl("BuyNumberPanel")
    self:setLabelText("NumberValueLabel", 1, countPanel)

    -- 价格
    local pricePanel = self:getControl("TotalPanel")
    local totalPrice, priceColor = gf:getArtFontMoneyDesc(self.goodsInfo.goods[pick].value * self.pk_add / 100)
    self:setNumImgForPanel("TotalPricePanel", priceColor, totalPrice, false, LOCATE_POSITION.MID, 21, pricePanel)
    --self:setLabelText("TotalLabel_1", totalPrice, "TotalValuePanel")
    --self:setLabelText("TotalLabel_2", totalPrice, "TotalValuePanel")
    -- 拥有
    self:updateMoney()
end

function PharmacyDlg:setGoodsInfo(name)
    local panel = self:getControl("GoodsAttribInfoPanel")
    self:setLabelText("NameLabel", name, panel)
    local desStr = InventoryMgr:getDescript(name)
    self:setLabelText("DescribeLabel", desStr, panel)

    local item = {}
    local funStr = InventoryMgr:getFuncStr(item)
end


function PharmacyDlg:onReduceButton(sender, eventType)
    local countPanel = self:getControl("BuyNumberPanel")
    local count = self:getLabelText("NumberValueLabel", countPanel)
    count = tonumber(count)
    if count and count > 1 then
        self:setLabelText("NumberValueLabel", count - 1, countPanel)
        self:updatePrice()
    else
        gf:ShowSmallTips(CHS[3003473])
    end
end


function PharmacyDlg:onAddButton(sender, eventType)
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
        gf:ShowSmallTips(CHS[3003474])
    end]]
end

function PharmacyDlg:updatePrice()
    local countPanel = self:getControl("BuyNumberPanel")
    local count = self:getLabelText("NumberValueLabel", countPanel)
    count = tonumber(count)
    if not count then return end

    -- 价格
    local pricePanel = self:getControl("TotalValuePanel")
    local totalPrice, priceColor = gf:getArtFontMoneyDesc(self.goodsInfo.goods[self.pick].value * self.pk_add * count / 100)
    --self:getControl("TotalPricePanel"):removeAllChildren()
    self:setNumImgForPanel("TotalPricePanel", priceColor, totalPrice, false, LOCATE_POSITION.MID, 21, pricePanel)
 --   self:setLabelText("TotalLabel_1", totalPrice, "TotalValuePanel")
 --   self:setLabelText("TotalLabel_2", totalPrice, "TotalValuePanel")
end

function PharmacyDlg:onBuyButton(sender, eventType)
    local countPanel = self:getControl("BuyNumberPanel")
    local count = self:getLabelText("NumberValueLabel", countPanel)

    if tonumber(count) < 1 then
        gf:ShowSmallTips(CHS[3003473])
        return
    end

    local price = self.goodsInfo.goods[self.pick].value * self.pk_add * tonumber(count) / 100

    local compCostStr = CHS[3002770] -- 确认框提示花费类型
    if Me:queryBasicInt("use_money_type") == MONEY_TYPE.CASH then
        -- 当前金钱模式
        compCostStr = CHS[3002770]
    else
        -- 当前代金券模式
        compCostStr = CHS[3003718]
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
        end)
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

function PharmacyDlg:onAddCashButton(sender, eventType)
    gf:showBuyCash()
end

-- 设置物品描绘信息
function PharmacyDlg:setDescript(descript)
    local panel = self:getControl("FunctionPanel")
    panel:removeAllChildren()

    local box = panel:getBoundingBox()

    local container = ccui.Layout:create()
    container:setPosition(0,0)
    local scrollview = ccui.ScrollView:create()
    scrollview:setContentSize(panel:getContentSize())
    scrollview:setDirection(ccui.ScrollViewDir.vertical)
    scrollview:addChild(container)
    panel:addChild(scrollview)

    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(20)
    textCtrl:setContentSize(box.width, 0)
    textCtrl:setString(descript)
    textCtrl:updateNow()

    textCtrl:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition(0,textH)
    container:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
    container:setContentSize(textW, textH)
    scrollview:setInnerContainerSize(container:getContentSize())
    if textH < panel:getContentSize().height then
        container:setPositionY(panel:getContentSize().height - textH)
    end

end

-- 金钱响应
function PharmacyDlg:onCashCheckBox(sender, eventType)
    if Me:queryBasicInt("use_money_type") == MONEY_TYPE.CASH then return end

    gf:ShowSmallTips(CHS[3003475])
    self:CashCheckBox()
    CharMgr:setUseMoneyType(MONEY_TYPE.CASH)
end

function PharmacyDlg:CashCheckBox()
    local cash = Me:query("cash")
    self:updateMoneyByAmount(cash)
    self:setCtrlVisible("AddCashButton", true, "HavePanel")
    self:setCtrlVisible("TicketImage", false, "HavePanel")
    self:setCtrlVisible("TotalValueCashImage", true, "BuyButton")
    self:setCtrlVisible("TicketImage", false, "BuyButton")
end

-- 代金券响应
function PharmacyDlg:onVoucherCheckBox(sender, eventType)
    if Me:queryBasicInt("use_money_type") == MONEY_TYPE.VOUCHER then return end

    gf:ShowSmallTips(CHS[3003476])
    self:VoucherCheckBox()
    CharMgr:setUseMoneyType(MONEY_TYPE.VOUCHER)
end

function PharmacyDlg:VoucherCheckBox()
    local voucher = Me:query("voucher")
    self:updateMoneyByAmount(voucher)
    self:setCtrlVisible("AddCashButton", false, "HavePanel")
    self:setCtrlVisible("TicketImage", true, "HavePanel")
    self:setCtrlVisible("TotalValueCashImage", false, "BuyButton")
    self:setCtrlVisible("TicketImage", true, "BuyButton")
end

-- 刷新金钱
function PharmacyDlg:updateMoneyByAmount(money)
    money = tonumber(money)
    Log:D(">>>> money :" .. money)

    -- 拥有
    local cashPanel = self:getControl("HavePanel")
    local cash, color = gf:getArtFontMoneyDesc(money)
    self:setNumImgForPanel("HaveCashPanel", color, cash, false, LOCATE_POSITION.MID, 21, cashPanel)
end

function PharmacyDlg:updateMoney()
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

-- 刷新金钱
function PharmacyDlg:MSG_UPDATE()
    -- 拥有
    self:updateMoney()
end

-- 数字键盘插入数字
function PharmacyDlg:insertNumber(num)
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


return PharmacyDlg
