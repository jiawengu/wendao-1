-- DesignatedUserDlg.lua
-- Created by songcw
-- 指定交易-指定角色界面

local DesignatedUserDlg = Singleton("DesignatedUserDlg", Dialog)
local SingleFriend = require("dlg/SingleFriendDlg")
local RECENT_GROUP = 0
local groupStatus = {}
local MSG_LIMIT = 6 * 2

local LEVEL_LIMIT = 70
local LEVEL_LIMIT_NEICE = 75

function DesignatedUserDlg:init()
    self:bindListener("SearchButton", self.onSearchButton)
    self:bindListener("CleanFieldButton", self.onCleanFieldButton)
    self:bindListener("DesignatedUserButton", self.onDesignatedUserButton)
    self:bindListViewListener("FriendListView", self.onSelectFriendListView)
    self:bindListener("ClickPanel", self.onClickPanel)
    self:setCtrlVisible("CleanFieldButton", false)

    -- 克隆一些需要用的
    self.tagsPanel = self:retainCtrl("TagsPanel")
    self.friendPanel = self:retainCtrl("SingleFriendPanel")
    -- 好友选中效果
    self.itemSelectImg = self:retainCtrl("ChosenImage", self.friendPanel)

    -- 设置好友列表
    self.listView = self:resetListView("FriendListView", 2)
    self.friendPanels = {}
    self.selectFried = nil
    groupStatus = {}
    self:getFriends()
    self.isSearch = false
    self:initFriendList(self.allFriends, false, false)
    self:setFriendsGroup()

    self:bindEditBoxInit()
end

function DesignatedUserDlg:bindEditBoxInit()
    self.newNameEdit = self:createEditBox("ValuePanel", nil, nil, function(sender, type)
        if type == "ended" then
        elseif type == "changed" then
            local newName = self.newNameEdit:getText()
            if gf:getTextLength(newName) > MSG_LIMIT then
                newName = gf:subString(newName, MSG_LIMIT)
                self.newNameEdit:setText(newName)
                gf:ShowSmallTips(CHS[5400041])
            end

            self:setCtrlVisible("DefaultLabel", gf:getTextLength(newName) == 0)
            self:setCtrlVisible("CleanFieldButton", gf:getTextLength(newName) ~= 0)
        end
    end)
    self.newNameEdit:setLocalZOrder(1)
    self.newNameEdit:setPlaceholderFont(CHS[3003597], 20)
    self.newNameEdit:setFont(CHS[3003597], 19)
    self.newNameEdit:setFontColor(cc.c3b(76, 32, 0))
    self.newNameEdit:setText("")
end

function DesignatedUserDlg:cleanup()

    for _, v in ipairs(self.friendPanels) do
        if v then
            v:release()
        end
    end

    self.friendPanels = {}
end

function DesignatedUserDlg:onClickPanel(sender, eventType)
    local parent = sender:getParent()
    local groupId = parent.groupId
    if groupStatus[groupId] then
        self:setCtrlVisible("ArrowImage1", true, sender)
        self:setCtrlVisible("ArrowImage2", false, sender)
        groupStatus[groupId] = false
    else
        self:setCtrlVisible("ArrowImage1", false, sender)
        self:setCtrlVisible("ArrowImage2", true, sender)
        groupStatus[groupId] = true
    end

    self:initFriendList(self.allFriends)
end

function DesignatedUserDlg:getFriends()
    self.friends = FriendMgr:getFriends()

    local rFriends = FriendMgr:getRecentFriends()
    self.allFriends = {}
    for gid, time in pairs(rFriends) do
        local friend = FriendMgr:convertToUserData(FriendMgr:getFriendByGid(gid))
        if friend then
            friend.group = RECENT_GROUP
            friend.time = time
            table.insert(self.allFriends, friend)
        end
    end

    for _, v in ipairs(self.friends) do
        table.insert(self.allFriends, v)
    end

    self:sortFriends(self.allFriends)
end

