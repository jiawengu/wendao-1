-- MarketGoldSellGoodsDlg.lua
-- Created by
--

local MarketGoldSellGoodsDlg = Singleton("MarketGoldSellGoodsDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

-- 价格上限
local PRICE_MAX = 100000000        -- 最高

local VENDUE_TWF        = 500000    -- 拍卖的摊位费


-- 寄售类型checkBox
local TRADE_TYPE_CHECKBOX = {
    "CommonSellButton",
    "DesignatedSellButton",
    "VendueSellButton",
}

local TRADE_TYPE_CHECKBOX_2 = {
    "CommonSellButton",
    "DesignatedSellButton",
}

local TRADE_TYPE_CHECKBOX_4 = {
    "CommonSellButton",
    "VendueSellButton",
}


local TRADE_TYPE_PANEL = {
    ["CommonSellButton"] = "CommonSellPanel",
    ["DesignatedSellButton"] = "DesignatedSellPanel",
    ["VendueSellButton"] = "VenduePanel",
}

local SELL_TYPE = {
    NORMAL          = 1,    -- 普通上架
    DESIGNATED      = 2,    -- 指定交易
    VENDUE          = 5,    -- 指定交易

}

function MarketGoldSellGoodsDlg:init()
    self:bindListener("SellButton", self.onSellButton)
    self:bindListener("SellButton", self.onVendueSellButton, "VenduePanel")
    self:bindListener("DesignatedButton", self.onDesignatedButton)
    self:bindListener("SellButton", self.onDSellButton, "DesignatedSellPanel")
    self:bindListener("NoteButton", self.onNoteButton)
    self:bindListener("NoteButton", self.onVendueNoteButton, "VenduePanel")
    self:bindListener("VendueButton", self.onVendueButton)

    self:bindListener("Label_1_0_0", self.onNoteButton)

    self:bindCheckBoxListener("CheckBox", self.onCheckBox)
    gf:grayImageView(self:getControl("SellButton", nil, "DesignatedSellPanel"))

    self.data = nil
    self.commonPrice = nil
    self.designatePrice = nil
    self.parentDlg = nil
    self.designatedChar = nil



    self:bindSellNumInput()

    self:refreshVendueCost()    --  初始化摊位费

    --self:setCtrlVisible("SellTypePanel", true)
    self:setCtrlVisible("SellTypePanel", false)
    self:setCtrlVisible("SellTypePanel_2", false)
    self:setCtrlVisible("SellTypePanel_3", false)
    self:setCtrlVisible("SellTypePanel_4", false)



    if MarketMgr.goldStallConfig then
        if MarketMgr.goldStallConfig.enable_appoint == 1 and MarketMgr.goldStallConfig.enable_autcion == 1 then
            self:setCtrlVisible("SellTypePanel", true)
        elseif MarketMgr.goldStallConfig.enable_appoint == 1 then
            self:setCtrlVisible("SellTypePanel_2", true)
        elseif MarketMgr.goldStallConfig.enable_autcion == 1 then
            self:setCtrlVisible("SellTypePanel_4", true)
        else
            self:setCtrlVisible("SellTypePanel_3", true)
        end
    else
        self:setCtrlVisible("SellTypePanel_4", true)
    end
    self:onTradeCheckBox(self:getControl(TRADE_TYPE_CHECKBOX[1]))

    self:initTradeCheckBox()

end

function MarketGoldSellGoodsDlg:onCheckBox(sender, eventType)
    if sender:getSelectedState() then
        gf:resetImageView(self:getControl("SellButton", nil, "DesignatedSellPanel"))
    else
        gf:grayImageView(self:getControl("SellButton", nil, "DesignatedSellPanel"))
    end
end

function MarketGoldSellGoodsDlg:cleanup()
    self.data = nil
end

function MarketGoldSellGoodsDlg:setItem(data)
    self.data = data
end

-- 绑定输入框
function MarketGoldSellGoodsDlg:bindSellNumInput()
    -- 普通交易
    local moneyPanel = self:getControl('ValuePanel', nil, "PricePanel")
    local function openNumIuputDlg()
        local rect = self:getBoundingBoxInWorldSpace(moneyPanel)
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setObj(self)
        dlg:setKey("normal")

        dlg.root:setPosition((rect.x + rect.width / 2), rect.y - dlg.root:getContentSize().height / 2 - 10)
        dlg:setCtrlVisible("UpImage", false)
        dlg:setCtrlVisible("DownImage", true)
        self.inputNum = 0
    end
    self:bindTouchEndEventListener(moneyPanel, openNumIuputDlg)

        -- 指定交易
    local designPanel = self:getControl('PricePanel', nil, "DesignatedSellPanel")
    local moneyPanel = self:getControl('ValuePanel', nil, designPanel)
    local function openNumIuputDlg()

        local rect = self:getBoundingBoxInWorldSpace(moneyPanel)
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setObj(self)
        dlg:setKey("designated")
        dlg.root:setPosition((rect.x + rect.width / 2), rect.y - dlg.root:getContentSize().height / 2 - 10)
        dlg:setCtrlVisible("UpImage", false)
        dlg:setCtrlVisible("DownImage", true)

        self.inputNumDesignated = 0
    end
    self:bindTouchEndEventListener(moneyPanel, openNumIuputDlg)

    -- 拍卖
    local venduePanel = self:getControl('PricePanel', nil, "VenduePanel")
    local moneyPanel = self:getControl('ValuePanel', nil, venduePanel)
    local function openNumIuputDlg()

        local rect = self:getBoundingBoxInWorldSpace(moneyPanel)
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setObj(self)
        dlg:setKey("vendue")
        dlg.root:setPosition((rect.x + rect.width / 2), rect.y - dlg.root:getContentSize().height / 2 - 10)
        dlg:setCtrlVisible("UpImage", false)
        dlg:setCtrlVisible("DownImage", true)

        self.inputNumVendue = 0
    end
    self:bindTouchEndEventListener(moneyPanel, openNumIuputDlg)
end

-- 数字键盘删除数字
function MarketGoldSellGoodsDlg:deleteNumber(key)
    if key == "normal" then
        self.inputNum = math.floor(self.inputNum / 10)
        self:refreshCommonCost(self.inputNum )
    elseif key == "designated" then
        self.inputNumDesignated = math.floor(self.inputNumDesignated / 10)
        self:refreshDesignatedCost(self.inputNumDesignated)
    elseif key == "vendue" then
        self.inputNumVendue = math.floor(self.inputNumVendue / 10)
        self:refreshVendueCost(self.inputNumVendue)
    end
end

-- 数字键盘清空
function MarketGoldSellGoodsDlg:deleteAllNumber(key)
    if key == "normal" then
        self.inputNum = 0
        self:refreshCommonCost(self.inputNum)
    elseif key == "designated" then
        self.inputNumDesignated = 0
        self:refreshDesignatedCost(self.inputNumDesignated)
    elseif key == "vendue" then
        self.inputNumVendue = 0
        self:refreshVendueCost(self.inputNumVendue)
    end
end

-- 数字键盘插入数字
function MarketGoldSellGoodsDlg:insertNumber(num, key)

    local function setNum(num, inputNum, key)
        if num == "00" then
            inputNum = inputNum * 100
        elseif num == "0000" then
            inputNum = inputNum * 10000
        else
            inputNum = inputNum * 10 + num
        end

        if key == "vendue" then

            if inputNum >= MarketMgr:getVendueMax() then
                inputNum = MarketMgr:getVendueMax()
                gf:ShowSmallTips(CHS[3003069])
            end
        else
            if inputNum >= PRICE_MAX then
                inputNum = PRICE_MAX
                gf:ShowSmallTips(CHS[3003069])
            end
        end

        return inputNum
    end

    if key == "normal" then
        self.inputNum = setNum(num, self.inputNum)
        self:refreshCommonCost(self.inputNum)
    elseif key == "designated" then
        self.inputNumDesignated = setNum(num, self.inputNumDesignated)
        self:refreshDesignatedCost(self.inputNumDesignated)
    elseif key == "vendue" then
        self.inputNumVendue = setNum(num, self.inputNumVendue, key)
        self:refreshVendueCost(self.inputNumVendue)
    end
end

function MarketGoldSellGoodsDlg:isMeetGoldSellCondition(item)


    if not MarketMgr:checkItemSellCondition(item, self:getTradeType()) then
        return
    end
end


-- 设置、刷新价格相关
function MarketGoldSellGoodsDlg:refreshCost(price, panelName)

    -- 出售价格
    local sellPricePanel = self:getControl("PricePanel", nil, panelName)
    if not price then
        self:removeNumImgForPanel("ValuePanel", LOCATE_POSITION.MID, sellPricePanel)
        self:setCtrlVisible("DefaultLabel", true, sellPricePanel)
    else
        local cashText, fonColor = gf:getArtFontMoneyDesc(price)
        self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, sellPricePanel)
        self:setCtrlVisible("DefaultLabel", false, sellPricePanel)
    end

    -- 摊位费
    local taxPanel = self:getControl("TaxPanel", nil, panelName)
    local cashText, fonColor = gf:getArtFontMoneyDesc(self:getBoothCost(price or 0))
    self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, taxPanel)
