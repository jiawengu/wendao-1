-- CallBackDlg.lua
-- Created by songcw
-- 再续前缘

local CallBackDlg = Singleton("CallBackDlg", Dialog)
local PageTag = require('ctrl/PageTag')
-- 纪念宠物列表
local jinianPetList = require(ResMgr:getCfgPath("JinianPetList.lua"))

local PAGE_COUNT = 4

local DISPLAY_PANEL = {
    "MainPanel",
    "CallBackPanel",
    "CallBackMallPanel",
}

local ONE_DAY = 86400
CallBackDlg.RED_DOT_SCALE = 0.65

function CallBackDlg:init()
    self:bindListener("PointButton", self.onPointButton)
    self:bindListener("GoCallBackButton", self.onCallBackButton, "ActivitiesUnitPanel1")
    self:bindListener("GoButton", self.onTeamButton, "ActivitiesUnitPanel2")
    self:bindListener("ReturnButton", self.onReturnButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("GetButton", self.onGetButton)
    self:bindListener("GetButton", self.onGetButton)
    self:bindListener("GetButton", self.onGetButton)

    self:bindListener("BuyButton", self.onBuyButton)

    self:bindSellNumInput()

    self:bindFloatPanelListener("InfoMainPanel")
    self:bindFloatPanelListener("InfoFloatPanel")
    self:setCtrlVisible("LimitTimePanel", false)

    for _, pName in pairs(DISPLAY_PANEL) do
        self:bindListener("ReturnButton", self.onReturnButton, pName)
    end

    self.playerPanel = self:toCloneCtrl("PlayerListPanel1")
    self.scorePanel = self:toCloneCtrl("GoodsPanel")
    self.selectScoreEffImage = self:toCloneCtrl("ChosenEffectImage", self.scorePanel)

    self.separatedImage = self:toCloneCtrl("BKImage", "CallBackPanel")

    self:bindTouchEndEventListener(self.scorePanel, self.onScorePanel)

    self.scoreItemCount = 1
    self.scoreItem = nil
    self.continuousTimes = 0
    self.clickNum = 0
    self.callRecordData = {}
    self.callData = {}
    self.zhaohuiLock = nil -- 防止重复刷新
    self.isRefreashForScoreShop = false -- 为true则刷新
    self.delayData = nil

    self:bindPressForIntervalCallback('ReduceButton', 0.1, self.onSubOrAddNum, 'times')
    self:bindPressForIntervalCallback('AddButton', 0.1, self.onSubOrAddNum, 'times')


    self:setDisplay("MainPanel")
    self:updateScoreCount()

    -- 广告page
    self:initPageCtrl()

    self:hookMsg("MSG_RECALL_USER_ACTIVITY_DATA")
    self:hookMsg("MSG_RECALL_USER_DATA_LIST")
    self:hookMsg("MSG_RECALLED_USER_DATA_LIST")
    self:hookMsg("MSG_RECALL_SCORE_SHOP_ITEM_LIST")
    self:hookMsg("MSG_RECALL_USER_SUCCESS")

    self:hookMsg("MSG_RECALL_USER_SCORE_DATA")

    -- 界面开启再请求一次，是为了防止，玩家可能在签到等其他界面放了很久再切过来
    GiftMgr:queryCallBackData()

    if self.data then
        self:MSG_RECALL_USER_ACTIVITY_DATA(self.data)
    end

    local delayData = GiftMgr:getCallBackDlgData(1)
    if delayData then
        self:MSG_RECALL_USER_SCORE_DATA(delayData)

        local scoreShopData = GiftMgr:getCallBackDlgData(2)
        if scoreShopData then
            self:MSG_RECALL_SCORE_SHOP_ITEM_LIST(scoreShopData)
        end
    end
end

function CallBackDlg:cleanup()
    self:releaseCloneCtrl("playerPanel")
    self:releaseCloneCtrl("scorePanel")
    self:releaseCloneCtrl("selectScoreEffImage")
    self:releaseCloneCtrl("separatedImage")
end

function CallBackDlg:autoNextPage()
    local pageCtrl = self:getControl("NewsPageView")
    pageCtrl:stopAllActions()

    local delay = cc.DelayTime:create(4)
    local fun = cc.CallFunc:create(function()
        local idx = pageCtrl:getCurPageIndex()
        if idx + 1 < PAGE_COUNT then
            pageCtrl:scrollToPage(idx + 1)
        else
            pageCtrl:scrollToPage(0)
        end
    end)
    pageCtrl:runAction(cc.Sequence:create(delay, fun))
end

-- 初始化主界面的广告page
function CallBackDlg:initPageCtrl()
    -- 绑定分页控件和分页标签
    local pageTagPanel = self:getControl("PageDotPanel")
    local pageTag = PageTag.new(PAGE_COUNT, 2, 20, 1)
    local tagPanelSz = pageTagPanel:getContentSize()
    pageTag:ignoreAnchorPointForPosition(false)
    pageTag:setAnchorPoint(0.5, 0)
    pageTag:setPosition(tagPanelSz.width / 2 + 20, -8)
    pageTagPanel:addChild(pageTag)

    local pageCtrl = self:getControl("NewsPageView")
    self:bindPageViewAndPageTag(pageCtrl, pageTag, self.autoNextPage)
    pageTag:setPage(1)
    self:autoNextPage()
    local panel = self:getControl("MoveTouchPanel")
    self.isAuto = false
    gf:bindTouchListener(panel, function(touch, event)
        local pos = touch:getLocation()
        local rect = self:getBoundingBoxInWorldSpace(panel)
        local eventCode = event:getEventCode()

        local pageCtrl = self:getControl("NewsPageView")
        if eventCode == cc.EventCode.BEGAN then
            if cc.rectContainsPoint(rect, pos) then
                self.isAuto = true
                pageCtrl:stopAllActions()
            end
        elseif eventCode == cc.EventCode.MOVED then
            if self.isAuto then
                pageCtrl:stopAllActions()
            end
        elseif eventCode == cc.EventCode.ENDED then

            if self.isAuto then
                self:autoNextPage()
                self.isAuto = false
            end
        else
            if self.isAuto then
                self:autoNextPage()
                self.isAuto = false
            end
        end

        -- 需要往后传递
        return true
    end, {
        cc.Handler.EVENT_TOUCH_BEGAN,
        cc.Handler.EVENT_TOUCH_MOVED,
        cc.Handler.EVENT_TOUCH_ENDED
    }, true)
end

function CallBackDlg:setDisplay(panelName)
    for _, pName in pairs(DISPLAY_PANEL) do
        self:setCtrlVisible(pName, pName == panelName)
    end
end

function CallBackDlg:setUnitPlayerPanel(data, panel)
    if not data then
        panel:setVisible(false)
        return
    end


    self:setCtrlVisible("BackLabel_0", false, panel)
    self:setCtrlVisible("TimePanel", false, panel)
    self:setCtrlVisible("GetButton", false, panel)

    panel.data = data

    self:setImage("BackImage2", ResMgr:getSmallPortrait(data.icon), panel)

    -- 人物等级使用带描边的数字图片显示
    self:setNumImgForPanel("PortraitPanel1", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)


    self:setLabelText("NameLabel", data.name, panel)

    if data.has_recall then
        self:setCtrlVisible("GetButton", data.has_recall == 0, panel)
        self:setCtrlVisible("BackLabel_0", data.has_recall == 1, panel)
    end

    if data.recalled_time then
        self:setCtrlVisible("BackLabel_0", data.recalled_time == 0, panel)
        if data.recalled_time ~= 0 then
            self:setCtrlVisible("TimePanel", true, panel)
            self:setLabelText("TimeLabel_1", gf:getServerDate(CHS[4300031], data.recalled_time), panel)
        end
    end

    self:bindListener("GetButton", self.onCallBackPlayerButton, panel)
end

function CallBackDlg:setUnitListPanel(row, data, panel)
    local panel1 = self:getControl("PlayerListUnitPanel1", nil, panel)
    self:setUnitPlayerPanel(data[(row - 1) * 3 + 1], panel1)

    local panel2 = self:getControl("PlayerListUnitPanel2", nil, panel)
    self:setUnitPlayerPanel(data[(row - 1) * 3 + 2], panel2)

    local panel3 = self:getControl("PlayerListUnitPanel3", nil, panel)
    self:setUnitPlayerPanel(data[(row - 1) * 3 + 3], panel3)
end

function CallBackDlg:setCallBackPlayers()
    local listview = self:resetListView("PlayerListView", 3)

    -- 没有数据时，问道女神，莲花姑娘
    local hasCallData = (next(self.callData) and self.callData.count ~= 0)
    local hasCallRecordData = (next(self.callRecordData) and self.callRecordData.count ~= 0)

    if not hasCallData and not hasCallRecordData then
        self:setCtrlVisible("NoticePanel", true)
        return
    else
        self:setCtrlVisible("NoticePanel", false)
    end

    if next(self.callData) and self.callData.count ~= 0 then
        local row = math.ceil(self.callData.count / 3)
        for i = 1, row do
            local panel = self.playerPanel:clone()
            self:setUnitListPanel(i, self.callData, panel)
            listview:pushBackCustomItem(panel)
        end
    end

    if next(self.callRecordData) and self.callRecordData.count ~= 0 then
        local relData = {count = 0}
        for i = 1, self.callRecordData.count do
            local isExsit = false
            -- 正常情况下，有历史数据，
            if next(self.callData) and self.callData.count ~= 0 then
                for j = 1, self.callData.count do
                    if self.callRecordData[i].name == self.callData[j].name then
                        isExsit = true
    end
                end
            end

            if not isExsit then
                relData.count = relData.count + 1
                relData[relData.count] = self.callRecordData[i]
            end
        end

        if relData.count ~= 0 then
            local sp = self.separatedImage:clone()
            listview:pushBackCustomItem(sp)
        end

        local row = math.ceil(relData.count / 3)
        for i = 1, row do
            local panel = self.playerPanel:clone()
            self:setUnitListPanel(i, relData, panel)
            listview:pushBackCustomItem(panel)
        end
    end
end


-- 活动结束判断
function CallBackDlg:isEndOfZaixqy(data)

    if not data then data = self.data end

    if not data then return true end

    local curTime = gf:getServerTime()

    if curTime > data.end_time then
        gf:ShowSmallTips(CHS[4200331])
        ChatMgr:sendMiscMsg(CHS[4200331])
        self:onCloseButton()
        return true
    end

    return false
end

-- 召回某个玩家
function CallBackDlg:onCallBackPlayerButton(sender, eventType)
    if not self.data then return end
    local data = sender:getParent().data

    if self:isEndOfZaixqy() then
        return
    end

    -- 等级判断
    if Me:queryInt("level") < 70 then
        gf:ShowSmallTips(CHS[4200319])
        return
    end

    if self.data.today_recall_times >= 5 then
        gf:ShowSmallTips(CHS[4200320])
        return
    end

    GiftMgr:callBackPlayerByGid(data.gid)
end

function CallBackDlg:onPointButton(sender, eventType)
    if not self.data then return end
    local data = sender:getParent().data

    if self:isEndOfZaixqy() then
        return
    end

    -- 等级判断
    if Me:queryInt("level") < 70 then
        gf:ShowSmallTips(CHS[4200319])
        return
    end
    GiftMgr:queryCallBackShop()
    self:setDisplay("CallBackMallPanel")
end

function CallBackDlg:onCallBackButton(sender, eventType)
    if self:isEndOfZaixqy() then
        return
    end

    -- 等级判断
    if Me:queryInt("level") < 70 then
        gf:ShowSmallTips(CHS[4200319])
        return
    end

    self.zhaohuiLock = false

    GiftMgr:queryCallBackPlayersData()
    self:setDisplay("CallBackPanel")
end

function CallBackDlg:onTeamButton(sender, eventType)
    if self:isEndOfZaixqy() then
        return
    end

    -- 等级判断
    if Me:queryInt("level") < 70 then
        gf:ShowSmallTips(CHS[4200319])
        return
    end

    self:setCtrlVisible("InfoMainPanel", true)
end

function CallBackDlg:onReturnButton(sender, eventType)
    self:setDisplay("MainPanel")
end


function CallBackDlg:onBuyButton(sender, eventType)
    if not self.data and not self.delayData then return end
    local data = self.data or self.delayData
    if self:isEndOfZaixqy(data) then
        return
    end

    -- 等级判断
    if Me:queryInt("level") < 70 then
        gf:ShowSmallTips(CHS[4200319])
        return
    end

    if not self.scoreItem then
        gf:ShowSmallTips(CHS[4200299])  -- 请先选择要购买的商品
        return
    end

    if self.scoreItemCount < 1 then
        gf:ShowSmallTips(CHS[4200302])  -- 购买数量不能小于1
        return
    end

    if self.scoreItem.amount <= 0 then
        gf:ShowSmallTips(CHS[4200308])  -- 该商品库存不足，无法购买
        return
    end

    if self.scoreItem.amount < self.scoreItemCount then
        gf:ShowSmallTips(CHS[4200308])
        return
    end

    local isItem = InventoryMgr:getItemInfoByName(self.scoreItem.name)
    if not isItem then
        if PetMgr:getPetCount() >= PetMgr:getPetMaxCount() then
            gf:ShowSmallTips(CHS[4200336])
            return
        end
    else
        local count = InventoryMgr:getCountCanAddToBag(self.scoreItem.name, self.scoreItemCount, true)
        if count < self.scoreItemCount then
            self.scoreItemCount = self.scoreItemCount - 1
            gf:ShowSmallTips(CHS[4200309])
            return
        end
    end

    local totalPrice = self.scoreItem.price * self.scoreItemCount
    if data.score < totalPrice then
        gf:ShowSmallTips(CHS[4200321])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onBuyButton") then
        return
    end

    local unitStr = InventoryMgr:getUnit(self.scoreItem.name)
    if self.scoreItem == CHS[6000500] or self.scoreItem == CHS[6000497] then
        unitStr = CHS[4200328]
    end

    gf:confirm(string.format(CHS[4200332], totalPrice, self.scoreItemCount, unitStr, self.scoreItem.name), function ()
        local info = string.format("%s_%d", self.scoreItem.index, self.scoreItemCount)
        GiftMgr:buyZhaoHuiShop(info)
    end)

end

function CallBackDlg:onInfoButton(sender, eventType)
    self:setCtrlVisible("InfoFloatPanel", true)

end

function CallBackDlg:onGetButton(sender, eventType)
end

function CallBackDlg:onGetButton(sender, eventType)
end

function CallBackDlg:onGetButton(sender, eventType)
end

function CallBackDlg:onReduceButton(sender, eventType)
end

function CallBackDlg:onAddButton(sender, eventType)
end

function CallBackDlg:setUnitScorePanel(data, panel)
    panel.data = data

    self:setLabelText("GoodsNameLabel", data.name, panel)


    self:setNumImgForPanel("MoneyNumberPanel", ART_FONT_COLOR.NORMAL_TEXT, data.price, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- icon
    if data.portrait then
        self:setImage("GoodsImage", ResMgr:getSmallPortrait(data.portrait), panel)
    else
        self:setImage("GoodsImage", ResMgr:getIconPathByName(data.name), panel)
    end

    self:setLabelText("LeftNumLabel", CHS[4200297] .. data.amount, panel)


    if data.amount <= 0 then
        self:setCtrlEnabled("GoodsImage", false, panel)
    end
    self:setCtrlVisible("SellOutImage", data.amount <= 0, panel)

    local image = self:getControl("GoodsImage", nil, panel)
    image:removeAllChildren()
    if data.bind > 1 then
        InventoryMgr:addLogoTimeLimit(image)
    elseif data.bind == 1 then
        InventoryMgr:addLogoBinding(image)
    end
end

-- 设置积分
function CallBackDlg:setScoreData(data)
    if self.isRefreashForScoreShop then
        local listview = self:getControl("ScoreListView")
        local items = listview:getItems()

        for i, panel in pairs(items) do
            if not data[i] then
                -- 刷新数据，要是没了，需要移除
                panel:removeFromParent()
                self:onScorePanel(items[1])
            else
                self:setUnitScorePanel(data[i], panel)
            end
        end

        listview:requestRefreshView()
    else
        local listview = self:resetListView("ScoreListView", 3)
        for i = 1, data.count do
            local panel = self.scorePanel:clone()
            self:setUnitScorePanel(data[i], panel)
            listview:pushBackCustomItem(panel)
        end

        local panel = self:getControl("CallBackMallPanel")
        self:setCtrlVisible("EmptyPanel", true, panel)
    end
end

-- 点击单个积分兑换项
function CallBackDlg:onScorePanel(sender, eventType)
    self.selectScoreEffImage:removeFromParent()
    sender:addChild(self.selectScoreEffImage)

    if self.scoreItem == sender.data then
        self.clickNum = self.clickNum + 1
        self:onAddButton()
    else
        self.clickNum = 0
        self.scoreItemCount = 1
    end

    self.scoreItem = sender.data

    self:updateScoreCount()

    -- 设置右侧信息
    self:setScoreGoodsInfo(self.scoreItem)
end

-- 设置右侧积分商品信息
function CallBackDlg:setScoreGoodsInfo(data)
    -- 设置右侧信息
    local panel = self:getControl("ZaixqyMallPanel")
    self:setCtrlVisible("EmptyPanel", false, panel)

    -- 名称
    local infoPanel = self:getControl("BuyPanel", nil, panel)
    self:setLabelText("GoodsNameLabel", data.name, infoPanel)

    -- 描述
    local descPanel = self:getControl("DescriptionPanel", nil, infoPanel)
    local desc = InventoryMgr:getDescript(data.name)
    if data.name == CHS[6000500] then
        desc = CHS[4200298]
    end

    -- 如果是2018年周年庆的纪念宠物，需要加上
    local petCard = string.match(data.name, CHS[4101005])
    if petCard and jinianPetList[petCard]then
        self:setCtrlVisible("LimitFestivalPanel", true)
    else
        self:setCtrlVisible("LimitFestivalPanel", false)
    end

    local realHeight = self:setColorText(desc, "DescriptionPanel", infoPanel)
    local size = descPanel:getContentSize()
    descPanel:setContentSize(size.width, size.height)

    -- 刷新listview控件
    local listCtrl = self:getControl("GoodsAttribInfoListView", nil, infoPanel)
    listCtrl:doLayout()
    listCtrl:refreshView()

    -- 限时
    if data.bind > 1 then
        self:setCtrlVisible("LimitTimePanel", true)
        self:setLabelText("LimitTimeLabel2", math.floor(data.bind / ONE_DAY), infoPanel)
    else
        self:setCtrlVisible("LimitTimePanel", false)
    end
end

-- 更新积分商城，选择道具数量
function CallBackDlg:updateScoreCount()
    -- 设置右侧信息
    local panel = self:getControl("ZaixqyMallPanel")

    self:setLabelText("NumberLabel", self.scoreItemCount, panel)
    self:setLabelText("NumberLabel_1", self.scoreItemCount, panel)

    -- 商品总价
    self:updateTotalPrice()
end

function CallBackDlg:continuousTips()
    if self.clickNum == 4 then
        gf:ShowSmallTips(CHS[3002731])
    end
end

-- 更新我的积分
function CallBackDlg:updateMyScore(data)
    local panel = self:getControl("ZaixqyMallPanel")
    self:setNumImgForPanel("GoldValuePanel", ART_FONT_COLOR.NORMAL_TEXT, data.score, false, LOCATE_POSITION.MID, 21, panel)
end

function CallBackDlg:changeScoreCount(changetype)
    if not self.scoreItem then
        gf:ShowSmallTips(CHS[4200299])
        return
    end

    if changetype == "add" then
        self.scoreItemCount = self.scoreItemCount + 1
        if self.scoreItem.name ~= CHS[6000500] then
            local count = InventoryMgr:getCountCanAddToBag(self.scoreItem.name, self.scoreItemCount, true)
            if count < self.scoreItemCount then
                self.scoreItemCount = self.scoreItemCount - 1
                gf:ShowSmallTips(CHS[4200300])
                self:updateScoreCount()
                return
            end
        end

        if self.scoreItem and self.scoreItemCount > self.scoreItem.amount then
            self.scoreItemCount = self.scoreItem.amount
            gf:ShowSmallTips(CHS[4200301])
            self:updateScoreCount()
            return
        end
    elseif changetype == "reduce" then
        self.scoreItemCount = self.scoreItemCount - 1
        if self.scoreItemCount < 1 then
            self.scoreItemCount = 1
            gf:ShowSmallTips(CHS[4200302])
            self:updateScoreCount()
            return
        end
    end

    self:updateScoreCount()
end

function CallBackDlg:onAddButton(sender, eventType)
    if not self.scoreItem then
        gf:ShowSmallTips(CHS[4200299])
        return
    end
    self:changeScoreCount("add")
    self:continuousTips()
end

function CallBackDlg:onReduceButton(sender, eventType)
    if not self.scoreItem then
        gf:ShowSmallTips(CHS[4200299])
        return
    end
    self:changeScoreCount("reduce")
    self.continuousTimes = self.continuousTimes + 1
    self:continuousTips()
end

function CallBackDlg:onSubOrAddNum(ctrlName, times)
    if times == 1 then
        self.needShowSubOrAddTips = true
        self.clickNum = self.clickNum  + 1  -- 点击次数，不包括长按
    elseif self.clickNum < 4 then
        self.clickNum = 0
    end

    if ctrlName == "AddButton" then
        self:onAddButton()
    elseif ctrlName == "ReduceButton" then
        self:onReduceButton()
    end
end

function CallBackDlg:MSG_RECALL_USER_ACTIVITY_DATA(data)
    self.data = data
    local mainPanel = self:getControl("MainPanel")

    -- 活动时间
    local startTimeStr = gf:getServerDate(CHS[5420147], data.start_time)
    local endTimeStr = gf:getServerDate(CHS[5420147], data.end_time)
    self:setLabelText("TitleLabel", string.format(CHS[4200311], startTimeStr, endTimeStr), mainPanel)

    -- 活动时间
    local panel = self:getControl("TimePanel", nil, "CallBackMallPanel")
    local startTimeStr = gf:getServerDate(CHS[5420147], data.start_time)
    local endTimeStr = gf:getServerDate(CHS[5420147], data.end_time)
    self:setLabelText("TitleLabel", string.format(CHS[4200311], startTimeStr, endTimeStr), panel)

    -- 积分
    self:setLabelText("PointLabel", data.score, mainPanel)

    -- 今日召回次数
    local todayTimesPanel = self:getControl("ActivitiesUnitPanel1", nil, mainPanel)
    self:setLabelText("InfoLabel", string.format(CHS[4200322], data.today_recall_times), todayTimesPanel)

    -- 召回界面，今日已召回次数
    local zhaohuiPanel = self:getControl("CallBackPanel")
    self:setLabelText("NoteLabel", string.format(CHS[4200330], data.today_recall_times), zhaohuiPanel)

    -- 今日召回积分
    local todayScorePanel = self:getControl("ActivitiesUnitPanel2", nil, mainPanel)
    self:setLabelText("InfoLabel", string.format(CHS[4200323], data.today_bonus_score), todayScorePanel)

    -- 规则说明中
    --- 成功召回玩家数
    self:setLabelText("Label6", data.total_recall_succ_times, zhaohuiPanel)

    --- 共获得多少积分
    self:setLabelText("Label9", data.total_bonus_score, zhaohuiPanel)
end

function CallBackDlg:MSG_RECALLED_USER_DATA_LIST(data)
    self.callRecordData = data
    if self.zhaohuiLock then
        self:setCallBackPlayers()
    end
    self.zhaohuiLock = true
end

function CallBackDlg:MSG_RECALL_USER_DATA_LIST(data)
    self.callData = data
    if self.zhaohuiLock then
        self:setCallBackPlayers()
    end
    self.zhaohuiLock = true
end

function CallBackDlg:MSG_RECALL_USER_SUCCESS(data)
    local listview = self:getControl("PlayerListView")
    local items = listview:getItems()

    for i, panel in pairs(items) do
        local panel1 = self:getControl("PlayerListUnitPanel1", nil, panel)
        if panel1.data and panel1.data.gid == data.gid then
            self:setCtrlVisible("GetButton", false, panel1)
            self:setCtrlVisible("BackLabel_0", true, panel1)
            return
        end

        local panel2 = self:getControl("PlayerListUnitPanel2", nil, panel)
        if panel2.data and panel2.data.gid == data.gid then
            self:setCtrlVisible("GetButton", false, panel2)
            self:setCtrlVisible("BackLabel_0", true, panel2)
            return
        end

        local panel3 = self:getControl("PlayerListUnitPanel3", nil, panel)
        if panel3.data and panel3.data.gid == data.gid then
            self:setCtrlVisible("GetButton", false, panel3)
            self:setCtrlVisible("BackLabel_0", true, panel3)
            return
        end
    end
end

function CallBackDlg:MSG_RECALL_SCORE_SHOP_ITEM_LIST(data)
    self:setScoreData(data)
    self:updateMyScore(data)
    self.isRefreashForScoreShop = true
end

function CallBackDlg:bindSellNumInput()
    local moneyPanel = self:getControl('NumberValueImage')
    local function openNumIuputDlg()
        if not self.scoreItem then return end
        local rect = self:getBoundingBoxInWorldSpace(moneyPanel)
        self.isStartInput = true
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setObj(self)
        dlg.root:setPosition(rect.x + rect.width /2 , rect.y  + rect.height +  dlg.root:getContentSize().height /2 + 10)

        self.inputNum = 0
        --   self:setCtrlVisible("Label", false, moneyPanel)
    end
    self:bindTouchEndEventListener(moneyPanel, openNumIuputDlg)
end

-- 数字键盘删除数字
function CallBackDlg:deleteNumber()
    self.scoreItemCount = math.floor(self.scoreItemCount / 10)
    self:updateScoreCount()
end

-- 数字键盘清空
function CallBackDlg:deleteAllNumber(key)
    self.scoreItemCount = 0
    self:updateScoreCount()
end

-- 数字键盘插入数字
function CallBackDlg:insertNumber(num)
    if self.isStartInput then
        self.scoreItemCount = 0
        self.isStartInput = false
    end
    if num == "00" then
        self.scoreItemCount = self.scoreItemCount * 100
    elseif num == "0000" then
        self.scoreItemCount = self.scoreItemCount * 10000
    else
        self.scoreItemCount = self.scoreItemCount * 10 + num
    end

    local ret = 0
    if self.scoreItem.name ~= CHS[6000500] then
        local count = InventoryMgr:getCountCanAddToBag(self.scoreItem.name, self.scoreItemCount, true)
        if count < self.scoreItemCount then
            self.scoreItemCount = count
            ret = 1
        end
    end

    if self.scoreItem and self.scoreItemCount > self.scoreItem.amount then
        self.scoreItemCount = self.scoreItem.amount
        ret = 2
    end

    if self.scoreItemCount >= 100 then
        self.scoreItemCount = 100
        ret = 3
    end
    if ret == 1 then
        gf:ShowSmallTips(CHS[4200300])
    elseif ret == 2 then
        gf:ShowSmallTips(CHS[4200301])
    elseif ret == 3 then
        gf:ShowSmallTips(CHS[4200325])
    end
    self:updateScoreCount()
end

function CallBackDlg:updateTotalPrice()
    local buyButton = self:getControl("BuyButton", nil, "MallPanel")
    if self.scoreItem and self.scoreItemCount then
        self:setLabelText("NumLabel", self.scoreItem.price * self.scoreItemCount, buyButton)
        self:setLabelText("NumLabel_1", self.scoreItem.price * self.scoreItemCount, buyButton)
    end
end

function CallBackDlg:MSG_RECALL_USER_SCORE_DATA(data)
    self.delayData = data
    self.data = nil

    self:setDisplay("CallBackMallPanel")

    self:setCtrlVisible("ReturnPanel", false, "CallBackMallPanel")

    local panel = self:getControl("TimePanel", nil, "CallBackMallPanel")

    -- 活动时间
    local startTimeStr = gf:getServerDate(CHS[5420147], data.start_time)
    local endTimeStr = gf:getServerDate(CHS[5420147], data.end_time)
    self:setLabelText("TitleLabel", string.format(CHS[4101108], endTimeStr), panel)
end


return CallBackDlg
