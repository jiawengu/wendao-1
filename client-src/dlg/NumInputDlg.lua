-- NumInputDlg.lua
-- Created by Aug/19/2015
-- 数字输入框二

local NumInputDlg = Singleton("NumInputDlg", Dialog)

function NumInputDlg:init()
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

end

function NumInputDlg:cleanup()
    self:callBack("closeNumInputDlg", self.key)
end

-- 回调对象
function NumInputDlg:setObj(obj)
    self.obj = obj
end

-- 表示当前 key
function NumInputDlg:setKey(key)
    self.key = key
end

-- 设置对话框位置
function NumInputDlg:updatePosition(rect, displayPosition)
    -- 上边界的Y坐标
    local upY = rect.y  + rect.height
    local winSize = Const.WINSIZE
    local rootContentSize = self.root:getContentSize()
    rootContentSize.width = rootContentSize.width
    rootContentSize.height = rootContentSize.height
    local upImage = self:getControl("UpImage")
    local upContentSize = upImage:getContentSize()

    -- displayPosition若不为nil，则根据传入的参数值（“up” or “down”）直接决定对话框显示位置
    if displayPosition then
        if displayPosition == "down" then
            self:setCtrlVisible("UpImage", false)
            self:setCtrlVisible("DownImage", true)
            self.root:setPosition((rect.x + rect.width / 2), rect.y - rootContentSize.height / 2 - 15)
            return
        elseif displayPosition == "up" then
            self:setCtrlVisible("UpImage", true)
            self:setCtrlVisible("DownImage", false)
            self.root:setPosition((rect.x + rect.width / 2), rect.y  + rect.height +  rootContentSize.height / 2 + 15)
            return
        end
    end

    if upY + rootContentSize.height - upContentSize.height > winSize.height then
        -- 在下方显示
        self:setCtrlVisible("UpImage", false)
        self:setCtrlVisible("DownImage", true)
        self.root:setPosition((rect.x + rect.width / 2), rect.y - rootContentSize.height / 2 - 15)
    else
        self:setCtrlVisible("UpImage", true)
        self:setCtrlVisible("DownImage", false)
        self.root:setPosition((rect.x + rect.width / 2), rect.y  + rect.height +  rootContentSize.height / 2 + 15)
    end
end

function NumInputDlg:onButton(sender, eventType)
    local insetNumber
    if sender:getTag() == 10 then
        insetNumber = "00"
    elseif sender:getTag() == 11 then
        insetNumber = "0000"
    else
        insetNumber = sender:getTag()
    end

    self:callBack("insertNumber", insetNumber, self.key)
end

function NumInputDlg:onDeleteButton()
    self:callBack("deleteNumber", self.key)
end

function NumInputDlg:onAllDeleteButton()
    self:callBack("deleteAllNumber", self.key)
end

function NumInputDlg:onComfireButton()
    self:onCloseButton()
end


function NumInputDlg:callBack(funcName, ...)
    if self.obj == nil then return end
    local func = self.obj[funcName]
    if self.obj and func then
         func(self.obj, ...)
    end
end

function NumInputDlg:onCloseButton()
    DlgMgr:closeDlg(self.name)
end

return NumInputDlg
