-- JuBaoEquipSellDlg.lua
-- Created by songcw Feb/21/2017
-- 聚宝斋，寄售装备界面

local JuBaoEquipSellDlg = Singleton("JuBaoEquipSellDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local CHECKBOX = {
    "CommonSellButton",
    "DesignatedSellButton",
    "VendueSellButton",
}

local DISPLAY_MAP = {
    ["CommonSellButton"] = {"CommonSellPanel", "ModifyPriceTimeLabel", "SellButton"},
    ["DesignatedSellButton"] = {"DesignatedSellPanel", "NoteButton", "SellButton"},
    ["VendueSellButton"] = {"VenduePanel", "NoteButton", "VendueButton"},
}

local COLUMN = 4

local COLUMN_MAGIN = 20

local LINE_MAGIN = 6

local START_MAGIN = 6

local PRICE_MIN = 10            -- 最低价格
local PRICE_MAX = 200000        -- 最高


local EQUIP_PANEL = {
    "ArtifactInfoPanel", "EquipmentInfoPanel", "JewelryInfoPanel"
}

function JuBaoEquipSellDlg:init()
    self:bindListener("SellButton", self.onSellButton)
    self:bindListener("VendueButton", self.onVendueButton)
    self:bindListener("DesignatedButton", self.onDesignatedButton)
    self:bindListener("ValuePanel", self.onDesignatedButton, "DesignatedNamePanel")
    self:setCtrlVisible("ForbidEditImage", false, "DesignatedSellPanel")
    self:bindListener("NoteButton", self.onNoteButton)
    self:bindListener("NoteButton", self.onNoteButton1, "DesignatedSellPanel")

    -- 初始化单个克隆空间
    self.unitEquipPanel = self:toCloneCtrl("UnitItemPanel")
    self.selectImage = self:toCloneCtrl("ChosenEffectImage", self.unitEquipPanel)

    self:setCtrlVisible("SlipButton", false, "EquipmentInfoPanel")

    for _, pName in pairs(EQUIP_PANEL) do
        self:setCtrlVisible(pName, false)
    end

    self.selectEquip = nil
    -- 默认最低
    self.price = nil
    self.priceDesignated = nil
    self.priceVendue = nil

    TradingMgr:setCheckBindFlag(false)

    self:setDisplayByCtrlName(CHECKBOX[1])
    self:initCheckBox()

    -- 设置装备
    self:setEquipsList()

    -- 价格输入
    self:bindSellNumInput()

    -- 初始化价格
    self.priceDesignated = nil
    self.designatedChar = nil
    self.price = nil

    -- 默认最低
    self:refreshCost()
    self:refreshVendueCost()

    self:hookMsg('MSG_TRADING_OPER_RESULT')
    self:hookMsg("MSG_FUZZY_IDENTITY")
end

-- 单选框初始化
function JuBaoEquipSellDlg:initCheckBox()

    self.group = RadioGroup.new()
    self.group:setItemsByButton(self, CHECKBOX, self.onCheckBox)
end

function JuBaoEquipSellDlg:onCheckBox(sender, eventType, isInit)
    self:setDisplayByCtrlName(sender:getName())
end

-- 指定交易和正常交易显示
function JuBaoEquipSellDlg:setDisplayByCtrlName(ctrlName)
    for _, panelName in pairs(DISPLAY_MAP) do
        for i, pName in pairs(panelName) do
            self:setCtrlVisible(pName, false)
        end
    end
    --

    for i, pName in pairs(DISPLAY_MAP[ctrlName]) do
        self:setCtrlVisible(pName, true)
    end

    self.display = ctrlName
end

function JuBaoEquipSellDlg:cleanup()
    self:releaseCloneCtrl("unitEquipPanel")

    self:releaseCloneCtrl("selectImage")
end

