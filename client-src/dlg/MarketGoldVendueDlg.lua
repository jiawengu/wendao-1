-- MarketGoldVendueDlg.lua
-- Created by songcw Sep/2018/30
-- 珍宝拍卖界面

local MarketBuyDlg = require('dlg/MarketBuyDlg')
local MarketGoldVendueDlg = Singleton("MarketGoldVendueDlg", MarketBuyDlg)
local RadioGroup = require("ctrl/RadioGroup")

local ITEM_CLASS = {
    CHS[4101226], CHS[4101227], CHS[4101228], CHS[4101229], CHS[4101230]-- "我的竞拍", "装备", "宠物", "高级首饰", "法宝"
}

local SELL_STATE_CHECKBOX = {
    "SellingCheckBox", "PublicityCheckBox"
}

local PUBLIC_ITEM_CLASS = {}

function MarketGoldVendueDlg:init(notQuery)

    self.notQuery = notQuery    -- 为true 时，希望初始化取请求数据
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, SELL_STATE_CHECKBOX, self.onCheckBox)
    self.firstClass = self:getDefaultMenu()
    self.radioGroup:setSetlctByName(SELL_STATE_CHECKBOX[1])
    self.notQuery = false
    MarketBuyDlg.init(self)

    self:setCtrlVisible("ViewButton", true)

    self:bindListener("ViewButton", self.onViewButton)

end

function MarketGoldVendueDlg:onCheckBox(sender, eventType)
    self:clickClassList(self.firstClass)
end

function MarketGoldVendueDlg:getDefaultMenu()
    return CHS[4101226]
end

function MarketGoldVendueDlg:clickClassList(name)
    -- 现在会记忆二级菜单滑动位置，连续点击一级菜单的某一项过程中，每次都会刷新二级菜单，导致画面闪烁
    -- 故如果连续点击一级菜单的某一项，不再重新生成二级菜单界面
    if self.firstClass and self.firstClass == name then
        if self:getCtrlVisible("SecondPanel") == true then
            return
        end
    end

    self:setCtrlVisible("SellMoneyPanel", false)
    self:setCtrlVisible("MoneyPanel2", false)
    self:setCtrlVisible("ItemsPanel", true)
    self:setCtrlVisible("LianxiButton", true)
    self:setCtrlVisible("RefreshButton", false)
    self:setCtrlVisible("SearchInfoPanel", name == CHS[7000306])
    self:setCtrlVisible(SELL_STATE_CHECKBOX[2], name ~= CHS[4101226])
    if name == CHS[4101226] then
        self:setCheck(SELL_STATE_CHECKBOX[1], true)
        self:setCheck(SELL_STATE_CHECKBOX[2], false)
    end

    self.firstClass = name

    self:setCtrlVisible("PriceSortButton", name ~= CHS[4101226])

    if self.notQuery then return end

    if name == CHS[4101226] then
        --    self.radioGroup:setSetlctByName(SELL_STATE_CHECKBOX[1])
        gf:CmdToServer("CMD_GOLD_STALL_MY_BID_GOODS")
        return
    end

    local key = self:getRequestKey()
    local page_str = self:getPageStr()

    if key and page_str then
        MarketMgr:requestBuyItem(key, page_str, self:tradeType())
    end
end

-- 获取关键字
function MarketGoldVendueDlg:getKeyStr()
    return (self.firstClass .. "__")
end

-- 获取相关位置信息
function MarketGoldVendueDlg:getPosInfo()
    return self.curPage, self.sortType
end

-- 获取一级菜单的列表
function MarketGoldVendueDlg:getFirstItemList()
    return ITEM_CLASS
end

-- 设置所有hook消息
function MarketGoldVendueDlg:setAllHookMsgs()
    self:hookMsg("MSG_GOLD_STALL_GOODS_LIST")
    self:hookMsg("MSG_GOLD_STALL_MY_BID_GOODS")
    self:hookMsg("MSG_GOLD_STALL_GOODS_STATE")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_GOLD_STALL_GOODS_INFO_ITEM")