-- 排序所有好友，包括最近联系人
function DesignatedUserDlg:sortFriends(friends)
    local function sortFunc(l, r)
        if l.group > r.group then return false end
        if l.group < r.group then return true end

        if l.group == RECENT_GROUP then
            -- 最近联系人以交互时间排序
            if l.time > r.time then return true end
            if l.time < r.time then return false end
        end

        if l.isOnline > r.isOnline then return false end
        if l.isOnline < r.isOnline then return true end

        if FriendMgr:getVipWeight(l.isVip)  > FriendMgr:getVipWeight(r.isVip) then return true end
        if FriendMgr:getVipWeight(l.isVip)  < FriendMgr:getVipWeight(r.isVip) then return false end

        if l.friendShip > r.friendShip then
            return true
        else
            return false
        end
    end

    table.sort(friends, sortFunc)
end

-- 初值化好友列表
function DesignatedUserDlg:initFriendList(friends, isNotGroup, isFirstInit)
    local listView = self.listView
    self:stopSchedule(self.schedule)
    listView:removeAllItems()

    local loadcount = 0
    local timeCount = 0
    local count = #friends
    local curGroup = -1

    -- item 优先取之前已创建的 好友条目，不够用时再调用 schedule 逐个创建好友条目
    for i, cell in ipairs(self.friendPanels) do
        if loadcount >= count  then
            return
        end

        loadcount = loadcount + 1
        local groupId = friends[loadcount].group
        if not isNotGroup and curGroup ~= groupId then
            -- 创建分组标签
            local gCell = self.tagsPanel:clone()
            gCell.groupId = groupId
            if isFirstInit and groupId > 0 then
                groupStatus[groupId] = true
            end

            self:setGroupData(gCell, groupId)
            listView:pushBackCustomItem(gCell)

            curGroup = groupId
        end

        if isNotGroup or groupStatus[groupId] then
            -- 不分组或分组为打开状态，直接加入 listView
            self:setFriendData(cell, friends[loadcount])
            cell:setTag(loadcount)
            listView:pushBackCustomItem(cell)
        end

        if isFirstInit and groupId > 0 then
            -- 默认选项（默认选中非最近联系人的第一个好友）
            self:addItemSelcelImage(cell)
            self:selectFriend(friends[loadcount])
            isFirstInit = false
        end
    end

    local function func()
        if loadcount >= count  then
            self:stopSchedule(self.schedule)

            if load_complete_cb then
                -- 等加载结束之后执行
                self:selectCharEx(load_complete_cb)
            end

            return
        end

        loadcount = loadcount + 1
        local groupId = friends[loadcount].group
        if not isNotGroup and curGroup ~= groupId then
            -- 创建分组标签
            local gCell = self.tagsPanel:clone()
            gCell.groupId = groupId

            if isFirstInit and groupId > 0 then
                groupStatus[groupId] = true
            end

            self:setGroupData(gCell, groupId)
            listView:pushBackCustomItem(gCell)

            curGroup = groupId
        end

        local cell = self.friendPanel:clone()
        cell:retain()

        if isNotGroup or groupStatus[groupId] then
            -- 不分组或分组为打开状态，直接加入 listView
            self:setFriendData(cell, friends[loadcount])
            cell:setTag(loadcount)
            listView:pushBackCustomItem(cell)
        end

        table.insert(self.friendPanels, cell)

        if isFirstInit and groupId > 0 then
            -- 默认选项
            self:addItemSelcelImage(cell)
            self:selectFriend(friends[loadcount])
            isFirstInit = false
        end
    end

    self.schedule = self:startSchedule(func, 0.02)
end

function DesignatedUserDlg:selectFriend(friend)
    if not friend then  return end
    self.selectFried = friend
end

function DesignatedUserDlg:addItemSelcelImage(cell)
    self.itemSelectImg:removeFromParent()
    cell:addChild(self.itemSelectImg)
end