-- 设置数字键盘输入
function JuBaoEquipSellDlg:bindSellNumInput()
    local moneyPanel = self:getControl('ValuePanel', nil, "PricePanel")
    local function openNumIuputDlg()
        local rect = self:getBoundingBoxInWorldSpace(moneyPanel)
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setObj(self)
        dlg:setKey("normal")
    --    dlg.root:setPosition(rect.x + rect.width /2 , rect.y  + rect.height +  dlg.root:getContentSize().height /2 + 10)
        dlg.root:setPosition((rect.x + rect.width / 2), rect.y - dlg.root:getContentSize().height / 2 - 10)
        dlg:setCtrlVisible("UpImage", false)
        dlg:setCtrlVisible("DownImage", true)
        self.inputNum = 0
        --   self:setCtrlVisible("Label", false, moneyPanel)
    end
    self:bindTouchEndEventListener(moneyPanel, openNumIuputDlg)

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
        --   self:setCtrlVisible("Label", false, moneyPanel)
    end
    self:bindTouchEndEventListener(moneyPanel, openNumIuputDlg)
    local venduePanel = self:getControl('VenduePanel')
    local touchPanel = self:getControl('UpSetPricePanel', nil, venduePanel)
    local moneyPanel = self:getControl('ValuePanel', nil, touchPanel)
    local function openNumIuputDlg()

        local rect = self:getBoundingBoxInWorldSpace(moneyPanel)
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setObj(self)
        dlg:setKey("vendue")
        dlg.root:setPosition((rect.x + rect.width / 2), rect.y - dlg.root:getContentSize().height / 2 - 10)
        dlg:setCtrlVisible("UpImage", false)
        dlg:setCtrlVisible("DownImage", true)

        self.inputNumVendue = 0
        --   self:setCtrlVisible("Label", false, moneyPanel)
    end
    self:bindTouchEndEventListener(moneyPanel, openNumIuputDlg)
end

function JuBaoEquipSellDlg:refreshDesignatedCost(price)
    local mainPanel = self:getControl("DesignatedSellPanel")
    -- 设置消耗手续费
    local cashText2,fonColor2 = gf:getArtFontMoneyDesc(TradingMgr:getCostCash(self.selectEquip))
    --[[
    if self.state ~= SELL_STATE.TO_SELL then
    cashText2,fonColor2 = gf:getArtFontMoneyDesc(0)
    end
    --]]
    local taxPanel = self:getControl("TaxPanel", nil, mainPanel)
    local costPanel = self:getControl("ValuePanel", nil, taxPanel)
    self:setNumImgForPanel(costPanel, fonColor2, cashText2, false, LOCATE_POSITION.MID, 19)

    self.priceDesignated = price
    if not price then return end
    -- 一口价
    local cashText = gf:getArtFontMoneyDesc(TradingMgr:getYKJ(price, true))
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
    --]]

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
end

-- 数字键盘删除数字
function JuBaoEquipSellDlg:deleteNumber(key)
    if key == "normal" then
        self.inputNum = math.floor(self.inputNum / 10)
        self:refreshCost(self.inputNum )
    elseif key == "designated" then
        self.inputNumDesignated = math.floor(self.inputNumDesignated / 10)
        self:refreshDesignatedCost(self.inputNumDesignated)
    else
        self.inputNumVendue = math.floor(self.inputNumVendue / 10)
        self:refreshVendueCost(self.inputNumVendue)
    end
end

-- 数字键盘清空
function JuBaoEquipSellDlg:deleteAllNumber(key)
    if key == "normal" then
        self.inputNum = 0
        self:refreshCost(self.inputNum)
    elseif key == "designated" then
        self.inputNumDesignated = 0
        self:refreshDesignatedCost(self.inputNumDesignated)
    else
        self.inputNumVendue = 0
        self:refreshVendueCost(self.inputNumVendue)
    end
end

-- 数字键盘插入数字
function JuBaoEquipSellDlg:insertNumber(num, key)
    if key == "normal" then
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

        self:refreshCost(self.inputNum)
    elseif key == "designated" then
        if num == "00" then
            self.inputNumDesignated = self.inputNumDesignated * 100
        elseif num == "0000" then
            self.inputNumDesignated = self.inputNumDesignated * 10000
        else
            self.inputNumDesignated = self.inputNumDesignated * 10 + num
        end

        if self.inputNumDesignated >= PRICE_MAX then
            self.inputNumDesignated = PRICE_MAX
            gf:ShowSmallTips(CHS[3003069])
        end

        self:refreshDesignatedCost(self.inputNumDesignated)
    else
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
        self:refreshVendueCost(self.inputNumVendue)
    end
end

-- 设置、刷新价格相关
function JuBaoEquipSellDlg:refreshCost(price)
    -- 设置消耗手续费
    local cashText2,fonColor2 = gf:getArtFontMoneyDesc(TradingMgr:getCostCash(self.selectEquip))
    local costPanel = self:getControl("ValuePanel", nil, "TaxPanel")
    self:setNumImgForPanel("ValuePanel", fonColor2, cashText2, false, LOCATE_POSITION.MID, 19, costPanel)

    self.price = price
    if not price then return end

    local cashText = gf:getArtFontMoneyDesc(price)
    local pricePanel = self:getControl("ValuePanel", nil, "PricePanel")
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText, false, LOCATE_POSITION.MID, 21, pricePanel)

    -- 实际获得
    local income = TradingMgr:getRealIncome(price)
    local cashText3 = gf:getArtFontMoneyDescByPoint(income, 2)
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText3, false, LOCATE_POSITION.MID, 17, "IncomePanel")
    self:setCtrlVisible("NoteImage", income <= 0, "IncomePanel")
