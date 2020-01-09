-- TradingSpotInfoDlg.lua
-- Created by songcw June/11/2019
-- 商贾货站信息界面

local TradingSpotInfoDlg = Singleton("TradingSpotInfoDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local CheckBox = {
    "BuyInfoCheckBox",
    "AllBuyCheckBox",
}

local CheckBox_Panel = {
    ["BuyInfoCheckBox"] = "MiddlePanel1",
    ["AllBuyCheckBox"] = "MiddlePanel2",
}

function TradingSpotInfoDlg:init()
    self:bindListener("TimeCheckBox", self.onTimeCheckBox)
    self:bindListener("RefreshButton", self.onRefreshButton)
    self:bindListener("SeeButton", self.onSeeButton)
    self:bindListener("TimeSelectButton", self.onTimeSelectButton)

    self:bindListener("SelectListView", self.onSelectPanel)


    self:setValidClickTime("RefreshButton", 10 * 1000, CHS[4300518])

    self:bindFloatPanelListener("SelectPanel")

    self.unitPanel1 = self:retainCtrl("UnitPanel", "MiddlePanel1")
    self:bindListener("ItemImagePanel", self.onHeadPanel, self.unitPanel1)
    self:bindListener("MessagePanel", self.onMessagePanel, self.unitPanel1)

    self.unitPanel2 = self:retainCtrl("UnitPanel", "MiddlePanel2")
    self.selectPanelImage = self:retainCtrl("SChosenEffectImage", "MiddlePanel2")
    self:bindTouchEndEventListener(self.unitPanel2, self.onAllPanel)
    self.seasonPanel = self:retainCtrl("UnitPanel", "SelectPanel")
    self:bindTouchEndEventListener(self.seasonPanel, self.onSeasonButton)

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, CheckBox, self.onCheckBox)
    self.radioGroup:setSetlctByName(CheckBox[1])

    gf:CmdToServer('CMD_TRADING_SPOT_BBS_CATALOG_LIST')
    self.selectCatalog = nil
    self.seasonData = nil
    self.selectCharGid = nil
    self.selectedGoodsId = nil

    local function callback(dlg, percent, list)

        if percent > 100 then
            -- 该请求数据了
            local idx = #list:getItems() + 1
            local curCatalog = string.match(self.selectCatalog, "spot/(.+)" )
            performWithDelay(self.root, function ( )
                gf:CmdToServer("CMD_TRADING_SPOT_LARGE_ORDER_DATA", {trading_no = curCatalog, from = idx, page = 15})
            end, 0.3)
        end
    end


    self:bindListViewByPageLoad("ItemsListView", "TouchPanel", callback, "MiddlePanel1")

    self:hookMsg("MSG_CHAR_INFO_EX")
    self:hookMsg("MSG_OFFLINE_CHAR_INFO")
    self:hookMsg("MSG_TRADING_SPOT_BBS_CATALOG_LIST")
    self:hookMsg("MSG_TRADING_SPOT_GOODS_VOLUME")
    self:hookMsg("MSG_TRADING_SPOT_LARGE_ORDER_DATA")
end


-- 设置期数listView
function TradingSpotInfoDlg:setSeasonListView(data)
    local list = self:resetListView("SelectListView")
    for i = 1, data.count do
        local panel = self.seasonPanel:clone()
        panel.catalog = data.orgKey[i]
        self:setLabelText("Label", data[i], panel)
        list:pushBackCustomItem(panel)
    end
end


