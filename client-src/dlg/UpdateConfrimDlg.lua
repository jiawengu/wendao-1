-- UpdateConfrimDlg.lua
-- Created by zhengjh Sep/2015/17
-- 更新确认框

local UpdateConfrimDlg = class("UpdateConfrimDlg", function()
    return ccui.Layout:create()
end)

local DLG_TYPE =
{
    CHANNEL_CONFIRM = 1,
    UPDATE_NOTE = 2,
    UPDATE_CONFIRM = 3,
}
function UpdateConfrimDlg:create()
    local dlg = UpdateConfrimDlg.new()
    return dlg
end

function UpdateConfrimDlg:ctor()
    local size = cc.Director:getInstance():getWinSize()
    local runScene =  cc.Director:getInstance():getRunningScene()
    local jsonName =  "ui/UpdateConfrimDlg.json"
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(jsonName)
    self.root:setAnchorPoint(0.5, 0.5)
    self.root:setPosition(size.width / 2, size.height / 2)

    local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 153))
    colorLayer:setContentSize(size)
    colorLayer:addChild(self.root)

    self:addChild(colorLayer)

    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)
end

-- 更新提示框
function UpdateConfrimDlg:setInfo(size, obj, cancelFunc, confirmFunc)
    self.dlgType = DLG_TYPE.UPDATE_NOTE
    self.obj = obj
    self.cancelFunc = cancelFunc
    self.confirmFunc = confirmFunc
    local m = size / (1024 * 1024)

    local sizeStr = ""
    if m > 1 then
        sizeStr = string.format("%0.2fMB", m)
    else
        local k = math.ceil(size / 1024)
        sizeStr = string.format("%dKB", k)
    end

    local str = string.format(CHSUP[3000144], sizeStr)
    local notelabel = self:getControl("NoteLabel_1")
    notelabel:setString(str)
    local noteLabel2 = self:getControl("NoteLabel_2")
    noteLabel2:setVisible(true)
end

-- 输入渠道错误确认框
function UpdateConfrimDlg:setChannelInfo(obj, func)
    self.dlgType = DLG_TYPE.CHANNEL_CONFIRM
    self.obj = obj
    self.func = func
    local str = CHSUP[5000225]
    local notelabel = self:getControl("NoteLabel_1")
    notelabel:setString(str)
    local noteLabel2 = self:getControl("NoteLabel_2")
    noteLabel2:setVisible(false)
end

-- 更新提示框中，点击取消后再次弹出的确认提示框
function UpdateConfrimDlg:setUpdateConfirmInfo(obj, cancelFunc, para)

    self.obj2 = obj
    self.cancelFunc2 = cancelFunc
    self.cancelFunc2_para = para

    self.cancel = false
    self.dlgType = DLG_TYPE.UPDATE_CONFIRM
    local noteLabel = self:getControl("NoteLabel_1")
    noteLabel:setString(CHSUP[7000038])
    local noteLabel2 = self:getControl("NoteLabel_2")
    noteLabel2:setString(CHSUP[7000039])
end

-- 获取控件
function UpdateConfrimDlg:getControl(name, type, root)
    root = root or self.root
    local widget = ccui.Helper:seekWidgetByName(root, name)
    return widget
end


-- 控件绑定事件
function UpdateConfrimDlg:bindListener(name, func, root)
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

-- 为指定的控件对象绑定 TouchEnd 事件
function UpdateConfrimDlg:bindTouchEndEventListener(ctrl, func, data)
    if not ctrl then
        Log:W("Dialog:bindTouchEndEventListener no control ")
        return
    end

    -- 事件监听
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            func(self, sender, eventType, data)
        end
    end

    ctrl:addTouchEventListener(listener)
end

function UpdateConfrimDlg:onCancelButton(sender, eventType)
    if self.dlgType == DLG_TYPE.CHANNEL_CONFIRM then
        self.func(self.obj)
        self:removeFromParent()
    elseif self.dlgType == DLG_TYPE.UPDATE_NOTE then  -- 点击取消后，继续弹出对话框
        self.cancelFunc(self.obj)
    elseif self.dlgType == DLG_TYPE.UPDATE_CONFIRM then
        self.cancelFunc2(self.obj2, self.cancelFunc2_para)
        self:removeFromParent()
    end
end

function UpdateConfrimDlg:onConfrimButton(sender, eventType)
    if self.dlgType then
        if self.dlgType == DLG_TYPE.CHANNEL_CONFIRM then
            self:removeFromParent()
        elseif self.dlgType == DLG_TYPE.UPDATE_NOTE then  -- 下载补丁、进入游戏
            self.confirmFunc(self.obj)
            self:removeFromParent()
        elseif self.dlgType == DLG_TYPE.UPDATE_CONFIRM then  --直接退出游戏
            performWithDelay(cc.Director:getInstance():getRunningScene(), function()
                ccs.ActionManagerEx:destroyInstance()
                ccs.GUIReader:destroyInstance()
                ccs.SceneReader:destroyInstance()
                ccs.NodeReader:destroyInstance()
                ccs.ArmatureDataManager:destroyInstance()
                cc.Director:getInstance():endToLua()
                if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
                    cc.Director:getInstance():mainLoop()
                end
            end, 0.1)
        end
    end
end

return UpdateConfrimDlg
