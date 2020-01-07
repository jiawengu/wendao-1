-- FriendVerifyOperateDlg.lua
-- Created by liuhb Mar/06/2015
-- 好友验证操作界面

local FriendVerifyOperateDlg = class("FriendVerifyOperateDlg")
local panelList = {}
local actionList = {}
local panleCount = 0
local needLoadCount = 0

local COLORTEXT_TAG = 99

function FriendVerifyOperateDlg:ctor()
    self:init()
end

function FriendVerifyOperateDlg:init()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/FriendVerifyOperateDlg.json")

    self:bindListener("FriendVerifyReturnButton", self.onReturnButton)
    -- self:bindListener("RefuseAllButton", self.onRefuseAllButton)
    self:bindListener("ClearAllButton", self.onClearAllButton)
    self:bindListener("AgreeButton", self.onAgreeButton)
    self:bindListener("RefuseButton", self.onRefuseButton)
    self:bindListener("PortraitPanel", self.onPortraitPanel)
    self:bindListener("SingleVerifyPanel", self.onChat)
    self.name = "FriendVerifyOperateDlg"

    -- 初始化界面
    self.singlePanel = self:getControl("SingleVerifyPanel")
    self.singlePanel:retain()
    self.singlePanel:removeFromParent()
    
    local mPanel = self:getControl("MessagePanel", nil, self.singlePanel)
    self.msgPanelWidth = mPanel:getContentSize().width
    
    self:updateList()
    
    Dialog.hookMsg(self, "MSG_MAILBOX_REFRESH")
    Dialog.hookMsg(self, "MSG_CHAR_INFO")
    Dialog.hookMsg(self, "MSG_FIND_CHAR_MENU_FAIL")
end

function FriendVerifyOperateDlg:adjustDlgSize(rawHeight, heightScale)

    local panel = self:getControl("FriendVerifyOperatePanel")
    local panelSize = panel:getContentSize()
    local tmpH = rawHeight - panelSize.height
    panel:setContentSize(panelSize.width, rawHeight * heightScale - tmpH)

    -- 进行列表的重新布局
    local listViewCtrl = self:getControl("ListView")
    local listViewSize = listViewCtrl:getContentSize()
    tmpH = rawHeight - listViewSize.height
    listViewCtrl:setContentSize(listViewSize.width, rawHeight * heightScale - tmpH)

    -- 对背景图进行布局
    local bkImageCtrl = self:getControl("MessageBKImage")
    if bkImageCtrl then
        local bkImageSize = bkImageCtrl:getContentSize()
        bkImageCtrl:setContentSize(bkImageSize.width, rawHeight * heightScale - tmpH + 4)
    end
end

function FriendVerifyOperateDlg:close()
    Dialog.unhookMsg(self)
    panelList = {}
    actionList = {}
    panleCount = 0
    needLoadCount = 0

    self.root = nil

    if self.singlePanel then
        self.singlePanel:release()
        self.singlePanel = nil
    end
end

