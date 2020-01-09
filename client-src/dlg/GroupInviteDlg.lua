-- GroupInviteDlg.lua
-- Created by zhengjh Aug/07/2016
-- 邀请好友

local GroupInviteDlg = Singleton("GroupInviteDlg", Dialog)

local friendsDateByGid = {}
local findCellByGid = {}

function GroupInviteDlg:init()
    self:bindListener("ReturnButton", self.onReturnButton)
    self:bindListener("InvitationButton", self.onInvitationButton)
    self:bindListViewListener("AllFriendListView", self.onSelectAllFriendListView)
    self:bindListViewListener("HaveChooseListView", self.onSelectHaveChooseListView)
    self:bindListener("CleanFieldButton", self.onCleanFieldButton, "SearchPanel")
    self:bindListener("SearchButton", self.onSearchButton, "SearchPanel")

    self.groupFriendPanel = self:getControl("GroupFriendPanel")
    self.groupFriendPanel:retain()
    self.groupFriendPanel:removeFromParent()

    self.groupInvitationPanel = self:getControl("GroupInvitationPanel")
    self.groupInvitationPanel:retain()
    self.groupInvitationPanel:removeFromParent()

    self.chooseListView = self:getControl("HaveChooseListView")

    self:bindEditFieldForSafe("SearchPanel", 6, "CleanFieldButton")

    self.friendGidList = {}
    self.selectGidList = {}
    findCellByGid = {}
    friendsDateByGid = {}
    self:initAllFriendListView()
end

function GroupInviteDlg:setData(group)
    self.group = group

    -- 设置还可邀请人数
    local online, total = FriendMgr:getOnlinAndTotaleCountsByGroup(group.group_id)
    local left = FriendMgr:getMaxMemberNum() - total
    self.leftToInvite = left
    self:setLabelText("SurplusLabel", left)

    -- 设置群里里面总人数
    self:setLabelText("AllNumLabel", string.format("(%d)", #FriendMgr:getFriends()))

    -- 设置已邀请人数
    self:setInvitedNum()
end

function GroupInviteDlg:setInvitedNum()
    local count = 0
    for k, v in pairs(self.selectGidList) do
        count = count + 1
    end

    self:setLabelText("SelectedLabel", count)
end

function GroupInviteDlg:initAllFriendListView(datas)
    self:setCtrlVisible("NoticePanel", false)
    local friends = datas or FriendMgr:getFriends()

    table.sort(friends, function(l, r) return FriendMgr:sortFunc(l, r) end)

    self.allFriendListView = self:getControl("AllFriendListView")
    self.allFriendListView:removeAllItems()
    self.allFriendListView:stopAllActions()
    self.friendGidList = {} -- 维护列表的顺序


    local timeCount = 0
    for i = 1, #friends do
        if not self.selectGidList[friends[i].gid] then
            local func = cc.CallFunc:create(function()
                local palyer = self.groupFriendPanel:clone()
                self:setFriendCell(palyer, friends[i])
                friendsDateByGid[friends[i].gid] = friends[i]
                self.allFriendListView:pushBackCustomItem(palyer)
                table.insert(self.friendGidList, {gid = friends[i].gid, isInlist = true})
            end)

            self.allFriendListView:runAction(cc.Sequence:create(cc.DelayTime:create(0.02 * timeCount), func))
            timeCount = timeCount + 1
        end
    end
end

function GroupInviteDlg:setFriendCell(cell, data)
    -- 设置图标
    local iconPath = ResMgr:getSmallPortrait(data.icon)
    self:setImage("PortraitImage", iconPath, cell)
    self:setItemImageSize("PortraitImage", cell)

    self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT,
        data.lev, false, LOCATE_POSITION.LEFT_TOP, 21, cell)

    local polar = gf:getPolar(gf:getPloarByIcon(data.icon))
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("PolarImage", polarPath, cell)

    -- 名字
    self:setLabelText("NameLabel", gf:getRealName(data.name), cell)

    -- 帮派
    self:setLabelText("PartyNameLabel", data.faction or "", cell)


    local addButton = self:getControl("AddButton", nil, cell)


    if FriendMgr:isGroupMember(self.group.group_id, data.gid) then -- 成员
        addButton:setVisible(false)
        self:setCtrlVisible("MemberImage", true, cell)
        self:setCtrlVisible("HaveInvitedImage", false, cell)
    elseif FriendMgr:isInvited(self.group.group_id, data.gid) then -- 已邀请
        addButton:setVisible(false)
        self:setCtrlVisible("MemberImage", false, cell)
        self:setCtrlVisible("HaveInvitedImage", true, cell)
    else
        self:setCtrlVisible("MemberImage", false, cell)
        self:setCtrlVisible("HaveInvitedImage", false, cell)
        addButton:setVisible(true)
    end


    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.leftToInvite == 0 then
                gf:ShowSmallTips(CHS[6000442])
                return
            end

            self:removeDataList(data.gid)
            self:removeOneItem(self.allFriendListView, cell)
            self:insertChoooseListView(data)
            self.selectGidList[data.gid] = data.gid
            self:setInvitedNum()
        end
    end

    addButton:addTouchEventListener(listener)
end

function GroupInviteDlg:removeDataList(gid)
    for i = 1, #self.friendGidList do
        if self.friendGidList[i]["gid"] == gid then
            self.friendGidList[i]["isInlist"] = false
            break
        end
    end
end

function GroupInviteDlg:addDataList(gid)
    for i = 1, #self.friendGidList do
        if self.friendGidList[i]["gid"] == gid then
            self.friendGidList[i]["isInlist"] = true
            break
        end
    end
end

function GroupInviteDlg:getInsertIndex(gid)
    local index = 0
    for i = 1, #self.friendGidList do
        if self.friendGidList[i]["isInlist"] == true then
            if self.friendGidList[i]["gid"] == gid then
                break
            end

            index = index + 1
        end
    end

    return index
end

function GroupInviteDlg:insertAllFriendListView(data)
    self:setCtrlVisible("NoticePanel", false)
    local palyer = self.groupFriendPanel:clone()
    self:setFriendCell(palyer, data)
    self.allFriendListView:insertCustomItem(palyer, self:getInsertIndex(data.gid))
end

function GroupInviteDlg:removeOneItem(listView, sender)
    local index = listView:getIndex(sender)
    listView:removeItem(index)
    listView:refreshView()
end

function GroupInviteDlg:insertChoooseListView(data)
    local palyer = self.groupInvitationPanel:clone()
    self:setChooseCell(palyer, data)
    findCellByGid[data.gid] = palyer
    self.chooseListView:pushBackCustomItem(palyer)
end

function GroupInviteDlg:setChooseCell(cell, data)
    -- 设置图标
    local iconPath = ResMgr:getSmallPortrait(data.icon)
    self:setImage("PortraitImage", iconPath, cell)
    self:setItemImageSize("PortraitImage", cell)

    self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT,
        data.lev, false, LOCATE_POSITION.LEFT_TOP, 21, cell)

    local polar = gf:getPolar(gf:getPloarByIcon(data.icon))
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("PolarImage", polarPath, cell)

    -- 名字
    self:setLabelText("NameLabel", gf:getRealName(data.name), cell)

    -- 帮派
    self:setLabelText("PartyNameLabel", data.faction or "", cell)

    local delButton = self:getControl("DelButton", nil, cell)

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:removeOneItem(self.chooseListView , cell)
            self:addDataList(data.gid)
            self:insertAllFriendListView(data)
            self.selectGidList[data.gid] = nil
            findCellByGid[data.gid] = nil
            self:setInvitedNum()
        end
    end

    delButton:addTouchEventListener(listener)
