-- JuBaoCashSellDlg.lua
-- Created by lixh2 Sep/27/2017
-- 聚宝斋金钱上架界面

local JuBaoCashSellDlg = Singleton("JuBaoCashSellDlg", Dialog)

local CASH_MIN = 50000000          -- 出售金钱数量下限
local CASH_MAX = 2000000000        -- 出售金钱数量上限

local PRICE_MIN = 50      -- 寄售价格下限
local PRICE_MAX = 500     -- 寄售价格上限

local GONGSHI_TIME = 1    -- 公示期1天
local SELL_TIME = 3       -- 寄售期3天

local LEFT_PANEL_NUMBER = 5  -- 左边正在寄售的金钱列表个数

function JuBaoCashSellDlg:init()
    self:bindListener("SellButton", self.onSellButton)

    -- 初始显示莲花姑娘，隐藏左侧价格参考列表，在收到MSG_TRADING_SELL_CASH后再显示左侧价格参考列表
    self:setCtrlVisible("OtherCashPanel", false, "PriceComparePanel")
    self:setCtrlVisible("NoticePanel", true, "PriceComparePanel")
    self:setRightPanel()

    self.sellCount = nil
    self.sellPrice = nil

    TradingMgr:setCheckBindFlag(false)

        -- 数字输入
    self:bindSellNumInput()

    -- 请求当日标准价
    gf:CmdToServer("CMD_TRADING_SELL_CASH", {goods_gid = ""})

    self:hookMsg('MSG_TRADING_OPER_RESULT')
    self:hookMsg("MSG_FUZZY_IDENTITY")
    self:hookMsg("MSG_TRADING_SELL_CASH")
end

function JuBaoCashSellDlg:setLeftPanel()
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
        self:setNumImgForPanel("CashPanel", fontColor, cashText, false, LOCATE_POSITION.LEFT_TOP, 17, panel)

        -- 单价
        local moneyStr, fontColor = gf:getMoneyDesc(math.floor(tonumber(saleData[i].goods_name) / tonumber(saleData[i].price)), true)
        self:setLabelText("PerValueLabel", moneyStr, panel, fontColor)
        self:setLabelText("PerValueLabel2", moneyStr, panel)
    end

    for i = #saleData + 1, LEFT_PANEL_NUMBER do
        self:setCtrlVisible("ItemCell_" .. i, false, "OtherCashPanel")
    end
end

function JuBaoCashSellDlg:setRightPanel()
    -- 拥有金钱
    self.ownCash = Me:queryBasicInt('cash')
    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(self.ownCash))
    self:setNumImgForPanel("ValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 17, "OwnCashPanel")

    -- 公示期
    self:setLabelText("PublicLabel_2", string.format(CHS[7190095], tostring(GONGSHI_TIME)), "LeftTimePanel")

    -- 寄售期
    self:setLabelText("SaleLabel_2", string.format(CHS[7190095], tostring(SELL_TIME)), "LeftTimePanel")
end

-- 设置数字键盘输入
function JuBaoCashSellDlg:bindSellNumInput()
    local sellValuePanel = self:getControl("ValuePanel", nil, "SellCashPanel")
    self:bindTouchEndEventListener(sellValuePanel, function()
        local rect = self:getBoundingBoxInWorldSpace(sellValuePanel)
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setKey("sellValuePanel")
        dlg:setObj(self)
        dlg.root:setPosition((rect.x + rect.width / 2), rect.y - dlg.root:getContentSize().height / 2 - 10)
        dlg:setCtrlVisible("UpImage", false)
        dlg:setCtrlVisible("DownImage", true)

        self.inputNum = nil
    end)

    local priceValuePanel = self:getControl("ValuePanel", nil, "PricePanel")
    self:bindTouchEndEventListener(priceValuePanel, function()
        local rect = self:getBoundingBoxInWorldSpace(priceValuePanel)
        if not self.sellCount or self.sellCount and self.sellCount <= 0 then
            gf:ShowSmallTips(CHS[7120015])
            return
        end

        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setKey("priceValuePanel")
        dlg:setObj(self)
        dlg.root:setPosition((rect.x + rect.width / 2), rect.y - dlg.root:getContentSize().height / 2 - 10)
        dlg:setCtrlVisible("UpImage", false)
        dlg:setCtrlVisible("DownImage", true)

        self.inputNum = nil
    end)
end

-- 数字键盘删除数字
function JuBaoCashSellDlg:deleteNumber(key)
    if self.inputNum == nil then
        self.inputNum = 0
    end

    self.inputNum = math.floor(self.inputNum / 10)
    self:showInsertNumber(key)
end

-- 数字键盘清空
function JuBaoCashSellDlg:deleteAllNumber(key)
    self.inputNum = 0
    self:showInsertNumber(key)
end

-- 数字界面关闭时
function JuBaoCashSellDlg:closeNumInputDlg(key)
    if key == "sellValuePanel" then
        if self.inputNum then
            self.sellCount = self.inputNum
            self:refreshCost(self.sellCount, key)
        end
    else
        if self.inputNum then
            self.sellPrice = self.inputNum
            self:refreshCost(self.sellPrice, key)
        end
    end

    self.inputNum = 0
end

-- 数字键盘插入数字
function JuBaoCashSellDlg:insertNumber(num, key)
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

    if key == "sellValuePanel" then
        if self.inputNum >= CASH_MAX then
            self.inputNum = CASH_MAX
            gf:ShowSmallTips(CHS[3002954])
        end
    else
        if self.inputNum >= PRICE_MAX then
            self.inputNum = PRICE_MAX
            gf:ShowSmallTips(CHS[3002954])
        end
    end

    -- 输入直接显示，在数字键盘关闭时refreshCost
    self:showInsertNumber(key)
end

-- 数字键盘数字改变后，界面直接显示
function JuBaoCashSellDlg:showInsertNumber(key)
    if key == "sellValuePanel" then
        local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(self.inputNum))
        self:setNumImgForPanel("ValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 17, "SellCashPanel")
    elseif key == "priceValuePanel" then
        local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(self.inputNum))
        self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText, false, LOCATE_POSITION.MID, 21, "PricePanel")
    end
