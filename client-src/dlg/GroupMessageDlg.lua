-- GroupMessageDlg.lua
-- Created by zhengjh Aug/11/2016
-- 群系统消息

local GroupMessageDlg = class("GroupMessageDlg")
local MARGIN_HEIGH = 10
local MARGIN_WIDTH = 10
local CONTENT_TAG = 9996

function GroupMessageDlg:ctor()
    self:init()
end

function GroupMessageDlg:init()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/GroupMessageDlg.json")
    self.name = "GroupMessageDlg"
    self:bindListener("RefuseAllButton", self.onRefuseAllButton)
    self:bindListener("AgreeButton", self.onAgreeButton)
    self:bindListener("RefuseButton", self.onRefuseButton)
    self:bindListener("DelButton", self.onDelButton)
    
    self.timePanel = self:getControl("TimePanel")
    self.timePanel:retain()
    self.timePanel:removeFromParent()
    
    self.contentPanel = self:getControl("ContentPanel")
    self.contentPanel:retain()
    self.contentPanel:removeFromParent()
    
    self.itemSelectImg = self:getControl("SelectedImage", Const.UIImage, self.contentPanel)
    self.itemSelectImg:retain()
    self.itemSelectImg:removeFromParent()
    
    self.ctrlList = {}
    self.selectId = nil
    self.listCtrl = self:getControl("GroupMessageListView")
    
    self.sysMsgQueue = SystemMessageMgr:getGroupMessage()
    self.sysMsgById = {}
    for i = 1, #self.sysMsgQueue do
        self.sysMsgById[self.sysMsgQueue[i].id] = self.sysMsgQueue[i]
    end
    
    self:updateView()
    
    Dialog.hookMsg(self, "MSG_MAILBOX_REFRESH")
    
    Dialog.setCtrlVisible(self, "RefuseButton", false)
    Dialog.setCtrlVisible(self, "AgreeButton", false)
    Dialog.setCtrlVisible(self, "DelButton", false)
end

function GroupMessageDlg:adjustDlgSize(rawHeight, heightScale)

    local panel = self:getControl("GroupMessageListPanel")
    local panelSize = panel:getContentSize()
    local tmpH = rawHeight - panelSize.height
    panel:setContentSize(panelSize.width, rawHeight * heightScale - tmpH)

    -- 进行列表的重新布局
    local listViewCtrl = self:getControl("GroupMessageListView")
    local listViewSize = listViewCtrl:getContentSize()
    tmpH = rawHeight - listViewSize.height
    listViewCtrl:setContentSize(listViewSize.width, rawHeight * heightScale - tmpH )

    -- 对背景图进行布局
   --[[ local bkImageCtrl = self:getControl("MessageBKImage")
    if bkImageCtrl then
        local bkImageSize = bkImageCtrl:getContentSize()
        bkImageCtrl:setContentSize(bkImageSize.width, rawHeight * heightScale - tmpH + 4)
    end]]
end

function GroupMessageDlg:stopSchedule()
    if self.schedulId then
        gf:Unschedule(self.schedulId)
        self.schedulId = nil
    end
end

function GroupMessageDlg:updateView()
    local function insertListView() 
        local day = self:getDayStr(self.sysMsgQueue[1].create_time)
        local itemCtrl =  self.ctrlList[self.sysMsgQueue[1].id] 

        if not itemCtrl then
            local msgCell
            -- 先确认延时期间该消息是否依然存在
            local info = SystemMessageMgr:getOnGroupMessageInfo(self.sysMsgQueue[1].id)
            if not info then
                self.sysMsgById[self.sysMsgQueue[1].id] = nil
                table.remove(self.sysMsgQueue, 1)
                return
            end

            if not self.ctrlList[day] then
                msgCell = self:createContentCell(self.sysMsgQueue[1])
                self.listCtrl:insertCustomItem(msgCell, 0)
                self.ctrlList[self.sysMsgQueue[1].id] = msgCell   
                
                local cell = self:createTimeCell(day)
                self.listCtrl:insertCustomItem(cell, 0)   
                self.ctrlList[day] = {ctrl = cell, count = 1}  
            else
                msgCell = self:createContentCell(self.sysMsgQueue[1])
                self.ctrlList[self.sysMsgQueue[1].id] = msgCell
                local index = self.listCtrl:getIndex(self.ctrlList[day].ctrl)
                self.listCtrl:insertCustomItem(msgCell, index + 1)   
                self.ctrlList[day].count = self.ctrlList[day].count + 1
            end
            
            if not self.selectId and #self.sysMsgQueue == 1 then -- 默认选择
                self:initSelectInfo(msgCell, self.sysMsgQueue[1])
            end
            
            self.listCtrl:requestDoLayout()
            self.listCtrl:requestRefreshView()
        elseif self.sysMsgQueue[1].title == "6" then -- 需要处理邮件
            self:refreshContentCell(itemCtrl, self.sysMsgQueue[1])
            
            if self.selectId == self.sysMsgQueue[1].id then
                self:swichButton(self.sysMsgQueue[1])    
            end
        end
        
        self.sysMsgById[self.sysMsgQueue[1].id] = nil
        table.remove(self.sysMsgQueue, 1)
    end
    
    if not self.schedulId then
        self.schedulId = gf:Schedule(function()
            if #self.sysMsgQueue > 0  then
                insertListView()
            else
                self:stopSchedule()
            end
        end, 0.1)
    end
