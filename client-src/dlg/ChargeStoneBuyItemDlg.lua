-- ChargeStoneBuyItemDlg.lua
-- Created by songcw Apr/07/2017
-- 【周年庆】五行兑换

local ChargeStoneBuyItemDlg = Singleton("ChargeStoneBuyItemDlg", Dialog)

function ChargeStoneBuyItemDlg:init()
    self:bindListener("SellReduceButton", self.onSellReduceButton)
    self:bindListener("SellAddButton", self.onSellAddButton)
    self:bindListener("BuyButton", self.onBuyButton)
    
    self:bindListener("MoneyValuePanel", self.onNumInput)
    
    self:hookMsg("MSG_WUXING_SHOP_REFRSH")
    
    self:bindListener("IconPanel", self.onShowItemInfo)
end

function ChargeStoneBuyItemDlg:setDataByItem(item)
    self.inputNum = 1
    self.item = item
    
    -- 名称
    self:setLabelText("NameLabel", item.name)

    -- icon
    self:setImage("IconImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(item.name)))

    -- 限制交易    
    local imgCtrl = self:getControl("IconImage")
    if item["limited"] == 1 then
        InventoryMgr:addLogoBinding(imgCtrl)
    else
        InventoryMgr:removeLogoBinding(imgCtrl)
    end    
    
    -- 价值
    local priceDesc = gf:getArtFontMoneyDesc(item.price, true)
    self:setNumImgForPanel("PointPanel", ART_FONT_COLOR.DEFAULT, priceDesc, false, LOCATE_POSITION.CENTER, 23)

    local num = item.totalNum - item.num

    -- 限购剩余数量
    if item.totalNum > 0 then
        self:setLabelText("SellFloatLabel", CHS[5400069] .. num .. "/" .. item.totalNum)
    else
        self:setLabelText("SellFloatLabel", CHS[5400069] .. CHS[3001763])
    end
    
    self:updataNum()
end

function ChargeStoneBuyItemDlg:updataNum()

    -- 购买数量
    self:setNumImgForPanel("MoneyValuePanel", ART_FONT_COLOR.DEFAULT, self.inputNum, false, LOCATE_POSITION.MID, 23)
    
    -- 总价
    local totalPrice = self.inputNum * self.item.price
    local totalPriceStr =  gf:getArtFontMoneyDesc(totalPrice)
    
    local haved = InventoryMgr:getAmountByName(CHS[5400065]) or 0
    local color = totalPrice > haved and ART_FONT_COLOR.RED or ART_FONT_COLOR.DEFAULT
    
    self:setNumImgForPanel("PointValuePanel", color, totalPriceStr, false, LOCATE_POSITION.MID, 23)
end

function ChargeStoneBuyItemDlg:onNumInput(sender, eventType)
    self.firstInsert = true
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local dlg = DlgMgr:openDlg("NumInputDlg")
    dlg:setObj(self)
    dlg.root:setPosition(rect.x + rect.width /2 , rect.y  + rect.height +  dlg.root:getContentSize().height /2 + 20)
end

-- 数字键盘删除数字
function ChargeStoneBuyItemDlg:deleteNumber()
    self.inputNum = math.floor(self.inputNum / 10)
    self:updataNum()
end

-- 数字键盘清空
function ChargeStoneBuyItemDlg:deleteAllNumber(key)
    self.inputNum = 0
    
    self:updataNum()
end

function ChargeStoneBuyItemDlg:closeNumInputDlg()
--[[
    if self.inputNum < 1 then self.inputNum = 1 end
    self:updataNum()
    --]]
end

function ChargeStoneBuyItemDlg:onShowItemInfo(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(self.item.name, rect, self.item.limted)
end

-- 数字键盘插入数字
function ChargeStoneBuyItemDlg:insertNumber(num)
    if self.firstInsert then 
        self.inputNum = 0
        self.firstInsert = false 
    end    
    if num == "00" then
        self.inputNum = self.inputNum * 100
    elseif num == "0000" then
        self.inputNum = self.inputNum * 10000
    else
        self.inputNum = self.inputNum * 10 + num
    end
    local num = math.min(self.item.totalNum - self.item.num, 99)
    if self.item.totalNum == 0 then num = 99 end
    if self.inputNum > num then
        self.inputNum = num
        gf:ShowSmallTips(string.format(CHS[4200265], num))
    end

    self:updataNum()
end

function ChargeStoneBuyItemDlg:onSellReduceButton(sender, eventType)
    self.inputNum = self.inputNum - 1
    if self.inputNum < 1 then
        self.inputNum = 1
        gf:ShowSmallTips(string.format(CHS[4200264]))
    end
    self:updataNum()
end

function ChargeStoneBuyItemDlg:onSellAddButton(sender, eventType)
    self.inputNum = self.inputNum + 1
    local num = math.min(self.item.totalNum - self.item.num, 99)
    if self.item.totalNum == 0 then num = 99 end
    if self.inputNum > num then
        self.inputNum = num
        gf:ShowSmallTips(string.format(CHS[4200265], num))
    end
    self:updataNum()
end

function ChargeStoneBuyItemDlg:onBuyButton(sender, eventType)

    if self.inputNum < 1 then
        self.inputNum = 1
        self:updataNum()
        gf:ShowSmallTips(string.format(CHS[4200264]))
        return
    end

    local haved = InventoryMgr:getAmountByName(CHS[5400065]) or 0
    local totalPrice = self.item.price * self.inputNum
    if totalPrice > haved then
        gf:ShowSmallTips(CHS[5400057])
        return
    end


    local cout = InventoryMgr:getCountCanAddToBag(self.item.name, 1, self.item.limted)
    if cout < 1 then
        gf:ShowSmallTips(CHS[4200268])
        return
    end

    gf:confirm(string.format(CHS[4200266], totalPrice, self.inputNum, InventoryMgr:getUnit(self.item.name), self.item.name), function ()
        AnniversaryMgr:wuxingShopExchange(self.item.name, self.inputNum)	
    end)    
end

function ChargeStoneBuyItemDlg:MSG_WUXING_SHOP_REFRSH(data)
    self:onCloseButton()
end


return ChargeStoneBuyItemDlg
