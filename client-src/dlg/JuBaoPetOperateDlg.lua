-- JuBaoPetOperateDlg.lua
-- Created by songcw Jan/04/2017
-- 聚宝斋宠物操作界面

local JuBaoPetOperateDlg = Singleton("JuBaoPetOperateDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local CHECKBOX = {
    "CommonSellButton",
    "DesignatedSellButton",
    "VendueSellButton",
}

local SBT_TO_CHECK = {

    ["CommonSellButton"] = TRADE_SBT.NONE,
    ["DesignatedSellButton"] = TRADE_SBT.APPOINT_SELL,
    ["VendueSellButton"] = TRADE_SBT.AUCTION,
}


local DISPLAY_MAP = {
    ["CommonSellButton"] = {"CommonSellPanel"},
    ["DesignatedSellButton"] = {"DesignatedSellPanel"},
        ["VendueSellButton"] = {"VenduePanel"},
}

-- 宠物属性、成长、技能checkBox
local DISPLAY_CHECKBOX = {
    "PetBasicInfoCheckBox",
    "PetAttribInfoCheckBox",
    "PetSkillInfoCheckBox",
}

-- 宠物属性、成长、技能checkBox 对应显示的panel
local CHECKBOX_PANEL = {
    ["PetBasicInfoCheckBox"] = "PetBasicInfoPanel",
    ["PetAttribInfoCheckBox"] = "PetAttribInfoPanel",
    ["PetSkillInfoCheckBox"] = "PetSkillInfoPanel",
}

local PRICE_MIN = 10            -- 最低价格
local PRICE_MAX = 200000        -- 最高

function JuBaoPetOperateDlg:init()
    self:bindListener("ResellButton", self.onResellButton)
    self:bindListener("TakeBackButton", self.onTakeBackButton)
    self:bindListener("ModifyPriceButton", self.onModifyPriceButton)
    self:setCtrlEnabled("DesignatedButton", false)
    self:bindListener("NoteButton", self.onNoteButton1, "DesignatedSellPanel")

    -- 初始化3个ScrollView
    for _, panelName in pairs(CHECKBOX_PANEL) do
        local scollCtrl = self:getControl("ScrollView", nil, panelName)
        local container = self:getControl("InfoPanel", nil, scollCtrl)
        scollCtrl:setInnerContainerSize(container:getContentSize())

        container:requestDoLayout()
        scollCtrl:setInnerContainerSize(container:getContentSize())
        scollCtrl:requestDoLayout()
    end

    self.goodsData = nil
    self.price = nil

    -- 单选框初始化
    self:initCheckBox()

    -- 价格修改按钮默认置灰
    self:setCtrlEnabled("ModifyPriceButton", false)

    TradingMgr:setCheckBindFlag(false)

    -- 价格输入
    self:bindSellNumInput()

    self:hookMsg('MSG_TRADING_OPER_RESULT')
    self:hookMsg("MSG_FUZZY_IDENTITY")
end

