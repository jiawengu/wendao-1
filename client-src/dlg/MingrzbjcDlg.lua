-- MingrzbjcDlg.lua
-- Created by lixh Mar/05/2018
-- 名人争霸竞猜界面

local MingrzbjcDlg = Singleton("MingrzbjcDlg", Dialog)

-- 队伍成员最大数量
local TEAM_MEMBER_MAX_COUNT = 5

-- 角色icon资源
local ICON_MAP = {
    [6001] = ResMgr.ui.watch_centre_tag1, [7001] = ResMgr.ui.watch_centre_tag6, -- 金 
    [6002] = ResMgr.ui.watch_centre_tag2, [7002] = ResMgr.ui.watch_centre_tag7, -- 木 
    [7003] = ResMgr.ui.watch_centre_tag3, [6003] = ResMgr.ui.watch_centre_tag8, -- 水
    [7004] = ResMgr.ui.watch_centre_tag4, [6004] = ResMgr.ui.watch_centre_tag9, -- 水
    [7005] = ResMgr.ui.watch_centre_tag5, [6005] = ResMgr.ui.watch_centre_tag10, -- 水
}

function MingrzbjcDlg:init()
    self:bindListViewListener("CategoryListView", self.onSelectCategoryListView)
    self.bigPanel = self:retainCtrl("BigPanel")
    self.smallPanel = self:retainCtrl("SmallPanel")
    self.jcPanel1 = self:retainCtrl("MatchPanel_1")
    self.jcPanel2 = self:retainCtrl("MatchPanel_2")

    self:refreshPointsNum()

    self:setCtrlVisible("FinalMatchPanel", false)
    self:setCtrlVisible("MatchListPanel", false)

    local defBigType, defSmallType = MingrzbjcMgr:getScDefaultType()
    self:setScListView(defBigType, defSmallType)

    -- listView分页
    MingrzbjcMgr:bindTouchPanel(self, "TouchPanel", self.tryAddItemToListView)

    self:hookMsg("MSG_CG_DAY_INFO")
    self:hookMsg("MSG_CG_FINAL_MATCH_INFO")
    self:hookMsg("MSG_LOOKON_COMBAT_RECORD_DATA")
end

-- 设置赛程列表
function MingrzbjcDlg:setScListView(showType, subType)
    local listView = self:resetListView("CategoryListView")
    self.curSelectItem = nil

    local bigTypeAll = MingrzbjcMgr:getScBigTypeOrder()
    local smallTypeAll = MingrzbjcMgr:getScSmallTypeOrder()
    local bigTypeList = MingrzbjcMgr:getScBigType()
    local smallTypeMap = MingrzbjcMgr:getScSmallType()
    for i = 1, #bigTypeAll do
        if bigTypeList[bigTypeAll[i]] then
            local bigType = bigTypeAll[i]
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

    if self.curMainType ~= showType then
        self.curMainType = showType
    else
        self.curMainType = nil
    end

    -- 显示选中的赛程数据
    if self.curSelectItem then
        MingrzbjcMgr:fetchScDayInfo(self.curSelectItem:getTag())
    end
end

-- 创建赛程列表中的控件
function MingrzbjcDlg:createScTypeItem(type, isBig, info)
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
function MingrzbjcDlg:setJcListView(day)
    -- 比赛日列表
    local listView = self:resetListView("RankingListView")
    local data = MingrzbjcMgr:getJcDataByDay(day)
    if not data then return end

    -- 记录当前listView的day信息
    self.curDay = day

    local maxAddCount = MingrzbjcMgr:getScListViewAddNum()
    for i = 1, maxAddCount do
        if not data.list[i] then return end

        local item = self:createJcListItem(data.list[i], i)
        listView:pushBackCustomItem(item)
    end
end

-- 尝试给竞猜列表增加item
function MingrzbjcDlg:tryAddItemToListView()
    local day = self.curDay
    local listView = self:getControl('RankingListView', Const.UIListView)
    local data = MingrzbjcMgr:getJcDataByDay(day)
    if not data then return end

    local count = listView:getChildrenCount()
    local tryAddCount = MingrzbjcMgr:getScListViewAddNum()
    local needAddItem = {}
    for i = count + 1, count + tryAddCount do
        if data.list[i] then
            if MingrzbjcMgr:isScNeedShowData(data.list[i]) then
                table.insert(needAddItem, {info = data.list[i], tag = i})
            end
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
function MingrzbjcDlg:createJcListItem(data, i)
    local item = self.jcPanel1
    if i % 2 == 0 then
        item = self.jcPanel2
    end

    item = item:clone()
    self:setJcTeamInfo(data, item)
    return item
end

