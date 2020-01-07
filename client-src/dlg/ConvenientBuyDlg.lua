-- ConvenientBuyDlg.lua
-- Created by sujl, Apr/12
-- 快捷购买窗口

local ConvenientBuyDlg = Singleton("ConvenientBuyDlg", Dialog)

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

function ConvenientBuyDlg:init()
    self:blindPress("ReduceButton")
    self:blindPress("AddButton")
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("GoldBackImage", self.onAddGoldButton)

    self.radio = self:getControl("CheckBox", Const.UICheckBox, "CoinTypePanel")
    self.radio:setSelectedState(OnlineMallMgr.isUseGold)

    self:setNeedGotoOnline(false)

    -- 打开数字键盘
    self:bindNumInput("NumberValueImage")

    local function checkBoxClick(self, sender, eventType)
        lastClick = "checkBox"
        if eventType == ccui.CheckBoxEventType.selected then
            gf:ShowSmallTips(CHS[3003170])
            OnlineMallMgr.isUseGold = true
            self:setShopPanel(true)
        elseif eventType == ccui.CheckBoxEventType.unselected then
            gf:ShowSmallTips(CHS[3003171])
            OnlineMallMgr.isUseGold = false
            self:setShopPanel(true)
        end
    end

    self.openFrom = nil

    self:bindCheckBoxWidgetListener(self.radio, checkBoxClick)

    self:refreshInfo()
    self:setShopPanel()

    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_BUY_FROM_MALL_RESULT")
end

function ConvenientBuyDlg:refreshInfo()
    local meSiliverStr = gf:getArtFontMoneyDesc(Me:queryBasicInt("silver_coin"))
    self:setNumImgForPanel("SilverValuePanel", ART_FONT_COLOR.DEFAULT, meSiliverStr, false, LOCATE_POSITION.CENTER, 21)
    local meGoldStr = gf:getArtFontMoneyDesc(Me:queryBasicInt("gold_coin"))
    self:setNumImgForPanel("GoldValuePanel", ART_FONT_COLOR.DEFAULT, meGoldStr, false, LOCATE_POSITION.CENTER, 21)
    self:updateLayout("SilverValuePanel")
    self:updateLayout("GoldValuePanel")
end

-- 商城数据回来刷新
function ConvenientBuyDlg:initData()
    self.ShopGoodsNumber = 0  -- 道具默认购买数量是1
    self.goodsTable = OnlineMallMgr:getOnlineMallList()

    -- 设置金钱信息
    self:refreshInfo()
end

-- 设置界面打开来源
function ConvenientBuyDlg:setOpenFrom(from)
    self.openFrom = from
end

function ConvenientBuyDlg:setNeedGotoOnline(isNeed)
    self.isNeedGotoOnline = isNeed
end

function ConvenientBuyDlg:onDlgOpened(items)
    self.items = items
    self:setCurretBuyGoods()
end

function ConvenientBuyDlg:setCurretBuyGoods()
    if not self.items then return end
    self.selectGoods = nil
    for i = 1, #self.goodsTable do
        local goods = self.goodsTable[i]
        if self.items[goods.name] and (not goods["sale_quota"] or goods["sale_quota"] == -1) then
            self.selectGoods = goods
            break
        end
    end

    if self.selectGoods then
        self.ShopGoodsNumber = self.items[self.selectGoods.name]
        self:setShopPanel()
        self:refreshBuyGoods()
        self.shopLimit = InventoryMgr:isCanAddToBag(self.selectGoods["name"], CONST_DATA.shopLimit, OnlineMallMgr.isUseGold and 0 or self.selectGoods["coin"])
        self.items[self.selectGoods.name] = nil
    else
        DlgMgr:closeDlg(self.name)
    end
end

function ConvenientBuyDlg:refreshBuyGoods()
    if not self.selectGoods then return end

    -- 道具图片
    local goodsImage = self:getControl("GoodsImage", Const.UIImage, goodsCell)
    local imgPath = InventoryMgr:getIconFileByName(self.selectGoods.name)
    goodsImage:loadTexture(imgPath)
    self:setItemImageSize("GoodsImage", goodsCell)

    -- 金银元宝
    self:setCtrlVisible("GoldImage_2", self.selectGoods["for_sale"] == 1)
    self:setCtrlVisible("SilverImage_2", self.selectGoods["for_sale"] == 2)

    -- 道具名称
    self:setLabelText("Label_0", self.selectGoods.name, "Image_2_0_1")

    --物品价格
    local goodPrice = gf:getArtFontMoneyDesc(self.selectGoods["coin"])
    self:setLabelText("Label", goodPrice, "Image_2_0_1")