function TradingSpotInfoDlg:setUnitBigBuy(data, panel)

    panel.data = data
   -- local timeStr = os.date("%H:%M", data.update_time)  -- 2019-06-11 15:04:50
 --   local timeDestStr = string.format( "%s 第%d期", 123 )
    local timeStr = os.date("%Y-%m-%d %H:%M", data.update_time)
    self:setLabelText("TimeLabel", timeStr, panel)
    self:setImage("ItemImage", ResMgr:getSmallPortrait(data.icon), panel)
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 17, panel)
    self:setLabelText("NameLabel", data.name, panel)

    local itemName, itemInfo = TradingSpotMgr:getItemInfo(data.goods_id)

    local moenyStr = gf:getMoneyDesc(data.cash_cost)

    local str = string.format(CHS[4300515], itemName, moenyStr)
    local mPanel = self:getControl("MessagePanel", nil, panel)
    --self:setColorTextEx(str, mPanel, COLOR3.TEXT_DEFAULT, 19)
    self:setColorText(str, mPanel, nil, 0,0,COLOR3.TEXT_DEFAULT,19)
end

function TradingSpotInfoDlg:setUnitAllBuy(data, panel)
    panel.data = data
    --local timeStr = os.date("%H:%M", data.ti)
    local itemName, itemInfo = TradingSpotMgr:getItemInfo(data.goods_id)

    self:setLabelText("TimeLabel", self:changeTime(self.selectCatalog), panel)

    self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(itemName)), panel)

    self:setLabelText("NameLabel", itemName, panel)

    -- 涨跌
    local rangeDes, rangeColor = TradingSpotMgr:getPriceUpTextInfo(data.chg_ratio)
    self:setLabelText("FloatLabel", rangeDes, panel, rangeColor)

    -- 全服买入总额
    local moenyStr, color = gf:getMoneyDesc(data.open * data.volume, true)
    self:setLabelText("AllPriceLabel", moenyStr, panel, COLOR3.TEXT_DEFAULT)
end



function TradingSpotInfoDlg:onCheckBox(sender, eventType, notResetSeasonList)
    self:resetListView("ItemsListView", 0, nil, "MiddlePanel2")
    self:resetListView("ItemsListView", 0, nil, "MiddlePanel1")
    if not self.selectCatalog then return end

    self.selectedGoodsId = nil
    for checkBoxName, panelName in pairs(CheckBox_Panel) do
        self:setCtrlVisible(panelName, checkBoxName == sender:getName())
    end

    if self.seasonData and not notResetSeasonList then
        self:MSG_TRADING_SPOT_BBS_CATALOG_LIST(self.seasonData)
    end

    local curCatalog = string.match(self.selectCatalog, "spot/(.+)" )
    if sender:getName() == "AllBuyCheckBox" then
        gf:CmdToServer("CMD_TRADING_SPOT_GOODS_VOLUME", {trading_no = curCatalog})

    elseif sender:getName() == "BuyInfoCheckBox" then
        gf:CmdToServer("CMD_TRADING_SPOT_LARGE_ORDER_DATA", {trading_no = curCatalog, from = 1, page = 15})
    end


end

function TradingSpotInfoDlg:onTimeCheckBox(sender, eventType)
end

function TradingSpotInfoDlg:onRefreshButton(sender, eventType)
    local curCatalog = string.match(self.selectCatalog, "spot/(.+)" )
    gf:CmdToServer("CMD_TRADING_SPOT_LARGE_ORDER_DATA", {trading_no = curCatalog, from = 1, page = 15})
end


function TradingSpotInfoDlg:onTimeSelectButton(sender, eventType)
    self:setCtrlVisible("SelectPanel", true)
end

function TradingSpotInfoDlg:onSelectPanel(sender, eventType)
    self:setCtrlVisible("SelectPanel", false)
end


function TradingSpotInfoDlg:onSeeButton(sender, eventType)
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

function TradingSpotInfoDlg:onSelectItemsListView(sender, eventType)
end

function TradingSpotInfoDlg:onSelectSelectListView(sender, eventType)
end

function TradingSpotInfoDlg:onSelectItemsListView(sender, eventType)
end


