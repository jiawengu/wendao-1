-- GoodValueDlg.lua
-- Created by zhengjh Jan/16/2016
-- 好心值商店

local SpecialBuyDlg = require("dlg/SpecialBuyDlg")
local GoodValueDlg = Singleton("GoodValueDlg", SpecialBuyDlg)
local shopLimit = 100

function GoodValueDlg:initData()
    -- 设置拥有的好心值
    self:setHavePanel()

    self.shopLimit = shopLimit

    self:hookMsg("MSG_UPDATE", GoodValueDlg)
end

function GoodValueDlg:setGoods(index, panel)
    if not self.goods[index] then
        return
    end

    local goodImagePanel = self:getControl("GoodsImagePanel", Const.UIPanel, panel)
    local goodImage = ccui.ImageView:create(ResMgr:getItemIconPath(InventoryMgr:getIconByName(self.goods[index].name)))
    goodImage:setPosition(goodImagePanel:getContentSize().width / 2, goodImagePanel:getContentSize().height / 2)
    goodImage:setAnchorPoint(0.5, 0.5)
    gf:setItemImageSize(goodImage)

    goodImagePanel:removeAllChildren()
    goodImagePanel:addChild(goodImage)

    InventoryMgr:addLogoBinding(goodImage)

    self:setLabelText("GoodsNameLabel", self.goods[index].name, panel)
    self:setLabelText("GoodsValueLabel", self.goods[index].price, panel)
end

function GoodValueDlg:refreshTotalValuePanel(totalValue)

    local costStr = gf:getMoneyDesc(totalValue, true)

    local pricePanel = self:getControl("TotalValuePanel")
    if totalValue > Me:queryInt("nice") then
        self:setLabelText("TotalValueLabel_1", costStr, pricePanel, COLOR3.RED)
        self:setLabelText("TotalValueLabel_2", costStr, pricePanel)
    else
        self:setLabelText("TotalValueLabel_1", costStr, pricePanel, COLOR3.WHITE)
        self:setLabelText("TotalValueLabel_2", costStr, pricePanel)
    end
end

function GoodValueDlg:onSubOrAddNum(ctrlName, times)
    if times == 1 then
        self.needShowSubOrAddTips = true
        self.clickNum = self.clickNum  + 1  -- 点击次数，不包括长按
    elseif self.clickNum < 4 then
        self.clickNum = 0
    end

    if ctrlName == "AddButton" then
        self:onAddButton()
    elseif ctrlName == "ReduceButton" then
        self:onReduceButton()
    end

end

function GoodValueDlg:doBuy(num)
    local totalCost = self.goods[self.pickGoods].price * num
    local name = self.goods[self.pickGoods].name
    if Me:queryInt("nice") < totalCost then
        -- 好心值不足，购买失败
        gf:ShowSmallTips(CHS[3002734])
        return
    end


    local showMessage = string.format(CHS[3002735], totalCost, num, InventoryMgr:getUnit(name), name)

    gf:confirm(showMessage, function()
        -- 发送购买指令
        gf:CmdToServer("CMD_EXCHANGE_GOODS", {
            type = 2,
            name = name,
            amount = num,
        })
    end)
end

function GoodValueDlg:onAddButton(sender, eventType)
    if not self.pickGoods then
        if self.needShowSubOrAddTips then
            gf:ShowSmallTips(CHS[3002730])
            self.needShowSubOrAddTips = nil
        end

        return
    end

    local countPanel = self:getControl("BuyNumberPanel")
    local num = tonumber(self:getLabelText("NumberValueLabel", countPanel))

    if num + 1 > self.shopLimit then
        -- 单次购买已达上限。
        if self.needShowSubOrAddTips then
            if self.shopLimit == shopLimit then
                gf:ShowSmallTips(CHS[6000035])
            else
                gf:ShowSmallTips(CHS[6000150])
            end
            self.needShowSubOrAddTips = nil
        end

        return
    else
        if Me:queryInt("nice") < self.goods[self.pickGoods].price * (num + 1) then
            gf:ShowSmallTips(CHS[4200405])
            return
        end
    end

    if self.clickNum == 3 then
        gf:ShowSmallTips(CHS[3002731])
    end

    self:setLabelText("NumberValueLabel", num + 1, countPanel)
    self:refreshTotalValuePanel(self.goods[self.pickGoods].price * (num + 1))