-- 设置竞猜列表中的队伍信息
function MingrzbjcDlg:setJcTeamInfo(data, item)
    item.competName = data.competName

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
        self:setCtrlVisible("LeftSupportButton_1", data.supportStatus == 0, item)
        self:setCtrlVisible("LeftSupportButton_2", data.supportStatus == 1, item)
        self:setCtrlVisible("LeftSupportButton_3", data.supportStatus == 2, item)

        local button1 = self:getControl("LeftSupportButton_1", nil, item)
        button1.data = {id = data.aTeamId, name = data.aTeamName, supports = data.mySupports,
                day = data.day, competName = data.competName, result = data.supportResult}
        local button2 = self:getControl("LeftSupportButton_2", nil, item)
        button2.data = {id = data.aTeamId, name = data.aTeamName, supports = data.mySupports,
                day = data.day, competName = data.competName, result = data.supportResult}
        local button3 = self:getControl("LeftSupportButton_3", nil, item)
        button3.data = {result = data.supportResult}
        self:bindTouchEndEventListener(button1, self.onTeamSupport1)
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
        self:setCtrlVisible("RightSupportButton_1", data.supportStatus == 0, item)
        self:setCtrlVisible("RightSupportButton_2", data.supportStatus == 2, item)
        self:setCtrlVisible("RightSupportButton_3", data.supportStatus == 1, item)

        local button1 = self:getControl("RightSupportButton_1", nil, item)
        button1.data = {id = data.bTeamId, name = data.bTeamName, supports = data.mySupports,
            day = data.day, competName = data.competName, result = data.supportResult}
        local button2 = self:getControl("RightSupportButton_2", nil, item)
        button2.data = {id = data.bTeamId, name = data.bTeamName, supports = data.mySupports,
            day = data.day, competName = data.competName, result = data.supportResult}
        local button3 = self:getControl("RightSupportButton_3", nil, item)
        button3.data = {result = data.supportResult}
        self:bindTouchEndEventListener(button1, self.onTeamSupport1)
        self:bindTouchEndEventListener(button2, self.onTeamSupport2)
        self:bindTouchEndEventListener(button3, self.onTeamSupport3)
    end

    -- 对比条
    local maxSz = self:getCtrlContentSize("LeftImage", item)
    local rate = data.bTeamSupportNum * 100 / (data.aTeamSupportNum + data.bTeamSupportNum) / 100
    self:setCtrlContentSize("RightImage", maxSz.width * rate, maxSz.height, item)
end

function MingrzbjcDlg:onTeamPanel(sender, eventType)
    -- 打开队伍界面
    local teamId = sender.id
    if teamId then
        MingrzbjcMgr:fetchScTeamInfo(teamId)
    end
end

function MingrzbjcDlg:onTeamSupport1(sender, eventType)
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

function MingrzbjcDlg:onTeamSupport2(sender, eventType)
    self:onTeamSupport1(sender, eventType)
end

function MingrzbjcDlg:onTeamSupport3(sender, eventType)
    if sender.data.result ~= 0 then
        -- 比赛已结束
        gf:ShowSmallTips(CHS[7150064])
        return    
    end

    -- 每场比赛仅可支持一支队伍，无法同时支持比赛双方。
    gf:ShowSmallTips(CHS[7100185])
end

function MingrzbjcDlg:onSelectCategoryListView(sender, eventType)
    local selectItem = self:getListViewSelectedItem(sender)
    local type = selectItem.type
    local day = selectItem:getTag()

    local bigType = MingrzbjcMgr:getScBigType()
    if bigType[type] then
        -- 选中大类，默认选择大类的第一个小类
        self:setScListView(type, type + 1)
    else
        -- 取消已选中小类选中效果
        if self.curSelectItem then 
            self:setCtrlVisible('BackImage_2', false, self.curSelectItem)
        end

        -- 选中当前小类
        self.curSelectItem = selectItem
        self:setCtrlVisible('BackImage_2', true, selectItem)

        MingrzbjcMgr:fetchScDayInfo(day)
    end
end

-- 刷新当前listView中的单个控件
function MingrzbjcDlg:refreshSingleItem(data)
    local listView = self:getControl('RankingListView', Const.UIListView, "MatchListPanel")
    local items = listView:getItems()
    for i = 1, #items do
        if items[i].competName == data.competName then
            self:setJcTeamInfo(data, items[i])
        end
    end

    -- 尝试刷新总决赛
    local finalMatchPanel = self:getControl("MatchPanel", nil, "FinalMatchPanel")
    if finalMatchPanel.competName == data.competName then
        self:setJcTeamInfo(data, finalMatchPanel)
    end
end

