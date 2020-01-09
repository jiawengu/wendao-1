-- SingleFriendDlg.lua
-- Created by liuhb Mar/02/2015
-- 单条好友信息

local DataObject = require("core/DataObject")
local SingleFriendDlg = class("SingleFriend")

function SingleFriendDlg:ctor()
    self:init()
end

function SingleFriendDlg:init()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/SingleFriendDlg.json")
    self.name = "SingleFriendDlg"

    local function onNodeEvent(event)
        if Const.NODE_CLEANUP == event then
            FriendMgr:unrequestCharMenuInfo(self.name)
            self.onCharInfo = nil
        end
    end

    self.root:registerScriptHandler(onNodeEvent)
end

function SingleFriendDlg:setData(friend)
    if nil == friend then return end

    self.friend = friend
    local gid = friend.gid
    
    -- 设置图标
    local iconPath = ResMgr:getSmallPortrait(friend.icon)
    Dialog.setImage(self, "PortraitImage", iconPath)
    Dialog.setItemImageSize(self, "PortraitImage")
    -- 跨服对象没有在线状态数据，先显示为在线
    local imgCtrl = Dialog.getControl(self, "PortraitImage", Const.UIImage)
    if 1 ~= friend.isOnline then        
        gf:grayImageView(imgCtrl)
    else        
        gf:resetImageView(imgCtrl)
    end

    performWithDelay(gf:getUILayer(), function()
         -- FriendDlg:insertOneItem() 中调用的 self:refreshList() 接口会停掉小红点闪烁，故延后一帧添加小红点
        if FriendMgr:isTempByGid(gid) and RedDotMgr:tempFriendHasRedDot(gid) then
            DlgMgr:sendMsg("FriendDlg", "addSingleFriendRedDot", "TempListView", gid)
        end
        
        if FriendMgr:hasFriend(gid) and RedDotMgr:hasRedDotInfoByDlgName("FriendChat", gid) then
            DlgMgr:sendMsg("FriendDlg", "addSingleFriendRedDot", (friend.group or "") .. "listView", gid)
            
            -- 搜索的好友条目
            DlgMgr:sendMsg("FriendDlg", "addSingleFriendRedDot", "FriendListView", gid)
        end
    end, 0)

    -- 设置名字
    local realName, flagName = gf:getRealNameAndFlag(friend.name)
    if 2 == friend.isOnline and (not FriendMgr:getKuafObjDist(gid) or FriendMgr:isBlackByGId(gid)) then
        self:setLabelText("NamePatyLabel", realName, nil, COLOR3.BROWN)
    elseif 0 == friend.isVip then
        Dialog.setLabelText(self, "NamePatyLabel", realName, nil, COLOR3.GREEN)
    elseif 0 ~= friend.isVip then
        Dialog.setLabelText(self, "NamePatyLabel", realName, nil, COLOR3.CHAR_VIP_BLUE_EX)
    end
    
	Dialog.setImagePlist(self, "MasterImage", ResMgr.ui.touming)
	
    if FriendMgr:getKuafObjDist(gid) then
        Dialog.setCtrlVisible(self, "ServerImage", true)
    else
        Dialog.setCtrlVisible(self, "ServerImage", false)

        -- 与吕寅确认，关系和跨服 ServerImage 不可能同时存在
        Dialog.setCtrlVisible(self, "MasterImage", true)
        Dialog.setCtrlVisible(self, "MasterImage_1", false)
        
        if MasterMgr:isMyTeacherByGid(friend.gid) then
            Dialog.setImage(self, "MasterImage", ResMgr:getRelationIconByTitle(CHS[4300043]))
        elseif MasterMgr:isMyStudentByGid(friend.gid) then
            Dialog.setImage(self, "MasterImage", ResMgr:getRelationIconByTitle(CHS[4300042]))
        else
            local jiebaiInfo = JiebaiMgr:getJiebaiInfo()
            local isRelation = false
            for _, relationInfo in pairs(jiebaiInfo) do
                if relationInfo and relationInfo.gid == gid and not isJieBai then
                    Dialog.setImage(self, "MasterImage", ResMgr:getRelationIconByTitle(relationInfo.showRelation))    
                    isRelation = true
                end
            end
            
            local info = MarryMgr:getLoverInfo()
            if MarryMgr:isMarried() and info and info.gid == gid then                
                Dialog.setImage(self, "MasterImage", ResMgr:getRelationIconByTitle(info.relation))    
                isRelation = true
            end
        
            if not isRelation then
                Dialog.setImagePlist(self, "MasterImage", ResMgr.ui.touming)
            end
        end
    end

    Dialog.setCtrlVisible(self, "BackPlayerImage", friend.comeback_flag == 1)

    --使用接口，为Panel设置NumImg控件：setNumImgForPanel():好友等级
    if friend.lev and friend.lev > 1 then
    
    
    local panel = self:getControl("PortraitPanel")
        Dialog.setNumImgForPanel(self, panel, ART_FONT_COLOR.NORMAL_TEXT, friend.lev, false, LOCATE_POSITION.LEFT_TOP, 19)
    end

    -- 设置帮派信息
    if GameMgr:IsCrossDist() and flagName then
        Dialog.setLabelText(self, "PartyLabel", flagName or "")
    else
        Dialog.setLabelText(self, "PartyLabel", friend.faction or "")
    end

    -- 设置按钮信息
    Dialog.bindListener(self, "NoteButton", self.onNoteButton)

    -- 绑定点击事件
    Dialog.bindListener(self, "SingleFriendPanel", self.onChat)

    -- 现在好友可能是NPC，例如客栈（最近联系人）
    if FriendMgr:isNpcByGid(friend.gid) then
        Dialog.setCtrlVisible(self, "NoteButton", false)
        Dialog.setCtrlVisible(self, "NoteImage", false)
    end
