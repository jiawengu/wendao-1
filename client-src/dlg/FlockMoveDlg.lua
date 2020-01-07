-- FlockMoveDlg.lua
-- Created by zhengjh Aug/02/2016
-- 编辑分组

local FlockMoveDlg = Singleton("FlockMoveDlg", Dialog)

function FlockMoveDlg:init()
    self:bindListener("MoveButton", self.onMoveButton)
    
    self.playerPanel = self:getControl("PlayerPanel")
    self.playerPanel:retain()
    self.playerPanel:removeFromParent()
    
    self.groupPanel = self:getControl("FriendGroupPanel")
    self.groupPanel:retain()
    self.groupPanel:removeFromParent()
    
    self.classSelectImg = self:getControl("CashImage", Const.UIImage, self.groupPanel)
    self.classSelectImg:retain()
    self.classSelectImg:removeFromParent()

    self.upArrowImage = self:getControl("CashArrowImage", Const.UIImage, self.groupPanel)
    self.upArrowImage:retain()
    self.upArrowImage:removeFromParent()
    
    self.selectFriends = {}
    self.selectGroup = nil
    self:hookMsg("MSG_FRIEND_MOVE_CHAR")
end

function FlockMoveDlg:initGroup(data)
	self:setGroupListView(data)
end

function FlockMoveDlg:setGroupListView(selectGroup)
    local data = FriendMgr:getFriendGroupData()
    local listView = self:getControl("ListView")

    for i = 1, #data do
        local groupPanel = self.groupPanel:clone()
        self:setGroupCellData(groupPanel, data[i])
        listView:pushBackCustomItem(groupPanel)
             
        if selectGroup.groupId == data[i].groupId then
            self:selectOneGroup(groupPanel, data[i])
        end
    end
end

function FlockMoveDlg:setGroupCellData(cell, data)
    -- 组名
    self:setLabelText("FriendNameLabel", data.name, cell)
    
    -- 数量
    self:setLabelText("FriendNumLabel", string.format("(%d)", data.totalNum) , cell)
    
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:selectOneGroup(sender, data)
        end
    end

    cell:addTouchEventListener(listener)
    cell:setName(tostring(data.groupId))
end

function FlockMoveDlg:selectOneGroup(sender, data)
    if self.selectGroup and self.selectGroup.name == data.name then return end
    self.selectGroup = data
    self.selectFriends = {}
    self:setGroupPlayerListView(data)
    self:addClassSelcelImage(sender) 
    self:setGroupName(data.name)
end

function FlockMoveDlg:setGroupName(name)
    local panel = self:getControl("GroupNamePanel")
    self:setLabelText("Label_87", name, panel)
end


function FlockMoveDlg:addClassSelcelImage(item)
    self.classSelectImg:removeFromParent()
    item:addChild(self.classSelectImg)
    self.upArrowImage:removeFromParent()
    item:addChild(self.upArrowImage)
end

function FlockMoveDlg:setGroupPlayerListView(data)
    local friends = FriendMgr:getFriendsByGroup(tonumber(data.groupId))
    table.sort(friends, function(l, r) return FriendMgr:sortFunc(l, r) end)
    local listView = self:getControl("GroupPlayerListView")
    listView:removeAllChildren()
    listView:stopAllActions()
    
    local timeCount = 0
    
    for i = 1, #friends do
        local func = cc.CallFunc:create(function()
            local palyer = self.playerPanel:clone()
            self:setPlayerCellData(palyer, friends[i])
            listView:pushBackCustomItem(palyer)
        end)

        listView:runAction(cc.Sequence:create(cc.DelayTime:create(0.02 * timeCount), func))
        timeCount = timeCount + 1
    end
    
end

function FlockMoveDlg:setPlayerCellData(cell, data)
    -- 设置图标
    local iconPath = ResMgr:getSmallPortrait(data.icon)
    self:setImage("PortraitImage", iconPath, cell)
    self:setItemImageSize("PortraitImage", cell)
    
    -- 设置图标
    if 1 ~= data.isOnline then
        local imgCtrl = self:getControl("PortraitImage", Const.UIImage, cell)
        gf:grayImageView(imgCtrl)
    else
        local imgCtrl = Dialog:getControl("PortraitImage", Const.UIImage, cell)
        gf:resetImageView(imgCtrl)
    end
    
    self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT,
        data.lev, false, LOCATE_POSITION.LEFT_TOP, 21, cell)
    
    local polar = gf:getPolar(gf:getPloarByIcon(data.icon))
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("PolarImage", polarPath, cell)

    -- 设置名字
    if 2 == data.isOnline then
        self:setLabelText("NameLabel", data.name, cell, COLOR3.BROWN)
    elseif 0 == data.isVip then
        self:setLabelText("NameLabel", data.name, cell, COLOR3.GREEN )
    elseif 0 ~= data.isVip then
        self:setLabelText("NameLabel", data.name, cell, COLOR3.CHAR_VIP_BLUE_EX)
    end
    
    
    -- 帮派
    self:setLabelText("PartyLabel", data.faction or "", cell)
   
    local function checkBoxClick(self, sender, eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            self.selectFriends[data.gid] = data
        else
            self.selectFriends[data.gid] = nil
        end
    end
    
    self:bindCheckBoxListener("CheckBox", checkBoxClick, cell)
end

function FlockMoveDlg:onMoveButton(sender, eventType)
    if not self.selectGroup or not self.selectFriends then return end
    local gidsStr = ""
    local nameListStr = ""
    
    for k, v in pairs(self.selectFriends) do
        gidsStr = gidsStr .. v.gid .. ";"
        nameListStr = nameListStr .. v.name .. ";"
    end
    
    if gidsStr == "" then
        gf:ShowSmallTips(CHS[6000436])
        return
    end
    
    if FriendMgr:getFriendGroupCount() <= 1 then
        gf:ShowSmallTips(CHS[6000443])
        return
    end

    
    local dlg = DlgMgr:openDlg("SingleFlockMoveDlg")
    local rect = self:getBoundingBoxInWorldSpace(sender)
    dlg:setMoveGidsString(self.selectGroup.groupId, gidsStr, nameListStr)
    dlg.root:setPosition(rect.x, rect.y + rect.height)
end

function FlockMoveDlg:MSG_FRIEND_MOVE_CHAR(data)
    if self.selectGroup then
        self:setGroupPlayerListView(self.selectGroup)
        local listView = self:getControl("ListView")
        if data.fromId then
            local item = listView:getChildByName(data.fromId)
            local group = FriendMgr:getFriendsGroupsInfoById(data.fromId)
            
            if item then
                self:setGroupCellData(item, group)
            end
        end
        
        if data.toId then
            local item = listView:getChildByName(data.toId)
            local group = FriendMgr:getFriendsGroupsInfoById(data.toId)
            
            if item then
                self:setGroupCellData(item, group)
            end
        end
    end
end

function FlockMoveDlg:cleanup()
    self:releaseCloneCtrl("playerPanel")
    self:releaseCloneCtrl("groupPanel")
    self:releaseCloneCtrl("classSelectImg")
    self:releaseCloneCtrl("upArrowImage")
end

return FlockMoveDlg
