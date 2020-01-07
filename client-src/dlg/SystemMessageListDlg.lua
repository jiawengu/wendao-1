-- SystemMessageListDlg.lua
-- Created by liuhb Mar/2/2015
-- 系统消息列表界面

local SystemMessageListDlg = class("SystemMessageListDlg")

SystemMessageListDlg.msgPanels = {}
local itemCount = 0
local toLoadItemCount = 0

function SystemMessageListDlg:ctor()
    self:init()
end

function SystemMessageListDlg:init()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/SystemMessageListDlg.json")
    self:bindListener("SystemMessageReturnButton", self.onSystemMessageReturnButton)
    self:bindListener("DelAllMessageButton", self.onDelAllMessageButton)

    local NODE_CLEANUP = Const.NODE_CLEANUP
    local function onNodeEvent(event)
        if NODE_CLEANUP == event then
            itemCount = 0
            toLoadItemCount = 0
            self.dirty = nil
            MessageMgr:unhookByHooker("SystemMessageListDlg")
        end
    end

    self.root:registerScriptHandler(onNodeEvent)

    self.dirty = nil

    -- 获取系统消息数据
    self:retainCtrl()

    -- 更新控件布局
    self:updateView()

    MessageMgr:hook("MSG_MAILBOX_REFRESH", self, "SystemMessageListDlg")
    MessageMgr:hook("MSG_LOGIN_DONE", self, "SystemMessageListDlg")
    MessageMgr:hook("MSG_SWITCH_SERVER", self, "SystemMessageListDlg")
    MessageMgr:hook("MSG_SWITCH_SERVER_EX", self, "SystemMessageListDlg")
    MessageMgr:hook("MSG_SPECIAL_SWITCH_SERVER", self, "SystemMessageListDlg")
    MessageMgr:hook("MSG_SPECIAL_SWITCH_SERVER_EX", self, "SystemMessageListDlg")

    MessageMgr:hook("MSG_MAIL_NOT_EXIST", self, "SystemMessageListDlg")


end

function SystemMessageListDlg:close()
    MessageMgr:unhookByHooker("SystemMessageListDlg")
    SystemMessageListDlg.msgPanels = {}
    itemCount = 0
    toLoadItemCount = 0
    self.dirty = nil

    if self.selectImg then
        self.selectImg:release()
        self.selectImg = nil
    end

    if self.singleMessagePanel then
        self.singleMessagePanel:release()
        self.singleMessagePanel = nil
    end
end

function SystemMessageListDlg:updateView()
    local list, size = self:resetListView("SystemMessageListView", 5)
    self.listCtrl = list
    self.root:stopAllActions()

    -- 对列表进行初始化
    self.hasAcc = false
    self.msgPanels = {}
    local sysMsgList = SystemMessageMgr:getSystemMessageList()
    for i = 1, #sysMsgList do
        local info = sysMsgList[i]
        if not info or not info.name or "" == info.name then
            gf:ftpUploadEx("info.name can't not be empty")
        end
        local func = cc.CallFunc:create(function()
            local haveCreateCtrl = self.msgPanels[info.id]
            if haveCreateCtrl then
                -- 已经创建过了，无需重复创建
                return
            end

            -- 判断是否存在数据，如果不存在数据，也无需创建
            local curInfo = SystemMessageMgr:getSystemMessageById(info.id)
            if nil == curInfo then return end

            self:insertToListView(self:createMessageInfo(info))
            itemCount = itemCount + 1

            -- 更新未读邮件数和总邮件数，未读邮件数在createMessageInfo中更新
            self:updateUI()

            toLoadItemCount = toLoadItemCount - 1
        end)

        toLoadItemCount = toLoadItemCount + 1
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.5 + 0.06 * i), func))
    end

    self:updateUI()
end

