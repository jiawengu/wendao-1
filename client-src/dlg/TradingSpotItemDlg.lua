-- TradingSpotItemDlg.lua
-- Created by lixh Des/26/2018
-- 商贾货站主界面

local TradingSpotItemDlg = Singleton("TradingSpotItemDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

-- 界面数据类型
local DLG_DATA_TYPE = TradingSpotMgr:getGoodsListTypeCfg()

-- 交易类型
local TRADING_STATUS = TradingSpotMgr:getTradingStatusCfg()

function TradingSpotItemDlg:init(dlgType)
    self:bindListener("SeeButton", self.onSeeButton)
    self:bindListener("CollectionButton", self.onCollectionButton)
    self:bindListener("InfoButton", self.onInfoButton)

    self.listView = self:getControl("ItemsListView")
    self.selectEffect = self:retainCtrl("SChosenEffectImage")
    self.itemPanel = self:retainCtrl("ItemsUnitPanel")

    self.dlgType = nil
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, { "AllItemCheckBox", "MyItemCheckBox", "MyCollectionCheckBox" }, self.onTypeCheckBox)
    self:selectRadio(dlgType or DLG_DATA_TYPE.ALL_ITEM)

    self:bindListViewListener("ItemsListView", self.onSelectItemsListView)

    self:refreshRestTimeDes()

    self.scheduleId = self:startSchedule(function()
        local closeTradingTime = TradingSpotMgr:getTradingCloseTime()
        if closeTradingTime < gf:getServerTime() and not self.closeSpotRequest then
            -- 结算时间到，请求刷新数据
            TradingSpotMgr:requestMainSpotData(DLG_DATA_TYPE.ALL_ITEM)
            self.closeSpotRequest = true
        end
    end, 3)
end

-- 选择菜单
function TradingSpotItemDlg:selectRadio(type)
    if self.radioGroup then
        self.radioGroup:selectRadio(type)
    end
end

-- 设置界面数据
function TradingSpotItemDlg:refreshDlgData()
    local dlgData = TradingSpotMgr:getGoodsListByType(self.dlgType)
    local count = #dlgData

    self.listView:removeAllItems()

    -- 设置数据
    for i = 1, count do
        local itemPanel = self.itemPanel:clone()
        self:setSingleItemInfo(itemPanel, dlgData[i])

        self:setCtrlVisible("BackImage1", i % 2 ~= 0, itemPanel)
        self:setCtrlVisible("BackImage2", i % 2 == 0, itemPanel)

        self.listView:pushBackCustomItem(itemPanel)
    end

    local noticePanel = self:getControl("NoticePanel")
    if count > 0 then
        if self.selectedGoodsId then
            if self.needOpenGoodsDetail then
                self:selectItemById(self.selectedGoodsId, true)
                self.needOpenGoodsDetail = nil
            else
                self:selectItemById(self.selectedGoodsId)
            end
        else
            -- 默认选择第1项
            self:setSelectItem(self.listView:getItems()[1])
        end

        self:setCtrlVisible("ListPanel", true)
        noticePanel:setVisible(false)
    else
        -- 显示莲花姑娘
        noticePanel:setVisible(true)
        self:setCtrlVisible("ListPanel", false)
        if self.dlgType == DLG_DATA_TYPE.MY_ITEM then
            self:setCtrlVisible("InfoPanel1", true, noticePanel)
            self:setCtrlVisible("InfoPanel2", false, noticePanel)
        elseif self.dlgType == DLG_DATA_TYPE.COLLECTION then
            self:setCtrlVisible("InfoPanel1", false, noticePanel)
            self:setCtrlVisible("InfoPanel2", true, noticePanel)
        end
    end

    -- 刷新休市，收市时间
    self:refreshRestTimeDes()
end

