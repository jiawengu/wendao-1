-- FlockTagsDlg.lua
-- Created by zhengjh Aug/02/2016
-- 好友分组单条信息

local SingleFriend = require("dlg/SingleFriendDlg")
local FlockTagsDlg = class("FlockTagsDlg")
local MARGIN = 5

function FlockTagsDlg:ctor()
    self:init()
end

function FlockTagsDlg:init()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/FlockTagsDlg.json")
    self.name = "FlockTagsDlg"
    self.isOpen = false
    self.groupHeight = self:getControl("TagsPanel"):getContentSize().height
    self.loadIsEnd = false
    self.root.owner = self
end

function FlockTagsDlg:setData(group, index)
    if nil == group then return end

    self.group = group

    self.friends = FriendMgr:getFriendsByGroup(tonumber(group.groupId))
    table.sort(self.friends, function(l, r) return FriendMgr:sortFunc(l, r) end)

    local listView = self:getControl("ListView")
    local listViewHeight = 0
    local listViewName = (group.groupId or "").."listView"
    listView:setName(listViewName)
    listView:setTag(group.groupId)
    DlgMgr:sendMsg("FriendDlg", "resetData", listViewName)

    local singleFriend = SingleFriend.new()
    self.cellHeight = singleFriend.root:getContentSize().height
    local count = #self.friends
    self.loadcount = 0
    local timeCount = 0

    local function func()
        if self.loadcount >= count  then
            self.root:stopAllActions()
            self.loadIsEnd = true

            -- 创建完直接重设高度，防止延时创建到一半时，添加了新的好友，导致高度设置错误
            self:refreshListViewContentSize()
            return
        end

        timeCount = timeCount + 1

        if not self:needLoadQuickly() then
           if timeCount % 9 ~= 0 then  return end
        end

        self.loadcount = self.loadcount + 1
        local singleFriend = SingleFriend.new()
        local friend = self.friends[self.loadcount]

        if not friend then
            return
        end

        local friendconvert = FriendMgr:getFriendByGid(friend.gid)
        if friendconvert then
            friend = FriendMgr:convertToUserData(friendconvert)
        else
            return
        end

        singleFriend:setData(friend)
        DlgMgr:sendMsg("FriendDlg", "insertOneItem", listView, listViewName, friend, true, true)
        listViewHeight = listViewHeight + singleFriend.root:getContentSize().height  + MARGIN

        if self.loadcount < count and (self.loadcount == 10 or (self.loadcount % 10 == 0 and self:needLoadQuickly())) then
            listView:setContentSize(listView:getContentSize().width, listViewHeight)
            self:refreshRootContentSize()
        end
    end

    local time = (index or 0) * 0.02
    schedule(self.root, func, 0.06  + time)


    listView:setContentSize(listView:getContentSize().width, listViewHeight)
    listView:setTouchEnabled(false)
    listView:requestDoLayout()
    listView:getInnerContainer():requestDoLayout()
    listView:getInnerContainer():setTouchEnabled(false)
    listView:setEventNeedNotifyParent(true)
    self.listView = listView


    -- 名字
    self:setLabelText("NameLabel", group.name)

    -- 人数
    local str = (group.num or "") .. "/" .. (group.totalNum or "")
    self:setLabelText("Numlabel", str)

    -- 设置按钮信息
    self:bindListener("NoteButton", self.onNoteButton)

    if group.groupId == "1" then -- 我的好友不显示编辑
        Dialog.setCtrlVisible(self, "NoteButton", false)
    end

    -- 绑定箭头事件
    self:bindListener("ClickPanel", self.onClickPanel)

    if group.groupId == 1 then
        self:getControl("NoteButton"):setVisible(false)
    end
end

-- 加载好友列表时，优先加载有小红点的条目
function FlockTagsDlg:sortOneFriend(gid)
    local changeTag
    for i = self.loadcount + 1, #self.friends do
        local friend = self.friends[i]
        if friend.gid == gid then
            if changeTag then
                -- 将有新消息的条目加载顺序往前移
                local temp = self.friends[i]
                for j = i, changeTag + 1, -1 do
                    self.friends[j] = self.friends[j - 1]
                end

                self.friends[changeTag] = temp
            end

            break
        end

        local friendconvert = FriendMgr:getFriendByGid(friend.gid)
        if not changeTag and friendconvert and friendconvert.hasRedDot == 0 then
            changeTag = i
        end
    end
end

function FlockTagsDlg:needLoadQuickly()
    if not DlgMgr:sendMsg("FriendDlg", "isOutsideWin") and self.isOpen then
        return true
    end

    return false
end

function FlockTagsDlg:getLoadIsEnd()
    return self.loadIsEnd