end

-- 数字键盘插入数字
function GoodValueDlg:insertNumber(num)
    local countPanel = self:getControl("BuyNumberPanel")
    local shopNum = tonumber(self:getLabelText("NumberValueLabel", countPanel))
    shopNum = num

    if shopNum < 0 then
        shopNum = 0
    end

    -- 超过包裹上限
    local limit = self.shopLimit

    if num > limit then
        if self.shopLimit == shopLimit then
            gf:ShowSmallTips(CHS[6000035]) -- 超过上限
        else
            gf:ShowSmallTips(CHS[6000150]) -- 包裹不足
        end

        shopNum =  math.max(math.min(limit, math.floor(Me:queryInt("nice") / self.goods[self.pickGoods].price)), 0)
    else
        if Me:queryInt("nice") < self.goods[self.pickGoods].price * num then
            gf:ShowSmallTips(CHS[4200405])
            shopNum =  math.floor(Me:queryInt("nice") / self.goods[self.pickGoods].price)
        end
    end

    self:setLabelText("NumberValueLabel", shopNum, countPanel)
    self:refreshTotalValuePanel(self.goods[self.pickGoods].price * (shopNum))

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(shopNum)
    end
end

-- 设置拥有的好心值
function GoodValueDlg:setHavePanel()
    local ownPanel = self:getControl("HavePanel")

    local haveText = gf:getArtFontMoneyDesc(Me:queryInt("nice"))
    self:setNumImgForPanel("HaveTextPanel", ART_FONT_COLOR.DEFAULT, haveText, haveText, LOCATE_POSITION.MID, 23, ownPanel)
end

function GoodValueDlg:MSG_UPDATE(data)
    -- 设置拥有的好心值
    self:setHavePanel()
end

-- 打开界面需要某些参数需要重载这个函数
function GoodValueDlg:onDlgOpened(param)
    local sellListView = self:getControl("PharmacyListView")
    local listSize = sellListView:getContentSize()
    local itemsPanel = sellListView:getItems()



    local num = 0
    for _,goodsPanel in pairs(itemsPanel) do
        num = num + 1
        local goodsPanel1 = self:getControl("GoodsPanel1", nil, goodsPanel)
        local goodsPanel2 = self:getControl("GoodsPanel2", nil, goodsPanel)

        self:setCtrlVisible("ChosenImage", false, goodsPanel1)
        self:setCtrlVisible("ChosenImage", false, goodsPanel2)

        if self:getLabelText("GoodsNameLabel", goodsPanel1) == param[1] then
            local pick = goodsPanel1:getTag()

            self:setGoods(pick, goodsPanel1)
            self:chooseGoods(goodsPanel1)
            local singelHeight = goodsPanel:getContentSize().height
            if singelHeight * num > listSize.height then
                local temp = math.floor(listSize.height / singelHeight * #itemsPanel)
                sellListView:scrollToPercentHorizontal(temp, 1,false)
            end

        end

        if self:getLabelText("GoodsNameLabel", goodsPanel2) == param[1] then
            local pick = goodsPanel2:getTag()

            self:setGoods(pick, goodsPanel2)
            self:chooseGoods(goodsPanel2)
            local singelHeight = goodsPanel:getContentSize().height
            if singelHeight * num > listSize.height then
                local temp = math.floor(listSize.height / singelHeight * #itemsPanel)
                sellListView:scrollToPercentHorizontal(temp, 1,false)
            end

        end
    end

end


return GoodValueDlg