function JuBaoPetOperateDlg:setTimeInfo(goodsData)
    local state = goodsData.state
    if state == TRADING_STATE.SHOW then
        self:setLabelText("PublicLabel_2", TradingMgr:getLeftTime(goodsData.end_time - gf:getServerTime()), "CommonSellPanel")
        self:setLabelText("SaleLabel_2", CHS[4300145], "CommonSellPanel")

        self:setLabelText("PublicLabel_2", TradingMgr:getLeftTime(goodsData.end_time - gf:getServerTime()), "DesignatedSellPanel")
        self:setLabelText("SaleLabel_2", CHS[4100985], "DesignatedSellPanel")

        self:setLabelText("PublicLabel_2", TradingMgr:getLeftTime(goodsData.end_time - gf:getServerTime()), "VenduePanel")
        self:setLabelText("SaleLabel_2", string.format("%d", 3), "VenduePanel")
    elseif state == TRADING_STATE.SALE then
        self:setLabelText("PublicLabel_2", CHS[4300146], "CommonSellPanel")
        self:setLabelText("SaleLabel_2", TradingMgr:getLeftTime(goodsData.end_time - gf:getServerTime()), "CommonSellPanel")

        self:setLabelText("PublicLabel_2", CHS[4300146], "DesignatedSellPanel")
        self:setLabelText("SaleLabel_2", TradingMgr:getLeftTime(goodsData.end_time - gf:getServerTime()), "DesignatedSellPanel")

        self:setLabelText("PublicLabel_2", CHS[4300146], "VenduePanel")
        self:setLabelText("SaleLabel_2", TradingMgr:getLeftTime(goodsData.end_time - gf:getServerTime()), "VenduePanel")
    elseif state == TRADING_STATE.TIMEOUT then
        self:setLabelText("PublicLabel_2", CHS[4300146], "CommonSellPanel")
        self:setLabelText("SaleLabel_2", CHS[4300145], "CommonSellPanel")

        self:setLabelText("PublicLabel_2", CHS[4300146], "DesignatedSellPanel")
        self:setLabelText("SaleLabel_2", CHS[4100985], "DesignatedSellPanel")

        self:setLabelText("PublicLabel_2", CHS[4300146], "VenduePanel")
        self:setLabelText("SaleLabel_2", string.format(CHS[4200520], 3), "VenduePanel")
    elseif state == TRADING_STATE.CANCEL or state == TRADING_STATE.FORCE_CLOSED then
        self:setLabelText("PublicLabel_2", CHS[4100986], "CommonSellPanel")
        self:setLabelText("SaleLabel_2", CHS[4300145], "CommonSellPanel")

        self:setLabelText("PublicLabel_2", CHS[4100986], "DesignatedSellPanel")
        self:setLabelText("SaleLabel_2", CHS[4100985], "DesignatedSellPanel")

        self:setLabelText("PublicLabel_2", CHS[4100986], "VenduePanel")
        self:setLabelText("SaleLabel_2", string.format(CHS[4200520], 3), "VenduePanel")
    elseif state == TRADING_STATE.FORCE_CLOSED  then
    elseif state == TRADING_STATE.AUCTION  then
        local panel2 = self:getControl("LeftTimePanel", nil, "VenduePanel")
        self:setLabelText("PublicLabel_1", CHS[4300490], panel2) -- 拍卖寄售期，
        self:setLabelText("PublicLabel_2", string.format(CHS[4200520], 0), panel2)

        self:setLabelText("SaleLabel_1", CHS[4300491], panel2) -- 拍卖寄售期，
        self:setLabelText("SaleLabel_2", TradingMgr:getLeftTime(goodsData.end_time - gf:getServerTime()), panel2)
    elseif state == TRADING_STATE.AUCTION_SHOW  then
        local panel2 = self:getControl("LeftTimePanel", nil, "VenduePanel")
        self:setLabelText("PublicLabel_1", CHS[4300490], panel2) -- 拍卖寄售期，
        self:setLabelText("PublicLabel_2", TradingMgr:getLeftTime(goodsData.end_time - gf:getServerTime()), panel2)

        self:setLabelText("SaleLabel_1", CHS[4300491], panel2) -- 拍卖寄售期，
        self:setLabelText("SaleLabel_2", string.format(CHS[4200520], 3), panel2)
    end
end

-- 设置数字键盘输入
function JuBaoPetOperateDlg:bindSellNumInput()
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

    local designPanel = self:getControl('PricePanel', nil, "DesignatedSellPanel")
    local moneyPanel = self:getControl('ValuePanel', nil, designPanel)
    local function openNumIuputDlg()
        if not self.goodsData then return end
        if self.goodsData.state == TRADING_STATE.TIMEOUT or self.goodsData.state == TRADING_STATE.CANCEL or self.goodsData.state == TRADING_STATE.FORCE_CLOSED then
            return
        end

        if self:isAppointTrading() then
            gf:ShowSmallTips(CHS[4100972])
            return
        end

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

    local designPanel = self:getControl('UpSetPricePanel', nil, "VenduePanel")
    local moneyPanel = self:getControl('ValuePanel', nil, designPanel)
    local function openNumIuputDlg()
        if not self.goodsData then return end
        if self:isAppointTrading() then
            gf:ShowSmallTips(CHS[4100972])
            return
        end

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

-- 是否是指定交易
function JuBaoPetOperateDlg:isAppointTrading()
    if not self.goodsData then return end

    if self.goodsData and next(self.goodsData) then
        if self.goodsData.sell_buy_type == TRADE_SBT.APPOINT_SELL then
            return true
        end
    end

    return false
end


function JuBaoPetOperateDlg:setDisplayByCtrlName(ctrlName)
    for _, panelName in pairs(DISPLAY_MAP) do
        for i, pName in pairs(panelName) do
            self:setCtrlVisible(pName, false)
        end
    end
    --

    for i, pName in pairs(DISPLAY_MAP[ctrlName]) do
        self:setCtrlVisible(pName, true)
    end