end

-- 获取摊位费
function MarketGoldSellGoodsDlg:getBoothCost(sellPrice, sellType)
    if sellType == SELL_TYPE.VENDUE then
        return VENDUE_TWF
    end

    return MarketMgr:getBoothCost(sellPrice, false, MarketMgr.TradeType.goldType)
end

-- 设置、刷新价格相关
function MarketGoldSellGoodsDlg:refreshCommonCost(price)
    self.commonPrice = price

    self:refreshCost(price, "CommonSellPanel")
end

-- 设置、刷新价格相关  拍卖
function MarketGoldSellGoodsDlg:refreshVendueCost(price)
    self.venduePrice = price

    self:refreshCost(price, "VenduePanel")

    -- 摊位费

    local taxPanel = self:getControl("TaxPanel", nil, "VenduePanel")
    local cashText, fonColor = gf:getArtFontMoneyDesc(VENDUE_TWF)
    self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, taxPanel)
end

-- 设置、刷新价格相关
function MarketGoldSellGoodsDlg:refreshDesignatedCost(price)
    self.designatePrice = price

    self:refreshCost(price, "DesignatedSellPanel")

    -- 一口价
    local ykjPricePanel = self:getControl("FixedPricePanel", nil, designPanel)
    if not price then
        self:removeNumImgForPanel("ValuePanel", LOCATE_POSITION.MID, ykjPricePanel)
    else
        local cashText, fonColor = gf:getArtFontMoneyDesc(MarketMgr:getGoldYkj(price))
        self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, ykjPricePanel)
    end

    -- 订金
    local depositPanel = self:getControl("DepositPanel", nil, designPanel)
    if not price then
        self:removeNumImgForPanel("ValuePanel", LOCATE_POSITION.MID, depositPanel)
    else
        local cashText, fonColor = gf:getArtFontMoneyDesc(MarketMgr:getDepositDingJin(price))
        self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, depositPanel)
    end
