-- SubmitFDIDlg.lua
-- Created by zhengjh Jun/01/2016
-- 友好度道具使用界面

local SubmitFDIDlg = Singleton("SubmitFDIDlg", Dialog)
local COLUNM = 5
local SPACE = 6
local MAX_SEND_NUMBER = 6

local ONLINE = 1

local RECENT_GROUP = 0 -- 最近联系人

local WORD_LIMIT = 12

local IMTE_TO_FRIENDLY =
{
   [CHS[6000262]] = 88,
   [CHS[6000263]] = 66,
   [CHS[6000264]] = 66,
}

function SubmitFDIDlg:init(param)
    self:bindListener("SubmitButton", self.onSubmitButton)
    self:bindListener("NoteButton", self.onNoteButton)
    self:bindListener("ClickPanel", self.onClickTag, "TagsPanel")
    self:bindListener("CleanFieldButton", self.onCleanFieldButton)
    self:bindListener("SearchButton", self.onSearchButton)

    self.friendPanel = self:retainCtrl("SingleFriendPanel")

    self.itemSelectImg = self:retainCtrl("ChosenImage", self.friendPanel)
    self.itemSelectImg:setVisible(true)

    self.itemCell = self:retainCtrl("ItemPanel_1")

    self.tagCell = self:retainCtrl("TagsPanel")
    
    local scroview = self:getControl("ScrollView")
    scroview:removeAllChildren()

    self.itemSch = nil
    self.canApplyItem = true
    
    self.friendSch = {}
    
    self.friendPanels = {}
    
    self.itemPanels = {}
    
    self.groupStatus = {}
    
    self:unSelectFriend()
    
    self.listView = self:resetListView("FriendListView")
    self.listView:setBounceEnabled(false)
    self.searchListView = self.listView:clone()
    self.searchListView:setVisible(false)
    self.searchListView:setName("SearchListView")
    self.listView:getParent():addChild(self.searchListView)

    -- 绑定点击事件
    self:bindTouchEvent()

    -- 设置好友列表
   --  self:initFriendList(param or "")
   
    self:bindEditBox()
   
    self:initGroups()
    
    self:setDefaultSelect(param)

    self:hookMsg("MSG_FRIEND_NOTIFICATION")
    self:hookMsg("MSG_APPLY_FRIEND_ITEM_RESULT")
    self:hookMsg("MSG_APPLY_QINGYUANHE_RESULT")
end

function SubmitFDIDlg:bindEditBox()
    self.newEdit = self:createEditBox("InputPanel", "SearchPanel", nil, function(sender, type)
        if type == "end" then
        elseif type == "changed" then
            local inputText = self.newEdit:getText()
            if gf:getTextLength(inputText) > WORD_LIMIT then
                inputText = gf:subString(inputText, WORD_LIMIT)
                self.newEdit:setText(inputText)
                gf:ShowSmallTips(CHS[4000224])
            end

            if gf:getTextLength(inputText) == 0 then
                self:setCtrlVisible("CleanFieldButton", false)
            else
                self:setCtrlVisible("CleanFieldButton", true)
            end
        end
    end)

    self:setCtrlVisible("DefaultLabel", false)
    self:setCtrlVisible("CleanFieldButton", false)
    self.newEdit:setPlaceHolder(CHS[5420161])
    self.newEdit:setPlaceholderFontColor(COLOR3.GRAY)
    self.newEdit:setPlaceholderFont(CHS[3003597], 21)
    self.newEdit:setFont(CHS[3003597], 21)
    self.newEdit:setFontColor(COLOR3.WHITE)
    self.newEdit:setText("")
end

function SubmitFDIDlg:onCleanFieldButton(sender, eventType)
    self.newEdit:setText("")
    
    if sender then
        sender:setVisible(false)
    end

    self:unSelectFriend()
    
    self.listView:setVisible(true)
    self.searchListView:setVisible(false)
    self:setCtrlVisible("NoticePanel", false)
end

function SubmitFDIDlg:onSearchButton(sender, eventType)
    local inputText = self.newEdit:getText()
    
    self:unSelectFriend()

    if not inputText or inputText == "" then
        gf:ShowSmallTips(CHS[5420158])
        self:onCleanFieldButton()
    else
        local searchFriends = {}
        local friends = FriendMgr:getFriends()
        for _, friend in ipairs(friends) do
            if string.find(friend.name, inputText) then
                table.insert(searchFriends, friend)
            end
        end

        if #searchFriends == 0 then
            gf:ShowSmallTips(CHS[5420159])
            self:initSearchFriendList(searchFriends)
        else
            self:sortFriends(searchFriends)
            self:initSearchFriendList(searchFriends)
        end
    end
