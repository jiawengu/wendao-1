-- DiscountDlg.lua
-- Created by sujl, Nov/12/2016
-- 幸运折扣券界面

local DiscountDlg = Singleton("DiscountDlg", Dialog)

local panels = {}
panels[CHS[2000188]] = "CouponPanel_1"
panels[CHS[2000189]] = "CouponPanel_2"
panels[CHS[2000190]] = "CouponPanel_3"

local MAX_DISCOUNT_NUM = 5000

function DiscountDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("MinusButton", self.onReduce1Button, "CouponPanel_1")
    self:bindListener("PlusButton", self.onAdd1Button, "CouponPanel_1")
    self:bindListener("MinusButton", self.onReduce5Button, "CouponPanel_2")
    self:bindListener("PlusButton", self.onAdd5Button, "CouponPanel_2")
    self:bindListener("MinusButton", self.onReduce9Button, "CouponPanel_3")
    self:bindListener("PlusButton", self.onAdd9Button, "CouponPanel_3")
    self:bindListener("CheckAllButton", self.onCheckAllButton)
    self:bindListener("EmptyButton", self.onEmptyButton)
    self:bindListener("GoldImage_1", self.onAddGoldButton, "MoneyPanel")

    self:bindListener("ItemShapePanel", self.onCouponPanel1, "CouponPanel_1")
    self:bindListener("ItemShapePanel", self.onCouponPanel2, "CouponPanel_2")
    self:bindListener("ItemShapePanel", self.onCouponPanel3, "CouponPanel_3")

    -- 优惠券
    self.coupons = InventoryMgr:getDiscountCoupon()

    local isTestDist = DistMgr:curIsTestDist()
    self:setCtrlVisible("RuleLabel_1", not isTestDist, "RulePanel")
    self:setCtrlVisible("RuleLabel_2", not isTestDist, "RulePanel")
    self:setCtrlVisible("RuleLabel_3", isTestDist, "RulePanel")
    self:setCtrlVisible("RuleLabel_4", isTestDist, "RulePanel")

    -- 设置优惠券图标
    self:setCouponIcon("CouponPanel_1", CHS[2000188])
    self:setCouponIcon("CouponPanel_2", CHS[2000189])
    self:setCouponIcon("CouponPanel_3", CHS[2000190])

    self:hookMsg("MSG_INVENTORY")
end

function DiscountDlg:cleanup()
    self.coupons = nil
    self.goodsData = nil
    self.num = 0
end

function DiscountDlg:setData(goodsData, num)
    if not goodsData then return end

    self.goodsData = goodsData
    self.num = num or 1

    -- 道具图片
    local goodsImage = self:getControl("ItemImage", Const.UIImage, "GoodsInfoPanel")
    local imgPath = InventoryMgr:getIconFileByName(goodsData.name)
    goodsImage:loadTexture(imgPath)
    self:setItemImageSize("ItemImage", "GoodsInfoPanel")

    -- 道具名字
    local nameLabel = self:getControl("TextLabel", Const.UILabel, self:getControl("NameImage", Const.UIPanel, "GoodsInfoPanel"))
    nameLabel:setString(goodsData["name"])

    local priceTextPanel = self:getControl("PriceTextPanel", Const.UILabel, "GoodsInfoPanel")

    -- 道具数量
    self:setLabelText("NumLabel_2", num, priceTextPanel)

    -- 道具原价
    self:setLabelText("OriginalLabel_2", tonumber(goodsData.coin) * num, priceTextPanel)

    -- 当前携带元宝
    local cashText, _ = gf:getArtFontMoneyDesc(tonumber(OnlineMallMgr.isUseGold and Me:queryBasicInt("gold_coin") or Me:queryBasicInt("silver_coin")))
    self:setNumImgForPanel("GoldValuePanel", ART_FONT_COLOR.DEFAULT, cashText,
        false, LOCATE_POSITION.LEFT_BOTTOM, 21, "MoneyPanel")
    self:updateLayout("GoldValuePanel", "MoneyPanel")

    -- 更新元宝图片
    if OnlineMallMgr.isUseGold then
        self:setCtrlVisible("OriginalImage_1", true, priceTextPanel)
        self:setCtrlVisible("OriginalImage_2", false, priceTextPanel)
        self:setCtrlVisible("PresentImage_1", true, priceTextPanel)
        self:setCtrlVisible("PresentImage_2", false, priceTextPanel)
        self:setCtrlVisible("GoldImage_1", true, "MoneyPanel")
        self:setCtrlVisible("GoldImage_2", false, "MoneyPanel")
    else
        self:setCtrlVisible("OriginalImage_1", 1 == goodsData["for_sale"], priceTextPanel)
        self:setCtrlVisible("OriginalImage_2", 2 == goodsData["for_sale"], priceTextPanel)
        self:setCtrlVisible("PresentImage_1", 1 == goodsData["for_sale"], priceTextPanel)
        self:setCtrlVisible("PresentImage_2", 2 == goodsData["for_sale"], priceTextPanel)
        self:setCtrlVisible("GoldImage_1", 1 == goodsData["for_sale"], "MoneyPanel")
        self:setCtrlVisible("GoldImage_2", 2 == goodsData["for_sale"], "MoneyPanel")
    end

    self:refreshCouponCount(num)
