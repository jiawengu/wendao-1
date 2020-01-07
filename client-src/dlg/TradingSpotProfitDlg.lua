-- TradingSpotProfitDlg.lua
-- Created by lixh Des/26/2018
-- 商贾货站盈亏界面

local TradingSpotProfitDlg = Singleton("TradingSpotProfitDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

-- 界面数据类型
local DLG_DATA_TYPE = TradingSpotMgr:getProfitListTypeCfg()

-- ListView分页加载数量
local PAGE_ADD_NUM = 20

function TradingSpotProfitDlg:init()
    self:bindListener("SeeButton", self.onSeeButton)
    self:bindListener("GetMoneyButton", self.onGetMoneyButton)
    self:bindListener("MoneyPanel", self.onBuyCashPanel)

    self.lastRoot = self:getControl("ItemsPanel1")
    self.lastListView = self:getControl("ItemsListView", nil, self.lastRoot)
    self.lastSelectEffect = self:retainCtrl("SChosenEffectImage", self.lastRoot)
    self.lastItemPanel = self:retainCtrl("ItemsUnitPanel", self.lastRoot)
    self:bindListViewListener("ItemsListView", self.onSelectItemListView, nil, self.lastRoot)

    self.historyRoot = self:getControl("ItemsPanel2")
    self.historyListView = self:getControl("ItemsListView", nil, self.historyRoot)
    self.historySelectEffect = self:retainCtrl("SChosenEffectImage", self.historyRoot)
    self.historyItemPanel = self:retainCtrl("ItemsUnitPanel", self.historyRoot)
    self:bindListViewListener("ItemsListView", self.onSelectItemListView, nil, self.historyRoot)

    self.dlgType = nil
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, { "LastProfitCheckBox", "HistoryProfitCheckBox" }, self.onTypeCheckBox)
    self.radioGroup:selectRadio(DLG_DATA_TYPE.LAST)

    self:refreshCashPanel()

    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_TRADING_SPOT_UPDATE_MONEY")
end

-- 设置界面数据
function TradingSpotProfitDlg:setData(data)
    if data.list_type ~= self.dlgType then return end

    self.lastRoot:setVisible(false)
    self.historyRoot:setVisible(false)
    local listView
    local itemPanel
    local root
    if self.dlgType == DLG_DATA_TYPE.LAST then
        listView = self.lastListView
        itemPanel = self.lastItemPanel
        root = self.lastRoot
    else
        listView = self.historyListView
        itemPanel = self.historyItemPanel
        root = self.historyRoot
    end

    root:setVisible(true)
    listView:removeAllItems()

    -- 分页加载
    self.startNum = 0
    self.goodsListInfo = data
    self:bindListViewByPageLoad("ItemsListView", "TouchPanel", function(dlg, percent)
        if percent > 100 then
            -- 加载
            self:pushData()
        end
    end, root)

    -- 设置数据
    local sumProfit = 0
    local addCount = math.min(PAGE_ADD_NUM, data.count)
    for i = 1, data.count do
        if i <= addCount then
            local item = itemPanel:clone()
            self:setSingleItemInfo(item, data.list[i])

            self:setCtrlVisible("BackImage1", i % 2 ~= 0, item)
            self:setCtrlVisible("BackImage2", i % 2 == 0, item)

            listView:pushBackCustomItem(item)
        end

        sumProfit = sumProfit + data.list[i].profit
    end

    self.startNum = self.startNum + addCount

    -- 累计盈亏
    local allProfitStr, allProfitColor = TradingSpotMgr:getProfitTextInfo(sumProfit)
    self:setLabelText("NumLabel", allProfitStr, root, allProfitColor)

    if data.count > 0 then
        -- 默认选择第1项
        self:setSelectItem(listView:getItems()[1])
        self:setCtrlVisible("NoticePanel", false, root)
    else
        -- 显示莲花姑娘
        self:setCtrlVisible("NoticePanel", true, root)
    end

    -- 总额
    self:refreshBankMoney(data.bank_money)
end

-- 分页加载增加数据显示
function TradingSpotProfitDlg:pushData()
    local data = self.goodsListInfo
    local listView = self.lastListView
    local itemPanel = self.lastItemPanel
    if self.dlgType == DLG_DATA_TYPE.HISTORY then
        listView = self.historyListView
        itemPanel = self.historyItemPanel
    end

    local endIndex = math.min(self.startNum + PAGE_ADD_NUM, data.count)
    if endIndex == self.startNum then return end

    for i = self.startNum + 1, endIndex do
        local item = itemPanel:clone()
        self:setSingleItemInfo(item, data.list[i])

        self:setCtrlVisible("BackImage1", i % 2 ~= 0, item)
        self:setCtrlVisible("BackImage2", i % 2 == 0, item)

        listView:pushBackCustomItem(item)
    end

    listView:refreshView()
    self:setListJumpItem(listView, self.startNum + 1)
    self.startNum = endIndex