-- WDSY-26227
function SystemMessageListDlg:logReport()
    local sysMsgList = SystemMessageMgr:getSystemMessageList()
    performWithDelay(self.root, function()
        local msgs = SystemMessageMgr:getValidAutoMsg()
        local list = self:getControl("SystemMessageListView")
        gf:sendErrInfo(ERR_OCCUR.ERROR_TYPE_MAIL, string.format("%d,%d,%d", gf:getServerTime(), #sysMsgList - #msgs, #(list:getItems()) - #msgs))
    end, 1 + 0.06  * #sysMsgList)
end

function SystemMessageListDlg:updateUI()
    -- 更新未读邮件数和总邮件数
    local totalMsg, _ = SystemMessageMgr:getMailAmount()

    -- 当前邮件显示的未读数量，需要根据listView显示的前50封计算
    local unReadCount = 0
    local showCount = math.min(totalMsg, SystemMessageMgr:getSysMailShowMax())
    local items = self.listCtrl:getItems()
    for i = 1, showCount do
        if items[i] then
            local msg = SystemMessageMgr:getSystemMessageById(items[i].id)
            if msg and msg.status == SystemMessageMgr.SYSMSG_STATUS.UNREAD then
                unReadCount = unReadCount + 1
            end
        end
    end

    self:setLabelText("ReadNumLabel", unReadCount)
end

function SystemMessageListDlg:insertToListView(cell)
    local items = self.listCtrl:getItems()
    local index = #items
    local info = cell.info
    for i = 1, #items do
        local otherInfo = items[i].info
        if otherInfo and info.date >= otherInfo.date then
            index = i - 1
            break
        end
    end

    self.listCtrl:insertCustomItem(cell, index)

    -- 更新listView高度
    self:updateListViewHeight()
end

-- 系统邮件界面listView滚动区域大小，策划要求最多只显示50封邮件，所以限制InnerContainerSize
-- 由于ListView在插入或删除item后，需要在下一帧计算高度，否则下一帧doLayout会将InnerContainerSize恢复为所有item的高度
function SystemMessageListDlg:updateListViewHeight()
    performWithDelay(self.listCtrl, function()
        local contentSize = self.singleMessagePanel:getContentSize()
        local count = self:getItemsCount()
        local height = (contentSize.height + 5) * math.min(count, SystemMessageMgr:getSysMailShowMax())
        self.listCtrl:setInnerContainerSize({width = contentSize.width, height = height})
    end, 0)
end

function SystemMessageListDlg:getCurSelectIndex()
    local img = self:getSelectImg()
    local item = img:getParent()
    if item then
        return self.listCtrl:getIndex(item)
    end
end

function SystemMessageListDlg:updateOneMsgView(info)
    local haveCreateCtrl = self.msgPanels[info.id]

    repeat
        if info.status == SystemMessageMgr.SYSMSG_STATUS.DEL then
            -- 如果是删除邮件
            if haveCreateCtrl then
                local index = self.listCtrl:getIndex(haveCreateCtrl)
                self.listCtrl:removeItem(index)
                self.listCtrl:requestDoLayout()
                self.listCtrl:requestRefreshView()
                self.msgPanels[info.id] = nil
                itemCount = itemCount - 1
                if itemCount <= 0 then
                    itemCount = 0
                    toLoadItemCount = 0
                end
            end

            break
        end

        local isNewOne = false
        if not haveCreateCtrl then
            -- 如果当前列表没有控件
            isNewOne = true
        end

        local func = cc.CallFunc:create(function()
            local itemCtrl = self.msgPanels[info.id]
            local isNewCreate = false

            toLoadItemCount = toLoadItemCount - 1

            if not SystemMessageMgr:getSystemMessageById(info.id) then
                -- 这个邮件的数据已经被删除
                Log:D(string.format("mail(%s) is be deleted.", tostring(info.id)))
                return
            end

            if not itemCtrl then
                isNewCreate = true
            end

            if isNewCreate and SystemMessageMgr:getSystemMessageById(info.id) then
                itemCtrl = self.singleMessagePanel:clone()
                itemCount = itemCount + 1
                if not info or not info.title or "" == info.title then
                    gf:ftpUploadEx("info.title can't not be empty")
                end
            elseif not self.msgPanels[info.id] then
                -- 控件已被删除
                return
            end

            -- 判断是否包含附件
            local hasAcc = not SystemMessageMgr:isAttachmentEmpty(info.attachment)
            -- 判断附件是否被获取
            local hasGetAcc = (info.status ~= SystemMessageMgr.SYSMSG_STATUS.GET)
            self:getControl("AttachmentImage", nil, itemCtrl):setVisible(hasAcc and hasGetAcc)

            -- 标记是否有附件
            self.hasAcc = (hasAcc and hasGetAcc) or self.hasAcc

            -- 判断是否未读
            local isUnRead = SystemMessageMgr.SYSMSG_STATUS.UNREAD == info.status
            self:getControl("SystemImage", nil, itemCtrl):setVisible(not isUnRead)
            self:getControl("SystemWithAccImage", nil, itemCtrl):setVisible(isUnRead)

            -- 设置基本信息
            self:setLabelText("NameLabel", info.title, itemCtrl)
            self:setLabelText("SendtimeLabel", gf:getServerDate("%m-%d %H:%M", tonumber(info.create_time)), itemCtrl)
            if not AutoMsgMgr:isAutoMsg(info) then
                local timeStr = string.format(CHS[5000072], math.max(math.ceil((tonumber(info.expired_time) - tonumber(info.create_time)) / 24 / 60 / 60), 1))
                self:setLabelText("SavetimeLabel", timeStr, itemCtrl)
            else
                self:setLabelText("SavetimeLabel", "", itemCtrl)
            end

            itemCtrl.id = info.id
            info.name = info.title
            info.saveTime = info.expired_time
            info.date = info.create_time

            itemCtrl.info = info
            self.msgPanels[info.id] = itemCtrl

            -- 如果发现选择项目则直接选中
            if self.selectId == info.id then
                local img = self:getSelectImg()
                img:removeFromParent(false)
                itemCtrl:addChild(img)
            end

            if isNewCreate then
                -- 绑定监听
                self:bindTouchEndEventListener(itemCtrl, self.onClickMsg)
                self:insertToListView(itemCtrl)
            end

            -- 收到新邮件和打开邮件时，需要更新邮件数值
            self:updateUI()
        end)

        toLoadItemCount = toLoadItemCount + 1
        if isNewOne then
            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.06 * toLoadItemCount), func))
        else
            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.06), func))
        end

    until true

    -- 更新ListView高度
    self:updateListViewHeight()
