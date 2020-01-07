-- MarketGoldReSellGoodsDlg.lua
-- Created by songcw
-- 珍宝展示界面，重新寄售


local MarketGoldReSellGoodsDlg = Singleton("MarketGoldReSellGoodsDlg", Dialog)

-- 价格上限
local PRICE_MAX = 100000000        -- 最高

function MarketGoldReSellGoodsDlg:init()
    self:bindListener("TakeBackButton", self.onTakeBackButton, "CommonReSellPanel")
 --   self:bindListener("ReSellButton", self.onReSellButton)
    self:bindListener("TakeBackButton", self.onTakeBackButton, "DesignatedReSellPanel")
    self:bindListener("TakeBackButton", self.onTakeBackButton, "VendueReSellPanel")
 --   self:bindListener("ReSellButton", self.onReSellButton)
    self:bindListener("NoteButton", self.onNoteButton)
    self:bindListener("NoteButton_2", self.onNoteButton_2)
    self:bindListener("VendueButton", self.onVendueButton)

    self:bindListener("ReSellButton", self.onDReSellButton, "DesignatedReSellPanel")
    self:bindListener("ReSellButton", self.onCReSellButton, "CommonReSellPanel")
    self:bindListener("ContinueButton", self.onVReSellButton, "VendueReSellPanel")
    self:bindListener("NoteButton", self.onVendueNoteButton, "VendueReSellPanel")

    self:bindListener("VendueSellButton", self.onVendueSellButton)
    self:bindListener("NormalSellButton", self.onNormalSellButton)

    self:bindFloatPanelListener("ButtonFloatPanel")

    self:bindSellNumInput()

    self.tradeInfo = nil
    self.designatedResellPrice = nil
    self.commonResellPrice = nil
    self.vendueResellPrice = nil
    self.parentDlg = nil
end

-- 绑定输入框
function MarketGoldReSellGoodsDlg:bindSellNumInput()
    -- 重新摆摊
    local designNPPanel = self:getControl('NewPricePanel', nil, "DesignatedReSellPanel")
    local moneyNPPanel = self:getControl('ValuePanel', nil, designNPPanel)
    local function openNumIuputDlg()

        local rect = self:getBoundingBoxInWorldSpace(moneyNPPanel)
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setObj(self)
        dlg:setKey("designatedNewPrice")
        dlg.root:setPosition((rect.x + rect.width / 2), rect.y + dlg.root:getContentSize().height * 0.5 + 50)
        dlg:setCtrlVisible("UpImage", true)
        dlg:setCtrlVisible("DownImage", false)

        self.inputNumDesignatedNewPrice = 0
    end
    self:bindTouchEndEventListener(moneyNPPanel, openNumIuputDlg)

    -- 普通交易过期，输入新价格
    local designPanel = self:getControl('NewPricePanel', nil, "CommonReSellPanel")
    local moneyPanel = self:getControl('ValuePanel', nil, designPanel)
    local function openNumIuputDlg()

        local rect = self:getBoundingBoxInWorldSpace(moneyPanel)
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setObj(self)
        dlg:setKey("commonResell")
        dlg.root:setPosition((rect.x + rect.width / 2), rect.y - dlg.root:getContentSize().height / 2 - 10)
        dlg:setCtrlVisible("UpImage", false)
        dlg:setCtrlVisible("DownImage", true)

        self.inputNumCommonResell = 0
    end
    self:bindTouchEndEventListener(moneyPanel, openNumIuputDlg)

    -- 拍卖交易过期，输入新价格
    local designPanel = self:getControl('NewPricePanel', nil, "VendueReSellPanel")
    local moneyPanel = self:getControl('ValuePanel', nil, designPanel)
    local function openNumIuputDlg()

        local rect = self:getBoundingBoxInWorldSpace(moneyPanel)
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setObj(self)
        dlg:setKey("vendueResell")
        dlg.root:setPosition((rect.x + rect.width / 2), rect.y + dlg.root:getContentSize().height * 0.5 + 60)
        dlg:setCtrlVisible("UpImage", true)
        dlg:setCtrlVisible("DownImage", false)

        self.inputNumVendueResell = 0
    end
    self:bindTouchEndEventListener(moneyPanel, openNumIuputDlg)
end

-- 数字键盘删除数字
function MarketGoldReSellGoodsDlg:deleteNumber(key)
    if key == "designatedNewPrice" then
        self.inputNumDesignatedNewPrice = math.floor(self.inputNumDesignatedNewPrice / 10)
        self:refreshDesignatedNewPriceCost(self.inputNumDesignatedNewPrice, "DesignatedReSellPanel")
    elseif key == "commonResell" then
        self.inputNumCommonResell = math.floor(self.inputNumCommonResell / 10)
        self:refreshDesignatedNewPriceCost(self.inputNumCommonResell, "CommonReSellPanel")
    elseif key == "vendueResell" then
        self.inputNumVendueResell = math.floor(self.inputNumVendueResell / 10)
        self:refreshDesignatedNewPriceCost(self.inputNumVendueResell, "VendueReSellPanel")
    end