end

-- 数字键盘删除数字
function JuBaoPetOperateDlg:deleteNumber(key)
    self:setCtrlEnabled("ModifyPriceButton", true)
    if key == "normal" then
        self:setCtrlEnabled("ModifyPriceButton", true)
        self.inputNum = math.floor(self.inputNum / 10)
        self:refreshCost(self.inputNum, self.goodsData)
    elseif key == "vendue" then
        self.inputNumVendue = math.floor(self.inputNumVendue / 10)
        self:refreshVendueCost(self.inputNumVendue, self.goodsData)
    else
        self.inputNumDesignated = math.floor(self.inputNumDesignated / 10)
        self:refreshDesignatedCost(self.inputNumDesignated)
    end
end

-- 数字键盘清空
function JuBaoPetOperateDlg:deleteAllNumber(key)
    self:setCtrlEnabled("ModifyPriceButton", true)
    if key == "normal" then
        self:setCtrlEnabled("ModifyPriceButton", true)
        self.inputNum = 0
        self:refreshCost(self.inputNum, self.goodsData)
    elseif key == "vendue" then
        self.inputNumVendue = 0
        self:refreshVendueCost(self.inputNumVendue, self.goodsData)
    else
        self.inputNumDesignated = 0
        self:refreshDesignatedCost(self.inputNumDesignated)
    end
end

-- 数字键盘插入数字
function JuBaoPetOperateDlg:insertNumber(num, key)
    self:setCtrlEnabled("ModifyPriceButton", true)
    if key == "normal" then
        self:setCtrlEnabled("ModifyPriceButton", true)
        if num == "00" then
            self.inputNum = self.inputNum * 100
        elseif num == "0000" then
            self.inputNum = self.inputNum * 10000
        else
            self.inputNum = self.inputNum * 10 + num
        end

        if self.inputNum >= PRICE_MAX then
            self.inputNum = PRICE_MAX
            gf:ShowSmallTips(CHS[3003069])
        end

        self:refreshCost(self.inputNum, self.goodsData)
    elseif key == "vendue" then
        if num == "00" then
            self.inputNumVendue = self.inputNumVendue * 100
        elseif num == "0000" then
            self.inputNumVendue = self.inputNumVendue * 10000
        else
            self.inputNumVendue = self.inputNumVendue * 10 + num
        end

        if self.inputNumVendue >= PRICE_MAX then
            self.inputNumVendue = PRICE_MAX
            gf:ShowSmallTips(CHS[3003069])
        end
        self:refreshVendueCost(self.inputNumVendue, self.goodsData)
    else
        if num == "00" then
            self.inputNumDesignated = self.inputNumDesignated * 100
        elseif num == "0000" then
            self.inputNumDesignated = self.inputNumDesignated * 10000
        else
            self.inputNumDesignated = self.inputNumDesignated * 10 + num
        end

        if self.inputNumDesignated >= TradingMgr:getMaxPrice() then
            self.inputNumDesignated = TradingMgr:getMaxPrice()
            gf:ShowSmallTips(CHS[3003069])
        end

        self:refreshDesignatedCost(self.inputNumDesignated)
    end
end


-- 单选框初始化
function JuBaoPetOperateDlg:initCheckBox()
    self.radioCheckBox = RadioGroup.new()
    self.radioCheckBox:setItems(self, DISPLAY_CHECKBOX, self.onPetInfoCheckBox)
    self.radioCheckBox:setSetlctByName(DISPLAY_CHECKBOX[1])

    self.group = RadioGroup.new()
    self.group:setItemsByButton(self, CHECKBOX, self.onCheckBox)
end

function JuBaoPetOperateDlg:onCheckBox(sender, eventType, isInit)
    if not self.goodsData then return end

    if self.goodsData.state == TRADING_STATE.TIMEOUT or self.goodsData.state == TRADING_STATE.CANCEL or self.goodsData.state == TRADING_STATE.FORCE_CLOSED then
        self:setDisplayByCtrlName(sender:getName())
        return
    end

    if not isInit and SBT_TO_CHECK[sender:getName()] ~= self.goodsData.sell_buy_type then
        self:setCheckImage(self.goodsData.sell_buy_type)
        gf:ShowSmallTips(CHS[4100971])
        return
    end
end