end

function FlockTagsDlg:refreshGroupInfo(group)
    if not group then return end
    -- 名字
    self:setLabelText("NameLabel", group.name)

    -- 人数
    local str = (group.num or "") .. "/" .. (group.totalNum or "")
    self:setLabelText("Numlabel", str)

    Dialog.updateLayout(self, "TagsPanel")

    if self.dirCb and type(self.dirCb) == "function" then
        self.dirCb()
    end

    self.group = group
end

function FlockTagsDlg:refreshListViewContentSize()
    -- 以好友个数计算高度，若延时创建的好友条目未创建，会导致高度设置错误，分组间出现断层
    -- local friends = FriendMgr:getFriendsByGroup(tonumber(self.group.groupId))
    local cou = #self.listView:getItems()
    local listViewHeight = (self.cellHeight + MARGIN) * cou --#friends
    self.listView:setContentSize(self.listView:getContentSize().width, listViewHeight)
    if self.isOpen then
        self.root:setContentSize(self.root:getContentSize().width, self.groupHeight + self.listView:getContentSize().height)
    end

    DlgMgr:sendMsg("FriendDlg","dolayoutFriendListView")
end

function FlockTagsDlg:onNoteButton(sender, eventType)
    local dlg = DlgMgr:openDlg("SingleFlockDlg")
    local rect = sender:getBoundingBox()
    local pt = sender:convertToWorldSpace(cc.p(0, 0))
    rect.x = pt.x
    rect.y = pt.y
    rect.width = rect.width * Const.UI_SCALE
    rect.height = rect.height * Const.UI_SCALE
    dlg:setFloatingFramePos(rect)
    dlg:setGroup(self.group)
end

function FlockTagsDlg:onClickPanel()
    local arrowImage1 = self:getControl("ArrowImage1")
    local arrowImage2 = self:getControl("ArrowImage2")
    if self.isOpen then -- 关闭
        self.isOpen = false
        self.root:setContentSize(self.root:getContentSize().width, self.groupHeight)
        self.root:requestDoLayout()
        DlgMgr:sendMsg("FriendDlg","dolayoutFriendListView")
        arrowImage1:setVisible(true)
        arrowImage2:setVisible(false)
    else -- 展开
        self.isOpen = true
        self.root:setContentSize(self.root:getContentSize().width, self.groupHeight + self.listView:getContentSize().height)
        self.root:requestDoLayout()
        DlgMgr:sendMsg("FriendDlg","dolayoutFriendListView")
        arrowImage2:setVisible(true)
        arrowImage1:setVisible(false)
        self:refreshRootContentSize()
    end
end

function FlockTagsDlg:refreshRootContentSize()
    if self.isOpen then
        self.root:setContentSize(self.root:getContentSize().width, self.groupHeight + self.listView:getContentSize().height)
        self.root:requestDoLayout()
        DlgMgr:sendMsg("FriendDlg","dolayoutFriendListView")
    else
        DlgMgr:sendMsg("FriendDlg","dolayoutFriendListView")
    end
end

function FlockTagsDlg:setImage(name, path, root)
    if path == nil or string.len(path) == 0 then return end
    local img = self:getControl(name, Const.UIImage, root)
    if img ~= nil then
        img:loadTexture(path)
    end
end

function FlockTagsDlg:getControl(name, type, root)
    root = root or self.root
    local widget = ccui.Helper:seekWidgetByName(root, name)
    return widget
end

function FlockTagsDlg:setLabelText(name, text, root, color3)
    local ctl = self:getControl(name, Const.UILabel, root)
    if nil ~= ctl and text ~= nil then
        ctl:setString(tostring(text))
        if color3 then
            ctl:setColor(color3)
        end
    end
end

-- 为指定的控件对象绑定 TouchEnd 事件
function FlockTagsDlg:bindTouchEndEventListener(ctrl, func)
    if not ctrl then
        Log:W("Dialog:bindTouchEndEventListener no control ")
        return
    end

    -- 事件监听
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            func(self, sender, eventType)
            SoundMgr:playEffect("button")
        end
    end

    ctrl:addTouchEventListener(listener)
end

-- 控件绑定事件
function FlockTagsDlg:bindListener(name, func, root)
    if nil == func then
        Log:W("Dialog:bindListener no function.")
        return
    end

    -- 获取子控件
    local widget = self:getControl(name,nil,root)
    if nil == widget then
        if name ~= "CloseButton" then
            Log:W("Dialog:bindListener no control " .. name)
        end
        return
    end

    -- 事件监听
    self:bindTouchEndEventListener(widget, func)
end

return FlockTagsDlg