end

-- 购买物品信息
function ConvenientBuyDlg:setShopPanel(refreshShopLimit)
    if not self.items or not self.selectGoods then self:refreshGoldIcon() return end
    local goodsData = self.selectGoods

    if refreshShopLimit then
        self.shopLimit = InventoryMgr:isCanAddToBag(self.selectGoods["name"], CONST_DATA.shopLimit, OnlineMallMgr.isUseGold and 0 or self.selectGoods["coin"])
        self.ShopGoodsNumber = math.min(self.ShopGoodsNumber, self.shopLimit)
    end

    -- 购买道具数量
    local numberImage = self:getControl("NumberValueImage")
    local numberLabel = self:getControl("NumberLabel", Const.UILabel, numberImage)
    numberLabel:setString(self.ShopGoodsNumber)
    local numberLabel1 = self:getControl("NumberLabel_1", Const.UILabel, numberImage)
    numberLabel1:setString(self.ShopGoodsNumber)

    -- 购买道具总价

    local buyButton = self:getControl("BuyButton")
    local totalPrice = self.ShopGoodsNumber * goodsData["coin"]
    local totalNumberLabel = self:getControl("NumLabel", Const.UILabel, buyButton)
    totalNumberLabel:setString(totalPrice)
    local totalNumberLabel1 = self:getControl("NumLabel_1", Const.UILabel, buyButton)
    totalNumberLabel1:setString(totalPrice)

    self:refreshGoldIcon()
end

function ConvenientBuyDlg:refreshGoldIcon()
    local buyButton = self:getControl("BuyButton")
    local goldImage = self:getControl("GoldImage", Const.UIImage, buyButton)
    local silverImage = self:getControl("SilverImage", Const.UIImage, buyButton)
    local showGold = OnlineMallMgr.isUseGold or (self.selectGoods and 1 == self.selectGoods["for_sale"])
    goldImage:setVisible(showGold)
    silverImage:setVisible(not showGold)
end

-- 数字键盘插入数字
function ConvenientBuyDlg:insertNumber(num)

    self.ShopGoodsNumber = num

    if self.ShopGoodsNumber < 0 then
        self.ShopGoodsNumber = 0
    end

    -- 限购道具
    local goodsData = self.selectGoods
    if self:isQuotaItem() and not self:isCanBuyQuotaItemByNum(num) then
        self.ShopGoodsNumber = math.max(goodsData.sale_quota, 0)
    else
        if num > self.shopLimit then
            if self.shopLimit == CONST_DATA.shopLimit then
                gf:ShowSmallTips(CHS[6000035])
            else
                gf:ShowSmallTips(CHS[6000150])
            end

            self.ShopGoodsNumber = math.max(self.shopLimit, 0)
        end
    end

    self:setShopPanel()

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(self.ShopGoodsNumber)
    end
end

function ConvenientBuyDlg:isQuotaItem()
    local goodsData = self.selectGoods

    if goodsData.sale_quota ~= -1 then
        return true
    end
end

function ConvenientBuyDlg:isCanBuyQuotaItemByNum(num)
    local goodsData = self.selectGoods
    local discountTime = goodsData["discountTime"]
    local soldOutTip = CHS[7000209]
    local hasQuotaTip = CHS[7000208]

    if goodsData.sale_quota == 0 then
        gf:ShowSmallTips(string.format(soldOutTip, goodsData.quota_limit or 0))
        return false
    else
        if num > goodsData.sale_quota then
            gf:ShowSmallTips(string.format(hasQuotaTip, goodsData.sale_quota))
            return false
        else
            return true
        end
    end
end

function ConvenientBuyDlg:blindPress(name)
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

function ConvenientBuyDlg:onReduceButton(longClick)
    if lastClick ~= "reduceButton" then self.clickButtonTime = 0 end
    if not self.selectGoods then return gf:ShowSmallTips(CHS[3003169]) end
    if self.selectGoods then
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
end

function ConvenientBuyDlg:onAddButton(longClick)
    if lastClick ~= "addButton" then self.clickButtonTime = 0 end
    if not self.selectGoods then return gf:ShowSmallTips(CHS[3003169]) end

    if self:isQuotaItem() and not self:isCanBuyQuotaItemByNum(self.ShopGoodsNumber + 1) then -- 超过配额
        return
    elseif self.ShopGoodsNumber >= self.shopLimit then
        if self.shopLimit == CONST_DATA.shopLimit then
            gf:ShowSmallTips(CHS[6000035])
        else
            gf:ShowSmallTips(CHS[6000150])
        end
    else
        self.ShopGoodsNumber = self.ShopGoodsNumber + 1
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
    lastClick = "addButton"
