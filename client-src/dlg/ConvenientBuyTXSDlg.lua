-- ConvenientBuyTXSDlg.lua
-- Created by sujl, Apr/12
-- 快捷购买窗口

local ConvenientBuyTXSDlg = Singleton("ConvenientBuyTXSDlg", Dialog)

local CONST_DATA =
{
    shopLimit = 100,
    goldCoin  = 1,    -- 金元宝
    silverCoin = 2,   -- 银元宝
}

local COIN_IMAGE =
{
    [1] = ResMgr.ui["big_gold"],
    [2] = ResMgr.ui["big_silver"],
}

local TOUCH_BEGAN   = 1
local TOUCH_END     = 2

local lastClick -- 代表表示上一次点击的按钮，用于判断按不同按钮

function ConvenientBuyTXSDlg:getCfgFileName()
    return ResMgr:getDlgCfg("ConvenientBuyDlg")
end

function ConvenientBuyTXSDlg:init()
    self:blindPress("ReduceButton")
    self:blindPress("AddButton")
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("GoldBackImage", self.onAddGoldButton)

    self.radio = self:getControl("CheckBox", Const.UICheckBox, "CoinTypePanel")
    self.radio:setSelectedState(OnlineMallMgr.isUseGold)

    -- 打开数字键盘
    self:bindNumInput("NumberValueImage")

    local function checkBoxClick(self, sender, eventType)
        lastClick = "checkBox"
        if eventType == ccui.CheckBoxEventType.selected then
            gf:ShowSmallTips(CHS[4200155])
            OnlineMallMgr.isUseGold = true
            self:setShopPanel()
        elseif eventType == ccui.CheckBoxEventType.unselected then
            gf:ShowSmallTips(CHS[4200156])
            OnlineMallMgr.isUseGold = false
            self:setShopPanel()
        end
    end

    self:bindCheckBoxWidgetListener(self.radio, checkBoxClick)

    self:refreshInfo()
    self:setShopPanel()

    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_INVENTORY")
end

function ConvenientBuyTXSDlg:refreshInfo()
    local meSiliverStr = gf:getArtFontMoneyDesc(Me:queryBasicInt("silver_coin"))
    self:setNumImgForPanel("SilverValuePanel", ART_FONT_COLOR.DEFAULT, meSiliverStr, false, LOCATE_POSITION.CENTER, 21)
    local meGoldStr = gf:getArtFontMoneyDesc(Me:queryBasicInt("gold_coin"))
    self:setNumImgForPanel("GoldValuePanel", ART_FONT_COLOR.DEFAULT, meGoldStr, false, LOCATE_POSITION.CENTER, 21)
    self:updateLayout("SilverValuePanel")
    self:updateLayout("GoldValuePanel")
end

-- 商城数据回来刷新
function ConvenientBuyTXSDlg:initData()
    self.ShopGoodsNumber = 0  -- 道具默认购买数量是1
    self.goodsTable = OnlineMallMgr:getOnlineMallList()

    -- 设置金钱信息
    self:refreshInfo()
end

function ConvenientBuyTXSDlg:setData(data)
    self.data = data

    self.ShopGoodsNumber = data.max_count
    -- 道具图片
    local goodsImage = self:getControl("GoodsImage", Const.UIImage)
    local imgPath = InventoryMgr:getIconFileByName(CHS[2000062])
    goodsImage:loadTexture(imgPath)
    self:setItemImageSize("GoodsImage")

    self:setCtrlVisible("GoldImage_2", false)
    self:setCtrlVisible("SilverImage_2", true)

    -- 道具名称
    self:setLabelText("Label_0", CHS[2000062], "Image_2_0_1")

    --物品价格
    local goodPrice = gf:getArtFontMoneyDesc(data.price)
    self:setLabelText("Label", data.price, "Image_2_0_1")

    self:setShopPanel()
end


function ConvenientBuyTXSDlg:refreshBuyGoods()
    if not self.selectGoods then return end

    -- 道具图片
    local goodsImage = self:getControl("GoodsImage", Const.UIImage, goodsCell)
    local imgPath = InventoryMgr:getIconFileByName(self.selectGoods.name)
    goodsImage:loadTexture(imgPath)
    self:setItemImageSize("GoodsImage", goodsCell)

    -- 道具名称
    self:setLabelText("Label_0", self.selectGoods.name, "Image_2_0_1")

    --物品价格
    local goodPrice = gf:getArtFontMoneyDesc(self.selectGoods["coin"])
    self:setLabelText("Label", goodPrice, "Image_2_0_1")


end

-- 购买物品信息
function ConvenientBuyTXSDlg:setShopPanel()
    if not self.data then return end
    -- 购买道具数量
    local numberImage = self:getControl("NumberValueImage")
    local numberLabel = self:getControl("NumberLabel", Const.UILabel, numberImage)
    numberLabel:setString(self.ShopGoodsNumber)
    local numberLabel1 = self:getControl("NumberLabel_1", Const.UILabel, numberImage)
    numberLabel1:setString(self.ShopGoodsNumber)

    -- 购买道具总价
    local buyButton = self:getControl("BuyButton")
    local totalPrice = self.ShopGoodsNumber * self.data["price"]
    local totalNumberLabel = self:getControl("NumLabel", Const.UILabel, buyButton)
    totalNumberLabel:setString(totalPrice)
    local totalNumberLabel1 = self:getControl("NumLabel_1", Const.UILabel, buyButton)
    totalNumberLabel1:setString(totalPrice)

    self:refreshGoldIcon()
end