end

function GroupMessageDlg:getDayStr(time)
    if not time then return end
    return os.date("%Y-%m-%d",time)
end

function GroupMessageDlg:getOursStr(time)
    if not time then return end
    return os.date("[%H:%M]",time) or ""
end

function GroupMessageDlg:createTimeCell(time)
    local cell = self.timePanel:clone()
    Dialog.setLabelText(self, "TimeLabel", time, cell)
    return cell
end

function GroupMessageDlg:createContentCell(data)
    local cell = self.contentPanel:clone()
    self:refreshContentCell(cell, data)
    return cell
end

function GroupMessageDlg:refreshContentCell(cell, data)
    local text =  cell:getChildByTag(CONTENT_TAG)
    if text then
       text:removeFromParent()
    end
    
    local str = ""
    if data.title == "6" then -- 需要处理邮件
        local list = gf:split(data.msg, ";")
        if list[5] == "0" then -- 未操作
            str = CHS[6000433]
        elseif list[5] == "1" then -- 已同意
            str = CHS[6000434]    
        elseif list[5] == "2" then -- 已拒绝    
            str = CHS[6000435]
        end
    end   

    local dataStr = gf:split(data.attachment, "|||")
    local lableText = CGAColorTextList:create(true)
    lableText:setFontSize(19)
    lableText:setString(self:getOursStr(data.create_time) .. " " .. dataStr[1] .. str)
    lableText:setContentSize(cell:getContentSize().width - MARGIN_WIDTH, 0)
    lableText:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    lableText:updateNow()
    local labelW, labelH = lableText:getRealSize()
    cell:setContentSize(cell:getContentSize().width, labelH + MARGIN_HEIGH)
    lableText:setPosition(MARGIN_WIDTH / 2, labelH + MARGIN_HEIGH/ 2)
   
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:initSelectInfo(sender, data)
            self:showCharMenu(data)
        end
    end
    
    local colorLayer = tolua.cast(lableText, "cc.LayerColor")
    colorLayer:setTag(CONTENT_TAG)
    cell:addChild(colorLayer)
    cell:addTouchEventListener(listener)
end

function GroupMessageDlg:showCharMenu(data)
    if data.title == "3" or data.title == "5" then return end -- 解散 和退出群组
    
    local dataStr = gf:split(data.attachment, "|||")
    
    local list = gf:split(dataStr[2], ";") -- "name;gid;icon;level;party_name"
    if not list then return end
    local dlg = DlgMgr:openDlg("CharMenuContentDlg")
    local char = {}
    char.gid = list[2]
    char.name = list[1]
    char.level = tonumber(list[4]) or 0
    char.icon = tonumber(list[3]) or 0
    char.isOnline = 1
    dlg:setInfo(char)
    dlg.root:setPositionX(dlg.root:getPositionX() + 100)   
    
    FriendMgr:requestCharMenuInfo(char.gid)
end

function GroupMessageDlg:initSelectInfo(sender, data)
    local info = SystemMessageMgr:getOnGroupMessageInfo(data.id)
    if info then
    self:swichButton(info)
    self.selectId = data.id
    self:addItemSelcelImage(sender)
end
end

function GroupMessageDlg:addItemSelcelImage(item)
    self.itemSelectImg:removeFromParent()
    item:addChild(self.itemSelectImg)
    self.itemSelectImg:setContentSize(item:getContentSize().width + 4, item:getContentSize().height + 4)
end

