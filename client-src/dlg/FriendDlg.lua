-- FriendDlg.lua
-- Created by liuhb Feb/25/2015
-- 好友界面显示

local RadioGroup = require("ctrl/RadioGroup")
local FriendVerifyDlg = require("dlg/FriendVerifyDlg")
local SingleFriend = require("dlg/SingleFriendDlg")
local SystemMessageListDlg = require("dlg/SystemMessageListDlg")
local FriendVerifyOperateDlg = require("dlg/FriendVerifyOperateDlg")
local FlockTags = require("dlg/FlockTagsDlg")
local SingleGroup = require("dlg/SingleGroupDlg")
local FriendInstallDlg = require("dlg/FriendInstallDlg")
local GroupMessageDlg = require("dlg/GroupMessageDlg")
local SingleCreatGroup = require("dlg/SingleCreatGroupDlg")
local FriendDlg = Singleton("FriendDlg", Dialog)
local CHECKBOXS = {
    "FriendCheckBox",
    "TempCheckBox",
    "GroupCheckBox",
    "BlacklistCheckBox",
    "MailCheckBox",
    "InstallCheckBox",
}

local CHECK_BOX_PANEL_LIST = {
    "FriendListPanel",
    "TempPanel",
    "GroupListPanel",
    "BlackListPanel",
    "SystemMessageListDlg",
    "FriendInstallDlg",
    "SearchPanel",
    "SuggestPanel",
    "ChatBoxPanel",
    "FriendVerifyOperateDlg",
    "GroupMessageDlg",
}

local PANEL_TO_INDEX =
 {
    ["FriendListPanel"] = 1,
    ["TempPanel"] = 2,
    ["GroupListPanel"] = 3,
    ["BlackListPanel"] = 4,
    ["SystemMessageListDlg"] = 5,
    ["FriendInstallDlg"] = 6,
    ["SearchPanel"] = 7,
    ["SuggestPanel"] = 8,
    ["ChatBoxPanel"] = 9,
    ["FriendVerifyOperateDlg"] = 10,
    ["GroupMessageDlg"] = 11,
}

local CHECK_BOX_PANEL_LIST_INDEX = {
    ["FriendListView"]          = 1,
    ["TempListView"]            = 2,
    ["BlackListView"]           = 3,
    ["SearchListView"]          = 5,
    ["SuggestListView"]         = 6,
}

local SEARCH_CHECKBOX = {
    "SearchWithIdCheckBox",
    "SearchWithNameCheckBox",
}

local GROUP_LIST_MAPPING = {
    [1] = "1listView",--"FriendListView",
    [2] = "2listView",
    [3] = "3listView",
    [4] = "4listView",
    [6] = "TempListView",
    [5] = "BlackListView",
    [7] = "7listView",
    [8] = "8listView",
}

local ChatPanelTag = 9999
local START_POS = cc.p(5, 64)

local listOrderList = {}

function FriendDlg:init()
    local size = self.root:getContentSize()
    self.rawHeight = size.height
    self:setFullScreen()
    self:bindListener("SuggestButton", self.onSuggestButton)
    self:bindListener("RefreshButton", self.onSuggestButton)
    self:bindListener("BlackReturnButton", self.returnBtn)
    self:bindListener("SearchReturnButton", self.returnBtn)
    self:bindListener("TempReturnButton", self.returnBtn)
    self:bindListener("SuggestReturnButton", self.returnBtn)
    self:bindListener("SearchButton", self.onSearch, "SearchAndSupPanel")
    self:bindListener("DelButton", self.onDelButton, "SearchAndSupPanel")
    self:bindListener("CloseButton", self.onCloseButton_1)
    self:bindListener("SearchLabel", self.onSearchLabel)
    self:bindListener("BlogDlgButton", self.onBlogDlgButton)
    self:bindListener("CityDlgButton", self.onCityDlgButton)
    self:bindListener("ChannelDlgButton", self.onChannelButton)
    self:bindListener("FriendReturnButton", self.onChatBoxReturnButton)
    self:bindListener("TempReturnButton", self.onChatBoxReturnButton)
    self:bindListener("NewFriendButton", self.onNewFriendButton)
    self:bindListener("GroupNewsButton", self.onGroupNewsButton)
    self:bindListener("GroupReturnButton", self.onGroupReturnButton)
    self:bindListener("EmptyFriendButton", self.onEmptyFriendButton)

    self:bindFriendSearchEditField("FriendSearchPanel", 6, "DelButton")

    local friendListView = self:getControl("FriendListView")

    local delayRefreshFriendListView
    local function onScrollFrineView(sender, eventType)
        if ccui.ScrollviewEventType.scrolling == eventType or ccui.ScrollviewEventType.scrollToTop == eventType or ccui.ScrollviewEventType.scrollToBottom == eventType then
            local function _onScrolling()
                -- 获取控件
                local listViewCtrl = sender
                local listInnerContent = listViewCtrl:getInnerContainer()
                local innerSize = listInnerContent:getContentSize()
                local listViewSize = listViewCtrl:getContentSize()

                -- 计算滚动的百分比
                local totalHeight = innerSize.height - listViewSize.height

                local innerPosY = math.floor(listInnerContent:getPositionY() + 0.5)

                -- 计算坐标
                local y = listViewSize.height - innerPosY
                local items = listViewCtrl:getItems()
                local item
                for i = 1, #items do
                    item = items[i]
                    local itemX, itemY = item:getPosition()
                    local itemSize = item:getContentSize()
                    if itemY <= y and itemY + itemSize.height >= y then
                        -- 轮到我了
                        if item and item.owner and item.owner and item.owner.isOpen then
                            self:createFlockTags(item, math.min(y - itemY, 67))
                        elseif self.flockTags then
                            self.flockTags:setVisible(false)
                        end
                        -- Log:D(string.format("<<<<(%s, %.2f, %.2f)>>>>", self:getLabelText("NameLabel", item), itemX, math.min(y - itemY, 67)))
                        item = nil
                        break
                    end
                end
            end
            performWithDelay(sender, function() _onScrolling() end, 0)
        end
    end

    friendListView:addScrollViewEventListener(onScrollFrineView)

    self.chatGroupCtrList = {}
    self.friendGroupList = {}

    -- 界面初始化
    self:updateView()

    -- 初始化数据
    self:updateData()

    -- 绑定移动事件
    self:blinkMove()

    self:doBlogEffect()

    -- 同城入口处理
    self:doCityView()

    self.tempReturnBtn = self:getControl("TempReturnButton")
    self.friendReturnBtn = self:getControl("FriendReturnButton")
    self.groupReturnBtn = self:getControl("GroupReturnButton")
    -- 添加PageView事件
 --   self.pageView = self:getControl("PageView", Const.UIPageView)
 --   self.pageView:scrollToPage(1)
--[[    performWithDelay(self.pageView, function()
        self.pageView:scrollToPage(0)

        -- 绑定关闭窗口监听
        self.pageView:addEventListener(function(sender, eventType)
            if ccui.PageViewEventType.turning == eventType and 1 == self.pageView:getCurPageIndex() then
                if true == DlgMgr:isDlgOpened(self.name) then
                    DlgMgr:setVisible(self.name, false)
                end
            end
        end)
    end, 0)]]

    self:hookMsg("MSG_MY_APPENTICE_INFO")
    self:hookMsg("MSG_FRIEND_UPDATE_LISTS")
    self:hookMsg("MSG_FRIEND_ADD_CHAR")
    self:hookMsg("MSG_FRIEND_REMOVE_CHAR")
    self:hookMsg("MSG_FRIEND_NOTIFICATION")
    self:hookMsg("MSG_FRIEND_UPDATE_PARTIAL")
    self:hookMsg("MSG_RECOMMEND_FRIEND")
    self:hookMsg("MSG_MESSAGE_EX")
    self:hookMsg("MSG_MESSAGE")
    self:hookMsg("MSG_FINGER")
    self:hookMsg("MSG_FRIEND_ADD_GROUP")
    self:hookMsg("MSG_FRIEND_MOVE_CHAR")
    self:hookMsg("MSG_FRINED_REMOVE_GROUP")
    self:hookMsg("MSG_FRIEND_REFRESH_GROUP")
    self:hookMsg("MSG_DELETE_CHAT_GROUP")
    self:hookMsg("MSG_CHAT_GROUP")
    self:hookMsg("MSG_CHAT_GROUP_PARTIAL")
    self:hookMsg("MSG_CHAT_GROUP_MEMBERS")
    self:hookMsg("MSG_LOGIN_DONE")
    self:hookMsg("MSG_LBS_REMOVE_FRIEND")
    self:hookMsg("MSG_LBS_ADD_FRIEND_OPER")
    self:hookMsg("MSG_LBS_ENABLE")
end

function FriendDlg:createFlockTags(item, y)
    if not self.flockTags then
        self.flockTags = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/FlockTagsDlg.json")
        self:getControl("ClipPanel", nil, "FriendListPanel"):addChild(self.flockTags)
    else
        self.flockTags:setVisible(true)
    end

    self.flockTags:setPosition(cc.p(START_POS.x, START_POS.y - y))
    -- self.flockTags:setContentSize(cc.size(item:getContentSize().width, self.flockTags:getContentSize().height))

    local updateLable = function()
    self:setLabelText("NameLabel", self:getLabelText("NameLabel", item), self.flockTags)
    self:setLabelText("Numlabel", self:getLabelText("Numlabel", item), self.flockTags)
    end

    -- 刷新名字和人数
    updateLable()

    self:setCtrlVisible("NoteButton", self:getControl("NoteButton", nil, item):isVisible(), self.flockTags)

    self:setCtrlVisible("ArrowImage1", self:getControl("ArrowImage1", nil, item):isVisible(), self.flockTags)
    self:setCtrlVisible("ArrowImage2", self:getControl("ArrowImage2", nil, item):isVisible(), self.flockTags)

    if item and item.owner then
        if self.flockTags and self.flockTags.refOb then
            -- 清除上一个拥有者回调
            self.flockTags.refOb.dirCb = nil
        end

        item.owner.dirCb = updateLable
        self.flockTags.refOb = item.owner
    end

    -- 设置按钮信息
    self:bindListener("NoteButton", function()
        if item and item.owner and item.owner.onNoteButton then
            item.owner.onNoteButton(item.owner, self:getControl("NoteButton", nil, item))
        end
    end, self.flockTags)

    -- 绑定箭头事件
    self:bindListener("ClickPanel", function()
        if item and item.owner and item.owner.onClickPanel then
            item.owner.onClickPanel(item.owner, self:getControl("ClickPanel", nil, item))
        end
    end, self.flockTags)
