-- ChooseFishToolDlg.lua
-- Created by huangzz Aug/19/2017
-- 鱼竿、鱼饵补充及购买界面

local ChooseFishToolDlg = Singleton("ChooseFishToolDlg", Dialog)

local LIMIT_NUM = 100    -- 可拥有的最大上限

local TOOL_TYPE_POLE = 1 -- 鱼竿

local TOOL_TYPE_BAIT = 2 -- 鱼饵

function ChooseFishToolDlg:init(data)
    self:bindListener("ReduceButton", self.onReduceButton, "PoleDescriptionPanel")
    self:bindListener("AddButton", self.onAddButton, "PoleDescriptionPanel")
    self:bindListener("BuyButton", self.onBuyButton, "PoleDescriptionPanel")
    self:bindListener("NoneButton", self.onNoneButton, "PoleDescriptionPanel")
    self:bindListener("ReduceButton", self.onReduceButton, "BaitDescriptionPanel")
    self:bindListener("AddButton", self.onAddButton, "BaitDescriptionPanel")
    self:bindListener("BuyButton", self.onBuyButton, "BaitDescriptionPanel")
    self:bindListener("NoneButton", self.onNoneButton, "BaitDescriptionPanel")
    
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("ItemPanel", self.onSelectPole, "PoleListPanel")
    self:bindListener("ItemPanel", self.onSelectBait, "BaitListPanel")
    
    self.polesInfo, self.baitsInfo = self:getFishToolInfo()
    
    self.polePanel = self:retainCtrl("ItemPanel", "PoleListPanel")
    self.baitPanel = self:retainCtrl("ItemPanel", "BaitListPanel")

    self.selectImage = self:retainCtrl("ChosenEffectImage1", self.polePanel)
    self.selectPoleImage = self:retainCtrl("ChosenEffectImage2", self.polePanel)
    self.selectImage2 = self:retainCtrl("ChosenEffectImage1", self.baitPanel)
    self.selectBaitImage = self:retainCtrl("ChosenEffectImage2", self.baitPanel)
    
    self.selectPoleTag = nil
    self.selectBaitTag = nil
    self.selectItem = nil
    
    self.selectDefautPole = data.poleName
    self.selectDefautBait = data.baitName
    self.fishLevel = data.level or 1
    self.myGid = Me:queryBasic("gid")
    
    local panel1 = self:getControl("PoleDescriptionPanel")
    local panel2 = self:getControl("BaitDescriptionPanel")
    self:setMoneyImage(0, panel1)
    self:setMoneyImage(0, panel2)
    self:setLabelText("NameLabel", "", panel1)
    self:setLabelText("NameLabel", "", panel2)
    panel1:setVisible(false)
    panel2:setVisible(false)
    self:setCtrlVisible("NonePanel", true)

    -- 打开数字键盘
    self:bindNumInput("NumberValueImage", "PoleDescriptionPanel")
    self:bindNumInput("NumberValueImage", "BaitDescriptionPanel")
    
    self.poleScrollView = self:getControl("PolesScrollView", nil, "PoleListPanel")
    self.baitScrollView = self:getControl("PolesScrollView", nil, "BaitListPanel")
    self:initScrollViewPanel(self.baitsInfo, self.baitPanel, self.onSetItem, self.baitScrollView, 3, 10, 15, 13, 13)
    self:initScrollViewPanel(self.polesInfo, self.polePanel, self.onSetItem, self.poleScrollView, 3, 10, 15, 13, 13)

    self:MSG_HOUSE_ALL_FISH_TOOL_INFO()
    
    self:hookMsg("MSG_HOUSE_ALL_FISH_TOOL_INFO")
    self:hookMsg("MSG_HOUSE_FISH_TOOL_PART_INFO")
    self:hookMsg("MSG_UPDATE")
end

function ChooseFishToolDlg:setButtonStatus(type, cell, level)
    if type == 1 then
        self:setCtrlVisible("NoneButton", false, cell)
        self:setCtrlVisible("BuyButton", true, cell)
    elseif type == 2 then
        self:setCtrlVisible("NoneButton", true, cell)
        self:setCtrlVisible("BuyButton", false, cell)
        
        local boneButton = self:getControl("NoneButton", nil, cell)
        self:setLabelText("Label_1", CHS[5400224], boneButton)
        self:setLabelText("Label_2", CHS[5400224], boneButton)
        self:setCtrlEnabled("NoneButton", true, cell)
    elseif type == 3 then
        self:setCtrlVisible("NoneButton", true, cell)
        self:setCtrlVisible("BuyButton", false, cell)
        
        local boneButton = self:getControl("NoneButton", nil, cell)
        self:setLabelText("Label_1", string.format(CHS[5400221], level), boneButton)
        self:setLabelText("Label_2", string.format(CHS[5400221], level), boneButton)
        self:setCtrlEnabled("NoneButton", false, cell)
    end
    
    self:setCtrlVisible("NonePanel", false)
