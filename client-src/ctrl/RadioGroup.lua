-- RadioGroup.lua
-- Created by chenyq Jan/15/2015
-- 负责管理一组单选框

local RadioGroup = class("RadioGroup")

function RadioGroup:ctor()
    self.radios = {}
end

-- 设置单选框信息
-- dlg          对话框对象
-- radioNames   单选框名称列表
-- func         选中时的回调函数，function dlg:func(raido, idx)
-- selectSameFunc 选中和之前同一个回调
-- 界面中有很多地方，由于资源原因，功能时checkBox，但是控件是按钮，该接口支持按钮的单选框
-- 需要注意，按钮选中的图片资源控件名称需要一致，规则为，比如按钮叫做 xxxxButton，则选中图片叫做xxxxImage
-- notDef 为true时表示不需要默认选中
function RadioGroup:setItemsByButton(dlg, radioNames, func, root, selectSameFunc, notDef, limitFun)
    local function cb(dlg, sender, eventType)

        if limitFun then
            if not limitFun(dlg, sender, curIdx) then
                return
            end
        end

        local curIdx = 1
        for j = 1, #self.radios do
            local radio = self.radios[j]
            local ctlName = radio:getName()
            local key = string.match(ctlName, "(.+)Button")
            local selectImageName = key .. "Image"

            dlg:setCtrlVisible(selectImageName, radio == sender, root)
            if radio ~= sender then
            else
                curIdx = j
            end
        end

        if func then
            func(dlg, sender, curIdx)
        end

        Dialog.removeRedDot(dlg, sender)
    end

    self.radios = {}
    self.dlg = dlg
    self.cb = func
    for i = 1, #radioNames do
        local radio
        if type(radioNames[i]) == "userdata" then
            radio = radioNames[i]
        else
            radio = dlg:getControl(radioNames[i], nil, root)
        end

        dlg:bindTouchEndEventListener(radio, cb)
        table.insert(self.radios, radio)
    end

    -- 默认选中第一个
    if not notDef then
        local key = string.match(radioNames[1], "(.+)Button")
        local selectImageName = key .. "Image"
        dlg:setCtrlVisible(selectImageName, true, root)
    end
end



-- 设置单选框信息
-- dlg          对话框对象
-- radioNames   单选框名称列表
-- func         选中时的回调函数，function dlg:func(raido, idx)
-- selectSameFunc 选中和之前同一个回调
function RadioGroup:setItems(dlg, radioNames, func, root, selectSameFunc, selectFunc)
    local function cb(sender, eventType)
        local isRemovedRed = Dialog.removeRedDot(dlg, sender)
        if eventType == ccui.CheckBoxEventType.selected then
            if 'function' ~= type(selectFunc) or selectFunc(dlg, sender) then
                local curIdx = 1
                for j = 1, #self.radios do
                    local radio = self.radios[j]
                    if radio ~= sender then
                        radio:setSelectedState(false)
                    else
                        curIdx = j
                    end
                end

                if func then
                func(dlg, sender, curIdx, isRemovedRed)
                end
            else
                sender:setSelectedState(false)
            end
        else
            -- 选中被取消了
            -- 单选框中选中状态下点击仍然为选中状态
            sender:setSelectedState(true)

            if selectSameFunc then -- 如果选中同一个需要回调则回调
                selectSameFunc(dlg, sender)
            end
        end

        SoundMgr:playEffect("button")


    end

    self.radios = {}
    self.dlg = dlg
    self.cb = func
    for i = 1, #radioNames do
        local radio
        if type(radioNames[i]) == "userdata" then
            radio = radioNames[i]
        else
            radio = dlg:getControl(radioNames[i], Const.UICheckBox, root)
        end

        radio:addEventListener(cb)
        table.insert(self.radios, radio)
    end
end

-- setItems区别在于，响应已经选择的checkBox
function RadioGroup:setItemsCanReClick(dlg, radioNames, func, root)
    local function cb(sender, eventType)
        local isRemovedRed = Dialog.removeRedDot(dlg, sender)
        local curIdx = 1
        for j = 1, #self.radios do
            local radio = self.radios[j]
            if radio ~= sender then
                radio:setSelectedState(false)
            else
                curIdx = j
            end
        end

        local rState = 0
        if sender:getSelectedState() then
            rState = 1
        end

        sender:setSelectedState(true)

        SoundMgr:playEffect("button")

        if func then
            -- rState 点击之前，该check的状态
            func(dlg, sender, curIdx, isRemovedRed, rState)
        end
    end

    self.radios = {}
    self.dlg = dlg
    self.cb = func
    for i = 1, #radioNames do
        local radio = dlg:getControl(radioNames[i], Const.UICheckBox, root)
        radio:addEventListener(cb)
        table.insert(self.radios, radio)
    end
end

-- 选中指定框通过名字 按钮类型
function RadioGroup:setSetlctButtonByName(name)
    local num = #self.radios


    for j = 1, num do
        local radio = self.radios[j]
        local ctlName = radio:getName()
        local key = string.match(ctlName, "(.+)Button")
        local selectImageName = key .. "Image"

        self.dlg:setCtrlVisible(selectImageName, radio:getName() == name)
    end

end

-- 选中指定框通过名字
function RadioGroup:setSetlctByName(name, noCallback)
    local num = #self.radios
    local idx

    for j = 1, num do
        local radio = self.radios[j]

        if radio:getName() == name then
            radio:setSelectedState(true)
            idx = j
        else
            radio:setSelectedState(false)
        end
    end

    if self.cb and not noCallback then
        self.cb(self.dlg, self.radios[idx], idx)
    end
end

-- 选中指定的单选框
function RadioGroup:selectRadio(idx, noCallback)
    local num = #self.radios
    if idx > num or idx < 1 then
        return
    end

    for j = 1, num do
        local radio = self.radios[j]
        radio:setSelectedState(j == idx)
    end

    if self.cb and not noCallback then
        self.cb(self.dlg, self.radios[idx], idx)
    end
end

-- 将所有设置为未选中状态
function RadioGroup:unSelectedRadio()
    local num = #self.radios

    for j = 1, num do
        local radio = self.radios[j]
        radio:setSelectedState(false)
    end
end

-- 获取选中的单选按钮
function RadioGroup:getSelectedRadio()
    for j = 1, #self.radios do
        local radio = self.radios[j]
        if radio:getSelectedState() then
            return radio
        end
    end
end

-- 获取选中的单选索引
function RadioGroup:getSelectedRadioIndex()
    for j = 1, #self.radios do
        local radio = self.radios[j]
        if radio:getSelectedState() then
            return j
        end
    end
end

-- 获取选中的单选按钮的名字
function RadioGroup:getSelectedRadioName()
    local radio = self:getSelectedRadio()
    if radio then
        return radio:getName()
    end
end

-- 根据索引获取指定Check
function RadioGroup:getRadioNameIndex(index)
    return self.radios[index]
end

return RadioGroup