end

-- 设置单个item数据
function TradingSpotProfitDlg:setSingleItemInfo(panel, info)
    local itemName, itemInfo = TradingSpotMgr:getItemInfo(info.goods_id)
    if not itemName or not itemInfo then return end

    if panel:getChildByName("TimeLabel") then
        -- 历史盈亏，期数
        self:setLabelText("TimeLabel", TradingSpotMgr:getTradingNoDes(info.trading_no), panel)
    end

    -- 图标
    self:setImage("ItemImage", ResMgr:getItemIconPath(itemInfo.icon), panel)

    -- 名称
    self:setLabelText("NameLabel", itemName, panel)

    -- 涨幅
    local valueStr, desColor = TradingSpotMgr:getPriceUpTextInfo(info.range)
    self:setLabelText("LastFloatLabel", valueStr, panel, desColor)

    -- 持有总额
    local allPriceDes, _ = gf:getMoneyDesc(math.floor(info.all_price), true)
    self:setLabelText("AllPriceLabel", allPriceDes, panel)

    -- 盈亏
    local profitStr, profitColor = TradingSpotMgr:getProfitTextInfo(info.profit)
    self:setLabelText("ProfitNumLabel", profitStr, panel, profitColor)

    -- 设置标记
    panel.info = info
end

-- 设置选中
function TradingSpotProfitDlg:setSelectItem(panel)
    local selectEffect = self.lastSelectEffect
    if self.dlgType == DLG_DATA_TYPE.HISTORY then
        selectEffect = self.historySelectEffect
    end

    if selectEffect:getParent() then
        selectEffect:removeFromParent()
    end

    panel:addChild(selectEffect)
    self.selectItem = panel
end

-- 刷新金钱
function TradingSpotProfitDlg:refreshCashPanel()
    local moneyPanel = self:getControl("MoneyPanel")
    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(Me:queryBasicInt("cash")))
    self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, moneyPanel)
end

-- 刷新货站余额
function TradingSpotProfitDlg:refreshBankMoney(bankMoney)
    local remainMoneyPanel = self:getControl("RemainMoneyPanel")
    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(bankMoney))
    self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, remainMoneyPanel)
end

-- 切换界面数据：上期盈亏，历史盈亏
function TradingSpotProfitDlg:onTypeCheckBox(sender, eventType)
    local name = sender:getName()
    local dlgType
    if name == "LastProfitCheckBox" then
        dlgType = DLG_DATA_TYPE.LAST
    elseif name == "HistoryProfitCheckBox" then
        dlgType = DLG_DATA_TYPE.HISTORY
    end

    if self.dlgType ~= dlgType then
        -- 请求界面数据
        self.dlgType = dlgType
        TradingSpotMgr:requestProfitData(self.dlgType)

        -- 切换到不同标签后要清空选中货品
        self.selectItem = nil
    end
end

function TradingSpotProfitDlg:onSelectItemListView(sender, eventType)
    local item = self:getListViewSelectedItem(sender)
    if not item then return end

    -- 选中
    self:setSelectItem(item)
end

-- 查看
function TradingSpotProfitDlg:onSeeButton(sender, eventType)
    if not TradingSpotMgr:isTradingSpotEnable() then
        gf:ShowSmallTips(CHS[7190461])
        return
    end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[7190462])
        return
    end

    if not self.selectItem then
        gf:ShowSmallTips(CHS[7190463])
        return
    end

    -- 打开货品详情界面
    DlgMgr:openDlgEx("TradingSpotItemInfoDlg", TradingSpotMgr:getGoodsInfoById(self.selectItem.info.goods_id))
end

function TradingSpotProfitDlg:onGetMoneyButton(sender, eventType)
    if not TradingSpotMgr:isTradingSpotEnable() then
        gf:ShowSmallTips(CHS[7190461])
        self:onCloseButton()
        return
    end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[7190462])
        return
    end

    -- 请求提款
    TradingSpotMgr:requestGetMoney()
end

function TradingSpotProfitDlg:onBuyCashPanel(sender, eventType)
    OnlineMallMgr:openOnlineMall("OnlineMallExchangeMoneyDlg")
end

function TradingSpotProfitDlg:cleanup()
    self.dlgType = nil
    self.startNum = nil
    self.goodsListInfo = nil
    self.selectItem = nil
end

function TradingSpotProfitDlg:MSG_TRADING_SPOT_UPDATE_MONEY(data)
    self:refreshBankMoney(data.bank_money)
end

function TradingSpotProfitDlg:MSG_UPDATE(data)
    if data and data.cash then
        self:refreshCashPanel()
    end
end

return TradingSpotProfitDlg
