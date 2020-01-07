-- FriendInstallDlg.lua
-- Created by zhengjh Aug/04/2016
-- 好友设置

local FriendInstallDlg = class("FriendInstallDlg")

function FriendInstallDlg:ctor()
    self:init()
end

function FriendInstallDlg:init()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/FriendInstallDlg.json")
    self.name = "FriendInstallDlg"
    self:bindListener("DelButton", self.onDelButton)
    
    Dialog.bindEditFieldForSafe(self, "AutoReplyPanel", 20, "DelButton", cc.VERTICAL_TEXT_ALIGNMENT_TOP, self.textEventCallBack)
    
    -- 获取系统设置状态
    local settingTable = SystemSettingMgr:getSettingStatus()
    
    -- 好友验证
    local isOn = settingTable["verify_be_added"] == 1 
    local refusePanel = self:getControl("RefuseFriendPanel")
    local switchPanel = self:getControl("SwitchPanel", nil, refusePanel)
    Dialog.createSwichButton(self, switchPanel, isOn, self.OnFriendVerifyButton)
    
    -- 拒绝陌生消息
    local refuseStrangerOn = settingTable["refuse_stranger_msg"] == 1 
    local refuseStrangerPanel = self:getControl("RefuseStrangerPanel")
    local refuseStrangeStatePanel = self:getControl("SwitchPanel", nil, refuseStrangerPanel)
    Dialog.createSwichButton(self, refuseStrangeStatePanel, refuseStrangerOn, self.OnRefuseStranger, nil, function(sender, isOn)
        if not isOn then
            if not self.level or self.level == 0 then 
                gf:ShowSmallTips(CHS[6000418]) 
                return true 
            elseif self.level < 2 then
                gf:ShowSmallTips(CHS[6000417])
                return true
            end
        end
    end)
    
    -- 自动回复开关
    local isOn = settingTable["auto_reply_msg"] == 1 
    self.autoReplyIsOn = isOn
    local replyPanel = self:getControl("AutoReplyPanel")
    local switchPanel = self:getControl("SwitchPanel", nil, replyPanel)
    Dialog.createSwichButton(self, switchPanel, isOn, self.OnAutoRelyButton, nil, function (sender, isOn)
        local panel = self:getControl("InputPanel")
        local inputText = Dialog.getInputText(self, "TextField", panel)
        if not isOn and (not inputText or string.len(inputText) == 0) then 
            gf:ShowSmallTips(CHS[6000421])  
            return true
        end
        
        local inputText = Dialog.getInputText(self, "TextField", panel)
        local filtTextStr, haveFilt = gf:filtText(inputText)
        if haveFilt then
            Dialog.setInputText(self, "TextField", filtTextStr, panel)
            return
        end
        
    end)
    
    -- 好友拒绝
    local isOn = settingTable["refuse_be_added"] == 1 
    local refuseApplyPanel = self:getControl("RefuseApplyPanel")
    local switchPanel = self:getControl("SwitchPanel", nil, refuseApplyPanel)
    Dialog.createSwichButton(self, switchPanel, isOn, self.OnRefuseApplyButton, nil, function (sender, isOn)
        if not isOn then
            if not self.friendLevel or self.friendLevel == 0 then 
                gf:ShowSmallTips(CHS[6000424]) 
                return true 
            elseif self.friendLevel < 2 then
                gf:ShowSmallTips(CHS[6000417])
                return true
            end
        end
    end)
    
    -- 师徒申请提示 
    local isOn = nil
    if settingTable["apply_apprentice_mail"] == 0 then
        isOn = false
    else
        isOn = true
    end
    
    local refuseMasterPanel = self:getControl("RefuseMasterPanel")
    local switchPanel = self:getControl("SwitchPanel", nil, refuseMasterPanel)
    Dialog.createSwichButton(self, switchPanel, isOn, self.OnRefuseMasterButton)
    
    
    -- 好友消息气泡
    local isOn = nil
    if settingTable["friend_msg_bubble"] == 0 then
        isOn = false
    else
        isOn = true
    end
    
    local friendPopupPanel = self:getControl("MessageBubblePanel")
    local switchPanel = self:getControl("SwitchPanel", nil, friendPopupPanel)
    Dialog.createSwichButton(self, switchPanel, isOn, self.onFriendPopupButton)

    -- 数字输入框
    Dialog.bindNumInput(self, "LevelValuePanel", refuseStrangerPanel, nil, "stranger")
    Dialog.bindNumInput(self, "LevelValuePanel", refuseApplyPanel, nil, "friend")
    
    self:setUiInfo()