end

function ChooseFishToolDlg:getFishToolInfo()
    local itemInfo = InventoryMgr:getAllItemInfo()
    local baits = {}
    local poles = {}
    for name, v in pairs(itemInfo) do
        if string.match(name, CHS[5400182]) then
            local subName = string.match(name, CHS[5400177])
            if string.match(subName, CHS[5400179]) then
                table.insert(poles, v)
                v.name = subName
                v.type = TOOL_TYPE_POLE
                v.amount = 0
            else
                table.insert(baits, v)
                v.name = subName
                v.type = TOOL_TYPE_BAIT
                v.amount = 0
            end
        end
    end
    
    table.sort(poles, function(l, r)
        return l.icon < r.icon
    end)
    
    table.sort(baits, function(l, r)
        return l.icon < r.icon
    end)

    return poles, baits
end

function ChooseFishToolDlg:onSetItem(cell, data)
    data.cell = cell
    self:setImage("IconImage", ResMgr:getItemIconPath(data.icon), cell)
    
    local img = self:getControl("IconImage", nil, cell)
    
    self:setNumImgForPanel(img, ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 19, cell)
    
    gf:grayImageView(img)
    
    if self.selectDefautPole == data.name then
        self:onSelectPole(cell, nil)
    end
    
    if self.selectDefautBait == data.name then
        self:onSelectBait(cell, nil)
    end
end

function ChooseFishToolDlg:refreshShowNum(name, amount, data)
    for _, v in ipairs(data) do
        if v.name == name and v.cell then
            local img = self:getControl("IconImage", nil, v.cell)
            if amount > 0 then
                self:setNumImgForPanel(img, ART_FONT_COLOR.NORMAL_TEXT, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, v.cell)
                gf:resetImageView(img)
            else
                img:removeChildByTag(LOCATE_POSITION.RIGHT_BOTTOM * 999)
                gf:grayImageView(img)
            end
            
            v.amount = amount
        end
    end
end

-- 选中道具刷新描述
function ChooseFishToolDlg:setItemInfo(data, panel, type)
    self:setLabelText("NameLabel", data.name, panel)

    self:setColorText(data.descript, "DescPanel", panel, 0, 7)
    local amountStr
    if data.amount > 0 then
        amountStr = "#Y" .. data.amount .. "#n"
    else
        amountStr = "#R0#n"
    end
    if type == "pole" then
        self:setColorText(string.format(CHS[5400161], amountStr), "DescPanel1", panel, 0, 7, nil, 18)
    else
        self:setColorText(data.func, "DescPanel1", panel, 0, 7, nil, 18)
        
        self:setColorText(string.format(CHS[5400161], amountStr), "DescPanel2", panel, 0, 7, nil, 18)
    end
    
    self.inputNum = 1
    self:setShopPanel()
    self:refreshInfo()
end

-- 选择鱼竿
function ChooseFishToolDlg:onSelectPole(sender, eventType)
    self.selectImage:removeFromParent()
    self.selectPoleImage:removeFromParent()
    sender:addChild(self.selectImage)
    sender:addChild(self.selectPoleImage)
    
    self.selectPoleTag = sender:getTag()
    self.selectItem = self.polesInfo[self.selectPoleTag]
    
    self.descPanel = self:getControl("PoleDescriptionPanel")
    self.descPanel:setVisible(true)
    self:setCtrlVisible("BaitDescriptionPanel", false)
    self:setItemInfo(self.selectItem, self.descPanel, "pole")
    

    self:setButtonStatus(1, self.descPanel)
end

-- 选择鱼饵
function ChooseFishToolDlg:onSelectBait(sender, eventType)
    self.selectImage:removeFromParent()
    self.selectBaitImage:removeFromParent()
    sender:addChild(self.selectImage)
    sender:addChild(self.selectBaitImage)
    
    self.selectBaitTag = sender:getTag()
    self.selectItem = self.baitsInfo[self.selectBaitTag]
    
    self.descPanel = self:getControl("BaitDescriptionPanel")
    self:setCtrlVisible("PoleDescriptionPanel", false)
    self.descPanel:setVisible(true)
    self:setItemInfo(self.selectItem, self.descPanel)
    
    if self.selectItem.level > self.fishLevel then
        self:setButtonStatus(3, self.descPanel, self.selectItem.level)
    else
        self:setButtonStatus(1, self.descPanel)
    end
end