end

-- 收藏某个，返回的数据
function MarketGoldVendueDlg:MSG_GOLD_STALL_GOODS_STATE(data)
    if not self.selectItemData then return end
    local selettItem
    for i = 1, data.count do
        if self.selectItemData.id == data.itemList[i].id then
            selettItem = data.itemList[i]

            self.selectItemData.appointee_name = data.itemList[i].appointee_name
      --      self.selectItemData.price = data.itemList[i].price
            self.selectItemData.buyout_price = data.itemList[i].buyout_price

        end
    end

    if not selettItem then return end

    if selettItem.status == MARKET_STATUS.STALL_GS_AUCTION_SHOW or selettItem.status == MARKET_STATUS.STALL_GS_AUCTION or selettItem.status == MARKET_STATUS.STALL_GS_AUCTION_PAYMENT then
        -- MSG_GOLD_STALL_GOODS_STATE也会走到这，该消息如果 data.is_from_client == 0不需要加收藏
    if data.is_from_client and data.is_from_client == 0 then return end


    elseif selettItem.status == 0 then
        gf:ShowSmallTips(CHS[4200235]) -- 当前商品已卖出或已下架，请选择其他商品。",
        self:requireItemList()
        return
    elseif selettItem.status ~= 2 then
        gf:ShowSmallTips(CHS[4200236]) -- 当前商品状态已发生变化，请重新操作。"
        self:requireItemList()
        return
    end

    -- 是否已经收藏
    if MarketMgr:isCollectedInAll(self.selectItemData.id, self:tradeType()) then return end

    if selettItem.status == MARKET_STATUS.STALL_GS_AUCTION_SHOW then
        MarketMgr:addPublicCollectItem(self.selectItemData, self:tradeType())
    elseif selettItem.status == MARKET_STATUS.STALL_GS_AUCTION or selettItem.status == MARKET_STATUS.STALL_GS_AUCTION_PAYMENT then
        MarketMgr:addCollectItem(self.selectItemData, self:tradeType())
    end


    -- 可以收藏
    gf:ShowSmallTips(CHS[3002995])

    self:swichCancelAndCollectBtn(false)
    self:refreshCollectImage(true, self.selectItemCell)
end