end

function SubmitFDIDlg:setDefaultSelect(gid)
    if not gid then
        return
    end
    
    local friend = FriendMgr:getFriendByGid(gid)
    if friend then
        self.initSelectGid = gid
        
        -- 打开分组
        local groupId = friend:queryBasic("group")
        local cell = self.listView:getChildByName("group" .. groupId)
        local panel = self:getControl("ClickPanel", nil, cell)
        if panel then
            self:onClickTag(panel)
        end
        
        -- 选中好友
        local cell = self.listView:getChildByName(groupId .. gid)
        if cell then
            self:addItemSelcelImage(cell)
            self:selectFriend(cell.friend, true)
        end
    end
end

-- 显示分组（只显示有好友的分组）
function SubmitFDIDlg:initGroups()
    local groupInfo = FriendMgr:getFriendGroupsData()
    local showGroup = {}
    
    -- 最近联系人
    table.insert(showGroup, {name = CHS[5420160], groupId = tostring(RECENT_GROUP)})
    
    -- 好友分组
    for i = 1, #groupInfo do
        -- local num, totalNum = self:getFriendsStatus(tonumber(groupInfo[i].groupId))
        -- if totalNum > 0 then
        table.insert(showGroup, groupInfo[i])
        -- end
    end
    
    local listView = self.listView
    for i = 1, #showGroup do
        local cell = self.tagCell:clone()
        self:setTagData(cell, showGroup[i])
        listView:pushBackCustomItem(cell)
    end
    
    self.showGroup = showGroup
end

function SubmitFDIDlg:getOneShowGroup(groupId)
     for _, v in pairs(self.showGroup) do
         if tonumber(v.groupId) == groupId then
             return v
         end
     end
end

-- 设置单个分组
function SubmitFDIDlg:setTagData(cell, data)
    local groupId = tonumber(data.groupId)
    if self.groupStatus[groupId] then
        self:setCtrlVisible("ArrowImage1", false, cell)
        self:setCtrlVisible("ArrowImage2", true, cell)
    else
        self:setCtrlVisible("ArrowImage1", true, cell)
        self:setCtrlVisible("ArrowImage2", false, cell)
    end

    local num, totalNum = self:getFriendsStatus(groupId)
    self:setLabelText("NameLabel", data.name, cell)
    self:setLabelText("Numlabel", num .. "/" .. totalNum, cell)

    cell:setName("group" .. groupId)
    cell.groupId = groupId
end

function SubmitFDIDlg:onClickTag(sender, eventType)
    local parent = sender:getParent()
    local groupId = parent.groupId
    if not parent or not groupId then
        return
    end
    
    -- 关掉其它分组
    self:removeFriends(groupId, parent)
    for _, v in pairs(self.showGroup) do
        if tonumber(v.groupId) ~= groupId then
            local cell = self.listView:getChildByName("group" .. v.groupId)
            self:setCtrlVisible("ArrowImage1", true, cell)
            self:setCtrlVisible("ArrowImage2", false, cell)
            self.groupStatus[tonumber(v.groupId)] = false
        end
    end
    
    self.itemSelectImg:removeFromParent()
    
    -- 打开或关闭点击分组
    if self.groupStatus[groupId] then
        self:setCtrlVisible("ArrowImage1", true, parent)
        self:setCtrlVisible("ArrowImage2", false, parent)
        self.groupStatus[groupId] = false
    else
        self:setCtrlVisible("ArrowImage1", false, parent)
        self:setCtrlVisible("ArrowImage2", true, parent)
        self.groupStatus[groupId] = true
        
        local group = self:getOneShowGroup(groupId)
        local item = self.listView:getChildByName("group" .. groupId)
        if group then
            self:setTagData(item, group)
        end
        
        self:insertOneGroupFriends(groupId)
    end
end