-- 刷新休市，收市时间
function TradingSpotItemDlg:refreshRestTimeDes()
    if TradingSpotMgr:isInRestTime() then
        -- 处于休市状态
        self:setCtrlVisible("TipsLabel1", false)
        self:setCtrlVisible("TipsLabel2", true)
    else
        -- 刷新距离收市的时间
        self:setCtrlVisible("TipsLabel1", false)
        self:setCtrlVisible("TipsLabel2", false)
        local closeTradingTime = TradingSpotMgr:getTradingCloseTime()
        if closeTradingTime then
            local leftTime = closeTradingTime - gf:getServerTime()
            if leftTime > 0 then
                self:setCtrlVisible("TipsLabel1", true)
                local hour = math.floor(leftTime / 3600)
                local minute = math.ceil(leftTime % 3600 / 60)
                if hour > 0 then
                    self:setLabelText("TipsLabel1", string.format(CHS[7190455], hour, minute))
                else
                    self:setLabelText("TipsLabel1", string.format(CHS[7190482], minute))
                end
            end
        end

        if self.closeSpotRequest then
            -- 收市之后，又重新开市了，重置请求数据标记
            self.closeSpotRequest = false
        end
    end

    -- 每隔1分钟刷新一次休市、收市时间
    if self.refreshTimeAction then self.root:stopAction(self.refreshTimeAction) end
    self.refreshTimeAction = performWithDelay(self.root, function()
        self:refreshRestTimeDes()
        self.refreshTimeAction = nil
    end, 60)
end

-- 设置单个item数据
function TradingSpotItemDlg:setSingleItemInfo(panel, info)
    local itemName, itemInfo = TradingSpotMgr:getItemInfo(info.goods_id)
    if not itemName or not itemInfo then return end

    -- 图标
    self:setImage("ItemImage", ResMgr:getItemIconPath(itemInfo.icon), panel)

    -- 名称, 单价，涨幅
    if info.status == TRADING_STATUS.HALT then
        -- 停市状态
        self:setLabelText("NameLabel", itemName, panel, COLOR3.GRAY)
        self:setLabelText("PriceLabel", CHS[7190454], panel, COLOR3.GRAY)
        self:setLabelText("FloatLabel", "0.00%", panel, COLOR3.TEXT_DEFAULT)
    else
        self:setLabelText("NameLabel", itemName, panel, COLOR3.TEXT_DEFAULT)

        local priceDes, _ = gf:getMoneyDesc(math.floor(info.price), true)
        self:setLabelText("PriceLabel", priceDes, panel, COLOR3.TEXT_DEFAULT)

        local valueStr, desColor = TradingSpotMgr:getPriceUpTextInfo(info.last_range)
        self:setLabelText("FloatLabel", valueStr, panel, desColor)
    end

    -- 持有数量, 持有总额
    if info.volume > 0 then
        local volumeDes, _ = gf:getMoneyDesc(math.floor(info.volume), true)
        self:setLabelText("NumLabel", volumeDes, panel)

        local allPriceDes, _ = gf:getMoneyDesc(math.floor(info.all_price), true)
        self:setLabelText("AllPriceLabel", allPriceDes, panel)
    else
        self:setLabelText("NumLabel", "", panel)
        self:setLabelText("AllPriceLabel", "", panel)
    end

    -- 是否收藏
    self:setCtrlVisible("CollectionImage1", not info.is_collected, panel)
    self:setCtrlVisible("CollectionImage2", info.is_collected, panel)

    -- 响应收藏事件
    self:bindListener("CollectionImage1", self.onCollectionButton, panel)
    self:bindListener("CollectionImage2", self.onCollectionButton, panel)

    -- 设置标记
    panel.info = info
end

-- 刷新控件数据
function TradingSpotItemDlg:refreshItemInfo(info)
    local items = self.listView:getItems()
    for i = 1, #items do
        if items[i].info and items[i].info.goods_id == info.goods_id then
            self:setSingleItemInfo(items[i], info)

            if items[i].info.goods_id == self.selectedGoodsId then
                self:setSelectItem(items[i])
            end
        end
    end
end