end

function FriendDlg:doBlogEffect()
    local btn = self:getControl("BlogDlgButton")
    if not btn then return end

    local hasShowYSGT = cc.UserDefault:getInstance():getIntegerForKey("blogBtnMagic" .. gf:getShowId(Me:queryBasic("gid"))) or 0
    if hasShowYSGT ~= 1 and Me:getLevel() >= 40 and Me:getLevel() <= 75 then
        -- 大于等于45级的玩家第一次打开宠物属性界面，需要在元神共通按钮处播放环绕光效
        local effect = btn:getChildByTag(ResMgr.magic.blog_btn)
        if not effect then
            local magic = gf:createLoopMagic(ResMgr.magic.blog_btn)
            magic:setTag(ResMgr.magic.blog_btn)
            magic:setPosition(btn:getContentSize().width * 0.5, btn:getContentSize().height * 0.5)
            btn:addChild(magic)
        end

        cc.UserDefault:getInstance():setIntegerForKey("blogBtnMagic" .. gf:getShowId(Me:queryBasic("gid")), 1)

        self:setCtrlVisible("BlogTipsPanel", true)
    end
end

function FriendDlg:addMagicForCity()
    local btn = self:getControl("CityDlgButton")
    local effect = btn:getChildByTag(ResMgr.magic.blog_btn)
    if not effect then
        local magic = gf:createLoopMagic(ResMgr.magic.blog_btn)
        magic:setTag(ResMgr.magic.blog_btn)
        magic:setPosition(btn:getContentSize().width * 0.5, btn:getContentSize().height * 0.5)
        btn:addChild(magic)
    end
end

function FriendDlg:doCityView()
    local btn = self:getControl("CityDlgButton")
    if not btn then return end

    if CitySocialMgr:checkCanShowCity() then
        btn:setVisible(true)
    else
        -- 屏蔽同城入口
        btn:setVisible(false)
        return
    end

    local level, levelTest = CitySocialMgr:getLevelLimit()
    -- 若为公测区且当前角色等级<70级
    if not DistMgr:curIsTestDist() and Me:getLevel() < level then
        return
    end

    -- 若为内测区且当前角色等级<75级
    if DistMgr:curIsTestDist() and Me:getLevel() < levelTest then
        return
    end

    local key = "hasCityBtnMagic" .. gf:getShowId(Me:queryBasic("gid"))
    local hasShow = cc.UserDefault:getInstance():getIntegerForKey(key, 0)
    if hasShow ~= 1 then
        local effect = btn:getChildByTag(ResMgr.magic.blog_btn)
        if not effect then
            self:addMagic(btn, ResMgr.magic.blog_btn)
        end

        cc.UserDefault:getInstance():setIntegerForKey(key, 1)

        self:setCtrlVisible("CityTipsPanel", true)
    end
end