function SubmitFDIDlg:getIndex(listView, groupId)
    local groups = self.showGroup or {}
    local nextGroupId
    local cou = #groups
    for i = 1, cou do
        if tonumber(groups[i].groupId) == groupId then
            if i < cou then
                nextGroupId = groups[i + 1].groupId
            end
            
            break
        end
    end
    
    local index = 0
    if nextGroupId then
        local item = listView:getChildByName("group" .. nextGroupId)
        if item then
            index = listView:getIndex(item)
        else
            index = #listView:getItems()
        end
    else
        index = #listView:getItems()
    end
    
    return index
end

-- 移除某一分组的所有好友
function SubmitFDIDlg:removeFriends()
    self:stopSchedule(self.friendSch["group"])
    self.friendSch["group"] = nil
    
    local listView = self.listView
    local items = listView:getItems()
    for _, v in ipairs(items) do
        if v.friend then
            listView:removeChild(v)
        end
    end
    
    listView:refreshView()
end

-- 插入某一分组的所有好友
function SubmitFDIDlg:insertOneGroupFriends(groupId)
    local friends = {}
    if groupId == RECENT_GROUP then
        friends = self:getRecentFriendsInfo()
    else
        friends = FriendMgr:getFriendsByGroup(groupId)
        self:sortFriends(friends)
    end
    
    local listView = self.listView

    local function creatOneFriend(i)
        local cell
        if self.friendPanels[i] then
            cell = self.friendPanels[i]
            cell:removeFromParent()
        else
            cell = self.friendPanel:clone()
            cell:retain()
            self.friendPanels[i] = cell
        end

        self:setFriendData(cell, friends[i])
        local index = self:getIndex(listView, groupId)
        listView:insertCustomItem(cell, index)
    end
    
    local cou = #friends
    local panelCou = #self.friendPanels
    local initLoadNum = math.min(math.max(panelCou, 4), 50)
    for i = 1, initLoadNum do
        if i > cou then
            break
        end
        
        creatOneFriend(i)
    end
    
    local curNum = initLoadNum + 1
    local function func()
        if curNum > cou then
            self:stopSchedule(self.friendSch["group"])
            self.friendSch["group"] = nil
            return
        end
        
        creatOneFriend(curNum)

        curNum = curNum + 1
    end


    self.friendSch["group"] = self:startSchedule(func, 0.03)
end

function SubmitFDIDlg:getRecentFriendsInfo()
    local friends = FriendMgr:getRecentFriendsInfo()
    
    local totalNum = 0
    local needFriends = {}
    for i = 1, #friends do
        table.insert(needFriends, friends[i])
        totalNum = totalNum + 1
        
        if totalNum >= 20 then
            break
        end
    end
    
    return needFriends
end

-- 获取好友在线数目
function SubmitFDIDlg:getFriendsStatus(groupId)
    local friends = {}
    if groupId == RECENT_GROUP then
        friends = self:getRecentFriendsInfo()
    else
        friends = FriendMgr:getFriendsByGroup(groupId)
        self:sortFriends(friends)
    end
    
    local num = 0
    local totalNum = 0
    for _, v in pairs(friends) do
        if v.isOnline == 1 then
            num = num + 1
        end

        totalNum = totalNum + 1
    end

    return num, totalNum
end

-- 初值化好友列表
function SubmitFDIDlg:initSearchFriendList(friends)
    self.listView:setVisible(false)
    if #friends == 0 then
        self:setCtrlVisible("NoticePanel", true)
        self.searchListView:setVisible(false)
    else
        self:setCtrlVisible("NoticePanel", false)
        self.searchListView:setVisible(true)
    end
    
    local listView = self.searchListView
    listView:removeAllItems()
    listView:setInnerContainerSize(cc.size(0, 0))
    if self.friendSch["search"] then
        self:stopSchedule(self.friendSch["search"])
    end
    
    local curNum = 1
    local oneLoadNum = 5
    local cou = #friends
    local function func()
        for i = curNum, curNum + oneLoadNum - 1 do
            if i > cou then
                self:stopSchedule(self.friendSch["search"])
                self.friendSch["search"] = nil
                return
            end
            
            local cell = self.friendPanel:clone()
            self:setFriendData(cell, friends[i])
            listView:pushBackCustomItem(cell)
        end
        
        curNum = curNum + oneLoadNum
    end
    

    self.friendSch["search"] = self:startSchedule(func, 0.07)
    
    func()
    oneLoadNum = 1
end