-- 设置选中
function TradingSpotItemDlg:setSelectItem(panel)
    if self.selectEffect:getParent() then
        self.selectEffect:removeFromParent()
    end

    panel:addChild(self.selectEffect)
    self.selectedGoodsId = panel.info.goods_id

    local collectionBtn = self:getControl("CollectionButton")
    if panel.info and panel.info.is_collected then
        -- 显示取消收藏
        self:setLabelText("Label_1", CHS[7190457], collectionBtn)
        self:setLabelText("Label_2", CHS[7190457], collectionBtn)
    else
        -- 显示收藏
        self:setLabelText("Label_1", CHS[7190456], collectionBtn)
        self:setLabelText("Label_2", CHS[7190456], collectionBtn)
    end
end

function TradingSpotItemDlg:selectItemById(goodsId, openDetails)
    local items = self.listView:getItems()
    for i = 1, #items do
        if items[i].info and items[i].info.goods_id == goodsId then
            self:setSelectItem(items[i])

            if openDetails then
                -- 打开货品详情界面
                DlgMgr:openDlgEx("TradingSpotItemInfoDlg", items[i].info)
            end

            return
        end
    end
end

-- 获取当前列表下一个商品的goods_id
function TradingSpotItemDlg:getNextGoodsId(goodsId, isLeft)
    local data = TradingSpotMgr:getGoodsListByType(self.dlgType)
    if not data then
        return
    end

    for i = 1, #data do
        if data[i].goods_id == goodsId then
            if isLeft then
                if data[i - 1] then
                    return data[i - 1].goods_id
                end
            else
                if data[i + 1] then
                    return data[i + 1].goods_id
                end
            end

            break
        end
    end
end

function TradingSpotItemDlg:cleanup()
    self.dlgType = nil
    self.selectedGoodsId = nil
    self.needOpenGoodsDetail = nil
    self.closeSpotRequest = nil

    if self.scheduleId then
        self:stopSchedule(self.scheduleId)
        self.scheduleId = nil
    end
end

function TradingSpotItemDlg:onSelectItemsListView(sender, eventType)
    local item = self:getListViewSelectedItem(sender)
    if not item then return end

    -- 选中
    self:setSelectItem(item)
end

-- 切换界面数据：所有货品，我的货品，我的收藏
function TradingSpotItemDlg:onTypeCheckBox(sender, eventType)
    local name = sender:getName()
    local dlgType
    if name == "AllItemCheckBox" then
        dlgType = DLG_DATA_TYPE.ALL_ITEM
    elseif name == "MyItemCheckBox" then
        dlgType = DLG_DATA_TYPE.MY_ITEM
    elseif name == "MyCollectionCheckBox" then
        dlgType = DLG_DATA_TYPE.COLLECTION
    end

    if self.dlgType ~= dlgType then
        -- 请求界面数据
        self.dlgType = dlgType
        TradingSpotMgr:requestMainSpotData(self.dlgType)

        -- 切换到不同标签后要清空选中货品id
        self.selectedGoodsId = nil
    end
end

-- 查看
function TradingSpotItemDlg:onSeeButton(sender, eventType)
    if not TradingSpotMgr:isTradingSpotEnable() then
        gf:ShowSmallTips(CHS[7190461])
        return
    end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[7190462])
        return
    end

    if not self.selectedGoodsId then
        gf:ShowSmallTips(CHS[7190463])
        return
    end

    -- 打开货品详情界面
    DlgMgr:openDlgEx("TradingSpotItemInfoDlg", TradingSpotMgr:getGoodsInfoById(self.selectedGoodsId))
end

-- 收藏/取消收藏
function TradingSpotItemDlg:onCollectionButton(sender, eventType)
    if not self.selectedGoodsId then
        gf:ShowSmallTips(CHS[7190458])
        return
    end

    local goodsInfo = TradingSpotMgr:getGoodsInfoById(self.selectedGoodsId)
    if goodsInfo then
        TradingSpotMgr:requestCollectGoods(self.selectedGoodsId, not goodsInfo.is_collected)
    end
end

-- 规则说明
function TradingSpotItemDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("TradingSpotRuleDlg")
end

return TradingSpotItemDlg
