-- MarketBatchSellItemDlg.lua
-- Created by zhnejgh Aug/16/2016
-- 批量道具购买和摆摊界面

local MarketSellItemDlg = require('dlg/MarketSellItemDlg')
local MarketBatchSellItemDlg = Singleton("MarketBatchSellItemDlg", MarketSellItemDlg)

function MarketBatchSellItemDlg:init()
    MarketSellItemDlg.init(self)
    self:bindListener("SellNumReduceButton", self.onSellNumReduceButton)
    self:bindListener("SellNumAddButton", self.onSellNumAddButton)
    self:bindListener("BuyNumReduceButton", self.onBuyNumReduceButton)
    self:bindListener("BuyNumAddButton", self.onBuyNumAddButton)
    self:bindListener("BuyButton", self.OnBuyButton)
    self:bindListener("ReSellReduceButton", self.onReSellReduceButton)
    self:bindListener("ReSellAddButton", self.onReSellAddButton)

    self:hookMsg("MSG_GENERAL_NOTIFY")

    self.inputCount = 1
    self.limitNum = 10 -- 摆摊上限
    self.canOperateNum = 1 -- 可以操作数量
    self.isBuy = false -- 默认是出售界面
end

function MarketBatchSellItemDlg:setDesc(data)
    -- 获取道具描述
    local itemDesc = InventoryMgr:getDescript(data.name)

    -- 获取道具功效
    local itemEffect = funStr or InventoryMgr:getFuncStr(data)

    if data.item_type == ITEM_TYPE.EQUIPMENT and data.unidentified == 1 then
        InventoryMgr:addLogoUnidentified(self:getControl("IconImage"))
        itemDesc = InventoryMgr:getDescript(CHS[3003092])
    end

    local listView = self:getControl("DescriptionListView")
    listView:removeAllChildren()

    local desPanel = ccui.Layout:create()
    local desText = CGAColorTextList:create(true)
    desText:setFontSize(19)
    desText:setString(itemDesc.." \n \n"..itemEffect)
    desText:setContentSize(listView:getContentSize().width , 0)
    desText:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    desText:updateNow()
    local labelW, labelH = desText:getRealSize()
    desPanel:addChild(tolua.cast(desText, "cc.LayerColor"))
    desText:setPosition(0, labelH)
    desPanel:setContentSize(listView:getContentSize().width, labelH)
    listView:pushBackCustomItem(desPanel)

    if data.amount then
        self.canOperateNum =  math.min(self.data.amount, self.limitNum)
    end

    self.inputCount = self.canOperateNum
    self:setInputCount(self.inputCount)
    self.data = data

    -- 绑定数字键盘
    local  sellPanel = self:getControl("SellPanel")
    self:bindNumInput("NumInputPanel", sellPanel, nil)
end

function MarketBatchSellItemDlg:setBuyInfo(count, callBack)
    self.isBuy = true
    self.canOperateNum = count
    self.callBack = callBack
    self:setInputCount(self.canOperateNum)

    local panel = self:getControl("BuyPanel")
    local text, fontColor = gf:getArtFontMoneyDesc(self.data.price or 0)
    self:setNumImgForPanel("MoneyValuePanel", fontColor, text, false, LOCATE_POSITION.MID, 23, panel)

    self:onHideButton()
    self:setCtrlVisible("ShowButton", false)
    self:setCtrlVisible("HideButton", false)
    -- 绑定数字键盘
    local  BuyPanel = self:getControl("BuyPanel")
    self:bindNumInput("NumInputPanel", BuyPanel, nil)
end

-- 设置购买或者出售数量
function MarketBatchSellItemDlg:setInputCount(count)
    local panel
    if self.isBuy then
        panel = self:getControl("BuyPanel")
    else
        local sellpanel = self:getControl("SellPanel")
        panel = self:getControl("SellNumPanel", nil, sellpanel)
    end

    local text, fontColor = gf:getArtFontMoneyDesc(count or 0)
    self:setNumImgForPanel("NumValuePanel", fontColor, text, false, LOCATE_POSITION.MID, 23, panel)

    self:setTotalPrice()
end

function MarketBatchSellItemDlg:setTotalPrice()
    local panel, totalPrice
    if self.isBuy then
        panel = self:getControl("BuyPanel")
        totalPrice = (self.data.price or 0) * self.inputCount
    else
        panel = self:getControl("SellPanel")
        totalPrice = self.inputCount * self:getUnPublicPrice()
        self:setDouleBoothCost(totalPrice)
    end

    local totalPricepanel = self:getControl("TotalPricePanel", nil, panel)

    local text, fontColor = gf:getArtFontMoneyDesc(totalPrice or 0)
    self:setNumImgForPanel("MoneyValuePanel", fontColor, text, false, LOCATE_POSITION.MID, 23, totalPricepanel)

end

-- 设置重新摆摊信息
function MarketBatchSellItemDlg:setResellInfo()
    MarketSellItemDlg.setResellInfo(self)
    local sellPanel = self:getControl("SellPanel")

    self:setCtrlVisible("ReSellNumPanel", true, sellPanel)
    self:setCtrlVisible("SellNumPanel", false, sellPanel)

    local text, fontColor = gf:getArtFontMoneyDesc(self.curItem.amount or 0)
    self:setNumImgForPanel("ReSellNumValuePanel", fontColor, text, false, LOCATE_POSITION.MID, 23, sellPanel)
