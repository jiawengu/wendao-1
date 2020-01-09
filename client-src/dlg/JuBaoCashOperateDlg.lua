-- JuBaoCashOperateDlg.lua
-- Created by lixh2 Sep/27/2017
-- 聚宝斋金钱操作界面:取回，继续寄售

local JuBaoCashOperateDlg = Singleton("JuBaoCashOperateDlg", Dialog)

local LEFT_PANEL_NUMBER = 5  -- 左边正在寄售的金钱列表个数

local GONGSHI_TIME = 1    -- 公示期1天
local SELL_TIME = 3       -- 寄售期3天

local PRICE_MAX = 500     -- 寄售价格最高
local PRICE_MIX = 10

function JuBaoCashOperateDlg:init()
    self:bindListener("ResellButton", self.onResellButton)
    self:bindListener("TakeBackButton", self.onTakeBackButton)
    self:bindListener("ModifyPriceButton", self.onModifyPriceButton)

    self.goodsData = nil

    -- 价格输入
    self:bindSellNumInput()

    -- 价格修改按钮默认置灰
    self:setCtrlEnabled("ModifyPriceButton", false)

    TradingMgr:setCheckBindFlag(false)

    self:hookMsg("MSG_TRADING_OPER_RESULT")
    self:hookMsg("MSG_FUZZY_IDENTITY")
end

function JuBaoCashOperateDlg:setLeftPanel()
    -- 从管理器获取金钱订单信息
    local saleData = TradingMgr:getOtherCashData()
    if not saleData or not next(saleData) then
        self:setCtrlVisible("OtherCashPanel", false, "PriceComparePanel")
        self:setCtrlVisible("NoticePanel", true, "PriceComparePanel")
        return
    end

    self:setCtrlVisible("OtherCashPanel", true, "PriceComparePanel")
    self:setCtrlVisible("NoticePanel", false, "PriceComparePanel")

    for i = 1, #saleData do
        self:setCtrlVisible("ItemCell_" .. i, true, "OtherCashPanel")
        local panel = self:getControl("ItemCell_" .. i, nil, "OtherCashPanel")

        -- 头像
        local image = self:getControl("IconImage", nil, panel)
        image:loadTexture(ResMgr.ui.big_cash, ccui.TextureResType.plistType)
        gf:setItemImageSize(image)

        -- 总游戏币数量
        local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(saleData[i].goods_name))
        self:setNumImgForPanel("CashPanel", fontColor, cashText, false, LOCATE_POSITION.LEFT_TOP, 23, panel)

        -- 单价
        local moneyStr, fontColor = gf:getMoneyDesc(math.floor(tonumber(saleData[i].goods_name) / tonumber(saleData[i].price)), true)

        self:setLabelText("PerValueLabel", moneyStr, panel, fontColor)
        self:setLabelText("PerValueLabel2", moneyStr, panel)
    end

    for i = #saleData + 1, LEFT_PANEL_NUMBER do
        self:setCtrlVisible("ItemCell_" .. i, false, "OtherCashPanel")
    end
end