function FriendDlg:bindFriendSearchEditField(parentPanelName, lenLimit, clenButtonName)

    local namePanel = self:getControl(parentPanelName)
    local textCtrl = self:getControl("SearchTextField", nil, namePanel)
    self:setCtrlVisible(clenButtonName, false, namePanel)
    self:setCtrlVisible("NoteLabel", true, parentPanelName)

    textCtrl:addEventListener(function(sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType then
            self:setCtrlVisible(clenButtonName, true, namePanel)
            self:setCtrlVisible("NoteLabel", false, parentPanelName)
            local str = textCtrl:getStringValue()
            if gf:getTextLength(str) > lenLimit * 2 then
                gf:ShowSmallTips(CHS[4000224])
            end

            textCtrl:setText(tostring(gf:subString(str, lenLimit * 2)))
        elseif ccui.TextFiledEventType.delete_backward == eventType then
        -- 判断是否为空,如果将来需要有清空输入按钮
            local str = sender:getStringValue()
            if "" == str then
                self:setCtrlVisible(clenButtonName, false, namePanel)
                self:setCtrlVisible("NoteLabel", true, parentPanelName)
                self:setFriendGroupPanelList()
            end
        end
    end)

    local function onSearchFriend(ctrl, sender, eventType)
        local idOrName = self:getInputText("SearchTextField", "FriendSearchPanel")
        if string.isNilOrEmpty(idOrName) then
            gf:ShowSmallTips(CHS[2100089])
            self:setFriendGroupPanelList()
        else
            local friends = FriendMgr:localSearchFriend(idOrName)
            table.sort(friends, function(l, r) return FriendMgr:sortFunc(l, r) end)
            if not friends or #friends <= 0 then
                gf:ShowSmallTips(CHS[2100090])
            end

            if self.flockTags then
                self.flockTags:setVisible(false)
            end

            self:setPanelList(friends, "FriendListView", "FriendSlider")
        end
    end

    self:bindListener("SearchButton", onSearchFriend, namePanel)

    self:bindListener(clenButtonName, self.onCleanSearchName, namePanel)
end

-- 清空搜索好友内容，显示好友分组列表
function FriendDlg:onCleanSearchName(sender, eventType)
    local namePanel = self:getControl("FriendSearchPanel")
    local textCtrl = self:getControl("SearchTextField", nil, namePanel)
    local str = textCtrl:getStringValue()
    if not string.isNilOrEmpty(str) then
        textCtrl:didNotSelectSelf()
        textCtrl:setText("")
        textCtrl:setDeleteBackward(true)
        self:setCtrlVisible("DelButton", true, namePanel)
        self:setCtrlVisible("NoteLabel", true, namePanel)
        self:setFriendGroupPanelList()
    end
end

function FriendDlg:blinkMove()
    local sartPos, rect, posx
    local movePanel = self:getControl("MovePanel")
    local winSize = self:getWinSize()
    gf:bindTouchListener(movePanel, function(touch, event)

            local toPos = touch:getLocation()
            local eventCode = event:getEventCode()
            if eventCode == cc.EventCode.BEGAN then
                local panelCtrl = self:getControl("FriendPanel")
                rect = self:getBoundingBoxInWorldSpace(movePanel)
                posx = self.root:getPositionX()
                local dlg = DlgMgr.dlgs["SystemMessageShowDlg"]

                if cc.rectContainsPoint(rect, toPos) and not dlg then -- 并且邮件没有打开可以滑动
                    sartPos = toPos
                    return true
                end
            elseif eventCode == cc.EventCode.MOVED then
                if toPos.x < sartPos.x then
                    local dif = toPos.x - sartPos.x

                    self.root:setPositionX(posx + dif)
                end
            elseif eventCode == cc.EventCode.ENDED then
                if toPos.x < rect.x then
                    self:moveToWinOut(0.5)
                else
                    self:moveToWinIn(0.2)
                end

            end
    end, {
        cc.Handler.EVENT_TOUCH_BEGAN,
        cc.Handler.EVENT_TOUCH_MOVED,
        cc.Handler.EVENT_TOUCH_ENDED
    }, false)
end

function FriendDlg:removeVerifyRedDot()
    if self.friendCheckPanel then
        Dialog.removeRedDot(self.friendCheckPanel, "PortraitImage")
    end
end

function FriendDlg:cleanup()
    if self.friendCheckPanel then
        self.friendCheckPanel.root:release()
        self.friendCheckPanel = nil
    end

    if self.systemMessageDlg then
        self.systemMessageDlg:close()
        self.systemMessageDlg = nil
    end

    if self.friendVerifyOperateDlg then
        self.friendVerifyOperateDlg:close()
        self.friendVerifyOperateDlg = nil
    end

    if self.groupMessageDlg then
        self.groupMessageDlg:close()
        self.groupMessageDlg = nil
    end

    listOrderList = {}
    self.chatName = nil
    self.chatGroupName = nil
    self.chatGid = nil
    self.chatLastUpdateStateTime = nil
    self.flockTags = nil

    -- 如果存在聊天面板，则需要清理一下
    local curChatPanel = self:getCurChatPanel()
    if curChatPanel then
        curChatPanel:clear()
    end

    -- 重新标记为选中好友标签
    FriendMgr.curVisibleDlg = 1
    self.idx = 1

    DlgMgr:closeDlg("SystemMessageShowDlg")

    RedDotMgr:removeCtrRedDotData("FriendDlg", "FriendVerifyReturnButton")
    RedDotMgr:removeCtrRedDotData("FriendDlg", "FriendReturnButton")
    RedDotMgr:removeCtrRedDotData("FriendDlg", "TempReturnButton")
    RedDotMgr:removeCtrRedDotData("FriendDlg", "GroupReturnButton")
end

function FriendDlg:clearData()
    self.chatGroupCtrList = {}
    self.friendGroupList = {}
    self:updateData(true)
end

function FriendDlg:sortFunc(l, r)
    -- 排序逻辑
    l.lastChatTime = l.lastChatTime or 0
    r.lastChatTime = r.lastChatTime or 0
    l.hasRedDot = l.hasRedDot or 0
    r.hasRedDot = r.hasRedDot or 0
    l.index = l.index or 0
    r.index = r.index or 0

    if l.hasRedDot > r.hasRedDot then
        return true
    elseif l.hasRedDot < r.hasRedDot then
        return false
    end

    if l.lastChatTime > r.lastChatTime then
        return true
    elseif l.lastChatTime < r.lastChatTime then
        return false
    end

    if l.isOnline < r.isOnline then
        return true
    elseif l.isOnline > r.isOnline then
        return false
    end

    if l.isOnline ~= 2 then
        -- 离线不排vip
        if l.isVip > 0 and r.isVip <= 0 then
            return true
        elseif l.isVip <= 0 and r.isVip > 0 then
            return false
        end
    end

    if l.friendShip > r.friendShip then
        return true
    elseif l.friendShip < r.friendShip then
        return false
    end

    if l.index < r.index then
        return true
    elseif l.index > r.index then
        return false
    end

    return false
end

-- 设置panel列表
function FriendDlg:setPanelList(arr, listView, slider)
    local friends = arr
    -- listOrderList[listView] = arr
    table.sort(friends, function(l, r) return self:sortFunc(l, r) end)

    local list = self:resetData(listView)
    local i = 1
    for i = 1, #friends do
        local func = cc.CallFunc:create(function()
            local friend
            if listView == "TempListView" then
                friend = FriendMgr:convertToUserData(FriendMgr:getTemFriendByGid(friends[i].gid))
            elseif listView == "FriendListView" then
                friend = FriendMgr:convertToUserData(FriendMgr:getFriendByGid(friends[i].gid))
            end

            if friend then
                self:insertOneItem(list, listView, friend, true)
            else
                self:insertOneItem(list, listView, friends[i], true)
            end
        end)

        list:runAction(cc.Sequence:create(cc.DelayTime:create(0.03 * (i - 1)), func))
    end
end

function FriendDlg:resetData(listView, notBounce)
    self[listView] = {}
    listOrderList[listView] = {}
    local list, _ = self:resetListView(listView, 5, nil, nil, notBounce)
    if list then
        list:stopAllActions()
    end

    if listView == "FriendListView" then
        -- 好友条目是保存在 (group)listView 中，故要另外做删除
        for i = 1, 8 do
            if GROUP_LIST_MAPPING[i] and i ~= 5 and i ~= 6 then
                self[GROUP_LIST_MAPPING[i]] = {}
                listOrderList[GROUP_LIST_MAPPING[i]] = {}
            end
        end
    end

    return list
end

-- 在好友列表中插入条目
function FriendDlg:insertOneItem(list, listView, friendInfo, isRefresh, notFreshGroupSize)
    if not list then return end
    if not self[listView] then self[listView] = {} end
    if self[listView][friendInfo.gid] then
        self:updateOneItem(list, listView, friendInfo)
        return self[listView][friendInfo.gid]
    end

    local singleFriend = SingleFriend.new()
    singleFriend:setData(friendInfo)
    singleFriend.parentListViewIndex = CHECK_BOX_PANEL_LIST_INDEX[listView]
    list:pushBackCustomItem(singleFriend.root)
    list:refreshView()

    -- 刷新分组的间距
    if not notFreshGroupSize then
        self:refreshFriendGroupSize(list)
    end

    self[listView][friendInfo.gid] = singleFriend
    if not listOrderList[listView] then
        listOrderList[listView] = {}
    end

    -- 直接取 #listOrderList[listView] 为Index，当先删除好友在添加好友，index 可能重复，导致排序出错
    if not self.maxIndex then
        self.maxIndex = {}
    end

    if not self.maxIndex[listView] or #listOrderList[listView] == 0 then
        self.maxIndex[listView] = 0
    end

    friendInfo.index = self.maxIndex[listView] + 1 -- #listOrderList[listView]
    self.maxIndex[listView] = friendInfo.index
    table.insert(listOrderList[listView], friendInfo)

    if isRefresh then
        self:refreshList(list, listView, friendInfo)
    end

    return singleFriend
end

-- 刷新好友分组的间距
function FriendDlg:refreshFriendGroupSize(list)
    local tag = list:getTag()
    local group = self.friendGroupList[tostring(tag)]
    if group  then
        group:refreshListViewContentSize()
    end
end

-- 重新排列列表
function FriendDlg:refreshList(list, listView, friendInfo)
    if not list then return end
    local friendCtrl = self[listView][friendInfo.gid]
    local arr = listOrderList[listView]
    local index = 0

    if nil == arr then
        arr = {}
    end

    for i = 1, #arr do
        if arr[i].gid == friendInfo.gid then
            -- 找到这个条目，并删除
            friendInfo.index = arr[i].index or 0
            table.remove(arr, i)
            break
        end
    end

    for i = 1, #arr do
        if not self:sortFunc(arr[i], friendInfo) then
            -- 查询最佳位置
            -- 表中已经是一个有序的队列，所以，只要根据规则查询到相应的位置即可
            index = i
            table.insert(arr, index, friendInfo)
            break
        end
    end

    if 0 == #arr then
        -- 列表为空
        index = 1
        table.insert(arr, index, friendInfo)
    end

    if 0 == index then
        table.insert(arr, friendInfo)
        index = #arr
    end

    -- 如果存在邮箱跟系统消息需要递增
  --[[  if listView == "FriendListView" then
        index = index + 1
    end]]


    -- 删除原来的条目
    local no = list:getIndex(friendCtrl.root)
    friendCtrl.root:retain()
    list:removeItem(no)

    if index - 1 < 0 or #list:getItems() + 1 < index then
        -- 容错
        list:pushBackCustomItem(friendCtrl.root)
    else
        list:insertCustomItem(friendCtrl.root, index - 1)
    end

    list:refreshView()
    friendCtrl.root:release()
    return index
end

-- 在好友列表中删除条目
function FriendDlg:removeOneItem(list, listView, friendInfo)
    local friendCtrl = self[listView][friendInfo.gid]
    if friendCtrl then
        local dataIndex = self:getFriendInfo(listView, friendInfo.gid)
        local index = list:getIndex(friendCtrl.root)
        list:removeItem(index)
        self[listView][friendInfo.gid] = nil
        table.remove(listOrderList[listView], dataIndex)

        -- 刷新分组的间距
        self:refreshFriendGroupSize(list)
    end
end

-- 更新好友中的某个条目
function FriendDlg:updateOneItem(list, listView, friendInfo)
    if not self[listView]  then return end
    local singleFriend = self[listView][friendInfo.gid]
    -- 获取最新数据进行更新
    local newFriendInfo
    if listView == "TempListView" then
        newFriendInfo = FriendMgr:convertToUserData(FriendMgr:getTemFriendByGid(friendInfo.gid))
    else
        newFriendInfo = FriendMgr:convertToUserData(FriendMgr:getFriendByGid(friendInfo.gid))
    end

    if newFriendInfo then
        friendInfo = newFriendInfo
    end

    if singleFriend then
        self:refreshList(list, listView, friendInfo)
        singleFriend:setData(friendInfo)
    else
        if not self:isLoadfriendsEnd() then -- 好友没加载完成(会面回加载最新的好友数据)
            local groupCtrl = self.friendGroupList[tostring(friendInfo.group)]
            if groupCtrl and friendInfo.hasRedDot == 1 then
                -- 加载好友列表收到新消息时，需优先加载出来
                groupCtrl:sortOneFriend(friendInfo.gid)
            end

            return
        end
        self:insertOneItem(list, listView, friendInfo, true)
    end
end

-- 初始化界面上的数据
function FriendDlg:updateData(onlyClearData)
    if self.friendCheckPanel then
        self.friendCheckPanel.root:removeFromParentAndCleanup(true)
        self.friendCheckPanel.root:release()
        self.friendCheckPanel = nil
    end

    -- 获取好友数据
    if onlyClearData then
        self.friendGroupList = {}
        self:resetData("FriendListView", true)
    else
        -- 上线、换线刷新的好友对象没有小红点标记，此处刷新一下
        FriendMgr:setFriendsRedDot()

        self:setFriendGroupPanelList()
    end

    -- 获取黑名单数据
    local friends = FriendMgr:getBlackList()
    self:setPanelList(friends, "BlackListView", "BlackSlider")

    -- 获取最近联系人
    local friends = FriendMgr:getTempFriend()
    self:setPanelList(friends, "TempListView", "TempSlider")

    -- 设置群组数据
    self:setGroupPanelList()
end

function FriendDlg:setFriendGroupPanelList()
    local data = FriendMgr:getFriendGroupData()
    local friendListView = self:getControl("FriendListView")
    self.friendGroupList = {}
    self:resetData("FriendListView", true)
    for i = 1, #data do
        local flockTages = FlockTags.new()
        flockTages:setData(data[i], i)
        friendListView:pushBackCustomItem(flockTages.root)
        self.friendGroupList[data[i].groupId] = flockTages
    end

    -- 创建分组
    local singleCreateGroup = SingleCreatGroup.new()
    local data = {}
    data.type = "friendGroup"
    singleCreateGroup:setData(data)
    friendListView:pushBackCustomItem(singleCreateGroup.root)
end

function FriendDlg:setGroupPanelList()
    local groups = FriendMgr:getChatGroupsData()
    local count = #groups
    local lsitView = self:getControl("GroupListView")
    lsitView:removeAllItems()
    self.chatGroupCtrList = {}

    for i = 1, count do
        local singleGroup = SingleGroup.new()
        singleGroup:setData(groups[i])
        lsitView:pushBackCustomItem(singleGroup)
        self.chatGroupCtrList[groups[i].group_id] = singleGroup
    end


    -- 创建分组
    local singleCreateGroup = SingleCreatGroup.new()
    local data = {}
    data.type = "chatGroup"
    singleCreateGroup:setData(data)
    lsitView:pushBackCustomItem(singleCreateGroup.root)
end

-- 初始化界面上的布局
function FriendDlg:updateView()
    -- 初始化对话框的位置
    self:moveToWinOutAtOnce()

    -- 对对话框进行高低调整适配
    local winSize = self:getWinSize()
    self.heightScale = winSize.height / Const.UI_SCALE / self.rawHeight
    -- self.root:setContentSize(size.width, self.rawHeight * self.heightScale)

    local panelCtrl = self:getControl("FriendPanel")
    local panelSize = panelCtrl:getContentSize()
    local panelHeght = self.rawHeight * self.heightScale
    panelCtrl:setContentSize(panelSize.width, panelHeght)

   -- local suggestPanel = self:getControl("SuggestPanel")
   -- local suggsetSize = suggestPanel:getContSize()

    --local pageCtrl = self:getControl("PageView")
    --local pageSize = pageCtrl:getContentSize()
   -- pageCtrl:setContentSize(pageSize.width, panelHeght)

    -- 对页面的高度进行调整适配
    self:updatePage("TempPanel", "TempListView")
    self:updatePage("FriendListPanel", "FriendListView")
    self:updatePage("SearchPanel", "SearchListView")
    self:updatePage("BlackListPanel", "BlackListView")
    self:updatePage("SuggestPanel", "SuggestListView")
    self:updatePage("GroupListPanel", "GroupListView")


    -- 添加额外的列表(系统消息，好友验证消息)
    -- 系统消息
    self.systemMessageDlg = SystemMessageListDlg.new()
    self.systemMessageDlg.root:setContentSize(panelSize.width, panelHeght)
    panelCtrl:addChild(self.systemMessageDlg.root)
    self.systemMessageDlg.root:setVisible(false)
    self:updatePage("SystemMessagePanel", "SystemMessageListView", "SystemMessageSlider")

    -- 群消息
    self.groupMessageDlg = GroupMessageDlg.new()
    self.groupMessageDlg.root:setContentSize(panelSize.width, panelHeght)
    self.groupMessageDlg:adjustDlgSize(self.rawHeight, self.heightScale)
    panelCtrl:addChild(self.groupMessageDlg.root)
    self.groupMessageDlg.root:setVisible(false)
    self:updatePage("GroupMessagePanel")


    -- 好友设置
    self.friendInstallDlg = FriendInstallDlg.new()
    self.friendInstallDlg.root:setContentSize(panelSize.width, panelHeght)
    panelCtrl:addChild(self.friendInstallDlg.root)
    self.friendInstallDlg.root:setVisible(false)
    self:updatePage("FriendInstallOperatePanel", "ListView")


    -- 好友验证
    self.friendVerifyOperateDlg = FriendVerifyOperateDlg.new()
    self.friendVerifyOperateDlg.root:setContentSize(panelSize.width, panelHeght)
    self.friendVerifyOperateDlg:adjustDlgSize(self.rawHeight, self.heightScale)
    panelCtrl:addChild(self.friendVerifyOperateDlg.root)
    self.friendVerifyOperateDlg.root:setVisible(false)
    --self:updatePage("FriendVerifyOperatePanel", "ListView", "Slider")

    -- 创建互斥按钮
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, CHECKBOXS, self.onCheckBoxClick)

    -- 创建搜索列表互斥按钮
    -- self.searchRadioGroup = RadioGroup.new()
    -- self.searchRadioGroup:setItems(self, SEARCH_CHECKBOX, function(sender, curIdx) end)
    -- self.searchRadioGroup:selectRadio(1)

    local panelCtrl = self:getControl("ChatBoxPanel", Const.UIPanel)
    local PanelSize = panelCtrl:getContentSize()
    local tmpH = self.rawHeight - PanelSize.height
    panelCtrl:setContentSize(PanelSize.width, self.rawHeight * self.heightScale - tmpH)

    -- 搜索编辑框添加监听
    local searchCtrl = self:getControl("SearchTextField", nil, "SearchAndSupPanel")
    searchCtrl:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    searchCtrl:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    searchCtrl:addEventListener(function(sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType then
            self:setCtrlVisible("DelButton", true, "SearchAndSupPanel")
            self:setCtrlVisible("NoteLabel", false, "SearchAndSupPanel")

            local str = sender:getStringValue()
            if gf:getTextLength(str) > 12 then
                str = gf:subString(str, 12)
                searchCtrl:setText(str)
                gf:ShowSmallTips(CHS[3002642])
            end
        elseif ccui.TextFiledEventType.delete_backward == eventType then
            -- 判断是否为空
            local str = sender:getStringValue()
            if "" == str then
                self:setCtrlVisible("DelButton", false, "SearchAndSupPanel")
                self:setCtrlVisible("NoteLabel", true, "SearchAndSupPanel")
            end
        end
    end)

    self:setCtrlVisible("DelButton", false, "SearchAndSupPanel")
    self:setCtrlVisible("NoteLabel", true, "SearchAndSupPanel")

    local closeBtn = self:getControl("CloseButton")
    local centerY = winSize.height / 2 / Const.UI_SCALE
    closeBtn:setPositionY(centerY)
end

-- 设置某个子窗口可见
function FriendDlg:exchangeWinVisible(idx)
    -- 将所有的界面设置为不可见
    local i = 0
    for i = 1, #CHECK_BOX_PANEL_LIST do
        local ctrl = self:getControl(CHECK_BOX_PANEL_LIST[i])
        if ctrl then
            ctrl:setVisible(false)
        end
    end

    local ctrlName = CHECKBOXS[idx]
    if ctrlName then
        self:removeRedDot(ctrlName)
    end

    if idx <= 6 and idx >= 1 then
        self.radioGroup:selectRadio(idx, true)
    else
        if idx ~= PANEL_TO_INDEX["GroupMessageDlg"]
            and idx ~= PANEL_TO_INDEX["FriendVerifyOperateDlg"] then
            self.radioGroup:unSelectedRadio()
        end
    end

    -- 将所点击的界面设置为可见
    local ctrl = self:getControl(CHECK_BOX_PANEL_LIST[idx])
    ctrl:setVisible(true)
    if CHECK_BOX_PANEL_LIST[idx] == "SystemMessageListDlg" then
        -- ListView在首次setVisible时，底层会在下一帧重新计算ListView高度，但是系统邮件界面特殊，高度需要限制在50封以内
        self.systemMessageDlg:updateListViewHeight()
    end

    local hasChange = self.idx ~= idx
    self.idx = idx
    if idx ~= PANEL_TO_INDEX["SearchPanel"] and idx ~= PANEL_TO_INDEX["SuggestPanel"] and idx ~= PANEL_TO_INDEX["FriendVerifyOperateDlg"] then
        self:setCtrlVisible("SearchAndSupPanel", false)
    end

    -- 显示和隐藏信息按钮
    if idx == PANEL_TO_INDEX["FriendListPanel"] then
        self:setCtrlVisible("NewFriendButton", true)
        self:setCtrlVisible("GroupNewsButton", false)
    elseif idx == PANEL_TO_INDEX["GroupListPanel"] or idx == PANEL_TO_INDEX["GroupMessageDlg"] then
        self:setCtrlVisible("NewFriendButton", false)
        self:setCtrlVisible("GroupNewsButton", true)
    elseif idx == PANEL_TO_INDEX["SystemMessageListDlg"] then
        local widget = ccui.Helper:seekWidgetByName(ctrl, "InfoPanel")
        if widget then widget:setVisible(true) end
        self:setCtrlVisible("NewFriendButton", false)
        self:setCtrlVisible("GroupNewsButton", false)
    else
        self:setCtrlVisible("NewFriendButton", false)
        self:setCtrlVisible("GroupNewsButton", false)
    end

    -- 移除返回按钮的小红点
    if hasChange then
    RedDotMgr:removeOneRedDot("FriendDlg", "GroupReturnButton")
    RedDotMgr:removeOneRedDot("FriendDlg", "TempReturnButton")
    RedDotMgr:removeOneRedDot("FriendDlg", "FriendReturnButton")
    end
end

function FriendDlg:getCurDlgIndex()
    return self.idx
end

function FriendDlg:onCheckBoxClick(sender, curIdx)
    FriendMgr:exchangeFriendDlg(curIdx)
    self:removeRedDot(sender)
    DlgMgr:closeDlg("SystemMessageShowDlg")
    self.chatName = nil
    self.chatGroupName = nil
    self.chatGid = nil
    self.chatLastUpdateStateTime = nil
    self:setCtrlVisible("GroupReturnButton", false)

    -- 将好友列表置为搜索前的显示状态
    if sender:getName() ~= "FriendCheckBox" then
        self:onCleanSearchName()
    end
end

function FriendDlg:dolayoutFriendListView()
    local listView = self:getControl("FriendListView")
    listView:refreshView()
end

-- 初始化页面的布局
function FriendDlg:updatePage(panelName, listViewName)
    local panelCtrl = self:getControl(panelName, Const.UIPanel)
    if not panelCtrl then return end
    local PanelSize = panelCtrl:getContentSize()
    local tmpH = self.rawHeight - PanelSize.height
    panelCtrl:setContentSize(PanelSize.width, self.rawHeight * self.heightScale - tmpH - 3)

    -- 进行列表的重新布局
    if listViewName then
        local listViewCtrl = self:getControl(listViewName)
        local listViewSize = listViewCtrl:getContentSize()
        tmpH = self.rawHeight - listViewSize.height
        listViewCtrl:setContentSize(listViewSize.width, self.rawHeight * self.heightScale - tmpH - 3)
    end

    -- 对背景图进行布局
    local bkImageCtrl = self:getControl("MessageBKImage", nil, panelCtrl)
    if bkImageCtrl then
        local bkImageSize = bkImageCtrl:getContentSize()
        tmpH = self.rawHeight - bkImageSize.height
        bkImageCtrl:setContentSize(bkImageSize.width, self.rawHeight * self.heightScale - tmpH - 3)
    end
end

-- 刷新群组聊天的显示的群组信息
function FriendDlg:refreshChatGroupInfo(name, groupId)
    FriendDlg:setGroupChatTips(name, groupId)
end

-- 设置群组聊天信息
function FriendDlg:setGroupChatTips(name, groupId)
    if self.chatGid ~= groupId then return end -- 不是当前聊天群组不设置数据

    self:setCtrlVisible("GoupInfoPanel", true)
    self:setCtrlVisible("InfoPanel", false)
    local panelCtrl = self:getControl("GoupInfoPanel")
    self:setLabelText("NameLabel", name, panelCtrl)

    -- local groupId =  FriendMgr:getGroupIdByName(name)
    local online, total = FriendMgr:getOnlinAndTotaleCountsByGroup(groupId)
    self:setLabelText("PlayerNumLabel1", online)
    self:setLabelText("PlayerNumLabel2", "/" .. total)

    local groupInfo = FriendMgr:convertGroupInfo(FriendMgr:getChatGroupInfoById(groupId))

    local button = self:getControl("GroupInformationButton")
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if groupInfo and Me:queryBasic("gid") == groupInfo.leader_gid then -- 群主
                local dlg = DlgMgr:openDlg("GroupInformationDlg")
                dlg:setGroupData(groupInfo)
            else
                -- 成员
                local dlg = DlgMgr:openDlg("GroupInformationMemberDlg")
                dlg:setGroupData(groupInfo)
            end
        end
    end

    button:addTouchEventListener(listener)

    self:updateLayout("GoupInfoPanel")
end

-- 设置聊天对象提示信息
-- online 设置在线状态，部分聊天对象可能非好友也非最近联系人，故直接传入参数设置。
function FriendDlg:setFriendTips(online)
    if not self.chatGid or not self.chatName then
        return
    end

    local panelCtrl = self:getControl("InfoPanel", nil, "ChatBoxPanel")
    local warningImg = self:getControl("WarningImage", nil , panelCtrl)
    self:setCtrlVisible("GoupInfoPanel", false)
    self:setCtrlVisible("InfoPanel", true)

    local gid = self.chatGid
    local name = self.chatName
    local friendType = CHS[5000070]
    if FriendMgr:isNpcByGid(gid) then
        -- NPC不显示RelationShip与警告标志
        friendType = ""
        warningImg:setVisible(false)
    elseif FriendMgr:hasFriend(gid) then
        friendType = CHS[5000069]
        warningImg:setVisible(false)
    elseif CitySocialMgr:hasCityFriendByGid(gid) then
        -- 区域好友
        friendType = CHS[5400513]
        warningImg:setVisible(false)
    else
        warningImg:setVisible(true)
    end

    -- 好友不存在且未传入 online 时默认显示在线状态
    local onlineStr = ""
    local friend = FriendMgr:getFriendByGid(gid) or FriendMgr:getTemFriendByGid(gid)
    if ((friend and friend:queryBasicInt("online") == 2) or online == 2) and not FriendMgr:isNpcByGid(gid) then
        -- 不在线，且不是npc
        onlineStr = CHS[5420217]
    end

    local titleStr = string.format(CHS[5000068], friendType, gf:getRealName(name), onlineStr)
    local namePanel = self:getControl("NamePanel", Const.UIPanel, panelCtrl)
    namePanel:removeAllChildren()

    local size = panelCtrl:getContentSize()
    local titleCtrl = CGAColorTextList:create()
    titleCtrl:setFontSize(20)
    titleCtrl:setString(titleStr)
    titleCtrl:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    titleCtrl:updateNow()
    local textW, textH = titleCtrl:getRealSize()
    local layer = tolua.cast(titleCtrl, "cc.LayerColor")
    layer:setPosition(0, textH)
    namePanel:addChild(layer)
    namePanel:setContentSize(textW, textH)
    self:updateLayout("InfoPanel", "ChatBoxPanel")
end

-- 设置群组聊天窗口数据
function FriendDlg:setGroupChatInfo(group)
    self.chatGroupName = group.group_name
    local chatBoxPanel = self:getControl("ChatBoxPanel")

    -- 根据好友gid获取聊天列表
    local griupId = group.group_id
    self.chatGid = griupId
    local chatCtrl = FriendMgr:getChatByGid(griupId, chatBoxPanel:getContentSize(), CHAT_CHANNEL.CHAT_GROUP)


    -- 设置聊天群提示信息
    self:setGroupChatTips(group.group_name, group.group_id)

    self:setCtrlVisible("GroupReturnButton", true)
    self:setCtrlVisible("FriendReturnButton", false)
    self:setCtrlVisible("TempReturnButton", false)

    -- 移除返回按钮的小红点
    RedDotMgr:removeOneRedDot("FriendDlg", "GroupReturnButton")

    -- 添加聊天列表
    chatCtrl:removeFromParent(false)
    chatBoxPanel:removeChildByTag(ChatPanelTag, false)
    chatBoxPanel:addChild(chatCtrl, 0, ChatPanelTag)
    chatCtrl:refreshChatPanel()

    -- 绑定回调函数
    chatCtrl:setCallBack(self, "sendGroupMsg", CHAT_CHANNEL.CHAT_GROUP)

    -- 信息设置完毕，显示界面
    FriendMgr:exchangeFriendDlg(PANEL_TO_INDEX["ChatBoxPanel"])

    self.root:requestDoLayout()
end

-- 设置聊天窗口的数据及让窗口显示
function FriendDlg:setChatInfo(info, isFromFriendpanel)
    -- 设置显示的信息
    local name
    local gid = info.gid
    local friendInfo = FriendMgr:getFriendByGid(gid) or FriendMgr:getTemFriendByGid(gid)
    if friendInfo then
        -- info 传入的 name、level 可能是改名前的名字，故重新从 FriendMgr 中取。
        name = friendInfo:queryBasic("char")
        self.chatIcon = friendInfo:queryBasicInt("icon")
        self.chatLevel = friendInfo:queryBasicInt("level")
    else
        name = info.name
        self.chatIcon = info.icon
        self.chatLevel = info.level or 0
    end

    self.chatName = name
    self.chatGid = gid
    self.chatLastUpdateStateTime = gf:getServerTime()

    -- 设置聊天对象提示信息
    self:setFriendTips()

    --local charPanel = self:getControl("ChatListPanel")
    local chatBoxPanel = self:getControl("ChatBoxPanel")

    -- 根据好友gid获取聊天列表
    local chatCtrl = FriendMgr:getChatByGid(gid, chatBoxPanel:getContentSize(), CHAT_CHANNEL.FRIEND)

    local seleclRadioName = self.radioGroup:getSelectedRadioName()

    self:setCtrlVisible("FriendCheckBox", true)
    self:setCtrlVisible("TempCheckBox", true)

    -- 显示返回位置
    local showFriendBox =  (isFromFriendpanel and seleclRadioName == "FriendCheckBox") or (not isFromFriendpanel and not FriendMgr:isTempByGid(gid) and FriendMgr:hasFriend(gid))
    if showFriendBox then
            self:setCtrlVisible("FriendReturnButton", true)
            self:setCtrlVisible("TempReturnButton", false)
        else
            self:setCtrlVisible("FriendReturnButton", false)
            self:setCtrlVisible("TempReturnButton", true)
        end

        self:setCtrlVisible("GroupReturnButton", false)

    -- 非好友要刷新在线状态（跨服对象需要增加发送跨服区组）, npc不需要刷新在线状态
    if not FriendMgr:hasFriend(gid) and not FriendMgr:isNpcByGid(gid) then
        local dist = FriendMgr:getKuafObjDist(gid)
        FriendMgr:requestFriendOnlineState(gid, dist)
    end

    -- 添加聊天列表
    chatCtrl:removeFromParent(false)
    chatBoxPanel:removeChildByTag(ChatPanelTag, false)
    --charPanel:removeAllChildren()
    chatBoxPanel:addChild(chatCtrl, 0, ChatPanelTag)
    chatCtrl:refreshChatPanel()

    -- 绑定回调函数
    chatCtrl:setCallBack(self, "sendMsg", CHAT_CHANNEL.FRIEND)

    -- 信息设置完毕，显示界面
    FriendMgr:exchangeFriendDlg(PANEL_TO_INDEX["ChatBoxPanel"])

    if not showFriendBox then
        -- 存在非聊天对象的未读消息，需要添加小红点
        local friends = FriendMgr.tempList
        for gid, v in pairs(friends) do
            if RedDotMgr:tempFriendHasRedDot(gid) and gid ~= self.chatGid then
                RedDotMgr:insertOneRedDot("FriendDlg", "TempReturnButton")
                break
            end
        end
    end

    self.root:requestDoLayout()
end

-- 设置系统消息，并更新
function FriendDlg:setSystemMsgInfo(info)
    FriendMgr:exchangeFriendDlg(PANEL_TO_INDEX["SystemMessageListDlg"])
end

-- 设置好友验证消息,并更新
function FriendDlg:setFriendVerfyInfo(info)
    FriendMgr:exchangeFriendDlg(PANEL_TO_INDEX["FriendVerifyOperateDlg"])
    self:setCtrlVisible("SearchAndSupPanel", true)

    RedDotMgr:removeOneRedDot("FriendDlg", "FriendReturnButton")
end

function FriendDlg:sendGroupMsg(text, voiceTime, token)
    if nil == self.chatGroupName then return end
    local name = self.chatGroupName
    if FriendMgr:sendMsgToChatGroup(name, text, self.chatGid, voiceTime, token) then
        return true
    end
end

function FriendDlg:sendMsg(text, voiceTime, token)
    if nil == self.chatName then return end
    local name = self.chatName
    --text = gf:filtText(text) -- 在消息回来一起过滤
    FriendMgr:sendMsgToFriend(name, text, self.chatGid, voiceTime, token)
    self:MSG_FRIEND_UPDATE_PARTIAL({char = name, gid = self.chatGid})

    return true
    -- 将数据添加到本地中
   --[[local chatTable = {}
    chatTable.gid = Me:queryBasic("gid")
    chatTable.icon = Me:queryBasicInt("icon") or 0
    chatTable.chatStr = text
    chatTable.name = name
    chatTable.time = gf:getServerTime()
    local chatCtrl = FriendMgr:getChatList(self.chatGid)
    if nil ~= chatCtrl then
        local chatData = chatCtrl:getListData()
        table.insert(chatData, chatTable)
        chatCtrl:refreshChatPanel()
    end]]
end

function FriendDlg:onSuggestButton(sender, eventType)
    FriendMgr:exchangeFriendDlg(PANEL_TO_INDEX["SuggestPanel"])

    -- 请求推荐列表
    local leftTime = 60 - (gf:getServerTime() - (self.clickTime or 0))
    if leftTime <= 0 then
        FriendMgr:requetSuggestFriend()
        self.clickTime = gf:getServerTime()
    else
        gf:ShowSmallTips(string.format(CHS[3002643], leftTime))
    end
end

function FriendDlg:returnBtn(sender, eventType)
    self.radioGroup:selectRadio(1)
end

function FriendDlg:onChatBoxReturnButton(sender, eventType)
    if sender:getName() == "FriendReturnButton" then
        self.radioGroup:selectRadio(1)
    else
        if not FriendMgr:isTempByGid(self.chatGid) then
            -- 不是最近联系人
            FriendMgr:exchangeFriendDlg(PANEL_TO_INDEX["FriendListPanel"])
        else
            self.radioGroup:selectRadio(2)
        end
    end

    self:setCtrlVisible("FriendCheckBox", true)
    self:setCtrlVisible("TempCheckBox", true)

    -- 移除当前聊天的小红点
    RedDotMgr:removeChatRedDot(self.chatGid)

    self.chatName = nil
    self.chatGid = nil
    self.chatLastUpdateStateTime = nil
end

-- 是否在屏幕外
function FriendDlg:isOutsideWin()
    local winSize = self:getWinSize()
    if self.root:getPositionX() <= (-self.root:getContentSize().width / 2 + winSize.x) then
        return true
    else
        return false
    end
end

function FriendDlg:isShow()
    return self:isVisible() and not self:isOutsideWin()
end

-- 打开好友对话框，根据情况判断是否播放动画
function FriendDlg:show(noOpenAction)
    local channelDlg = DlgMgr:getDlgByName("ChannelDlg")
    if channelDlg then
        if not channelDlg:isOutsideWin() then
            noOpenAction = true
        end
        channelDlg:moveToWinOutAtOnce()
    end
    if not self:isOutsideWin() then noOpenAction = true end
    if noOpenAction then
        self:moveToWinInAtOnce()
    else
        self:moveToWinOutAtOnce()
        self:moveToWinIn()
    end

    local gid = self.chatGid
    performWithDelay(self.root, function()
        -- 如 FriendMgr:communicat(userName, gid, icon, level, canSpeakWithMe, distName) 中会先调到该接口再调 setChatInfo() 重设 self.chatGid
        -- 此时上一个聊天对象的小红点不用删除
        if self.chatGid and gid == self.chatGid then
            RedDotMgr:removeChatRedDot(self.chatGid)
        end
    end, 0)
end

-- 立刻离开屏幕
function FriendDlg:moveToWinOutAtOnce()
    self.root:stopAllActions()
    local winSize = self:getWinSize()
    self.root:setPosition(-self.root:getContentSize().width / 2 + winSize.x, Const.WINSIZE.height / Const.UI_SCALE / 2 + winSize.y)
end

-- 慢慢离开屏幕
function FriendDlg:moveToWinOut(time)
    DlgMgr:closeDlg("SystemMessageShowDlg")
    local callBack = cc.CallFunc:create(function()
        -- WDSY-29121，离开屏蔽后，若邮件详情界面已经打开，需要关闭
        DlgMgr:closeDlg("SystemMessageShowDlg")
    end)

    local winSize = self:getWinSize()
    local action = cc.MoveTo:create(time or 0.25, cc.p(-self.root:getContentSize().width / 2 + winSize.x, Const.WINSIZE.height / Const.UI_SCALE / 2 + winSize.y))

    self.root:stopAllActions()
    self.root:runAction(cc.Sequence:create(action, callBack))

    -- 删除小红点
    RedDotMgr:removeOneRedDot("ChatDlg", "FriendButton")
    RedDotMgr:removeOneRedDot("ChannelDlg", "FriendDlgButton")
    RedDotMgr:removeOneRedDot("HomeFishingDlg", "FriendButton")

    -- 关闭存在的角色信息操作对话框
    DlgMgr:closeDlg("CharMenuContentDlg")
end


-- 立刻移入屏幕
function FriendDlg:moveToWinInAtOnce()
    self.root:stopAllActions()
    local winSize = self:getWinSize()
    -- 移入屏幕时，需要考虑安全区域或高比宽大于2/3的情况，因此使用的是WINSIZE
    self.root:setPosition(Const.WINSIZE.width / Const.UI_SCALE / 2 + winSize.x, Const.WINSIZE.height / Const.UI_SCALE / 2 + winSize.y)

    -- 移入屏幕后检查npc信息阅读情况
    FriendMgr:checkNeedDoNpcMsgRead(self.chatGid)
end

-- 慢慢划入屏幕
function FriendDlg:moveToWinIn(time)
    self.root:stopAllActions()
    local winSize = self:getWinSize()
    -- 移入屏幕时，需要考虑安全区域或高比宽大于2/3的情况，因此使用的是WINSIZE
    local moveto = cc.MoveTo:create(time or 0.25, cc.p(Const.WINSIZE.width / Const.UI_SCALE / 2 + winSize.x, Const.WINSIZE.height / Const.UI_SCALE / 2 + winSize.y))
    local callBack = cc.CallFunc:create(function()
        if self.gid then
            DlgMgr:sendMsg("ChatDlg", "hideDoFriendPopup", self.gid)
        end

        -- 移入屏幕后检查npc信息阅读情况
        FriendMgr:checkNeedDoNpcMsgRead(self.chatGid)
    end)

    self.root:runAction(cc.Sequence:create(moveto, callBack))
end

function FriendDlg:onCloseButton_2(sender, eventType)
    self:moveToWinOut()
end

function FriendDlg:onCloseButton_1(sender, eventType)
    self:moveToWinOut()
end

function FriendDlg:onSearch(sender, eventType)
    local text = self:getInputText("SearchTextField", "SearchAndSupPanel")
    if "" == text then return gf:ShowSmallTips(CHS[3002644]) end

    FriendMgr:exchangeFriendDlg(PANEL_TO_INDEX["SearchPanel"])
    self:resetData("SearchListView")
    if not gf:checkRename(text) then
        if gf:getShowId(Me:queryBasic("gid")) == text then
            gf:ShowSmallTips(CHS[3002645])
            return
        end

        -- 根据id查找
        local data = {}
        data.char = text
        data.type = 2
        gf:CmdToServer("CMD_FINGER", data);
    else
        if Me:queryBasic("name") == text then
            gf:ShowSmallTips(CHS[3002645])
            return
        end

        -- 根据名字查找
        local data = {}
        data.char = text
        data.type = 1
        gf:CmdToServer("CMD_FINGER", data);
    end
end

function FriendDlg:onSearchLabel(sender, eventType)
    FriendMgr:exchangeFriendDlg(PANEL_TO_INDEX["SearchPanel"])
end

function FriendDlg:onDelButton(sender, eventType)
    local searchCtrl = self:getControl("SearchTextField", nil, "SearchAndSupPanel")
    searchCtrl:didNotSelectSelf()
    searchCtrl:setText("")
    searchCtrl:setDeleteBackward(true)
    self:setCtrlVisible("NoteLabel", false, "SearchAndSupPanel")
end

-- 设置系统消息的选择项目
function FriendDlg:setSysMsgSelect(info)
    self.systemMessageDlg:setSelectMsgId(info)
end

-- 察看列表中是否已经存在这个好友了
function FriendDlg:getFriendInfo(listView, gid)
    local curList = listOrderList[listView]
    if nil == curList then return end
    for k, value in pairs(curList) do
        if value.gid == gid then
            return k, value
        end
    end

    return nil
end

function FriendDlg:MSG_MY_APPENTICE_INFO(data)
    local lastData = MasterMgr:getLastMyMasterInfo()
    if lastData then
        for i = 1, lastData.count do
            local user = lastData.userInfo[i]
            -- 刷新旧师徒信息中好友名字（可能存在某个徒弟解除师徒关系，导致新数据没有）
            self:MSG_FRIEND_UPDATE_PARTIAL({char = user.name, gid = user.gid})
        end
    end

    -- 刷新新数据，可能新收了徒弟，旧数据没有
    for i = 1, data.count do
        local user = data.userInfo[i]
        self:MSG_FRIEND_UPDATE_PARTIAL({char = user.name, gid = user.gid})
    end
end

function FriendDlg:MSG_FRIEND_UPDATE_LISTS(data)
    self:updateData()
end

function FriendDlg:MSG_FRIEND_ADD_CHAR(data)
    for i = 1, data.count do
        local group = tonumber(data[i].group)
        -- if group == 6 and FriendMgr:getFriendByGid(data[i].gid) then return end -- 如果存在好友列表则不加最近联系人

        local list = self:getControl(GROUP_LIST_MAPPING[group])
        if list then
            local friendInfo = FriendMgr:convertToUserData(FriendMgr:getFriendByGroupAndGid(group, data[i].gid))
            if not friendInfo then
                if "N/A" == data[i]["party/name"] then
                    data[i]["party/name"] = ""
                end

                friendInfo = {
                    gid = data[i].gid,
                    name = data[i].char,
                    icon = data[i].icon,
                    faction = data[i]["party/name"],
                    lev = data[i].level,
                    isVip = 0,
                    isOnline = data[i].online or 2,
                    friendShip = data[i].friend
                }
            end

            if friendInfo then
                self:insertOneItem(list, GROUP_LIST_MAPPING[group], friendInfo, true)

                if group ~= 6 and group ~= 5 then
                    -- 刷新好友时也要刷新最近联系人数据
                    self:refreshTempFriend({group = 6, gid = friendInfo.gid})
                end
            end

            if self.chatGid == data[i].gid then
                -- self.name 不为空时正在聊天
                -- 聊天对象有可能更名了，重新设置聊天对象提示信息
                self.chatName = data[i].char
                self:setFriendTips()
            end

            -- 更新界面list数据玩家名字
            self:updateListData(data[i], friendInfo)

        end
    end
end

function FriendDlg:updateListData(data, friendInfo)
    local list = listOrderList[GROUP_LIST_MAPPING[data.group]]
    if nil == list then return end
    for k, value in pairs(list) do
        if value.gid == friendInfo.gid then
            value.name = data.char
            break
        end
    end
end

function FriendDlg:MSG_FRIEND_REMOVE_CHAR(data)
    local group = tonumber(data.group)
    local list = self:getControl(GROUP_LIST_MAPPING[group])
    local _, friendInfo = self:getFriendInfo(GROUP_LIST_MAPPING[group], data.gid)
    if list and friendInfo then
        self:removeOneItem(list, GROUP_LIST_MAPPING[group], {
            group = data.group,
            name = data.char,
            gid = data.gid
        })
    end
end

function FriendDlg:MSG_FRIEND_NOTIFICATION(data)
    local name =  data.char
    local friendInfo = FriendMgr:convertToUserData(FriendMgr:getFriendByName(name))
    if not friendInfo then return end
    local group = tonumber(friendInfo.group)
    local list = self:getControl(GROUP_LIST_MAPPING[group])
    self:updateOneItem(list, GROUP_LIST_MAPPING[group], friendInfo)

    if self.chatGid == friendInfo.gid then
        self.chatName = friendInfo.name
        self:setFriendTips()
    end

    -- 刷新好友时也要刷新最近联系人数据
    self:refreshTempFriend({group = 6, gid = friendInfo.gid})
end

function FriendDlg:MSG_FRIEND_UPDATE_PARTIAL(data)
    local name =  data.char
    local gid = data.gid
    local charInfo = nil
    local group = tonumber(data.group)
    if FriendMgr:isBlackByGId(gid) then
        charInfo = FriendMgr:getBlackByGid(gid)
    else
        if FriendMgr:isTemFriendGroup(group) then
            charInfo = FriendMgr:getTemFriendByGid(gid)
        else
            charInfo = FriendMgr:getFriendByGid(gid)
        end
    end

    local friendInfo = FriendMgr:convertToUserData(charInfo)
    if not friendInfo then return end
    local group = tonumber(friendInfo.group)
    local list = self:getControl(GROUP_LIST_MAPPING[group])
    self:updateOneItem(list, GROUP_LIST_MAPPING[group], friendInfo)

    if self.chatGid == gid then
        self.chatName = friendInfo.name
        self:setFriendTips()
    end

    -- 刷新好友时也要刷新最近联系人数据
    if FriendMgr:isFriendGroup(group) then
        self:refreshTempFriend({group = 6, gid = friendInfo.gid})
    end
end

function FriendDlg:refreshTempFriendForNpc(data)
    local group = tonumber(data.group)
    local list = self:getControl(GROUP_LIST_MAPPING[group])
    self:updateOneTempItem(list, GROUP_LIST_MAPPING[group], data)
end

function FriendDlg:refreshTempFriend(data)
    local group = tonumber(data.group)
    if group ~= 6 then return end
    local friendInfo = FriendMgr:convertToUserData(FriendMgr:getTemFriendByGid(data.gid))
    if not friendInfo then return end
    local group = tonumber(friendInfo.group)
    local list = self:getControl(GROUP_LIST_MAPPING[group])
    self:updateOneTempItem(list, GROUP_LIST_MAPPING[group], friendInfo)
end

function FriendDlg:updateOneTempItem(list, listView, friendInfo)
    local singleFriend = self[listView][friendInfo.gid]
    -- 获取最新数据进行更新
    local newFriendInfo = FriendMgr:convertToUserData(FriendMgr:getTemFriendByGid(friendInfo.gid))
    if newFriendInfo then
        friendInfo = newFriendInfo
    end

    if singleFriend then
        self:refreshList(list, listView, friendInfo)
        singleFriend:setData(friendInfo)
    else
        self:insertOneItem(list, listView, friendInfo, true)
    end
end

function FriendDlg:updateSingleFriendData(group, gid)
    local listView = GROUP_LIST_MAPPING[group]
    local singleFriend = self[listView][gid]
    local friendInfo = FriendMgr:convertToUserData(FriendMgr:getFriendByGroupAndGid(group, gid))

    if singleFriend then
        singleFriend:setData(friendInfo)
    end

    if self.chatGid == friendInfo.gid then
        self.chatName = friendInfo.name
        self:setFriendTips()
    end
end

function FriendDlg:MSG_FINGER(data)
    -- 更新搜索列表
    local count = data.count
    local search = {}

    if count <= 0 then
        self:resetData("SearchListView")
        return
    end

    for i = 1, count do
        local info = {}
        info.name = data[i].name
        info.icon = data[i].icon
        info.lev = data[i].level
        info.gid = data[i].gid
        info.comeback_flag = data[i].comeback_flag
        info.faction = data[i]["party/name"] or ""
        info.isVip = data[i].insider_level
        info.isOnline = 1
        info.friendShip = 0
        search[i] = info
    end

    self:setPanelList(search, "SearchListView", "SearchSlider")
end

function FriendDlg:MSG_RECOMMEND_FRIEND(data)
    -- 更新推荐列表
    local count = data.count

    if count <= 0 then
        gf:ShowSmallTips(CHS[5000099])
        self:setCtrlVisible("EmptyPanel", true)
        self:resetData("SuggestListView")
        return
   else
        self:setCtrlVisible("EmptyPanel", false)
   end

    local search = {}
    for i = 1, count do
        local info = {}
        info.name = data[i].name
        info.icon = data[i].icon
        info.lev = data[i].level
        info.gid = data[i].gid
        info.faction = data[i]["party/name"] or ""
        info.isVip = data[i].insider_level
        info.isOnline = 1
        info.friendShip = 0
        search[i] = info
    end

    self:setPanelList(search, "SuggestListView", "SuggestSlider")
end

function FriendDlg:addSingleFriendRedDot(listView, gid)
    if self[listView] and self[listView][gid] then
        local ctrl = Dialog.getControl(self[listView][gid], "PortraitImage")
        self:addRedDot(ctrl, nil, true)
    end
end

function FriendDlg:MSG_MESSAGE(data)
    if CHAT_CHANNEL.FRIEND ~= data.channel then return end

    local friend = FriendMgr:getFriendByGid(data.gid)
    if friend then
        -- 好友列表
        if self.chatGid ~= data.gid then
            local listView = (friend:queryBasic("group") or "") .. "listView"
                self:addSingleFriendRedDot(listView, data.gid)

            -- 搜索的好友条目
                self:addSingleFriendRedDot("FriendListView", data.gid)
            end
    elseif FriendMgr:isTempByGid(data.gid) then
        -- 临时列表
        if nil ~= self["TempListView"] and nil ~= self["TempListView"][data.gid] and self.chatGid ~= data.gid then
            self:addSingleFriendRedDot("TempListView", data.gid)
        end

        local lastUpdateTime = self.chatLastUpdateStateTime or 0
        if data.gid == self.chatGid and gf:getServerTime() - lastUpdateTime > 60 then
            self.chatLastUpdateStateTime = gf:getServerTime()
            local dist = FriendMgr:getKuafObjDist(data.gid)
            FriendMgr:requestFriendOnlineState(data.gid, dist)
        end
    end

    if data.gid == self.chatGid
        and data.name ~= self.chatName then
        -- 改名了，刷新一下数据
        self.chatName = data.name
        self:setFriendTips()
    end
end

function FriendDlg:MSG_MESSAGE_EX(data)
    self:MSG_MESSAGE(data)
end

-- 是否可以录音
function FriendDlg:isCanSpeak()
   if  self:getControl("ChatBoxPanel"):isVisible() then
        return true
   else
        return false
   end
end


function FriendDlg:onBlogDlgButton(sender)
    BlogMgr:openBlog()

    local effect = sender:getChildByTag(ResMgr.magic.blog_btn)
    if effect then
        effect:removeFromParent()
    end

    self:setCtrlVisible("BlogTipsPanel", false)
end

function FriendDlg:onCityDlgButton(sender)
    if CitySocialMgr:checkOpenCityDlg() then
        CitySocialMgr:requestOpenCity()
    end

    local effect = sender:getChildByTag(ResMgr.magic.blog_btn)
    if effect then
        effect:removeFromParent()
    end

    self:setCtrlVisible("CityTipsPanel", false)
end

-- 切换到频道
function FriendDlg:onChannelButton()
    self:moveToWinOutAtOnce()

    local dlg = DlgMgr:openDlg("ChannelDlg")
    dlg:moveToWinInAtOnce()
    DlgMgr:reorderDlgByName("ChannelDlg")

    -- 删除小红点
    RedDotMgr:removeOneRedDot("ChatDlg", "FriendButton")
    RedDotMgr:removeOneRedDot("ChannelDlg", "FriendDlgButton")
    RedDotMgr:removeOneRedDot("HomeFishingDlg", "FriendButton")

    DlgMgr:closeDlg("SystemMessageShowDlg")

    self:onCleanSearchName()
end

-- 是否可以增加红点
function FriendDlg:onCheckAddRedDot(ctrlName)
    local isTemChat = self.chatGid and self.tempReturnBtn:isVisible()
    local isFriendChat = self.chatGid and self.friendReturnBtn:isVisible()
    local isGroupChat = self.chatGid and self.groupReturnBtn:isVisible()
    if "TempCheckBox" == ctrlName and (isTemChat or self.radioGroup:getSelectedRadioName() == "TempCheckBox") then
        return false
    elseif "FriendCheckBox" == ctrlName and (isFriendChat or self.radioGroup:getSelectedRadioName() == "FriendCheckBox") then
        return false
    elseif "GroupCheckBox" == ctrlName and (isGroupChat or self.radioGroup:getSelectedRadioName() == "GroupCheckBox") then
        return false
    elseif PANEL_TO_INDEX["GroupMessageDlg"] == self.idx and ctrlName == "GroupNewsButton" then
        return false
    elseif PANEL_TO_INDEX["FriendVerifyOperateDlg"] == self.idx and ctrlName == "NewFriendButton" then
        return false
    elseif "MailCheckBox" == ctrlName then
        return not self:isCheck("MailCheckBox")
    elseif ctrlName == "FriendReturnButton" and not isFriendChat then
        return false
    elseif ctrlName == "TempReturnButton" and not isTemChat then
        return false
    elseif ctrlName == "GroupReturnButton" and not isGroupChat and PANEL_TO_INDEX["GroupMessageDlg"] ~= self.idx then
        return false
    else
        return true
    end
end

-- 获取当前玩家聊天名字
function FriendDlg:getCurChatName()
    return self.chatName
end

-- 获取当前聊天群组mingz
function FriendDlg:getCurChatGroupName()
    return self.chatGroupName
end

-- 获取当前聊天Gid
function FriendDlg:getCurChatGid()
    return self.chatGid
end

-- 获取当前聊天的对象的等级
function FriendDlg:getCurChatLevel()
    local friendInfo = FriendMgr:getFriendByGid(self.chatGid) or FriendMgr:getTemFriendByGid(self.chatGid)
    if friendInfo then
        self.chatLevel = friendInfo:queryBasicInt("level")
    end

    return self.chatLevel
end

-- 获取显示当前聊天信息的 Panel
function FriendDlg:getCurChatPanel()
    local chatBoxPanel = self:getControl("ChatBoxPanel")
    if not chatBoxPanel or not self.chatGid then return end

    local chatPanel = chatBoxPanel:getChildByTag(ChatPanelTag)
    return chatPanel
end

function FriendDlg:sortGroupList()
    local lsitView = self:getControl("GroupListView")
    local groups = FriendMgr:getChatGroupsData()
    local count = #lsitView:getItems()

    for i = 1, count - 1 do
        local item = lsitView:getItem(i - 1)
        if item then
            item:setData(groups[i])
            self.chatGroupCtrList[groups[i].group_id] = item
        end
    end
end

function FriendDlg:isLoadfriendsEnd()
    local load = true
    if self.friendGroupList then
        for k, v in pairs(self.friendGroupList) do
            if v then
               if not v:getLoadIsEnd() then
                    load = false
                    break
               end
            end
        end
    end

    return load
end

function FriendDlg:onNewFriendButton(sender, eventType)
    self:setFriendVerfyInfo({})

    self:onCleanSearchName()
end

function FriendDlg:onGroupNewsButton(sender, eventType)
    FriendMgr:exchangeFriendDlg(PANEL_TO_INDEX["GroupMessageDlg"])
    self:setCtrlVisible("GroupReturnButton", true)
    SystemMessageMgr:redAllGgroupMsg()

    -- 移除返回按钮的小红点
    RedDotMgr:removeOneRedDot("FriendDlg", "GroupReturnButton")
end

function FriendDlg:onGroupReturnButton(sender, eventType)
    FriendMgr:exchangeFriendDlg(PANEL_TO_INDEX["GroupListPanel"])
    self:setCtrlVisible("GroupReturnButton", false)
    self.chatGroupName = nil
    self.chatGid = nil
    self.chatLastUpdateStateTime = nil
end

-- 清空最近联系人
function FriendDlg:onEmptyFriendButton(sender, eventType)
    local tempList = FriendMgr.tempList
    if tempList and next(tempList) then
        local str = CHS[5400040]
        if RedDotMgr:hasRedDotInfoByOnlyDlgName("tempFriendChat") then
            str = CHS[5400436]
        end

        gf:confirm(str, function ()
            self:resetData("TempListView")
            FriendMgr:delAllTempFriend()
        end)
    else
        gf:ShowSmallTips(CHS[5410030])
    end
end

function FriendDlg:MSG_FRIEND_ADD_GROUP(data)
    local friendListView = self:getControl("FriendListView")

    local friendsGroup = FriendMgr:getFriendsGroupsInfoById(data.groupId)
    local flockTages = FlockTags.new()
    flockTages:setData(friendsGroup)
    local index = #friendListView:getItems() - 1

    if index < 0 then
        friendListView:pushBackCustomItem(flockTages.root)
    else
        friendListView:insertCustomItem(flockTages.root, #friendListView:getItems() - 1)
    end

    self.friendGroupList[data.groupId] = flockTages
end

function FriendDlg:MSG_FRINED_REMOVE_GROUP(data)
    local groupId = data.groupId
    local friendListView = self:getControl("FriendListView")
    local index = friendListView:getIndex(self.friendGroupList[data.groupId].root)
    friendListView:removeItem(index)
    self[GROUP_LIST_MAPPING[tonumber(groupId)]] = nil
    listOrderList[GROUP_LIST_MAPPING[tonumber(groupId)]] = nil
end

function FriendDlg:MSG_FRIEND_MOVE_CHAR(data)
    local count = 0

    for i = 1, #data.gidList do
        local moveFriends = cc.CallFunc:create(function()
            local gid = data.gidList[i]
            local friend = FriendMgr:getFriendByGid(gid)
            if friend then
                local friendData = {}
                friendData.group = data.toId
                friendData.char = friend:queryBasic("char")
                friendData.gid = friend:queryBasic("gid")
                local freindsList = {}
                freindsList.count = 1
                freindsList[1] = friendData
                self:MSG_FRIEND_ADD_CHAR(freindsList)

                local friendData = {}
                friendData.group = data.fromId
                friendData.char = friend:queryBasic("char")
                friendData.gid = friend:queryBasic("gid")
                self:MSG_FRIEND_REMOVE_CHAR(friendData)
            end
            count = count - 1
        end )


        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.02 * count), moveFriends))
        count = count + 1
    end