-- 数字键盘插入数字
function ChooseFishToolDlg:insertNumber(num)
    if not self.selectItem then
        return
    end
    
    if num <= 0 then
        num = 0
    end

    local canBuyNum = LIMIT_NUM - self.selectItem.amount
    if num > canBuyNum then
        num = canBuyNum
        gf:ShowSmallTips(string.format(CHS[5400181], canBuyNum, self:getItemUint(self.selectItem)))
    end

    self.inputNum = num
    self:setShopPanel()

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(self.inputNum)
    end
end

-- 购买物品信息
function ChooseFishToolDlg:setShopPanel()
    local info = self.selectItem

    local num = self.inputNum

    -- 购买道具数量
    local numberImage = self:getControl("NumberValueImage", nil, self.descPanel)
    local numberLabel = self:getControl("NumberLabel", Const.UILabel, numberImage)
    numberLabel:setString(num)
    local numberLabel1 = self:getControl("NumberLabel_1", Const.UILabel, numberImage)
    numberLabel1:setString(num)

    -- 购买道具总价
    local buyButton = self:getControl("BuyButton", nil, self.descPanel)
    local totalPrice = num * info.purchase_cost * self:getUnit(info.purchase_type)
    local priceStr, color = gf:getArtFontMoneyDesc(totalPrice)
    if info.purchase_type > 1 then
        color = ART_FONT_COLOR.DEFAULT
    end
    
    self:setNumImgForPanel("CostPanel", color, priceStr, false, LOCATE_POSITION.MID, 21, buyButton)
    self:updateLayout("CostPanel", buyButton)
end

-- 刷新拥有的金钱
function ChooseFishToolDlg:refreshInfo()
    local item = self.selectItem
    if not item then
        return
    end
    
    local meGoldStr, color = gf:getArtFontMoneyDesc(self:getMeMoney(item.purchase_type))
    if item.purchase_type > 1 then
        color = ART_FONT_COLOR.DEFAULT
    end
    
    self:setNumImgForPanel("GoldValuePanel", color, meGoldStr, false, LOCATE_POSITION.MID, 21, self.descPanel)
    self:updateLayout("GoldValuePanel")
    
    
    self:setMoneyImage(item.purchase_type, self.descPanel)
end

function ChooseFishToolDlg:setMoneyImage(type, cell)
    self:setCtrlVisible("GoldImage_Cash", type == 1, cell)
    self:setCtrlVisible("CostImage_Cash", type == 1, cell)

    self:setCtrlVisible("GoldImage_Gold", type == 2, cell)
    self:setCtrlVisible("CostImage_Gold", type == 2, cell)

    self:setCtrlVisible("GoldImage_Silver", type == 3, cell)
    self:setCtrlVisible("CostImage_Silver", type == 3, cell)
end

function ChooseFishToolDlg:doBuyGoods(item)
    if item.type == TOOL_TYPE_POLE then
        gf:CmdToServer('CMD_HOUSE_ADD_POLE_NUM', {pole_name = item.name, num = self.inputNum})
    else
        gf:CmdToServer('CMD_HOUSE_ADD_BAIT_NUM', {bait_name = item.name, num = self.inputNum})
    end
end

function ChooseFishToolDlg:onReduceButton()
    if not self.selectItem then
        return
    end
    
    if self.inputNum <= 1 then
        gf:ShowSmallTips(string.format(CHS[5400180], self:getItemUint(self.selectItem)))
        return
    end
    
    self.inputNum = self.inputNum - 1

    self:setShopPanel()
end

function ChooseFishToolDlg:onAddButton()
    if not self.selectItem then
        return
    end
    
    if self.inputNum + self.selectItem.amount >= LIMIT_NUM then
        gf:ShowSmallTips(string.format(CHS[5400181], LIMIT_NUM - self.selectItem.amount, self:getItemUint(self.selectItem)))
        return
    end

    self.inputNum = self.inputNum + 1

    self:setShopPanel()
end

function ChooseFishToolDlg:onNoneButton(sender, eventType)
    gf:ShowSmallTips(CHS[5400219])
end

function ChooseFishToolDlg:onBuyButton(sender, eventType)
    if not self.selectItem then
        return
    end
    
    local item = self.selectItem
    if self.selectItem.amount >= LIMIT_NUM then
        if item.type == TOOL_TYPE_POLE then
            gf:ShowSmallTips(CHS[5400199])
        else
            gf:ShowSmallTips(CHS[5400200])
        end
        
        return
    end
    
    if self.inputNum <= 0 then
        self.inputNum = 1
        self:setShopPanel()
        gf:ShowSmallTips(string.format(CHS[5400180], self:getItemUint(item)))
        return
    end
    
    
    if self.inputNum + item.amount > LIMIT_NUM then
        gf:ShowSmallTips(string.format(CHS[5400181], LIMIT_NUM - item.amount, self:getItemUint(item)))
        return
    end

    local cost = self.inputNum * item.purchase_cost * self:getUnit(item.purchase_type)
    local money = self:getMeMoney(item.purchase_type)
    if item.purchase_type == 3 then
        money = money + Me:queryInt("gold_coin")
    end
    
    if cost > money then
        if 1 == item.purchase_type then
            gf:askUserWhetherBuyCash()
        elseif 2 == item.purchase_type then
            gf:askUserWhetherBuyCoin("gold_coin")
        else
            gf:askUserWhetherBuyCoin()
        end

        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("doBuyGoods", item) then
        return
    end

    self:doBuyGoods(item)
