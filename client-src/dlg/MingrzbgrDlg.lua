-- MingrzbgrDlg.lua
-- Created by lixh Mar/05/2018
-- 名人争霸竞猜个人界面

local MingrzbgrDlg = Singleton("MingrzbgrDlg", Dialog)

local PREVIEW_ALL_TAG = 999

function MingrzbgrDlg:init()
    self:bindListViewListener("CategoryListView", self.onSelectCategoryListView)
    self.bigPanel = self:retainCtrl("BigPanel")
    self.smallPanel = self:retainCtrl("SmallPanel")
    self.jcPanel1 = self:retainCtrl("MatchPanel_1")
    self.jcPanel2 = self:retainCtrl("MatchPanel_2")

    -- 请求我的竞猜数据
    MingrzbjcMgr:fetchScMyInfo()

    -- 刷新竞猜点数
    self:refreshPointsNum()

    -- listView分页
    MingrzbjcMgr:bindTouchPanel(self, "TouchPanel", self.tryAddItemToListView)

    self:hookMsg("MSG_CG_MY_GUESS")
    self:hookMsg("MSG_LOOKON_COMBAT_RECORD_DATA")
end

-- 设置赛程列表
function MingrzbgrDlg:setScListView(showType, subType)
    local listView = self:resetListView("CategoryListView")
    self.curSelectItem = nil

    -- 总览
    local allItem = self.bigPanel:clone()
    allItem:setTag(PREVIEW_ALL_TAG)
    allItem.type = PREVIEW_ALL_TAG
    self:setLabelText("Label", CHS[7100187], allItem)
    self:setCtrlVisible("TodayImage", false, allItem)
    listView:pushBackCustomItem(allItem)
    if showType == PREVIEW_ALL_TAG then
        self.curSelectItem = allItem
        self:setCtrlVisible('BackImage_2', true, allItem)
    end

    -- 比赛日列表
    local bigTypeAll = MingrzbjcMgr:getScBigTypeOrder()
    local smallTypeAll = MingrzbjcMgr:getScSmallTypeOrder()
    local bigTypeList = MingrzbjcMgr:getScBigType()
    local smallTypeMap = MingrzbjcMgr:getScSmallType()
    for i = 1, #bigTypeAll do
        if bigTypeList[bigTypeAll[i]] then
            local bigType = bigTypeAll[i]
            if MingrzbjcMgr:getScTypeCanAdd(bigType) then
                -- 个人竞猜页签需要有数据才显示
                local item = self:createScTypeItem(bigType, true, bigTypeList[bigTypeAll[i]])
                if smallTypeMap[bigType] then
                    self:setCtrlVisible('DownArrowImage', true, item)
                end

                listView:pushBackCustomItem(item)
                self:setCtrlVisible('BackImage_2', showType == bigType, item)
                if showType == bigType and self.curMainType ~= bigType then
                    -- 尝试展开新的二级菜单
                    self:setCtrlVisible('DownArrowImage', false, item)
                    self:setCtrlVisible('UpArrowImage', false, item)
                    self.curSelectItem = item
    
                    local subList = smallTypeMap[bigType]
                    if subList then
                        -- 需要显示二级菜单
                        self:setCtrlVisible('UpArrowImage', true, item)
                        for j = 1, #smallTypeAll do
                            if subList[smallTypeAll[j]] then
                                local sType = smallTypeAll[j]
                                if MingrzbjcMgr:getScTypeCanAdd(sType) then
                                    -- 个人竞猜页签需要有数据才显示
                                    local sItem = self:createScTypeItem(sType, false, subList[smallTypeAll[j]])
                                    self:setCtrlVisible('BackImage_2', sType == subType, sItem)
                                    listView:pushBackCustomItem(sItem)
                                    if sType == subType then
                                        self.curSelectItem = sItem
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if self.curMainType ~= showType then
        self.curMainType = showType
    else
        self.curMainType = nil
    end

    -- 显示选中的赛程数据
    if self.curSelectItem then
        self:setJcListView(self.curSelectItem:getTag())
    end
end

-- 创建赛程列表中的控件
function MingrzbgrDlg:createScTypeItem(type, isBig, info)
    local item = self.smallPanel
    if isBig then
        item = self.bigPanel
    end

    item = item:clone()
    if info and info.day then
        item:setTag(info.day)
    end

    item.type = type
    self:setLabelText("Label", MingrzbjcMgr:getScListItemName(type), item)

    self:setCtrlVisible("TodayImage", false, item)

    if info then
        local status = MingrzbjcMgr:getScSupportsStatus(info.day)
        if status ~= MINGRZB_JC_SUPPORTS_STATUS.OVER and status ~= MINGRZB_JC_SUPPORTS_STATUS.FUTURE then
            -- 比赛开始时间与今天是同一天，则显示今日页签标记
            self:setCtrlVisible("TodayImage", true, item)
        end
    end

    return item