end

function SingleFriendDlg:onChat(sender, eventType)
    local name = self.friend.name
    local gid = self.friend.gid
    if not FriendMgr:isBlackByGId(gid) then
        local dlg = FriendMgr:openFriendDlg(true)
        dlg:setChatInfo({name = name, gid = gid, icon = self.friend.icon, level = self.friend.lev}, true)

        DlgMgr:sendMsg("ChatDlg", "hideDoFriendPopup", self.friend.gid)

        Dialog.removeRedDot(self, "PortraitImage")

        RedDotMgr:removeChatRedDot(self.friend.gid)
    end
end

function SingleFriendDlg:onNoteButton(sender, eventType)
    local friendDlg = DlgMgr:showDlg("FriendDlg", true)

    local type = nil
    if FriendMgr:getKuafObjDist(self.friend.gid) then
        type = CHAR_MUNE_TYPE.CITY
    end

    local char = {}
    char.gid = self.friend.gid
    char.name = self.friend.name
    char.level = self.friend.lev
    char.friend_score = self.friend.friendShip
    char.icon = self.friend.icon
    char.party = self.friend.faction
    char.isOnline = self.friend.isOnline
    char.dist_name = FriendMgr:getKuafObjDist(self.friend.gid)
    local rect = Dialog.getBoundingBoxInWorldSpace(self, sender)
    FriendMgr:openCharMenu(char, type, rect)
end

function SingleFriendDlg:setImage(name, path, root)
    if path == nil or string.len(path) == 0 then return end
    local img = self:getControl(name, Const.UIImage, root)
    if img ~= nil then
        img:loadTexture(path)
    end
end

function SingleFriendDlg:getControl(name, type, root)
    root = root or self.root
    local widget = ccui.Helper:seekWidgetByName(root, name)
    return widget
end

function SingleFriendDlg:setLabelText(name, text, root, color3)
    local ctl = self:getControl(name, Const.UILabel, root)
    if nil ~= ctl and text ~= nil then
        ctl:setString(tostring(text))
        if color3 then
            ctl:setColor(color3)
        end
    end
end

-- 为指定的控件对象绑定 TouchEnd 事件
function SingleFriendDlg:bindTouchEndEventListener(ctrl, func)
    if not ctrl then
        Log:W("Dialog:bindTouchEndEventListener no control ")
        return
    end

    -- 事件监听
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local name = sender:getName()
            if string.match(name, "Button") then
                SoundMgr:playEffect("button")
            end

            func(self, sender, eventType)
        end
    end

    ctrl:addTouchEventListener(listener)
end

-- 控件绑定事件
function SingleFriendDlg:bindListener(name, func, root)
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

return SingleFriendDlg
