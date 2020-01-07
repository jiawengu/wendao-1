-- SingleGroupDlg.lua
-- Created by zhengjh Aug/03/2016
-- 单个群组

local SingleGroupDlg = class("SingleGroupDlg",  function()
    return ccui.Layout:create()
end)

function SingleGroupDlg:ctor()
    self:init()
end

function SingleGroupDlg:init()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/SingleGroupDlg.json")
    self.name = "SingleGroupDlg"
    self:bindListener("NoteButton", self.onNoteButton)
    self:addChild(self.root)
    self:setContentSize(self.root:getContentSize())
end

function SingleGroupDlg:setData(group)
    if not group then return end
    self.group = group
    
    -- 名字
    self:setLabelText("NameLabel", group.group_name)

    -- 人数
    local list =  FriendMgr:getGroupByGroupId(group.group_id)
    local online, total = FriendMgr:getOnlinAndTotaleCounts(list)
    local str = (total or "") .. "/" .. FriendMgr:getMaxMemberNum()
    self:setLabelText("NumLabel", str)
    
    -- 设置图标
    local iconPath = ResMgr:getSmallPortrait(group.icon)
    Dialog.setImage(self, "PortraitImage", iconPath)
    Dialog.setItemImageSize(self, "PortraitImage")

    if RedDotMgr:hasRedDotInfoByDlgName("GroupChat", group.group_id) then
        Dialog.addRedDot(self, "PortraitImage", self.root, RedDotMgr:oneRedDotHasBlink("GroupChat", group.group_id))
    else
        Dialog.removeRedDot(self, "PortraitImage")    
    end
    
    self.isBlink = nil
    
    -- 绑定点击事件
    Dialog.bindListener(self, "SingleFriendPanel", self.onChat)
    
    if Me:queryBasic("gid") == self.group.leader_gid then -- 群主
        Dialog.setCtrlVisible(self, "MsterImage", true)
    else
        -- 成员
        Dialog.setCtrlVisible(self, "MsterImage", false)
    end
    
    local panel = self:getControl("SingleFriendPanel")
    panel:requestDoLayout()
end


function SingleGroupDlg:onChat(sender, eventType)
    local dlg = FriendMgr:openFriendDlg(true)
    dlg:setGroupChatInfo(self.group)
    RedDotMgr:removeOneRedDot("GroupChat", self.group.group_id)  
    Dialog.removeRedDot(self, "PortraitImage")
end

function SingleGroupDlg:onNoteButton(sender, eventType)
    if Me:queryBasic("gid") == self.group.leader_gid then -- 群主
        local dlg = DlgMgr:openDlg("GroupInformationDlg")
        dlg:setGroupData(self.group)
    else
        -- 成员
        local dlg = DlgMgr:openDlg("GroupInformationMemberDlg")
        dlg:setGroupData(self.group)
    end
end

function SingleGroupDlg:setImage(name, path, root)
    if path == nil or string.len(path) == 0 then return end
    local img = self:getControl(name, Const.UIImage, root)
    if img ~= nil then
        img:loadTexture(path)
    end
end

function SingleGroupDlg:getControl(name, type, root)
    root = root or self.root
    local widget = ccui.Helper:seekWidgetByName(root, name)
    return widget
end

function SingleGroupDlg:setLabelText(name, text, root, color3)
    local ctl = self:getControl(name, Const.UILabel, root)
    if nil ~= ctl and text ~= nil then
        ctl:setString(tostring(text))
        if color3 then
            ctl:setColor(color3)
        end
    end
end

-- 为指定的控件对象绑定 TouchEnd 事件
function SingleGroupDlg:bindTouchEndEventListener(ctrl, func)
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
function SingleGroupDlg:bindListener(name, func, root)
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

return SingleGroupDlg
