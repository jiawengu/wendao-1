-- TeamQuickDlg.lua
-- Created by liuhb Apr/28/2015
-- 便捷组队

local TeamQuickDlg = Singleton("TeamQuickDlg", Dialog)

local ONE_PAGE_NUM = 8  -- 一页加载的队伍人数

local leftSelectCtrls = {}

local oneActiveAdjustList
local twoActiveAdjustListMap
local activeLevelMap

function TeamQuickDlg:init()
    self:bindListener("CreateButton", self.onCreateButton)
    self:bindListener("RefreshButton", self.onRefreshButton)
    self:bindListener("MatchButton", self.onMatchButton)

    oneActiveAdjustList = TeamMgr:getOneActiveAdjustList()
    twoActiveAdjustListMap = TeamMgr:getTwoActiveAdjustListMap()
    activeLevelMap = TeamMgr:getActiveLevelMap()

    self.lasetRefreshTime = 0
    self.curSelectName = nil

    self:initLeftViewData()
    self:updateLeftViewData()

    self.teamListData = nil
    self:bindTeamListView()

    self:hookMsg("MSG_MATCH_TEAM_LIST")
    self:hookMsg("MSG_MATCH_TEAM_STATE")
end

function TeamQuickDlg:selectItemInit(activeName)
    if activeName then
        local oneName, twoName = self:getOneName(activeName)
        self:selectItemEx(oneName, twoName)
    else
        local matchInfo = TeamMgr:getCurMatchInfo()
        if 1 == matchInfo.state then
            local oneName, twoName = self:getOneName(matchInfo.name)
            self:selectItemEx(oneName, twoName)
        else
            self:selectItemEx(CHS[3003747], "")
        end
    end
end

function TeamQuickDlg:close(now)
    Dialog.close(self, now)

    self.curSelectName = nil
end

-- 更新右下角字段
function TeamQuickDlg:updateLeaderAndMember(leader, member)
    if nil == leader or nil == member then
        return
    end

    local infoLabel = self:getControl("InfoLabel")
    infoLabel:setString(string.format(CHS[5000146], leader, member))
end

function TeamQuickDlg:bindTeamListView()
    self.teamList = self:resetListView("TeamListView", 1)
    local function onScrollView(sender, eventType)
        if self.notCallListView then
            return
        end

        if ccui.ScrollviewEventType.scrolling == eventType
                or ccui.ScrollviewEventType.scrollToTop == eventType
                or ccui.ScrollviewEventType.scrollToBottom == eventType then
            -- 获取控件
            local listViewCtrl = sender
            local listInnerContent = listViewCtrl:getInnerContainer()
            local innerSize = listInnerContent:getContentSize()
            local scrollViewSize = listViewCtrl:getContentSize()

            -- 计算滚动的百分比
            local innerPosY = listInnerContent:getPositionY()
            local totalHeight = innerSize.height - scrollViewSize.height

            Log:D(innerPosY .. "    " .. totalHeight)

            if innerPosY > 10 then
                -- 向下加载
                self:updateTeamList()
            end
        end
    end

    self.teamList:addScrollViewEventListener(onScrollView)
end

