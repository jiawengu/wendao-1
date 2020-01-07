-- NumInputExDlg.lua
-- Created by Aug/19/2015
-- 数字输入框二的扩展，直接返回计算后的数值

local NumInputDlg = require('dlg/NumInputDlg')
local NumInputExDlg = Singleton("NumInputExDlg", NumInputDlg)

function NumInputExDlg:init()
    self:bindListener("1Button", self.onButton)
    self:bindListener("2Button", self.onButton)
    self:bindListener("3Button", self.onButton)
    self:bindListener("4Button", self.onButton)
    self:bindListener("5Button", self.onButton)
    self:bindListener("6Button", self.onButton)
    self:bindListener("0Button", self.onButton)
    self:bindListener("7Button", self.onButton)
    self:bindListener("8Button", self.onButton)
    self:bindListener("9Button", self.onButton)
    self:bindListener("00Button", self.onButton)
    self:bindListener("0000Button", self.onButton)
    self:bindListener("ComfireButton", self.onComfireButton)
    self:bindPressForIntervalCallback('DeleteButton', 0.1, self.onDeleteButton, 'times')
    self:bindListener("AllDeleteButton", self.onAllDeleteButton)
    self.inputValue = ""
end

function NumInputExDlg:getCfgFileName()
    return ResMgr:getDlgCfg("NumInputDlg")
end

function NumInputExDlg:cleanup()
    self:callBack("closeNumInputDlg", self.key)
end

function NumInputExDlg:setIsString(isString)
    self.isString = isString
    self.inputValue = ""
end

function NumInputExDlg:onButton(sender, eventType)
    local tag = sender:getTag()
    if tag == 10 then
        self.inputValue = self.inputValue .. "00"
        self:updateNum("00")
    elseif tag == 11 then
        self.inputValue = self.inputValue .. "0000"
        self:updateNum("0000")
    else
        self.inputValue = self.inputValue .. tag
        self:updateNum(tostring(tag))
    end
end

function NumInputExDlg:onDeleteButton()
    if self.inputValue and string.len(self.inputValue) > 0 then
        self.inputValue = string.sub(self.inputValue, 1, -2)
    end

    self:updateNum("del")
end

function NumInputExDlg:onAllDeleteButton()
    self.inputValue = ""

    self:updateNum("delAll")
end

function NumInputExDlg:setInputValue(value)
    self.inputValue = tostring(value)
end

function NumInputExDlg:updateNum(oper)
    local num = self.inputValue
    if not self.isString then
        num = tonumber(num)
        
        if not num then
            num = 0
            self.inputValue = ""
        end
    end

    self:callBack("insertNumber", num, self.key, oper)
end

function NumInputExDlg:callBack(funcName, ...)
    if self.obj == nil then return end
    local func = self.obj[funcName]
    if self.obj and func then
        local realNum = func(self.obj, ...)

        if tonumber(realNum) then
            self:setInputValue(realNum)
        end
    end
end

return NumInputExDlg