function JuBaoCashOperateDlg:setRightPanel(data)
    -- 出售金钱数量
    self.sellCount = tonumber(data.goods_name)
    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(self.sellCount))
    self:setNumImgForPanel("ValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, "SellCashPanel")

    -- 剩余时间
    if tonumber(data.state) == TRADING_STATE.SHOW then
        self:setLabelText("SaleLabel_2", string.format(CHS[7190095], tostring(SELL_TIME)), "LeftTimePanel")
        self:setLabelText("PublicLabel_2", TradingMgr:getLeftTime(tonumber(self.goodsData.end_time) - gf:getServerTime()), "LeftTimePanel")
    elseif tonumber(data.state) == TRADING_STATE.SALE then
        self:setLabelText("SaleLabel_2", TradingMgr:getLeftTime(tonumber(self.goodsData.end_time) - gf:getServerTime()), "LeftTimePanel")
        self:setLabelText("PublicLabel_2", CHS[4300146], "LeftTimePanel")
    else
        self:setLabelText("SaleLabel_2", string.format(CHS[7190095], tostring(SELL_TIME)), "LeftTimePanel")
        self:setLabelText("PublicLabel_2", CHS[4300146], "LeftTimePanel")
    end

    -- 取回，继续寄售，确认改价按钮状态
    if data.state == TRADING_STATE.SHOW or data.state == TRADING_STATE.SALE then
        self:setCtrlVisible("ModifyPriceButton", true)
        self:setCtrlVisible("ResellButton", false)
        self:setCtrlVisible("TakeBackButton", true)
    else
        self:setCtrlVisible("ModifyPriceButton", false)
        self:setCtrlVisible("ResellButton", true)
        self:setCtrlVisible("TakeBackButton", true)
    end

    -- 今日可修改次数
    self:setLabelText("ModifyPriceLabel", string.format(CHS[4100406], data.change_price_count))
end

-- 设置数字键盘输入
function JuBaoCashOperateDlg:bindSellNumInput()
    local moneyPanel = self:getControl('ValuePanel', nil, "PricePanel")
    local function openNumIuputDlg()
        local rect = self:getBoundingBoxInWorldSpace(moneyPanel)
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setObj(self)
        dlg.root:setPosition((rect.x + rect.width / 2), rect.y - dlg.root:getContentSize().height / 2 - 10)
        dlg:setCtrlVisible("UpImage", false)
        dlg:setCtrlVisible("DownImage", true)

        self.inputNum = nil
    end
    self:bindTouchEndEventListener(moneyPanel, openNumIuputDlg)
end

-- 数字键盘删除数字
function JuBaoCashOperateDlg:deleteNumber()
    self:setCtrlEnabled("ModifyPriceButton", true)
    if self.inputNum == nil then
        self.inputNum = 0
    end

    self.inputNum = math.floor(self.inputNum / 10)
    self:showInsertNumber()
end

-- 数字键盘清空
function JuBaoCashOperateDlg:deleteAllNumber()
    self:setCtrlEnabled("ModifyPriceButton", true)
    self.inputNum = 0
    self:showInsertNumber()
end

-- 数字界面关闭时再刷新界面其他金钱信息
function JuBaoCashOperateDlg:closeNumInputDlg()
    if self.inputNum then
        self:refreshCost(self.inputNum)
    end
end

-- 数字键盘插入数字
function JuBaoCashOperateDlg:insertNumber(num)
    self:setCtrlEnabled("ModifyPriceButton", true)
    if not self.inputNum then
        self.inputNum = 0
    end

    if num == "00" then
        self.inputNum = self.inputNum * 100
    elseif num == "0000" then
        self.inputNum = self.inputNum * 10000
    else
        self.inputNum = self.inputNum * 10 + num
    end

    if self.inputNum >= PRICE_MAX then
        self.inputNum = PRICE_MAX
        gf:ShowSmallTips(CHS[3002954])
    end

    self:showInsertNumber()
end

-- 数字键盘数字改变后，界面直接显示
function JuBaoCashOperateDlg:showInsertNumber()
    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(self.inputNum))
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText, false, LOCATE_POSITION.MID, 23, "PricePanel")
end