end

-- 设置、刷新价格相关
function JuBaoEquipSellDlg:refreshVendueCost(price)
    -- 设置消耗手续费
    local cashText2,fonColor2 = gf:getArtFontMoneyDesc(TradingMgr:getCostCash(self.selectEquip))

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

function JuBaoEquipSellDlg:setEquipsList()
    local equips = self:getEquips()
    self:setCtrlVisible("NoticePanel", not next(equips))
    self:setCtrlVisible("MainBKImage", next(equips) and true)

    local scrollView = self:getControl("ScrollView")
    self:initScrollViewPanel(equips, self.unitEquipPanel, self.setUnitEquip, scrollView, COLUMN, LINE_MAGIN, COLUMN_MAGIN, START_MAGIN, START_MAGIN)
end

-- 获取装备
function JuBaoEquipSellDlg:getEquips()
    local bagItems = InventoryMgr:getAllExistItem()
    local retEquip = {}
    for pos, item in pairs(bagItems) do
        -- 过滤非装备、未鉴定装备、限时道具
        if (item.item_type == ITEM_TYPE.EQUIPMENT or item.item_type == ITEM_TYPE.ARTIFACT)
        and (not item.unidentified or item.unidentified == 0)
        and not InventoryMgr:isTimeLimitedItem(item)
        and not InventoryMgr:isLimitedItemForever(item) then

            -- 装备中，时装要排除
            if item.item_type == ITEM_TYPE.EQUIPMENT and (item.equip_type == EQUIP_TYPE.FASHION_SUIT or item.equip_type == EQUIP_TYPE.FASHION_JEWELRY) then
            else
                table.insert(retEquip, item)
            end
        end
    end

    return retEquip
end

function JuBaoEquipSellDlg:setUnitEquip(cell, data)
    local iconPath = ResMgr:getItemIconPath(data.icon)
    self:setImage("IconImage", iconPath, cell)

    local imageCtrl = self:getControl("IconImage", nil, cell)

    -- 限制交易道具置灰
    if InventoryMgr:isLimitedItem(data) then
        InventoryMgr:addLogoBinding(imageCtrl)
        gf:grayImageView(imageCtrl)
    end

    if data.item_type == ITEM_TYPE.EQUIPMENT and data.req_level and data.req_level > 0 then
        self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.req_level, false, LOCATE_POSITION.LEFT_TOP, 21, cell)
    end

    if data.item_type == ITEM_TYPE.ARTIFACT and data.level then
        self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21, cell)
    end

    -- 法宝相性
    if data.item_type == ITEM_TYPE.ARTIFACT and data.item_polar then
        InventoryMgr:addArtifactPolarImage(imageCtrl, data.item_polar)
    end

    cell.data = data

    if not self.selectEquip then
        self:onSelectEquip(cell)
    end

    self:bindTouchEndEventListener(cell, function(self, sender, eventType)
        self:onSelectEquip(sender)
    end)
end

function JuBaoEquipSellDlg:queryBindNotAnswer()
    if not TradingMgr:getCheckBindFlag() then return end
    gf:ShowSmallTips(CHS[4300198])
    TradingMgr:setCheckBindFlag(false)
end

function JuBaoEquipSellDlg:addSelectImage(sender, selectTeg)
    self.selectImage:removeFromParent()
    sender:addChild(self.selectImage)
end

function JuBaoEquipSellDlg:onSelectEquip(sender, eventType)
    self:addSelectImage(sender)
    self.selectEquip = sender.data
    self:onRightInfo(self.selectEquip)
end

function JuBaoEquipSellDlg:onRightInfo(data)
    self:refreshCost(self.price)
    self:refreshDesignatedCost(self.priceDesignated)
    self:refreshVendueCost(self.priceVendue)

    self:setCtrlVisible("ArtifactInfoPanel", false)
    self:setCtrlVisible("EquipmentInfoPanel", false)
    self:setCtrlVisible("JewelryInfoPanel", false)

    if data.item_type == ITEM_TYPE.EQUIPMENT then
        if EquipmentMgr:isJewelry(data) then
            -- 首饰
            self:setCtrlVisible("JewelryInfoPanel", true)
            EquipmentMgr:setJewelryForJubao(self, data)
        else
            -- 装备
            self:setCtrlVisible("EquipmentInfoPanel", true)
            EquipmentMgr:setEquipForJubao(self, data)
        end
    elseif data.item_type == ITEM_TYPE.ARTIFACT then
        -- 法宝
        self:setCtrlVisible("ArtifactInfoPanel", true)
        EquipmentMgr:setArtifactForJubao(self, data)
    end