function SubmitFDIDlg:sortFriends(friends)
    local function sortFunc(l, r)
        if self.initSelectGid == l.gid then return true end
        if self.initSelectGid == r.gid then return false end
        
        if l.isOnline > r.isOnline then return false end
        if l.isOnline < r.isOnline then return true end
        
        local lVip = FriendMgr:getVipWeight(l.isVip)
        local rVip = FriendMgr:getVipWeight(r.isVip)
        if lVip > rVip then return true end
        if lVip < rVip then return false end

        if l.friendShip > r.friendShip then
           return true
        else
           return false
        end
    end

    table.sort(friends, sortFunc)
end

function SubmitFDIDlg:setFriendData(cell, friend)
    --设置图标
    local iconPath = ResMgr:getSmallPortrait(friend.icon)
    self:setImage("PortraitImage", iconPath, cell)
    self:setItemImageSize("PortraitImage", cell)
    if ONLINE ~= friend.isOnline then
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
            self:selectFriend(friend, true)
        end
    end
    
    cell:setName(friend.group .. friend.gid)
    cell:addTouchEventListener(touch)
    cell.friend = friend
    
    if self.selectFriedGid == friend.gid then
        self:addItemSelcelImage(cell)
    end
end

function SubmitFDIDlg:refreshFriednPanel(friend)
    if not friend then  return end
    local listView = self.listView
    
    -- 好友条目
    local item = listView:getChildByName(friend.group .. friend.gid)
    if item then 
        self:setFriendData(item, friend)
    end
    
    -- 好友分组
    local item = listView:getChildByName("group" .. friend.group)
    if item then
        local group = self:getOneShowGroup(friend.group)
        if group then
            self:setTagData(item, group)
        end
    end
    
    -- 最经联系人及分组
    local item = listView:getChildByName(RECENT_GROUP .. friend.gid)
    if item then 
        self:setFriendData(item, friend)
    end
    
    -- 最经联系人分组
    local item = listView:getChildByName("group" .. RECENT_GROUP)
    if item then
        self:setTagData(item, {name = CHS[5420160], groupId = tostring(RECENT_GROUP)})
    end
    
    -- 搜索的好友
    local item = self.searchListView:getChildByName(friend.group .. friend.gid)
    if item then 
        self:setFriendData(item, friend)
    end
end

function SubmitFDIDlg:selectFriend(friend, scrollToTop)
    if not friend then  return end
    if self.selectFriedGid == friend.gid then
        return
    end
    
    self:initList(gf:getGenderByIcon(friend.icon), scrollToTop)
    self:clearSelectItemInfo()

    -- 设置友好度
    local fdPanel = self:getControl("FDPanel")
    fdPanel:setVisible(true)
    self:setLabelText("Label_2", friend.friendShip, fdPanel)
    fdPanel:requestDoLayout()
    self.selectFriedGid = friend.gid
end

function SubmitFDIDlg:addItemSelcelImage(cell)
    self.itemSelectImg:removeFromParent()
    cell:addChild(self.itemSelectImg)
end

function SubmitFDIDlg:unSelectFriend()
    self:setCtrlVisible("FDPanel", false)
    self.selectFriedGid = nil
    self.itemSelectImg:removeFromParent()
    self:clearSelectItemInfo()
end

function SubmitFDIDlg:clearSelectItemInfo()
    self.selectItems = {}

    local fdPanel = self:getControl("FDPanel")
    self:setLabelText("Label_3", "", fdPanel)
    self:setLabelText("Label_2", "", fdPanel)
end