function JuBaoCashOperateDlg:refreshCost(price)
    local sellPriceMax = self:getSellPriceMax()
    local sellPriceMin = self:getSellPriceMin()

    self.sellPrice = price
    if self.sellPrice == 0 then
        gf:ShowSmallTips(CHS[7120016])
        self.sellPrice = self.goodsData.price
    end

    local cashText
    local fontColor

    -- 寄售价格
    local cashText = gf:getArtFontMoneyDesc(tonumber(self.sellPrice))
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText, false, LOCATE_POSITION.MID, 23, "PricePanel")

    -- 指导售价下限
    self:setLabelText("MinPriceLabel", sellPriceMin .. CHS[7190093], "GuidePricePanel")

    -- 指导售价上限
    self:setLabelText("MaxPriceLabel", sellPriceMax .. CHS[7190093], "GuidePricePanel")

    -- 实际收入
    local income = TradingMgr:getRealIncome(self.sellPrice, false, true)
    local cashText3 = gf:getArtFontMoneyDescByPoint(income, 2)
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText3, false, LOCATE_POSITION.MID, 23, "IncomePanel")

    -- 单价
    local perPrice = math.floor(self.sellCount / self.sellPrice)
    cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(perPrice))
    self:setNumImgForPanel("ValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, "PerValuePanel")
end

-- 获取当前订单售价指导上限
function JuBaoCashOperateDlg:getSellPriceMax()
    local guidePrice = TradingMgr:getCashStandardPrice()
    local guidePriceMax = math.floor(self.sellCount / math.ceil(guidePrice * 0.8))
    local guidePriceMin = math.ceil(self.sellCount / math.ceil(guidePrice * 1.2))
    return math.max(guidePriceMin, guidePriceMax)
end

-- 获取当前订单售价指导下限
function JuBaoCashOperateDlg:getSellPriceMin()
    local guidePrice = TradingMgr:getCashStandardPrice()
    local guidePriceMax = math.floor(self.sellCount / math.ceil(guidePrice * 0.8))
    local guidePriceMin = math.ceil(self.sellCount / math.ceil(guidePrice * 1.2))
    return math.min(guidePriceMin, guidePriceMax)
end

function JuBaoCashOperateDlg:queryBindNotAnswer()
    if not TradingMgr:getCheckBindFlag() then return end
    gf:ShowSmallTips(CHS[4300198])
    TradingMgr:setCheckBindFlag(false)
end

function JuBaoCashOperateDlg:setDlgData(tradingData)
    self.goodsData = tradingData
    self:setLeftPanel()
    self:setRightPanel(tradingData)
    self:refreshCost(tradingData.price)
end

function JuBaoCashOperateDlg:onResellButton(sender, eventType)
    if not TradingMgr:getIsCanSellCash() then
        gf:ShowSmallTips(string.format(CHS[7190096], TradingMgr:getSellCashAfterDays()))
        return
    end

    if not self.goodsData then return end
    local income = TradingMgr:getRealIncome(self.sellPrice, false, true)
    TradingMgr:cmdSellGoodsAgain(self.goodsData.goods_gid, self.sellPrice, TRADE_SBT.NONE, JUBAO_SELL_TYPE.SALE_TYPE_CASH)
end

function JuBaoCashOperateDlg:onTakeBackButton(sender, eventType)
    if not self.goodsData then return end

    if self.goodsData.state == TRADING_STATE.SALE then
        local dlg = gf:confirm(CHS[4100440], function ()
            TradingMgr:askAutoLoginToken(self.name, self.goodsData.goods_gid, nil, nil, true)
        end)
        dlg:setConfirmText(CHS[4300148])
        dlg:setCancleText(CHS[4200219])
        return
    end

    local gid = self.goodsData.goods_gid
    TradingMgr:cmdCancelGoods(gid)
end

function JuBaoCashOperateDlg:onModifyPriceButton(sender, eventType)
    if not self.goodsData then return end


    local meetMinPrice = self:getSellPriceMin()
    local meetMaxPrice = self:getSellPriceMax()
    if self.sellPrice < meetMinPrice then
        if PRICE_MIX >= meetMinPrice then
            gf:ShowSmallTips(string.format( CHS[4200563], PRICE_MIX))
        else
            gf:ShowSmallTips(string.format( CHS[4200564], math.floor( meetMinPrice )))
        end

        self:refreshCost(meetMinPrice)
        return
    elseif self.sellPrice > meetMaxPrice then
        if PRICE_MIX >= math.floor( meetMaxPrice ) then
            gf:ShowSmallTips(string.format( CHS[4200565], PRICE_MAX))
        else
            gf:ShowSmallTips(string.format( CHS[4200566], math.floor( meetMaxPrice )))
        end
        self:refreshCost(meetMaxPrice)
        return
    end


    TradingMgr:cmdChangePriceGoods(self.goodsData.goods_gid, self.sellPrice)
end

function JuBaoCashOperateDlg:onCloseButton(sender, eventType)
    TradingMgr:cleanAutoLoginInfo()
    DlgMgr:closeDlg(self.name)
end

function JuBaoCashOperateDlg:MSG_TRADING_OPER_RESULT(data)
    -- 完成一次寄售操作，刷新金钱寄售信息
    gf:CmdToServer("CMD_TRADING_SELL_CASH", {goods_gid = self.goodsData.goods_gid})
    self:onCloseButton()
end

function JuBaoCashOperateDlg:MSG_FUZZY_IDENTITY(data)
    if TradingMgr:getCheckBindFlag() then
        self:onResellButton()
        TradingMgr:setCheckBindFlag(false)
    end
end

return JuBaoCashOperateDlg