end

-- 设置批量出售的出售的数量
function MarketBatchSellItemDlg:setOnsellNumInfo()
    local panel = self:getControl("OnSellPanel")
    local text, fontColor = gf:getArtFontMoneyDesc(self.curItem.amount or 0)
    self:setNumImgForPanel("NumValuePanel", fontColor, text, false, LOCATE_POSITION.MID, 23, panel)
end

function MarketBatchSellItemDlg:reFreshPrice()
	self:setTotalPrice()
end

function MarketBatchSellItemDlg:onSellNumReduceButton(sender, eventType)
    if self.inputCount <= 1 then
        gf:ShowSmallTips(CHS[6200051])
        return
    end

    self.inputCount = self.inputCount - 1
    self:setInputCount(self.inputCount)
end

function MarketBatchSellItemDlg:onSellNumAddButton(sender, eventType)
    if self.inputCount >= self.canOperateNum then
        if self.canOperateNum == self.limitNum then
            gf:ShowSmallTips(string.format(CHS[6200049], self.canOperateNum))
        else
            gf:ShowSmallTips(CHS[6200050])
        end

        return
    end

    self.inputCount = self.inputCount + 1
    self:setInputCount(self.inputCount)
end

function MarketBatchSellItemDlg:onBuyNumReduceButton(sender, eventType)
    if self.inputCount <= 1 then
        gf:ShowSmallTips(CHS[6200053])
        return
    end

    self.inputCount = self.inputCount - 1
    self:setInputCount(self.inputCount)
end

function MarketBatchSellItemDlg:onBuyNumAddButton(sender, eventType)

    if self.inputCount >= self.canOperateNum then
        gf:ShowSmallTips(CHS[6200050])
        return
    end

    self.inputCount = self.inputCount + 1
    self:setInputCount(self.inputCount)
end

function MarketBatchSellItemDlg:OnBuyButton(sender, eventType)
    self.callBack(self.inputCount)
    DlgMgr:closeDlg(self.name)
end

function MarketBatchSellItemDlg:onReSellReduceButton(sender, eventType)
    self:onSellReduceButton(sender, eventType)
end

function MarketBatchSellItemDlg:onReSellAddButton(sender, eventType)
    self:onSellAddButton(sender, eventType)
end

-- 刷新摆摊购买最大值 和 刷新摆摊价格
function MarketBatchSellItemDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_STALL_BATCH_NUM == data.notify then
        self.limitNum = tonumber(data.para)
        self.canOperateNum = math.min(self.canOperateNum, self.limitNum)
        self.inputCount = self.canOperateNum
        self:setInputCount(self.inputCount)
    elseif NOTIFY.NOTIFY_STALL_ITEM_PRICE == data.notify then
        self:setWaitingForStdPrice(false)
        self.floatPrice = json.decode(data.para)
        if not gf:findStrByByte(self.floatPrice.name, self.data.name) then
            -- 当前选中的和服务器下发的不一致，不理
            -- 用匹配是因为 时装 这类特殊的
            self.floatPrice = nil
            return
        end


        self.standPrice = self.floatPrice[100]

        -- 如果本次摆摊的非公示道具与上一次意图摆摊的非公示道具相同，则floatNum沿用上一次的值
        local itemName = self.data.name
        local level = self.data.level
        local lastSellUnPublicItem = MarketMgr:getLastSellUnPublicItem()
        local lastFloatNum
        if itemName and lastSellUnPublicItem.name == itemName and lastSellUnPublicItem.level == level then
            lastFloatNum = lastSellUnPublicItem.floatNum
        end

        if lastFloatNum then
            self.sellFloatNum = lastFloatNum
        else
            self.sellFloatNum = 0
        end

        self:refreshUnPublicCash()
    end
end

-- 数字键盘插入数字
function MarketBatchSellItemDlg:insertNumber(num)
    if self.isBuy  then
        if num <= 0 then
            num = 1 gf:ShowSmallTips(CHS[6200053])
        elseif num > self.canOperateNum then
            num = self.canOperateNum
            gf:ShowSmallTips(CHS[6200050])
        end
    else
        if num <= 0 then
            num = 1 gf:ShowSmallTips(CHS[6200051])
        elseif num > self.canOperateNum then
            num = self.canOperateNum

            if self.canOperateNum == self.limitNum then
                gf:ShowSmallTips(string.format(CHS[6200049], self.canOperateNum))
            else
                gf:ShowSmallTips(CHS[6200050])
            end
        end
    end


    -- 更新键盘数据
    DlgMgr:sendMsg("SmallNumInputDlg", "setInputValue", num)
    self.inputCount = num
    self:setInputCount(self.inputCount)
end

function MarketBatchSellItemDlg:cleanup()
    MarketSellItemDlg.cleanup(self)
    self.inputCount = 1
end

return MarketBatchSellItemDlg