function SubmitFDIDlg:initList(gender, scrollToTop)
    local scroview = self:getControl("ScrollView")
    scroview:removeAllChildren()
    
    local contentLayer = ccui.Layout:create()
    local data = InventoryMgr:getGenderItems(gender)
    local count = #data + 1 -- 加1是因为最后一格多了个加号
    local cellColne = self.itemCell
    local line = math.floor(count / COLUNM)
    local left =  count % COLUNM

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0
    local totalHeight = line * (cellColne:getContentSize().height + SPACE)
    local curLine = 1
    local cellSize = cellColne:getContentSize()
    local function func()
        local i = curLine
        if i == line and left ~= 0 then
            curColunm = left
        elseif i <= line then
            curColunm = COLUNM
        else
            self:stopSchedule(self.itemSch)
            self.itemSch = nil
            return
        end
        
        for j = 1, curColunm do
            local tag = j + (i - 1) * COLUNM
            local cell
            if self.itemPanels[tag] then
                self.itemPanels[tag]:removeFromParent()
                cell = self.itemPanels[tag]
            else
                cell = cellColne:clone()
                cell:retain()
                cell:setAnchorPoint(0,1)
                self.itemPanels[tag] = cell
            end
            
            local x = (j - 1) * (cellSize.width + SPACE)
            local y = totalHeight - (i - 1) * (cellSize.height + SPACE)
            cell:setPosition(x, y)
            self:setCellData(cell, data[tag], tag == count)
            contentLayer:addChild(cell)
        end
        
        curLine = curLine + 1
    end
    
    self.itemSch = schedule(contentLayer, func, 0.05)
    
    local panelCou = #self.itemPanels
    local initLine
    if not scrollToTop and count <= 250 then
        initLine = math.max(math.min(math.ceil(count / COLUNM), math.ceil(panelCou / COLUNM)), 4)
    else
        scroview:jumpToTop()
        initLine = 4
    end
    
    for i = 1, initLine do
        func()
    end

    contentLayer:setContentSize(scroview:getContentSize().width, totalHeight)
    scroview:addChild(contentLayer)
    scroview:setInnerContainerSize(contentLayer:getContentSize())
    
    if totalHeight < scroview:getContentSize().height then
        contentLayer:setPositionY(scroview:getContentSize().height  - totalHeight)
    end
end

function SubmitFDIDlg:setCellData(cell, item, isAddItem)
    if isAddItem then
        self:setCtrlVisible("AddImage", true, cell)
        self:setCtrlVisible("GetImage", false, cell)

        local icon = InventoryMgr:getIconByName(CHS[6000265])
        local iconPath = ResMgr:getItemIconPath(icon)
        self:setImage("ItemImage", iconPath, cell)
        self:setItemImageSize("ItemImage", cell)
        local image = self:getControl("ItemImage", nil ,cell)
        gf:grayImageView(image)
        InventoryMgr:removeLogoBinding(image)
    else
        self:setCtrlVisible("AddImage", false, cell)
        self:setCtrlVisible("GetImage", false, cell)
        
        -- 设置图标
        local iconPath = ResMgr:getItemIconPath(item.icon)
        local image = self:getControl("ItemImage", nil ,cell)
        image:loadTexture(iconPath)
        gf:setItemImageSize(image)
        gf:resetImageView(image)
        
        if InventoryMgr:isLimitedItem(item) then
            InventoryMgr:addLogoBinding(image)
        else
            InventoryMgr:removeLogoBinding(image)
        end
    end

    local function touch(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if isAddItem then
                local num =  InventoryMgr:getAmountByNameBind(CHS[6000265], true)
                local itemName = CHS[6000265]
                if num == 0 then
                    gf:askUserWhetherBuyItem(itemName, true)
                else
                    gf:confirm(string.format(CHS[6000266], num), function ()
                        local items =  InventoryMgr:getItemByName(itemName, true) -- 背包非限制交易物品
                        local item = InventoryMgr:getFirstBindItemByName(itemName) or items[1]
                        if item then
                            InventoryMgr:applyItem(item.pos, 1)
                        end
                    end, nil)
                end
            else
                 self:seleceltItem(sender, item)
            end
        end
    end

    cell:addTouchEventListener(touch)
end

function SubmitFDIDlg:seleceltItem(cell, item)
    if item and self.selectItems[tostring(cell)] then -- 如果已经存在则取消
        self.selectItems[tostring(cell)] = nil
        self:setCtrlVisible("GetImage", false, cell)
    else
        if self:getItemsCount(self.selectItems)>= MAX_SEND_NUMBER then
            gf:ShowSmallTips(string.format(CHS[6000267], MAX_SEND_NUMBER))
            return
        end
        self.selectItems[tostring(cell)] = item
        self:setCtrlVisible("GetImage", true, cell)
    end

    self:refreshAddFriendShip()
    local fdPanel = self:getControl("FDPanel")
    fdPanel:requestDoLayout()
end

function SubmitFDIDlg:refreshAddFriendShip()
    local friendShip = 0
    if self.selectItems then
        for _, v in pairs(self.selectItems) do
            friendShip = friendShip + IMTE_TO_FRIENDLY[v.name] or 0
        end
    end

    local fdPanel = self:getControl("FDPanel")
    if friendShip == 0 then
        self:setLabelText("Label_3", "", fdPanel)
    else
        self:setLabelText("Label_3", "+" .. friendShip, fdPanel)
    end
end

function SubmitFDIDlg:onSubmitButton(sender, eventType)
    if not self.selectItems then return end

    if not self.canApplyItem then return end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    elseif GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3002257])
        return
    elseif not self.selectFriedGid then
        gf:ShowSmallTips(CHS[6000272])
        return
    elseif self:getItemsCount(self.selectItems)> MAX_SEND_NUMBER then
        gf:ShowSmallTips(string.format(CHS[6000267], MAX_SEND_NUMBER))
        return
    end
    
    local friend =  FriendMgr:convertToUserData(FriendMgr:getFriendByGid(self.selectFriedGid))
    if not friend then return end   -- 好友已经不存在
    
    if ONLINE ~= friend.isOnline then
        gf:ShowSmallTips(CHS[6000270])
        return
    end

    local items = ""
    for _, v in pairs(self.selectItems) do
        items = items .."|" .. v.pos
    end

    if items == "" then
        gf:ShowSmallTips(CHS[6000273])
        return
    end

    local data = {}
    data.items = items
    data.gid = self.selectFriedGid
    data.name = friend.name
    
    self.canApplyItem = false
    gf:CmdToServer("CMD_APPLY_FRIEND_ITEM", data)