-- 设置check选中，起始这个是用button模拟的check
function JuBaoPetOperateDlg:setCheckImage(traType)
    self:setCtrlVisible("CommonSellImage", false)
    self:setCtrlVisible("DesignatedSellImage", false)
    self:setCtrlVisible("VendueSellImage", false)


    if traType == TRADE_SBT.APPOINT_SELL then
        self:setCtrlVisible("DesignatedSellImage", true)
    elseif traType == TRADE_SBT.AUCTION then
        self:setCtrlVisible("VendueSellImage", true)
    else
        self:setCtrlVisible("CommonSellImage", true)
    end
end

-- 点击宠物显示信息的checkBox
function JuBaoPetOperateDlg:onPetInfoCheckBox(sender, eventType)
    for _, panelName in pairs(CHECKBOX_PANEL) do
        self:setCtrlVisible(panelName, false)

        self:setCtrlVisible("ChosenPanel", false, _)
        self:setCtrlVisible("UnChosenPanel", true, _)
    end

    self:setCtrlVisible("ChosenPanel", true, sender)
    self:setCtrlVisible("UnChosenPanel", false, sender)
    self:setCtrlVisible(CHECKBOX_PANEL[sender:getName()], true)
end

function JuBaoPetOperateDlg:setButton(goodsData)
    -- / 10，原因是，寄售公示为 11，起始公示都是
    if math.floor(goodsData.state / 10) == TRADING_STATE.SHOW / 10 or math.floor(goodsData.state / 10) == TRADING_STATE.SALE / 10 then
        self:setCtrlVisible("ResellButton", false)
        self:setCtrlVisible("TakeBackButton", true)
        self:setCtrlVisible("ModifyPriceButton", true)
    else
        self:setCtrlVisible("ModifyPriceButton", false)
        self:setCtrlVisible("ResellButton", true)
        self:setCtrlVisible("TakeBackButton", true)
    end

    self:setCheckImage(goodsData.sell_buy_type)
    if goodsData.sell_buy_type == TRADE_SBT.AUCTION then
        self:setDisplayByCtrlName("VendueSellButton")
    elseif goodsData.sell_buy_type == TRADE_SBT.APPOINT_SELL then
        self:setDisplayByCtrlName("DesignatedSellButton")
    else
        self:setDisplayByCtrlName("CommonSellButton")
    end


    if goodsData.state == TRADING_STATE.TIMEOUT or goodsData.state == TRADING_STATE.CANCEL then
        self:setCtrlEnabled("DesignatedButton", false)
        return
    end
end

-- 设置、刷新价格相关
function JuBaoPetOperateDlg:refreshVendueCost(price)
    -- 设置消耗手续费
    local cashText2,fonColor2 = gf:getArtFontMoneyDesc(TradingMgr:getCostCash(self.pet))

    local venduePanel = self:getControl("VenduePanel")
    local taxPanel = self:getControl("TaxPanel", nil, venduePanel)
    local costPanel = self:getControl("ValuePanel", nil, taxPanel)
    self:setNumImgForPanel("ValuePanel", fonColor2, cashText2, false, LOCATE_POSITION.MID, 19, costPanel)

    self.priceVendue = price
    if not price then return end

    local cashText = gf:getArtFontMoneyDesc(price)
    local panel1 = self:getControl("UpSetPricePanel", nil, venduePanel)
    local pricePanel = self:getControl("ValuePanel", nil, panel1 )
    self:setNumImgForPanel(pricePanel, ART_FONT_COLOR.DEFAULT, "$" .. cashText, false, LOCATE_POSITION.MID, 21)

    -- 实际获得
    local income = TradingMgr:getRealIncomeForVendue(price)
    local cashText3 = gf:getArtFontMoneyDescByPoint(income, 2)
    local panel2 = self:getControl("IncomePanel", nil, venduePanel)
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText3, false, LOCATE_POSITION.MID, 17, panel2)
    self:setCtrlVisible("NoteImage", income <= 0, panel2)
end