end

function FriendDlg:MSG_FRIEND_REFRESH_GROUP(data)
    if not self.friendGroupList then return end
    local flockTags = self.friendGroupList[data.groupId]
    local friendsGroup = FriendMgr:getFriendsGroupsInfoById(data.groupId)

    if flockTags then
        flockTags:refreshGroupInfo(friendsGroup)
    end
end

-- 删除群分组
function FriendDlg:MSG_DELETE_CHAT_GROUP(data)
    local lsitView = self:getControl("GroupListView")
    local ctrl =  self.chatGroupCtrList[data.groupId]
    local index = lsitView:getIndex(ctrl)
    lsitView:removeItem(index)
    self.chatGroupCtrList[data.groupId] = nil
end

-- 添加群组
function FriendDlg:MSG_CHAT_GROUP(data)
    local lsitView = self:getControl("GroupListView")

    local group = FriendMgr:getChatGroupInfoById(data.groupId)
    local singleGroup = SingleGroup.new()
    singleGroup:setData(FriendMgr:convertGroupInfo(group))

    if self.chatGroupCtrList and not self.chatGroupCtrList[data.groupId] then
        self.chatGroupCtrList[data.groupId] = singleGroup
        local index = #lsitView:getItems() - 1

        if index < 0 then
            lsitView:pushBackCustomItem(singleGroup)
        else
            lsitView:insertCustomItem(singleGroup, index)
        end

        -- 排序群组
        self:sortGroupList()
    end