end

function ConvenientBuyDlg:onBuyButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    lastClick = "buyButton"
    if self.ShopGoodsNumber < 1 then
        gf:ShowSmallTips(CHS[3003175])
        return
    end

    if not self.selectGoods then return gf:ShowSmallTips(CHS[3003169]) end


    local function buyItems()
        local goodsData = self.selectGoods

        if self:isQuotaItem() and goodsData["discountTime"] < gf:getServerTime() then
                gf:ShowSmallTips(CHS[6000231])
                OnlineMallMgr:openOnlineMall()
                return
            end

        if not Me:isVip() and goodsData["must_vip"] == 1 then  gf:ShowSmallTips(CHS[6000230]) return end

        local totalMoney = 0
        local isGold = ""
        local coinType = ""
        if  goodsData["for_sale"] == CONST_DATA.goldCoin then
            totalMoney = Me:getGoldCoin()
            isGold = "gold_coin"
            coinType = CHS[3003176]
        elseif goodsData["for_sale"] == CONST_DATA.silverCoin then
            totalMoney = Me:getTotalCoin()
            if Me:getSilverCoin() < 0 then totalMoney = Me:getGoldCoin() end
            coinType = CHS[3003177]
        end

        if self.radio:getSelectedState() and Me:getGoldCoin() < goodsData["coin"] then
            gf:askUserWhetherBuyCoin("gold_coin")
            return
        end

        if totalMoney < goodsData["coin"] * self.ShopGoodsNumber then
            gf:askUserWhetherBuyCoin(isGold)
        else
            -- (其中#RNum2#n个以金元宝替代)
            local showMessage = CHS[3003178]
            local showExtra = CHS[3003179]

            if not self.radio:getSelectedState() then

                if goodsData["for_sale"] ~= CONST_DATA.goldCoin then
                    if Me:getSilverCoin() >= goodsData["coin"] * self.ShopGoodsNumber then
                        showExtra = ""
                    else
                        -- 银元宝如果未负，则计算消耗的金元时，银元宝用0计算
                        local realUseSilver = Me:queryInt("silver_coin")
                        if realUseSilver < 0 then realUseSilver = 0 end
                        showExtra = string.format(showExtra, (goodsData["coin"] * self.ShopGoodsNumber - realUseSilver))
                        coinType = CHS[3003177]
                    end
                else
                    showExtra = ""
                    coinType = CHS[3003176]
                end
            else
                showExtra = ""
                coinType = CHS[3003176]
            end

            showMessage = string.format(showMessage,
                goodsData["coin"] * self.ShopGoodsNumber,
                coinType,
                showExtra,
                self.ShopGoodsNumber,
                InventoryMgr:getUnit(goodsData["name"]),
                goodsData["name"])

            local data = {}
            data["barcode"] = goodsData["barcode"]
            data["amount"] = self.ShopGoodsNumber
            data["coin_pwd"] = ""

            if self.radio:getSelectedState() then
                data["coin_type"] = "gold_coin"
            else
                data["coin_type"] = ""
            end

            gf:confirm(showMessage, function()
                OnlineMallMgr:buyGoods(data)
            end)
        end
    end

    if self.isNeedGotoOnline then
        local itemName = self.selectGoods.name
        gf:confirm(CHS[4101055], function ()
            -- 请求商城信息
			OnlineMallMgr:openOnlineMall("OnlineMallDlg", nil, {[itemName] = 1})
        end, function ()
        	buyItems()
        end)
        return
    else
        buyItems()
    end
end

function ConvenientBuyDlg:onAddGoldButton(sender, eventType)
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
function ConvenientBuyDlg:MSG_UPDATE()
    self:refreshInfo()
end

function ConvenientBuyDlg:MSG_INVENTORY()
    if self.selectGoods then
        self:setShopPanel()
        self:refreshBuyGoods()
        self.shopLimit = InventoryMgr:isCanAddToBag(self.selectGoods["name"], CONST_DATA.shopLimit, OnlineMallMgr.isUseGold and 0 or self.selectGoods["coin"])
    end
end

function ConvenientBuyDlg:MSG_BUY_FROM_MALL_RESULT(data)
    if not self.selectGoods or self.selectGoods.barcode ~= data.barcode then
        return
    end

    if data.result == 1 then
        self:setCurretBuyGoods()
    end
end

function ConvenientBuyDlg:cleanup()
    OnlineMallMgr:cmdBuyItemResult(self.openFrom, 0)
end

return ConvenientBuyDlg