end

-- 输入金钱数量不满足条件时，清空下方Panel
function JuBaoCashSellDlg:cleanLeftPanel()
    self:setCtrlVisible("GuidePricePanel", false, "MainBodyPanel")
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "", false, LOCATE_POSITION.MID, 17, "SellCashPanel")
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "", false, LOCATE_POSITION.MID, 17, "PricePanel")
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "", false, LOCATE_POSITION.MID, 17, "IncomePanel")
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "", false, LOCATE_POSITION.MID, 17, "PerValuePanel")
end

-- 设置、刷新价格相关
function JuBaoCashSellDlg:refreshCost(price, key)
    if not self.sellCount or self.sellCount == 0 then
        -- 未设置出售金钱数量时，指导售价，单价，实际收入都为空
        self:cleanLeftPanel()
        return
    end

    local sellPriceMax = self:getSellPriceMax()
    local sellPriceMin = self:getSellPriceMin()

    if key == "sellValuePanel" then
        if self.ownCash < CASH_MIN then
            -- 自身携带金钱小于要求下限
            gf:ShowSmallTips(string.format(CHS[7120014], gf:getMoneyDesc(CASH_MIN)))
            self.inputNum = 0
            self.sellCount = 0
            self:cleanLeftPanel()
            return
        else
            if self.sellCount < CASH_MIN then
                -- 当前输入数量小于 要求下限
                gf:ShowSmallTips(string.format(CHS[7190094], gf:getMoneyDesc(CASH_MIN)))
                self.inputNum = 0
                self.sellCount = 0
                self:cleanLeftPanel()
                return
            elseif self.ownCash < self.sellCount and self.sellCount <= CASH_MAX then
                -- 携带金钱数量不足，但满足出售条件，进行校正
                gf:ShowSmallTips(string.format(CHS[7190089], gf:getMoneyDesc(self.ownCash)))
                self.sellCount = self.ownCash

                -- 修改当前金钱出售数量后，当前指导价需要重新计算
                sellPriceMax = self:getSellPriceMax()
                sellPriceMin = self:getSellPriceMin()
            elseif self.sellCount > CASH_MAX then
                -- 当前输入数量大于 要求上限
                gf:ShowSmallTips(string.format(CHS[7190097], gf:getMoneyDesc(CASH_MAX)))
                self.inputNum = 0
                self.sellCount = 0
                self:cleanLeftPanel()
                return
            end
        end

        -- 每次重新输入金钱数量后，价格需要清空，默认使用指导价格
        self.sellPrice = nil
    elseif key == "priceValuePanel" then
        self.sellPrice = self.inputNum
    end

    -- 寄售总价价格:默认使用指导价格
    if not self.sellPrice then
        self.sellPrice = math.floor(self.sellCount / TradingMgr:getCashStandardPrice())
    end

    -- 寄售总价格调整(只修改出售金钱数量的情况)
    if self.sellPrice < sellPriceMin then
        self.sellPrice = sellPriceMin
        gf:ShowSmallTips(string.format(CHS[7190090], sellPriceMin))
    elseif self.sellPrice > sellPriceMax then
        self.sellPrice = sellPriceMax
        gf:ShowSmallTips(string.format(CHS[7190091], sellPriceMax))
    end

    local cashText
    local fontColor

    -- 出售金钱
    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(self.sellCount))
    self:setNumImgForPanel("ValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 17, "SellCashPanel")

    -- 寄售价格
    local cashText = gf:getArtFontMoneyDesc(tonumber(self.sellPrice))
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText, false, LOCATE_POSITION.MID, 21, "PricePanel")

    -- 指导售价下限,上限
    self:setCtrlVisible("GuidePricePanel", true, "MainBodyPanel")
    self:setLabelText("MinPriceLabel", sellPriceMin .. CHS[7190093], "GuidePricePanel")
    self:setLabelText("MaxPriceLabel", sellPriceMax .. CHS[7190093], "GuidePricePanel")

    -- 实际收入
    local income = TradingMgr:getRealIncome(self.sellPrice, false, true)
    cashText = gf:getArtFontMoneyDescByPoint(income, 2)
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText, false, LOCATE_POSITION.MID, 17, "IncomePanel")
    self:setCtrlVisible("NoteImage", income <= 0, "IncomePanel")

    -- 单价
    local perPrice = math.floor(self.sellCount / self.sellPrice)
    cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(perPrice))
    self:setNumImgForPanel("ValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 19, "PerValuePanel")
end

-- 获取当前订单售价指导上限
function JuBaoCashSellDlg:getSellPriceMax()
    -- TradingMgr 中的获取 当日金钱指导价格
    local guidePrice = TradingMgr:getCashStandardPrice()
    local guidePriceMax = math.floor(self.sellCount / math.ceil(guidePrice * 0.8))
    local guidePriceMin = math.ceil(self.sellCount / math.ceil(guidePrice * 1.2))
    return math.max(guidePriceMin, guidePriceMax)
end

-- 获取当前订单售价指导下限
function JuBaoCashSellDlg:getSellPriceMin()
    -- TradingMgr 中的获取 当日金钱指导价格
    local guidePrice = TradingMgr:getCashStandardPrice()
    local guidePriceMax = math.floor(self.sellCount / math.ceil(guidePrice * 0.8))
    local guidePriceMin = math.ceil(self.sellCount / math.ceil(guidePrice * 1.2))
    return math.min(guidePriceMin, guidePriceMax)
end

function JuBaoCashSellDlg:queryBindNotAnswer()
    if not TradingMgr:getCheckBindFlag() then return end
    gf:ShowSmallTips(CHS[4300198])
    TradingMgr:setCheckBindFlag(false)
end

function JuBaoCashSellDlg:onSellButton(sender, eventType)
    if not TradingMgr:getIsCanSellCash() then
        gf:ShowSmallTips(string.format(CHS[7190096], TradingMgr:getSellCashAfterDays()))
        return
    end

    gf:confirm(CHS[4100401], function ()

        TradingMgr:cmdSellGoods(self.sellPrice, JUBAO_SELL_TYPE.SALE_TYPE_CASH, self.sellCount)
    end)

end

function JuBaoCashSellDlg:MSG_TRADING_SELL_CASH()
    self:setLeftPanel()
end

function JuBaoCashSellDlg:MSG_TRADING_OPER_RESULT(data)
    -- 完成一次寄售操作
    self:onCloseButton()
end

function JuBaoCashSellDlg:MSG_FUZZY_IDENTITY(data)
    if TradingMgr:getCheckBindFlag() then
        if self.sellPrice and self.sellCount then
            TradingMgr:cmdSellGoods(self.sellPrice, JUBAO_SELL_TYPE.SALE_TYPE_CASH, self.sellCount)
        end
        TradingMgr:setCheckBindFlag(false)
    end
end

return JuBaoCashSellDlg
