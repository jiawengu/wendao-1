-- MarketBuyItemDlg.lua
-- Created by liuhb Apr/22/2015
-- 购买物品界面

local MarketBuyItemDlg = Singleton("MarketBuyItemDlg", Dialog)

local BTN_FUNC = {
    ["ReduceButton"]    = "onReduceButton",
    ["AddButton"]       = "onAddButton",
}

function MarketBuyItemDlg:init()
    self:bindListener("MaxButton", self.onMaxButton)
    self:bindListener("AddCoinButton", self.onAddCoinButton)
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("BuyButton", self.onSellButton)

    self:blindAddReduceLongClick("ReduceButton")
    self:blindAddReduceLongClick("AddButton")
end

function MarketBuyItemDlg:setViewData(item)
    if nil == item then return end

    self.item = item

    -- 设置数量
    self:setLabelText("NumLabel", item.amount, self:getControl("NumPanel"))

    -- 设置身上的金钱
    local label = self:getControl("CoinPanel", Const.UILabel, self:getControl("MyCoinPanel"))
    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel(label, fontColor, cashText, false, LOCATE_POSITION.LEFT_BOTTOM, 23)

    -- 设置等级、图标、数量
    local iconPanel = self:getControl("IconPanel")
    if nil == item.level or 0 == item.level then
        self:removeNumImgForPanel(iconPanel, LOCATE_POSITION.LEFT_TOP)
    else
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, item.level, false, LOCATE_POSITION.LEFT_TOP, 21)
    end

    if nil == item.amount or 1 >= item.amount then
        self:removeNumImgForPanel(iconPanel, LOCATE_POSITION.RIGHT_BOTTOM)
    else
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, item.amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
    end

    local iconPath = ResMgr:getItemIconPath(item.icon)
    self:setImage("IconImage", iconPath)
    self:setItemImageSize("IconImage")

    if item.item_type == ITEM_TYPE.EQUIPMENT and item.unidentified == 1 then
        InventoryMgr:addLogoUnidentified(self:getControl("IconImage"))
    end
    
    -- 法宝相性
    if item.item_type == ITEM_TYPE.ARTIFACT and item.item_polar then
        InventoryMgr:addArtifactPolarImage(self:getControl("IconImage"), item.item_polar)
    end
    
    self:setMoneyDesc("CoinPanel", item.price)

    -- 设置物品名称
    self:setLabelText("NameLabel", item.name)

    -- 获取道具描述
    local itemDesc = InventoryMgr:getDescript(item.name)
    self:setLabelText("DescriptionLabel", itemDesc)

    -- 获取道具功效
    local itemEffect = InventoryMgr:getFuncStr(item)
    self:setLabelText("ContentLabel", itemEffect)

    self:updateTotleCash()
end

function MarketBuyItemDlg:onReduceButton(sender, eventType)
    -- 获取当前数量
    local curNum = self:getLabelText("NumLabel", self:getControl("NumPanel"))
    curNum = tonumber(curNum)

    curNum = curNum - 1
    if curNum <= 0 then
        curNum = 1
    end

    self:setLabelText("NumLabel", curNum, self:getControl("NumPanel"))

    self:updateTotleCash()
end

function MarketBuyItemDlg:onAddButton(sender, eventType)
    if nil == self.item then return end

    -- 获取当前数量
    local curNum = self:getLabelText("NumLabel", self:getControl("NumPanel"))
    curNum = tonumber(curNum)

    curNum = curNum + 1
    if curNum >= self.item.amount then
        curNum = self.item.amount
    end

    self:setLabelText("NumLabel", curNum, self:getControl("NumPanel"))

    self:updateTotleCash()
end

function MarketBuyItemDlg:updateTotleCash()
    if nil == self.item then return end

    local curNum = self:getLabelText("NumLabel", self:getControl("NumPanel"))
    curNum = tonumber(curNum)

    self:setMoneyDesc("CoinPanel", self.item.price * curNum)

    if self.item.amount == curNum then
        local Ctrl = self:getControl("AddButton")
        gf:grayImageView(Ctrl)
        if self.isTouch then
            self.isSetTouchEnabelFalse = true
        else
            Ctrl:setTouchEnabled(false)
        end
    else
        local Ctrl = self:getControl("AddButton")
        gf:resetImageView(Ctrl)
        Ctrl:setTouchEnabled(true)
    end

    if 1 >= curNum then
        local Ctrl = self:getControl("ReduceButton")
        gf:grayImageView(Ctrl)
        if self.isTouch then
            self.isSetTouchEnabelFalse = true
        else
            Ctrl:setTouchEnabled(false)
        end
    else
        local Ctrl = self:getControl("ReduceButton")
        gf:resetImageView(Ctrl)
        Ctrl:setTouchEnabled(true)
    end
end

function MarketBuyItemDlg:onMaxButton(sender, eventType)
    if nil == self.item then return end

    self:setLabelText("NumLabel", self.item.amount, self:getControl("NumPanel"))

    self:updateTotleCash()
end

function MarketBuyItemDlg:onAddCoinButton(sender, eventType)
    gf:showBuyCash()
end

function MarketBuyItemDlg:onCancelButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
end

function MarketBuyItemDlg:onSellButton(sender, eventType)
    if nil == self.item then return end

    if Me:queryBasic("gid") == self.item.gid then
        gf:ShowSmallTips(CHS[3002997])
        return;
    end

    local curNum = self:getLabelText("NumLabel", self:getControl("NumPanel"))
    curNum = tonumber(curNum)

    MarketMgr:BuyItem(self.item.item_unique, curNum, self.item.price)
    DlgMgr:closeDlg(self.name)
end

function MarketBuyItemDlg:blindAddReduceLongClick(name, root)
    local widget = self:getControl(name, nil, root)

    if not widget then
        Log:W("Dialog:bindListViewListener no control " .. name)
        return
    end

    local function updataCount()
        self[BTN_FUNC[name]](self, widget)
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            schedule(widget , updataCount, 0.2)
            self.isTouch = true
        elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
            self.isTouch = false
            updataCount()
            widget:stopAllActions()

            if self.isSetTouchEnabelFalse then
                sender:setTouchEnabled(false)
                self.isSetTouchEnabelFalse = nil
            end
        end
    end

    widget:addTouchEventListener(listener)
end

function MarketBuyItemDlg:setMoneyDesc(ctrlName, cash)
    local num = tonumber(cash) or 0
    local ctrl = self:getControl(ctrlName)

    local cashText, fontColor = gf:getArtFontMoneyDesc(num)
    self:setNumImgForPanel(ctrl, fontColor, cashText, false, LOCATE_POSITION.LEFT_BOTTOM, 23)
end

return MarketBuyItemDlg
