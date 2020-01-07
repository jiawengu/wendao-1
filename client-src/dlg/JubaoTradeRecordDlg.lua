-- JubaoTradeRecordDlg.lua
-- Created by songcw Feb/06/2017
-- 聚宝斋交易记录界面

local JubaoTradeRecordDlg = Singleton("JubaoTradeRecordDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local json = require("json")

-- 单选框
local CHECK_BOXS = {
    "BuyRecordCheckBox",
    "SaleRecordCheckBox",
}

function JubaoTradeRecordDlg:init()
    -- 初始化克隆
    self:initRetainPanels()

    -- 单选框初始化
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, CHECK_BOXS, self.onCheckBox)
    self.radioGroup:setSetlctByName(CHECK_BOXS[1])

    TradingMgr:queryJuBaoRecord()

    self:hookMsg("MSG_TRADING_RECORD")
end

-- 初始化克隆
function JubaoTradeRecordDlg:initRetainPanels()
    self.goodsInfoPanel = self:toCloneCtrl("GoodsInfoPanel")
end

function JubaoTradeRecordDlg:cleanup()
    self:releaseCloneCtrl("goodsInfoPanel")
end

-- 点击checkBox
function JubaoTradeRecordDlg:onCheckBox(sender, eventType)
    local ctrlName = sender:getName()
    local goods
    if ctrlName == "BuyRecordCheckBox" then
        goods = TradingMgr:getTradeRecord("buy")
        self:setLabelText("Label", CHS[6000226], "LeftTimesPanel")
    else
        goods = TradingMgr:getTradeRecord("sale")
        self:setLabelText("Label", CHS[6000225], "LeftTimesPanel")
    end

    self:setListInfo(goods)
end

-- 设置list项
function JubaoTradeRecordDlg:setListInfo(goods)
    local listCtrl = self:resetListView("ListView")
    if not goods or not next(goods) then
        self:setCtrlVisible("NoticePanel", true)
        return
    end
    self:setCtrlVisible("NoticePanel", false)
    local count = #goods
    for i = 1, count do
        local panel = self.goodsInfoPanel:clone()
        self:setUnitGoodsInfo(goods[i], panel, i)
        listCtrl:pushBackCustomItem(panel)
    end

    listCtrl:requestRefreshView()
end