end

-- 数字键盘插入数字
function MarketGoldReSellGoodsDlg:insertNumber(num, key)

    local function setNum(num, inputNum)
        if num == "00" then
            inputNum = inputNum * 100
        elseif num == "0000" then
            inputNum = inputNum * 10000
        else
            inputNum = inputNum * 10 + num
        end

        if inputNum >= PRICE_MAX then
            inputNum = PRICE_MAX
            gf:ShowSmallTips(CHS[3003069])
        end

        return inputNum
    end

    if key == "designatedNewPrice" then
        self.inputNumDesignatedNewPrice = setNum(num, self.inputNumDesignatedNewPrice)
        self:refreshDesignatedNewPriceCost(self.inputNumDesignatedNewPrice, "DesignatedReSellPanel")
    elseif key == "commonResell" then
        self.inputNumCommonResell = setNum(num, self.inputNumCommonResell)
        self:refreshDesignatedNewPriceCost(self.inputNumCommonResell, "CommonReSellPanel")
    elseif key == "vendueResell" then
        self.inputNumVendueResell = setNum(num, self.inputNumVendueResell)
        self:refreshDesignatedNewPriceCost(self.inputNumVendueResell, "VendueReSellPanel")
    end
end

-- 数字键盘清空
function MarketGoldReSellGoodsDlg:deleteAllNumber(key)
    if key == "designatedNewPrice" then
        self.inputNumDesignatedNewPrice = 0
        self:refreshDesignatedNewPriceCost(self.inputNumDesignatedNewPrice, "DesignatedReSellPanel")
    elseif key == "commonResell" then
        self.inputNumCommonResell = 0
        self:refreshDesignatedNewPriceCost(self.inputNumCommonResell, "CommonReSellPanel")
    elseif key == "vendueResell" then
        self.inputNumVendueResell = 0
        self:refreshDesignatedNewPriceCost(self.inputNumVendueResell, "VendueReSellPanel")
    end
end

-- 指定交易重新上架价格
function MarketGoldReSellGoodsDlg:refreshDesignatedNewPriceCost(price, panelName)
    if panelName == "DesignatedReSellPanel" then
        self.designatedResellPrice = price
    elseif panelName == "CommonReSellPanel" then
        self.commonResellPrice = price
    elseif panelName == "VendueReSellPanel" then
        self.vendueResellPrice = price
    end

    local panel = self:getControl(panelName)

        -- 出售价格
    local sellPricePanel = self:getControl("NewPricePanel", nil, panel)
    if not price then
        self:removeNumImgForPanel("ValuePanel", LOCATE_POSITION.MID, sellPricePanel)
        self:setCtrlVisible("DefaultLabel", true, sellPricePanel)
    else
        local cashText, fonColor = gf:getArtFontMoneyDesc(price)
        self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, sellPricePanel)
        self:setCtrlVisible("DefaultLabel", false, sellPricePanel)
    end

    -- 摊位费
    local taxPanel = self:getControl("TaxPanel", nil, panel)

    if taxPanel then
        local cashText, fonColor = gf:getArtFontMoneyDesc(MarketMgr:getBoothCost(price or 0))
        self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, taxPanel)
    end
end

function MarketGoldReSellGoodsDlg:closeParentDlg()
    if self.parentDlg then
        DlgMgr:closeDlg(self.parentDlg.name)
    end
end

function MarketGoldReSellGoodsDlg:setData(item, tradeInfo)

    local paraExtra = tradeInfo.extra or tradeInfo.para_str
    local goodsData = json.decode(paraExtra)
    for field, value in pairs(goodsData) do
        tradeInfo[field] = value
    end

    self.tradeInfo = tradeInfo

    local isVisibleCommonResell = (tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_NONE or tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_CONTINUE)
    self:setCtrlVisible("CommonReSellPanel", isVisibleCommonResell, "RightPanel")
    self:setCtrlVisible("DesignatedReSellPanel", tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_SELL, "RightPanel")
    self:setCtrlVisible("VendueReSellPanel", tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_AUCTION, "RightPanel")

    if tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_SELL then
        self:setDesignatedByPanelName(tradeInfo, "DesignatedReSellPanel")
    elseif isVisibleCommonResell then
        self:setCommonOutTime(tradeInfo)
    elseif tradeInfo.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_AUCTION then
        self:setVendue(tradeInfo)
    end
