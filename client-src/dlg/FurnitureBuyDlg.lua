-- FurnitureBuyDlg.lua
-- Create by sujl, Jun/22/2017
-- 家具购买界面

local FurnitureBuyDlg = Singleton("FurnitureBuyDlg", Dialog)

local FurnitureInfo = require ("cfg/FurnitureInfo")

local lastClick

local TOUCH_BEGAN  = 1
local TOUCH_END    = 2

function FurnitureBuyDlg:init(args)
    self:blindPress("ReduceButton")
    self:blindPress("AddButton")
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("GoldBackImage", self.onAddGoldButton)

    -- 打开数字键盘
    self:bindNumInput("NumberValueImage")

    self.itemName = args
    local info = HomeMgr:getFurnitureInfo(self.itemName)
    self.costType = info and info.purchase_type or 1

    self.shopLimit = 100
    self.ShopGoodsNumber = 1

    self:refreshInfo()
    self:refreshBuyGoods()
    self:setShopPanel()

    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_INVENTORY")
end

function FurnitureBuyDlg:cleanup()
    lastClick = nil
end

function FurnitureBuyDlg:getUnit()
    if 1 == self.costType then
        return 10000
    else
        return 1
    end
end

function FurnitureBuyDlg:getMeMoney()
    if 1 == self.costType then
        return Me:queryBasicInt("cash")
    else
        return Me:queryBasicInt("gold_coin")
    end
end

function FurnitureBuyDlg:refreshInfo()
    local meGoldStr, color = gf:getArtFontMoneyDesc(self:getMeMoney())
    if self.costType ~= 1 then
        color = ART_FONT_COLOR.DEFAULT
    end

    self:setNumImgForPanel("GoldValuePanel", color, meGoldStr, false, LOCATE_POSITION.MID, 21)
    self:updateLayout("GoldValuePanel")

    self:setCtrlVisible("CostImage_Cash", 1 == self.costType, "GoodsPanel")
    self:setCtrlVisible("CostImage_Gold", 2 == self.costType, "GoodsPanel")

    self:setCtrlVisible("GoldImage_Cash", 1 == self.costType, "HavePanel")
    self:setCtrlVisible("GoldImage_Gold", 2 == self.costType, "HavePanel")

    self:setCtrlVisible("CostImage_Cash", 1 == self.costType, "BuyButton")
    self:setCtrlVisible("CostImage_Gold", 2 == self.costType, "BuyButton")
end

function FurnitureBuyDlg:refreshBuyGoods()
    local info = FurnitureInfo[self.itemName]

    -- 道具图片
    local iconPath = ResMgr:getItemIconPath(info.icon)
    self:setImage("GoodsImage", iconPath, "GoodsPanel")

    -- 道具名称
    self:setLabelText("NameLabel", self.itemName, "GoodsPanel")

    --物品价格
    local price = info.purchase_cost * self:getUnit()
    local priceStr, color = gf:getArtFontMoneyDesc(price)
    if self.costType ~= 1 then
        color = ART_FONT_COLOR.DEFAULT
    end
    
    self:setNumImgForPanel("CostPanel", color, priceStr, false, LOCATE_POSITION.CENTER, 21, "GoodsPanel")
    self:updateLayout("CostPanel", "BuyButton")
end

-- 数字键盘插入数字
function FurnitureBuyDlg:insertNumber(num)
    local info = FurnitureInfo[self.itemName]

    if num < 0 then
        num = 0
        -- gf:ShowSmallTips(CHS[2000339])
    elseif (HomeMgr:isWall(self.itemName) or HomeMgr:isFloor(self.itemName)) and num > 1 then
        num = 1
        gf:ShowSmallTips(CHS[2100091])
    end

    -- 限购道具
    if num > self.shopLimit then
        gf:ShowSmallTips(CHS[2000340])
        num = math.min(self.shopLimit, num)
    end

    if num * info.purchase_cost * self:getUnit() > 2000000000 then
        num = self.ShopGoodsNumber
        gf:ShowSmallTips(CHS[2000341])
    end

    self.ShopGoodsNumber = num
    self:setShopPanel()

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(self.ShopGoodsNumber)
    end
end

function FurnitureBuyDlg:blindPress(name)
    local widget = self:getControl(name,nil,self.root)

    if not widget then
        Log:W("Dialog:bindListViewListener no control " .. name)
        return
    end
    -- longClick为长按的标志位
    local function upateCount(longClick)
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
            schedule(widget , function() upateCount(true) end, 0.1)
        elseif eventType == ccui.TouchEventType.moved then
        else
            upateCount()
            self.touchStatus = TOUCH_END
            widget:stopAllActions()
        end
    end

    widget:addTouchEventListener(listener)