end

function FriendDlg:MSG_CHAT_GROUP_PARTIAL(data)
    local singleGroup = self.chatGroupCtrList[data.groupId]
    if singleGroup then
        local groupData = FriendMgr:getChatGroupInfoById(data.groupId)
        if not groupData then return end
        local groupInfo = FriendMgr:convertGroupInfo(groupData)
        if not groupInfo then return end
        singleGroup:setData(groupInfo)
        self:refreshChatGroupInfo(groupInfo.group_name, data.groupId)

        if self.chatGid == data.groupId and self.chatGroupName and self.chatGroupName ~= data.group_name then
            -- 群组名发生更改
            self.chatGroupName = groupInfo.group_name
        end
    end
end

function FriendDlg:MSG_CHAT_GROUP_MEMBERS(data)
    local groupData = FriendMgr:getChatGroupInfoById(data.group_id)
    if not groupData then return end
    local groupInfo = FriendMgr:convertGroupInfo(groupData)
    self:refreshChatGroupInfo(groupInfo.group_name, data.group_id)
end

function FriendDlg:MSG_LOGIN_DONE(data)
    local chatPanel = self:getCurChatPanel()
    if not chatPanel then
        return
    end

    FriendMgr:setChatByGid(self.chatGid, chatPanel)
end

function FriendDlg:MSG_LBS_REMOVE_FRIEND(data)
    -- 删除区域好友刷新一下提示
    if self.chatGid == data.gid then
        self:setFriendTips()
    end
end

function FriendDlg:MSG_LBS_ADD_FRIEND_OPER(data)
    -- 添加区域好友刷新一下提示
    if self.chatGid == data.gid then
        self.chatName = data.char
        self:setFriendTips()
    end
end

function FriendDlg:MSG_LBS_ENABLE(data)
    self:doCityView()
end

return FriendDlg
