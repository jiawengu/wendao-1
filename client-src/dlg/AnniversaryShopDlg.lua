-- AnniversaryShopDlg.lua
-- Created by huangzz Mar/14/2017
-- 【周年庆】五行商店界面

local AnniversaryShopDlg = Singleton("AnniversaryShopDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

function AnniversaryShopDlg:init()
    self:bindListener("ListUnitMidPanel1", self.onGetItem)
    self:bindListener("PointImage", self.onShowItemInfo, "ListTitlePanel")
    
    local pImg= self:getControl("PointImage", nil,"ListTitlePanel")
    pImg.name = CHS[5400065]
    
    self.itemPanel = self:getControl("ListUnitMidPanel1")
    self.itemPanel:retain()
    self.itemPanel:removeFromParent()
    
    self:showOwnStone()
    
    local activtyStartTime = ActivityMgr:getStartTimeList() or {}
    if not activtyStartTime["activityList"] or not activtyStartTime["activityList"]["zhounianqing_2017_wxsf"] then
        ActivityMgr:CMD_ACTIVITY_LIST()
        self:showEndTime()
    else
        self:showEndTime(activtyStartTime["activityList"]["zhounianqing_2017_wxsf"].endTime)
    end
    
    AnniversaryMgr:wuxingShopRefresh()
    self.znqWXShopGift = AnniversaryMgr.znqWXShopGift or {}
    if self.znqWXShopGift.size and self.znqWXShopGift.size > 0 then
        self:initScrollView(self.znqWXShopGift)
        self:startSchedule(self.znqWXShopGift.refreshTime)
    end
    
    self:hookMsg("MSG_WUXING_SHOP_REFRSH")
    self:hookMsg("MSG_ACTIVITY_LIST")
end

function AnniversaryShopDlg:onGetItem(sender, eventType)
    local item = sender.item
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end
    
    if item.totalNum > 0 and item.totalNum - item.num < 1 then
        gf:ShowSmallTips(CHS[5400056])
        return
    end
    
    local dlg = DlgMgr:openDlg("ChargeStoneBuyItemDlg")
    
    dlg:setDataByItem(item)
    
    --[[
    if item.price > self.ownWXNum then
        gf:ShowSmallTips(CHS[5400057])
        return
    end
    
    
    local cout = InventoryMgr:getCountCanAddToBag(item.name, 1, item.limted)
    if cout < 1 then
        gf:ShowSmallTips(CHS[5400059])
        return
    end

    AnniversaryMgr:wuxingShopExchange(item.name)
    --]]
end

function AnniversaryShopDlg:showOwnStone()
    self.ownWXNum = InventoryMgr:getAmountByName(CHS[5400065]) or 0
    local amountDesc = gf:getArtFontMoneyDesc(self.ownWXNum, true)
    self:setNumImgForPanel("PointValuePanel", ART_FONT_COLOR.DEFAULT, amountDesc, false, LOCATE_POSITION.MID, 23, "ListTitlePanel")
end

function AnniversaryShopDlg:showEndTime(endTime)
    if endTime then
        local endTimeStr = gf:getServerDate(CHS[4300158], tonumber(endTime))
        self:setLabelText("TimeLabel_2", endTimeStr)
    else
        self:setLabelText("TimeLabel_2", "")
    end
end

function AnniversaryShopDlg:initScrollView(data)
    self.scrollView = self:getControl("ItemListScrollView")
    self.scrollView:setBounceEnabled(true)
    self:initScrollViewPanel(data, self.itemPanel, self.setOneItemInfo, self.scrollView, 4, -1, -1, -2, -4)
end

-- 显示物品悬浮框
function AnniversaryShopDlg:onShowItemInfo(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(sender.name, rect, sender.limted)
end

-- 设置每个商品的信息
function AnniversaryShopDlg:setOneItemInfo(cell, data)
    cell.item = data
    local itemPanel = self:getControl("ItemPanel", nil, cell)
    itemPanel.item = data
    
    self:setImage("IconImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(data.name)), cell)
    
    local imgCtrl = self:getControl("IconImage", nil, cell)
    if data["limited"] == 1 then
        InventoryMgr:addLogoBinding(imgCtrl)
    else
        InventoryMgr:removeLogoBinding(imgCtrl)
    end

    local num = data.totalNum - data.num
    --[[ 奖品数量
    if num <= 0 and data.totalNum > 0 then
        self:setNumImgForPanel(imgCtrl, ART_FONT_COLOR.RED, 0, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, cell)
    elseif num > 1 and data.totalNum > 0 then
        self:setNumImgForPanel(imgCtrl, ART_FONT_COLOR.NORMAL_TEXT, num, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, cell)
    else
        imgCtrl:removeChildByTag(999 * LOCATE_POSITION.RIGHT_BOTTOM)
    end]]
    
    -- 限购剩余数量
    if data.totalNum > 0 then
        self:setLabelText("LimitLabel", CHS[5400069] .. num .. "/" .. data.totalNum, cell)
        if num == 0 then
            self:setCtrlVisible("SellOutImage", true, cell)
            gf:grayImageView(imgCtrl)
        else
            self:setCtrlVisible("SellOutImage", false, cell)
            gf:resetImageView(imgCtrl)
        end
    else
        self:setLabelText("LimitLabel", CHS[5400069] .. CHS[3001763], cell)
        self:setCtrlVisible("SellOutImage", false, cell)
        gf:resetImageView(imgCtrl)
    end
    
    -- 价值
    local priceDesc = gf:getArtFontMoneyDesc(data.price, true)
    self:setNumImgForPanel("PointValuePanel", ART_FONT_COLOR.DEFAULT, priceDesc, false, LOCATE_POSITION.CENTER, 23, cell)
    
    local itemPanel = self:getControl("ItemPanel", nil, cell)
    itemPanel.name = data.name
    itemPanel.limted = data.limited == 1 and true or false
    --self:bindTouchEndEventListener(itemPanel, self.onShowItemInfo)
    self:blindLongPress(itemPanel, self.onShowItemInfo, self.onGetItem)
end

function AnniversaryShopDlg:updateItemInfo(data)
    local cou = #data
    local contentLayer = self.scrollView:getChildByTag(cou * 99)
    for i = 1, cou do
        local cell = contentLayer:getChildByTag(i)
        self:setOneItemInfo(cell, data[i])
    end
end

function AnniversaryShopDlg:MSG_WUXING_SHOP_REFRSH(data)
    if data.size == 0 then
        self:stopSchedule()
        if self.scrollView then
            self.scrollView:removeAllChildren()
            self.scrollView = nil
        end
        
        return
    end
    
    if self.scrollView then
        -- scrollView 以创建，直接更新 panel
        self.znqWXShopGift = data
        self:updateItemInfo(data)
    else
        self.znqWXShopGift = data
        self:initScrollView(data)
    end
    
    self:showOwnStone()
    self:startSchedule(data.refreshTime)
end

function AnniversaryShopDlg:MSG_ACTIVITY_LIST(data)
    if data["activityList"]["zhounianqing_2017_wxsf"] then
        self:showEndTime(data["activityList"]["zhounianqing_2017_wxsf"].endTime)
    else
        self:showEndTime()
    end
end

-- 显示刷新商品倒计时
function AnniversaryShopDlg:showRefreshTime(time)
    local hour = math.floor(time / 3600) % 24
    local min = math.floor(time / 60) % 60
    local sec = time % 60
    local timeStr = string.format("%02d:%02d:%02d", hour, min, sec)
    self:setLabelText("TimeLabel_2", timeStr, "ItemListPanel")
end

-- 开启倒计时
function AnniversaryShopDlg:startSchedule(refreshTime)
    self.refreshTime = refreshTime
    self:showRefreshTime(refreshTime - gf:getServerTime())
    
    if not self.schedulId then
        self.schedulId = gf:Schedule(function()
            local time = self.refreshTime - gf:getServerTime()
            
            if time > 0 then
                -- 显示倒计时
                self:showRefreshTime(time)
            else
                -- 请求刷新商店数据
                AnniversaryMgr:wuxingShopRefresh()
                self:showRefreshTime(0)
                self:stopSchedule()
            end
        end, 1)
    end
end

function AnniversaryShopDlg:stopSchedule()
    if self.schedulId then
        gf:Unschedule(self.schedulId)
        self.schedulId = nil
    end
end

function AnniversaryShopDlg:cleanup()
    self:stopSchedule()
    self:releaseCloneCtrl("itemPanel")
    self.scrollView = nil
end

return AnniversaryShopDlg