end

function JuBaoEquipSellDlg:setJewelryPanel(equip)

end


function JuBaoEquipSellDlg:onVendueButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if not self.selectEquip then return end
    local equip = self.selectEquip
    local price = self.priceVendue
    local sale_type = TradingMgr:getEquipSaleType(equip)
    gf:confirm(CHS[4100401], function ()
            self.curTradeType = CHECKBOX[3] -- 记录本次操作类型

            -- 第二个参数类型实际为 Const.lua 中 JUBAO_SELL_TYPE
            TradingMgr:cmdSellGoods(price, sale_type, equip.pos, nil, nil, TRADE_SBT.AUCTION)
    end)
end


function JuBaoEquipSellDlg:onSellButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if not self.selectEquip then return end

    local equip = self.selectEquip
    local price = self.price
    if self:getCtrlVisible("DesignatedSellPanel") then
        price = self.priceDesignated
    end
    local sale_type = TradingMgr:getEquipSaleType(equip)
    gf:confirm(CHS[4100401], function ()

        if self:getCtrlVisible("DesignatedSellPanel") then
            -- 指定交易
            if not self.designatedChar then
                gf:ShowSmallTips(CHS[4100973])
                return
            end
            self.curTradeType = CHECKBOX[2] -- 记录本次操作类型
            TradingMgr:cmdSellGoods(price, sale_type, equip.pos, self.designatedChar.gid)
        else
            self.curTradeType = CHECKBOX[1] -- 记录本次操作类型

            -- 第二个参数类型实际为 Const.lua 中 JUBAO_SELL_TYPE
            TradingMgr:cmdSellGoods(price, sale_type, equip.pos)
        end
    end)
end

function JuBaoEquipSellDlg:MSG_TRADING_OPER_RESULT(data)
    -- 完成一次寄售操作
    self:onCloseButton()
end

function JuBaoEquipSellDlg:MSG_FUZZY_IDENTITY(data)

    if TradingMgr:getCheckBindFlag() then
        if CHECKBOX[1] == self.curTradeType then
            if self.price and self.selectEquip then
                TradingMgr:cmdSellGoods(self.price, TradingMgr:getEquipSaleType(self.selectEquip), self.selectEquip.pos)
            end
        elseif CHECKBOX[2] == self.curTradeType then
            if self.priceDesignated and self.selectEquip and self.designatedChar then
                TradingMgr:cmdSellGoods(self.priceDesignated, TradingMgr:getEquipSaleType(self.selectEquip), self.selectEquip.pos, self.designatedChar.gid)
            end
        elseif CHECKBOX[3] == self.curTradeType then
            if self.priceVendue and self.selectEquip then
                TradingMgr:cmdSellGoods(self.priceVendue, TradingMgr:getEquipSaleType(self.selectEquip), self.selectEquip.pos, nil, nil, TRADE_SBT.AUCTION)
            end
        end

        TradingMgr:setCheckBindFlag(false)
    end
end

-- 选择好指定交易对象后的回调
function JuBaoEquipSellDlg:setDesignatedChar(char)
    self:setLabelText("DefaultLabel", char.name)
    self.designatedChar = char
end

function JuBaoEquipSellDlg:onDesignatedButton(sender, eventType)
    DlgMgr:openDlg("DesignatedUserDlg")
end

function JuBaoEquipSellDlg:onNoteButton(sender, eventType)
    if CHECKBOX[3] == self.display then
        local str1 = CHS[4010044]
        local str2 = CHS[4010045]
        local str3 = CHS[4010046]
        local str4 = CHS[4010047]
        local str5 = CHS[4010048]
        local str6 = CHS[4010049]
        local str7 = CHS[4010050]
        local str = str1 .. "\n" .. str2 .. "\n" .. str3 .. "\n" .. str4 .. "\n" .. str5 .. "\n" .. str6 .. "\n" .. str7
        gf:showTipInfo(str, sender)
        return
    end


    local str = CHS[4100983]
    gf:showTipInfo(str, sender)
end

function JuBaoEquipSellDlg:onNoteButton1(sender, eventType)
    local str = CHS[2100213]
    gf:showTipInfo(str, sender)
end


return JuBaoEquipSellDlg
