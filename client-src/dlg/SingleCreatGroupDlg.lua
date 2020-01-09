-- SingleCreatGroupDlg.lua
-- Created by zhengjh Aug/11/2016
-- 添加分组

local SingleCreatGroupDlg = class("SingleCreatGroupDlg")

function SingleCreatGroupDlg:ctor()
    self:init()
end

function SingleCreatGroupDlg:init()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/SingleCreatGroupDlg.json")
    self.name = "SingleCreatGroupDlg"
    self:bindListener("SingleCreatGroupPanel", self.onSingleCreatGroupPanel)
end

function SingleCreatGroupDlg:setData(data)
    self.data = data
    if self.data.type == "friendGroup" then
        Dialog.setCtrlVisible(self, "NameLabel", true)
        Dialog.setCtrlVisible(self, "GroupNameLabel", false)
    elseif self.data.type == "chatGroup" then
        Dialog.setCtrlVisible(self, "NameLabel", false)
        Dialog.setCtrlVisible(self, "GroupNameLabel", true)
    end
end

function SingleCreatGroupDlg:onSingleCreatGroupPanel(sender, eventType)
    local left = 0
    if self.data.type == "friendGroup" then
        left = FriendMgr:getMaxGroupCount() - FriendMgr:getFriendGroupCount()
        if left <= 0 then
            gf:ShowSmallTips(CHS[6000428])
            return
        end
        
        Dialog.setCtrlVisible(self, "NameLable", true)
        Dialog.setCtrlVisible(self, "GroupNameLable", false)
    elseif self.data.type == "chatGroup" then
        left = FriendMgr:getMaxChatGroupCount() - FriendMgr:getChatGroupCount()
        if Me:queryInt("level") < 20 then
            gf:ShowSmallTips(CHS[6000430])
            return
        elseif left <= 0 then
            gf:ShowSmallTips(CHS[6000429])
            return
        end
        Dialog.setCtrlVisible(self, "NameLable", false)
        Dialog.setCtrlVisible(self, "GroupNameLable", true)
    end
        
    self.data.left = left    
    local dlg = DlgMgr:openDlg("GroupCreateDlg")
    dlg:setData(self.data)
end

function SingleCreatGroupDlg:getControl(name, type, root)
    root = root or self.root
    local widget = ccui.Helper:seekWidgetByName(root, name)
    return widget
end

function SingleCreatGroupDlg:setLabelText(name, text, root, color3)
    local ctl = self:getControl(name, Const.UILabel, root)
    if nil ~= ctl and text ~= nil then
        ctl:setString(tostring(text))
        if color3 then
            ctl:setColor(color3)
        end
    end
end

-- 为指定的控件对象绑定 TouchEnd 事件
function SingleCreatGroupDlg:bindTouchEndEventListener(ctrl, func)
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
function SingleCreatGroupDlg:bindListener(name, func, root)
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

return SingleCreatGroupDlg