function FriendVerifyOperateDlg:setSinglePanel(data, cell, msg)
    -- 设置图标
    local iconPath = ResMgr:getSmallPortrait(data.icon)
    Dialog.setImage(self, "PortraitImage", iconPath, cell)
    if 1 ~= data.isOnline then
        local imgCtrl = Dialog.getControl(self, "PortraitImage", Const.UIImage, cell)
        gf:grayImageView(imgCtrl)
    else
        local imgCtrl = Dialog.getControl(self, "PortraitImage", Const.UIImage, cell)
        gf:resetImageView(imgCtrl)
    end
    
    -- 设置名字
    local realName, flagName = gf:getRealNameAndFlag(data.name)
    if 2 == data.isOnline then
        self:setLabelText("NamePatyLabel", realName, cell, COLOR3.BROWN)
    elseif 0 == data.isVip then
        Dialog.setLabelText(self, "NamePatyLabel", realName, cell, COLOR3.GREEN)
    elseif 0 ~= data.isVip then
        Dialog.setLabelText(self, "NamePatyLabel", realName, cell, COLOR3.CHAR_VIP_BLUE_EX)
    end
    
    Dialog.setNumImgForPanel(self, "PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT,
        data.lev, false, LOCATE_POSITION.LEFT_TOP, 19, cell)
    
    cell.data = data
    cell:setName(data.gid)
    
    -- 滚动动画
    local panel = self:getControl("MessagePanel", nil, cell):getChildByTag(COLORTEXT_TAG)
    if not panel and msg then
        local panel, textW = self:setColorText(msg, "MessagePanel", cell)
        if panel and textW > self.msgPanelWidth then
            local moveX = textW + self.msgPanelWidth
            local moveT = moveX * 0.04
            local action = cc.RepeatForever:create(cc.Sequence:create(
                cc.MoveBy:create(moveT, cc.p(-moveX, 0)),
                cc.Place:create(cc.p(self.msgPanelWidth, 0))
            ))
            
            panel:setPosition(self.msgPanelWidth, 0)
            panel:runAction(action)
        end
    end
end

-- 初始化界面
function FriendVerifyOperateDlg:updateList()
    -- 移除选择框
    local requestList = FriendMgr:getFriendCheck()
    if nil == requestList then return end

    local list = self:resetListView("ListView", 5)
    self.listCtrl = list
    panelList = {}
    actionList = {}
    panleCount = 0
    needLoadCount = 0
    for i = 1, #requestList do
        local func = cc.CallFunc:create(function()
            if panelList[requestList[i].id] then
                -- 已经创建过控件了，无需重复创建
                self:stopActionById(requestList[i].id)
                return
            end

            local msg = SystemMessageMgr:getSystemMessageById(requestList[i].id)
            if not msg then
                -- 已经找不到邮件数据了，无需创建
                self:stopActionById(requestList[i].id)
                return
            end

            local cell = self.singlePanel:clone()
            local text, textFilt = gf:filtText(msg.msg, nil, true)
            self:setSinglePanel(requestList[i], cell, text)
            list:pushBackCustomItem(cell)
            
            panelList[requestList[i].id] = cell
            panleCount = panleCount + 1
            
            self:stopActionById(requestList[i].id)
            self:updateUI()
        end)

        self:stopActionById(requestList[i].id)
        
        self:creatAction(requestList[i].id, func)
    end

    if #requestList == 0 then  -- 增加该判断。requestList 为好友验证条目信息，同郑锦华讨论，若没有对该信息为0判断， panleCount 还未被赋值，导致updateUI中删除了小红点
        self:updateUI()
    end
end

function FriendVerifyOperateDlg:stopActionById(id)
    if actionList[id] then
        self.root:stopAction(actionList[id])

        actionList[id] = nil
        needLoadCount = math.max(0, needLoadCount - 1)
    end
end

function FriendVerifyOperateDlg:creatAction(id, func)
    needLoadCount = needLoadCount + 1
    actionList[id] = self.root:runAction(cc.Sequence:create(cc.DelayTime:create(1 * needLoadCount), func))
end

-- 更新UI界面
function FriendVerifyOperateDlg:updateUI()
    if 0 == panleCount then
        -- 如果没有验证消息
        Dialog.setCtrlEnabled(self, "ClearAllButton", false)

        if RedDotMgr:getRedDotList("FriendDlg") and RedDotMgr:getRedDotList("FriendDlg")["NewFriendButton"] then
            RedDotMgr:removeOneRedDot("FriendDlg", "NewFriendButton")
            RedDotMgr:removeOneRedDot("FriendDlg", "FriendCheckBox")
        end
    else
        Dialog.setCtrlEnabled(self, "ClearAllButton", true)
    end
end

-- 获取items总数
function FriendVerifyOperateDlg:getItemsCount()
    local items = self.listCtrl:getItems()

    return #items