end

-- 设置竞猜列表
function MingrzbgrDlg:setJcListView(day)
    -- 对应比赛日标题
    local supportStatus = MingrzbjcMgr:getScSupportsStatus(day)
    if day == PREVIEW_ALL_TAG then
        -- 总览
        self:setColorText(CHS[7120052], "TipsPanel", "RankingTitlePanel", nil, nil, nil, 19, true)
    elseif supportStatus == MINGRZB_JC_SUPPORTS_STATUS.CAN_GO then
        self:setColorText(string.format(CHS[7100192], gf:getServerDate("%H", MingrzbjcMgr:getDayScTime(day, "start"))),
            "TipsPanel", "RankingTitlePanel", nil, nil, nil, 19, true)
    elseif supportStatus == MINGRZB_JC_SUPPORTS_STATUS.CAN_NOT_GO then
        self:setColorText(CHS[7100193], "TipsPanel", "RankingTitlePanel", nil, nil, nil, 19, true)
    elseif supportStatus == MINGRZB_JC_SUPPORTS_STATUS.FUTURE then
        local curEndDate = gf:getServerDate(CHS[7100196], MingrzbjcMgr:getDayScTime(day, "start"))
        self:setColorText(string.format(CHS[7180001], curEndDate), "TipsPanel", "RankingTitlePanel", nil, nil, nil, 19, true)
    else
        local curEndDate = gf:getServerDate(CHS[7100196], MingrzbjcMgr:getDayScTime(day, "start"))
        self:setColorText(string.format(CHS[7100191], curEndDate), "TipsPanel", "RankingTitlePanel", nil, nil, nil, 19, true)
    end

    -- 对应比赛日比赛信息列表
    local listView = self:resetListView("RankingListView")
    local data
    if day == PREVIEW_ALL_TAG then
        data = MingrzbjcMgr:getMyJcData()
    else
        data = MingrzbjcMgr:getMyJcData(day)
    end
    
    if not data then return end

    -- 记录当前listView的day信息
    self.curDay = day

    if #data > 0 then
        self:setCtrlVisible("NoticePanel", false)

        local maxAddCount = MingrzbjcMgr:getScListViewAddNum()
        for i = 1, maxAddCount do
            if not data[i] then return end

            if MingrzbjcMgr:isScNeedShowData(data[i]) then
                local item = self:createJcListItem(data[i], i)
                listView:pushBackCustomItem(item)
            end
        end
    else
        self:setCtrlVisible("NoticePanel", true)
    end
end

-- 尝试给竞猜列表增加item
function MingrzbgrDlg:tryAddItemToListView()
    local day = self.curDay
    local listView = self:getControl('RankingListView', Const.UIListView)
    local data
    if day == PREVIEW_ALL_TAG then
        data = MingrzbjcMgr:getMyJcData()
    else
        data = MingrzbjcMgr:getMyJcData(day)
    end

    if not data then return end

    local count = listView:getChildrenCount()
    local tryAddCount = MingrzbjcMgr:getScListViewAddNum()
    local needAddItem = {}
    for i = count + 1, count + tryAddCount do
        if data[i] then
            table.insert(needAddItem, {info = data[i], tag = i})
        end
    end

    local needAddCount = #needAddItem
    if needAddCount <= 0 then return end

    local itemHeight = self.jcPanel1:getContentSize().height
    local innerContainer = listView:getInnerContainerSize()
    innerContainer.height = (count + needAddCount) * itemHeight
    listView:setInnerContainerSize(innerContainer)

    for i = 1, #needAddItem do
        local item = self:createJcListItem(needAddItem[i].info, needAddItem[i].tag)
        listView:pushBackCustomItem(item)
    end

    MingrzbjcMgr:jumpToItem(listView, itemHeight * count)
    listView:requestRefreshView()
end

-- 创建竞猜列表中的控件
function MingrzbgrDlg:createJcListItem(data, i)
    local item = self.jcPanel1
    if i % 2 == 0 then
        item = self.jcPanel2
    end

    item = item:clone()
    item.competName = data.competName
    self:setJcTeamInfo(data, item)
    return item
end

