-- TextView.lua
-- Created by sujl, Mar/10/2017
-- 多行文本输入

local TextView = class('TextView')

function TextView:ctor(dlg, panel, root, fontSize, sv)
    local back = dlg:getControl(panel, nil, root)
    local showText = dlg:getControl('ShowText', Const.UILabel, back)
    local scrollView = sv and dlg:getControl(sv, nil, root)
    if scrollView then
        local clickTime
        local function listener(sender, eventType)
            if eventType == ccui.TouchEventType.began then
                clickTime = gf:getTickCount()
            elseif eventType == ccui.TouchEventType.moved then
            elseif eventType == ccui.TouchEventType.ended then
                if clickTime and gf:getTickCount() - clickTime < 200 then
                    self:onClick(dlg, sender, eventType)
                end
            end
        end

        scrollView:addTouchEventListener(listener)
    end
    local showPanel
    if not showText then
        showPanel = dlg:getControl('ShowPanel', Const.UIPanel, back)
        showPanel:setAnchorPoint(cc.p(0, 1))
    end

    self.showText = function(str)
        if showText then
            showText:setString(str)
        elseif showPanel then
            Dialog.setColorText(dlg, str, showPanel, nil, nil, nil, self.fontColor, fontSize)

            if scrollView then
                local panelSize = showPanel:getContentSize()
                scrollView:setInnerContainerSize(panelSize)
                if panelSize.height < scrollView:getContentSize().height then
                    showPanel:setPositionY(scrollView:getContentSize().height - panelSize.height)
                else
                    showPanel:setPositionY(0)
                end
            end
        end
    end

    self.showTextColor = function(color3)
        if showText then
            showText:setColor(color3)
        elseif showPanel then
            self.fontColor = color3
            Dialog.setColorText(dlg, self.editBox:getText(), showPanel, nil, nil, nil, self.fontColor, fontSize)
        end
    end

    self.setTextVisible = function(visible)
        if showText then
            showText:setVisible(visible)
        elseif showPanel then
            showPanel:setVisible(visible)
        end
    end

    local function editBoxListner(obj, event, sender)
        if 'ended' == event then
            if self.editBox then
                self.editBox:setVisible(false)
                self.showText(self.editBox:getText())
            end

            self.setTextVisible(true)
            if self.func then self.func(dlg, sender, event) end
        elseif 'changed' == event then
            -- 移除换行符 WDSY-34713
            local txt = self.editBox:getText()
            txt = string.gsub(txt, "\n", "")
            txt = string.gsub(txt, "\r", "")
            self.editBox:setText(txt)
            if self.func then self.func(dlg, sender, event) end
        elseif 'began' == event then
            self.setTextVisible(false)
            if self.func then self.func(dlg, sender, event) end
        end
    end

    dlg:bindListener(panel, function(obj, sender, eventType)
        self:onClick(obj, sender, eventType)
    end)

    self.editBox = dlg:createEditBox('EditPanel', back, nil, editBoxListner)
    self.editBox:setVisible(false)
    self.editBox:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    dlg:getControl("EditPanel", nil, back):setClippingEnabled(true)
    self.editBox:setFontSize(fontSize)
    self.editBox:setFontColor(COLOR3.TEXT_DEFAULT)
end

function TextView:onClick(obj, sender, eventType)
    if self.editBox and (not self.clickLimitFunc or self.clickLimitFunc()) then
        self.editBox:setVisible(true)
        self.editBox:openKeyboard()
    end
end

function TextView:setClickLimit(func)
    self.clickLimitFunc = func
end

function TextView:bindListener(func)
    self.func = func
end

function TextView:getText()
    if self.editBox then
        return self.editBox:getText()
    end
end

function TextView:setText(str)
    if self.editBox then
        self.editBox:setText(str)
    end

    -- 初始化文本
    self.showText(str)
end

function TextView:setFontColor(color)
    if self.editBox then
        self.editBox:setFontColor(color)
    end

    self.showTextColor(color)
end

function TextView:openKeyboard()
    if self.editBox then
        self.editBox:openKeyboard()
    end
end

function TextView:closeKeyboard()
    if self.editBox then
        self.editBox:closeKeyboard()
    end
end

return TextView