-- FriendVerifyDlg.lua
-- Created by liuhb Feb/28/2015
-- 系统消息和好友验证条目

local FriendVerifyDlg = class("FriendVerifyDlg")

function FriendVerifyDlg:ctor()
    self:init()
end

function FriendVerifyDlg:init()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/FriendVerifyDlg.json")
    self.name = "FriendVerifyDlg"
    
    Dialog.hookMsg(self, "MSG_MAILBOX_REFRESH")
end

function FriendVerifyDlg:setShowType(type)
    local func = ""
    self.type = type
    if nil == type or 0 == type then 
        -- 默认模式
        -- todo
       -- Dialog.setLabelText(self, "NamePatyLabel", CHS[5000096])
        -- Dialog.bindListener(self, "SingleFriendPanel", self.onFriendRequist)
        func = "onFriendRequist"
    elseif 1 == type then
        -- 系统消息模式
        -- todo
       -- Dialog.setLabelText(self, "NamePatyLabel", CHS[5000097])
        -- Dialog.bindListener(self, "SingleFriendPanel", self.onSystemMsg)
        func = "onSystemMsg"
    end
    
    local itemCtrl = Dialog.getControl(self, "SingleFriendPanel")
    itemCtrl:setTouchEnabled(false)
    local listener = cc.EventListenerTouchOneByOne:create()
    local function TouchDeal(touch, event) 
        local dlg = DlgMgr:getDlgByName("FriendDlg")
        if 1 ~= dlg:getCurDlgIndex() then
            return false
        end
        
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        if eventCode == cc.EventCode.BEGAN then
            local bonudingBox = Dialog.getBoundingBoxInWorldSpace(self, itemCtrl)
            if cc.rectContainsPoint(bonudingBox, touchPos) then
                self.lastPos = touchPos
                return true
            end

            self.lastPos = nil            
            return false
        elseif eventCode == cc.EventCode.ENDED then
            if self.lastPos and cc.pGetDistance(self.lastPos, touch:getLocation()) < 15 then
                self[func](self, itemCtrl)
            end

            self.lastPos = nil
        end
    end

    listener:setSwallowTouches(false)
    listener:registerScriptHandler(TouchDeal, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(TouchDeal, cc.Handler.EVENT_TOUCH_ENDED)

    local dispatcher = itemCtrl:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, itemCtrl)
    
    if FriendMgr:hasFriendCheck() then
        Dialog.addRedDot(self, "PortraitImage")
    end
end

function FriendVerifyDlg:onFriendRequist(sender, eventType)
    local dlg = DlgMgr:openDlg("FriendDlg")
    dlg:setFriendVerfyInfo({})
    
    Dialog.removeRedDot(self, "PortraitImage")
end

function FriendVerifyDlg:onSystemMsg(sender, eventType)
    local dlg = DlgMgr:openDlg("FriendDlg")
    dlg:setSystemMsgInfo({})

    Dialog.removeRedDot(self, "PortraitImage")
end

function FriendVerifyDlg:setImage(name, path, root)
    if path == nil or string.len(path) == 0 then return end
    local img = self:getControl(name, Const.UIImage, root)
    if img ~= nil then
        img:loadTexture(path)
    end
end

function FriendVerifyDlg:getControl(name, type, root)
    root = root or self.root
    local widget = ccui.Helper:seekWidgetByName(root, name)
    return widget
end

function FriendVerifyDlg:setLabelText(name, text, root, color3)
    local ctl = self:getControl(name, Const.UILabel, root)
    if nil ~= ctl and text ~= nil then
        ctl:setString(tostring(text))
        if color3 then
            ctl:setColor(color3)
        end
    end
end

-- 为指定的控件对象绑定 TouchEnd 事件
function FriendVerifyDlg:bindTouchEndEventListener(ctrl, func)
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
function FriendVerifyDlg:bindListener(name, func, root)
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

function FriendVerifyDlg:MSG_MAILBOX_REFRESH(data)
    for i = 1, data.count do
        if data[i].type == SystemMessageMgr.SYSMSG_TYPE.SYSTEM and 1 == self.type then
            Dialog.addRedDot(self, "PortraitImage")
        elseif data[i].type == SystemMessageMgr.SYSMSG_TYPE.FRIEND_CHECK and (0 == self.type or nil == self.type) and data[i].status == 0 then
            Dialog.addRedDot(self, "PortraitImage")
        end
    end
end

return FriendVerifyDlg
