-- JuBaoZhaiStorageDlg.lua
-- Created by
--

local JuBaoZhaiStorageDlg = Singleton("JuBaoZhaiStorageDlg", Dialog)

-- 寄售商品相关最大值定义
local MY_EQUIP_MAX = 10
local MY_PET_MAX = 3
local MY_CASH_MAX = 2
local MY_GOODS_MAX = MY_EQUIP_MAX + MY_PET_MAX + MY_CASH_MAX

function JuBaoZhaiStorageDlg:init()
    self:bindListener("TradeRecordButton", self.onTradeRecordButton)
    self:bindListener("GetBackButton", self.onGetBackButton)
    self:bindListener("ModifyPriceButton", self.onModifyPriceButton)
    self:bindListViewListener("ListView", self.onSelectListView)

    -- 克隆相关控件
    self.addSellPanel = self:retainCtrl("SellGoodsPanel")
    self:setCtrlVisible("IndexImage", false, self.addSellPanel)
    self.goodsPanel = self:retainCtrl("GoodsInfoPanel")

    -- 控件绑定
    self:bindTouchEndEventListener(self.addSellPanel, self.addSellItem)
    self:bindTouchEndEventListener(self.goodsPanel, self.modifySellItem)

    self.operateGoodsGid = nil
    self.openType = nil

    -- 设置我的货架
    self:setMyStorega()

    self:hookMsg("MSG_TRADING_SNAPSHOT_ME")
    self:hookMsg("MSG_TRADING_ROLE")
    self:hookMsg("MSG_TRADING_GOODS_MINE_UPDATE")
    self:hookMsg("MSG_TRADING_GOODS_MINE_REMOVE")
    self:hookMsg("MSG_TRADING_SELL_CASH")

end

-- 设置我的寄售列表
function JuBaoZhaiStorageDlg:setMyStorega()
    local listInfo = TradingMgr:getTradingData()
    local listCtrl = self:resetListView("ListView", 0, ccui.ListViewGravity.centerVertical, "StoragePanel")
    local titlePanel = self:getControl("TypePanel", nil, "StoragePanel")

    if not listInfo or not next(listInfo) then
        -- 如果没有寄售的商品
        self:setLabelText("NumLabel", "", self.addSellPanel)
        listCtrl:pushBackCustomItem(self.addSellPanel)
        return
    end

    local isShowAdd = false     -- 判断是否需要显示增加的panel
    local myUserData = TradingMgr:getTradingUserData()
    if (myUserData and next(myUserData)) or listInfo.count >= MY_GOODS_MAX then
    else
        isShowAdd = true
    end

    if isShowAdd then
        self:setLabelText("NumLabel", "", self.addSellPanel)
        listCtrl:pushBackCustomItem(self.addSellPanel)
    end

    for i = 1, listInfo.count do
        local panel = self.goodsPanel:clone()
        self:setGoodsUnitPanel(panel, i, listInfo[i])
        listCtrl:pushBackCustomItem(panel)
    end
end

-- 指定交易标记
function JuBaoZhaiStorageDlg:setAppointeeFlag(isApppintee, panel)
    self:setCtrlVisible("StateBKImage", isApppintee, panel)
    self:setCtrlVisible("SellStateValueLabel_1", isApppintee, panel)
    self:setCtrlVisible("SellStateValueLabel_2", isApppintee, panel)
end