end

function ChooseFishToolDlg:getItemUint(item)
    if item.type == TOOL_TYPE_POLE then
        return CHS[5400201]
    else
        return item.unit
    end
end

-- 选择鱼竿
function ChooseFishToolDlg:onConfirmButton(sender, eventType)
    if not self.selectPoleTag and not self.selectBaitTag then
        gf:ShowSmallTips(CHS[5400211])
        return
    end
    
    if not self.selectPoleTag then
        gf:ShowSmallTips(CHS[5400209])
        return
    end
    
    if not self.selectBaitTag then
        gf:ShowSmallTips(CHS[5400210])
        return
    end

    local pole = self.polesInfo[self.selectPoleTag]
    local bait = self.baitsInfo[self.selectBaitTag]
    if pole and pole.amount <= 0 then
        gf:ShowSmallTips(string.format(CHS[5400203], pole.name))
        return
    end
    
    if bait and bait.amount <= 0 then
        gf:ShowSmallTips(string.format(CHS[5400204], bait.name))
        return
    end
    
    --[[local status = DlgMgr:sendMsg("HomeFishingDlg", "getMyFishingStatus")
    if status and status > 1 then
        gf:ShowSmallTips(CHS[5400222])
        return
    end]]
    
    gf:CmdToServer("CMD_HOUSE_SELECT_TOOLS", {pole_name = pole.name, bait_name = bait.name})
    self:close()
end

function ChooseFishToolDlg:onAddGoldButton(sender, eventType)
    local onlineTabDlg = DlgMgr.dlgs["OnlineMallTabDlg"]
    gf:showBuyCash()
end

function ChooseFishToolDlg:getUnit(costType)
    if 1 == costType then
        return 10000
    else
        return 1
    end
end

function ChooseFishToolDlg:getMeMoney(costType)
    if 1 == costType then
        return Me:queryBasicInt("cash")
    elseif 2 == costType then
        return Me:queryBasicInt("gold_coin")
    else
        return Me:queryBasicInt("silver_coin")
    end
end

-- 更新所有鱼具消息
function ChooseFishToolDlg:MSG_HOUSE_ALL_FISH_TOOL_INFO(data)
    self.toolsInfo = HomeMgr.allFishToolsInfo
    if not self.toolsInfo or self.myGid ~= self.toolsInfo.gid then
        return
    end
    
    for name, amount in pairs(self.toolsInfo.poles) do
        self:refreshShowNum(name, amount, self.polesInfo)
    end
    
    for name, amount in pairs(self.toolsInfo.baits) do
        self:refreshShowNum(name, amount, self.baitsInfo)
    end
    
    local item = self.selectItem
    if item then
        if self.inputNum + item.amount > LIMIT_NUM then
            self.inputNum = LIMIT_NUM - item.amount
            self:setShopPanel()
        end
        
        if self.toolsInfo.poles[item.name] then
            self:onSelectPole(item.cell, nil)
        elseif self.toolsInfo.baits[item.name] then 
            self:onSelectBait(item.cell, nil)
        end
    end
end

-- 更新部分鱼具消息
function ChooseFishToolDlg:MSG_HOUSE_FISH_TOOL_PART_INFO(data)
    if self.myGid ~= data.gid then
        return
    end
    
    for name, amount in pairs(data.tools) do
        if data.tool_type == TOOL_TYPE_POLE then
            self:refreshShowNum(name, amount, self.polesInfo)
        else
            self:refreshShowNum(name, amount, self.baitsInfo)
        end
    end
    
    local item = self.selectItem
    if item and item.type == data.tool_type then
        if self.inputNum + item.amount > LIMIT_NUM then
            self.inputNum = LIMIT_NUM - item.amount
            self:setShopPanel()
        end
        
        if data.tools[item.name] then
            if item.type == TOOL_TYPE_POLE then
                self:onSelectPole(item.cell, nil)
            else
                self:onSelectBait(item.cell, nil)
            end
        end
    end
end

-- 刷新金钱
function ChooseFishToolDlg:MSG_UPDATE()
    self:refreshInfo()
end

return ChooseFishToolDlg