end

-- 单选框初始化
function MarketGoldSellGoodsDlg:initTradeCheckBox()
    self.tradeGroup = RadioGroup.new()
    self.tradeGroup:setItemsByButton(self, TRADE_TYPE_CHECKBOX, self.onTradeCheckBox, nil, nil, nil, self.onTradeLimitFun)
    self:onTradeCheckBox(self:getControl(TRADE_TYPE_CHECKBOX[1]))

    self.tradeGroup2 = RadioGroup.new()
    self.tradeGroup2:setItemsByButton(self, TRADE_TYPE_CHECKBOX_2, self.onTradeCheckBox, "SellTypePanel_2", nil, nil, self.onTradeLimitFun)
    self:onTradeCheckBox(self:getControl(TRADE_TYPE_CHECKBOX_2[1], nil, "SellTypePanel_2"))

    self.tradeGroup4 = RadioGroup.new()
    self.tradeGroup4:setItemsByButton(self, TRADE_TYPE_CHECKBOX_4, self.onTradeCheckBox, "SellTypePanel_4", nil, nil, self.onTradeLimitFun)
    self:onTradeCheckBox(self:getControl(TRADE_TYPE_CHECKBOX_4[1], nil, "SellTypePanel_4"))


end

-- 点击交易类型信息的checkBox
function MarketGoldSellGoodsDlg:onTradeLimitFun(sender, idx)
    if sender:getName() == "DesignatedSellButton" then
        if MarketMgr.goldStallConfig and MarketMgr.goldStallConfig.enable_appoint ~= 1 then
            gf:ShowSmallTips(CHS[4101209])
            return
        end
    elseif sender:getName() == "VendueSellButton" then
        if MarketMgr.goldStallConfig and MarketMgr.goldStallConfig.enable_autcion ~= 1 then
            gf:ShowSmallTips(CHS[4101209])
            return
        end
    end

    return true