function JuBaoPetOperateDlg:refreshDesignatedCost(price, goodsDate)
    local mainPanel = self:getControl("DesignatedSellPanel")
    -- 设置消耗手续费
    -- 设置消耗手续费
    local costNum = 0
    if goodsDate then
        costNum = TradingMgr:getCostCash(self.pet)
    end
    local cashText2,fonColor2 = gf:getArtFontMoneyDesc(costNum)


    local taxPanel = self:getControl("TaxPanel", nil, mainPanel)
    local costPanel = self:getControl("ValuePanel", nil, taxPanel)
    self:setNumImgForPanel(costPanel, fonColor2, cashText2, false, LOCATE_POSITION.MID, 19)

    self.priceDesignated = price
    if not price then return end
    -- 一口价
    local cashText = goodsDate.butout_price
    local panelP = self:getControl("FixedPricePanel", nil, mainPanel)
    local pricePanel = self:getControl("ValuePanel", nil, panelP)
    self:setNumImgForPanel(pricePanel, ART_FONT_COLOR.DEFAULT, "$" .. cashText, false, LOCATE_POSITION.MID, 21)


    -- 实际获得   一口价
    local income = TradingMgr:getRealIncome(TradingMgr:getYKJ(price, true))
    local cashText3 = gf:getArtFontMoneyDescByPoint(income, 2)
    local panelP = self:getControl("IncomePanel_2", nil, mainPanel)
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText3, false, LOCATE_POSITION.MID, 17, panelP)
    self:setCtrlVisible("NoteImage", income <= 0, panelP)


    --
    -- 实际获得   指定
    local income = TradingMgr:getRealIncome(price)
    local cashText3 = gf:getArtFontMoneyDescByPoint(income, 2)
    local panelP = self:getControl("IncomePanel_1", nil, mainPanel)
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText3, false, LOCATE_POSITION.MID, 17, panelP)
    self:setCtrlVisible("NoteImage", income <= 0, panelP)



    -- 买方定金
    local income = TradingMgr:getDeposit(price)
    local cashText3 = gf:getArtFontMoneyDescByPoint(income, 2)
    local panelP = self:getControl("BuyerDepositPanel", nil, mainPanel)
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText3, false, LOCATE_POSITION.MID, 21, panelP)

    -- 价格
    local cashText = gf:getArtFontMoneyDesc(price)
    local panelP = self:getControl("PricePanel", nil, mainPanel)
    local pricePanel = self:getControl("ValuePanel", nil, panelP)
    self:setNumImgForPanel(pricePanel, ART_FONT_COLOR.DEFAULT, "$" .. cashText, false, LOCATE_POSITION.MID, 21)
    --]]
end


function JuBaoPetOperateDlg:setPet(pet, goodsData)
    self.pet = pet

    self.goodsData = goodsData

    self:setButton(goodsData)

    self:setTimeInfo(goodsData)

    self:refreshCost(goodsData.price, goodsData)
    self:refreshDesignatedCost(goodsData.price, goodsData)
    self:refreshVendueCost(goodsData.price, goodsData)

    self:setLabelText("DefaultLabel", goodsData.appointee_name)

    -- 设置宠物形象的
    self:setShapeInfo(pet)

    -- 头像
    self:setImage("GuardImage", ResMgr:getSmallPortrait(pet:queryInt("icon")), "PortraitPanel")
    self:setItemImageSize("GuardImage", "PortraitPanel")

    -- 等级
    local levelPanel = self:getControl("LevelPanel", nil, "PetBasicInfoPanel")
    self:setLabelText("ValueLabel", pet:queryInt("level"), levelPanel)

    -- 姓名
    self:setLabelText("ValueLabel", pet:queryBasic("name"), "NamePanel")

    -- 交易
    local strLimitedTime = gf:converToLimitedTimeDay(pet:query("gift"))
    if not strLimitedTime or strLimitedTime == "" then
        self:setLabelText("ValueLabel", CHS[4200228], "ExChangePanel")
    else
        self:setLabelText("ValueLabel", strLimitedTime, "ExChangePanel")
    end

    -- 武学
    self:setLabelText("ValueLabel", pet:queryInt("martial"), "TaoLevelPanel")

    -- 设置类型：野生、宝宝
    self:setImage("SuffixImage", ResMgr:getPetRankImagePath(pet))

    -- 今日可修改次数
    self:setLabelText("ModifyPriceLabel", string.format(CHS[4100406], goodsData.change_price_count))

    -- 基本信息
    PetMgr:setBasicInfoForCard(pet, self, true)

    -- 宠物资质
    PetMgr:setAttribInfoForCard(pet, self, true)

    -- 宠物技能
    PetMgr:setSkillInfoForCard(pet, self, true)

end