end

-- 更新一条验证信息
function FriendVerifyOperateDlg:updateOneVerify(data)
    local itemCtrl = panelList[data.id]

    self:stopActionById(data.id)

    repeat
        if data.status == SystemMessageMgr.SYSMSG_STATUS.DEL then
            if itemCtrl then
                local index = self.listCtrl:getIndex(itemCtrl)
                self.listCtrl:removeItem(index)
                self.listCtrl:requestDoLayout()
                self.listCtrl:requestRefreshView()
                panelList[data.id] = nil
                panleCount = panleCount - 1
                self:updateUI()
            end
            
            break
        end

        local isNewOne = false
        if not itemCtrl then
            isNewOne = true
        end
        
        local function func()
            local itemCtrl = panelList[data.id]

            local msg = SystemMessageMgr:getSystemMessageById(data.id)
            if not msg then
                -- 已经找不到邮件数据了，无需创建
                self:stopActionById(data.id)
                return
            end
            
            if not itemCtrl then
                itemCtrl = self.singlePanel:clone()
                panleCount = panleCount + 1

                self.listCtrl:pushBackCustomItem(itemCtrl)
            end
            
            -- 验证信息
            local text, textFilt = gf:filtText(msg.msg, nil, true)
            self:setSinglePanel(data, itemCtrl, text)
            panelList[data.id] = itemCtrl

            self:stopActionById(data.id)
            self:updateUI()
        end
        
        if isNewOne then
            self:creatAction(data.id, cc.CallFunc:create(function() func() end))
        else
            func()
        end
    until true
end

function FriendVerifyOperateDlg:onReturnButton(sender, eventType)
    DlgMgr:sendMsg("FriendDlg", "returnBtn", sender, eventType)
    DlgMgr:sendMsg("FriendDlg", "removeVerifyRedDot")
end

function FriendVerifyOperateDlg:onClearAllButton(sender, eventType)
    gf:confirm(CHS[6200041], function ()
        if self.root then
            self.root:stopAllActions()
            actionList = {}
            needLoadCount = 0
        end
        
        SystemMessageMgr:deleteFriendCheckOneKey()
    end)
end

function FriendVerifyOperateDlg:onRefuseButton(sender, eventType)
    local data = sender:getParent().data
    if not data then return end

    FriendMgr:refuseFriend(data.id)
end

function FriendVerifyOperateDlg:onAgreeButton(sender, eventType)
    local cell = sender:getParent()
    local data = cell.data
    if not data then return end

    FriendMgr:agreeFriend(data.id)
end

function FriendVerifyOperateDlg:onChat(sender, eventType)
    local data = sender.data
    if not data then return end
    
    FriendMgr:communicat(data.name, data.gid, data.icon, data.level)
end

function FriendVerifyOperateDlg:onPortraitPanel(sender, eventType)
    local data = sender:getParent().data
    if not data then return end
    
    if data.gid ~= Me:queryBasic("gid") then
        local dlg = DlgMgr:openDlg("CharMenuContentDlg")

        FriendMgr:requestCharMenuInfo(data.gid, nil, "FriendVerifyOperateDlg", nil, data.id)
        if FriendMgr:getCharMenuInfoByGid(data.gid) then
            dlg:setting(data.gid)
        else
            local char = {}
            char.gid = data.gid
            char.name = data.name
            char.level = data.lev
            char.icon = data.icon
            char.isOnline = 2
            dlg:setInfo(char)
        end

        local rect = sender:getBoundingBox()
        local pt = sender:convertToWorldSpace(cc.p(0, 0))
        rect.x = pt.x
        rect.y = pt.y
        rect.width = rect.width * Const.UI_SCALE
        rect.height = rect.height * Const.UI_SCALE
        dlg:setFloatingFramePos(rect)
    end
end