-- 刷新支持券，竞猜点数
function MingrzbjcDlg:refreshPointsNum()
    local jcData = MingrzbjcMgr:getJcData()
    if jcData then
        self:setNumImgForPanel("TicketValuePanel", ART_FONT_COLOR.NORMAL_TEXT, 
            jcData.supportCardNum, false, LOCATE_POSITION.MID, 19, "TicketPanel")
        self:setNumImgForPanel("TicketValuePanel", ART_FONT_COLOR.NORMAL_TEXT,
            jcData.jcPoints, false, LOCATE_POSITION.MID, 19, "TicketPanel_1")
    end
end

-- 设置竞猜总决赛信息
function MingrzbjcDlg:setJcFinalInfo(day)
    local root = self:getControl("MatchPanel", nil, "FinalMatchPanel")
    local data = MingrzbjcMgr:getJcDataByDay(day)
    if not data or not data.list[1] then return end

    -- 基本信息调用通用接口
    self:setJcTeamInfo(data.list[1], root)

    -- 额外队伍成员信息，在MSG_CG_FINAL_MATCH_INFO函数中设置
end

function MingrzbjcDlg:cleanup()
    self.curDay = nil
    self.curMainType = nil
    self.curSelectItem = nil
end

-- 某日竞猜数据回来了
function MingrzbjcDlg:MSG_CG_DAY_INFO()
    local day = self.curSelectItem:getTag()

    local titlePanel = "MatchListPanel"
    if MingrzbjcMgr:getScTypeByDay(day) == MINGRZB_JC_BIG_TYPE.FINAL then
        -- -- 策划增加设定：总决赛有单独的Panel显示，其他赛程使用ListView显示
        titlePanel = "FinalMatchPanel"
        self:setJcFinalInfo(day)
        self:setCtrlVisible("FinalMatchPanel", true)
        self:setCtrlVisible("MatchListPanel", false)
    else
        self:setJcListView(day)
        self:setCtrlVisible("FinalMatchPanel", false)
        self:setCtrlVisible("MatchListPanel", true)
    end

    -- 比赛日标题
    local supportStatus = MingrzbjcMgr:getScSupportsStatus(day)
    if supportStatus == MINGRZB_JC_SUPPORTS_STATUS.CAN_GO then
        self:setColorText(string.format(CHS[7100192], gf:getServerDate("%H", MingrzbjcMgr:getDayScTime(day, "start"))),
            "TipsPanel", titlePanel, nil, nil, nil, 19, true)
    elseif supportStatus == MINGRZB_JC_SUPPORTS_STATUS.CAN_NOT_GO then
        self:setColorText(CHS[7100193], "TipsPanel", titlePanel, nil, nil, nil, 19, true)
    elseif supportStatus == MINGRZB_JC_SUPPORTS_STATUS.FUTURE then
        local curEndDate = gf:getServerDate(CHS[7100196], MingrzbjcMgr:getDayScTime(day, "start"))
        self:setColorText(string.format(CHS[7180001], curEndDate), "TipsPanel", "RankingTitlePanel", nil, nil, nil, 19, true)
    else
        local curEndDate = gf:getServerDate(CHS[7100196], MingrzbjcMgr:getDayScTime(day, "start"))
        self:setColorText(string.format(CHS[7100191], curEndDate), "TipsPanel", titlePanel, nil, nil, nil, 19, true)
    end
end

-- 总决赛队伍信息回来了
function MingrzbjcDlg:MSG_CG_FINAL_MATCH_INFO(data)
    local root = self:getControl("MatchPanel", nil, "FinalMatchPanel")

    -- A队信息
    for i = 1, TEAM_MEMBER_MAX_COUNT do
        local info = data.aTeamList[i]
        if info then
            local lPanel = self:getControl("LeftPanel", nil, "MemberPanel_" .. i)
            self:setImage("MemberImage", ICON_MAP[info.icon], lPanel)
            self:setLabelText("NameLabel", info.name, lPanel)
            self:setCtrlVisible("MemberPanel_" .. i, true, root)
        else
            self:setCtrlVisible("MemberPanel_" .. i, false, root)
        end
    end

    -- B队信息
    for i = 1, TEAM_MEMBER_MAX_COUNT do
        local info = data.bTeamList[i]
        if info then
            local lPanel = self:getControl("RightPanel", nil, "MemberPanel_" .. i)
            self:setImage("MemberImage", ICON_MAP[info.icon], lPanel)
            self:setLabelText("NameLabel", info.name, lPanel)
            self:setCtrlVisible("MemberPanel_" .. i, true, root)
        else
            self:setCtrlVisible("MemberPanel_" .. i, false, root)
        end
    end
end

-- 进入观战，关闭界面
function MingrzbjcDlg:MSG_LOOKON_COMBAT_RECORD_DATA()
    self:onCloseButton()
end

return MingrzbjcDlg
