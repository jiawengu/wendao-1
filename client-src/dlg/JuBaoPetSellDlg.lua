-- JuBaoPetSellDlg.lua
-- Created by songcw Dec/30/2016
-- 聚宝斋寄售宠物

local JuBaoPetSellDlg = Singleton("JuBaoPetSellDlg", Dialog)
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

JuBaoPetSellDlg.isMePet = true

local PRICE_MIN = 10            -- 最低价格
local PRICE_MAX = 200000        -- 最高

function JuBaoPetSellDlg:init()
    self:bindListener("SellButton", self.onSellButton)
    self:bindListener("VendueButton", self.onVendueButton)
    self:bindListener("DesignatedButton", self.onDesignatedButton)
    self:bindListener("ValuePanel", self.onDesignatedButton, "DesignatedNamePanel")
    self:setCtrlVisible("ForbidEditImage", false, "DesignatedSellPanel")
    self:bindListener("NoteButton", self.onNoteButton)
    self:bindListener("NoteButton", self.onNoteButton1, "DesignatedSellPanel")

    -- 克隆项
    self:initRetainPanels()

    -- 初始化3个ScrollView
    for _, panelName in pairs(CHECKBOX_PANEL) do
        local scollCtrl = self:getControl("ScrollView", nil, panelName)
        local container = self:getControl("InfoPanel", nil, scollCtrl)
        scollCtrl:setInnerContainerSize(container:getContentSize())

        container:requestDoLayout()
        scollCtrl:setInnerContainerSize(container:getContentSize())
        scollCtrl:requestDoLayout()
    end

    self:setDisplayByCtrlName(CHECKBOX[1])

    -- 单选框初始化
    self:initCheckBox()

    -- 价格输入
    self:bindSellNumInput()

    -- 初始化价格
    self.priceDesignated = nil
    self.priceVendue = nil
    self.designatedChar = nil
    self.price = nil
    self.pet = nil
    self:refreshCost()
    self:refreshVendueCost()

    TradingMgr:setCheckBindFlag(false)

    -- 设置数据
    self:setPetsList()

    self:hookMsg('MSG_TRADING_OPER_RESULT')
    self:hookMsg("MSG_FUZZY_IDENTITY")

end

-- 设置数字键盘输入
function JuBaoPetSellDlg:bindSellNumInput()
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

-- 数字键盘删除数字
function JuBaoPetSellDlg:deleteNumber(key)
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
function JuBaoPetSellDlg:deleteAllNumber(key)
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
function JuBaoPetSellDlg:insertNumber(num, key)

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
function JuBaoPetSellDlg:refreshVendueCost(price)
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

function JuBaoPetSellDlg:refreshDesignatedCost(price)
    local mainPanel = self:getControl("DesignatedSellPanel")
    -- 设置消耗手续费
    local cashText2,fonColor2 = gf:getArtFontMoneyDesc(TradingMgr:getCostCash(self.pet))
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

function JuBaoPetSellDlg:onDesignatedButton(sender, eventType)
    DlgMgr:openDlg("DesignatedUserDlg")
end

function JuBaoPetSellDlg:onNoteButton(sender, eventType)
    if self:getCtrlVisible("DesignatedSellPanel") then
        -- 指定交易
        local str = CHS[4100983]
        gf:showTipInfo(str, sender)
    else
        local str1 = CHS[4101089]
        local str2 = CHS[4101090]
        local str3 = CHS[4101091]
        local str4 = CHS[4101092]
        local str5 = CHS[4101093]
        local str6 = CHS[4101094]
        local str7 = CHS[4101095]
        local str = str1 .. "\n" .. str2 .. "\n"  .. str3 .. "\n"  .. str4 .. "\n"  .. str5 .. "\n"  .. str6 .. "\n"  .. str7
        gf:showTipInfo(str, sender)
    end
end

function JuBaoPetSellDlg:onNoteButton1(sender, eventType)
    local str = CHS[2100213]
    gf:showTipInfo(str, sender)
end

-- 选择好指定交易对象后的回调
function JuBaoPetSellDlg:setDesignatedChar(char)
    self:setLabelText("DefaultLabel", char.name)
    self.designatedChar = char
end

-- 指定交易和正常交易显示
function JuBaoPetSellDlg:setDisplayByCtrlName(ctrlName)
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

-- 设置、刷新价格相关
function JuBaoPetSellDlg:refreshCost(price)
    -- 设置消耗手续费
    local cashText2,fonColor2 = gf:getArtFontMoneyDesc(TradingMgr:getCostCash(self.pet))
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

-- 初始化克隆
function JuBaoPetSellDlg:initRetainPanels()
    -- 克隆
    self.oneRowPanel = self:toCloneCtrl("OneRowPanel")

    self.chosenImage = self:toCloneCtrl("ChosenImage", self.oneRowPanel)
end

-- 清理资源
function JuBaoPetSellDlg:cleanup()
    self:releaseCloneCtrl("oneRowPanel")
    self:releaseCloneCtrl("chosenImage")

    self.curTradeType = nil
end