-- 设置单个商品
function JuBaoZhaiStorageDlg:setGoodsUnitPanel(sender, i, data)
    -- 索引
    self:setLabelText("NumLabel", i, sender)

    -- 指定交易标记
 --   self:setAppointeeFlag(data.sell_buy_type == TRADE_SBT.APPOINT_SELL, sender)
    TradingMgr:setSellBuyTypeFlag(data.sell_buy_type, self, sender)

    -- 等级
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP,21, sender)

    -- 隐藏金钱信息部分
    self:setCtrlVisible("CashInfoPanel", false, sender)
    self:setCtrlVisible("NameLabel", true, sender)

    -- 预定
    if data.state == TRADING_STATE.TIMEOUT or data.state == TRADING_STATE.CANCEL or data.state == TRADING_STATE.FORCE_CLOSED or data.end_time - gf:getServerTime() <= 0 then
        self:setCtrlVisible("DepositImage", false, sender)
    else
        local deposit_state = data.jdata and data.jdata.deposit_state or data.deposit_state
        self:setCtrlVisible("DepositImage", deposit_state == 1, sender)
    end

    self:setLabelText("InfoLabel", "", sender)
    if not data.para then
        -- 人物
        -- 名字
        self:setLabelText("NameLabel", Me:getShowName(), sender)
        -- 头像
        self:setImage("GoodsImage", ResMgr:getSmallPortrait(Me:queryBasicInt("icon")), sender)
        self:setItemImageSize("GoodsImage", sender)
        -- 道行\元婴

        self:setLabelText("InfoLabel", "", sender)
        self:setLabelText("InfoLabel2", string.format(CHS[4100404], gf:getTaoStr(Me:queryBasicInt("tao"), 0)), sender)
        if Me:getChildType() == 0 then
            self:setLabelText("InfoLabel3", CHS[4100577], sender)
        else
            self:setLabelText("InfoLabel3", string.format(CHS[4100578], Me:getChildName(), Me:queryInt("upgrade/level")), sender)
        end

        self:setCtrlVisible("InfoLabel2", true, sender)
        self:setCtrlVisible("InfoLabel3", true, sender)

    else
        self:setLabelText("NameLabel", data.goods_name, sender)
        local bigType = math.floor(data.goods_type / 100)
        if bigType == JUBAO_SELL_TYPE.SALE_TYPE_CASH then
            self:setImage("GoodsImage", ResMgr.ui.money, sender)
            self:setCtrlVisible("NameLabel", false, sender)
            self:setCtrlVisible("CashInfoPanel", true, sender)

            local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(data.goods_name))
            self:setNumImgForPanel("CashPanel", fontColor, cashText, false, LOCATE_POSITION.LEFT_TOP, 23, sender)
            local moneyStr, fontColor = gf:getMoneyDesc(math.floor(tonumber(data.goods_name) / data.price), true)
            self:setLabelText("PerValueLabel", moneyStr, sender, fontColor)
            self:setLabelText("PerValueLabel2", moneyStr, sender)
            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, "", false, LOCATE_POSITION.LEFT_TOP,21, sender)
        elseif bigType == JUBAO_SELL_TYPE.SALE_TYPE_PET then
            self:setImage("GoodsImage", ResMgr:getSmallPortrait(data.icon), sender)

            if data.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_NORMAL
                or data.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_ELITE
                or data.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_EPIC
                or data.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_OTHER
                or data.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_JINIAN then
                -- 普通、变异、其他显示武学
                -- 道行、宠物为武学
                if data.martial then
                    self:setLabelText("InfoLabel", string.format(CHS[4100441], data.martial), sender)
                end
            else
                -- 御灵、精怪显示阶位
                if data.capacity_level == data.default_capacity_level then
                    self:setLabelText("InfoLabel", string.format(CHS[4300213], data.capacity_level), sender)
                else
                    self:setLabelText("InfoLabel", string.format(CHS[4300214], data.default_capacity_level, data.capacity_level - data.default_capacity_level), sender)
                end
            end
        elseif bigType == JUBAO_SELL_TYPE.SALE_TYPE_ROLE then
            self:setImage("GoodsImage", ResMgr:getSmallPortrait(data.icon), sender)

            if data.tao then
                self:setLabelText("InfoLabel", string.format(CHS[4100404], gf:getTaoStr(data.tao, 0)), sender)
            end
        elseif bigType == JUBAO_SELL_TYPE.SALE_TYPE_JEWELRY then
            if data.best_prop_key then
                local attChs = EquipmentMgr:getAttribChsOrEng(data.best_prop_key)
                local bai = EquipmentMgr:getPercentSymbolByField(data.best_prop_key)
                local retChs = attChs .. " " .. data.best_prop_val .. bai
                if data.best_prop_max then
                    retChs = retChs .. "/" .. data.best_prop_max .. bai
                end
                self:setLabelText("InfoLabel", retChs, sender)
            end

            -- 图标
            self:setImage("GoodsImage", ResMgr:getItemIconPath(data.icon), sender)
        elseif bigType == JUBAO_SELL_TYPE.SALE_TYPE_ARTIFACT then
            -- 图标
            self:setImage("GoodsImage", ResMgr:getItemIconPath(data.icon), sender)
            if data.extra_skill_name and data.extra_skill_name ~= "" then
                self:setLabelText("InfoLabel", CHS[4100459] .. data.extra_skill_name, sender)
            else
                self:setLabelText("InfoLabel", CHS[4100460], sender)
            end

            if data.polar then
                local image = self:getControl("GoodsImage", nil, sender)
                InventoryMgr:addArtifactPolarImage(image, data.polar)
            end
        elseif bigType == JUBAO_SELL_TYPE.SALE_TYPE_WEAPON or bigType == JUBAO_SELL_TYPE.SALE_TYPE_PROTECTOR then
            self:setImage("GoodsImage", ResMgr:getItemIconPath(data.icon), sender)

            if data.rebuild_level and data.rebuild_level ~= 0 then
                self:setLabelText("InfoLabel", string.format(CHS[4100461], data.rebuild_level) , sender)
            else
                self:setLabelText("InfoLabel", CHS[4100462], sender)
            end
        end
    end

    -- 状态
    self:setLabelText("StateLabel", TradingMgr:getTradingState(data.state), sender)

    -- 时间
    if data.state == TRADING_STATE.TIMEOUT or data.state == TRADING_STATE.CANCEL or data.state == TRADING_STATE.FORCE_CLOSED then
        self:setLabelText("LeftTimeLabel", "", sender)
    else
        self:setLabelText("LeftTimeLabel", TradingMgr:getLeftTime(data.end_time - gf:getServerTime(), data.state), sender)
    end

    local cashText = gf:getArtFontMoneyDesc(data.price)
    if data.sell_buy_type == TRADE_SBT.AUCTION then
        cashText = gf:getArtFontMoneyDesc(data.butout_price)
    end

    self:setNumImgForPanel("PriceValuePanel_2", ART_FONT_COLOR.DEFAULT, cashText, false, LOCATE_POSITION.MID, 23, sender)

    self:setNumImgForPanel("PriceValuePanel_1", ART_FONT_COLOR.DEFAULT, "$", false, LOCATE_POSITION.MID, 23, sender)


    sender.goods_type = data.goods_type

    sender.goods_gid = data.goods_gid

    sender:requestDoLayout()