end

function DiscountDlg:refreshCouponCount(num)
    local count1, count5, coun9

    count1 = math.min(num, self.coupons[CHS[2000188]] or 0)
    self:setCouponNum(CHS[2000188], count1, true)

    num = math.max(num - count1, 0)
    count5 = math.min(num, self.coupons[CHS[2000189]] or 0)
    self:setCouponNum(CHS[2000189], count5, true)

    num = math.max(num - count5, 0)
    count9 = math.min(num, self.coupons[CHS[2000190]] or 0)
    self:setCouponNum(CHS[2000190], count9, true)

    self:refreshCouponButton()
    self:refreshPrice()
end

function DiscountDlg:refreshPrice()
    if not self.goodsData then return end

    local count1 = tonumber(self:getLabelText("NumLabel", "CouponPanel_1")) or 0
    local count5 = tonumber(self:getLabelText("NumLabel", "CouponPanel_2")) or 0
    local count9 = tonumber(self:getLabelText("NumLabel", "CouponPanel_3")) or 0

    local price = tonumber(self.goodsData.coin) or 0
    local total = math.max(math.ceil(price * 0.1), price - MAX_DISCOUNT_NUM) * count1 
                    + math.max(math.ceil(price * 0.5), price - MAX_DISCOUNT_NUM) * count5
                    + math.max(math.ceil(price * 0.9), price - MAX_DISCOUNT_NUM) * count9
                    + price * math.max(self.num - count1 - count5 - count9, 0)

    -- 道具现价
    self:setLabelText("PresentLabel_2", total, self:getControl("PriceTextPanel", Const.UILabel, "GoodsInfoPanel"))
end