end

function FriendInstallDlg:textEventCallBack(sender, eventType)
     -- 获取系统设置状态
    if ccui.TextFiledEventType.insert_text == eventType  or ccui.TextFiledEventType.delete_backward == eventType then
        self:closeAutoReply()
    elseif ccui.TextFiledEventType.detach_with_ime == eventType then
        local inputText = sender:getStringValue()
        local filtTextStr, haveFilt = gf:filtText(inputText)
        if haveFilt then
            sender:setText(filtTextStr)
        end
    end
end

function FriendInstallDlg:setUiInfo()
    -- 拒绝陌生人等级
    local refuseStrangerPanel = self:getControl("RefuseStrangerPanel")
    self.level = Me:queryInt("setting/refuse_stranger_level") 
    if self.level == 0 then
        Dialog.setLabelText(self, "LevelLabel", "", refuseStrangerPanel)  
    else
        Dialog.setLabelText(self, "LevelLabel", self.level, refuseStrangerPanel)  
    end

    
    -- 拒绝好友申请等级
    local refuseApplyPanel = self:getControl("RefuseApplyPanel")
    self.friendLevel = Me:queryInt("setting/refuse_be_add_level") 
    
    if self.friendLevel == 0 then
        Dialog.setLabelText(self, "LevelLabel", "", refuseApplyPanel)
    else
        Dialog.setLabelText(self, "LevelLabel", self.friendLevel, refuseApplyPanel)
    end
    
    -- 自动回复消息
    local panel = self:getControl("InputPanel")
    local msg = Me:queryBasic("setting/auto_reply_msg")
    
    if msg and string.len(msg) ~= 0 then
        Dialog.setInputText(self, "TextField", msg, panel)
        self:getControl("DelButton"):setVisible(true)
        self:setCtrlVisible("DefaultLabel", false)
    else    
        self:setCtrlVisible("DefaultLabel", true)
        Dialog.setInputText(self, "TextField", "", panel)
        self:getControl("DelButton"):setVisible(false)
    end
end

-- 数字键盘插入数字
function FriendInstallDlg:insertNumber(num, key)
    if key == "stranger" then
        self:updateStrangerLevel(num)
    elseif key == "friend" then
        self:updateFriendLevel(num)
    end
end

function FriendInstallDlg:updateStrangerLevel(num)
    self.level = num

    if num > 150 then
        self.level = 150
        gf:ShowSmallTips(CHS[6000416])
   --[[ elseif num < 2 then
        self.level = 2
        gf:ShowSmallTips(CHS[6000417])]]
    end

    local refuseStrangerPanel = self:getControl("RefuseStrangerPanel")
    Dialog.setLabelText(self, "LevelLabel", self.level, refuseStrangerPanel)

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(self.level)
    end

    --gf:CmdToServer("CMD_SET_REFUSE_STRANGER_CONFIG", {level =  self.level})
    local switchPanel = self:getControl("SwitchPanel", nil, refuseStrangerPanel)
    if  Dialog.getButtonStatus(self, switchPanel) then
        Dialog.switchButtonStatusWithAction(self, switchPanel, false)
        gf:ShowSmallTips(CHS[6800000])  
    end
end

function FriendInstallDlg:updateFriendLevel(num)
    self.friendLevel = num

    if num > 150 then
        self.friendLevel = 150
        gf:ShowSmallTips(CHS[6000416])
    --[[elseif num < 2 then
        self.friendLevel = 2
        gf:ShowSmallTips(CHS[6000417])]]
    end

    
    local refuseApplyPanel = self:getControl("RefuseApplyPanel")
    Dialog.setLabelText(self, "LevelLabel", self.friendLevel, refuseApplyPanel)

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(self.friendLevel)
    end

    --gf:CmdToServer("CMD_SET_REFUSE_BE_ADD_CONFIG", {level =  self.friendLevel})
    
    local switchPanel = self:getControl("SwitchPanel", nil, refuseApplyPanel)
    if  Dialog.getButtonStatus(self, switchPanel) then
        Dialog.switchButtonStatusWithAction(self, switchPanel, false)
        gf:ShowSmallTips(CHS[6800000])
    end