-- 单选框初始化
function JuBaoPetSellDlg:initCheckBox()
    self.radioCheckBox = RadioGroup.new()
    self.radioCheckBox:setItems(self, DISPLAY_CHECKBOX, self.onPetInfoCheckBox)
    self.radioCheckBox:setSetlctByName(DISPLAY_CHECKBOX[1])

    self.group = RadioGroup.new()
    self.group:setItemsByButton(self, CHECKBOX, self.onCheckBox)
end

-- 设置携带宠物
function JuBaoPetSellDlg:setPetsList()
    local listView = self:resetListView("PetListView")
    local pets = PetMgr:getOrderPets()
    if not next(pets) then return end

    -- 加载列表
    local count = #pets
    local rowCount = math.ceil(count / 2)
    for i = 1, rowCount do
        local parentPanel = self.oneRowPanel:clone()
        local leftPanel = self:getControl("PetInfoPanel_1", nil, parentPanel)
        self:setUnitPetCell(pets[i * 2 - 1], leftPanel)
        local rightPanel = self:getControl("PetInfoPanel_2", nil, parentPanel)
        self:setUnitPetCell(pets[i * 2], rightPanel)
        listView:pushBackCustomItem(parentPanel)
    end

    -- 设置默认选中
    local item = listView:getItem(0)
    if item then
        local panel = self:getControl("PetInfoPanel_1", nil, item)
        self:onSelectPet(panel)
    end
end

function JuBaoPetSellDlg:onCheckBox(sender, eventType, isInit)
    self:setDisplayByCtrlName(sender:getName())
end


-- 设置单个宠物列表
function JuBaoPetSellDlg:setUnitPetCell(pet, panel)
    if not pet then
        panel:setVisible(false)
        return
    end

    -- 头像
    self:setImage("GoodsImage", ResMgr:getSmallPortrait(pet:queryBasicInt("icon")), panel)
    self:setItemImageSize("GoodsImage", panel)

    -- 相性
    -- 设置宠物相性
    local polar = gf:getPolar(pet:queryBasicInt("polar"))
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("PolarImage", polarPath, panel)

    -- 名字
    self:setLabelText("NameLabel", pet:queryBasic("raw_name"), panel)

    -- 类型
    self:setLabelText("TypeLabel", string.format("(%s)", gf:getPetRankDesc(pet) or ""), panel)

    -- 等级
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, pet:queryBasicInt("level"), false, LOCATE_POSITION.LEFT_TOP,21, panel)

    local pet_status = pet:queryInt("pet_status")
    if pet_status == 1 then
        -- 参战
        self:setImage("StateImage", ResMgr.ui.canzhan_flag_new, panel)
    elseif pet_status == 2 then
        -- 掠阵
        if 1 == SystemSettingMgr:getSettingStatus("award_supply_pet", 0) then
            self:setImage("StateImage", ResMgr.ui.gongtong_flag_new, panel)
        else
            self:setImage("StateImage", ResMgr.ui.luezhen_flag_new, panel)
        end
    elseif PetMgr:isRidePet(pet:getId()) then -- 骑乘状态
        self:setImage("StateImage", ResMgr.ui.ride_flag_new, panel)
        if 2 == SystemSettingMgr:getSettingStatus("award_supply_pet", 0) then
            self:setImage("StateImage", ResMgr.ui.gongtong_flag_new, panel)
        end
    end

    if PetMgr:isLimitedPet(pet) then  -- 限制交易宠物
        local image = self:getControl("GoodsImage", nil, panel)
        gf:grayImageView(image)
    end

    panel.pet = pet

    -- 事件监听
    self:bindTouchEndEventListener(panel, self.onSelectPet)
end

-- 点击某个宠物
function JuBaoPetSellDlg:onSelectPet(sender, eventType)
    self.pet = sender.pet
    self:addSelectPetEff(sender)

    self:setPetInfo(self.pet)
end

-- 设置宠物
function JuBaoPetSellDlg:setPetInfo(pet)
    self:refreshCost(self.price)
    self:refreshDesignatedCost(self.priceDesignated)
    self:refreshVendueCost(self.priceVendue)

    self.pet = pet

    -- 设置宠物形象的
    self:setShapeInfo(pet)

    -- 头像
    self:setImage("GuardImage", ResMgr:getSmallPortrait(pet:queryInt("icon")), "PortraitPanel")
    self:setItemImageSize("GuardImage", "PortraitPanel")



    -- 姓名
    self:setLabelText("NameLabel", pet:queryBasic("raw_name"), "PetBasicInfoPanel")

    -- 交易
    local strLimitedTime = gf:converToLimitedTimeDay(pet:query("gift"))
    if not strLimitedTime or strLimitedTime == "" then
        self:setLabelText("ValueLabel", CHS[4200228], "ExChangePanel")
    else
        self:setLabelText("ValueLabel", strLimitedTime, "ExChangePanel")
    end

    -- 武学
    self:setLabelText("ValueLabel", pet:queryInt("martial"), "TaoLevelPanel")

        -- 等级
    local levelPanel = self:getControl("LevelPanel", nil, "PetBasicInfoPanel")
    self:setLabelText("ValueLabel", pet:queryInt("level"), levelPanel)

    -- 设置类型：野生、宝宝
    self:setImage("SuffixImage", ResMgr:getPetRankImagePath(pet))

    -- 基本信息
    PetMgr:setBasicInfoForCard(pet, self)

    -- 宠物资质
    PetMgr:setAttribInfoForCard(pet, self)

    -- 宠物技能
    PetMgr:setSkillInfoForCard(pet, self)
