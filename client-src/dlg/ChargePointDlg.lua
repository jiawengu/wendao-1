-- ChargePointDlg.lua
-- Created by huangzz Mar/06/2017
-- 充值积分界面

local ChargePointDlg = Singleton("ChargePointDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

local itemPanels = {}

function ChargePointDlg:init()
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("InfoButton", self.onInfoButton)

    self.listUnitPanel = self:getControl("ListUnitMidPanel1")
    self.listUnitPanel:retain()
    self.listUnitPanel:removeFromParent()

    -- 兑换奖品
    self:bindTouchEndEventListener(self.listUnitPanel, self.onBuyItem)

    -- 奖品名片
    self:blindLongPress("ItemPanel", self.onShowItemInfo, self.onBuyItem, self.listUnitPanel)

    -- 用于隐藏规则说明
    self:bindInfoPanel("InfoPanel")
    self:bindInfoPanel("InfoPanel2")

    self.type = GiftMgr:getPointWelfareType()

    if self.type == "charge" then
        self.chargePointInfo = GiftMgr.chargePointInfo or {}
        if next(self.chargePointInfo) then
            self:initData(self.chargePointInfo)
            self:initScrollView(self.chargePointInfo)
        end

        -- 请求商品信息
        GiftMgr:requestChargePointInfo()
    elseif self.type == "consume" then
        self.consumePointInfo = GiftMgr.consumePointInfo or {}
        if next(self.consumePointInfo) then
            self:initData(self.consumePointInfo)
            self:initScrollView(self.consumePointInfo)
        end

        GiftMgr:requestConsumePointInfo()
    end

    self.curGoldNum = Me:queryInt("gold_coin")

    self:hookMsg("MSG_RECHARGE_SCORE_GOODS_LIST")
    self:hookMsg("MSG_RECHARGE_SCORE_GOODS_INFO")
    self:hookMsg("MSG_CONSUME_SCORE_GOODS_LIST")
    self:hookMsg("MSG_CONSUME_SCORE_GOODS_INFO")
    self:hookMsg("MSG_UPDATE")

    self:showUI()
end

function ChargePointDlg:showUI()
    self:setCtrlVisible("InfoLabelPanel1", self.type == "charge")
    self:setCtrlVisible("InfoLabelPanel2", self.type == "consume")
end

function ChargePointDlg:initData(data)
    -- 累计积分
    local mainPanel
    if self.type == "charge" then
        mainPanel = "InfoPanel"
    elseif self.type == "consume" then
        mainPanel = "InfoPanel2"
    end

    self:setLabelText("Label2", data.totalPoint .. "/3000", self:getControl("TotalPointPanel", nil, mainPanel))

    -- 活动时间
    local curTime = gf:getServerTime()
    if curTime < data.endTime then
        local startTimeStr = gf:getServerDate(CHS[5420147], tonumber(data.startTime))
        local endTimeStr = gf:getServerDate(CHS[5420147], tonumber(data.endTime))
        self:setLabelText("TitleLabel", CHS[5420137] .. startTimeStr .. " - " .. endTimeStr)

        -- 当前积分
        self:setCtrlVisible("AddButton", true)
        self:setCtrlVisible("PointValuePanel", true, "PointPanel")
        self:setCtrlVisible("PointValuePanel2", false, "PointPanel")
        local pointDesc = gf:getArtFontMoneyDesc(data.ownPoint, true)
        self:setNumImgForPanel("PointValuePanel", ART_FONT_COLOR.DEFAULT, pointDesc, false, LOCATE_POSITION.MID, 23, "PointPanel")
    else
        local deadlineStr = gf:getServerDate(CHS[5420147], tonumber(data.deadline))
        self:setLabelText("TitleLabel", CHS[5420138] .. deadlineStr .. " " .. CHS[5420133])

        for i = 1, 2 do
            -- 活动已经结束，但仍然可以兑换奖品
            local mainPanel = self:getControl("InfoLabelPanel" .. i)
            self:setCtrlVisible("InfoLabel1", false, mainPanel)
            self:setCtrlVisible("InfoLabel2", false, mainPanel)
            self:setCtrlVisible("InfoLabel3", false, mainPanel)
            self:setCtrlVisible("InfoLabel4", true, mainPanel)
        end

        -- 当前积分
        self:setCtrlVisible("AddButton", false)
        self:setCtrlVisible("PointValuePanel", false, "PointPanel")
        self:setCtrlVisible("PointValuePanel2", true, "PointPanel")
        local pointDesc = gf:getArtFontMoneyDesc(data.ownPoint, true)
        self:setNumImgForPanel("PointValuePanel2", ART_FONT_COLOR.DEFAULT, pointDesc, false, LOCATE_POSITION.MID, 23, "PointPanel")
    end
end

function ChargePointDlg:initScrollView(data)
    self.scrollView = self:getControl("ItemListScrollView")
    self:initScrollViewPanel(data, self.listUnitPanel, self.setItemInfo, self.scrollView, 4, 0, 0)
end


function ChargePointDlg:onAddButton(sender, eventType)
    if self.type == "charge" then
        OnlineMallMgr:openOnlineMall("OnlineRechargeDlg")
    elseif self.type == "consume" then
        OnlineMallMgr:openOnlineMall("OnlineMallDlg")
    end
end

function ChargePointDlg:onInfoButton(sender, eventType)

    self:setCtrlVisible("InfoPanel", self.type == "charge")
    self:setCtrlVisible("InfoPanel2", self.type == "consume")
end

-- 弹出兑换奖品界面
function ChargePointDlg:onBuyItem(sender, eventType)
    local info
    if self.type == "charge" then
        info = self.chargePointInfo
    elseif self.type == "consume" then
        info = self.consumePointInfo
    end

    local curTime = gf:getServerTime()
    if curTime > info.deadline then
        gf:ShowSmallTips(CHS[5420148])
        ChatMgr:sendMiscMsg(CHS[5420148])
        DlgMgr:closeDlg("ChargePointDlg")
        return
    end

    local tag = sender:getTag()
    local itemInfo = info[tag]
    if not itemInfo then
        -- 可能点击的是其子控件
        local unitPanel = sender:getParent()
        local unitMidPanel = unitPanel:getParent()
        tag = unitMidPanel:getTag()
        itemInfo = info[tag]
    end

    if itemInfo.num == 0 then
        gf:ShowSmallTips(CHS[5420135])
        return
    end

    self.selectTag = tag
    local dlg = DlgMgr:openDlg("ChargePointBuyItemDlg")
    dlg:setData(itemInfo, info.ownPoint, info.deadline)
end

function ChargePointDlg:onShowItemInfo(sender, eventType)
    RewardContainer:imagePanelTouch(sender, 2)
end

-- 设置每个奖品的信息
function ChargePointDlg:setItemInfo(cell, data)
    local itemPanel = self:getControl("ItemPanel", nil, cell)
    local classList = TaskMgr:getRewardList(data.rewardStr)

    itemPanels[cell:getTag()] = cell

    local reward
    if #classList > 0 and classList[1] and classList[1][1] then
        reward = classList[1][1]
        data.reward = reward

        local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
        local item = TaskMgr:spliteItemInfo(itemInfoList, reward)
        data.name = RewardContainer:getTextList(reward)[1]
        data.level = item.level
        data.limted = item.limted
        data.type = reward[1]
    end

    itemPanel.reward = reward


    -- 奖品图标
    local imgPath, textureResType = RewardContainer:getRewardPath(reward)
    if textureResType == ccui.TextureResType.plistType then
        self:setImagePlist("IconImage", imgPath, cell)
    else
        self:setImage("IconImage", imgPath, cell)
    end

    local img = self:getControl("IconImage", nil, cell)
    if data["limted"] then
        InventoryMgr:addLogoBinding(img)
    end

    if data.level and tonumber(data.level) > 1 then
        self:setNumImgForPanel(img, ART_FONT_COLOR.NORMAL_TEXT, tonumber(data.level), false, LOCATE_POSITION.LEFT_TOP, 19, cell)
    end

    data.imgPath = imgPath
    data.textureResType = textureResType

    local num = data.num
    self:setLabelText("NumLabel", CHS[3003274] .. " " .. num, cell)

    -- 告罄
    if num <= 0 then
        self:setCtrlVisible("SellOutImage", true, cell)
        gf:grayImageView(img)
    else
        self:setCtrlVisible("SellOutImage", false, cell)
        gf:resetImageView(img)
    end

    -- 兑换积分
    local pointDesc = gf:getArtFontMoneyDesc(data.point, true)
    self:setNumImgForPanel("PointValuePanel", ART_FONT_COLOR.DEFAULT, pointDesc, false, LOCATE_POSITION.MID, 23, cell)
end

function ChargePointDlg:bindInfoPanel(panelName)
    local panel = self:getControl(panelName)

    local function onTouchBegan(touch, event)
        if not panel:isVisible() then
            return false
        end

        return true
    end

    local function onTouchMove(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
    end

    local function onTouchEnd(touch, event)
        panel:setVisible(false)
    end


    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

-- 获取所有的奖品信息
function ChargePointDlg:MSG_RECHARGE_SCORE_GOODS_LIST(data)

    if self.chargePointInfo and next(self.chargePointInfo) then
         -- 刷新积分、时间
         self:initData(data)
         for i = 1, data.count do
             local cell = itemPanels[i]
             -- 刷新单个奖品
             self:setItemInfo(cell, data[i])
         end
    else
        -- 刷新整个界面，重建scrollView
        self:initData(data)
        self:initScrollView(data)
    end

    self.chargePointInfo = data
end

-- 刷新单个奖品信息
function ChargePointDlg:MSG_RECHARGE_SCORE_GOODS_INFO(data)
    self.chargePointInfo.ownPoint = data.ownPoint
    self.chargePointInfo[data.no] = data

    local cell = itemPanels[data.no]
    self:setItemInfo(cell, data)

    -- 刷新当前积分
    local pointDesc = gf:getArtFontMoneyDesc(data.ownPoint, true)
    self:setNumImgForPanel("PointValuePanel", ART_FONT_COLOR.DEFAULT, pointDesc, false, LOCATE_POSITION.MID, 23, "PointPanel")
    self:setNumImgForPanel("PointValuePanel2", ART_FONT_COLOR.DEFAULT, pointDesc, false, LOCATE_POSITION.MID, 23, "PointPanel")
end

-- 获取所有的消费积分奖品信息
function ChargePointDlg:MSG_CONSUME_SCORE_GOODS_LIST(data)

    if self.consumePointInfo and next(self.consumePointInfo) then
        -- 刷新积分、时间
        self:initData(data)
        for i = 1, data.count do
            local cell = itemPanels[i]
            -- 刷新单个奖品
            self:setItemInfo(cell, data[i])
        end
    else
        -- 刷新整个界面，重建scrollView
        self:initData(data)
        self:initScrollView(data)
    end

    self.consumePointInfo = data
end

-- 刷新单个奖品信息
function ChargePointDlg:MSG_CONSUME_SCORE_GOODS_INFO(data)
    self.consumePointInfo.ownPoint = data.ownPoint
    self.consumePointInfo[data.no] = data

    local cell = itemPanels[data.no]
    self:setItemInfo(cell, data)

    -- 刷新当前积分
    local pointDesc = gf:getArtFontMoneyDesc(data.ownPoint, true)
    self:setNumImgForPanel("PointValuePanel", ART_FONT_COLOR.DEFAULT, pointDesc, false, LOCATE_POSITION.MID, 23, "PointPanel")
    self:setNumImgForPanel("PointValuePanel2", ART_FONT_COLOR.DEFAULT, pointDesc, false, LOCATE_POSITION.MID, 23, "PointPanel")
end

-- 购买/消费元宝，要刷新积分
function ChargePointDlg:MSG_UPDATE(data)
    if data["gold_coin"] and data["gold_coin"] > self.curGoldNum then
        -- 判断元宝是否增加，是则请求消息刷新积分
        self.curGoldNum = data["gold_coin"]
        GiftMgr:requestChargePointInfo()
    elseif data["gold_coin"] and data["gold_coin"] < self.curGoldNum then
        -- 判断金元宝是否减少了，如果减少了请求刷新消费积分
        self.curGoldNum = data["gold_coin"]
        GiftMgr:requestConsumePointInfo()
    end
end

function ChargePointDlg:cleanup()
    self:releaseCloneCtrl("listUnitPanel")
    self.chargePointInfo = {}
end

return ChargePointDlg