-- 设置宠物形象的
function JuBaoPetOperateDlg:setShapeInfo(pet)
    -- 名字等级
    self:setLabelText("NameLabel_1", string.format(CHS[4000391], pet:queryBasic("name"), pet:queryInt("level")), "NamePanel")
    self:setLabelText("NameLabel_2", string.format(CHS[4000391], pet:queryBasic("name"), pet:queryInt("level")), "NamePanel")

    -- 设置形象
    local icon = pet:queryBasicInt("dye_icon") ~= 0 and pet:queryBasicInt("dye_icon") or pet:queryBasicInt("icon")
    self:setPortrait("PetPanel", icon, 0, "PetBasicInfoPanel", true, nil, nil, cc.p(0, -50))

    -- 宠物logo
    PetMgr:setPetLogo(self, pet)
end

function JuBaoPetOperateDlg:refreshCost(price, goodsDate)
    self.price = price
    local cashText = gf:getArtFontMoneyDesc(price)
    local pricePanel = self:getControl("ValuePanel", nil, "PricePanel")
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText, false, LOCATE_POSITION.MID, 21, pricePanel)

    -- 实际获得
    local income = TradingMgr:getRealIncome(price)
    local cashText3 = gf:getArtFontMoneyDescByPoint(income, 2)
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText3, false, LOCATE_POSITION.MID, 17, "IncomePanel")
    self:setCtrlVisible("NoteImage", income <= 0, "IncomePanel")

    -- 设置消耗手续费
    local costNum = 0
    if goodsDate then
        costNum = TradingMgr:getCostCash(self.pet)
    end
    local cashText2,fonColor2 = gf:getArtFontMoneyDesc(costNum)

    local costPanel = self:getControl("ValuePanel", nil, "TaxPanel")
    self:setNumImgForPanel("ValuePanel", fonColor2, cashText2, false, LOCATE_POSITION.MID, 19, costPanel)

end

function JuBaoPetOperateDlg:queryBindNotAnswer()
    if not TradingMgr:getCheckBindFlag() then return end
    gf:ShowSmallTips(CHS[4300198])
    TradingMgr:setCheckBindFlag(false)
end

function JuBaoPetOperateDlg:onResellButton(sender, eventType)
    if not self.goodsData then return end

    if self:getCtrlVisible("DesignatedSellPanel") then
        -- 指定交易
        gf:ShowSmallTips(CHS[4100984])
    elseif self:getCtrlVisible("CommonSellPanel") then
        TradingMgr:cmdSellGoodsAgain(self.goodsData.goods_gid, self.price)
    elseif self:getCtrlVisible("VenduePanel") then
        TradingMgr:cmdSellGoodsAgain(self.goodsData.goods_gid, self.priceVendue, TRADE_SBT.AUCTION)
    end
end

function JuBaoPetOperateDlg:onTakeBackButton(sender, eventType)
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
    TradingMgr:setAutoLoginInfo(gid, self.name)
    TradingMgr:cmdCancelGoods(gid)
end

function JuBaoPetOperateDlg:onModifyPriceButton(sender, eventType)
    if not self.goodsData then return end

    if self:getCtrlVisible("VenduePanel") then
        local isOk, price, tips = TradingMgr:changePriceCondition(self.priceVendue, self.goodsData, PRICE_MIN)
        if isOk then
            TradingMgr:cmdChangePriceGoods(self.goodsData.goods_gid, self.priceVendue)
        else
            self:refreshVendueCost(price, self.goodsData)
            gf:ShowSmallTips(tips)
        end
    else
        local isOk, price, tips = TradingMgr:changePriceCondition(self.price, self.goodsData, PRICE_MIN)
        if isOk then
            TradingMgr:cmdChangePriceGoods(self.goodsData.goods_gid, self.price)
        else
            self:refreshCost(price, self.goodsData)
            gf:ShowSmallTips(tips)
        end
    end
end

function JuBaoPetOperateDlg:onCloseButton(sender, eventType)
    TradingMgr:cleanAutoLoginInfo()
    DlgMgr:closeDlg(self.name)
end

function JuBaoPetOperateDlg:onNoteButton1(sender, eventType)
    local str = CHS[2100213]
    gf:showTipInfo(str, sender)
end

function JuBaoPetOperateDlg:MSG_TRADING_OPER_RESULT(data)
    -- 完成一次寄售操作
    self:onCloseButton()
end

function JuBaoPetOperateDlg:MSG_FUZZY_IDENTITY(data)
    if TradingMgr:getCheckBindFlag() then
        self:onResellButton()
        TradingMgr:setCheckBindFlag(false)
    end
end

return JuBaoPetOperateDlg