end

-- 购买物品信息
function FurnitureBuyDlg:setShopPanel()
    local info = FurnitureInfo[self.itemName]

    -- 购买道具数量
    local numberImage = self:getControl("NumberValueImage")
    local numberLabel = self:getControl("NumberLabel", Const.UILabel, numberImage)
    numberLabel:setString(self.ShopGoodsNumber)
    local numberLabel1 = self:getControl("NumberLabel_1", Const.UILabel, numberImage)
    numberLabel1:setString(self.ShopGoodsNumber)

    -- 购买道具总价
    local buyButton = self:getControl("BuyButton")
    local totalPrice = self.ShopGoodsNumber * info.purchase_cost * self:getUnit()
    local priceStr, color = gf:getArtFontMoneyDesc(totalPrice)
    if self.costType ~= 1 then
        color = ART_FONT_COLOR.DEFAULT
    end

    self:setNumImgForPanel("CostPanel", color, priceStr, false, LOCATE_POSITION.MID, 21, "BuyButton")
    self:updateLayout("CostPanel", "BuyButton")
end

function FurnitureBuyDlg:doBuyGoods(info)
    gf:CmdToServer('CMD_HOUSE_BUY_FURNITURE', { furniture_id = info.icon, num = self.ShopGoodsNumber, cost = info.purchase_cost * self.ShopGoodsNumber * self:getUnit()})
    self:onCloseButton()
end

function FurnitureBuyDlg:onReduceButton(longClick)
    if lastClick ~= "reduceButton" then self.clickButtonTime = 0 end

    if self.ShopGoodsNumber <= 0 then
        self.ShopGoodsNumber = 0
    else
        self.ShopGoodsNumber = math.max(0, self.ShopGoodsNumber - 1)
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

function FurnitureBuyDlg:onAddButton(longClick)
    if lastClick ~= "addButton" then self.clickButtonTime = 0 end
    local info = FurnitureInfo[self.itemName]
    if (HomeMgr:isWall(self.itemName) or HomeMgr:isFloor(self.itemName)) and self.ShopGoodsNumber >= 1 then
        self.ShopGoodsNumber = 1
        gf:ShowSmallTips(CHS[2100091])
    elseif self.ShopGoodsNumber >= self.shopLimit then
        gf:ShowSmallTips(CHS[2000340])
    elseif (self.ShopGoodsNumber + 1) * info.purchase_cost * self:getUnit() > 2000000000 then
        gf:ShowSmallTips(CHS[2000341])
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

function FurnitureBuyDlg:onBuyButton(sender, eventType)
    local info = FurnitureInfo[self.itemName]
    -- local amount = HomeMgr:getItemCountByName(self.itemName)
    local limit = HomeMgr:getLimitByType(info.furniture_type)
    local amount = 0
    for k, v in pairs(FurnitureInfo) do
        if v.furniture_type == info.furniture_type then
            local items = StoreMgr:getFurnitureByName(k, true)
            for i = 1, #items do
                amount = amount + items[i].amount
            end
        end
    end
    if limit > 0 and self.ShopGoodsNumber + amount > limit then
        gf:ShowSmallTips(CHS[2000334])
        return
    end
    if self.ShopGoodsNumber <= 0 then
        gf:ShowSmallTips(CHS[2100110])
        self.ShopGoodsNumber = 1
        self:setShopPanel()
        return
    end

    if string.match(info.furniture_type, CHS[2000335]) or string.match(info.furniture_type, CHS[2000336]) or string.match(info.furniture_type, CHS[2000337]) then
        local amount = HomeMgr:getItemCountByName(self.itemName)
        if amount > 0 then
            gf:ShowSmallTips(CHS[2000338])
            return
        end
    end
    
    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    local cost = self.ShopGoodsNumber * info.purchase_cost * self:getUnit()
    if cost > self:getMeMoney() then
        if 1 == self.costType then
            gf:askUserWhetherBuyCash(cash)
        else
            gf:askUserWhetherBuyCoin("gold_coin")
        end
        return
    end   

    -- 安全锁判断
    if self:checkSafeLockRelease("doBuyGoods", info) then
        return
    end

    self:doBuyGoods(info)
end

function FurnitureBuyDlg:onAddGoldButton(sender, eventType)
    local onlineTabDlg = DlgMgr.dlgs["OnlineMallTabDlg"]
    gf:showBuyCash()
end

-- 刷新金钱
function FurnitureBuyDlg:MSG_UPDATE()
    self:refreshInfo()
end

function FurnitureBuyDlg:MSG_INVENTORY()
end

return FurnitureBuyDlg