-- 更新列表
function TeamQuickDlg:updateTeamList(isReset)
    if not self.teamListData then
        return
    end

    -- 初始化队伍列表
    if isReset then
        self.teamList:removeAllItems()
        self.loadNum = 0
        self:updateTeamListPanel(self.teamListData.count == 0)
    end

    if self.loadNum >= self.teamListData.count then
        return
    end

    for i = 1, ONE_PAGE_NUM do
        local team = self.teamListData.teams[self.loadNum + i]
        if nil ~= team then
            local newOne = self.teamCtrl:clone()
            self:setLabelText("NameLabel", gf:getRealName(team.leaderName), newOne)
            self:setLabelText("LevelLabel", string.format(CHS[3003748], team.leaderLevel), newOne)
            self:setLabelText("TargetLabel", TeamMgr:getShowName(TeamMgr:getNameByType(team.type)), newOne)
            self:setLabelText("PartyLabel", team.party, newOne)

            if nil ~= team.leaderIcon then
                local portrait = ResMgr:getSmallPortrait(team.leaderIcon)
                self:setImage("IconImage", portrait, newOne)
                self:setItemImageSize("IconImage", newOne)
            end
            self:setNumImgForPanel("IconBackImage", ART_FONT_COLOR.NORMAL_TEXT, team.leaderLevel, false, LOCATE_POSITION.LEFT_TOP, 21, newOne)

            local numPanel = self:getControl("NumPanel", nil, newOne)
            for j = 1, 5 do
                self:setCtrlVisible("Image_" .. j, j <= team.memberCount, numPanel)
            end

            local appBtn = self:getControl("ApplyButton", nil, newOne)
            self:bindListener("ApplyButton", function(self, sender, eventType)
                local titleText = sender:getTitleText()
                if titleText == CHS[5000151] then
                    return
                end

                gf:CmdToServer("CMD_REQUEST_JOIN", {
                    peer_name = team.leaderName,
                    ask_type = Const.REQUEST_JOIN_TEAM,
                })

                self:setLabelText("Label1", CHS[3003749], appBtn)
                self:setLabelText("Label2", CHS[3003749], appBtn)

                self:setCtrlEnabled("ApplyButton", false, appBtn)
            end, newOne)

            self.teamList:pushBackCustomItem(newOne)
        end
    end

    self.loadNum = self.loadNum + ONE_PAGE_NUM

    self.notCallListView = true
    self.teamList:requestRefreshView()
    self.teamList:doLayout()
    self.notCallListView = false
end

-- 获取一级二菜单选中光效
function TeamQuickDlg:getOneEffectImgbySecond()
    if nil == self.selectOneAndSec then
        -- 创建选择框
        local img = self:getControl("SelectedPanel", Const.UIImage)
        img:retain()
        img:setVisible(true)
        img:setPosition(0, 0)
        img:setAnchorPoint(0, 0)
        self.selectOneAndSec = img
    end

    self.selectOneAndSec:removeFromParent(false)

    return self.selectOneAndSec
end

function TeamQuickDlg:cleanup()
    self:releaseCloneCtrl("selectOneAndSec")
    self:releaseCloneCtrl("selectOneImg")
    self:releaseCloneCtrl("selectTwoImg")
    self:releaseCloneCtrl("bigCtrl")
    self:releaseCloneCtrl("smallCtrl")
    self:releaseCloneCtrl("teamCtrl")
    
    leftSelectCtrls= {}
end

-- 获取一级菜单选中光效
function TeamQuickDlg:getOneEffectImg()
    if nil == self.selectOneImg then
        -- 创建选择框
        local img = self:getControl("BChosenEffectImage", Const.UIImage)
        img:retain()
        img:setVisible(true)
        img:setPosition(0, 0)
        img:setAnchorPoint(0, 0)
        self.selectOneImg = img
    end

    self.selectOneImg:removeFromParent(false)

    return self.selectOneImg
end

-- 获取二级菜单选中光效
function TeamQuickDlg:getTwoEffectImg()
    if nil == self.selectTwoImg then
        -- 创建选择框
        local img = self:getControl("SChosenEffectImage", Const.UIImage)
        img:retain()
        img:setVisible(true)
        img:setPosition(0, 0)
        img:setAnchorPoint(0, 0)
        self.selectTwoImg = img
    end

    self.selectTwoImg:removeFromParent(false)

    return self.selectTwoImg
end

-- 初始化界面控件
function TeamQuickDlg:initLeftViewData()
    self:getOneEffectImg()
    self:getTwoEffectImg()

    -- 获取一级控件
    self.bigCtrl = self:getControl("BigPanel")
    self:setCtrlVisible("DownArrowImage", false, self.bigCtrl)
    self:setCtrlVisible("UpArrowImage", false, self.bigCtrl)
    self.bigCtrl:retain()

    -- 获取二级控件
    self.smallCtrl = self:getControl("SPanel")
    self.smallCtrl:retain()

    -- 初始化列表控件
    self.leftListCtrl, self.leftListSize = self:resetListView("CategoryListView", 1, ccui.ListViewGravity.centerHorizontal)

    -- 初始化队伍控件
    self.teamCtrl = self:getControl("TeamUnitPanel")
    self.teamCtrl:retain()
    self.teamCtrl:removeFromParent(false)