end

-- 点击 上架商品
function JuBaoZhaiStorageDlg:addSellItem(sender)
    self.openType = "add"
    local myUserData = TradingMgr:getTradingUserData()
    if myUserData and next(myUserData) then
        TradingMgr:tradingSnapshot(myUserData[1].goods_gid, TRAD_SNAPSHOT.SNAPSHOT)
    else
        TradingMgr:tradingSnapshotMe()
    end
end

-- 点击某个商品
function JuBaoZhaiStorageDlg:modifySellItem(sender)
    if sender.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_CASH_GOODS then
        -- 请求当日标准价
        gf:CmdToServer("CMD_TRADING_SELL_CASH", {goods_gid = sender.goods_gid})
        self.operateGoodsGid = sender.goods_gid
    else
        -- 角色
      --  TradingMgr:tradingSnapshotMe()
        TradingMgr:tradingSnapshot(sender.goods_gid, TRAD_SNAPSHOT.SNAPSHOT)
        self.openType = "modify"
    end
end

function JuBaoZhaiStorageDlg:onTradeRecordButton(sender, eventType)
    DlgMgr:openDlg("JubaoTradeRecordDlg")
end

function JuBaoZhaiStorageDlg:onGetBackButton(sender, eventType)
end

function JuBaoZhaiStorageDlg:onModifyPriceButton(sender, eventType)
end

function JuBaoZhaiStorageDlg:onSelectListView(sender, eventType)
end


function JuBaoZhaiStorageDlg:MSG_TRADING_SNAPSHOT_ME(data)
    local charData
    local tra_data
    if pcall(function()
        charData = json.decode(data.content)
    end) then
    end
    if charData then tra_data = TradingMgr:changeIndexToFieldByChar(charData) end

    if not charData or not tra_data or not self.openType then return end
    TradingMgr:setMyGoodsData(tra_data)
    local dlg = DlgMgr:openDlg("UserSellDlg")
    if self.openType == "add" then
        dlg:setButtonDisplay(1)
    elseif self.openType == "modify" then
        dlg:setButtonDisplay(TRADING_STATE.SHOW, TradingMgr:getTradingData()[1].price)
    end
end

function JuBaoZhaiStorageDlg:MSG_TRADING_ROLE(data)
    self:setMyStorega()
end

function JuBaoZhaiStorageDlg:MSG_TRADING_GOODS_MINE_UPDATE(data)
    self:setMyStorega()
end

function JuBaoZhaiStorageDlg:MSG_TRADING_GOODS_MINE_REMOVE(data)
    self:setMyStorega()
end

function JuBaoZhaiStorageDlg:MSG_TRADING_SELL_CASH()
    if self.operateGoodsGid then
        local goodsData = TradingMgr:getTradingDataByGid(self.operateGoodsGid)
        local dlg = DlgMgr:openDlg("JuBaoCashOperateDlg")
        dlg:setDlgData(goodsData)
    end

    self.operateGoodsGid = nil
end

return JuBaoZhaiStorageDlg