function TradingSpotInfoDlg:onMessagePanel(sender, eventType)
    if not TradingSpotMgr:isTradingSpotEnable() then
        gf:ShowSmallTips(CHS[7190461])
        return
    end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[7190462])
        return
    end

    self.selectedGoodsId = sender:getParent().data.goods_id

    if not self.selectedGoodsId then
        gf:ShowSmallTips(CHS[7190463])
        return
    end

    -- 打开货品详情界面
    DlgMgr:openDlgEx("TradingSpotItemInfoDlg", TradingSpotMgr:getGoodsInfoById(self.selectedGoodsId))
end

function TradingSpotInfoDlg:onHeadPanel(sender, eventType)
    if not sender:getParent().data then return end
    --FriendMgr:requestCharMenuInfo(sender:getParent().data.gid)
    self.selectCharGid = sender:getParent().data.gid
    FriendMgr:requestCharMenuInfo(sender:getParent().data.gid, nil, nil, 1, nil, sender:getParent().data.dist)
end


function TradingSpotInfoDlg:onAllPanel(sender, eventType)
    self.selectPanelImage:removeFromParent()

    self.selectedGoodsId = sender.data.goods_id

    sender:addChild(self.selectPanelImage)
end

function TradingSpotInfoDlg:onSeasonButton(sender, eventType)
    self.selectCatalog = sender.catalog
   -- TradingSpotMgr:queryBBSList(self.selectCatalog)
    self:setCtrlVisible("SelectPanel", false)
    -- self:resetListView("DiscussListView")

    self:setLabelText("TimeLabel", self:changeTime(self.selectCatalog), "TimeSelectPanel")

    self:onCheckBox(self.radioGroup:getSelectedRadio(), nil, true)
end

function TradingSpotInfoDlg:changeTime(orgStr)
    local key = string.match(orgStr, "spot/(.+)") or orgStr
    local year = string.sub(key, 1, 4)
    local m = string.sub(key, 5, 6)
    local d = string.sub(key, 7, 8)
    local season = string.sub(key, 10, -1)
    local retStr = string.format( CHS[4300516], year, m, d, season)
    return retStr
end

function TradingSpotInfoDlg:MSG_TRADING_SPOT_BBS_CATALOG_LIST(data)
    self.seasonData = data

    if self.radioGroup:getSelectedRadioName() == "BuyInfoCheckBox" then
        local count = math.min( 10, data.count)
        local ret = {count = count}
        ret.orgKey = {}
        for i = 1, data.count do
            local orgStr = data.catalogs[i]
            ret.orgKey[i] = orgStr
            local retStr = self:changeTime(orgStr)
            table.insert( ret, retStr)
        end

        self.selectCatalog = ret.orgKey[1]
        self:setLabelText("TimeLabel", ret[1])
        self:setSeasonListView(ret)
        local curCatalog = string.match(self.selectCatalog, "spot/(.+)" )
        gf:CmdToServer("CMD_TRADING_SPOT_LARGE_ORDER_DATA", {trading_no = curCatalog, from = 1, page = 15})
    elseif self.radioGroup:getSelectedRadioName() == "AllBuyCheckBox" then

        local ret = {}
        ret.orgKey = {}


        if data.count == 1 then
            -- 刚开服没有数据特殊处理
            local count = data.count
            ret.count = count
            for i = 1, data.count do
                local orgStr = data.catalogs[i]
                ret.orgKey[i] = orgStr
                local retStr = self:changeTime(orgStr)
                table.insert( ret, retStr)
            end
        else

            ret.count = 0
            for i = 2, data.count do
                local orgStr = data.catalogs[i]
                ret.orgKey[i - 1] = orgStr
                local retStr = self:changeTime(orgStr)
                table.insert( ret, retStr)
                ret.count = ret.count + 1
            end
        end



        self.selectCatalog = ret.orgKey[1]
        self:setLabelText("TimeLabel", ret[1])
        self:setSeasonListView(ret)
        local curCatalog = string.match(self.selectCatalog, "spot/(.+)" )
        gf:CmdToServer("CMD_TRADING_SPOT_GOODS_VOLUME", {trading_no = curCatalog})
    end