end

-- 初始化界面
function TeamQuickDlg:updateLeftViewData()
    if nil == oneActiveAdjustList then
        return
    end

    local isFirst = true
    local level = Me:queryBasicInt("level")
    for i = 1, #oneActiveAdjustList do
        local value = twoActiveAdjustListMap[oneActiveAdjustList[i]]
        local k = oneActiveAdjustList[i]

        -- key 为一级菜单
        if level >= activeLevelMap[k].level then
            local newOne = self.bigCtrl:clone()
            self:setLabelText("Label", k, newOne)
            newOne.isExpand = false
            newOne.value = value
            newOne.key = k

            if #value ~= 0 then
                self:setCtrlVisible("DownArrowImage", true, newOne)
                self:setCtrlVisible("UpArrowImage", false, newOne)
            end

            if isFirst then
                self.firstOneCtrl = newOne
                isFirst = false
            end

            self:bindTouchEndEventListener(newOne, self.oneClick)
            self.leftListCtrl:pushBackCustomItem(newOne)
            table.insert(leftSelectCtrls, newOne)
        end
    end

    self:updateBtn()
    self:updateLeaderAndMember(0, 0)
end

-- 一级菜单点击事件
function TeamQuickDlg:oneClick(sender, eventType, isExpand)
    self.oneKey = sender.key
    local value = sender.value

    -- 已经是展开状态了
    if isExpand then
        if sender.isExpand then
            return
        end
    end
    local level = Me:queryBasicInt("level")
    local isFirst = true
    if not sender.isExpand then
        -- 如果没有展开，插入
        -- value为二级菜单
        self:closeAllSelectItem()
        self.curTwoItemNum = 0
        if self.curSelectName ~= sender.key then
            TeamMgr:requestTeamList(sender.key)
        end

        if #value == 0 then
            self.curSelectName = sender.key
            sender:addChild(self:getOneEffectImg())
            self:getOneEffectImgbySecond()
        else
            self:setCtrlVisible("DownArrowImage", false, sender)
            self:setCtrlVisible("UpArrowImage", true, sender)
        end

        local realIndex = 0
        for i = 1, #value do
            if level >= activeLevelMap[value[i]].level then
                realIndex = realIndex + 1
                self.curTwoItemNum = self.curTwoItemNum + 1
                local newTwo = self.smallCtrl:clone()

                -- 进行切割“其他”类别
                local name = string.match(value[i], ".*-(.*)")
                if nil ~= name then
                    self:setLabelText("Label", name, newTwo)
                else
                    self:setLabelText("Label", value[i], newTwo)
                end

                local index = self.leftListCtrl:getIndex(sender)
                newTwo.key = value[i]
                self:bindTouchEndEventListener(newTwo, self.twoClick)
                -- self:setCtrlVisible("ChosenEffectImage", false, newTwo)

                self.leftListCtrl:insertCustomItem(newTwo, index + realIndex)
                sender.isExpand = true

                if isFirst then
                    self.firstTwoCtrl = newTwo
                    isFirst = false
                end

                if self.twoKey == value[i] then
                    self:twoClick(newTwo)
                end
            end
        end
    else
        for i = 1, self.curTwoItemNum do
            local index = self.leftListCtrl:getCurSelectedIndex()
            self.leftListCtrl:removeItem(index + 1)
            sender.isExpand = false
        end

        local isSelectSec = false
        for i, v in pairs(twoActiveAdjustListMap[sender.key]) do
            if v == self.curSelectName then
                isSelectSec = true
            end
        end

        if isSelectSec then
            isFirst = false
            local oneAndSecPanel = self:getOneEffectImgbySecond()
            self:setLabelText("BigLabel", sender.key, oneAndSecPanel)
            self:setLabelText("SLabel", self.curSelectName, oneAndSecPanel)
            sender:addChild(oneAndSecPanel)
        end

        self:setCtrlVisible("DownArrowImage", true, sender)
        self:setCtrlVisible("UpArrowImage", false, sender)
    end