end

function SystemMessageListDlg:touchDeal(touch, event, sender)
    local eventCode = event:getEventCode()
    local touchPos = touch:getLocation()
    if eventCode == cc.EventCode.BEGAN then
        local dlg = DlgMgr:getDlgByName("FriendDlg")
        if 4 ~= dlg:getCurDlgIndex() then
            return false
        end

        local bonudingBox = Dialog.getBoundingBoxInWorldSpace(self, sender)
        local listBoundingBox = Dialog.getBoundingBoxInWorldSpace(self, self.listCtrl)
        if cc.rectContainsPoint(bonudingBox, touchPos)
            and cc.rectContainsPoint(listBoundingBox, touchPos) then
            sender.lastPos = touchPos
            return true
        end

        sender.lastPos = nil
        return false
    elseif eventCode == cc.EventCode.ENDED then
        if sender.lastPos and cc.pGetDistance(sender.lastPos, touchPos) < 15 then
            self:onClickMsg(sender, eventCode)
        end

        self.lastPos = nil
    end
end

function SystemMessageListDlg:getSelectImg()
    if nil == self.selectImg then
        -- 创建选择框
        local img = self:getControl("ChoseEffectImage", Const.UIImage)
        img:retain()
        img:setPosition(0, 0)
        img:setAnchorPoint(0, 0)
        self.selectImg = img
    end

    return self.selectImg
end

