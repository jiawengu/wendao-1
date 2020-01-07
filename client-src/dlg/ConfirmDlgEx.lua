-- ConfirmDlgExEx.lua
-- created by cheny Nov/29/2014
-- 确认框 更新界面之前使用

local ConfirmDlgEx = class("UpdateConfrimDlg", function()
    return ccui.Layout:create()
end)

local WORD_LIMIT = 14

function ConfirmDlgEx:create()
    local dlg = ConfirmDlgEx.new()
    return dlg
end

function ConfirmDlgEx:ctor()
    local size = cc.Director:getInstance():getWinSize()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/ConfirmDlg.json")
    self.root:setAnchorPoint(0.5, 0.5)
    self.root:setPosition(size.width / 2, size.height / 2)
    self:addChild(self.root)

    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("CloseButton", self.onCancelButton)
    local ctrl = self:getControl("InputPanel")
    ctrl:setVisible(true)
    local inputText = self:getControl("InputTextField")
    inputText:setPlaceHolder(CHSUP[5000226])
    inputText:setVisible(true)

    inputText:addEventListener(function(sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType then
            local str = inputText:getStringValue()
            if gf and gf:getTextLength(str) > WORD_LIMIT * 2 then
                local str = gf:subString(str, WORD_LIMIT * 2)
                inputText:setText(tostring(str))
                gf:ShowSmallTips(CHSUP[2100001])
            end
        end
    end)
end

function ConfirmDlgEx:setTipText(text)
    local inputText = self:getControl("InputTextField")
    inputText:setPlaceHolder(text)
end

function ConfirmDlgEx:setCallBack(func, cancelfunc)
    self.func = func
    self.cancelfunc = cancelfunc
end

function ConfirmDlgEx:onConfirmButton()
    local input = ""
    local textField = self:getControl("InputTextField")
    if textField then
        input = textField:getStringValue()
    end

    if "function" == type(self.func) then
        self.func(input)
    end
end

function ConfirmDlgEx:onCancelButton()
    if 'function' == type(self.cancelfunc) then
        self.cancelfunc()
    end
end

-- 获取控件
function ConfirmDlgEx:getControl(name, widgetType, root)
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

-- 控件绑定事件
function ConfirmDlgEx:bindListener(name, func, root)
    if nil == func then
        return
    end

    -- 获取子控件
    local widget = self:getControl(name, nil, root)
    if nil == widget then
        return
    end

    -- 事件监听
    self:bindTouchEndEventListener(widget, func)
end

function ConfirmDlgEx:bindTouchEndEventListener(ctrl, func, data)
    if not ctrl then
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

return ConfirmDlgEx