end


-- 点击交易类型信息的checkBox
function MarketGoldSellGoodsDlg:onTradeCheckBox(sender, eventType)
    for _, panelName in pairs(TRADE_TYPE_PANEL) do
        self:setCtrlVisible(panelName, false)
        self:setCtrlVisible("ChosenPanel", false, _)
        self:setCtrlVisible("UnChosenPanel", true, _)
    end

    self:setCtrlVisible(TRADE_TYPE_PANEL[sender:getName()], true)
end


function MarketGoldSellGoodsDlg:sell(price, isReStall, sellType)

    sellType = sellType or SELL_TYPE.NORMAL

    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

        -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

        -- 安全锁判断
    if self:checkSafeLockRelease("sell", price, isReStall, sellType) then
        return
    end

    if not isReStall then
		-- 非重新寄售
        -- 任务 WDSY-27647 中，点击摆摊的时候，重新判断条件
        if not self.data.item_type then
            if not PetMgr:getPetById(tonumber(self.data:queryBasic("id"))) then
                gf:ShowSmallTips(CHS[6200054])
                DlgMgr:closeDlg(self.name)
                return
            end

            if not MarketMgr:checkPetSellCondition(PetMgr:getPetById(self.data:queryBasicInt("id")), self:getTradeType()) then return end
        else
            local item = InventoryMgr:getItemByPos(self.data.pos)
            if not item then
                gf:ShowSmallTips(CHS[6200054])
                DlgMgr:closeDlg(self.name)
                return
            end

            if not MarketMgr:checkItemSellCondition(item, self:getTradeType()) then return end
        end
    end

    local sellTypeForServer = 0 -- 服务器需要的sellType
    -- 价格判断
    if sellType == SELL_TYPE.VENDUE then
        if not price or price == 0 then
            gf:ShowSmallTips(CHS[4101101])
            return
        end

        if price < MarketMgr:getVendueMin() then
            gf:ShowSmallTips(string.format(CHS[4101225], MarketMgr:getVendueMin() ))    -- 拍卖底价不能少于%d元宝。
            return
        end

        if price > MarketMgr:getVendueMax() then
            gf:ShowSmallTips(string.format(CHS[4101219], MarketMgr:getVendueMax() ))    -- 拍卖底价不能少于%d元宝。
            return
        end

        sellTypeForServer = sellType
    else
        if not price or price == 0 then
            gf:ShowSmallTips(CHS[3003074])
            return
        end

        if price < 1000 then
            gf:ShowSmallTips(CHS[4010217])
            return
        end
    end

    local sellNum = MarketMgr:getSellPosCount(self:getTradeType())
    local allNum = MarketMgr:getMySellNum(self:getTradeType())

    if not sellNum then
        gf:ShowSmallTips(CHS[3003075])
        return
    end

    if not isReStall then
        if sellNum >= allNum then
            if Me:getVipType() ~= 3 then
                gf:ShowSmallTips(CHS[3003076])
                return
            else
                gf:ShowSmallTips(CHS[3003077])
                return
            end
        end
    end


    if not self.designatedChar and sellType == SELL_TYPE.DESIGNATED then
        gf:ShowSmallTips(CHS[4100973])
        return
    end

    if self:getBoothCost(price, sellType) > Me:queryBasicInt('cash') then
        gf:askUserWhetherBuyCash()
        return
    end

    local sellPos = MarketMgr:getSellPos(self:getTradeType())
    local data = self.data
    if isReStall then
        MarketMgr:reStartSell(self.tradeInfo.id, price, self:getTradeType(), nil, nil)
    elseif sellPos then
        if data.item_type then
            if not InventoryMgr:getItemByPos(data.pos) then
                gf:ShowSmallTips(CHS[6200054])
                self:closeParentDlg()
                return
            end


            local gid =  ""
            if sellType == SELL_TYPE.DESIGNATED then
                gid = self.designatedChar and self.designatedChar.gid or ""
            end


            MarketMgr:startSell(data.pos, price, sellPos, 1, self:getTradeType(), self.inputCount or 1, gid, sellTypeForServer)
        else
            if not PetMgr:getPetById(tonumber(data:queryBasic("id"))) then
                gf:ShowSmallTips(CHS[6200054])
                self:closeParentDlg()
                return
            end

            local gid =  ""
            if sellType == SELL_TYPE.DESIGNATED then
                gid = self.designatedChar and self.designatedChar.gid or ""
            end
            MarketMgr:startSell(data:queryBasic("id"), price, sellPos, 2, self:getTradeType(), 1, gid, sellTypeForServer)
        end
     end

    self:closeParentDlg()
    return true