function SystemMessageListDlg:retainCtrl()
    -- 首先获取附件消息和普通消息模板
    if nil == self.singleMessagePanel then
       self.singleMessagePanel = self:getControl("SystemSinglePanel")
       self.singleMessagePanel:retain()
    end

    self:getSelectImg():removeFromParent(false)
end

function SystemMessageListDlg:createMessageInfo(info)
    if nil == self.singleMessagePanel then return nil end
    if nil == info then return nil end

    local messagePanel = self.singleMessagePanel:clone()

    -- 判断是否包含附件
    local hasAcc = not SystemMessageMgr:isAttachmentEmpty(info.attachment)

    -- 判断附件是否被获取
    local hasGetAcc = (info.status ~= SystemMessageMgr.SYSMSG_STATUS.GET)
    self:getControl("AttachmentImage", nil, messagePanel):setVisible(hasAcc and hasGetAcc)

    -- 标记是否有附件
    self.hasAcc = (hasAcc and hasGetAcc) or self.hasAcc

    -- 判断是否未读
    local isUnRead = SystemMessageMgr.SYSMSG_STATUS.UNREAD == info.status
    self:getControl("SystemImage", nil, messagePanel):setVisible(not isUnRead)
    self:getControl("SystemWithAccImage", nil, messagePanel):setVisible(isUnRead)

    -- 设置基本信息
    if not info or not info.name or "" == info.name then
        gf:ftpUploadEx("info.name can't not be empty")
    end
    self:setLabelText("NameLabel", info.name, messagePanel)
    self:setLabelText("SendtimeLabel", gf:getServerDate("%m-%d %H:%M", tonumber(info.date)), messagePanel)
    if not AutoMsgMgr:isAutoMsg(info) then
        -- math.ceil WDSY-28117  粽子可能1.xx天
        local timeStr = string.format(CHS[5000072], math.max(math.ceil((tonumber(info.saveTime) - tonumber(info.date)) / 24 / 60 / 60), 1))
        self:setLabelText("SavetimeLabel", timeStr, messagePanel)
    else
        self:setLabelText("SavetimeLabel", "", messagePanel)
    end

    messagePanel.index = info.index
    messagePanel.id = info.id

    messagePanel.info = info
    self.msgPanels[info.id] = messagePanel

    -- 如果发现选择项目则直接选中
    if self.selectId == info.id then
        local img = self:getSelectImg()
        img:removeFromParent(false)
        messagePanel:addChild(img)
    end

    -- 绑定监听
    self:bindTouchEndEventListener(messagePanel, self.onClickMsg)

    return messagePanel
end

function SystemMessageListDlg:onClickMsg(sender, eventType)
    local img = self:getSelectImg()
    img:removeFromParent(false)
    sender:addChild(img)
    self.selectId = sender.id

    -- 打开邮件详细信息
    local dlg = DlgMgr:openDlg("SystemMessageShowDlg")
    local winSize =dlg:getWinSize()
    dlg:setShowInfo({index = self.listCtrl:getIndex(sender), id = sender.id})
    dlg.root:setAnchorPoint(0, 0)
    dlg.root:setContentSize(cc.size(dlg.root:getContentSize().width + winSize.width / 2, dlg.root:getContentSize().height))
    dlg.root:setPosition(self.root:getContentSize().width - 42 + (Const.WINSIZE.width - winSize.width) / 2, winSize.oy * 2)
end

-- 根据编号获取item
function SystemMessageListDlg:getItemByIndex(index)
    local itemCtrl = self.listCtrl:getItem(index)
    if not itemCtrl then return end
    return itemCtrl.info
end

-- 获取items总数
function SystemMessageListDlg:getItemsCount()
    return itemCount
end

function SystemMessageListDlg:setSelectMsgId(info)
    self.selectId = info.id
    local msgPanel = self.msgPanels[info.id]
    if nil == msgPanel then return end
    local img = self:getSelectImg()
    img:removeFromParent(false)
    msgPanel:addChild(img)
end

function SystemMessageListDlg:onSystemMessageReturnButton(sender, eventType)
    DlgMgr:sendMsg("FriendDlg", "returnBtn", sender, eventType)
