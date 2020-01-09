-- MarketAuctionDlg.lua
-- Created by songcw Feb/23/2016
-- 拍卖行界面

local MarketAuctionDlg = Singleton("MarketAuctionDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local RewardContainer = require("ctrl/RewardContainer")

local CHECKBOXS = {
    "AuctionCheckBox",
    "MyAuctionCheckBox",
    "MyCollectionCheckBox",
}

function MarketAuctionDlg:init()
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("CollectionButton", self.onCollectionButton)
    self:bindListener("RefreshButton", self.onRefreshButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListViewListener("ItemsListView", self.onSelectItemsListView)
    self:bindListener("MoneyPanel", self.onBuyCash)
    self:bindListener("UnlockButton", self.onUnlockButton)

    -- 单个商品信息panel
    self.unitItemPanel = self:getControl("ItemsUnitPanel1")
    self.unitItemPanel:retain()
    self.unitItemPanel:removeFromParent()

    self.chosenEffectImage = self:getControl("SChosenEffectImage", nil, self.unitItemPanel)
    self.chosenEffectImage:retain()
    self.chosenEffectImage:removeFromParent()
    self.chosenEffectImage:setVisible(true)

    self:setCtrlVisible("ItemsListView", true)

    -- 单选CheckBox
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, CHECKBOXS, self.onCheckBoxClick)

    -- 单选框默认选择第一个
    self.displayType = "AuctionCheckBox"
    self.radioGroup:selectRadio(1, true)
    self:onCheckBoxClick(self:getControl(self.displayType), 1)

    -- 设置金钱
    self:MSG_UPDATE()
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_SYS_AUCTION_GOODS_LIST")
    self:hookMsg("MSG_SYS_AUCTION_UPDATE_GOODS")
    self:hookMsg("MSG_SAFE_LOCK_INFO")

    -- 设置安全锁信息
    self:setSafeLockInfo()

    MarketMgr:queryAuctionGoodsList()

    -- 如果收藏夹中没有物品，读取本地数据
    if not next(MarketMgr.auctionFavoritiesGoods) then MarketMgr:getFavoritiesGoodsGid() end
end

function MarketAuctionDlg:setSafeLockInfo()
    if SafeLockMgr:isNeedUnLock() then -- 需要解锁
        self:setCtrlVisible("UnlockButton", true)
        self:setCtrlVisible("BuyButton", false)
    else
        self:setCtrlVisible("UnlockButton", false)
        self:setCtrlVisible("BuyButton", true)
    end
end

function MarketAuctionDlg:onUnlockButton()
    SafeLockMgr:cmdOpenSafeLockDlg("SafeLockReleaseDlg")
end

function MarketAuctionDlg:MSG_SAFE_LOCK_INFO()
    self:setSafeLockInfo()
end

function MarketAuctionDlg:cleanup()
    self:releaseCloneCtrl("unitItemPanel")
	self:releaseCloneCtrl("chosenEffectImage")
end

function MarketAuctionDlg:getItemName(orgName)
    local name = string.match(orgName, CHS[3002936])
    if name then
        return string.sub(orgName, 1, gf:findStrByByte(orgName, "|") - 1)
    end

    return orgName
end

function MarketAuctionDlg:setItemInfo(info, panel, index)
    self:setImage("SkillImage", ResMgr:getIconPathByName(info.name), panel)
    self:setItemImageSize("SkillImage", panel)
    local imagePanel = self:getControl("ItemImagePanel", nil, panel)
    self:bindTouchEndEventListener(imagePanel, function (self, sender)
        local rect = self:getBoundingBoxInWorldSpace(sender)
        local name = self:getItemName(info.name)
        local item = {}
        item["Icon"] = InventoryMgr:getIconByName(name)
        item.level = info.goodsLevel
        item["name"] = name
        item["extra"] = nil
        item["desc"] = InventoryMgr:getDescript(name)
        item["isGuard"] = InventoryMgr:getIsGuard(name)
        if string.match(info.name, CHS[3002936]) then
            item.upgrade_type = tonumber(gf:split(info.name,"|")[3])
            InventoryMgr:showBasicMessageByItem(item, rect)
        else
            local rewardList = TaskMgr:getRewardList(string.format(CHS[5200019], info.name))            
            
            local rewardInfo = RewardContainer:getRewardInfo(rewardList[1][1])
            
            rewardInfo.basicInfo[1] = rewardInfo.basicInfo[1] .. CHS[4400049] 
            
            local dlg
            if rewardInfo.desc then
                dlg = DlgMgr:openDlg("BonusInfoDlg")
            else
                dlg = DlgMgr:openDlg("BonusInfo2Dlg")
            end
            dlg:setRewardInfo(rewardInfo)
            dlg.root:setAnchorPoint(0, 0)
            dlg:setFloatingFramePos(rect)
        end
    end)

    local name = string.match(info.name, CHS[3002936])
    if name then
        local list = gf:split(name, "|")
        local att = list[1]
        local field = EquipmentMgr:getAttribChsOrEng(att)
        local bai = ""
        if EquipmentMgr:getAttribsTabByName(CHS[3002937])[field] then bai = "%" end

        self:setLabelText("NameLabel", att .. " " .. list[2] .. bai .. "/" .. list[2] .. bai, panel)
    else
        -- 正常不会走到这里
        self:setLabelText("NameLabel", info.name, panel)
    end

    self:setLabelText("LVLabel", info.goodsLevel .. CHS[3002938], panel)

    local price, color = gf:getMoneyDesc(info.price, true)
    self:setLabelText("CashLabel1", price, panel, color)
    self:setLabelText("CashLabel2", price, panel)

    if info.isBided == 1 then
        -- 该商品Me竞价过
        if info.isBidder == 1 then
            self:setLabelText("MyAuctionLabel1", CHS[3002939], panel, COLOR3.TEXT_DEFAULT)
        else
            self:setLabelText("MyAuctionLabel1", CHS[3002940], panel, COLOR3.RED)
        end
    else
        self:setLabelText("MyAuctionLabel1", "", panel)
    end

    local keepTime = info.endTime - gf:getServerTime()
    if keepTime <= 0 then
        self:setLabelText("TimeLabel", CHS[3002941], panel)
    else
        local hTime = keepTime / 3600
        if hTime > 1 then
            -- 大于1小时，显示小时，向上取整
            self:setLabelText("TimeLabel", math.ceil(hTime) .. CHS[3002942], panel)
        else
            -- 小于1小时
            local mTime = (keepTime % 3600) / 60
            self:setLabelText("TimeLabel", math.ceil(mTime) .. CHS[3002943], panel)
        end
    end

    self:setCtrlVisible("BackImage2", index % 2 == 0, panel)
    self:setCtrlVisible("CollectionImage", info.isFavorities, panel)
end

function MarketAuctionDlg:setGoodsInfo(goodsList)
    local list = self:resetListView("ItemsListView", 0, ccui.ListViewGravity.centerVertical)
    for i, info in pairs(goodsList) do
        local panel = self.unitItemPanel:clone()
        panel:setTag(i)
        panel.gid = info.id
        self:setItemInfo(info, panel, i)
        self:bindTouchEndEventListener(panel, self.onChosenPanel)
        list:pushBackCustomItem(panel)

        if self.selectItem and self.selectItem.id == info.id then
            self.chosenEffectImage:removeFromParent()
            panel:addChild(self.chosenEffectImage)
        end
    end
    list:jumpToTop()
end

function MarketAuctionDlg:addOneGoods(data, list)
    local panel = self.unitItemPanel:clone()
    panel:setTag(#list:getItems() + 1)
    panel.gid = data.id
    self:setItemInfo(data, panel, #list:getItems() + 1)
    self:bindTouchEndEventListener(panel, self.onChosenPanel)
    list:pushBackCustomItem(panel)
end

function MarketAuctionDlg:updateOneGoods(data)
    local list = self:getControl("ItemsListView")
    local panels = list:getItems()
    for i, panel in pairs(panels) do
        if self.selectItem and self.selectItem.id == data.id then
            self.selectItem = data
        end

        if panel.gid and panel.gid == data.id then
            panel.gid = data.id
            self:setItemInfo(data, panel, panel:getTag())
        end
    end
end

function MarketAuctionDlg:onChosenPanel(sender, eventType)
    self.chosenEffectImage:removeFromParent()
    sender:addChild(self.chosenEffectImage)
    local goodsList = {}

    if self.radioGroup:getSelectedRadioName() == "AuctionCheckBox" then
        -- 所有拍卖品
        goodsList = MarketMgr:getAuctionGoods()
    elseif self.radioGroup:getSelectedRadioName() == "MyAuctionCheckBox" then
        -- 已竞拍
        goodsList = MarketMgr.auctionMyBidedGoods
    elseif self.radioGroup:getSelectedRadioName() == "MyCollectionCheckBox" then
        -- 收藏夹
        goodsList = MarketMgr.auctionFavoritiesGoods
    end

    self.selectItem = goodsList[sender:getTag()]
    local collectBtn = self:getControl("CollectionButton")
    if self.selectItem.isFavorities then
        self:setLabelText("Label_1", CHS[3002944], collectBtn)
        self:setLabelText("Label_2", CHS[3002944], collectBtn)
    else
        self:setLabelText("Label_1", CHS[3002945], collectBtn)
        self:setLabelText("Label_2", CHS[3002945], collectBtn)
    end
end

function MarketAuctionDlg:onCheckBoxClick(sender, curIdx)
    local goodsList = {}
    if curIdx == 1 then
        goodsList = MarketMgr:getAuctionGoods()
    elseif curIdx == 2 then
        goodsList = MarketMgr.auctionMyBidedGoods
    elseif curIdx == 3 then
        goodsList = MarketMgr:updateFavorities()
    end

    self.selectItem = nil
    self:setGoodsInfo(goodsList)

    self.selectItem = nil
    self:setLabelText("Label_1", CHS[3002945], "CollectionButton")
    self:setLabelText("Label_2", CHS[3002945], "CollectionButton")
end

function MarketAuctionDlg:onBuyCash(sender, eventType)
    gf:showBuyCash()
end

function MarketAuctionDlg:onLeftButton(sender, eventType)
end

function MarketAuctionDlg:onRightButton(sender, eventType)
end

function MarketAuctionDlg:onBuyButton(sender, eventType)
    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    if not DistMgr:checkCrossDist() then return end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if not self.selectItem then
        gf:ShowSmallTips(CHS[3002946])
        return
    end

    if Me:queryBasicInt("level") < 30 then
        gf:ShowSmallTips(CHS[3002948])
        return
    end

    if self.selectItem.price >= 2000000000 then
        gf:ShowSmallTips(CHS[3002949])
        return
    end

    local dlg = DlgMgr:openDlg("MarketAuctionItemDlg")
    dlg:setItemInfo(self.selectItem)
end

function MarketAuctionDlg:onCollectionButton(sender, eventType)
    if not self.selectItem then
        gf:ShowSmallTips(CHS[3002950])
        return
    end

    if self.selectItem.isFavorities then
        -- 取消收藏
        MarketMgr:cancelFavorities(self.selectItem, (self.radioGroup:getSelectedRadioName() ~= "MyCollectionCheckBox"))
        self.selectItem.isFavorities = false
        self:setLabelText("Label_1", CHS[3002945], "CollectionButton")
        self:setLabelText("Label_2", CHS[3002945], "CollectionButton")
        gf:ShowSmallTips(CHS[3002951])
    else
        --收藏
        if #MarketMgr.auctionFavoritiesGoods >= 8 then
            if self.radioGroup:getSelectedRadioName() == "MyCollectionCheckBox" then
                -- 如果在收藏夹界面，这个分支为收藏    刚刚被取消的收藏的商品
            else
                gf:ShowSmallTips(CHS[3002952])
                return
            end
        end
        MarketMgr:writeFavoritiesGoodsGid(self.selectItem)
        self.selectItem.isFavorities = true
        self:setLabelText("Label_1", CHS[3002944], "CollectionButton")
        self:setLabelText("Label_2", CHS[3002944], "CollectionButton")
        gf:ShowSmallTips(CHS[3002953])
    end

    self:updateOneGoods(self.selectItem)
end

function MarketAuctionDlg:onRefreshButton(sender, eventType)
    MarketMgr:queryAuctionGoodsList()
end

function MarketAuctionDlg:onInfoButton(sender, eventType)
    local dlg = DlgMgr:openDlg("MarketRuleDlg")
    dlg:setRuleType("AuctionRulePanel")
end

function MarketAuctionDlg:onSelectItemsListView(sender, eventType)
end

function MarketAuctionDlg:MSG_UPDATE()
    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23)
end

function MarketAuctionDlg:MSG_SYS_AUCTION_UPDATE_GOODS(data)
    self:updateOneGoods(data)
end

function MarketAuctionDlg:MSG_SYS_AUCTION_GOODS_LIST(data)
    if not MarketMgr.auctionGoodsReceiveDone then return end
    local goodsList = MarketMgr:getAuctionGoods()
    if #goodsList == 0 then
        self:setCtrlVisible("ItemsListView", false)
        self:setCtrlVisible("NoticePanel", true)
    else
        self:setCtrlVisible("ItemsListView", true)
        self:setCtrlVisible("NoticePanel", false)
    end

    if self.radioGroup:getSelectedRadioName() == "MyCollectionCheckBox" then
        -- 收藏夹直接刷新
        local favoritiesGoods = MarketMgr.auctionFavoritiesGoods
        self:setGoodsInfo(favoritiesGoods)
        if self.selectItem then
            local isOut = true
            for i = 1, #favoritiesGoods do
                if favoritiesGoods[i].id == self.selectItem.id then
                    isOut = false
                end
            end
            if isOut then self.selectItem = nil end
        end
    elseif self.radioGroup:getSelectedRadioName() == "MyAuctionCheckBox" then
        -- 更新竞拍商品
        local bidedGoods = MarketMgr.auctionMyBidedGoods
        for i = 1, #bidedGoods do
            self:updateOneGoods(goodsList[i])
        end
    elseif self.radioGroup:getSelectedRadioName() == "AuctionCheckBox" then
        goodsList = MarketMgr:getAuctionGoods()
        if gf:getServerTime() < MarketMgr.refreshTime and #self:getControl("ItemsListView"):getItems() == #goodsList then
            for i = 1, #goodsList do
                self:updateOneGoods(goodsList[i])
            end
        else
            self:setGoodsInfo(goodsList)
        end
    end
end

return MarketAuctionDlg