function DiscountDlg:setCouponIcon(coupon, name)
    local goodsImage = self:getControl("ItemImage", Const.UIImage, self:getControl(coupon, Const.UIPanel, "DiscountInfoPanel"))
    local imgPath = InventoryMgr:getIconFileByName(name)
    goodsImage:loadTexture(imgPath)
    self:setItemImageSize("ItemImage", "DiscountInfoPanel")

    local items = InventoryMgr:getItemByName(name)
    local num = 0
    if items and #items > 0 then
        for i = 1, #items do
            num = num + items[i].amount
        end
    end
    self:setNumImgForPanel(goodsImage, ART_FONT_COLOR.NORMAL_TEXT, num,
                                 false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
end

function DiscountDlg:refreshCouponButton()
    local nums = {}
    local num, count
    local total = 0
    for name, panel in pairs(panels) do
        nums[name] = tonumber(self:getLabelText("NumLabel", panel)) or 0
        total = total + nums[name]
    end

    local plusEnabled = total < (self.num or 0)

    for name, panel in pairs(panels) do
        count = self.coupons[name] or 0
        num = nums[name]
        self:setCtrlEnabled("MinusButton", num > 0, panel)
        self:setCtrlEnabled("PlusButton", num < count and count > 0 and plusEnabled, panel)
    end
end

function DiscountDlg:setCouponNum(name, num, dontRefreshButton)
    local panel = panels[name]
    if not panel then return end

    self:setLabelText("NumLabel", num, panel)

    --[[
    local count = self.coupons[name] or 0
    self:setCtrlEnabled("MinusButton", num > 0, panel)
    local total = self:calcUsedCoupon()
    self:setCtrlEnabled("PlusButton", num < count and count > 0 and total < (self.num or 0), panel)
    ]]
    if not dontRefreshButton then
        self:refreshCouponButton()
        self:refreshPrice()
    end
end

-- 显示道具悬浮
function DiscountDlg:showItemInfo(itemName, sender)
    -- 显示道具悬浮
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(itemName, rect)
end

-- 购买
function DiscountDlg:onBuyButton(sender, eventType)
    if not self.goodsData or not self.num then return end

    local count1 = tonumber(self:getLabelText("NumLabel", "CouponPanel_1")) or 0
    local count5 = tonumber(self:getLabelText("NumLabel", "CouponPanel_2")) or 0
    local count9 = tonumber(self:getLabelText("NumLabel", "CouponPanel_3")) or 0

    if 0 == count1 and 0 == count5 and 0 == count9 then
        DlgMgr:sendMsg("OnlineMallDlg", "doBuyGoods", self.goodsData)
        DlgMgr:closeDlg(self.name)
        return
    end

    -- 检查优惠券有效期
    local hasInvalidCoupont = false
    local costDesc = {}
    if count1 > 0 then
        hasInvalidCoupont = hasInvalidCoupont or (not InventoryMgr:isCouponValid(CHS[2000188]))
        table.insert(costDesc, string.format(CHS[2200003], count1, CHS[2000188]))
    end
    if count5 > 0 then
        hasInvalidCoupont = hasInvalidCoupont or (not InventoryMgr:isCouponValid(CHS[2000189]))
        table.insert(costDesc, string.format(CHS[2200003], count5, CHS[2000189]))
    end
    if count9 > 0 then
        hasInvalidCoupont = hasInvalidCoupont or (not InventoryMgr:isCouponValid(CHS[2000190]))
        table.insert(costDesc, string.format(CHS[2200003], count9, CHS[2000190]))
    end

    if hasInvalidCoupont then
        gf:ShowSmallTips(CHS[2000191])
        return
    end

    local totalMoney = tonumber(self:getLabelText("PresentLabel_2", self:getControl("PriceTextPanel", Const.UILabel, "GoodsInfoPanel"))) or 0
    local isGold = OnlineMallMgr.isUseGold

    if (isGold and Me:queryBasicInt("gold_coin") < totalMoney) or (not isGold and Me:queryBasicInt("gold_coin") + Me:queryBasicInt("silver_coin") < totalMoney) then
        gf:askUserWhetherBuyCoin("gold_coin")
        return
    end

    -- (其中#RNum2#n个以金元宝替代)
    local showMessage = CHS[3003178]
    local showExtra = CHS[3003179]

    if not isGold then
        local realUseSilver = Me:queryInt("silver_coin")
        if realUseSilver < totalMoney then
            showExtra = string.format(showExtra, (totalMoney - realUseSilver))
        else
            showExtra = ""
        end
        coinType = CHS[3003177]
    else
        showExtra = ""
        coinType = CHS[3003176]
    end

    showMessage = string.format(showMessage,
        totalMoney,
        coinType,
        showExtra,
        self.num,
        InventoryMgr:getUnit(self.goodsData["name"]),
        self.goodsData["name"])

    if #costDesc > 0 then
        showMessage = showMessage .. "\n" .. string.format(CHS[2200002], table.concat(costDesc, CHS[2100019]))
    end

    local data = {}
    data["barcode"] = self.goodsData["barcode"]
    data["amount"] = self.num
    data["coin_pwd"] = ""

    if isGold then
        data["coin_type"] = "gold_coin"
    else
        data["coin_type"] = ""
    end

    data["coupon_str"] = string.format("%d|%d|%d", count9, count5, count1)

    -- 安全锁判断
    if self:checkSafeLockRelease("onBuyButton") then
        return
    end

    gf:confirm(showMessage, function()
        OnlineMallMgr:buyGoodsWithCoupon(data)
        DlgMgr:closeDlg(self.name)
    end)
end

function DiscountDlg:onReduce1Button(sender, eventType)
    local count = tonumber(self:getLabelText("NumLabel", "CouponPanel_1")) or 0
    if count > 0 then
        count = count - 1
        self:setCouponNum(CHS[2000188], count)
    end
end

function DiscountDlg:onAdd1Button(sender, eventType)
    local count = tonumber(self:getLabelText("NumLabel", "CouponPanel_1")) or 0
    local total = self.coupons[CHS[2000188]] or 0
    if count < total then
        count = count + 1
        self:setCouponNum(CHS[2000188], count)
    end
end

function DiscountDlg:onReduce5Button(sender, eventType)
    local count = tonumber(self:getLabelText("NumLabel", "CouponPanel_2")) or 0
    if count > 0 then
        count = count - 1
        self:setCouponNum(CHS[2000189], count)
    end
end

function DiscountDlg:onAdd5Button(sender, eventType)
    local count = tonumber(self:getLabelText("NumLabel", "CouponPanel_2")) or 0
    local total = self.coupons[CHS[2000189]] or 0
    if count < total then
        count = count + 1
        self:setCouponNum(CHS[2000189], count)
    end
end

function DiscountDlg:onReduce9Button(sender, eventType)
    local count = tonumber(self:getLabelText("NumLabel", "CouponPanel_3")) or 0
    if count > 0 then
        count = count - 1
        self:setCouponNum(CHS[2000190], count)
    end
end

function DiscountDlg:onAdd9Button(sender, eventType)
    local count = tonumber(self:getLabelText("NumLabel", "CouponPanel_3")) or 0
    local total = self.coupons[CHS[2000190]] or 0
    if count < total then
        count = count + 1
        self:setCouponNum(CHS[2000190], count)
    end
end

function DiscountDlg:onCheckAllButton(sender, eventType)
    if self.num then
        self:refreshCouponCount(self.num)
    end
end

function DiscountDlg:onEmptyButton(sender, eventType)
    self:setCouponNum(CHS[2000188], 0, true)
    self:setCouponNum(CHS[2000189], 0, true)
    self:setCouponNum(CHS[2000190], 0, true)
    self:refreshCouponButton()
    self:refreshPrice()
end

function DiscountDlg:onAddGoldButton(sender, eventType)
    local onlineTabDlg = DlgMgr.dlgs["OnlineMallTabDlg"]

    -- 需要延迟一帧，释放按钮
    performWithDelay(sender, function()
        if onlineTabDlg then
            onlineTabDlg.group:setSetlctByName("RechargeCheckBox")
        else
            DlgMgr:openDlg("OnlineRechargeDlg")
            DlgMgr.dlgs["OnlineMallTabDlg"].group:setSetlctByName("RechargeCheckBox")
        end
    end, 0)
end

function DiscountDlg:onCouponPanel1(sender, eventType)
    -- 显示道具悬浮
    self:showItemInfo(CHS[2000188], sender)
end


function DiscountDlg:onCouponPanel2(sender, eventType)
    -- 显示道具悬浮
    self:showItemInfo(CHS[2000189], sender)
end


function DiscountDlg:onCouponPanel3(sender, eventType)
    -- 显示道具悬浮
    self:showItemInfo(CHS[2000190], sender)
end

function DiscountDlg:MSG_INVENTORY(data)
    self.coupons = InventoryMgr:getDiscountCoupon()

    if self.num then
        self:refreshCouponCount(self.num)
    end
end

return DiscountDlg