end

-- 一键删除
function SystemMessageListDlg:onDelAllMessageButton(sender, eventType)
    if SystemMessageMgr:hasUnReadSystemMessageAcc() then
        gf:ShowSmallTips(CHS[3003697])
        return
    end

    if SystemMessageMgr:hasSystemMessageAcc() then
        gf:confirm(CHS[5000098], function()
            SystemMessageMgr:deleteSystemMessageOneKey()
            self.root:stopAllActions()
            self:resetListView("SystemMessageListView", 5)
            itemCount = 0
            toLoadItemCount = 0
        end)

        return
    end

    self.root:stopAllActions()
    self:resetListView("SystemMessageListView", 5)
    itemCount = 0
    toLoadItemCount = 0
    SystemMessageMgr:deleteSystemMessageOneKey()
end

function SystemMessageListDlg:onSelectSystemMessageListView(sender, eventType)
end

function SystemMessageListDlg:getControl(name, type, root)
    root = root or self.root
    local widget = ccui.Helper:seekWidgetByName(root, name)
    return widget
end

function SystemMessageListDlg:setLabelText(name, text, root, color3)
    local ctl = self:getControl(name, Const.UILabel, root)
    if nil ~= ctl and text ~= nil then
        ctl:setString(tostring(text))
        if color3 then
            ctl:setColor(color3)
        end
    end
end

-- 为指定的控件对象绑定 TouchEnd 事件
function SystemMessageListDlg:bindTouchEndEventListener(ctrl, func)
    if not ctrl then
        Log:W("Dialog:bindTouchEndEventListener no control ")
        return
    end

    -- 事件监听
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            func(self, sender, eventType)
        end
    end

    ctrl:addTouchEventListener(listener)
end

-- 控件绑定事件
function SystemMessageListDlg:bindListener(name, func, root)
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

function SystemMessageListDlg:resetListView(name, margin, gravity, root)
    margin = margin or 0
    gravity = gravity or ccui.ListViewGravity.left

    local list = self:getControl(name, Const.UIListView, root)
    if nil == list then return end

    list:removeAllItems()
    list:setGravity(ccui.ListViewGravity.left)
    list:setTouchEnabled(true)
    list:setItemsMargin(margin)
    list:setClippingEnabled(true)
    list:setBounceEnabled(false)

    local size = list:getContentSize()
    return list, size
end

function SystemMessageListDlg:MSG_MAIL_NOT_EXIST(data)
    if self.dirty then
        itemCount = 0
        toLoadItemCount = 0
        self:updateView()
        self.dirty = nil
        return
    end

    local info = {id = data.id, status = SystemMessageMgr.SYSMSG_STATUS.DEL}
    self:updateOneMsgView(info)

    -- 删除邮件时，需要更新邮件数值
    self:updateUI()
end

function SystemMessageListDlg:MSG_MAILBOX_REFRESH(data)
    if self.dirty then
        itemCount = 0
        toLoadItemCount = 0
        self:updateView()
        self.dirty = nil
        return
    end

    if nil == data or data.count <= 0 then return end

    -- 更新数据
    local count = data.count
    for i = 1, count do
        if tonumber(data[i].type) == SystemMessageMgr.SYSMSG_TYPE.SYSTEM then
            self:updateOneMsgView(data[i])
        end
    end
    -- 删除邮件时，需要更新邮件数值
    self:updateUI()
end

function SystemMessageListDlg:MSG_LOGIN_DONE(data)
    self.dirty = true
end

function SystemMessageListDlg:MSG_SWITCH_SERVER(data)
    self.dirty = true
end

function SystemMessageListDlg:MSG_SWITCH_SERVER_EX(data)
    self.dirty = true
end

function SystemMessageListDlg:MSG_SPECIAL_SWITCH_SERVER(data)
    self.dirty = true
end

function SystemMessageListDlg:MSG_SPECIAL_SWITCH_SERVER_EX(data)
    self.dirty = true
end

return SystemMessageListDlg