-- 设置金钱
function MarketGoldVendueDlg:setCashView()
    local goldText = gf:getArtFontMoneyDesc(Me:queryBasicInt('gold_coin'))
    self:setNumImgForPanel("MoneyValuePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.MID, 23)
end

function MarketGoldVendueDlg:setTradeTypeUI()
    -- 设置商品单元格为货币为金元宝
    self:setCtrlVisible("GoldImage", true, self.itemCellCtrl)
    self:setCtrlVisible("CoinImage", false, self.itemCellCtrl)

    -- 设置玩家身上的金元宝
    local moneyPanel = self:getControl("MoneyPanel")
    self:setCtrlVisible("GoldImage", true, moneyPanel)
    self:setCtrlVisible("MoneyImage", false, moneyPanel)
end

function MarketGoldVendueDlg:setItemData(cell, data)
    MarketBuyDlg.setItemData(self, cell, data)


    -- 落后、领先标记
    self:setCtrlVisible("BehindImage", false, cell)
    self:setCtrlVisible("LeadImage", false, cell)
    self:setCtrlVisible("PayImage", false, cell)
    if self.radioGroup:getSelectedRadioName() == "SellingCheckBox" then
        local panel = self:getControl("IconPanel", nil, cell)
        self:setCtrlVisible("BackImage", false, panel)
        self:setLabelText("TimeLabel", "", panel)


        if MarketMgr:isVenduedByGoodsGid(data.id) then
            self:setCtrlVisible("BehindImage", data.appointee_name ~= Me:queryBasic("name"), cell)
            self:setCtrlVisible("LeadImage", data.appointee_name == Me:queryBasic("name"), cell)
        end

        if data.appointee_name == Me:queryBasic("name") and data.status == MARKET_STATUS.STALL_GS_AUCTION_PAYMENT then
            self:setCtrlVisible("PayImage", true, cell)
        end
    else
        -- 超时
        if data.status == 3 then
            self:setCtrlVisible("TimeoutImage", true, cell)
            -- 公示中
        elseif data.status == 1 or data.status == 11 then
            self:setCtrlVisible("TimeLabel", true, cell)
            local leftTime = data.endTime - gf:getServerTime()
            local timeStr = MarketMgr:getTimeStr(leftTime)
            self:setLabelText("TimeLabel", timeStr, cell)
        elseif data.status == 4 then
            self:setCtrlVisible("TipImage", true, cell)
        elseif data.status == MARKET_STATUS.STALL_GS_AUCTION then
            self:setLabelText("TimeLabel", "", cell)
        end
    end

end


function MarketGoldVendueDlg:MSG_GOLD_STALL_GOODS_LIST(data)

    if self.defaultSelectGid and self.defaultSelectGid ~= "" then
        if data.sell_stage == MARKET_STATUS.STALL_GS_AUCTION_SHOW then
            self:setCheck("SellingCheckBox", false)
            self:setCheck("PublicityCheckBox", true)
        else
            self:setCheck("SellingCheckBox", true)
            self:setCheck("PublicityCheckBox", false)
        end
    end

    self:MSG_STALL_ITEM_LIST(data)
end

function MarketGoldVendueDlg:MSG_GOLD_STALL_MY_BID_GOODS(data)
    if self.firstClass ~= CHS[4101226] then return end
    if self.radioGroup:getSelectedRadioName() == "PublicityCheckBox" then
        -- 公示没有竞拍商品，如果消息延迟，手动清理
        data.count = 0
        data.itemList = {}
    end

    -- 竞拍要排序一下
    for i = 1, data.count do
        data.itemList[i].lastTime = MarketMgr:isVenduedByGoodsGid(data.itemList[i].id) or 0
    end

    table.sort(data.itemList, function(l, r)
        if l.lastTime > r.lastTime then return true end
        if l.lastTime < r.lastTime then return false end
    end)

    self:refreshItemList(data)
end

function MarketGoldVendueDlg:MSG_STALL_ITEM_LIST(data)

    self:refreshItemList()
end

function MarketGoldVendueDlg:openSearchDlg()
    DlgMgr:openDlg("MarketGoldSearchDlg")
end

function MarketGoldVendueDlg:cancleSelectItem()
    self.itemSelectImg:removeFromParent()

    self.selectItemData = nil
end



-- 刷新商品列表
function MarketGoldVendueDlg:refreshItemList(data)
    self:cancleSelectItem()
    self:swichCancelAndCollectBtn(true)
    self.isFromSearch = false


    local scrollview = self:getControl("ItemScrollView")
    scrollview:removeAllChildren()

    local itemList
    if data then
        itemList = data["itemList"] or {}
        self.curPage = 1            -- 目前有传data的，只有拍卖竞拍，设定8个
        self.totalPage = 1

        if #itemList == 0 then
            self:setCtrlVisible("NoticePanel", false, itemsPanel)
            self:setCtrlVisible("NoticePanel2", false, itemsPanel)
            self:setCtrlVisible("NoticePanel3", true, itemsPanel)
            self:refreshPageInfo()
            return
        end
    else
        local requireInfo = MarketMgr:getStallItemList("MarketGoldBuyDlgPublicityCheckBox")
        if self.radioGroup:getSelectedRadioName() == "SellingCheckBox" then
            requireInfo = MarketMgr:getStallItemList("MarketGoldBuyDlgSellingCheckBox")
        end

        itemList = requireInfo["itemList"] or {}
        self.curPage = requireInfo["cur_page"] or 0
        self.totalPage = requireInfo["totalPage"] or 0
    end

    local itemsPanel = self:getControl("ItemsPanel")

    if #itemList == 0 then
        self:setCtrlVisible("NoticePanel", true, itemsPanel)
        self:setCtrlVisible("NoticePanel2", false, itemsPanel)
        self:setCtrlVisible("NoticePanel3", false, itemsPanel)
        self:refreshPageInfo()
        return
    else
        self:setCtrlVisible("NoticePanel", false, itemsPanel)
        self:setCtrlVisible("NoticePanel2", false, itemsPanel)
        self:setCtrlVisible("NoticePanel3", false, itemsPanel)
    end

    self:initListPanel(itemList, self.itemCellCtrl, self.setItemData, scrollview, true)

    self:refreshPageInfo()
end


function MarketGoldVendueDlg:onViewButton(sender, eventType)

    if not self.selectItemData then
        gf:ShowSmallTips(CHS[4010213])
        return
    end

    MarketMgr:requireMarketGoodCard(self.selectItemData.id.."|"..self.selectItemData.endTime,
        MARKET_CARD_TYPE.VIEW_OTHERS, self.selectItemData, nil, true, self:tradeType())
end

function MarketGoldVendueDlg:refrshSortButtonInfo()
    self:refreshUpDownImage()
    self.isOnBuyButton = true

    self:requireItemList()

    MarketMgr:setLastSort(self.upSort, self.sortType)
end

-- 发送请求物品的指令
function MarketGoldVendueDlg:requireItemList()
    if not self.firstClass or not self.curPage then return end

    local key = self:getRequestKey()
    local page_str = self:getPageStr()

    if key and page_str then
        MarketMgr:requestBuyItem(key, page_str, self:tradeType())
    end
end


function MarketGoldVendueDlg:getPageStr()
    if not self.curPage then  return end

    local page_str = ""

    if self.curPage < 1 then
        self.curPage = 1
    end

    local marketStatus = MARKET_STATUS.STALL_GS_AUCTION_SHOW
    if self.radioGroup:getSelectedRadioName() == "SellingCheckBox" then
        marketStatus = MARKET_STATUS.STALL_GS_AUCTION
    end

    if self.upSort then
        page_str = string.format("%d;%d;%d;%s", self.curPage, marketStatus, 1, self.sortType or "price")
    else
        page_str = string.format("%d;%d;%d;%s", self.curPage, marketStatus, 2, self.sortType or "price")
    end

    return page_str
end

function MarketGoldVendueDlg:getRequestKey()
    if not self.firstClass then return end

    local key = self.firstClass.."__"   -- 珍宝拍卖没有二级菜单，所以 __

    return key
end

function MarketGoldVendueDlg:tradeType()
    return MarketMgr.TradeType.goldType
end

function MarketGoldVendueDlg:bindSecondClassTouchEvent()
end

function MarketGoldVendueDlg:bindMarketCheater()
end

function MarketGoldVendueDlg:defaultSelectCallBack()
    if self.isOpenPay then
        self:onViewButton()
        self.isOpenPay = false
    end
end

function MarketGoldVendueDlg:onDlgOpened(param, data)
    if nil == param[1] then
        return
    end

    self.notQuery = true
    local item = self.leftListCtrl:getChildByName(param[1])
    self:addClassSelcelImage(item)
    self:clickClassList(param[1])
    self.notQuery = false

    self.defaultSelectGid = param[4]

    self.isOpenPay = param[2] ~= ""
end

function MarketGoldVendueDlg:MSG_GOLD_STALL_GOODS_INFO_ITEM(data)
    if not self.selectItemData then return end
    local scoreView = self:getControl("ScoreView")
    local contentner = scoreView:getChildren()[1]
    if contentner then
        local cell = contentner:getChildByName(data.id)
        if cell then
            self:setItemData(cell, self.selectItemData)
        end
    end
end


return MarketGoldVendueDlg