-- 设置单个商品信息panel
function JubaoTradeRecordDlg:setUnitGoodsInfo(info, panel, index)
    local jsonData = json.decode(info.para)

    -- 商品序号
    self:setLabelText("NumLabel", index, panel)

    -- 如果有相性
    if jsonData.polar then
        InventoryMgr:addPetPolarImage(self:getControl("GoodsImage", nil, panel), jsonData.polar)
    end

    -- 名字
    self:setCtrlVisible("NameLabel", true, panel)
    self:setLabelText("NameLabel", info.goods_name, panel)

    -- 价格
    local cashText = gf:getArtFontMoneyDesc(info.price)

    if info.sell_buy_type == TRADE_SBT.APPOINT_BUYOUT then
        cashText = gf:getArtFontMoneyDesc(info.butout_price)
    elseif info.sell_buy_type == TRADE_SBT.AUCTION_BUY then
        cashText = gf:getArtFontMoneyDesc(info.butout_price)
    end

    self:setNumImgForPanel("PriceValuePanel_2", ART_FONT_COLOR.DEFAULT, cashText, false, LOCATE_POSITION.MID, 23, panel)
    self:setNumImgForPanel("PriceValuePanel_1", ART_FONT_COLOR.DEFAULT, "$", false, LOCATE_POSITION.MID, 23, panel)

    -- 等级
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, info.level, false, LOCATE_POSITION.LEFT_TOP,21, panel)

    -- 指定交易
    self:setAppointeeFlag(info.sell_buy_type == TRADE_SBT.APPOINT_BUY, panel)


    -- 信息
    self:setLabelText("InfoLabel", "", panel)
    self:setCtrlVisible("CashInfoPanel", false, panel)
    local bigType = math.floor(info.goods_type / 100)
    if bigType == JUBAO_SELL_TYPE.SALE_TYPE_CASH then
        self:setImage("GoodsImage", ResMgr.ui.money, panel)
        self:setCtrlVisible("NameLabel", false, panel)
        self:setCtrlVisible("CashInfoPanel", true, panel)

        local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(info.goods_name))
        self:setNumImgForPanel("CashPanel", fontColor, cashText, false, LOCATE_POSITION.LEFT_TOP, 23, panel)
        local moneyStr, fontColor = gf:getMoneyDesc(math.floor(tonumber(info.goods_name) / info.price), true)
        self:setLabelText("PerValueLabel", moneyStr, panel, fontColor)
        self:setLabelText("PerValueLabel2", moneyStr, panel)
        self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, "", false, LOCATE_POSITION.LEFT_TOP,21, panel)
    elseif JUBAO_SELL_TYPE.SALE_TYPE_PET == bigType then
        -- 头像
        self:setImage("GoodsImage", ResMgr:getSmallPortrait(info.icon), panel)

        -- 如果是宠物
        if info.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_NORMAL
            or info.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_ELITE
            or info.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_OTHER
            or info.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_JINIAN
            or not jsonData.capacity_level then -- 旧数据也许没有该字段
            -- 普通、变异、其他显示武学
            -- 道行、宠物为武学
            if jsonData.martial then
                self:setLabelText("InfoLabel", string.format(CHS[4100441], jsonData.martial), panel)
            end
        else
            -- 御灵、精怪显示阶位
            if jsonData.capacity_level == jsonData.default_capacity_level then
                self:setLabelText("InfoLabel", string.format(CHS[4300213], jsonData.capacity_level), panel)
            else
                self:setLabelText("InfoLabel", string.format(CHS[4300214], jsonData.default_capacity_level, jsonData.capacity_level - jsonData.default_capacity_level), panel)
            end
        end
    elseif bigType == JUBAO_SELL_TYPE.SALE_TYPE_JEWELRY then
        -- icon
        self:setImage("GoodsImage", ResMgr:getItemIconPath(info.icon), panel)

        if jsonData.best_prop_key then
            local attChs = EquipmentMgr:getAttribChsOrEng(jsonData.best_prop_key)
            local bai = EquipmentMgr:getPercentSymbolByField(jsonData.best_prop_key)
            local retChs = attChs .. " " .. jsonData.best_prop_val .. bai
            if jsonData.best_prop_max then
                retChs = retChs .. "/" .. jsonData.best_prop_max .. bai
            end
            self:setLabelText("InfoLabel", retChs, panel)
        end
    elseif bigType == JUBAO_SELL_TYPE.SALE_TYPE_ARTIFACT then
        -- icon
        self:setImage("GoodsImage", ResMgr:getItemIconPath(info.icon), panel)

        if jsonData.extra_skill_name and jsonData.extra_skill_name ~= "" then
            self:setLabelText("InfoLabel", CHS[4100459] .. jsonData.extra_skill_name, panel)
        else
            self:setLabelText("InfoLabel", CHS[4100460], panel)
        end
    elseif bigType == JUBAO_SELL_TYPE.SALE_TYPE_WEAPON or bigType == JUBAO_SELL_TYPE.SALE_TYPE_PROTECTOR then
        -- icon
        self:setImage("GoodsImage", ResMgr:getItemIconPath(info.icon), panel)

        if jsonData.rebuild_level and jsonData.rebuild_level ~= 0 then
            self:setLabelText("InfoLabel", string.format(CHS[4100461], jsonData.rebuild_level) , panel)
        else
            self:setLabelText("InfoLabel", CHS[4100462], panel)
        end
    elseif JUBAO_SELL_TYPE.SALE_TYPE_ROLE == bigType then
        if jsonData.tao then
            self:setLabelText("InfoLabel", string.format(CHS[4100404], gf:getTaoStr(jsonData.tao, 0)), panel)
        end

        if jsonData.upgrade_type then
            self:setLabelText("InfoLabel", "", panel)

            if jsonData.tao then
                self:setCtrlVisible("InfoLabel2", true, panel)
                self:setLabelText("InfoLabel2", string.format(CHS[4100404], gf:getTaoStr(jsonData.tao, 0)), panel)
            end
            self:setCtrlVisible("InfoLabel3", true, panel)
            if jsonData.upgrade_type == 0 then
                self:setLabelText("InfoLabel3", CHS[4100577], panel)
            else
                self:setLabelText("InfoLabel3", string.format(CHS[4100578], gf:getChildName(jsonData.upgrade_type), jsonData.upgrade_level), panel)
            end
        end

        -- 头像
        self:setImage("GoodsImage", ResMgr:getSmallPortrait(info.icon), panel)
    end

    -- 出售时间
    self:setLabelText("DateLabel", gf:getServerDate(CHS[4300233], info.end_time), panel)
    self:setLabelText("LeftTimeLabel", gf:getServerDate("%H:%M", info.end_time), panel)
end

function JubaoTradeRecordDlg:setAppointeeFlag(isApppintee, panel)
    self:setCtrlVisible("StateBKImage", isApppintee, panel)
    self:setCtrlVisible("SellStateValueLabel_1", isApppintee, panel)
    self:setCtrlVisible("SellStateValueLabel_2", isApppintee, panel)
end

function JubaoTradeRecordDlg:MSG_TRADING_RECORD(data)
    local selectName = self.radioGroup:getSelectedRadioName()
    local goods
    if selectName == "BuyRecordCheckBox" then
        goods = TradingMgr:getTradeRecord("buy")
    else
        goods = TradingMgr:getTradeRecord("sale")
    end

    self:setListInfo(goods)
end



return JubaoTradeRecordDlg