end

-- 二级菜单点击事件
function TeamQuickDlg:twoClick(sender, eventType, noSend)
    Log:D(">>>>>Click item : " .. sender.key)
    if self.curSelectName ~= sender.key then
        TeamMgr:requestTeamList(sender.key)
        self.curSelectName = sender.key
    end
    
    self.twoKey = sender.key
    sender:addChild(self:getTwoEffectImg())

    self:getOneEffectImgbySecond()
    if self.selectOneImg then self.selectOneImg:removeFromParent(false) end
end

-- 关闭左侧所有的菜单
function TeamQuickDlg:closeAllSelectItem()
    for i = 1, #leftSelectCtrls do
        local ctrl = leftSelectCtrls[i]
        local value = ctrl.value
        if ctrl.isExpand then
            local isSelectSec = false
            for j = 1, self.curTwoItemNum do
                local index = self.leftListCtrl:getIndex(ctrl)
                local item = self.leftListCtrl:getItem(index + 1)
                if self:getLabelText("Label", item) == self.curSelectName then
                    isSelectSec = true
                end
                self.leftListCtrl:removeItem(index + 1)
                ctrl.isExpand = false
            end
            if isSelectSec then
                local oneAndSecPanel = self:getOneEffectImgbySecond()
                self:setLabelText("BigLabel", ctrl.key, oneAndSecPanel)
                self:setLabelText("SLabel", self.curSelectName, oneAndSecPanel)
                ctrl:addChild(oneAndSecPanel)
            end
            self:setCtrlVisible("DownArrowImage", true, ctrl)
            self:setCtrlVisible("UpArrowImage", false, ctrl)
        end
    end
end

function TeamQuickDlg:onTeamUnitButton(sender, eventType)
end

function TeamQuickDlg:onCreateButton(sender, eventType)
    local isLeader = Me:isTeamLeader()
    local inTeam = TeamMgr:inTeamEx(Me:getId())

    if inTeam then
        gf:ShowSmallTips(CHS[6000182])
    else
        gf:CmdToServer("CMD_REQUEST_JOIN", {
            peer_name = Me:getName(),
            id = Me:getId(),
            ask_type = Const.REQUEST_JOIN_TEAM,
        })

        if DistMgr:isInKFJJServer() then
            local mode, needNum = KuafjjMgr:getCurCombatMode()
            if needNum > 1 then
                DlgMgr:openDlg("KuafjjsxDlg")
            end
        else
            local dlg = DlgMgr:openDlg("TeamAdjustmentDlg")
            dlg:selectItemInit(self.curSelectName)
        end
    end

    DlgMgr:closeDlg(self.name)
end

function TeamQuickDlg:onRefreshButton(sender, eventType)

    if gfGetTickCount() - self.lasetRefreshTime < 5 * 1000 then
        gf:ShowSmallTips(CHS[2000084])
        return
    end

    self.lasetRefreshTime = gfGetTickCount()
    TeamMgr:requestTeamList(self.curSelectName)
end



-- 更新按钮
function TeamQuickDlg:updateBtn()
    local matchInfo = TeamMgr:getCurMatchInfo()
    local matchBtn = self:getControl("MatchButton")
    if 1 == matchInfo.state then
        self:setLabelText("Label1", CHS[5000149], matchBtn)
        self:setLabelText("Label2", CHS[5000149], matchBtn)
    else
        self:setLabelText("Label1", CHS[5000150], matchBtn)
        self:setLabelText("Label2", CHS[5000150], matchBtn)
    end
end

-- 更新显示队伍界面
function TeamQuickDlg:updateTeamListPanel(isDisplay)
    self:setCtrlVisible("NoticePanel", isDisplay)
end