end

function FriendInstallDlg:OnRefuseStranger(isOn)
    SystemSettingMgr:sendSeting("refuse_stranger_msg", isOn and 1 or 0)
    if isOn then
        gf:ShowSmallTips(CHS[6000420])
        gf:CmdToServer("CMD_SET_REFUSE_STRANGER_CONFIG", {level =  self.level})
    else
        gf:ShowSmallTips(CHS[6000419])
    end
end

function FriendInstallDlg:OnFriendVerifyButton(isOn)
    SystemSettingMgr:sendSeting("verify_be_added", isOn and 1 or 0)
    
    if isOn then
        gf:ShowSmallTips(CHS[6400089])
    else
        gf:ShowSmallTips(CHS[6400088])
    end
end

function FriendInstallDlg:OnAutoRelyButton(isOn)
    self.autoReplyIsOn = isOn
    SystemSettingMgr:sendSeting("auto_reply_msg", isOn and 1 or 0)
    
    if isOn then
        gf:ShowSmallTips(CHS[6000415])
        local panel = self:getControl("InputPanel")
        local inputText = Dialog.getInputText(self, "TextField", panel)
        gf:CmdToServer("CMD_SET_AUTO_REPLY_MSG_CONFIG", {content = inputText})
    else
        gf:ShowSmallTips(CHS[6000414])
    end
end

function FriendInstallDlg:OnRefuseMasterButton(isOn)
    SystemSettingMgr:sendSeting("apply_apprentice_mail", isOn and 1 or 0)
    
    if isOn then
        gf:ShowSmallTips(CHS[6200055])
    else
        gf:ShowSmallTips(CHS[6200056])
    end
end

function FriendInstallDlg:onFriendPopupButton(isOn)
    SystemSettingMgr:sendSeting("friend_msg_bubble", isOn and 1 or 0)

    if isOn then
        gf:ShowSmallTips(CHS[7003068])
    else
        gf:ShowSmallTips(CHS[7003069])
    end
end

function FriendInstallDlg:OnRefuseApplyButton(isOn)
    SystemSettingMgr:sendSeting("refuse_be_added", isOn and 1 or 0)
    
    if isOn then
        gf:ShowSmallTips(CHS[6000425])
        gf:CmdToServer("CMD_SET_REFUSE_BE_ADD_CONFIG", {level =  self.friendLevel})
    else
        gf:ShowSmallTips(CHS[6000423])
    end
end

function FriendInstallDlg:onDelButton(sender, eventType)
    local panel = self:getControl("InputPanel")
    Dialog.setInputText(self, "TextField", "", panel)
    self:getControl("DelButton"):setVisible(false)
    self:setCtrlVisible("DefaultLabel", true)
    
    self:closeAutoReply()
end

function FriendInstallDlg:closeAutoReply()
    if self.autoReplyIsOn then
        gf:ShowSmallTips(CHS[6400090])
        local replyPanel = self:getControl("AutoReplyPanel")
        local switchPanel = self:getControl("SwitchPanel", nil, replyPanel)
        Dialog.switchButtonStatusWithAction(self, switchPanel, false)
        SystemSettingMgr:sendSeting("auto_reply_msg", 0) 
        self.autoReplyIsOn = false
    end
end

function FriendInstallDlg:getControl(name, type, root)
    root = root or self.root
    local widget = ccui.Helper:seekWidgetByName(root, name)
    return widget
end

-- 设置控件的可见性
function FriendInstallDlg:setCtrlVisible(ctrlName, visible, root)
    local ctrl = self:getControl(ctrlName, nil, root)
    if ctrl then
        ctrl:setVisible(visible)
    end
end

-- 为指定的控件对象绑定 TouchEnd 事件
function FriendInstallDlg:bindTouchEndEventListener(ctrl, func)
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
function FriendInstallDlg:bindListener(name, func, root)
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

-- 判断当前点击的点是否在panelName控件上
function FriendInstallDlg:isContainTouchPos(panelName)
    Dialog.isContainTouchPos(self, panelName)
end

function FriendInstallDlg:getDlgNeedUpHeight()
    Dialog.getDlgNeedUpHeight(self)
end

function FriendInstallDlg:getBoundingBoxInWorldSpace(node)
    return Dialog.getBoundingBoxInWorldSpace(self, node)
end


return FriendInstallDlg