function DesignatedUserDlg:setFriendData(cell, friend)
    -- 设置图标
    local iconPath = ResMgr:getSmallPortrait(friend.icon)
    self:setImage("PortraitImage", iconPath, cell)
    self:setItemImageSize("PortraitImage", cell)
    if 1 ~= friend.isOnline then
        local imgCtrl = self:getControl("PortraitImage", Const.UIImage, cell)
        gf:grayImageView(imgCtrl)
    else
        local imgCtrl = self:getControl("PortraitImage", Const.UIImage, cell)
        gf:resetImageView(imgCtrl)
    end

    -- 名字
    self:setLabelText("NamePatyLabel", gf:getRealName(friend.name), cell, COLOR3.BROWN)

    -- 友好度
    self:setLabelText("FDValueLabel", friend.friendShip, cell)

    local function touch(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:addItemSelcelImage(sender)
            self:selectFriend(friend)
        end
    end

    cell:requestDoLayout()
    cell:setName(friend.gid .. friend.group)
    cell:addTouchEventListener(touch)
    cell.data = friend
end

function DesignatedUserDlg:setGroupData(cell, groupId)
    if groupStatus[groupId] then
        self:setCtrlVisible("ArrowImage1", false, cell)
        self:setCtrlVisible("ArrowImage2", true, cell)
    else
        self:setCtrlVisible("ArrowImage1", true, cell)
        self:setCtrlVisible("ArrowImage2", false, cell)
    end

    local name = self.groupsName[groupId]
    local num, totalNum = self:getFriendsStatus(groupId)
    self:setLabelText("NameLabel", name, cell)
    self:setLabelText("Numlabel", num .. "/" .. totalNum, cell)

    cell:setName("group" .. groupId)
end

function DesignatedUserDlg:getFriendsStatus(group)
    if not self.allFriends then return end

    local num = 0
    local totalNum = 0
    for _, v in pairs(self.allFriends) do
        if v.group == group then
            if v.isOnline == 1 then
                num = num + 1
            end

            totalNum = totalNum + 1
        end
    end

    return num, totalNum
end

function DesignatedUserDlg:setFriendsGroup()
    local groups = FriendMgr.friendsGroupsInfo
    if not groups then
        return
    end

    self.groupsName = {}
    self.groupsName[0] = CHS[5420160]
    for _, v in ipairs(groups) do
        self.groupsName[tonumber(v.groupId)] = v.name
    end
end

function DesignatedUserDlg:onSearchButton(sender, eventType)
    local searchName = self.newNameEdit:getText()
    if searchName == "" then
        gf:ShowSmallTips(CHS[4100969])
        return
    end

    self.isSearch = true

    local listView = self.listView
    self:stopSchedule(self.schedule)
    listView:removeAllItems()

    local ret = {}
    local hasData = {}
    for _, friend in pairs(self.allFriends) do
        if string.match(friend.name, searchName) and not hasData[friend.gid] then
            hasData[friend.gid] = 1
            local cell = self.friendPanel:clone()
            self:setFriendData(cell, friend)
            listView:pushBackCustomItem(cell)
            table.insert(ret, friend)
        end
    end

    -- 如果为0
    if #ret == 0 then
        gf:ShowSmallTips(CHS[4100970])
    end
    self:setCtrlVisible("NoticePanel", #ret == 0)
end



function DesignatedUserDlg:onCleanFieldButton(sender, eventType)
    local listView = self.listView
    self:stopSchedule(self.schedule)
    listView:removeAllItems()
    self:initFriendList(self.allFriends, false, false)
    self:setFriendsGroup()

    self.isSearch = false

    self.newNameEdit:setText("")
    self:setCtrlVisible("DefaultLabel", true)
    sender:setVisible(false)
    self:setCtrlVisible("NoticePanel", false)
end

function DesignatedUserDlg:onDesignatedUserButton(sender, eventType)
    if not self.selectFried then
        gf:ShowSmallTips(CHS[4200473])
        return
    end

    -- 集市珍宝，等级限制70
    if DlgMgr:getDlgByName("MarketGoldItemInfoDlg") or DlgMgr:getDlgByName("MarketGoldSellGoodsDlg") then
        if self.selectFried.lev < 70 then
            gf:ShowSmallTips(string.format(CHS[4101261], 70))
            return
        end
    end

    DlgMgr:sendMsg("UserSellDlg", "setDesignatedChar", self.selectFried)
    DlgMgr:sendMsg("JuBaoPetSellDlg", "setDesignatedChar", self.selectFried)
    DlgMgr:sendMsg("JuBaoEquipSellDlg", "setDesignatedChar", self.selectFried)
    DlgMgr:sendMsg("MarketGoldItemInfoDlg", "setDesignatedChar", self.selectFried)
    DlgMgr:sendMsg("MarketGoldSellGoodsDlg", "setDesignatedChar", self.selectFried)
    self:onCloseButton()
end

function DesignatedUserDlg:onSelectFriendListView(sender, eventType)
end

return DesignatedUserDlg