function TeamQuickDlg:onMatchButton(sender, eventType)
    if DistMgr:isInKFJJServer() then
        if KuafjjMgr:checkKuafjjIsEnd() then
            return
        end
    end

    local matchInfo = TeamMgr:getCurMatchInfo()
    if 1 == matchInfo.state then
        TeamMgr:stopMatchTeam()
        self:updateBtn()
    else
        -- 八仙梦境/矿石大战副本中不能匹配
        if MapMgr:isInBaXian() or MapMgr:isInOreWars() then
            gf:ShowSmallTips(CHS[3003750])
            return
        end

        if not TeamMgr:isAllowActive(self.curSelectName) then
            gf:ShowSmallTips(CHS[3003751])
            return
        end

        -- 有老君发怒时不能匹配刷道活动
        if TaskMgr:isExistTaskByName(CHS[6000562]) then
            if self.curSelectName == CHS[6000563] or self.curSelectName == CHS[6000564] then
                gf:ShowSmallTips(CHS[6000561])
                return
            end
        end

        -- 跨服竞技
        if DistMgr:isInKFJJServer() then
            local mode = string.match(self.curSelectName, CHS[5400341] .. "(.+)")
            local curMode = KuafjjMgr:getCurCombatMode()
            if mode ~= curMode then
                if not curMode then
                    curMode = CHS[5400418]
                end

                gf:confirm(string.format(CHS[5400417], curMode, mode), function()
                    KuafjjMgr:requestCombatMode(mode)
                    TeamMgr:requstMatchTeam(self.curSelectName)
                    DlgMgr:closeDlg(self.name)
                end)
                return
            end
        end

        TeamMgr:requstMatchTeam(self.curSelectName)
        self:updateBtn()
        DlgMgr:closeDlg(self.name)
    end
end

-- 选择左边菜单,不响应菜单回调
function TeamQuickDlg:selectItem(oneItem, twoItem)
    self:operItem(oneItem, twoItem, true, true)
end

-- 选择左边菜单，响应回调
function TeamQuickDlg:selectItemEx(oneItem, twoItem)
    -- 如果已经选中
    if self.curSelectName and self.curSelectName == twoItem then
        return
    end

    self:operItem(oneItem, twoItem)
end

function TeamQuickDlg:operItem(oneItem, twoItem, one, two)
    local children = self.leftListCtrl:getChildren()

    -- 需要分开响应
    for k, child in pairs(children) do
        local str = child.key
        if oneItem == str then
            self:oneClick(child, nil, one)
        end
    end

    children = self.leftListCtrl:getChildren()

    -- 需要分开响应
    for k, child in pairs(children) do
        local str = child.key
        if twoItem == str then
            self:twoClick(child, nil, two)
        end
    end
end

-- 根据二级菜单获取一级菜单
function TeamQuickDlg:getOneName(twoName)
    for k, v in pairs(twoActiveAdjustListMap) do
        if k == twoName then return k, "" end
        for i = 1, #v do
            if v[i] == twoName then
                return k, twoName
            end
        end
    end
end

function TeamQuickDlg:scrollToItem(oneItem, twoItem)
    if twoItem == oneItem then twoItem = nil end
    local children = self.leftListCtrl:getChildren()

    local operItem = nil
    if twoItem then
        operItem = twoItem
    else
        operItem = oneItem
    end

    local operCtrl = nil
    for k, child in pairs(children) do
        local str = child.key
        if twoItem == str then
            operCtrl = child
        end
    end

    if nil == operCtrl then return end

    local index = self.leftListCtrl:getIndex(operCtrl)
    local height = operCtrl:getContentSize().height
    local listHeight = self.leftListCtrl:getContentSize().height

    if height * (index + 1) > listHeight then
        self.leftListCtrl:scrollToPercentVertical(height * (index + 1) / listHeight * 100, 0.5, false)
    end
end

function TeamQuickDlg:MSG_MATCH_TEAM_STATE(data)
    self:updateBtn()

    if 1 ~= data.state and TeamMgr:inTeamEx(Me:queryBasicInt("id")) then
        DlgMgr:closeDlg(self.name)
    end
end

function TeamQuickDlg:MSG_MATCH_TEAM_LIST(data)
    -- 更新右下角人数
    self:updateLeaderAndMember(data.teamCount, data.memberCount)

    -- 更新列表
    self.teamListData = data
    self:updateTeamList(true)
end

return TeamQuickDlg