-- 设置竞猜列表中的队伍信息
function MingrzbgrDlg:setJcTeamInfo(data, item)
    -- A队信息
    if data.aTeamId and data.aTeamId ~= "" then
        -- 队名
        local teamPanel1 = self:getControl("LeftTeamPanel", nil, item)
        teamPanel1.id = data.aTeamId
        self:setLabelText("TeamLabel", data.aTeamName, teamPanel1)
        self:bindTouchEndEventListener(teamPanel1, self.onTeamPanel)

        -- 胜负情况
        if data.supportResult == 1 then
            self:setImage("LeftResultImage", ResMgr.ui.mingrzb_jc_win, item)
        elseif data.supportResult == 2 or data.supportResult == 3 then
            self:setImage("LeftResultImage", ResMgr.ui.mingrzb_jc_lose, item)
        else
            self:setCtrlVisible("LeftResultImage", false, item)
        end

        -- 支持数
        local teamSuport1 = self:getControl("LeftNumberImage", nil, item)
        self:setLabelText("NumberLabel", string.format(CHS[7120051], data.aTeamSupportNum), teamSuport1)

        -- 支持按钮状态
        self:setCtrlVisible("LeftSupportButton_1", false, item)
        self:setCtrlVisible("LeftSupportButton_2", data.supportStatus == 1, item)
        self:setCtrlVisible("LeftSupportButton_3", data.supportStatus == 2, item)

        local button2 = self:getControl("LeftSupportButton_2", nil, item)
        button2.data = {id = data.aTeamId, name = data.aTeamName, supports = data.mySupports,
            day = data.day, competName = data.competName, result = data.supportResult}
        local button3 = self:getControl("LeftSupportButton_3", nil, item)
        button3.data = {result = data.supportResult}
        self:bindTouchEndEventListener(button2, self.onTeamSupport2)
        self:bindTouchEndEventListener(button3, self.onTeamSupport3)
    end

    -- B队信息
    if data.bTeamId and data.bTeamId ~= "" then
        -- 队名
        local teamPanel = self:getControl("RightTeamPanel", nil, item)
        teamPanel.id = data.bTeamId
        self:setLabelText("TeamLabel", data.bTeamName, teamPanel)
        self:bindTouchEndEventListener(teamPanel, self.onTeamPanel)

        -- 胜负情况
        if data.supportResult == 1 or data.supportResult == 3 then
            self:setImage("RightResultImage", ResMgr.ui.mingrzb_jc_lose, item)
        elseif data.supportResult == 2 then
            self:setImage("RightResultImage", ResMgr.ui.mingrzb_jc_win, item)
        else
            self:setCtrlVisible("RightResultImage", false, item)
        end

        -- 支持数
        local teamSuport = self:getControl("RightNumberImage", nil, item)
        self:setLabelText("NumberLabel", string.format(CHS[7120051], data.bTeamSupportNum), teamSuport)

        -- 支持按钮状态
        self:setCtrlVisible("RightSupportButton_1", false, item)
        self:setCtrlVisible("RightSupportButton_2", data.supportStatus == 2, item)
        self:setCtrlVisible("RightSupportButton_3", data.supportStatus == 1, item)

        local button2 = self:getControl("RightSupportButton_2", nil, item)
        button2.data = {id = data.bTeamId, name = data.bTeamName, supports = data.mySupports,
            day = data.day, competName = data.competName, result = data.supportResult}
        local button3 = self:getControl("RightSupportButton_3", nil, item)
        button3.data = {result = data.supportResult}
        self:bindTouchEndEventListener(button2, self.onTeamSupport2)
        self:bindTouchEndEventListener(button3, self.onTeamSupport3)
    end

    -- 对比条
    local maxSz = self:getCtrlContentSize("LeftImage", item)
    local rate = data.bTeamSupportNum * 100 / (data.aTeamSupportNum + data.bTeamSupportNum) / 100
    self:setCtrlContentSize("RightImage", maxSz.width * rate, maxSz.height, item)

    -- 竞猜结果，竞猜收益
    local tipsPanel = self:getControl("TipsPanel", nil, item)
    if data.supportResult == 1 and data.supportStatus == 1 then
        -- 猜A正确
        self:setImage("ResultImage", ResMgr.ui.mingrzb_jc_big_win, item)
        self:setLabelText("NumberLabel", string.format(CHS[7100189], data.mySupports, data.incomes), tipsPanel)
    elseif data.supportResult == 2 and data.supportStatus == 2 then
        -- 猜B正确
        self:setImage("ResultImage", ResMgr.ui.mingrzb_jc_big_win, item)
        self:setLabelText("NumberLabel", string.format(CHS[7100189], data.mySupports, data.incomes), tipsPanel)
    else
        -- 猜错或比赛未结束
        self:setImage("ResultImage", ResMgr.ui.mingrzb_jc_big_lose, item)
        if data.supportResult == 0 then
            self:setLabelText("NumberLabel", CHS[7100188], tipsPanel)
            self:setCtrlVisible("ResultImage", false, item)
        else
            self:setLabelText("NumberLabel", string.format(CHS[7100190], data.mySupports, data.incomes), tipsPanel)
        end
    end