end

-- 设置宠物形象的
function JuBaoPetSellDlg:setShapeInfo(pet)
    -- 名字等级
    --self:setLabelText("NameLabel_1", string.format(CHS[4000391], pet:queryBasic("raw_name"), pet:queryInt("level")), "NamePanel")
    self:setLabelText("ValueLabel", pet:queryBasic("raw_name"), "NamePanel")

    -- 设置形象

    local icon = pet:queryBasicInt("dye_icon") ~= 0 and pet:queryBasicInt("dye_icon") or pet:queryBasicInt("icon")

    self:setPortrait("PetPanel", icon, 0, nil, true, nil, nil, cc.p(0, -50))

    -- 宠物logo
    PetMgr:setPetLogo(self, pet)
end


-- 增加点击宠物的选中光效
function JuBaoPetSellDlg:addSelectPetEff(sender)
    self.chosenImage:removeFromParent()
    sender:addChild(self.chosenImage)
end

function JuBaoPetSellDlg:queryBindNotAnswer()
    if not TradingMgr:getCheckBindFlag() then return end
    gf:ShowSmallTips(CHS[4300198])
    TradingMgr:setCheckBindFlag(false)
end

-- 点击宠物显示信息的checkBox
function JuBaoPetSellDlg:onPetInfoCheckBox(sender, eventType)
    for _, panelName in pairs(CHECKBOX_PANEL) do
        self:setCtrlVisible(panelName, false)

        self:setCtrlVisible("ChosenPanel", false, _)
        self:setCtrlVisible("UnChosenPanel", true, _)
    end

    self:setCtrlVisible("ChosenPanel", true, sender)
    self:setCtrlVisible("UnChosenPanel", false, sender)
    self:setCtrlVisible(CHECKBOX_PANEL[sender:getName()], true)
end


function JuBaoPetSellDlg:onVendueButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if not self.pet then return end

    local pet = self.pet
    local price = self.priceVendue

    gf:confirm(CHS[4100401], function ()
        self.curTradeType = CHECKBOX[3] -- 记录本次操作类型
        TradingMgr:cmdSellGoods(price, JUBAO_SELL_TYPE.SALE_TYPE_PET, pet:queryInt("no"), nil, pet, TRADE_SBT.AUCTION)
    end)
end

function JuBaoPetSellDlg:onSellButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if not self.pet then return end

    local pet = self.pet
    local price = self.price
    if self:getCtrlVisible("DesignatedSellPanel") then
        price = self.priceDesignated
    end

    gf:confirm(CHS[4100401], function ()
        if self:getCtrlVisible("DesignatedSellPanel") then
            -- 指定交易
            if not self.designatedChar then
                gf:ShowSmallTips(CHS[4100973])
                return
            end
            self.curTradeType = CHECKBOX[2] -- 记录本次操作类型
            TradingMgr:cmdSellGoods(price, JUBAO_SELL_TYPE.SALE_TYPE_PET, pet:queryInt("no"), self.designatedChar.gid, pet, TRADE_SBT.NONE)
        else
            self.curTradeType = CHECKBOX[1] -- 记录本次操作类型
            TradingMgr:cmdSellGoods(price, JUBAO_SELL_TYPE.SALE_TYPE_PET, pet:queryInt("no"), nil, pet, TRADE_SBT.NONE)
        end
    end)
end

function JuBaoPetSellDlg:MSG_TRADING_OPER_RESULT(data)
    -- 完成一次寄售操作
    self:onCloseButton()
end

function JuBaoPetSellDlg:MSG_FUZZY_IDENTITY(data)
    if TradingMgr:getCheckBindFlag() then
        if CHECKBOX[1] == self.curTradeType then
            if self.price and self.pet then
                TradingMgr:cmdSellGoods(self.price, JUBAO_SELL_TYPE.SALE_TYPE_PET, self.pet:queryInt("no"), nil, self.pet, TRADE_SBT.NONE)
            end
        elseif CHECKBOX[2] == self.curTradeType then
            if self.priceDesignated and self.pet and self.designatedChar then
                TradingMgr:cmdSellGoods(self.priceDesignated, JUBAO_SELL_TYPE.SALE_TYPE_PET, self.pet:queryInt("no"), self.designatedChar.gid, self.pet, TRADE_SBT.NONE)
            end
        elseif CHECKBOX[3] == self.curTradeType then
            if self.priceVendue and self.pet then
                TradingMgr:cmdSellGoods(self.priceVendue, JUBAO_SELL_TYPE.SALE_TYPE_PET, self.pet:queryInt("no"), nil, self.pet, TRADE_SBT.AUCTION)
            end


        end

        TradingMgr:setCheckBindFlag(false)
    end
end

return JuBaoPetSellDlg