end

function GroupInviteDlg:onReturnButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
end

function GroupInviteDlg:onInvitationButton(sender, eventType)

    local gidsStr = ""
    local nameStr = ""

    for k, v in pairs(self.selectGidList) do
        -- 取消邀请框中的已在群组中的好友
        if FriendMgr:isGroupMember(self.group.group_id, v) then
            self:removeOneItem(self.chooseListView, findCellByGid[v])
            self:addDataList(v)
            self:insertAllFriendListView(friendsDateByGid[v])
            self.selectGidList[v] = nil
            findCellByGid[v] = nil
            self:setInvitedNum()
            if nameStr ~= "" then
                nameStr = nameStr .. "、"
            end

            nameStr = nameStr .. "#Y" .. friendsDateByGid[v].name .. "#n"
        end

        gidsStr = gidsStr .. v .. ";"
    end

    if nameStr ~= "" then
        gf:ShowSmallTips(nameStr .. CHS[5420003])
        return
    end

    if gidsStr == "" then
        gf:ShowSmallTips(CHS[6000441])
        return
    end

    FriendMgr:setInviteMember(self.group.group_id, self.selectGidList)
    FriendMgr:inventeFriendToGroup(self.group.group_id, gidsStr)
    DlgMgr:closeDlg(self.name)
end

function GroupInviteDlg:onCleanFieldButton(sender, eventType)
    self:setInputText("TextField", "", "SearchPanel")
    self:setCtrlVisible("CleanFieldButton", false, "SearchPanel")
    self:setCtrlVisible("DefaultLabel", true, "SearchPanel")
    self:initAllFriendListView()
end

function GroupInviteDlg:onSearchButton(sender, eventType)
    local idOrName = self:getInputText("TextField", "SearchPanel")
    if string.isNilOrEmpty(idOrName) then
        gf:ShowSmallTips(CHS[2100089])
        self:initAllFriendListView()
    else
        local friends = FriendMgr:localSearchFriend(idOrName, function(gid, f)
            if self.selectGidList[gid] then return false
            else return true end
        end)
        self:initAllFriendListView(friends)
        if not friends or #friends <= 0 then
            gf:ShowSmallTips(CHS[2100090])
            self:setCtrlVisible("NoticePanel", true)
        else
            self:setCtrlVisible("NoticePanel", false)
        end
    end
end

function GroupInviteDlg:onSelectAllFriendListView(sender, eventType)
end

function GroupInviteDlg:onSelectHaveChooseListView(sender, eventType)
end

function GroupInviteDlg:cleanup()
    self:releaseCloneCtrl("groupFriendPanel")
    self:releaseCloneCtrl("groupInvitationPanel")
end

return GroupInviteDlg
