-- SmallNumInputDlg.lua
-- Created by zhengjh Dec/2/2015
-- 小的数字键盘

local SmallNumInputDlg = Singleton("SmallNumInputDlg", Dialog)

local OFF_Y = 10 -- 偏移的y

function SmallNumInputDlg:init()
    self:bindListener("1Button", self.onButton)
    self:bindListener("2Button", self.onButton)
    self:bindListener("3Button", self.onButton)
    self:bindListener("4Button", self.onButton)
    self:bindListener("5Button", self.onButton)
    self:bindListener("6Button", self.onButton)
    self:bindListener("7Button", self.onButton)
    self:bindListener("8Button", self.onButton)
    self:bindListener("9Button", self.onButton)
    self:bindListener("DeleteButton", self.onDeleteButton)
    self:bindListener("ComfireButton", self.onComfireButton)
    self:bindListener("0Button", self.onButton)
    self.inputValue = 0
    self.key = nil
    self.isString = false
end

-- 回调对象
function SmallNumInputDlg:setObj(obj)
    self.obj = obj
end

function SmallNumInputDlg:setKey(key)
    self.key = key
end

function SmallNumInputDlg:setIsString(isString)
    self.isString = isString

    if self.isString then
        self.inputValue = ""
    else
        self.inputValue = 0
    end
end

-- 设置对话框位置
function SmallNumInputDlg:updatePosition(rect, displayPosition)
    -- 上边界的Y坐标
    local upY = rect.y  + rect.height
    local winSize = Const.WINSIZE
    local rootContentSize = self.root:getContentSize()
    rootContentSize.width = rootContentSize.width * 0.9
    rootContentSize.height = rootContentSize.height * 0.9
    local upImage = self:getControl("UpImage")
    local upContentSize = upImage:getContentSize()

    -- displayPosition若不为nil，则根据传入的参数值（“up” or “down”）直接决定对话框显示位置
    if displayPosition then
        if displayPosition == "down" then
            self:setCtrlVisible("UpImage", false)
            self:setCtrlVisible("DownImage", true)
            self.root:setPosition((rect.x + rect.width / 2), rect.y - rootContentSize.height / 2)
            return
        elseif displayPosition == "up" then
            self:setCtrlVisible("UpImage", true)
            self:setCtrlVisible("DownImage", false)
            self.root:setPosition((rect.x + rect.width / 2), rect.y  + rect.height +  rootContentSize.height / 2)
            return
        end
    end

    if upY + rootContentSize.height - upContentSize.height > winSize.height then
        -- 在下方显示
        self:setCtrlVisible("UpImage", false)
        self:setCtrlVisible("DownImage", true)
        self.root:setPosition((rect.x + rect.width / 2), rect.y - rootContentSize.height / 2)
    else
        self:setCtrlVisible("UpImage", true)
        self:setCtrlVisible("DownImage", false)
        self.root:setPosition((rect.x + rect.width / 2), rect.y  + rect.height +  rootContentSize.height / 2)
    end

    if rect.x + self.root:getContentSize().width * 0.5 > Const.WINSIZE.width then
        local panel = self:getControl("NumInputPanel")
        local curX = panel:getPositionX()

        panel:setPositionX(curX - (rect.x + self.root:getContentSize().width * 0.5 - Const.WINSIZE.width) - 20)
    end
end

function SmallNumInputDlg:cleanup()
    self:callBack("closeNumInputDlg", self.key)
end

function SmallNumInputDlg:onButton(sender, eventType)
    local insetNumber = sender:getTag()
    if self.isString then
        self.inputValue = self.inputValue .. tostring(insetNumber)
    else
        self.inputValue = self.inputValue * 10 + insetNumber
    end
    self:callBack("insertNumber", self.inputValue, self.key, "append")
end

function SmallNumInputDlg:onDeleteButton()
    if self.isString then
        if self.inputValue and string.len(self.inputValue) > 0 then
            self.inputValue = string.sub(self.inputValue, 1, -2)
        end
    else
        self.inputValue = math.floor(self.inputValue / 10)
    end

    self:callBack("insertNumber", self.inputValue, self.key, "delete")
end


function SmallNumInputDlg:onComfireButton()
    self:onCloseButton()
end

function SmallNumInputDlg:onCloseButton()
    self:callBack("comfireNumber", self.key)
    DlgMgr:closeDlg(self.name)
end

function SmallNumInputDlg:setInputValue(value)
     self.inputValue = value
end

function SmallNumInputDlg:callBack(funcName, ...)
    if self.obj == nil then return end
    local func = self.obj[funcName]
    local realNum
    if self.obj and func then
        realNum = func(self.obj, ...)
    end

    if "number" == type(realNum) then
        self:setInputValue(realNum)
    end
end


return SmallNumInputDlg