end

function MingrzbgrDlg:onTeamPanel(sender, eventType)
    -- 打开队伍界面
    local teamId = sender.id
    if teamId then
        MingrzbjcMgr:fetchScTeamInfo(teamId)
    end
end

function MingrzbgrDlg:onTeamSupport2(sender, eventType)
    if sender.data.result ~= 0 then
        -- 比赛已结束
        gf:ShowSmallTips(CHS[7150064])
        return    
    end

    local data = sender.data
    local serverTime = gf:getServerTime()
    local supportsEndTime = MingrzbjcMgr:getDayScTime(data.day, "start")
    if serverTime > supportsEndTime then
        -- 比赛已开始
        gf:ShowSmallTips(CHS[7100184])
        return
    end

    -- 打开投票界面
    DlgMgr:openDlgEx("MingrzbtpDlg", data)
end

function MingrzbgrDlg:onTeamSupport3(sender, eventType)
    if sender.data.result ~= 0 then
        -- 比赛已结束
        gf:ShowSmallTips(CHS[7150064])
        return    
    end

    -- 每场比赛仅可支持一支队伍，无法同时支持比赛双方。
    gf:ShowSmallTips(CHS[7100185])
end

function MingrzbgrDlg:onSelectCategoryListView(sender, eventType)
    local selectItem = self:getListViewSelectedItem(sender)
    local type = selectItem.type
    local day = selectItem:getTag()

    local bigType = MingrzbjcMgr:getScBigType()
    if bigType[type] or type == PREVIEW_ALL_TAG then
        -- 选中大类，默认选择大类的第一个小类
        self:setScListView(type, self:getScDefaultSmallType(type) or type + 1)
    else
        -- 取消已选中类别选中效果:与竞猜主界面不同，因为这里有个总览
        if self.curSelectItem then 
            self:setCtrlVisible('BackImage_2', false, self.curSelectItem)
        end

        -- 选中当前小类
        self.curSelectItem = selectItem
        self:setCtrlVisible('BackImage_2', true, selectItem)

        self:setJcListView(day)
    end
end

-- 获取大类默认选中的小类(个人竞猜数据，不一定每一天都有，与主界面不同)
function MingrzbgrDlg:getScDefaultSmallType(bigType)
    local smallTypeAll = MingrzbjcMgr:getScSmallTypeOrder()
    for i = 1, #smallTypeAll do
        local smallType = smallTypeAll[i]
        if MingrzbjcMgr:getBigType(smallType) == bigType and MingrzbjcMgr:getScTypeCanAdd(smallType) then
            return smallType
        end
    end
end

-- 刷新当前listView中的单个控件
function MingrzbgrDlg:refreshSingleItem(data)
    local listView = self:getControl('RankingListView', Const.UIListView, "MatchListPanel")
    local items = listView:getItems()
    for i = 1, #items do
        if items[i].competName == data.competName then
            self:setJcTeamInfo(data, items[i])
        end
    end
end

-- 刷新支持券，竞猜点数
function MingrzbgrDlg:refreshPointsNum()
    local jcData = MingrzbjcMgr:getJcData()
    if jcData then
        self:setNumImgForPanel("TicketValuePanel", ART_FONT_COLOR.NORMAL_TEXT, 
            jcData.supportCardNum, false, LOCATE_POSITION.MID, 19, "TicketPanel")
        self:setNumImgForPanel("TicketValuePanel", ART_FONT_COLOR.NORMAL_TEXT,
            jcData.jcPoints, false, LOCATE_POSITION.MID, 19, "TicketPanel_1")
    end
end

function MingrzbgrDlg:cleanup()
    self.curDay = nil
    self.curMainType = nil
    self.curSelectItem = nil
end

-- 我的竞猜数据回来了，默认选择总览
function MingrzbgrDlg:MSG_CG_MY_GUESS(data)
    self:setScListView(PREVIEW_ALL_TAG, 0)
end

-- 进入观战，关闭界面
function MingrzbgrDlg:MSG_LOOKON_COMBAT_RECORD_DATA()
    self:onCloseButton()
end

return MingrzbgrDlg