end

-- 设置 查看已经上架的拍卖类型的交易信息
function MarketGoldReSellGoodsDlg:setVendue(data)
    local panel = self:getControl("VendueReSellPanel")
    -- 原拍卖低价
    local pricePanel = self:getControl("PricePanel", nil, panel)
    local cashText, fonColor = gf:getArtFontMoneyDesc(data.price)
    self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, pricePanel)

    self:refreshDesignatedNewPriceCost(data.price, "VendueReSellPanel")
end

-- 设置 查看已经上架的普通类型的交易信息
function MarketGoldReSellGoodsDlg:setCommonOutTime(data)
    local panel = self:getControl("CommonReSellPanel")
    -- 价格
    local pricePanel = self:getControl("PricePanel", nil, panel)
    local cashText, fonColor = gf:getArtFontMoneyDesc(data.price)
    self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, pricePanel)


    self:refreshDesignatedNewPriceCost(data.price, "CommonReSellPanel")
end


-- 设置 查看已经上架的普通类型的交易信息
function MarketGoldReSellGoodsDlg:setDesignatedByPanelName(tradeInfo, panelName)

    local panel = self:getControl(panelName)

    -- 设置名字
    local namePanel = self:getControl("DesignatedNamePanel", nil, panel)
    self:setLabelText("DefaultLabel", tradeInfo.appointee_name, namePanel)

    -- 指定价格
    local pricePanel = self:getControl("PricePanel", nil, panel)
    local cashText, fonColor = gf:getArtFontMoneyDesc(tradeInfo.price)
    self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, pricePanel)

    -- 一口价
    local fixedPanel = self:getControl("FixedPricePanel", nil, panel)
    local cashText, fonColor = gf:getArtFontMoneyDesc(tradeInfo.buyout_price)
    self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, fixedPanel)

    -- 剩余时间
    local leftPanel = self:getControl("LeftTimePanel", nil, panel)
    -- 处于公示、寄售
    local leftTime = tradeInfo.endTime - gf:getServerTime()
    if tradeInfo.status == MarketMgr.TRADE_GOLD_STATE.SHOW then
        self:setLabelText("PublicLabel_1", string.format( CHS[4101208], MarketMgr:getTimeStr(leftTime)), leftPanel) -- 公示中，剩余时间：
        self:setCtrlEnabled("BuyButton", false, panel)
    elseif tradeInfo.status == MarketMgr.TRADE_GOLD_STATE.ON_SELL then
        self:setLabelText("PublicLabel_1", string.format( CHS[4010218], MarketMgr:getTimeStr(leftTime)), leftPanel) -- 指定交易摆摊中,剩余时间：
    end

    -- 订金
    local depositPanel = self:getControl("DepositPanel", nil, designPanel)
    if not tradeInfo.price then
        self:removeNumImgForPanel("ValuePanel", LOCATE_POSITION.MID, depositPanel)
    else
        local cashText, fonColor = gf:getArtFontMoneyDesc(MarketMgr:getDepositDingJin(tradeInfo.price))
        self:setNumImgForPanel("ValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 23, depositPanel)
    end

    -- 定金支付情况
    if tradeInfo.deposit_state == 1 or tradeInfo.deposit_state == 3 or tradeInfo.deposit_state == 4 then
        self:setLabelText("NoteLabel_0", string.format( CHS[4101262]), depositPanel)
    else
        self:setLabelText("NoteLabel_0", string.format( CHS[4101263]), depositPanel)
    end

    self:refreshDesignatedNewPriceCost(tradeInfo.price, "DesignatedReSellPanel")
end

function MarketGoldReSellGoodsDlg:onTakeBackButton(sender, eventType)
    gf:confirm(CHS[3003073], function()
        MarketMgr:stopSell(self.tradeInfo.id, MarketMgr.TradeType.goldType)

        self:closeParentDlg()
    end, nil, nil, nil, nil, true)
end

-- 指定交易 重新摆摊
function MarketGoldReSellGoodsDlg:onDReSellButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end


    self.designatedChar = {gid = self.tradeInfo.appointee_gid}

    self:sell(self.designatedResellPrice, true, ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_SELL)
end


function MarketGoldReSellGoodsDlg:onVendueSellButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end


    self:sell(self.vendueResellPrice, true, ZHENBAO_TRADE_TYPE.STALL_SBT_AUCTION)
end

function MarketGoldReSellGoodsDlg:onNormalSellButton(sender, eventType)
    self:sell(self.vendueResellPrice, true)
end

-- 拍卖 重新摆摊
function MarketGoldReSellGoodsDlg:onVReSellButton(sender, eventType)
    self:setCtrlVisible("ButtonFloatPanel", true)
end

-- 普通 重新摆摊
function MarketGoldReSellGoodsDlg:onCReSellButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end


    self:sell(self.commonResellPrice, true)
end


function MarketGoldReSellGoodsDlg:sell(price, isReStall, sellType)
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
                self:closeParentDlg()
                return
            end

            if not MarketMgr:checkPetSellCondition(PetMgr:getPetById(self.data:queryBasicInt("id")), self:getTradeType()) then return end
        else
            local item = InventoryMgr:getItemByPos(self.data.pos)
            if not item then
                gf:ShowSmallTips(CHS[6200054])
                self:closeParentDlg()
                return
            end

            if not MarketMgr:checkItemSellCondition(item, self:getTradeType()) then return end
        end
    end


    if sellType == ZHENBAO_TRADE_TYPE.STALL_SBT_AUCTION then
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

        if price < math.floor( self.tradeInfo.price * 0.8 ) then
            gf:ShowSmallTips(CHS[4101232])    --拍卖底价不能小于上次价格的80%，无法拍卖
            return
        end

        if price > math.floor( self.tradeInfo.price * 1.2 ) then
            gf:ShowSmallTips(CHS[4101233])    -- 拍卖底价不能高于上次价格的120%，无法拍卖。"
            return
        end
    else

        if not price or price == 0 then
            gf:ShowSmallTips(CHS[3003074])
            return
        end

        if price <= 1000 then
            gf:ShowSmallTips(CHS[4010217])
            return
        end
    end

    local sellNum = MarketMgr:getSellPosCount(self:getTradeType())
    local allNum = MarketMgr:getMySellNum(self:getTradeType())

    if not sellNum then
        gf:ShowSmallTips("111"..CHS[3003075])
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


    if not self.designatedChar and sellType == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_SELL then
        gf:ShowSmallTips(CHS[4100973])
        return
    end

    if MarketMgr:getBoothCost(price) > Me:queryBasicInt('cash') then
        gf:askUserWhetherBuyCash()
        return
    end

    local sellPos = MarketMgr:getSellPos(self:getTradeType())
    local data = self.data
    if isReStall then
        if sellType == ZHENBAO_TRADE_TYPE.STALL_SBT_AUCTION then
            MarketMgr:reStartSell(self.tradeInfo.id, price, self:getTradeType(), sellType)
        else
            MarketMgr:reStartSell(self.tradeInfo.id, price, self:getTradeType())
        end
    elseif sellPos then
        if data.item_type then
            if not InventoryMgr:getItemByPos(data.pos) then
                gf:ShowSmallTips(CHS[6200054])
                self:closeParentDlg()
                return
            end


            local gid = self.designatedChar and self.designatedChar.gid or ""
            MarketMgr:startSell(data.pos, price, sellPos, 1, self:getTradeType(), self.inputCount or 1, gid)
        else
            if not PetMgr:getPetById(tonumber(data:queryBasic("id"))) then
                gf:ShowSmallTips(CHS[6200054])
                self:closeParentDlg()
                return
            end

            local gid = self.designatedChar and self.designatedChar.gid or ""
            MarketMgr:startSell(data:queryBasic("id"), price, sellPos, 2, self:getTradeType(), 1, gid)
        end
     end

    self:closeParentDlg()
    return true
end

function MarketGoldReSellGoodsDlg:getTradeType()
    return MarketMgr.TradeType.goldType
end

function MarketGoldReSellGoodsDlg:onNoteButton(sender, eventType)
    local dlg = DlgMgr:openDlg("MarketRuleDlg")
    dlg:setRuleType("MarketGoldItemInfoDlg")
end

function MarketGoldReSellGoodsDlg:onVendueNoteButton(sender, eventType)

    local dlg = DlgMgr:openDlg("MarketRuleDlg")
    dlg:setRuleType("VendueReSellPanel")
end


function MarketGoldReSellGoodsDlg:getPageStr()
    if not self.curPage then  self.curPage = 1 end

    local page_str = ""

    if self.curPage < 1 then
        self.curPage = 1
    end

    if self.upSort then
        page_str = string.format("%d;%d;%d;%s", self.curPage, MarketMgr.TRADE_GOLD_STATE.ON_SELL_VENDUE, 1, self.sortType or "price")
    else
        page_str = string.format("%d;%d;%d;%s", self.curPage, MarketMgr.TRADE_GOLD_STATE.ON_SELL_VENDUE, 2, self.sortType or "price")
    end

    return page_str
end


function MarketGoldReSellGoodsDlg:onNoteButton_2(sender, eventType)
end

function MarketGoldReSellGoodsDlg:onVendueButton(sender, eventType)
end

return MarketGoldReSellGoodsDlg