end

function MarketGoldSellGoodsDlg:closeParentDlg()
    if self.parentDlg then
        DlgMgr:closeDlg(self.parentDlg.name)
    end
end

function MarketGoldSellGoodsDlg:onCommonSellButton(sender, eventType)
end

function MarketGoldSellGoodsDlg:onDesignatedSellButton(sender, eventType)
end


function MarketGoldSellGoodsDlg:onSellButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    self:sell(self.commonPrice)
end



-- 拍卖出售
function MarketGoldSellGoodsDlg:onVendueSellButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    self:sell(self.venduePrice, nil, SELL_TYPE.VENDUE)
--[[
    local dlg = DlgMgr:openDlg("MarketGoldBidDlg")
    dlg:setData(self.data)
    --]]
end

-- 指定交易出售
function MarketGoldSellGoodsDlg:onDSellButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if not self:isCheck("CheckBox") then
        gf:ShowSmallTips(CHS[4101265])
        return
    end

    self:sell(self.designatePrice, nil, SELL_TYPE.DESIGNATED)
end

function MarketGoldSellGoodsDlg:onDesignatedButton(sender, eventType)
    DlgMgr:openDlg("DesignatedUserDlg")
end

function MarketGoldSellGoodsDlg:setDesignatedChar(char)
    self:setLabelText("DefaultLabel", char.name, "DesignatedNamePanel")
    self.designatedChar = char
end

function MarketGoldSellGoodsDlg:onNoteButton(sender, eventType)
       local dlg = DlgMgr:openDlg("MarketRuleDlg")
        dlg:setRuleType("MarketGoldItemInfoDlg")
end

function MarketGoldSellGoodsDlg:onVendueNoteButton(sender, eventType)
    local dlg = DlgMgr:openDlg("MarketRuleDlg")
    dlg:setRuleType("VendueReSellPanel")
end

function MarketGoldSellGoodsDlg:onVendueButton(sender, eventType)
end

function MarketGoldSellGoodsDlg:getTradeType()
    return MarketMgr.TradeType.goldType
end


return MarketGoldSellGoodsDlg
