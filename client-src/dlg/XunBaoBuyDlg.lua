-- XunBaoBuyDlg.lua
-- Created by huangzz Oct/10/2018
-- 购买寻宝道具界面

local XunBaoBuyDlg = Singleton("XunBaoBuyDlg", Dialog)

local TOOLS = {
    {name = CHS[5400771], ctrl = "ShovelPanel", price = 50},
    {name = CHS[5400772], ctrl = "BombPanel", price = 100},
    {name = CHS[5400773], ctrl = "TntPanel", price = 200},
}

function XunBaoBuyDlg:init()
    self:bindListener("ReduceButton", self.onReduceButton)
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("BuyButton", self.onBuyButton)

    self.selectItem = nil

    self:bindNumInput("NumberValuePanel")

    self:setCtrlEnabled("AddButton", false)
    self:setCtrlEnabled("ReduceButton", false)
    self:setCtrlEnabled("BuyButton", false)
end

function XunBaoBuyDlg:setData(data, type)
    for i = 1, 3 do
        local panel = self:getControl("ItemPanel_" .. i, nil, "CommodityPanel")
        
        local iconPath = ResMgr:getIconPathByName(TOOLS[i].name)
        self:setImage("GoodsImage", iconPath, panel)

        -- self:setLabelText("PriceLabel", TOOLS[i].price, name)

        local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(TOOLS[i].price))
        self:setNumImgForPanel("PriceLabel", fontColor, cashText, false, LOCATE_POSITION.LEFT_TOP, 23, panel)

        self:setLabelText("NumLabel", data[i].left_num, panel)

        self:setCtrlVisible("SelectImage", false, panel)

        local img = self:getControl("Image", nil, panel)
        img.itemInfo = {name = TOOLS[i].name, leftNum = data[i].left_num, type = i, price = TOOLS[i].price}
        self:bindTouchEndEventListener(img, self.onItemPanel)

        if (self.selectItem and self.selectItem.type == i) or (not self.selectItem and i == type) then
            self:onItemPanel(img)
        end
    end
end

function XunBaoBuyDlg:onItemPanel(sender, eventType)
    if self.selectItem == sender.itemInfo then
        local rect = self:getBoundingBoxInWorldSpace(sender)
        InventoryMgr:showBasicMessageDlg(self.selectItem.name, rect)
        return
    end
    
    self.selectItem = sender.itemInfo

    for i = 1, 3 do
        local panel = self:getControl("ItemPanel_" .. i, nil, "CommodityPanel")
        self:setCtrlVisible("SelectImage", false, panel)
    end

    self:setCtrlVisible("SelectImage", true, sender)

    self.num = 1

    self:setCtrlEnabled("AddButton", self.num < self.selectItem.leftNum)
    self:setCtrlEnabled("ReduceButton", self.num > 1)
    self:setCtrlEnabled("BuyButton", self.selectItem.leftNum > 0)

    self:setBuyNum()
end

function XunBaoBuyDlg:setBuyNum()
    self:setLabelText("NumberLabel", self.num, "BuyNumberPanel")
    self:setLabelText("NumberLabel_1", self.num, "BuyNumberPanel")

    self:setLabelText("NumLabel", self.selectItem.price * self.num, "BuyButton")
end

function XunBaoBuyDlg:onReduceButton(sender, eventType)
    if not self.selectItem then
        return
    end
    
    if self.num <= 1 then
        return
    end


    self.num = self.num - 1

    self:setCtrlEnabled("AddButton", self.num < self.selectItem.leftNum)
    self:setCtrlEnabled("ReduceButton", self.num > 1)

    self:setBuyNum()
end

function XunBaoBuyDlg:onAddButton(sender, eventType)
    if not self.selectItem then
        return
    end

    if self.num >= self.selectItem.leftNum then
        return
    end

    self.num = self.num + 1

    self:setCtrlEnabled("BuyButton", true)

    self:setCtrlEnabled("AddButton", self.num < self.selectItem.leftNum)
    self:setCtrlEnabled("ReduceButton", self.num > 1)

    self:setBuyNum()
end

function XunBaoBuyDlg:onBuyButton(sender, eventType)
    gf:CmdToServer("CMD_SPRING_2019_XCXB_BUY_TOOL", {tool_type = self.selectItem.type, num = self.num})
end

-- 数字键盘插入数字
function XunBaoBuyDlg:insertNumber(num)
    if not self.selectItem then
        return
    end

    if num <= 0 then
        num = 0
        self:setCtrlEnabled("BuyButton", false)
    elseif self.selectItem.leftNum > 0 then
        self:setCtrlEnabled("BuyButton", true)
    end

    if num >= self.selectItem.leftNum then
        num = self.selectItem.leftNum
        self:setCtrlEnabled("AddButton", false)
    else
        self:setCtrlEnabled("AddButton", true)
    end

    self:setCtrlEnabled("ReduceButton", num > 1)

    self.num = num
    self:setBuyNum()

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(num)
    end
end

return XunBaoBuyDlg