end

function SubmitFDIDlg:getItemsCount(items)
    local count = 0
    for k, v in pairs(items)do
        count = count + 1
    end

    return count
end

-- 好友上线离线
function SubmitFDIDlg:MSG_FRIEND_NOTIFICATION(data)
    local name =  data.char
    local newFriendInfo = FriendMgr:convertToUserData(FriendMgr:getFriendByName(name))
    self:refreshFriednPanel(newFriendInfo)
end

function SubmitFDIDlg:onNoteButton(sender, eventType)
    local panel = self:getControl("OfflineRulePanel")
    panel:setVisible(true)
end

function SubmitFDIDlg:bindTouchEvent()
    local panel = self:getControl("OfflineRulePanel")
    local layout = ccui.Layout:create()
    layout:setContentSize(self.root:getContentSize())
    layout:setPosition(self.root:getPosition())
    layout:setAnchorPoint(self.root:getAnchorPoint())
    panel:setVisible(false)

    local  function touch(touch, event)
        local rect = self:getBoundingBoxInWorldSpace(panel)
        local toPos = touch:getLocation()
        local classRect = self:getBoundingBoxInWorldSpace(panel)

        if not cc.rectContainsPoint(rect, toPos) and not cc.rectContainsPoint(classRect, toPos) and  panel:isVisible() then
            panel:setVisible(false)
            return true
        end
    end
    self.root:addChild(layout, 10, 1)

    gf:bindTouchListener(layout, touch)
end

-- 好友度道具使用成功
function SubmitFDIDlg:MSG_APPLY_FRIEND_ITEM_RESULT(data)
    if data.result == 1 and self.selectFriedGid then
        local friend = FriendMgr:convertToUserData(FriendMgr:getFriendByGid(self.selectFriedGid))
        if not friend then
            return
        end

        if self.selectFriedGid == data.gid then
            self.selectFriedGid = nil
            self:refreshFriednPanel(friend)
            self:selectFriend(friend)
        else
            self:initList(gf:getGenderByIcon(friend.icon))
            self:clearSelectItemInfo()
        end
    end

    self.canApplyItem = true
end

-- 情缘道具使用成功
function SubmitFDIDlg:MSG_APPLY_QINGYUANHE_RESULT(data)
    if data.result == 1 then
        if self.selectFriedGid then
            local newFriendInfo = FriendMgr:convertToUserData(FriendMgr:getFriendByGid(self.selectFriedGid))
            if newFriendInfo then
                self.selectFriedGid = nil
                self:selectFriend(newFriendInfo)
            end
        end
    end
end

function SubmitFDIDlg:cleanup()
    self.selectFriedGid = nil
    self.initSelectGid = nil

    if self.friendPanels then
        for _, cell in pairs(self.friendPanels) do
            if cell then
                cell:release()
            end
        end
    end
    
    if self.itemPanels then
        for _, cell in pairs(self.itemPanels) do
            if cell then
                cell:release()
            end
        end
    end
    
    self.itemPanels = nil
    self.friendPanels = nil
end

return SubmitFDIDlg