function FriendVerifyOperateDlg:getControl(name, widgetType, root)
    local widget = nil
    if type(root) == "string" then
        root = self:getControl(root, "ccui.Widget")
        widget = ccui.Helper:seekWidgetByName(root, name)
    else
        root = root or self.root
        widget = ccui.Helper:seekWidgetByName(root, name)
    end
    
    return widget
end

function FriendVerifyOperateDlg:setLabelText(name, text, root, color3)
    local ctl = self:getControl(name, Const.UILabel, root)
    if nil ~= ctl and text ~= nil then
        ctl:setString(tostring(text))
        if color3 then
            ctl:setColor(color3)
        end
    end
end

-- 为指定的控件对象绑定 TouchEnd 事件
function FriendVerifyOperateDlg:bindTouchEndEventListener(ctrl, func)
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
function FriendVerifyOperateDlg:bindListener(name, func, root)
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

function FriendVerifyOperateDlg:resetListView(name, margin, gravity, root)
    margin = margin or 0
    gravity = gravity or ccui.ListViewGravity.left

    local list = self:getControl(name, Const.UIListView, root)
    if nil == list then return end

    list:removeAllItems()
    list:setGravity(ccui.ListViewGravity.left)
    list:setTouchEnabled(true)
    list:setItemsMargin(margin)
    list:setClippingEnabled(true)
    list:setBounceEnabled(true)

    local size = list:getContentSize()
    return list, size
end

-- 显示字符串
function FriendVerifyOperateDlg:setColorText(str, panelName, root)
    local panel = self:getControl(panelName, Const.UIPanel, root)
    if not panel then return end
    
    panel:removeAllChildren()
    
    local defColor = COLOR3.EQUIP_BLACK
    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(19)
    textCtrl:setString(str, true)
    textCtrl:setContentSize(960, 0)
    textCtrl:setDefaultColor(defColor.r, defColor.g, defColor.b)
    textCtrl:updateNow()

    local textW, textH = textCtrl:getRealSize()
    local node = tolua.cast(textCtrl, "cc.LayerColor")
    node:setTag(COLORTEXT_TAG)
    node:setAnchorPoint(0, 0)
    node:setPosition(0, 0)
    panel:addChild(node)
    return node, textW
end

function FriendVerifyOperateDlg:MSG_CHAR_INFO(data)
    if data.msg_type ~= "FriendVerifyOperateDlg" or data.gid == "" then
        return
    end

    local cell = self.listCtrl:getChildByName(data.gid)
    if cell and cell.data then
        cell.data.name = data.name
        cell.data.icon = data.icon
        cell.data.lev = data.level
        cell.data.isVip = data.vip
        cell.data.isOnline = 1
        self:setSinglePanel(cell.data, cell)
    end
end

function FriendVerifyOperateDlg:MSG_FIND_CHAR_MENU_FAIL(data)
    if data.msg_type ~= "FriendVerifyOperateDlg" or data.char_id == "" then
        return
    end

    local cell = self.listCtrl:getChildByName(data.char_id)
    if cell and cell.data then
        cell.data.isOnline = 2
        self:setSinglePanel(cell.data, cell)
    end
end

function FriendVerifyOperateDlg:MSG_MAILBOX_REFRESH(data)
    if nil == data or data.count <= 0 then return end

    local count  = data.count
    for i = 1, count do
        if data[i].type == SystemMessageMgr.SYSMSG_TYPE.FRIEND_CHECK then
            local lev, icon, party, isVip = string.match(data[i].attachment, "(%d+);(%d+);(.*);(%d+)")
            if not lev then
                lev, icon, party = string.match(data[i].attachment, "(%d+);(%d+);(.*)")
            end
            self:updateOneVerify({
                id = data[i].id,
                gid = data[i].title,
                name = data[i].sender or "",
                lev = lev,
                icon = icon,
                faction = party,
                isVip = isVip and tonumber(isVip),
                isOnline = 1,
                status = data[i].status
            })
        end
    end

    -- self:updateList()
end

return FriendVerifyOperateDlg