function ConvenientBuyTXSDlg:refreshGoldIcon()
    local buyButton = self:getControl("BuyButton")
    local goldImage = self:getControl("GoldImage", Const.UIImage, buyButton)
    local silverImage = self:getControl("SilverImage", Const.UIImage, buyButton)
    local showGold = OnlineMallMgr.isUseGold or (self.selectGoods and 1 == self.selectGoods["for_sale"])
    goldImage:setVisible(showGold)
    silverImage:setVisible(not showGold)
end

-- 数字键盘插入数字
function ConvenientBuyTXSDlg:insertNumber(num)
    if not self.data then return end
    self.ShopGoodsNumber = num

    if self.ShopGoodsNumber < 0 then
        self.ShopGoodsNumber = 0
    elseif self.ShopGoodsNumber > self.data.max_count then
        self.ShopGoodsNumber = self.data.max_count
        gf:ShowSmallTips(string.format(CHS[4200157], self.data.max_count))
    end

    self:setShopPanel()

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(self.ShopGoodsNumber)
    end
end

function ConvenientBuyTXSDlg:blindPress(name)
    local widget = self:getControl(name,nil,self.root)

    if not widget then
        Log:W("Dialog:bindListViewListener no control " .. name)
        return
    end
    -- longClick为长按的标志位
    local function updataCount(longClick)
        if self.touchStatus == TOUCH_BEGAN  then
            if self.clickBtn == "AddButton" then
                self:onAddButton(longClick)
            elseif self.clickBtn == "ReduceButton" then
                self:onReduceButton(longClick)
            end
        elseif self.touchStatus == TOUCH_END then

        end
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.clickBtn = sender:getName()
            self.touchStatus = TOUCH_BEGAN
            schedule(widget , function() updataCount(true) end, 0.1)
        elseif eventType == ccui.TouchEventType.moved then
        else
            updataCount()
            self.touchStatus = TOUCH_END
            widget:stopAllActions()
        end
    end

    widget:addTouchEventListener(listener)
end

function ConvenientBuyTXSDlg:onReduceButton(longClick)
    if lastClick ~= "addButton" then self.clickButtonTime = 0 end
    if not self.data then return end
    if self.ShopGoodsNumber <= 1 then
        gf:ShowSmallTips(CHS[6000034])
    else
        self.ShopGoodsNumber = self.ShopGoodsNumber - 1
        if longClick then
            self.clickButtonTime = -1
        else
            self.clickButtonTime = self.clickButtonTime + 1
            if self.clickButtonTime == 3 then
                gf:ShowSmallTips(CHS[3003173])
            end
        end
    end
    self:setShopPanel()
    lastClick = "reduceButton"
end

function ConvenientBuyTXSDlg:onAddButton(longClick)
    if lastClick ~= "addButton" then self.clickButtonTime = 0 end
    if not self.data then return end

    if self.ShopGoodsNumber >= self.data.max_count then
        gf:ShowSmallTips(string.format(CHS[4200157], self.data.max_count))
    else
        self.ShopGoodsNumber = self.ShopGoodsNumber + 1
    end

    self:setShopPanel()
    lastClick = "addButton"
end

function ConvenientBuyTXSDlg:onBuyButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if not self.data then return end

    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3002947])
        return
    end

    if Me:queryBasicInt("level") < 70 then
        gf:ShowSmallTips(CHS[4200158])
        self:onCloseButton()
        return
    end

    if self.radio:getSelectedState() then
        local price = self.data.price * self.ShopGoodsNumber
        if Me:queryBasicInt("gold_coin") < price then
            gf:askUserWhetherBuyCoin("gold_coin")
        else
            gf:confirm(string.format(CHS[4200165], price, self.ShopGoodsNumber), function ()
                gf:CmdToServer("CMD_EXCHANGE_GOODS", {
                    type = 3,
                    name = "gold_coin",
                    amount = self.ShopGoodsNumber,
                })
            end)
        end
    else
        local silver = Me:queryBasicInt("silver_coin")
        local gold = Me:queryBasicInt("gold_coin") -- 可能为负
        local totalPrice = self.data.price * self.ShopGoodsNumber
        if silver < totalPrice and silver + gold < totalPrice then
            gf:askUserWhetherBuyCoin()
        else
            local tip = string.format(CHS[4200159], totalPrice, self.ShopGoodsNumber)
            if silver < self.data.price * self.ShopGoodsNumber then
                tip = string.format(CHS[4200160], totalPrice, totalPrice - silver, self.ShopGoodsNumber)
            end
            gf:confirm(tip, function ()
                gf:CmdToServer("CMD_EXCHANGE_GOODS", {
                    type = 3,
                    name = "",
                    amount = self.ShopGoodsNumber,
                })

            end)
        end
    end
    self:onCloseButton()
end

function ConvenientBuyTXSDlg:onAddGoldButton(sender, eventType)
    local onlineTabDlg = DlgMgr.dlgs["OnlineMallTabDlg"]

    -- 需要延迟一帧，释放按钮
    if onlineTabDlg then
        onlineTabDlg.group:setSetlctByName("RechargeCheckBox")
    else
        DlgMgr:openDlg("OnlineRechargeDlg")
        DlgMgr.dlgs["OnlineMallTabDlg"].group:setSetlctByName("RechargeCheckBox")
    end
end

-- 刷新金钱
function ConvenientBuyTXSDlg:MSG_UPDATE()
    self:refreshInfo()
end

function ConvenientBuyTXSDlg:MSG_INVENTORY()
    self:refreshInfo()
end

return ConvenientBuyTXSDlg
