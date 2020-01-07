-- SeedBuyDlg.lua
-- Create by huangzz, Aug/11/2017
-- 种子购买界面

local SeedBuyDlg = Singleton("SeedBuyDlg", Dialog)

local FurnitureInfo = require ("cfg/FurnitureInfo")

function SeedBuyDlg:getCfgFileName()
    return ResMgr:getDlgCfg("FurnitureBuyDlg")
end

function SeedBuyDlg:init(args)
    self:bindListener("ReduceButton", self.onReduceButton)
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("GoldBackImage", self.onAddGoldButton)

    -- 打开数字键盘
    self:bindNumInput("NumberValueImage")

    self.itemName = args
    local info = HomeMgr:getFurnitureInfo(self.itemName)
    self.costType = info and info.purchase_type or 1

    self.shopLimit = 100
    self.ShopGoodsNumber = 1
    
    self.amount = HomeMgr:getAllItemCountByName(self.itemName)

    self:refreshInfo()
    self:refreshBuyGoods()
    self:setShopPanel()
    
    self:setLabelText("TitleLabel_1", CHS[5400164])
    self:setLabelText("TitleLabel_2", CHS[5400164])

    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_STORE")
    self:hookMsg("MSG_INVENTORY")
end

function SeedBuyDlg:cleanup()
    
end

function SeedBuyDlg:getUnit()
    if 1 == self.costType then
        return 10000
    else
        return 1
    end
end

function SeedBuyDlg:getMeMoney()
    if 1 == self.costType then
        return Me:queryBasicInt("cash")
    else
        return Me:queryBasicInt("gold_coin")
    end
end

function SeedBuyDlg:refreshInfo()
    local meGoldStr, color = gf:getArtFontMoneyDesc(self:getMeMoney())
    self:setNumImgForPanel("GoldValuePanel", color, meGoldStr, false, LOCATE_POSITION.MID, 21)
    self:updateLayout("GoldValuePanel")

    self:setCtrlVisible("CostImage_Cash", 1 == self.costType, "GoodsPanel")
    self:setCtrlVisible("CostImage_Gold", 2 == self.costType, "GoodsPanel")

    self:setCtrlVisible("GoldImage_Cash", 1 == self.costType, "HavePanel")
    self:setCtrlVisible("GoldImage_Gold", 2 == self.costType, "HavePanel")

    self:setCtrlVisible("CostImage_Cash", 1 == self.costType, "BuyButton")
    self:setCtrlVisible("CostImage_Gold", 2 == self.costType, "BuyButton")
end

function SeedBuyDlg:refreshBuyGoods()
    local info = FurnitureInfo[self.itemName]

    -- 道具图片
    local iconPath = ResMgr:getItemIconPath(info.icon)
    self:setImage("GoodsImage", iconPath, "GoodsPanel")

    -- 道具名称
    self:setLabelText("NameLabel", self.itemName, "GoodsPanel")

    --物品价格
    local price = info.purchase_cost * self:getUnit()
    local priceStr, color = gf:getArtFontMoneyDesc(price)
    self:setNumImgForPanel("CostPanel", color, priceStr, false, LOCATE_POSITION.CENTER, 21, "GoodsPanel")
    self:updateLayout("CostPanel", "BuyButton")
end

-- 数字键盘插入数字
function SeedBuyDlg:insertNumber(num)
    local info = FurnitureInfo[self.itemName]

    if num <= 0 then
        num = 0
    end

    -- 限购道具
    if num > self.shopLimit and self.shopLimit + self.amount <= 999 then
        gf:ShowSmallTips(CHS[2000340])
        num = math.min(self.shopLimit, num)
    end
    
    if num + self.amount > 999 then
        num = 999 - self.amount
        gf:ShowSmallTips(CHS[5400178])
    end

    if num * (info.purchase_cost * self:getUnit()) > 2000000000 then
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

-- 购买物品信息
function SeedBuyDlg:setShopPanel()
    local info = FurnitureInfo[self.itemName]
    
    local num = self.ShopGoodsNumber
    if num <= 0 then
        self:setCtrlEnabled("ReduceButton", false)
    else
        self:setCtrlEnabled("ReduceButton", true)
    end

    -- 购买道具数量
    local numberImage = self:getControl("NumberValueImage")
    local numberLabel = self:getControl("NumberLabel", Const.UILabel, numberImage)
    numberLabel:setString(num)
    local numberLabel1 = self:getControl("NumberLabel_1", Const.UILabel, numberImage)
    numberLabel1:setString(num)

    -- 购买道具总价
    local buyButton = self:getControl("BuyButton")
    local totalPrice = num * (info.purchase_cost * self:getUnit())
    local priceStr, color = gf:getArtFontMoneyDesc(totalPrice)
    self:setNumImgForPanel("CostPanel", color, priceStr, false, LOCATE_POSITION.MID, 21, "BuyButton")
    self:updateLayout("CostPanel", "BuyButton")
end

function SeedBuyDlg:doBuyGoods(info)
    gf:CmdToServer('CMD_HOUSE_BUY_FURNITURE', { furniture_id = info.icon, num = self.ShopGoodsNumber, cost = self.ShopGoodsNumber * (info.purchase_cost * self:getUnit())})
    self:onCloseButton()
end

function SeedBuyDlg:onReduceButton()
    self.ShopGoodsNumber = self.ShopGoodsNumber - 1
    
    self:setShopPanel()
end

function SeedBuyDlg:onAddButton()
    local info = FurnitureInfo[self.itemName]
    if self.ShopGoodsNumber >= self.shopLimit then
        gf:ShowSmallTips(CHS[2000340])
        return
    elseif (self.ShopGoodsNumber + 1) * (info.purchase_cost * self:getUnit()) > 2000000000 then
        gf:ShowSmallTips(CHS[2000341])
        return
    end
    
    if self.ShopGoodsNumber + self.amount >= 999 then
        gf:ShowSmallTips(CHS[5400178])
        return
    end
    
    self.ShopGoodsNumber = self.ShopGoodsNumber + 1
    
    self:setShopPanel()
end

function SeedBuyDlg:onBuyButton(sender, eventType)
    local info = FurnitureInfo[self.itemName]

    if self.ShopGoodsNumber <= 0 then
        gf:ShowSmallTips(CHS[2100110])
        self.ShopGoodsNumber = 1
        self:setShopPanel()
        return
    end

    local cost = self.ShopGoodsNumber * (info.purchase_cost * self:getUnit())
    if cost > self:getMeMoney() then
        if 1 == self.costType then
            gf:askUserWhetherBuyCash()
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

function SeedBuyDlg:onAddGoldButton(sender, eventType)
    local onlineTabDlg = DlgMgr.dlgs["OnlineMallTabDlg"]
    gf:showBuyCash()
end

-- 刷新金钱
function SeedBuyDlg:MSG_UPDATE()
    self:refreshInfo()
end

function SeedBuyDlg:MSG_STORE()
    self.amount = HomeMgr:getAllItemCountByName(self.itemName)
end

function SeedBuyDlg:MSG_INVENTORY()
    self.amount = HomeMgr:getAllItemCountByName(self.itemName)
end

return SeedBuyDlg