end

function TradingSpotInfoDlg:MSG_TRADING_SPOT_GOODS_VOLUME(data)
    if not self.selectCatalog or not string.match( self.selectCatalog, data.trading_no ) then return end

    table.sort(data.goods_info, function(l, r)
        if l.goods_id < r.goods_id then return true end
        if l.goods_id > r.goods_id then return false end
    end)

    self:setListViewInfoForAllBuy(data)
end

-- 全服买入列表
function TradingSpotInfoDlg:setListViewInfoForAllBuy(data)
    local listView = self:resetListView("ItemsListView", 0, nil, "MiddlePanel2")
    local count = data.count


    local sum = 0
    for i = 1, count do
        sum = data.goods_info[i].volume * data.goods_info[i].open + sum
        local panel = self.unitPanel2:clone()
        self:setUnitAllBuy(data.goods_info[i], panel)

        self:setCtrlVisible("BackImage2", i % 2 == 0, panel)

        listView:pushBackCustomItem(panel)

        if i == 1 then
            self:onAllPanel(panel)
        end
    end
    self:setCtrlVisible("NoticePanel", count == 0, "MiddlePanel2")


    -- 全服买入总额
    local moenyStr, color = gf:getMoneyDesc(sum, true)

    local panel = self:getControl("TotalPanel", nil, "MiddlePanel2")
    self:setLabelText("NumLabel", moenyStr, panel)
end

-- 大额买入列表设置
function TradingSpotInfoDlg:setListViewInfoForBigBuy(data)
    local listView
    if data.from <= 1 then
        listView = self:resetListView("ItemsListView", 0, nil, "MiddlePanel1")
    else
        listView = self:getControl("ItemsListView", nil, "MiddlePanel1")
    end
    if not self.selectCatalog then return end

    self:setLabelText("TimeLabel", self:changeTime(self.selectCatalog), "MiddlePanel1")

    local count = data.count
    for i = 1, count do
        local panel = self.unitPanel1:clone()
        self:setUnitBigBuy(data[i], panel)
        self:setCtrlVisible("BackImage2", #listView:getItems() % 2 == 0, panel)
        listView:pushBackCustomItem(panel)
    end

    self:setCtrlVisible("NoticePanel", #listView:getItems() == 0, "MiddlePanel1")
end

function TradingSpotInfoDlg:MSG_TRADING_SPOT_LARGE_ORDER_DATA(data)
    if not self.selectCatalog or not string.match( self.selectCatalog, data.trading_no ) then return end
    self:setListViewInfoForBigBuy(data)
end

-- 查看名片
function TradingSpotInfoDlg:MSG_CHAR_INFO_EX(data)
    if self.selectCharGid ~= data.gid or data.gid == Me:queryBasic("gid") then return end
    local dlg = DlgMgr:openDlg("CharMenuContentDlg")
    if FriendMgr:isKuafDist(data.dist_name) then
        dlg:setMuneType(CHAR_MUNE_TYPE.KUAFU_BLOG)
    end

    dlg:setting(data.id)
    dlg:setInfo(data)
end

function TradingSpotInfoDlg:MSG_OFFLINE_CHAR_INFO(data)
    if self.selectCharGid ~= data.gid or data.gid == Me:queryBasic("gid") then return end
    gf:ShowSmallTips(CHS[4300517])
end

-- 获取当前列表下一个商品的goods_id
function TradingSpotInfoDlg:getNextGoodsId(goodsId, isLeft)
    local data = TradingSpotMgr:getGoodsListByType(1)   -- 1 : GOODS_LIST_TYPE.ALL_ITEM
    if not data then
        return
    end

    if self.radioGroup:getSelectedRadioName() == "BuyInfoCheckBox" then
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

return TradingSpotInfoDlg