function GroupMessageDlg:updateOneMsgView(info)
    local itemCtrl =  self.ctrlList[info.id] 
    
    if info.status == SystemMessageMgr.SYSMSG_STATUS.DEL then
        if itemCtrl then
            local index = self.listCtrl:getIndex(itemCtrl)
            self.listCtrl:removeItem(index)
            self.listCtrl:requestDoLayout()
            self.listCtrl:requestRefreshView()
            self.ctrlList[info.id] = nil
             
            local day = self:getDayStr(info.create_time)
            if self.ctrlList[day] and self.ctrlList[day].count then
                self.ctrlList[day].count  = self.ctrlList[day].count - 1                 
            end
            
            if self.ctrlList[day].count == 0 then -- 删除时间条
                local index = self.listCtrl:getIndex(self.ctrlList[day].ctrl)
                self.listCtrl:removeItem(index)
                self.listCtrl:requestDoLayout()
                self.listCtrl:requestRefreshView()
                self.ctrlList[day] = nil
            end
        end
        
        self.selectId = nil  
        Dialog.setCtrlVisible(self, "RefuseButton", false)
        Dialog.setCtrlVisible(self, "AgreeButton", false)
        Dialog.setCtrlVisible(self, "DelButton", false)
    else
        if not itemCtrl then             
            if not self.sysMsgById[info.id] then
                local cou = #self.sysMsgQueue
                for i = 1, cou do
                    if info.create_time <= self.sysMsgQueue[i].create_time then
                        table.insert(self.sysMsgQueue, i, info)
                        break
                    end
                end
                
                if #self.sysMsgQueue == cou then
                    table.insert(self.sysMsgQueue, cou + 1, info)
                end
                
                if #self.sysMsgQueue == 0 then
                    table.insert(self.sysMsgQueue, 1, info)
                end

                self.sysMsgById[info.id] = info
            elseif info.title == "6" then
                self.sysMsgById[info.id].type = info.type
                self.sysMsgById[info.id].sender = info.sender
                self.sysMsgById[info.id].title = info.title
                self.sysMsgById[info.id].msg = info.msg
                self.sysMsgById[info.id].attachment = info.attachment
                self.sysMsgById[info.id].create_time = info.create_time
                self.sysMsgById[info.id].expired_time = info.expired_time
                self.sysMsgById[info.id].status = info.status
            end
            
            if not self.schedulId then
                self:updateView()
            end
        elseif info.title == "6" then -- 需要处理邮件
            self:refreshContentCell(itemCtrl, info)
            
            if self.selectId == info.id then
                self:swichButton(info)    
            end
        end    

        if self.root:isVisible() and info.status == SystemMessageMgr.SYSMSG_STATUS.UNREAD  then
            SystemMessageMgr:readMsg(info.id)
        end
    end
end

function GroupMessageDlg:swichButton(data)
    if data.title == "6" then
        local list = gf:split(data.msg, ";")
        if list[5] == "0" then -- 未操作
            Dialog.setCtrlVisible(self, "RefuseButton", true)
            Dialog.setCtrlVisible(self, "AgreeButton", true)
            Dialog.setCtrlVisible(self, "DelButton", false)
        else
            Dialog.setCtrlVisible(self, "RefuseButton", false)
            Dialog.setCtrlVisible(self, "AgreeButton", false)
            Dialog.setCtrlVisible(self, "DelButton", true)
        end
    else
        Dialog.setCtrlVisible(self, "RefuseButton", false)
        Dialog.setCtrlVisible(self, "AgreeButton", false)
        Dialog.setCtrlVisible(self, "DelButton", true)
    end
end

function GroupMessageDlg:onRefuseAllButton(sender, eventType)
    gf:confirm(CHS[6000422],function() SystemMessageMgr:deleteAllGroupSystemMsg() end, nil)
end

function GroupMessageDlg:onAgreeButton(sender, eventType)
    if not self.selectId  then return end
    gf:CmdToServer("CMD_ACCEPT_CHAT_GROUP_INVENTE", {id = self.selectId})
end

function GroupMessageDlg:onRefuseButton(sender, eventType)
    if not self.selectId  then return end
    gf:CmdToServer("CMD_REFUSE_CHAT_GROUP_INVENTE", {id = self.selectId}) 
end

function GroupMessageDlg:onDelButton(sender, eventType)
    SystemMessageMgr:deleteGroupSystemMessge(self.selectId)
end

function GroupMessageDlg:MSG_MAILBOX_REFRESH(data)
    for i = 1, data.count do
        if data[i].type == SystemMessageMgr.SYSMSG_TYPE.TYPE_MAIL_CHATGROUP  then
            self:updateOneMsgView(data[i])
        end
    end
end

function GroupMessageDlg:close()
    Dialog.unhookMsg(self)
    if self.timePanel then
        self.timePanel:release()
        self.timePanel = nil
    end
    
    if self.contentPanel then
        self.contentPanel:release()
        self.contentPanel = nil
    end
      
    if self.itemSelectImg then
        self.itemSelectImg:release()
        self.itemSelectImg = nil
    end 
    
    self:stopSchedule()
    
    self.ctrlList = {}
end

function GroupMessageDlg:getControl(name, type, root)
    root = root or self.root
    local widget = ccui.Helper:seekWidgetByName(root, name)
    return widget
end

-- 为指定的控件对象绑定 TouchEnd 事件
function GroupMessageDlg:bindTouchEndEventListener(ctrl, func)
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
function GroupMessageDlg:bindListener(name, func, root)
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

return GroupMessageDlg
